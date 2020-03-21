require "./spec_helper"

describe TextUi::Dialog do
  it "closes if a non-child widget get focus" do
    ui = init_ui(10, 4)
    label = TextUi::Label.new(ui, "Hey")
    dlg = TextUi::Dialog.new(ui, "Dlg!", TextUi::Dialog::Placement::Manual)
    dlg.move(0, 1)
    dlg.resize(10, 3)

    ui.children.size.should eq(2)
    dlg.focus
    dlg.focused?.should eq(true)
    ui.render
    Terminal.to_s.should eq("Hey       \n" \
                            "╭─ Dlg! ─╮\n" \
                            "│        │\n" \
                            "╰────────╯\n")

    label.focus
    ui.children.size.should eq(1)
    label.focused?.should eq(true)

    ui.render
    Terminal.to_s.should eq("Hey       \n" \
                            "          \n" \
                            "          \n" \
                            "          \n")
  end
end
