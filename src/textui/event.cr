module TextUi
  class Event
    getter? accepted : Bool = false

    def accept
      @accepted = true
    end
  end

  class KeyEvent < Event
    getter char : Char
    getter key : UInt16
    getter alt : UInt8

    def initialize(@char = '\0', @key = 0_u16, @alt = 0_u8)
    end

    def alt?
      @alt != 0
    end
  end

  class MouseEvent < Event
    getter x
    getter y
    getter key

    def initialize(@x : Int32, @y : Int32, @key : UInt16)
    end

    def left?
      @key == TB_KEY_MOUSE_LEFT
    end

    def right?
      @key == TB_KEY_MOUSE_RIGHT
    end

    def middle?
      @key == TB_KEY_MOUSE_MIDDLE
    end

    def release?
      @key == TB_KEY_MOUSE_RELEASE
    end

    def wheel_up?
      @key == TB_KEY_MOUSE_WHEEL_UP
    end

    def wheel_down?
      @key == TB_KEY_MOUSE_WHEEL_DOWN
    end
  end
end
