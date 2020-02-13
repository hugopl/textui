require "./spec_helper"

describe TextUi::Widget do
  it "invalidate widget if visible attribute turns true" do
    ui = init_ui(4, 1)
    label = TextUi::Label.new(ui)
    label.resize(4, 1)
    ui.render
    label.render_pending?.should eq(false)
    label.visible = false
    label.render_pending?.should eq(false)
    label.visible = true
    label.render_pending?.should eq(true)
  end

  it "can focus a widget with a shortcut" do
    ui = init_ui(4, 1)
    label = TextUi::Label.new(ui)
    label.resize(4, 1)
    label.focused?.should eq(false)

    ui.add_focus_shortcut(TextUi::KEY_CTRL_A, label)
    Terminal.inject_key_event(key: TextUi::KEY_CTRL_A)
    ui.process_queued_events
    label.focused?.should eq(true)
  end

  it "children_focused? returns true on gran...granchildren" do
    ui = init_ui(4, 1)
    box1 = TextUi::Label.new(ui)
    box2 = TextUi::Label.new(box1)
    box3 = TextUi::Label.new(box2)
    box4 = TextUi::Label.new(box3)
    box4.focus

    ui.children_focused?.should eq(true)
    box1.children_focused?.should eq(true)
    box2.children_focused?.should eq(true)
    box3.children_focused?.should eq(true)
  end

  context "when printing strings" do
    it "obey alignment on line feed" do
      ui = init_ui(12, 3)
      ui.print_lines(1, 1, "LineFeed\nHere")
      Terminal.to_s.should eq("            \n" \
                              " LineFeed   \n" \
                              " Here       \n")
    end

    it "prints line feed if stopped at it" do
      ui = init_ui(12, 3)
      ui.print_line(1, 1, "LineFeed\nHere", width: 11)
      Terminal.to_s.should eq("            \n" \
                              " LineFeed↵H…\n" \
                              "            \n")
    end

    it "replaces \\r by ␍" do
      ui = init_ui(7, 1)
      ui.print_lines(0, 0, "CR\rhere")
      Terminal.to_s.should eq("CR␍here\n")
    end

    it "prints ellipsis if the text is too long" do
      ui = init_ui(4, 1)
      ui.print_line(0, 0, "123456", width: 4)
      Terminal.to_s.should eq("123…\n")
    end

    it "does not prints ellipsis if the text is exact the width size" do
      ui = init_ui(4, 1)
      ui.print_line(0, 0, "1234", width: 4)
      Terminal.to_s.should eq("1234\n")
      ui.print_lines(0, 0, "1234", width: 4)
      Terminal.to_s.should eq("1234\n")
    end

    it "does not jump a line when linefeed is at width limits" do
      ui = init_ui(4, 2)
      ui.print_lines(0, 0, "1234\n5")
      Terminal.to_s.should eq("1234\n" \
                              "5   \n")
    end
  end

  context "when rendering children" do
    it "obey children coordinates" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box3 = TextUi::Box.new(box2, 1, 1, 12, 5, "box3")
      ui.render
      box3.print_line(5, 2, "Hi")
      Terminal.to_s.should eq("                  \n" \
                              "                  \n" \
                              "  ╭─ box1 ───────╮\n" \
                              "  │╭─ box2 ─────╮│\n" \
                              "  ││╭─ box3 ───╮││\n" \
                              "  │││          │││\n" \
                              "  │││    Hi    │││\n" \
                              "  │││          │││\n" \
                              "  ││╰──────────╯││\n" \
                              "  │╰────────────╯│\n" \
                              "  ╰──────────────╯\n")
    end

    it "prints ellipsis on nested children" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box3 = TextUi::Box.new(box2, 1, 1, 12, 5, "box3")
      ui.render
      box3.print_lines(5, 2, "123456789", width: 6)
      Terminal.to_s.should eq("                  \n" \
                              "                  \n" \
                              "  ╭─ box1 ───────╮\n" \
                              "  │╭─ box2 ─────╮│\n" \
                              "  ││╭─ box3 ───╮││\n" \
                              "  │││          │││\n" \
                              "  │││    12345…│││\n" \
                              "  │││          │││\n" \
                              "  ││╰──────────╯││\n" \
                              "  │╰────────────╯│\n" \
                              "  ╰──────────────╯\n")
    end

    it "does not render cursor out of widget area" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box2.set_cursor(0, 0)
      Terminal.cursor.should eq({x: 3, y: 3})
      box2.set_cursor(0, -1)
      Terminal.cursor.should eq({x: -1, y: -1})
      box2.set_cursor(20, 30)
      Terminal.cursor.should eq({x: -1, y: -1})
    end
  end
end
