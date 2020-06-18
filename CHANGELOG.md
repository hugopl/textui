## [0.3.1] - 2020-04-10
- Fix termbox compilation.

## [0.3.0] - 2020-04-10
### Added
- Widgets can refuse to be focusable.
- If UI root widget is invalidated, all screen is cleared.
- Compile our own copy of termbox C library.

### Fixed
- Fix warnings on Crystal 0.34.0.
- Fix some rendering issues on Dialog widget.

### Changed
- Remove Ui#add_focus_shortcut from API.
- Dialog close when focus is lost is now optimal.

## [0.2.1] - 2020-03-15
### Added
- Added mouse support to List widget.

### Fixed
- List#selected_item doesn't return the last item when no item is selected.

### Changed
- Removed Widget#clear_text
- Widget#erase renamed to Widget#clear_widget and visibility reduced to protected.
- Box widget now delegate the focus to their first child.

## [0.2.0] - 2020-03-11
### Added
- Add basic support to mouse events.
- Focus widget on mouse click.
- Added clean_state_changed to TextDocument.

### Fixed
- Fix cursor_changed signal from TextEditor.

### Breaking changes
- Rename TextDocument#insert to TextDocument#insert_line
- Rename TextDocument#remove to TextDocument#remove_line

## [0.1.4] - 2020-02-13
### Fixed
- Fix type error on Ui.add_focus_shortcut method.

## [0.1.3] - 2020-02-13
### Added
- Added UndoStack and UndoCommand classes for a undo/redo implementations.
- Added undo/redo to TextEditor.
- Added undo/redo to TextInput.

### Fixed
- All KEY_* constants are now u16 to match with key attribute of Event class.

## [0.1.2] - 2020-02-05
### Fixed
- Fix Widget#children_focused? to return true on grandchildren.

## [0.1.1] - 2020-02-02
### Fixed
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
