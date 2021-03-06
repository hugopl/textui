require "cute"

{% if !flag?(:release) %}
  def debug(text : String)
    File.open("/tmp/debug.txt", "a", &.puts(text))
  end

  def debug(floats : Array(Float64))
    debug(floats.map(&.humanize))
  end

  def debug(obj)
    File.open("/tmp/debug.txt", "a", &.puts(obj.inspect))
  end
{% end %}

module TextUi
  class Ui < Widget
    getter focused_widget : Widget?

    Cute.signal resized(width : Int32, height : Int32)
    Cute.signal key_typed(event : KeyEvent)
    Cute.signal focus_changed(old_widget : Widget?, new_widget : Widget?)

    def initialize(color_mode = ColorMode::Just256Colors)
      @event = Terminal::Event.new(type: 0, mod: 0, key: 0, ch: 0, w: 0, x: 0, y: 0)
      @shutdown = false
      @main_loop_running = false
      super(self)

      Terminal.init(color_mode)
    end

    def self.shutdown!
      Terminal.shutdown
    end

    def shutdown!
      @shutdown = true
      Terminal.shutdown unless @main_loop_running
    end

    def focus(widget : Widget?) : Nil
      return if widget && !widget.focusable?

      old_widget = @focused_widget
      unless old_widget.nil?
        old_widget.focused = false
        old_widget.invalidate
      end
      @focused_widget = widget
      unless widget.nil?
        widget.focused = true
        widget.invalidate
      end
      focus_changed.emit(old_widget, widget)
      set_cursor(-1, -1)
    end

    def absolute_x
      0
    end

    def absolute_y
      0
    end

    def absolute_width
      width
    end

    def absolute_height
      height
    end

    def render
      # A invalidate call to Ui root widget clear the terminal
      Terminal.clear if render_pending?

      render_children
      widget = @focused_widget
      widget.render_cursor if widget && !widget.widget_too_small?
      self.render_pending = false
      Terminal.present
    end

    def main_loop
      main_loop(polling: 0) do
      end
    end

    def main_loop(polling = 250)
      @main_loop_running = true
      handle_resize(Terminal.width, Terminal.height)
      loop do
        process_queued_events
        render

        if polling.zero?
          process_events
        else
          while !peek_event(polling)
            yield
          end
        end
        break if @shutdown
      end
    ensure
      @main_loop_running = false
      @shutdown = false
      Terminal.shutdown
    end

    def process_queued_events
      while Terminal.peek_event(pointerof(@event), 0)
        handle_event
      end
    end

    def process_events
      Terminal.poll_event(pointerof(@event))
      handle_event
    end

    def peek_event(timeout) : Bool
      Terminal.peek_event(pointerof(@event), timeout).tap do
        handle_event
      end
    end

    private def handle_event
      case @event.type
      when Terminal::EVENT_KEY    then on_key_event(KeyEvent.new(@event.ch.chr, @event.key, @event.mod))
      when Terminal::EVENT_MOUSE  then on_mouse_event(MouseEvent.new(@event.x, @event.y, @event.key))
      when Terminal::EVENT_RESIZE then handle_resize(@event.w, @event.h)
      else
        # unknown evet type
      end
    end

    private def handle_resize(width, height)
      self.width = width
      self.height = height
      invalidate
      self.resized.emit(width, height)
    end

    protected def on_key_event(event : KeyEvent)
      key_typed.emit(event)
      widget = @focused_widget
      widget.on_key_event(event) if widget && !event.accepted? && !widget.widget_too_small?
    end

    protected def on_mouse_event(event : MouseEvent)
      widget = event.release? ? @focused_widget : find(event.x, event.y)
      if widget && !widget.widget_too_small? && widget.focusable?
        focus(widget)
        widget.on_mouse_event(event)
      end
    end

    def inspect(io : IO)
      io << "<Ui width=#{width} height=#{height}>"
    end
  end
end
