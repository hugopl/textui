module TextUi
  enum Alignment
    Left
    Center
    Right
  end

  class Label < Widget
    property text

    property alignment = Alignment::Left

    def initialize(parent, text : String = "")
      initialize(parent, 0, 0, text)
    end

    def initialize(parent, x, y, @text : String = "")
      super(parent, x, y, @text.size, 1)
      self.focusable = false
    end

    def text=(@text)
      invalidate
    end

    def render
      clear_widget

      # FIXME: This only works when the text has a single line.
      case @alignment
      when Alignment::Left
        print_lines(0, 0, @text)
      when Alignment::Center
        print_lines((width - @text.size)//2, 0, @text)
      when Alignment::Right
        print_lines(width - @text.size, 0, @text)
      end
    end
  end
end
