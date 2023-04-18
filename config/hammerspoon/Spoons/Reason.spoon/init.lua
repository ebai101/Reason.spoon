local reason = {}
local log = hs.logger.new('reason', 'info')

reason.__index = reason
reason.name = "reason config"
reason.version = "1.0"
reason.author = "ethan bailey"
reason.hotkeys = {}

reason.spoonPath = hs.spoons.scriptPath()
reason.createDevice = dofile(reason.spoonPath .. 'create_device.lua')


function reason:start()
    reason.createDevice:start()

    reason.watcher = hs.application.watcher.new(function(appName, eventType)
        if appName == 'Reason' then
            if eventType == hs.application.watcher.activated then
                reason:activate()
            elseif eventType == hs.application.watcher.deactivated then
                reason:deactivate()
            end
        end
    end)
    reason.watcher:start()
end

function reason:activate()
    log.d('reason activated')
    for i = 1, #reason.hotkeys do reason.hotkeys[i]:enable() end
end

function reason:deactivate()
    log.d('reason deactivated')
    for i = 1, #reason.hotkeys do reason.hotkeys[i]:disable() end
end

function reason:bindHotkeys(m)
    table.insert(reason.hotkeys, hs.hotkey.new(m.bce[1], m.bce[2], reason.createDevice.show))
end

return reason
