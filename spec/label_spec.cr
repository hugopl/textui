require "./spec_helper"

describe TextUi::Label do
  it "aligns a single line fo text" do
    ui = init_ui(10, 1)
    label = TextUi::Label.new(ui, "Hey")
    label.resize(10, 1)

    label.alignment.should eq(TextUi::Alignment::Left)
    ui.render
    Terminal.to_s.should eq("Hey       \n")

    label.alignment = TextUi::Alignment::Right
    label.invalidate
    ui.render
    Terminal.to_s.should eq("       Hey\n")

    label.alignment = TextUi::Alignment::Center
    label.invalidate
    ui.render
    Terminal.to_s.should eq("   Hey    \n")
  end

  it "new labels has the size of their contents, ignoring \n" do
    ui = init_ui(10, 1)
    label = TextUi::Label.new(ui, "Hey")
    label.width.should eq(3)
    label.height.should eq(1)
  end
end
