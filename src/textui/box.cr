require "./widget"

module TextUi
  class Box < Widget
    property borderColor

    enum Docking
      None
      Left
      Right
    end

    @docking = Docking::None
    @borderColor = Color::Teal

    def initialize(parent, @title : String, @shortcut : String = "")
      super(parent)
    end

    def initialize(parent, x, y, width, height, @title : String, @shortcut : String = "")
      super(parent, x, y, width, height)
    end

    def right_of(another : Box)
      self.x = another.width - 1
      self.y = another.y
      @docking = Docking::Right
    end

    def render
      style = border_style
      # Top
      print_char(1, 0, style[:horizontal], @borderColor)
      print_line(3, 0, @title)
      print_line(@title.size + 4, 0, @shortcut, @borderColor | Attr::Reverse | Attr::Bold)
      (width - @title.size - @shortcut.size - 5).times do |i|
        print_char(@title.size + @shortcut.size + 4 + i, 0, style[:horizontal], @borderColor)
      end
      # Left
      (height - 2).times { |i| print_char(0, i + 1, style[:vertical], @borderColor) } unless @docking == Docking::Right
      # Bottom
      (width - 2).times { |i| print_char(i + 1, height - 1, style[:horizontal], @borderColor) }
      # Right
      (height - 2).times { |i| print_char(width - 1, i + 1, style[:vertical], @borderColor) }
      # Corners
      print_char(0, 0, style[:top_left], @borderColor)
      print_char(width - 1, 0, style[:top_right], @borderColor)
      print_char(0, height - 1, style[:bottom_left], @borderColor)
      print_char(width - 1, height - 1, style[:bottom_right], @borderColor)
    end

    private def border_style
      left_corners = if @docking == Docking::Right
                       {top: '┬', bottom: '┴'}
                     else
                       {top: '╭', bottom: '╰'}
                     end
      {horizontal: '─', vertical: '│', top_right: '╮', bottom_right: '╯', bottom_left: left_corners[:bottom], top_left: left_corners[:top]}
    end
  end
end
