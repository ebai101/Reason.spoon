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
	-- table.insert(globalMaps.hotkeys, globalMaps:color(maps))
end

function globalMaps:activate()
	for _, v in pairs(globalMaps.hotkeys) do v:enable() end
	globalMaps.eventtap:start()
end

function globalMaps:deactivate()
	for _, v in pairs(globalMaps.hotkeys) do v:disable() end
	globalMaps.eventtap:stop()
end

-----------
-- mouse --
-----------

local function mouse5(event)
	if event:getFlags()['cmd'] then
		log.d('mouse5: cmd+delete')
		hs.eventtap.event.newKeyEvent(hs.keycodes.map.delete, true):setFlags({ ['cmd'] = true }):post()
		return true
	else
		log.d('mouse5: delete')
		hs.eventtap.event.newKeyEvent(hs.keycodes.map.delete, true):setFlags({}):post()
		return true
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
			kbWindow:setFrameInScreenBounds(hs.geometry.rect(s.x, s.h, w.w, w.h))
			log.d('piano keys activated')
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

		local toolWindow = hs.window('Tool Window')
		if globalMaps.toolWindowActive then -- if tool window *should be* moved
			local m = hs.mouse.absolutePosition()
			toolWindow:setTopLeft(hs.geometry.point(m.x - 125, m.y - 210))
			log.d('tool window activated')
		else
			local s = hs.screen.mainScreen():frame()
			toolWindow:setTopLeft(s.x + s.w, s.y + s.h)
			log.d('tool window deactivated')
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

function globalMaps:color(m)
	-- chooser with all possible colors
	-- applies clip color, track color or channel color
	return hs.hotkey.new(m.color[1], m.color[2], function()
		log.d(hs.inspect(hs.appfinder.appFromName('Reason'):getMenuItems()[3]['AXChildren'][1][21]))
	end)
end

return globalMaps
