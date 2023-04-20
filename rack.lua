local rack = {}
local log = hs.logger.new('rack', 'debug')

rack.hotkeys = {}

-----------
-- setup --
-----------

function rack:bindHotkeys(maps)
end

function rack:activate()
	log.d('rack activated')
end

function rack:deactivate()
	log.d('rack deactivated')
end

--------------
-- keybinds --
--------------

return rack
