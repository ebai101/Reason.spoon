local mixer = {}
local log = hs.logger.new('mixer', 'debug')
local app = hs.appfinder.appFromName('Reason')

mixer.hotkeys = {}

-----------
-- setup --
-----------

function mixer:bindHotkeys(maps)
	table.insert(mixer.hotkeys, mixer:color(maps))
	table.insert(mixer.hotkeys, mixer:createMixChannel(maps))
end

function mixer:activate()
	for _, v in pairs(mixer.hotkeys) do v:enable() end
	log.d('mixer activated')
end

function mixer:deactivate()
	for _, v in pairs(mixer.hotkeys) do v:disable() end
	log.d('mixer deactivated')
end

--------------
-- keybinds --
--------------

function mixer:color(m)
	return hs.hotkey.new(m.color[1], m.color[2], function()
		log.d('mixer channel color')
	end)
end

function mixer:createMixChannel(m)
	return hs.hotkey.new(m.createMixChannel[1], m.createMixChannel[2], function()
		app:selectMenuItem({ 'Create', 'Create Mix Channel' })
		log.d('created mix channel')
	end)
end

return mixer
