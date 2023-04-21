--- === Reason ===
---
--- workflow optimizations for Reason
---
--- Download: eventually

local reason = {}
reason.__index = reason

-- Metadata
reason.name = 'reason config'
reason.version = '0.1.0'
reason.author = 'Ethan Bailey <ebailey256@gmail.com>'
reason.homepage = 'https://github.com/ebai101/Reason.spoon'
reason.license = 'MIT - https://opensource.org/licenses/MIT'

reason.createDevice = dofile(hs.spoons.resourcePath('create_device.lua'))
reason.globalMaps = dofile(hs.spoons.resourcePath('global_maps.lua'))
reason.modes = dofile(hs.spoons.resourcePath('modes.lua'))
reason.defaultKeys = dofile(hs.spoons.resourcePath('default_keys.lua'))


local log = hs.logger.new('reason', 'debug')

function reason:start()
    reason.createDevice:start()
    reason.watcher = hs.application.watcher.new(function(appName, eventType)
        if appName == 'Reason' then
            if eventType == hs.application.watcher.activated then
                reason.globalMaps:activate()
                reason.createDevice:activate()
                reason.modes:activate()
                log.d('reason activated')
            elseif eventType == hs.application.watcher.deactivated then
                reason.globalMaps:deactivate()
                reason.createDevice:deactivate()
                reason.modes:deactivate()
                log.d('reason deactivated')
            end
        end
    end)
    reason.watcher:start()
end

function reason:stop()
    reason.watcher:stop()
end

function reason:bindHotkeys(maps)
    maps = maps or reason.defaultKeys
    reason.globalMaps:bindHotkeys(maps)
    reason.createDevice:bindHotkeys(maps)
    reason.modes:bindHotkeys(maps)
end

return reason
