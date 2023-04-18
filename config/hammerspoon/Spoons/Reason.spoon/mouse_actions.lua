local mouseActions = {}
local log = hs.logger.new('mouseActs', 'debug')

function mouseActions:start()
	mouseActions.eventtap:start()
end

mouseActions.eventtap = hs.eventtap.new(
	{ hs.eventtap.event.types.otherMouseUp }, function(event)
		print(hs.inspect(event))
		local buttonNumber = tonumber(hs.inspect(event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)))

		if buttonNumber == 4 then
			if event:getFlags()["cmd"] then
				log.d('mouse5: cmd+delete')
				hs.eventtap.event.newKeyEvent(hs.keycodes.map.delete, true):setFlags({ ["cmd"] = true }):post()
				return true
			else
				log.d('mouse5: delete')
				hs.eventtap.event.newKeyEvent(hs.keycodes.map.delete, true):setFlags({}):post()
				return true
			end
		elseif buttonNumber == 3 then
			log.d('mouse4: mute')
		end
	end)

return mouseActions
