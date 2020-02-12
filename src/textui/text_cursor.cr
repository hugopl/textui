module TextUi
  class TextCursor
    include Comparable(TextCursor)

    getter line : Int32
    getter col : Int32
    property col_hint : Int32
    property? insert_mode : Bool
    getter? valid : Bool
    getter document

    def initialize(@document : TextDocument)
      @line = 0
      @col = 0
      @col_hint = 0
      @insert_mode = false
      @valid = true
    end

    def invalidate
      @valid = false
    end

    def move(line, col) : Nil
      self.line = line
      self.col = col
    end

    def line=(line)
      @line = line.clamp(0, @document.blocks.size - 1)
    end

    def col=(col)
      @col = col.clamp(0, current_block.size)
    end

    def <=>(other : TextCursor)
      value = @line <=> other.line
      value.zero? ? @col <=> other.col : 0
    end

    def current_block
      @document.blocks[@line]
    end

    protected def on_key_event(event : KeyEvent)
      return unless valid?

      if event.key == KEY_INSERT
        @insert_mode = !@insert_mode
        event.accept
      else
        handle_text_modification(event, current_block)
      end
    end

    private def handle_text_modification(event, block) : Nil
      chr = event.char
      key = event.key
      buffer = block.text

      if key == KEY_SPACE
        chr = ' '
        key = 0
      end

      if key == KEY_ENTER
        @document.push(TextBlockBreakLineCommand.new(self))
      elsif key == 0 && chr.ord != 0
        @document.push(TextBlockChangeCommand.new(self, chr))
      elsif key == KEY_BACKSPACE || key == KEY_BACKSPACE2
        if @col == 0 && @line > 0
          @document.push(TextBlockConcatLineCommand.new(self, TextBlockChangeCommand::Mode::Backspace))
        elsif @col != 0 && buffer.size > 0
          @document.push(TextBlockChangeCommand.new(self, TextBlockChangeCommand::Mode::Backspace))
        end
      elsif key == KEY_DELETE
        if @col == buffer.size && @document.blocks.size > @line + 1
          @document.push(TextBlockConcatLineCommand.new(self, TextBlockChangeCommand::Mode::Delete))
        elsif @col < buffer.size
          @document.push(TextBlockChangeCommand.new(self, TextBlockChangeCommand::Mode::Delete))
        end
      else
        return # Event not accepted.
      end
      event.accept
    end
  end
end
