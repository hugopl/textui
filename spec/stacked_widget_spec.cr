require "./spec_helper"

describe TextUi::StackedWidget do
  it "does not hide first child widget" do
    ui = init_ui(10, 1)
    stack = TextUi::StackedWidget.new(ui)
    label = TextUi::Label.new(stack, "Hey")
    label.visible?.should eq(true)
  end

  it "resize children upon insertion" do
    ui = init_ui(10, 1)
    stack = TextUi::StackedWidget.new(ui)
    stack.resize(10, 1)
    label = TextUi::Label.new(stack, "Hey")
    label.width.should eq(10)
    label.height.should eq(1)
  end

  it "have only one visible widget at a time" do
    ui = init_ui(10, 1)
    stack = TextUi::StackedWidget.new(ui)
    label1 = TextUi::Label.new(stack, "Hey")
    label2 = TextUi::Label.new(stack, "Ho")
    label3 = TextUi::Label.new(stack, "Let's Go!")
    label1.visible?.should eq(true)
    label2.visible?.should eq(false)
    label3.visible?.should eq(false)

    stack.current_index = 1
    label1.visible?.should eq(false)
    label2.visible?.should eq(true)
    label3.visible?.should eq(false)

    stack.current_index = 2
    label1.visible?.should eq(false)
    label2.visible?.should eq(false)
    label3.visible?.should eq(true)
  end

  it "resize all children" do
    ui = init_ui(10, 2)
    stack = TextUi::StackedWidget.new(ui)
    label1 = TextUi::Label.new(stack, "Hey")
    label2 = TextUi::Label.new(stack, "Ho")
    stack.resize(5, 2)

    label1.width.should eq(5)
    label1.height.should eq(2)
    label2.width.should eq(5)
    label2.height.should eq(2)
  end

  it "cycle widgets" do
    ui = init_ui(10, 2)
    stack = TextUi::StackedWidget.new(ui)
    label1 = TextUi::Label.new(stack, "Hey")
    label2 = TextUi::Label.new(stack, "Ho")
    label3 = TextUi::Label.new(stack, "Let's Go!")

    stack.cycle
    stack.current_index.should eq(1)
    label1.visible?.should eq(false)
    label2.visible?.should eq(true)
    label3.visible?.should eq(false)

    stack.cycle
    stack.current_index.should eq(2)
    label1.visible?.should eq(false)
    label2.visible?.should eq(false)
    label3.visible?.should eq(true)

    stack.cycle
    stack.current_index.should eq(0)
    label1.visible?.should eq(true)
    label2.visible?.should eq(false)
    label3.visible?.should eq(false)
  end
end
