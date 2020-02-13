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

    private def is_cursor_movement?(key) : Bool
      case key
      when KEY_HOME, KEY_END, KEY_ARROW_LEFT, KEY_ARROW_RIGHT then true
      else
        false
      end
    end

    private def handle_cursor_movement(event) : Nil
      col = @cursor.col

      case event.key
      when KEY_ARROW_LEFT  then col -= 1
      when KEY_ARROW_RIGHT then col += 1
      when KEY_END         then col = text.size
      when KEY_HOME        then col = 0
      end

      if col != @cursor.col
        @cursor.col = col
        event.accept
      end
    end

    protected def on_key_event(event : KeyEvent)
      old_text = self.text
      if event.key == UndoStack.undo_key && @document.can_undo?
        @document.undo
        event.accept
      elsif event.key == UndoStack.redo_key && @document.can_redo?
        @document.redo
        event.accept
      elsif event.key == KEY_ENTER
        return
      elsif is_cursor_movement?(event.key)
        handle_cursor_movement(event)
      else
        @cursor.on_key_event(event)
      end

      invalidate if event.accepted?
      key_typed.emit(event)
      text_changed.emit(old_text, text) if old_text != text
    end
  end
end
