## Unreleased
### Added
- Add support to mouse events.
- Focus widget on mouse click.

### Breaking changes
- Removed Widget#clear_text
- Widget#erase renamed to Widget#clear_widget and visibility reduced to protected.

## [0.1.4] - 2020-02-13
### Fix
- Fix type error on Ui.add_focus_shortcut method.

## [0.1.3] - 2020-02-13
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
