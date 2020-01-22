## Unreleased
### Fix
- Remove TextDocument#filename, it was moved to TextEditor#filename.
- Clear screen garbage when rendering a list widget.
- Fix crash on table widget when callign setData without calling clear before.
- Do not crash if there's not enough space to render a text editor widget.

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
