require "cute"

module TextUi
  class Dialog < Box
    Cute.signal dismissed

    @resized_con : Cute::ConnectionHandle = 0
    @focus_changed_con : Cute::ConnectionHandle = 0

    enum Placement
      Auto
      Manual
    end

    def initialize(parent : Widget, title : String = "", @placement = Placement::Auto)
      super(parent, 0, 0, title)

      @resized_con = ui.resized.on { repositionate(width, height) }
    end

    def resize(width, height)
      width = {min_width, width}.max
      super(width, height)

      repositionate(width, height) if @placement.auto?
    end

    def min_width
      @title.size + 6
    end

    def close_when_lose_focus
      return unless @focus_changed_con.zero?

      @focus_changed_con = ui.focus_changed.on do |_old_widget, new_widget|
        next if new_widget.nil?

        dismiss if new_widget != self && !children?(new_widget)
      end
    end

    private def repositionate(width, height)
      move((parent.width - width) // 2, (parent.height - height) // 2)
    end

    protected def on_key_event(_event : KeyEvent)
      dismiss
    end

    def dismiss
      destroy
      invalidate
      parent.invalidate
      ui.resized.disconnect(@resized_con)
      ui.focus_changed.disconnect(@focus_changed_con)
      dismissed.emit
      dismissed.disconnect
    end
  end
end
