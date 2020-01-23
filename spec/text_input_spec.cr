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
end
