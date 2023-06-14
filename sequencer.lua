local sequencer = {}
local log = hs.logger.new('sequencer', 'debug')

sequencer.hotkeys = {}
sequencer.colorPicker = dofile(hs.spoons.resourcePath('color_picker.lua'))

-----------
-- setup --
-----------

function sequencer:bindHotkeys(maps)
    table.insert(sequencer.hotkeys, sequencer:bounceClip(maps))
    table.insert(sequencer.hotkeys, sequencer:flatten(maps))
    table.insert(sequencer.hotkeys, sequencer:joinClips(maps))
    table.insert(sequencer.hotkeys, sequencer:doubleTempo(maps))
    table.insert(sequencer.hotkeys, sequencer:halfTempo(maps))
    table.insert(sequencer.hotkeys, sequencer:legato(maps))
    table.insert(sequencer.hotkeys, sequencer:quantize(maps))
    table.insert(sequencer.hotkeys, sequencer:reverse(maps))
    table.insert(sequencer.hotkeys, sequencer:setLoopAndPlay(maps))
    -- table.insert(sequencer.hotkeys, sequencer:toggleLoop(maps))
    table.insert(sequencer.hotkeys, sequencer:color(maps))
end

function sequencer:activate(app)
    for _, v in pairs(sequencer.hotkeys) do v:enable() end
    sequencer.eventtap:start()
    sequencer.app = app
    log.d('sequencer activated')
end

function sequencer:deactivate()
    for _, v in pairs(sequencer.hotkeys) do v:disable() end
    sequencer.eventtap:stop()
    log.d('sequencer deactivated')
end

-----------
-- mouse --
-----------

-- sequencer.eventtap
-- Variable
-- An hs.eventtap that maps MOUSE4 to "M", for muting clips in the sequencer
sequencer.eventtap = hs.eventtap.new(
    { hs.eventtap.event.types.otherMouseUp }, function(event)
        local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)))
        if buttonNumber == 3 then
            hs.eventtap.event.newKeyEvent('m', true):setFlags({}):post()
            hs.eventtap.event.newKeyEvent('m', false):setFlags({}):post()
            log.d('mouse4')
        end
    end)


--------------
-- keybinds --
--------------

-- sequencer:bounceClip(m)
-- Method
-- Opens the dialog to bounce the currently selected clip(s) to disk
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:bounceClip(m)
    return hs.hotkey.new(m.bounceClip[1], m.bounceClip[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Bounce', 'Bounce Clip to Disk…' })
        log.d('bouncing clip to disk')
    end)
end

-- sequencer:flatten(m)
-- Method
-- Performs a sequence of actions to "flatten" a clip and match the current tempo
-- In order, it does:
-- * Disable Stretch
-- * Bounce Clips to New Recordings
-- * Enable Stretch
-- * Delete Unused Recordings
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:flatten(m)
    return hs.hotkey.new(m.flatten[1], m.flatten[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Disable Stretch' })
        sequencer.app:selectMenuItem({ 'Edit', 'Bounce', 'Bounce Clips to New Recordings' })
        sequencer.app:selectMenuItem({ 'Edit', 'Bounce', 'Enable Stretch' })
        local ok = sequencer.app:selectMenuItem({ 'Edit', 'Delete Unused Recordings' })
        hs.osascript.applescript(
            [[tell application "System Events" to click button "Delete" of front window of application process "Reason"]])
        log.d('flattened clips')
    end)
end

-- sequencer:joinClips(m)
-- Method
-- Joins the selected clips
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:joinClips(m)
    return hs.hotkey.new(m.joinClips[1], m.joinClips[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Join Clips' })
        log.d('joined clips')
    end)
end

-- sequencer:doubleTempo(m)
-- Method
-- Doubles the tempo of the selected clips/MIDI notes
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:doubleTempo(m)
    return hs.hotkey.new(m.doubleTempo[1], m.doubleTempo[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 7 of window "Tool Window" of application process "Reason"')
        log.d('doubled tempo')
    end)
end

-- sequencer:halfTempo(m)
-- Method
-- Halves the tempo of the selected clips/MIDI notes
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:halfTempo(m)
    return hs.hotkey.new(m.halfTempo[1], m.halfTempo[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 8 of window "Tool Window" of application process "Reason"')
        log.d('halved tempo')
    end)
end

-- sequencer:legato(m)
-- Method
-- Applies the currently selected legato adjustment in the tool window
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:legato(m)
    return hs.hotkey.new(m.legato[1], m.legato[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 5 of window "Tool Window" of application process "Reason"')
        log.d('legato')
    end)
end

-- sequencer:quantize(m)
-- Method
-- Applies the currently selected quantize settings in the tool window
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:quantize(m)
    return hs.hotkey.new(m.quantize[1], m.quantize[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Quantize' })
        log.d('quantized')
    end)
end

-- sequencer:reverse(m)
-- Method
-- Reverses the currently selected clips/MIDI notes
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:reverse(m)
    return hs.hotkey.new(m.reverse[1], m.reverse[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Reverse' })
        log.d('reversed')
    end)
end

-- sequencer:setLoopAndPlay(m)
-- Method
-- Sets the loop to the current selection and starts playback
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:setLoopAndPlay(m)
    return hs.hotkey.new(m.setLoopAndPlay[1], m.setLoopAndPlay[2], function()
        sequencer.app:selectMenuItem({ 'Edit', 'Set Loop to Selection and Start Playback' })
        log.d('set loop and play')
    end)
end

-- sequencer:toggleLoop(m)
-- Method
-- Toggles loop mode
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:toggleLoop(m)
    return hs.hotkey.new(m.toggleLoop[1], m.toggleLoop[2], function()
        hs.eventtap.event.newKeyEvent('l', true):post()
        hs.eventtap.event.newKeyEvent('l', false):post()
        log.d('toggled loop')
    end)
end

-- mixer:color(m)
-- Method
-- Activates a colorPicker (hs.chooser) with available track colors
-- The selected color is then applied to the selected tracks
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function sequencer:color(m)
    return hs.hotkey.new(m.color[1], m.color[2], function()
        local picker = sequencer.colorPicker:setup(sequencer.app, 'Track Color')
        sequencer.colorPicker:show()
        log.d('showing sequencer device color picker')
    end)
end

return sequencer
