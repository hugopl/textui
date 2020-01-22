module TextUi
  class StackedWidget < Widget
    getter current_index = 0

    def initialize(parent, x = 0, y = 0)
      super
    end

    def current_index=(index : Int32)
      return if index == @current_index || index < 0 || index >= children.size

      children[index].visible = true
      children[@current_index]?.try(&.visible = false)
      @current_index = index
      current_widget.invalidate
    end

    def current_widget=(widget : Widget)
      idx = children.index(widget)
      self.current_index = idx unless idx.nil?
    end

    def current_widget
      widget = children[@current_index]?
      return widget unless widget.nil?

      cycle
      current_widget
    end

    def remove(widget : Widget) : Widget
      idx = children.index(widget)
      return widget if idx.nil?

      old_current = current_widget
      new_current = if widget == old_current
                      cycle
                      current_widget
                    else
                      old_current
                    end
      children.delete(widget)
      self.current_widget = new_current # update @current_index
      widget
    end

    def cycle
      raise "No widgets to cycle!" if children.size.zero?

      next_index = @current_index + 1
      next_index = 0 if next_index >= children.size
      self.current_index = next_index
    end

    protected def <<(child : Widget)
      super
      child.visible = false if @children.size > 1
      child.resize(width, height)
    end

    def resize(width, height)
      super
      @children.each(&.resize(width, height))
    end

    def render
    end
  end
end
