# Reason.spoon

A Spoon for workflow optimization in Reason. This spoon greatly overhauls Reason's keyboard shortcuts so that every important shortcut can be performed with the left hand, without moving it too far. This spoon also maps extra mouse buttons to Delete/Mute for fast sequencer editing.

Some other cool features include:
- Super fast, mouse-free creation of rack devices with Cmd + F 
- Move the tool window under your mouse when toggling it
- Keybinds for actions in the tool window, such as legato adjustments and tempo scaling, which cannot be accessed with keyboard shortcuts normally
- Quickly copy patches and different types of channel settings with Ctrl + C and Ctrl + V
- Color your channels and tracks using a chooser with Ctrl + Cmd + C

Check out a full list of keybinds in [KEYBINDS.md](KEYBINDS.md)

**DISCLAIMER:** This is a WIP and has only been tested on my machine, with the latest version of Reason. Some features may not work as intended.

## Installation

Requires [Hammerspoon](https://www.hammerspoon.org/) and Reason 12, therefore macOS 11.0 or later is also required. In theory, an older version of Hammerspoon with as old as macOS 10.13 should be fine, but this is untested.

```shell
git clone https://github.com/ebai101/Reason.spoon.git ~/.hammerspoon/Spoons/Reason.spoon 
```

## Example Config

In your `init.lua`:

```lua
hs.loadSpoon('Reason')

-- Simple config with the default hotkey mappings
-- See `default_keys.lua` for a full list
spoon.Reason:bindHotkeys()

-- You can override hotkey mappings by passing them to bindHotkeys()
local reasonHotkeys = spoon.Reason.defaultKeys
reasonHotkeys.record = { { 'ctrl' }, 'return' }
spoon.Reason:bindHotkeys(reasonHotkeys)

-- The device chooser can search for presets if you supply it with a list of files
-- This is done via a shell command such as "find" or any other command that can search for files
spoon.Reason:setPresetCommand([[/usr/bin/find /Users/me/folderOfPatches]])

-- Finally, after calling everything else
spoon.Reason:start()
```