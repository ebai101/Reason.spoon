local sequencer = {}
local log = hs.logger.new('sequencer', 'debug')
local app = hs.appfinder.appFromName('Reason')

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
    table.insert(sequencer.hotkeys, sequencer:toggleLoop(maps))
    table.insert(sequencer.hotkeys, sequencer:color(maps))
end

function sequencer:activate()
    for _, v in pairs(sequencer.hotkeys) do v:enable() end
    sequencer.eventtap:start()
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

local function mouse4(event)
    hs.eventtap.event.newKeyEvent('m', true):setFlags({}):post()
    hs.eventtap.event.newKeyEvent('m', false):setFlags({}):post()
    log.d('mouse4')
end

sequencer.eventtap = hs.eventtap.new(
    { hs.eventtap.event.types.otherMouseUp }, function(event)
        local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)))
        if buttonNumber == 3 then
            mouse4(event)
        end
    end)


--------------
-- keybinds --
--------------

function sequencer:bounceClip(m)
    return hs.hotkey.new(m.bounceClip[1], m.bounceClip[2], function()
        app:selectMenuItem({ 'Edit', 'Bounce', 'Bounce Clip to Disk…' })
        log.d('bouncing clip to disk')
    end)
end

function sequencer:flatten(m)
    return hs.hotkey.new(m.flatten[1], m.flatten[2], function()
        app:selectMenuItem({ 'Edit', 'Disable Stretch' })
        app:selectMenuItem({ 'Edit', 'Bounce', 'Bounce Clips to New Recordings' })
        app:selectMenuItem({ 'Edit', 'Bounce', 'Enable Stretch' })
        local ok = app:selectMenuItem({ 'Edit', 'Delete Unused Recordings' })
        -- todo: click delete dialog
        log.d('flattened clips')
    end)
end

function sequencer:joinClips(m)
    return hs.hotkey.new(m.joinClips[1], m.joinClips[2], function()
        app:selectMenuItem({ 'Edit', 'Join Clips' })
        log.d('joined clips')
    end)
end

function sequencer:doubleTempo(m)
    return hs.hotkey.new(m.doubleTempo[1], m.doubleTempo[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 7 of window "Tool Window" of application process "Reason"')
        log.d('doubled tempo')
    end)
end

function sequencer:halfTempo(m)
    return hs.hotkey.new(m.halfTempo[1], m.halfTempo[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 8 of window "Tool Window" of application process "Reason"')
        log.d('halved tempo')
    end)
end

function sequencer:legato(m)
    return hs.hotkey.new(m.legato[1], m.legato[2], function()
        hs.osascript.applescript(
            'tell application "System Events" to click button 5 of window "Tool Window" of application process "Reason"')
        log.d('legato')
    end)
end

function sequencer:quantize(m)
    return hs.hotkey.new(m.quantize[1], m.quantize[2], function()
        app:selectMenuItem({ 'Edit', 'Quantize' })
        log.d('quantized')
    end)
end

function sequencer:reverse(m)
    return hs.hotkey.new(m.reverse[1], m.reverse[2], function()
        app:selectMenuItem({ 'Edit', 'Reverse' })
        log.d('reversed')
    end)
end

function sequencer:setLoopAndPlay(m)
    return hs.hotkey.new(m.setLoopAndPlay[1], m.setLoopAndPlay[2], function()
        app:selectMenuItem({ 'Edit', 'Set Loop to Selection and Start Playback' })
        log.d('set loop and play')
    end)
end

function sequencer:toggleLoop(m)
    return hs.hotkey.new(m.toggleLoop[1], m.toggleLoop[2], function()
        hs.eventtap.event.newKeyEvent('l', true):post()
        hs.eventtap.event.newKeyEvent('l', false):post()
        log.d('toggled loop')
    end)
end

function sequencer:color(m)
    return hs.hotkey.new(m.color[1], m.color[2], function()
        local picker = sequencer.colorPicker:setup('Track Color')
        sequencer.colorPicker:show()
        log.d('showing sequencer device color picker')
    end)
end

return sequencer
