--- === Reason ===
---
--- workflow optimizations for Reason
---
--- Download: eventually

local reason = {}
reason.__index = reason

-- Metadata
reason.name = "reason config"
reason.version = "0.1.0"
reason.author = "Ethan Bailey <ebailey256@gmail.com>"
reason.homepage = "https://github.com/ebai101/Reason.spoon"
reason.license = "MIT - https://opensource.org/licenses/MIT"

reason.hotkeys = {}
reason.spoonPath = hs.spoons.scriptPath()
reason.createDevice = dofile(reason.spoonPath .. 'create_device.lua')
reason.mouseActions = dofile(reason.spoonPath .. 'mouse_actions.lua')

local log = hs.logger.new('reason', 'info')

function reason:start()
    reason.createDevice:start()
    reason.mouseActions:start()

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

local function loadModuleHotkeys(module, maps)
    for _, v in pairs(module:hotkeys(maps)) do
        table.insert(reason.hotkeys, v)
    end
end

function reason:bindHotkeys(maps)
    loadModuleHotkeys(reason.createDevice, maps)
end

return reason
