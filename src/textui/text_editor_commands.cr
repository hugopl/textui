require "./undo_command"

module TextUi
  abstract class TextBlockBaseCommand < UndoCommand
    @line : Int32
    @col : Int32
    @col_hint : Int32
    @block_ref : Int32

    delegate document, to: @cursor

    enum Mode
      Delete
      Backspace
    end

    def initialize(@cursor : TextCursor)
      @line = @cursor.line
      @col = @cursor.col
      @col_hint = @cursor.col_hint
      @block_ref = @line
    end

    def block
      @cursor.document.blocks[@block_ref]
    end

    def restore_cursor
      @cursor.move(@line, @col)
      @cursor.col_hint = @col_hint
    end
  end

  class TextBlockChangeCommand < TextBlockBaseCommand
    getter new_text
    getter? text_inserted : Bool
    getter new_col : Int32
    getter new_text : String

    @old_text : String

    # This remove a character from a block
    def initialize(cursor : TextCursor, mode : Mode)
      super(cursor)

      @text_inserted = false
      @old_text = block.text
      @new_col = case mode
                 when Mode::Backspace then @col - 1
                 else
                   @col
                 end
      @new_text = String.build(@old_text.size - 1) do |str|
        str << @old_text[0...@new_col]
        str << @old_text[(@new_col + 1)..-1]
      end
    end

    def initialize(cursor : TextCursor, chr : Char)
      super(cursor)

      @text_inserted = true
      @old_text = block.text
      @new_text = if @cursor.insert_mode? && @col < @old_text.size
                    @old_text.sub(@col, chr)
                  else
                    @old_text.insert(@col, chr)
                  end
      @new_col = @col + 1
    end

    def merge(other : TextBlockChangeCommand)
      return false if other.text_inserted? != @text_inserted

      @new_col = other.new_col
      @new_text = other.new_text
      true
    end

    def redo : Nil
      block.text = @new_text
      @cursor.move(@line, @new_col)
      @cursor.col_hint = @new_col
    end

    def undo : Nil
      block.text = @old_text
      @cursor.move(@line, @col)
    end
  end

  class TextBlockBreakLineCommand < TextBlockBaseCommand
    @old_text : String

    def initialize(cursor : TextCursor)
      super(cursor)
      @old_text = block.text
    end

    def redo : Nil
      new_line = @old_text[@col..-1]
      block.text = @old_text[0...@col]
      document.insert(@line + 1, new_line)
      @cursor.move(@line + 1, 0)
    end

    def undo : Nil
      block.text = @old_text
      document.remove(@line + 1)
      restore_cursor
    end
  end

  class TextBlockConcatLineCommand < TextBlockBaseCommand
    @line_to_remove : Int32 = 0
    @concat_point : Int32 = 0
    @new_text : String = ""

    def initialize(cursor : TextCursor, @mode : Mode)
      super(cursor)

      if @mode == Mode::Backspace
        @block_ref = @line - 1
        block_ref = self.block
        text = self.block.text
        @new_text = block_ref.text + block_ref.next_block.text
        @line_to_remove = @line
        @concat_point = text.size
      else # Delete
        @line_to_remove = @line + 1
        block_ref = self.block
        text = block_ref.text
        @concat_point = text.size
        @new_text = text + block_ref.next_block.text
      end
    end

    def redo : Nil
      block.text = @new_text
      document.remove(@line_to_remove)
      @cursor.move(@line - 1, @concat_point) if @mode == Mode::Backspace
    end

    def undo : Nil
      old_text1 = @new_text[0...@concat_point]
      block.text = old_text1
      old_text2 = @new_text[@concat_point..-1]

      document.insert(@line_to_remove, old_text2)
      restore_cursor if @mode == Mode::Backspace
    end
  end
end
