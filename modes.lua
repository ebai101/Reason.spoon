local modes = {}
local app = hs.appfinder.appFromName('Reason')

modes.hotkeys = {}
modes.mixer = dofile(hs.spoons.resourcePath('mixer.lua'))
modes.rack = dofile(hs.spoons.resourcePath('rack.lua'))
modes.sequencer = dofile(hs.spoons.resourcePath('sequencer.lua'))
modes.activeMode = 'mixer'

-----------
-- setup --
-----------

function modes:bindHotkeys(maps)
    table.insert(modes.hotkeys, modes:toggleMixer(maps))
    table.insert(modes.hotkeys, modes:toggleRack(maps))
    table.insert(modes.hotkeys, modes:toggleSequencer(maps))
    modes.mixer:bindHotkeys(maps)
    modes.rack:bindHotkeys(maps)
    modes.sequencer:bindHotkeys(maps)
end

function modes:activate()
    for _, v in pairs(modes.hotkeys) do v:enable() end
    if modes.activeMode == 'mixer' then
        modes.mixer:activate()
    elseif modes.activeMode == 'rack' then
        modes.rack:activate()
    elseif modes.activeMode == 'sequencer' then
        modes.sequencer:activate()
    end
end

function modes:deactivate()
    for _, v in pairs(modes.hotkeys) do v:disable() end
    modes.mixer:deactivate()
    modes.rack:deactivate()
    modes.sequencer:deactivate()
end

--------------
-- keybinds --
--------------

-- modes:toggleMixer(m)
-- Method
-- Toggles the mixer view and calls mixer:activate() to activate the mixer module
-- Also deactivates the rack and sequencer modules
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function modes:toggleMixer(m)
    return hs.hotkey.new(m.toggleMixer[1], m.toggleMixer[2], function()
        app:selectMenuItem({ 'Window', 'View Main Mixer' })
        modes.mixer:activate()
        modes.rack:deactivate()
        modes.sequencer:deactivate()
        modes.activeMode = 'mixer'
    end)
end

-- modes:toggleRack(m)
-- Method
-- Toggles the rack view and calls rack:activate() to activate the rack module
-- Also deactivates the mixer and sequencer modules
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function modes:toggleRack(m)
    return hs.hotkey.new(m.toggleRack[1], m.toggleRack[2], function()
        app:selectMenuItem({ 'Window', 'View Racks' })
        modes.mixer:deactivate()
        modes.rack:activate()
        modes.sequencer:deactivate()
        modes.activeMode = 'rack'
    end)
end

-- modes:toggleSequencer(m)
-- Method
-- Toggles the sequencer view and calls sequencer:activate() to activate the sequencer module
-- Also deactivates the mixer and rack modules
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function modes:toggleSequencer(m)
    return hs.hotkey.new(m.toggleSequencer[1], m.toggleSequencer[2], function()
        app:selectMenuItem({ 'Window', 'View Sequencer' })
        modes.mixer:deactivate()
        modes.rack:deactivate()
        modes.sequencer:activate()
        modes.activeMode = 'sequencer'
    end)
end

return modes
