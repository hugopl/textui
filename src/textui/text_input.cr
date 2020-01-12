module TextUi
  class TextInput < Widget
    property place_holder = ""

    @document = TextDocument.new

    Cute.signal text_changed(old_text : String, new_text : String)
    Cute.signal key_typed(event : KeyEvent)

    def initialize(parent : Widget)
      super
      @cursor = TextCursor.new(@document)
    end

    def render
      # TODO Adjust viewport
      text = @place_holder
      if @document.first_line.empty? && !focused?
        format = Format.new(Color::Grey15)
      else
        text = @document.first_line
        format = default_format
      end

      print_line(0, 0, text, format, width: width)
      set_cursor(@cursor.col, 0) if focused?
    end

    def text
      @document.first_line
    end

    def clear
      @document.blocks.first.text = ""
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
