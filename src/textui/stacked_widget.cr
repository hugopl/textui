module TextUi
  class StackedWidget < Widget
    getter current_index = 0

    def initialize(parent, x = 0, y = 0)
      super
    end

    def current_index=(index : Int32)
      return if index == @current_index

      @children[index].visible = true
      @children[@current_index].visible = false
      @current_index = index
      current_widget.invalidate
    end

    def current_widget=(widget : Widget)
      idx = children.index(widget)
      self.current_index = idx unless idx.nil?
    end

    def current_widget
      @children[@current_index]
    end

    def cycle
      next_index = @current_index + 1
      next_index = 0 if next_index >= @children.size
      self.current_index = next_index
    end

    protected def <<(child : Widget)
      super
      child.visible = false if @children.size > 1
      child.resize(width, height)
    end

    def resize(width, height)
      @children.each(&.resize(width, height))
      invalidate
    end

    def render
    end
  end
end
