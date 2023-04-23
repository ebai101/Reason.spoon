local modes = {}
local app = hs.appfinder.appFromName('Reason')

modes.hotkeys = {}
modes.mixer = dofile(hs.spoons.resourcePath('mixer.lua'))
modes.rack = dofile(hs.spoons.resourcePath('rack.lua'))
modes.sequencer = dofile(hs.spoons.resourcePath('sequencer.lua'))
modes.activeMode = 'rack'

-----------
-- setup --
-----------

-- modes.eventtap
-- Variable
-- An hs.eventtap that allows F5, F6 and F7 to change hotkey modes
-- The key events are passed through normally
modes.eventtap = hs.eventtap.new(
    { hs.eventtap.event.types.keyUp }, function(event)
        local keycode = event:getKeyCode()
        if keycode == hs.keycodes.map.f5 then
            modes:_mixer(true)
        elseif keycode == hs.keycodes.map.f6 then
            modes:_rack(true)
        elseif keycode == hs.keycodes.map.f7 then
            modes:_sequencer(true)
        end
        return false, nil
    end)

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
    modes.eventtap:start()
end

function modes:deactivate()
    for _, v in pairs(modes.hotkeys) do v:disable() end
    modes.mixer:deactivate()
    modes.rack:deactivate()
    modes.sequencer:deactivate()
    modes.eventtap:stop()
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
    return hs.hotkey.new(m.toggleMixer[1], m.toggleMixer[2], modes._mixer)
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
    return hs.hotkey.new(m.toggleRack[1], m.toggleRack[2], modes._rack)
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
    return hs.hotkey.new(m.toggleSequencer[1], m.toggleSequencer[2], modes._sequencer)
end

function modes:_mixer(onlyChangeModes)
    if not onlyChangeModes then
        app:selectMenuItem({ 'Window', 'View Main Mixer' })
    end
    modes.mixer:activate()
    modes.rack:deactivate()
    modes.sequencer:deactivate()
    modes.activeMode = 'mixer'
end

function modes:_rack(onlyChangeModes)
    if not onlyChangeModes then
        app:selectMenuItem({ 'Window', 'View Racks' })
    end
    modes.mixer:deactivate()
    modes.rack:activate()
    modes.sequencer:deactivate()
    modes.activeMode = 'rack'
end

function modes:_sequencer(onlyChangeModes)
    if not onlyChangeModes then
        app:selectMenuItem({ 'Window', 'View Sequencer' })
    end
    modes.mixer:deactivate()
    modes.rack:deactivate()
    modes.sequencer:activate()
    modes.activeMode = 'sequencer'
end

return modes
