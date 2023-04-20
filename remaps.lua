local remaps = {}
local log = hs.logger.new('remaps', 'debug')
local app = hs.appfinder.appFromName('Reason')

remaps.toolWindowActive = false

function remaps:togglePianoKeys()
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
end

function remaps:toggleToolWindow()
	-- tool window should always be open so its buttons can be accessed
	-- to deactivated it we move it to the corner

	if hs.window('Tool Window') == nil then
		log.d('tool window was closed, opening it')
		app:selectMenuItem({ 'Window', 'Show Tool Window' })
		remaps.toolWindowActive = true
	else
		remaps.toolWindowActive = not remaps.toolWindowActive
	end

	local toolWindow = hs.window('Tool Window')
	if remaps.toolWindowActive then -- if tool window *should be* moved
		local m = hs.mouse.absolutePosition()
		toolWindow:setTopLeft(hs.geometry.point(m.x - 125, m.y - 210))
		log.d('tool window activated')
	else
		local s = hs.screen.mainScreen():frame()
		toolWindow:setTopLeft(s.x + s.w, s.y + s.h)
		log.d('tool window deactivated')
	end
end

function remaps:toggleSpectrumEQ()
	local ok = app:selectMenuItem({ 'Window', 'Show Spectrum EQ Window' })
	if ok then
		log.d('spectrum eq activated')
	else
		app:selectMenuItem({ 'Window', 'Hide Spectrum EQ Window' })
		log.d('spectrum eq deactivated')
	end
end

function remaps:toggleRegrooveMixer()
	local ok = app:selectMenuItem({ 'Window', 'Show ReGroove Mixer' })
	if ok then
		log.d('regroove mixer activated')
	else
		app:selectMenuItem({ 'Window', 'Hide ReGroove Mixer' })
		log.d('regroove mixer deactivated')
	end
end

function remaps:toggleBrowser()
	local ok = app:selectMenuItem({ 'Window', 'Show Browser' })
	if ok then
		log.d('browser activated')
	else
		app:selectMenuItem({ 'Window', 'Hide Browser' })
		log.d('browser deactivated')
	end
end

function remaps:record()
	hs.eventtap.event.newKeyEvent('return', true):setFlags({ ['cmd'] = true }):post()
	log.d('record')
end

function remaps:hotkeys(maps)
	local keys = {}
	table.insert(keys, hs.hotkey.new(maps.togglePianoKeys[1], maps.togglePianoKeys[2], remaps.togglePianoKeys))
	table.insert(keys, hs.hotkey.new(maps.toggleToolWindow[1], maps.toggleToolWindow[2], remaps.toggleToolWindow))
	table.insert(keys, hs.hotkey.new(maps.toggleSpectrumEQ[1], maps.toggleSpectrumEQ[2], remaps.toggleSpectrumEQ))
	table.insert(keys,
		hs.hotkey.new(maps.toggleRegrooveMixer[1], maps.toggleRegrooveMixer[2], remaps.toggleRegrooveMixer))
	table.insert(keys, hs.hotkey.new(maps.toggleBrowser[1], maps.toggleBrowser[2], remaps.toggleBrowser))
	table.insert(keys, hs.hotkey.new(maps.record[1], maps.record[2], remaps.record))
	return keys
end

return remaps
