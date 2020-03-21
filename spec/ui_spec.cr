require "./spec_helper"

describe TextUi::Ui do
  it "clear needs_rendering flag after render" do
    ui = init_ui(2, 2)
    ui.render_pending?.should eq(true)
    ui.render
    ui.render_pending?.should eq(false)
  end

  it "clear terminal on invalidate" do
    ui = init_ui(2, 2)
    label = TextUi::Label.new(ui, "A")
    ui.render
    Terminal.to_s.should eq("A \n  \n")
    Terminal.clear('X')
    Terminal.to_s.should eq("XX\nXX\n")
    ui.invalidate
    ui.render
    Terminal.to_s.should eq("A \n  \n")
  end
end
