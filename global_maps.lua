local globalMaps = {}
local log = hs.logger.new('global', 'debug')

globalMaps.hotkeys = {}
globalMaps.toolWindowActive = false

-----------
-- setup --
-----------

function globalMaps:bindHotkeys(maps)
    table.insert(globalMaps.hotkeys, globalMaps:togglePianoKeys(maps))
    table.insert(globalMaps.hotkeys, globalMaps:toggleToolWindow(maps))
    table.insert(globalMaps.hotkeys, globalMaps:toggleSpectrumEQ(maps))
    table.insert(globalMaps.hotkeys, globalMaps:toggleRegrooveMixer(maps))
    table.insert(globalMaps.hotkeys, globalMaps:toggleBrowser(maps))
    table.insert(globalMaps.hotkeys, globalMaps:record(maps))
    table.insert(globalMaps.hotkeys, globalMaps:exportSong(maps))
    table.insert(globalMaps.hotkeys, globalMaps:exportLoop(maps))
    table.insert(globalMaps.hotkeys, globalMaps:bounceMixerChannels(maps))

    globalMaps.copySettingsMode = hs.hotkey.modal.new()
    globalMaps.copySettingsMode:bind({}, '1', globalMaps._copySettingsAll)
    globalMaps.copySettingsMode:bind({}, '2', globalMaps._copySettingsInserts)
    globalMaps.copySettingsMode:bind({}, '3', globalMaps._copySettingsEQ)
    globalMaps.copySettingsMode:bind({}, '4', globalMaps._copySettingsSends)
    globalMaps.copySettingsMode:bind({}, '5', globalMaps._copySettingsDynamics)
    globalMaps.copySettingsMode:bind({}, 'escape', globalMaps._copySettingsExit)
    table.insert(globalMaps.hotkeys, globalMaps:copySettings(maps))
    table.insert(globalMaps.hotkeys, globalMaps:pasteSettings(maps))
end

function globalMaps:activate(app)
    for _, v in pairs(globalMaps.hotkeys) do v:enable() end
    globalMaps.eventtap:start()
    globalMaps.app = app
end

function globalMaps:deactivate()
    for _, v in pairs(globalMaps.hotkeys) do v:disable() end
    globalMaps.eventtap:stop()
    globalMaps.copySettingsMode:exit()
end

-----------
-- mouse --
-----------

-- globalMaps.eventtap
-- Variable
-- An hs.eventtap that maps MOUSE5 and cmd+MOUSE5 to Delete and cmd+Delete
globalMaps.eventtap = hs.eventtap.new(
    { hs.eventtap.event.types.otherMouseUp }, function(event)
        local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)))
        if buttonNumber == 4 then
            if event:getFlags()['cmd'] then
                log.d('mouse5: cmd+delete')
                hs.eventtap.event.newKeyEvent('delete', true):setFlags({ ['cmd'] = true }):post()
                hs.eventtap.event.newKeyEvent('delete', false):setFlags({ ['cmd'] = true }):post()
            else
                log.d('mouse5: delete')
                hs.eventtap.event.newKeyEvent('delete', true):setFlags({}):post()
                hs.eventtap.event.newKeyEvent('delete', false):setFlags({}):post()
            end
        end
    end)

--------------
-- keybinds --
--------------

-- globalMaps:togglePianoKeys(m)
-- Method
-- Toggles the onscreen piano keys and moves them to the bottom left corner of the current screen
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:togglePianoKeys(m)
    return hs.hotkey.new(m.togglePianoKeys[1], m.togglePianoKeys[2], function()
        if globalMaps.app:findWindow('Piano Keys') == nil then
            globalMaps.app:selectMenuItem({ 'Window', 'Show On-screen Piano Keys' })
            local kbWindow = globalMaps.app:findWindow('Piano Keys')
            local w = kbWindow:frame()
            local s = hs.screen.mainScreen():frame()
            local p = hs.geometry.rect(s.x, s.y + s.h - w.h)
            kbWindow:setTopLeft(p)
            log.d('piano keys activated')
            -- log.d(s)
            -- log.d(p)
        else
            globalMaps.app:selectMenuItem({ 'Window', 'Hide On-screen Piano Keys' })
            log.d('piano keys deactivated')
        end
    end)
end

-- globalMaps:toggleToolWindow(m)
-- Method
-- Toggles the tool window. Instead of closing it, we move it to the bottom right corner of the screen
-- This allows script access to buttons in the tool window even when it's "closed"
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:toggleToolWindow(m)
    return hs.hotkey.new(m.toggleToolWindow[1], m.toggleToolWindow[2], function()
        if globalMaps.app:findWindow('Tool Window') == nil then
            log.d('tool window was closed, opening it')
            globalMaps.app:selectMenuItem({ 'Window', 'Show Tool Window' })
            globalMaps.toolWindowActive = true
        else
            globalMaps.toolWindowActive = not globalMaps.toolWindowActive
        end

        local toolWindow = globalMaps.app:getWindow('Tool Window')
        if globalMaps.toolWindowActive then -- if tool window *should be* moved
            local mp = hs.mouse.absolutePosition()
            local p = hs.geometry.point(mp.x - 125, mp.y - 210)
            toolWindow:setTopLeft(p)
            log.d('tool window activated')
        else
            local s = hs.screen.mainScreen():absoluteToLocal(hs.screen.mainScreen():frame())
            local p = hs.geometry.point(s.w, s.y + s.h)
            toolWindow:setTopLeft(p)
            log.d('tool window deactivated')
            -- log.d('screen frame: ' .. tostring(s))
            -- log.d('window point: ' .. tostring(p))
        end
    end)
end

-- globalMaps:toggleSpectrumEQ(m)
-- Method
-- Toggles the spectrum EQ window
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:toggleSpectrumEQ(m)
    return hs.hotkey.new(m.toggleSpectrumEQ[1], m.toggleSpectrumEQ[2], function()
        local ok = globalMaps.app:selectMenuItem({ 'Window', 'Show Spectrum EQ Window' })
        if ok then
            log.d('spectrum eq activated')
        else
            globalMaps.app:selectMenuItem({ 'Window', 'Hide Spectrum EQ Window' })
            log.d('spectrum eq deactivated')
        end
    end)
end

-- globalMaps:toggleRegrooveMixer(m)
-- Method
-- Toggles the regroove mixer
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:toggleRegrooveMixer(m)
    return hs.hotkey.new(m.toggleRegrooveMixer[1], m.toggleRegrooveMixer[2], function()
        local ok = globalMaps.app:selectMenuItem({ 'Window', 'Show ReGroove Mixer' })
        if ok then
            log.d('regroove mixer activated')
        else
            globalMaps.app:selectMenuItem({ 'Window', 'Hide ReGroove Mixer' })
            log.d('regroove mixer deactivated')
        end
    end)
end

-- globalMaps:toggleBrowser(m)
-- Method
-- Toggles the sidebar browser
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:toggleBrowser(m)
    return hs.hotkey.new(m.toggleBrowser[1], m.toggleBrowser[2], function()
        local ok = globalMaps.app:selectMenuItem({ 'Window', 'Show Browser' })
        if ok then
            log.d('browser activated')
        else
            globalMaps.app:selectMenuItem({ 'Window', 'Hide Browser' })
            log.d('browser deactivated')
        end
    end)
end

-- globalMaps:record(m)
-- Method
-- Enables recording and starts playback
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:record(m)
    return hs.hotkey.new(m.record[1], m.record[2], function()
        hs.eventtap.event.newKeyEvent('return', true):setFlags({ ['cmd'] = true }):post()
        hs.eventtap.event.newKeyEvent('return', false):setFlags({ ['cmd'] = true }):post()
        log.d('record')
    end)
end

-- globalMaps:exportSong(m)
-- Method
-- Opens the dialog to export the song as an audio file
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:exportSong(m)
    return hs.hotkey.new(m.exportSong[1], m.exportSong[2], function()
        globalMaps.app:selectMenuItem({ 'File', 'Export Song as Audio File…' })
        log.d('export song as audio file selected')
    end)
end

-- globalMaps:exportLoop(m)
-- Method
-- Opens the dialog to export the current loop as an audio file
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:exportLoop(m)
    return hs.hotkey.new(m.exportLoop[1], m.exportLoop[2], function()
        globalMaps.app:selectMenuItem({ 'File', 'Export Loop as Audio File…' })
        log.d('export loop as audio file selected')
    end)
end

-- globalMaps:bounceMixerChannels(m)
-- Method
-- Opens the dialog to bounce mixer channels
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:bounceMixerChannels(m)
    return hs.hotkey.new(m.bounceMixerChannels[1], m.bounceMixerChannels[2], function()
        globalMaps.app:selectMenuItem({ 'File', 'Bounce Mixer Channels…' })
        log.d('bounce mixer channels selected')
    end)
end

-------------------------
-- copy/paste settings --
-------------------------

-- globalMaps:copySettings(m)
-- Method
-- Allows the user to copy different types of channel settings
-- When pressed, it enters a mode with 5 different options - All, Inserts, EQ/Filters, sends, and dynamics
-- The user selects one using the number keys 1-5, and the corresponding channel settings are copied
-- If a device is selected that has a patch that can be copied, it copies the patch instead
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:copySettings(m)
    return hs.hotkey.new(m.copySettings[1], m.copySettings[2], function()
        local ok = globalMaps.app:selectMenuItem({ 'Edit', 'Copy Patch' })
        if ok then
            globalMaps.copyPatch = true
            log.d('copied patch')
        else
            globalMaps.copyPatch = false
            globalMaps.copySettingsMode:enter()
            globalMaps.copySettingsAlertUUID = hs.alert('1\tall\n2\tinserts\n3\tEQ/filters\n4\tsends\n5\tdynamics', '')
        end
    end)
end

-- globalMaps:pasteSettings(m)
-- Method
-- Pastes the channel settings or patch that is currently copied
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function globalMaps:pasteSettings(m)
    return hs.hotkey.new(m.pasteSettings[1], m.pasteSettings[2], function()
        if globalMaps.copyPatch then
            globalMaps.app:selectMenuItem({ 'Edit', 'Paste Patch' })
            log.d('pasted patch')
        else
            if globalMaps.copySettingsType == 'Filters and EQ' then
                globalMaps.copySettingsType = 'EQ'
            elseif globalMaps.copySettingsType == 'FX Sends' then
                globalMaps.copySettingsType = 'Sends'
            end
            local ok = globalMaps.app:selectMenuItem({ 'Edit', 'Paste Channel Settings: ' .. globalMaps.copySettingsType })
            if ok then
                log.d('pasted ' .. globalMaps.copySettingsType)
            else
                log.d('paste command failed')
            end
        end
    end)
end

function globalMaps:_copySettings()
    globalMaps.copySettingsMode:exit()
    hs.alert.closeSpecific(globalMaps.copySettingsAlertUUID)
    local ok = globalMaps.app:selectMenuItem({ 'Edit', 'Copy Channel Settings', globalMaps.copySettingsType })
    if ok then
        log.d('copied ' .. globalMaps.copySettingsType)
    else
        log.d('copy command failed')
    end
end

function globalMaps:_copySettingsAll()
    globalMaps.copySettingsType = 'All'
    globalMaps:_copySettings()
end

function globalMaps:_copySettingsInserts()
    globalMaps.copySettingsType = 'Insert FX'
    globalMaps:_copySettings()
end

function globalMaps:_copySettingsEQ()
    globalMaps.copySettingsType = 'Filters and EQ'
    globalMaps:_copySettings()
end

function globalMaps:_copySettingsSends()
    globalMaps.copySettingsType = 'FX Sends'
    globalMaps:_copySettings()
end

function globalMaps:_copySettingsDynamics()
    globalMaps.copySettingsType = 'Dynamics'
    globalMaps:_copySettings()
end

function globalMaps:_copySettingsExit()
    globalMaps.copySettingsMode:exit()
    hs.alert.closeSpecific(globalMaps.copySettingsAlertUUID)
end

return globalMaps
