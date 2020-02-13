require "./spec_helper"

describe TextUi::TextInput do
  it "render place holder if there's no input" do
    ui = init_ui(4, 1)
    input = TextUi::TextInput.new(ui)
    input.resize(4, 1)
    input.place_holder = "Hi!"
    ui.render
    Terminal.to_s.should eq(" Hi!\n")
    input.focus
    input.invalidate
    ui.render
    Terminal.to_s.should eq(" Hi!\n")

    input.text = "?"
    ui.render
    Terminal.to_s.should eq("?   \n")
  end

  it "supports undo/redo" do
    ui = init_ui(10, 1)
    input = TextUi::TextInput.new(ui)
    input.resize(10, 1)
    input.focus

    "Hey ho!".each_char do |chr|
      Terminal.inject_key_event(chr)
    end
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hey ho!   \n")

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Z)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("          \n")

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_Y)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Hey ho!   \n")
  end

  it "emit ENTER KEY signal" do
    ui = init_ui(10, 1)
    input = TextUi::TextInput.new(ui)
    input.resize(10, 1)
    input.focus

    received = false
    input.key_typed.on do
      received = true
    end
    Terminal.inject_key_event(key: TextUi::KEY_ENTER)
    ui.process_queued_events
    received.should eq(true)
  end
end
