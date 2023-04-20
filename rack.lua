local rack = {}
local log = hs.logger.new('rack', 'debug')
local app = hs.appfinder.appFromName('Reason')

rack.hotkeys = {}

-----------
-- setup --
-----------

function rack:bindHotkeys(maps)
	table.insert(rack.hotkeys, rack:color(maps))
	table.insert(rack.hotkeys, rack:autoRoute(maps))
	table.insert(rack.hotkeys, rack:browsePatches(maps))
	table.insert(rack.hotkeys, rack:disconnectDevice(maps))
	table.insert(rack.hotkeys, rack:resetDevice(maps))
	table.insert(rack.hotkeys, rack:combine(maps))
end

function rack:activate()
	for _, v in pairs(rack.hotkeys) do v:enable() end
	log.d('rack activated')
end

function rack:deactivate()
	for _, v in pairs(rack.hotkeys) do v:disable() end
	log.d('rack deactivated')
end

--------------
-- keybinds --
--------------
function rack:autoRoute(m)
	return hs.hotkey.new(m.autoRoute[1], m.autoRoute[2], function()
		app:selectMenuItem({ 'Edit', 'Auto-route Device' })
		log.d('auto routed')
	end)
end

function rack:browsePatches(m)
	return hs.hotkey.new(m.browsePatches[1], m.browsePatches[2], function()
		app:selectMenuItem({ 'Edit', 'Browse Patches…' })
		log.d('browsing patches')
	end)
end

function rack:disconnectDevice(m)
	return hs.hotkey.new(m.disconnectDevice[1], m.disconnectDevice[2], function()
		app:selectMenuItem({ 'Edit', 'Disconnect Device' })
		log.d('disconnected device')
	end)
end

function rack:resetDevice(m)
	return hs.hotkey.new(m.resetDevice[1], m.resetDevice[2], function()
		app:selectMenuItem({ 'Edit', 'Reset Device' })
		log.d('reset device')
	end)
end

function rack:combine(m)
	return hs.hotkey.new(m.combine[1], m.combine[2], function()
		local ok = app:findMenuItem({ 'Edit', 'Combine' })
		if ok.enabled then
			app:selectMenuItem({ 'Edit', 'Combine' })
			log.d('combined devices')
		else
			app:selectMenuItem({ 'Edit', 'Uncombine' })
			log.d('uncombined devices')
		end
	end)
end

function rack:color(m)
	return hs.hotkey.new(m.color[1], m.color[2], function()
		log.d('rack device color')
	end)
end

return rack
