## Unreleased
### Added
- Added UndoStack and UndoCommand classes for a undo/redo implementations.
- Added undo/redo to TextEditor.
- Added undo/redo to TextInput.

### Fix
- All KEY_* constants are now u16 to match with key attribute of Event class.

## [0.1.2] - 2020-02-05
### Fix
- Fix Widget#children_focused? to return true on grandchildren.

## [0.1.1] - 2020-02-02
### Fix
- Remove TextDocument#filename, it was moved to TextEditor#filename.
- Clear screen garbage when rendering a list widget.
- Fix crash on table widget when calling setData without calling clear before.
- Do not crash if there's not enough space to render a text editor widget.

### Added
- New StackedWidget.
- New TextInputWidget.

## [0.1.0] - 2020-01-09
### Added
- First release as a separated shard, current widgets inherited from Queryit:
 - Box
 - Label
 - List
 - Table
 - StatusBar
 - TextEditor
 - Dialog
