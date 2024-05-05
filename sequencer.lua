local sequencer = {}
local log = hs.logger.new('sequencer', 'debug')

sequencer.hotkeys = {}
sequencer.eventtaps = {}
sequencer.zoomSum = 0
sequencer.lastZoomTime = 0
sequencer.zoomThreshold = 0.10
sequencer.colorPicker = dofile(hs.spoons.resourcePath('color_picker.lua'))

local function applescript(x)
    hs.execute('osascript -e ' .. [[']] .. string.gsub(x, [[']], [['\'']]) .. [[']])
end

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
    table.insert(sequencer.hotkeys, sequencer:color(maps))

    table.insert(sequencer.eventtaps, sequencer:mouse4Mute())
    table.insert(sequencer.eventtaps, sequencer:pinchZoom())
end

function sequencer:activate(app)
    for _, v in pairs(sequencer.hotkeys) do v:enable() end
    for _, v in pairs(sequencer.eventtaps) do v:start() end
    sequencer.app = app
    log.d('sequencer activated')
end

function sequencer:deactivate()
    for _, v in pairs(sequencer.hotkeys) do v:disable() end
    for _, v in pairs(sequencer.eventtaps) do v:stop() end
    log.d('sequencer deactivated')
end

-----------
-- mouse --
-----------

-- sequencer:mouse4Mute()
-- Method
-- Maps MOUSE4 to "M", for muting clips and notes in the sequencer
--
-- Returns:
-- * An hs.eventtap object, to be addded to this module's eventtaps table
function sequencer:mouse4Mute()
    return hs.eventtap.new(
        { hs.eventtap.event.types.otherMouseUp }, function(event)
            local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties
                .mouseEventButtonNumber)))
            if buttonNumber == 3 then
                hs.eventtap.event.newKeyEvent('m', true):setFlags({}):post()
                hs.eventtap.event.newKeyEvent('m', false):setFlags({}):post()
                log.d('mouse4')
            end
        end)
end

-- sequencer:pinchZoom()
-- Method
-- Zooms the timeline in and out with a pinch gesture on the trackpad
-- Hold cmd while pinching to zoom vertically
-- Hold shift while pinching to zoom in on the playhead instead of the cursor
--
-- Returns:
-- * An hs.eventtap object, to be addded to this module's eventtaps table
function sequencer:pinchZoom()
    return hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
        local gestureType = event:getType(true)
        if gestureType ~= hs.eventtap.event.types.magnify then return end
        local zoomTime = hs.timer.absoluteTime()
        if zoomTime - sequencer.lastZoomTime > 1000000000 then sequencer.zoomSum = 0 end
        sequencer.lastZoomTime = zoomTime

        -- the zoom key commands are much less sensitive than the scroll wheel
        -- so we lower the threshold when using them
        local threshold = sequencer.zoomThreshold
        if event:getFlags()['shift'] then threshold = threshold * 0.5 end

        local zoomLevel = event:getTouchDetails().magnification
        sequencer.zoomSum = sequencer.zoomSum + zoomLevel

        local offsets = {}
        if sequencer.zoomSum >= threshold then
            offsets = { 1, 0 }
            sequencer.zoomSum = 0
        elseif sequencer.zoomSum <= -threshold then
            offsets = { -1, 0 }
            sequencer.zoomSum = 0
        else
            return
        end

        if event:getFlags()['shift'] or event:getFlags()['cmd'] then
            local flags = { ['cmd'] = true, ['shift'] = true }
            if event:getFlags()['cmd'] then flags['alt'] = true end
            local key = offsets[1] == 1 and '=' or '-'
            hs.eventtap.event.newKeyEvent(key, true):setFlags(flags):post()
            hs.eventtap.event.newKeyEvent(key, false):setFlags(flags):post()
        else
            hs.eventtap.event.newScrollEvent(offsets, { 'cmd', 'shift' }, 'pixel'):post()
        end
    end)
end

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
        applescript(
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
        applescript(
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
        applescript(
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
        applescript(
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
