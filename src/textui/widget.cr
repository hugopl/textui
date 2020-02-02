module TextUi
  abstract class Widget
    property x
    property y
    property width
    property height
    property default_format : Format
    getter? visible : Bool
    property? focused : Bool

    getter children
    getter parent
    property? render_pending

    def initialize(@parent : Widget, @x = 0, @y = 0, @width = 1, @height = 1)
      @default_format = Format.new(Color::Silver)
      @children = [] of Widget
      @focused = false
      @visible = true
      @render_pending = true
      @parent << self if @parent != self
    end

    def ui
      parent = @parent
      loop do
        return parent if parent.is_a?(Ui)
        parent = parent.parent
      end
    end

    protected def <<(child : Widget)
      raise "Bad parent!" if child.parent != self
      @children << child
    end

    def visible=(visible : Bool)
      invalidate if !@visible && visible
      @visible = visible
    end

    # Return true if the widget is too small to be rendered.
    # If a widget is too small it wont be rendered or receive any input events.
    def widget_too_small?
      false
    end

    def focus
      ui.focus(self)
    end

    def destroy
      parent.children.delete(self)
    end

    def resize(@width, @height)
      invalidate
    end

    def move(@x, @y)
      invalidate
    end

    def children_focused?
      children.any? do |child|
        child.focused? || child.children_focused?
      end
    end

    def clear_text(x, y, text : String, format : Format = @default_format, stop_on_lf = false)
      each_char_pos(x, y, text) do |xx, yy, chr|
        if chr == '\n'
          break if stop_on_lf
          next
        end
        Terminal.change_cell(xx, yy, ' ', format)
      end
    end

    def clear_text(x, y, n : Int32, format : Format = @default_format, stop_on_lf = false)
      x += absolute_x
      y += absolute_y
      n.times do |i|
        Terminal.change_cell(x + i, y, ' ', format)
      end
    end

    def erase
      height.times do |y|
        clear_line(y)
      end
    end

    def set_cursor(x, y)
      if x < 0 || y < 0 || x >= width || y >= height
        Terminal.set_cursor(-1, -1)
      else
        Terminal.set_cursor(x + absolute_x, y + absolute_y)
      end
    end

    def absolute_x
      @parent.absolute_x + @x
    end

    def absolute_y
      @parent.absolute_y + @y
    end

    def absolute_width
      @parent.absolute_width + @width
    end

    def absolute_height
      @parent.absolute_height + @height
    end

    def clear_line(y : Int32, format = @default_format)
      x = absolute_x
      y += absolute_y
      width.times do |offset|
        Terminal.change_cell(x + offset, y, ' ', format)
      end
    end

    def print_line(x : Int32, y : Int32, text : String,
                   format : Array(Format) | Format = @default_format,
                   offset = 0,
                   count = text.size,
                   width = 0,
                   ellipsis = true) : Nil
      x += absolute_x
      y += absolute_y
      width_alert = width - 1

      offset.upto(text.size - 1) do |char_idx|
        chr = text[char_idx]
        i = char_idx - offset
        break if i == count || width != 0 && i >= width

        if ellipsis && i == width_alert && text.size != width
          chr = '…'
        elsif chr == '\n'
          chr = '↵'
        elsif chr == '\r'
          chr = '␍'
        end
        fmt = format.is_a?(Format) ? format.as(Format) : format.as(Array(Format))[char_idx]? || Format::DEFAULT
        Terminal.change_cell(x + i, y, chr, fmt)
      end

      return if count >= width

      # fill width with blanks
      fmt = format.is_a?(Format) ? format : Format::DEFAULT
      start_x = x + count
      (width - count).times do |ii|
        Terminal.change_cell(start_x + ii, y, ' ', fmt)
      end
    end

    def print_lines(x, y, text : String, format : Format = @default_format, width = 0)
      count = 0
      width = 0 if text.size <= width # Turn off width if the string fits
      each_char_pos(x, y, text) do |xx, yy, chr|
        count += 1
        limit_reached = count >= width if width != 0
        if limit_reached
          chr = '…'
        elsif chr == '\n'
          next
        elsif chr == '\r'
          chr = '␍'
        end
        Terminal.change_cell(xx, yy, chr, format)
        break if limit_reached
      end
    end

    def each_char_pos(x, y, text : String)
      origin_x = x + absolute_x
      x_limit = @width + origin_x - 1
      x = origin_x
      y += absolute_y
      text.each_char do |chr|
        yield(x, y, chr)
        if chr == '\n'
          y += 1
          x = origin_x
        else
          if x > x_limit
            x = origin_x
            y += 1
          else
            x += 1
          end
        end
      end
    end

    def print_char(x : Int32, y : Int32, chr : Char, format : Format = @default_format)
      x += absolute_x
      y += absolute_y
      Terminal.change_cell(x, y, chr, format)
    end

    protected def render_children
      @children.each do |child|
        if child.render_pending? && !child.widget_too_small?
          child.render_pending = false
          child.render if child.visible?
        end
        child.render_children
      end
    end

    abstract def render

    def render_cursor
    end

    def children?(widget : Widget) : Bool
      return true if children.includes?(widget)

      children.any?(&.children?(widget))
    end

    protected def on_key_event(event : KeyEvent)
    end

    def invalidate
      @render_pending = true
      @children.each(&.invalidate)
    end

    def self.text_dimensions(text : String, max_width = -1, max_height = -1)
      height = text.count("\n") + 1
      height = max_height if max_height > 0 && max_height < height

      line_max_width = text.each_line.map(&.size).max? || 0
      width = line_max_width
      width = max_width if max_width > 0 && max_width < width
      {width: width, height: height}
    end
  end
end
