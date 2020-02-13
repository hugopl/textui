module TextUi
  class UndoStack
    # If the time between two mergeable commands happen is less than merge_interval, they will be merged into a single command.
    # merge_interval is specified in milliseconds, default to 1000ms.
    property merge_interval : Int32 = 1000

    @stack = [] of UndoCommand
    @index = -1
    @clean_state_index = -1
    @last_push : Time::Span?

    @@undo_key : UInt16 = KEY_CTRL_Z
    @@redo_key : UInt16 = KEY_CTRL_Y

    delegate size, to: @stack

    def self.undo_key
      @@undo_key
    end

    def self.undo_key=(key)
      @@undo_key = key
    end

    def self.redo_key
      @@redo_key
    end

    def self.redo_key=(key)
      @@redo_key = key
    end

    def push(cmd : UndoCommand) : Nil
      cmd.redo
      return if try_merge(cmd)

      if @index == @stack.size - 1
        @stack << cmd
      else
        @stack[(@index + 1)..-1] = cmd
        @clean_state_index = -1 if @clean_state_index > @index
      end
      @last_push = Time.monotonic
      @index += 1
    end

    private def try_merge(cmd) : Bool
      last_push = @last_push
      return false if @index < 0 || @merge_interval < 0 || last_push.nil?

      time_lapsed = (Time.monotonic - last_push).total_milliseconds
      return @stack[@index].merge(cmd) if time_lapsed < @merge_interval

      false
    end

    def undo : Nil
      @stack[@index].undo
      @index -= 1
    end

    def can_undo?
      @index >= 0
    end

    def redo
      @index += 1
      @stack[@index].redo
    end

    def can_redo?
      @index < @stack.size - 1
    end

    def set_clean_state
      @clean_state_index = @index
    end

    def clean_state?
      @clean_state_index == @index
    end

    def clear
      @stack.clear
      @index = -1
      @clean_state_index = -1
    end
  end
end
