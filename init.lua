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

reason.spoonPath = hs.spoons.scriptPath()
reason.createDevice = dofile(reason.spoonPath .. 'create_device.lua')
reason.globalMaps = dofile(reason.spoonPath .. 'global_maps.lua')
reason.defaultKeys = dofile(reason.spoonPath .. 'default_keys.lua')

local log = hs.logger.new('reason', 'debug')

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
    for _, v in pairs(reason.hotkeys) do v:enable() end
    for _, v in pairs(reason.eventtaps) do v:start() end
end

function reason:deactivate()
    log.d('reason deactivated')
    for _, v in pairs(reason.hotkeys) do v:disable() end
    for _, v in pairs(reason.eventtaps) do v:stop() end
end

local function loadHotkeys(module, maps)
    for _, v in pairs(module:hotkeys(maps)) do
        table.insert(reason.hotkeys, v)
    end
end

local function loadEventtap(module)
    table.insert(reason.eventtaps, module.eventtap)
end

function reason:bindHotkeys(maps)
    reason.hotkeys = {}
    reason.eventtaps = {}
    loadHotkeys(reason.globalMaps, maps)
    loadEventtap(reason.globalMaps)
    loadHotkeys(reason.createDevice, maps)
end

return reason
