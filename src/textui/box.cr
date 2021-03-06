require "./widget"

module TextUi
  class Box < Widget
    property border_color : Format
    property focused_border_color : Format
    property border_style : BorderStyle
    getter title : String
    getter footer : String

    enum Docking
      None
      Left
      Right
    end

    enum BorderStyle
      RoundedBorder
      Fancy
    end

    @docking = Docking::None
    @border_color = Format.new(Color::Grey20)
    @focused_border_color = Format.new(Color::Silver)
    @border_style = BorderStyle::RoundedBorder
    @footer = ""

    def initialize(parent, @title : String, @shortcut : String = "")
      super(parent)
      connect_signals
    end

    def initialize(parent, x, y, @title : String, @shortcut : String = "")
      super(parent, x, y)
      connect_signals
    end

    def initialize(parent, x, y, width, height, @title : String, @shortcut : String = "")
      super(parent, x, y, width, height)
      connect_signals
    end

    private def connect_signals
      ui.focus_changed.on(&->focus_changed(Widget?, Widget?))
    end

    private def focus_changed(old_focus : Widget?, new_focus : Widget?)
      if new_focus == self && children.any?
        ui.focus(children.first)
        return
      end
      invalidate if (!old_focus.nil? && children?(old_focus)) || (!new_focus.nil? && children?(new_focus))
    end

    def right_of(another : Box)
      self.x = another.width - 1
      self.y = another.y
      @docking = Docking::Right
    end

    def title=(@title)
      invalidate
    end

    def footer=(@footer)
      invalidate
    end

    def render
      color = focused? || children_focused? ? @focused_border_color : @border_color
      case @border_style
      when BorderStyle::Fancy         then render_fancy_style(color)
      when BorderStyle::RoundedBorder then render_rounded_border_style(color)
      end
    end

    def render_rounded_border_style(color)
      style = border_style
      # Top
      print_char(1, 0, style[:horizontal], color)
      print_char(2, 0, ' ')
      print_line(3, 0, @title)
      print_char(@title.size + 3, 0, ' ')
      print_line(@title.size + 4, 0, @shortcut, color.reverse.bold)
      (width - @title.size - @shortcut.size - 5).times do |i|
        print_char(@title.size + @shortcut.size + 4 + i, 0, style[:horizontal], color)
      end
      # Left
      (height - 2).times { |i| print_char(0, i + 1, style[:vertical], color) } unless @docking == Docking::Right
      # Bottom
      (width - 2).times { |i| print_char(i + 1, height - 1, style[:horizontal], color) }
      # Right
      (height - 2).times { |i| print_char(width - 1, i + 1, style[:vertical], color) }
      # Corners
      print_char(0, 0, style[:top_left], color)
      print_char(width - 1, 0, style[:top_right], color)
      print_char(0, height - 1, style[:bottom_left], color)
      print_char(width - 1, height - 1, style[:bottom_right], color)
    end

    private def border_style
      left_corners = if @docking == Docking::Right
                       {top: '┬', bottom: '┴'}
                     else
                       {top: '╭', bottom: '╰'}
                     end
      {horizontal: '─', vertical: '│', top_right: '╮', bottom_right: '╯', bottom_left: left_corners[:bottom], top_left: left_corners[:top]}
    end

    private def render_fancy_style(color)
      print_line(0, 0, "██", color)
      print_line(2, 0, @title, color.reverse)
      print_line(2 + @title.size, 0, "┊", color.reverse)
      print_line(3 + @title.size, 0, @shortcut, color.reverse)
      title_bar_remain = width//3 - 3 - @title.size - @shortcut.size - 3
      title_bar_remain.times do |i|
        print_char(@title.size + @shortcut.size + 3 + i, 0, '█', color)
      end
      title_bar_remain = 0 if title_bar_remain < 0
      print_line(title_bar_remain + 3 + @title.size + @shortcut.size, 0, "▓▒░", color)

      title_chars = title_bar_remain + @title.size + @shortcut.size + 6
      (width - title_chars - 1).times do |i|
        print_char(title_chars + i, 0, ' ', color)
      end

      # Left
      (height - 2).times { |i| print_char(0, i + 1, '┃', color) }
      print_char(0, height - 2, '┇', color)
      # Bottom
      bottom_y = height - 1
      2.times { |i| print_char(i, bottom_y, ' ', color) }
      print_line(2, bottom_y, @footer)
      start = footer.size + 2
      (width - start).times { |i| print_char(start + i, bottom_y, ' ', color) }
    end

    def inspect(io : IO)
      io << "<Box title=#{@title.inspect} x=#{absolute_x} y=#{absolute_y} width=#{width} height=#{height}>"
    end
  end
end
