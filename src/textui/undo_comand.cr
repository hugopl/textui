module TextUi
  abstract class UndoCommand
    # Attempts to merge this command other command.
    # Returns true on success; otherwise returns false.
    def merge(_cmd : UndoCommand) : Bool
      false
    end

    abstract def undo : Nil
    abstract def redo : Nil
  end
end
