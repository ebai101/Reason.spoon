# Reason.spoon

A Spoon for workflow optimization in Reason. This spoon greatly overhauls Reason's keyboard shortcuts so that every important shortcut can be performed with the left hand, without moving it too far. This spoon also maps extra mouse buttons to Delete/Mute for fast sequencer editing.

Some other cool features include:
- Super fast, mouse-free creation of rack devices with Cmd + F 
- Pinch to zoom the timeline with the trackpad
- Move the tool window under your mouse when toggling it
- Keybinds for actions in the tool window, such as legato adjustments and tempo scaling, which cannot be accessed with keyboard shortcuts normally
- Quickly copy patches and different types of channel settings with Ctrl + C and Ctrl + V
- Color your channels and tracks using a chooser with Ctrl + Cmd + C

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

## Usage

Once you're all set up, take a look at [defaults_keys.lua](default_keys.lua) for a full list of keybinds (more legible documentation is WIP).

This Spoon assumes a few things about how the user interacts with Reason. Most importantly, it assumes that you only have one of the Mixer, the Rack or the Sequencer in view at any given time, taking up the full window. I find this to be my preferred way to work in Reason, though I know many people like to have different views open at the same time. I can't guarantee that all of the modes will work properly if you use split views, but they should function somewhat reliably.

Also assumed is that you're using a mouse/pointing device with 5 buttons, e.g. thumb buttons or extra macro buttons on a trackball. If you're not, you will miss out on the mouse delete/mute functionality but you'll still be able to use everything else.

Not required but recommended: using a utility like [Karabiner-Elements](https://karabiner-elements.pqrs.org/) to remap Caps Lock to Ctrl, for easier use of the Ctrl key shortcuts, of which there are many.

## Known Issues

Reloading Hammerspoon can take a long time if `bce_data.json` is very large. This is usually due to the user-supplied preset command returning a ton of files. It can be quick-fixed by narrowing the search of the preset command, then deleting `bce_data.json` and reloading. This file read should ideally run concurrently or just at a better time, and the preset rebuilder should also prune invalid files from the results before writing them to disk.