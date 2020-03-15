require "./spec_helper"

describe Box do
  it "focus the first children when focused" do
    ui = init_ui(18, 11)
    box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "Box 1")
    box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "Box 2")
    box3 = TextUi::Box.new(box2, 1, 1, 12, 5, "Box 3")
    label = TextUi::Label.new(box3, 1, 1, "Hey")

    Terminal.inject_mouse_event(2, 2)
    ui.process_queued_events
    label.focused?.should eq(true)

    Terminal.inject_mouse_event(3, 3)
    ui.process_queued_events
    label.focused?.should eq(true)

    Terminal.inject_mouse_event(4, 4)
    ui.process_queued_events
    label.focused?.should eq(true)

    Terminal.inject_mouse_event(5, 5)
    ui.process_queued_events
    label.focused?.should eq(true)
  end
end
