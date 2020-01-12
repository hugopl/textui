module TextUi
  class StackedWidget < Widget
    getter current_index = 0

    def initialize(parent)
      super
    end

    def current_index=(index)
      return if index == @current_index

      @children[index].visible = true
      @children[@current_index].visible = false
      @current_index = index
    end

    def <<(child : Widget)
      child.visible = false unless @children.size.zero?
      super
    end

    def resize(width, height)
      @children.each(&.resize(width, height))
    end

    def render
    end
  end
end
