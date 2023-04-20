local globalMaps = {}
local log = hs.logger.new('global', 'debug')
local app = hs.appfinder.appFromName('Reason')

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
	globalMaps.copySettingsMode:bind({}, '1', globalMaps.copySettingsAll)
	globalMaps.copySettingsMode:bind({}, '2', globalMaps.copySettingsInserts)
	globalMaps.copySettingsMode:bind({}, '3', globalMaps.copySettingsEQ)
	globalMaps.copySettingsMode:bind({}, '4', globalMaps.copySettingsSends)
	globalMaps.copySettingsMode:bind({}, '5', globalMaps.copySettingsDynamics)
	globalMaps.copySettingsMode:bind({}, 'escape', globalMaps.copySettingsExit)
	table.insert(globalMaps.hotkeys, globalMaps:copySettings(maps))
	table.insert(globalMaps.hotkeys, globalMaps:pasteSettings(maps))
end

function globalMaps:activate()
	for _, v in pairs(globalMaps.hotkeys) do v:enable() end
	globalMaps.eventtap:start()
end

function globalMaps:deactivate()
	for _, v in pairs(globalMaps.hotkeys) do v:disable() end
	globalMaps.eventtap:stop()
	globalMaps.copySettingsMode:exit()
end

-----------
-- mouse --
-----------

local function mouse5(event)
	if event:getFlags()['cmd'] then
		log.d('mouse5: cmd+delete')
		hs.eventtap.event.newKeyEvent('delete', true):setFlags({ ['cmd'] = true }):post()
	else
		log.d('mouse5: delete')
		hs.eventtap.event.newKeyEvent('delete', true):setFlags({}):post()
	end
end

globalMaps.eventtap = hs.eventtap.new(
	{ hs.eventtap.event.types.otherMouseUp }, function(event)
		local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)))
		if buttonNumber == 4 then
			mouse5(event)
		end
	end)

--------------
-- keybinds --
--------------

function globalMaps:togglePianoKeys(m)
	return hs.hotkey.new(m.togglePianoKeys[1], m.togglePianoKeys[2], function()
		local ok = app:selectMenuItem({ 'Window', 'Show On-screen Piano Keys' })
		if ok then
			local kbWindow = hs.window('Piano Keys')
			local w = kbWindow:frame()
			local s = hs.screen.mainScreen():frame()
			local p = hs.geometry.rect(s.x, s.y + s.h - w.h)
			kbWindow:setTopLeft(p)
			log.d('piano keys activated')
			log.d(s)
			log.d(p)
		else
			app:selectMenuItem({ 'Window', 'Hide On-screen Piano Keys' })
			log.d('piano keys deactivated')
		end
	end)
end

function globalMaps:toggleToolWindow(m)
	-- tool window should always be open so its buttons can be accessed
	-- to deactivated it we move it to the corner

	return hs.hotkey.new(m.toggleToolWindow[1], m.toggleToolWindow[2], function()
		if hs.window('Tool Window') == nil then
			log.d('tool window was closed, opening it')
			app:selectMenuItem({ 'Window', 'Show Tool Window' })
			globalMaps.toolWindowActive = true
		else
			globalMaps.toolWindowActive = not globalMaps.toolWindowActive
		end

		local toolWindow = app:getWindow('Tool Window')
		if globalMaps.toolWindowActive then -- if tool window *should be* moved
			local m = hs.mouse.absolutePosition()
			local p = hs.geometry.point(m.x - 125, m.y - 210)
			toolWindow:setTopLeft(p)
			log.d('tool window activated')
		else
			local s = hs.screen.mainScreen():absoluteToLocal(hs.screen.mainScreen():frame())
			local p = hs.geometry.point(s.w, s.y + s.h)
			toolWindow:setTopLeft(p)
			log.d('tool window deactivated')
			log.d('screen frame: ' .. tostring(s))
			log.d('window point: ' .. tostring(p))
		end
	end)
end

function globalMaps:toggleSpectrumEQ(m)
	return hs.hotkey.new(m.toggleSpectrumEQ[1], m.toggleSpectrumEQ[2], function()
		local ok = app:selectMenuItem({ 'Window', 'Show Spectrum EQ Window' })
		if ok then
			log.d('spectrum eq activated')
		else
			app:selectMenuItem({ 'Window', 'Hide Spectrum EQ Window' })
			log.d('spectrum eq deactivated')
		end
	end)
end

function globalMaps:toggleRegrooveMixer(m)
	return hs.hotkey.new(m.toggleRegrooveMixer[1], m.toggleRegrooveMixer[2], function()
		local ok = app:selectMenuItem({ 'Window', 'Show ReGroove Mixer' })
		if ok then
			log.d('regroove mixer activated')
		else
			app:selectMenuItem({ 'Window', 'Hide ReGroove Mixer' })
			log.d('regroove mixer deactivated')
		end
	end)
end

function globalMaps:toggleBrowser(m)
	return hs.hotkey.new(m.toggleBrowser[1], m.toggleBrowser[2], function()
		local ok = app:selectMenuItem({ 'Window', 'Show Browser' })
		if ok then
			log.d('browser activated')
		else
			app:selectMenuItem({ 'Window', 'Hide Browser' })
			log.d('browser deactivated')
		end
	end)
end

function globalMaps:record(m)
	return hs.hotkey.new(m.record[1], m.record[2], function()
		hs.eventtap.event.newKeyEvent('return', true):setFlags({ ['cmd'] = true }):post()
		log.d('record')
	end)
end

function globalMaps:exportSong(m)
	return hs.hotkey.new(m.exportSong[1], m.exportSong[2], function()
		app:selectMenuItem({ 'File', 'Export Song as Audio File…' })
		log.d('export song as audio file selected')
	end)
end

function globalMaps:exportLoop(m)
	return hs.hotkey.new(m.exportLoop[1], m.exportLoop[2], function()
		app:selectMenuItem({ 'File', 'Export Loop as Audio File…' })
		log.d('export loop as audio file selected')
	end)
end

function globalMaps:bounceMixerChannels(m)
	return hs.hotkey.new(m.bounceMixerChannels[1], m.bounceMixerChannels[2], function()
		app:selectMenuItem({ 'File', 'Bounce Mixer Channels…' })
		log.d('bounce mixer channels selected')
	end)
end

-------------------------
-- copy/paste settings --
-------------------------

function globalMaps:copySettings(m)
	return hs.hotkey.new(m.copySettings[1], m.copySettings[2], function()
		local ok = app:selectMenuItem({ 'Edit', 'Copy Patch' })
		if ok then
			globalMaps.copyPatch = true
			log.d('copied patch')
		else
			globalMaps.copyPatch = false
			globalMaps.copySettingsMode:enter()
			globalMaps.copySettingsAlertUUID = hs.alert('1\tall\n2\tinserts\n3\tEQ/filters\n4\tsends\n5\tdynamics')
		end
	end)
end

function globalMaps:pasteSettings(m)
	return hs.hotkey.new(m.pasteSettings[1], m.pasteSettings[2], function()
		if globalMaps.copyPatch then
			app:selectMenuItem({ 'Edit', 'Paste Patch' })
			log.d('pasted patch')
		else
			if globalMaps.copySettingsType == 'Filters and EQ' then
				globalMaps.copySettingsType = 'EQ'
			elseif globalMaps.copySettingsType == 'FX Sends' then
				globalMaps.copySettingsType = 'Sends'
			end
			app:selectMenuItem({ 'Edit', 'Paste Channel Settings: ' .. globalMaps.copySettingsType })
			log.d('pasted ' .. globalMaps.copySettingsType)
		end
	end)
end

local function _copySettings()
	app:selectMenuItem({ 'Edit', 'Copy Channel Settings', globalMaps.copySettingsType })
	globalMaps.copySettingsMode:exit()
	hs.alert.closeSpecific(globalMaps.copySettingsAlertUUID)
	log.d('copied ' .. globalMaps.copySettingsType)
end

function globalMaps:copySettingsAll()
	globalMaps.copySettingsType = 'All'
	_copySettings()
end

function globalMaps:copySettingsInserts()
	globalMaps.copySettingsType = 'Insert FX'
	_copySettings()
end

function globalMaps:copySettingsEQ()
	globalMaps.copySettingsType = 'Filters and EQ'
	_copySettings()
end

function globalMaps:copySettingsSends()
	globalMaps.copySettingsType = 'FX Sends'
	_copySettings()
end

function globalMaps:copySettingsDynamics()
	globalMaps.copySettingsType = 'Dynamics'
	_copySettings()
end

function globalMaps:copySettingsExit()
	globalMaps.copySettingsMode:exit()
	hs.alert.closeSpecific(globalMaps.copySettingsAlertUUID)
end

return globalMaps
