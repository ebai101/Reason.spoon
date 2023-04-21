# Reason.spoon

A Spoon for workflow optimization in Reason. This spoon greatly overhauls Reason's keyboard shortcuts so that every important shortcut can be performed with the left hand, without moving it too far. This spoon also maps extra mouse buttons to Delete/Mute for fast sequencer editing.

Some other cool features include:
- Super fast, mouse-free creation of rack devices using a chooser
- Move the tool window under your mouse when toggling it
- Keybinds for actions in the tool window, such as legato adjustments and tempo scaling, which cannot be accessed with keyboard shortcuts normally
- Quickly copy different types of channel settings with one keybind
- Color your channels with one keybind using a chooser

**DISCLAIMER:** This is a WIP and has only been tested on my machine. Some features may not work properly, and others definitely will not work at all.

## Example Config

```lua
hs.loadSpoon('Reason')

-- Simple config with defaults
spoon.Reason:bindHotkeys()

-- You can override binds by copying the default keybinds and modifying them
-- See `default_keys.lua` for a full list
local reasonHotkeys = spoon.Reason.defaultKeys
reasonHotkeys.record = { { 'ctrl' }, 'return' }
spoon.Reason:bindHotkeys(reasonHotkeys)

spoon.Reason:start()
```