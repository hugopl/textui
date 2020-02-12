require "./spec_helper"

describe "TextEditor Undo/Redo" do
  it "can undo/redo line changes" do
    ui = init_ui(20, 1)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 1)
    editor.word_wrap = true
    editor.undo_stack_merge_interval = 200
    editor.focus

    "Hello".each_char do |char|
      Terminal.inject_key_event(char)
    end
    ui.process_queued_events
    ui.render
    sleep(0.250)
    " World".each_char do |char|
      Terminal.inject_key_event(char)
    end
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hello World         \n")
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hello               \n")
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Y)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hello World         \n")
    # Should not crash if there'snothing to redo
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Y)
    ui.process_queued_events

    # Should not crash if there'snothing to undo
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("                    \n")
  end

  it "does not merge commands that increase the text size with commands that decrease it" do
    ui = init_ui(20, 1)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 1)
    editor.word_wrap = true
    editor.undo_stack_merge_interval = 200
    editor.focus
    "Hello".each_char do |char|
      Terminal.inject_key_event(char)
    end
    Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hell                \n")

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hello               \n")

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("                    \n")
  end

  it "changing editor contents reset undo/redo stack" do
    ui = init_ui(10, 1)
    editor = TextUi::TextEditor.new(ui, 0, 0, 10, 1)
    editor.focus
    Terminal.inject_key_event('A')
    ui.process_queued_events
    ui.render
    editor.text = "B"
    editor.document.can_undo?.should eq(false)
    editor.document.can_redo?.should eq(false)
  end

  it "can undo/redo line removals" do
    ui = init_ui(10, 4)
    editor = TextUi::TextEditor.new(ui, 0, 0, 10, 4)
    editor.focus
    editor.text = "\nOne\nTwo\nThree"

    editor.cursor.move(1, 0)
    Terminal.inject_key_event(key: TextUi::KEY_END)
    Terminal.inject_key_event(key: TextUi::KEY_DELETE)
    Terminal.inject_key_event(key: TextUi::KEY_HOME)
    Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("OneTwo    \n" \
                            "Three     \n" \
                            "~         \n" \
                            "~         \n")
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    # FIXME: Merge of line removal (concat) command not implemented yet.
    Terminal.to_s.should eq("          \n" \
                            "OneTwo    \n" \
                            "Three     \n" \
                            "~         \n")
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("          \n" \
                            "One       \n" \
                            "Two       \n" \
                            "Three     \n")
  end

  it "can undo/redo line insertions" do
    ui = init_ui(10, 4)
    editor = TextUi::TextEditor.new(ui, 0, 0, 10, 4)
    editor.focus
    editor.text = "OneTwo"
    editor.cursor.move(0, 3)
    Terminal.inject_key_event(key: TextUi::KEY_ENTER)
    Terminal.inject_key_event(key: TextUi::KEY_ENTER)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("One       \n" \
                            "          \n" \
                            "Two       \n" \
                            "~         \n")
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("One       \n" \
                            "Two       \n" \
                            "~         \n" \
                            "~         \n")
    # FIXME: Merge of line insertion command not implemented yet.
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("OneTwo    \n" \
                            "~         \n" \
                            "~         \n" \
                            "~         \n")
  end
end
