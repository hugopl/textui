module TextUi
  class TextInput < Widget
    property place_holder = ""
    property place_holder_format = Format.new(Color::Grey15)

    @document = TextDocument.new

    Cute.signal text_changed(old_text : String, new_text : String)
    Cute.signal key_typed(event : KeyEvent)

    def initialize(parent : Widget)
      super
      @cursor = TextCursor.new(@document)
    end

    def render_cursor
      set_cursor(@cursor.col, 0)
    end

    def render
      return render_place_holder if text.empty?

      print_line(0, 0, text, width: width)
    end

    private def render_place_holder
      # We print first character empty, so the cursor gets more attention in the default color.
      print_char(0, 0, ' ')
      print_line(1, 0, @place_holder, @place_holder_format, width: width - 1)
    end

    def text=(value : String)
      @document.replace(0, value)
      invalidate
    end

    def text
      @document.first_line
    end

    def clear
      @document.replace(0, "")
    end

    protected def on_key_event(event : KeyEvent)
      col = @cursor.col
      text = self.text

      case event.key
      when KEY_ENTER # Need this to avoid cursor to insert a new TextBlock into the document
      when KEY_ARROW_LEFT  then col -= 1
      when KEY_ARROW_RIGHT then col += 1
      when KEY_END         then col = text.size
      when KEY_HOME        then col = 0
      else
        @cursor.on_key_event(event)
        invalidate
      end

      if col != @cursor.col && !event.accepted?
        @cursor.col = col
        event.accept
        invalidate
      end

      key_typed.emit(event)
      text_changed.emit(text, self.text) if text != self.text
    end
  end
end
