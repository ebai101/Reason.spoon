local sequencer = {}
local log = hs.logger.new('sequencer', 'debug')

sequencer.hotkeys = {}

-----------
-- setup --
-----------

function sequencer:bindHotkeys(maps)
end

function sequencer:activate()
	log.d('sequencer activated')
end

function sequencer:deactivate()
	log.d('sequencer deactivated')
end

--------------
-- keybinds --
--------------

return sequencer
