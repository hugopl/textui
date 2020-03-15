module TextUi
  class List < Widget
    getter items
    getter cursor : Int32
    getter selected_index = -1
    setter on_select : Proc(String, Nil)?

    property focused_format : Format

    @cursor = 0
    @viewport = 0
    @focused_format = Format.new(Color::Silver).reverse

    def initialize(parent, @items = [] of String)
      super(parent)
    end

    def initialize(parent, x, y, @items = [] of String)
      super(parent, x, y)
    end

    def select(item : String) : Nil
      idx = @items.index(item)

      return if idx.nil?
      self.select(idx)
    end

    def select(item_idx : Int32) : Nil
      return if item_idx < 0 || item_idx >= @items.size

      @selected_index = item_idx
      self.cursor = item_idx
      invalidate
    end

    def selected_item
      return nil if @selected_index < 0

      @items[@selected_index]?
    end

    def cursor=(cursor : Int32) : Nil
      return if cursor < 0

      @cursor = cursor
      invalidate
    end

    def items=(@items)
      invalidate
    end

    def render
      adjust_viewport
      has_scrollup = @viewport > 0
      has_scrolldown = @items.size - @viewport > height

      height.times do |i|
        item_idx = i + @viewport
        break if i >= height || item_idx >= @items.size

        item = @items[item_idx]
        limit = width - 1
        format = item_idx == @cursor && focused? ? @focused_format : default_format

        arrow = item_idx == @selected_index ? '🠺' : ' '
        print_char(0, i, arrow, default_format)

        if (i == 0 && has_scrollup) || (has_scrolldown && i == height - 1)
          limit -= 1
          print_char(width - 1, i, i.zero? ? '▲' : '▼')
        end

        print_line(1, i, item, format, width: limit)
      end

      if @items.size < height
        @items.size.upto(height - 1) do |i|
          clear_line(i)
        end
      end
    end

    protected def on_key_event(event : KeyEvent)
      super
      return if @items.empty?

      case event.key
      when KEY_ARROW_UP   then @cursor -= 1
      when KEY_ARROW_DOWN then @cursor += 1
      when KEY_ENTER
        @selected_index = @cursor
        on_select = @on_select
        on_select.call(@items[@selected_index]) if on_select
      else
        return
      end

      @cursor = @cursor.clamp(0, @items.size - 1)
      event.accept
      invalidate
    end

    private def adjust_viewport
      if @items.size <= height
        @viewport = 0
        return
      end

      if @cursor < @viewport
        @viewport = @cursor
      elsif @cursor >= @viewport + height
        @viewport = @cursor - height + 1
      end
      @viewport = @viewport.clamp(0, @items.size - height)
    end
  end
end
