require "./spec_helper"

class Calc
  property value : Int32 = 0
end

class Sum < TextUi::UndoCommand
  property value

  def initialize(@calc : Calc, @value : Int32)
  end

  def merge(cmd : Sum) : Bool
    @value += cmd.value
    true
  end

  def redo : Nil
    @calc.value += @value
  end

  def undo : Nil
    @calc.value -= @value
  end
end

class Multiply < TextUi::UndoCommand
  def initialize(@calc : Calc, @value : Int32)
  end

  def redo : Nil
    @calc.value *= @value
  end

  def undo : Nil
    @calc.value //= @value
  end
end

describe TextUi::UndoStack do
  it "can undo/redo commands" do
    stack = TextUi::UndoStack.new
    stack.merge_interval = -1
    stack.can_undo?.should eq(false)
    stack.can_redo?.should eq(false)

    calc = Calc.new
    stack.push(Sum.new(calc, 3))
    calc.value.should eq(3)
    stack.push(Multiply.new(calc, 2))
    stack.can_redo?.should eq(false)
    calc.value.should eq(6)

    stack.undo
    stack.can_redo?.should eq(true)
    calc.value.should eq(3)

    stack.redo
    calc.value.should eq(6)

    stack.undo
    calc.value.should eq(3)
    stack.can_undo?.should eq(true)

    stack.undo
    calc.value.should eq(0)
    stack.can_undo?.should eq(false)
  end

  it "destroy commands after a undo followed by a push" do
    stack = TextUi::UndoStack.new
    stack.merge_interval = -1
    calc = Calc.new
    stack.push(Sum.new(calc, 5))
    stack.push(Sum.new(calc, 5))
    stack.push(Sum.new(calc, 5))
    stack.push(Sum.new(calc, 5))
    calc.value.should eq(20)
    stack.undo
    stack.undo
    calc.value.should eq(10)
    stack.push(Multiply.new(calc, 2))
    calc.value.should eq(20)
    stack.can_undo?.should eq(true)
    stack.can_redo?.should eq(false)

    stack.push(Multiply.new(calc, 5))
    calc.value.should eq(100)
    stack.can_undo?.should eq(true)
    stack.can_redo?.should eq(false)

    stack.undo
    stack.can_undo?.should eq(true)
    stack.can_redo?.should eq(true)
    calc.value.should eq(20)

    stack.redo
    calc.value.should eq(100)
    stack.can_undo?.should eq(true)
    stack.can_redo?.should eq(false)
  end

  it "has a clean state" do
    stack = TextUi::UndoStack.new
    stack.merge_interval = -1
    stack.clean_state?.should eq(false)
    calc = Calc.new
    stack.push(Sum.new(calc, 1))
    stack.push(Sum.new(calc, 2))
    stack.set_clean_state
    stack.clean_state?.should eq(true)

    stack.push(Sum.new(calc, 3))
    stack.clean_state?.should eq(false)

    stack.undo
    stack.clean_state?.should eq(true)
    stack.undo
    stack.clean_state?.should eq(false)
    # Cut the undo tree
    stack.push(Sum.new(calc, 4))
    stack.clean_state?.should eq(false)

    stack.set_clean_state
    stack.push(Sum.new(calc, 5))
    stack.clean_state?.should eq(false)
    # Cut the undo tree
    stack.undo
    stack.push(Sum.new(calc, 6))
    stack.clean_state?.should eq(false)
    stack.undo
    stack.clean_state?.should eq(true)
    stack.undo
    stack.clean_state?.should eq(false)
  end

  it "merge commands if executed in less than the configured time interval" do
    stack = TextUi::UndoStack.new
    stack.merge_interval = 200
    calc = Calc.new
    stack.push(Sum.new(calc, 5))
    sleep(0.1)
    stack.push(Sum.new(calc, 6))
    stack.push(Multiply.new(calc, 2))
    stack.size.should eq(2)
    calc.value.should eq(22)
    stack.push(Sum.new(calc, 10))
    sleep(0.25) # A timecop gem here would be nice
    stack.push(Sum.new(calc, 100))
    stack.size.should eq(4)
    calc.value.should eq(132)
  end
end
