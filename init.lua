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

reason.appName = 'Reason'
reason.createDevice = dofile(hs.spoons.resourcePath('create_device.lua'))
reason.globalMaps = dofile(hs.spoons.resourcePath('global_maps.lua'))
reason.modes = dofile(hs.spoons.resourcePath('modes.lua'))
reason.defaultKeys = dofile(hs.spoons.resourcePath('default_keys.lua'))


local log = hs.logger.new('reason', 'debug')

function reason:start()
    reason.createDevice:start()

    local app = hs.application.frontmostApplication()
    if app:title() == 'Reason' then
        reason:_activateAll(app)
        log.d('reason already at the front, automatically activating')
    end

    reason.watcher = hs.application.watcher.new(function(appName, eventType)
        if appName == reason.appName then
            if eventType == hs.application.watcher.activated then
                reason:_activateAll(hs.appfinder.appFromName(appName))
                log.d('reason activated')
            elseif eventType == hs.application.watcher.deactivated then
                reason:_deactivateAll()
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

function reason:_activateAll(app)
    reason.globalMaps:activate(app)
    reason.createDevice:activate(app)
    reason.modes:activate(app)
end

function reason:_deactivateAll()
    reason.globalMaps:deactivate()
    reason.createDevice:deactivate()
    reason.modes:deactivate()
end

-- Reason:setPresetCommand()
-- Method
-- Sets the command used to find presets for the device chooser
-- Any command that returns a list of files separated by newlines (e.g. find, fd) will work
-- Note that any commands must be absolute paths, for example "/usr/bin/find" instead of "find"
-- If this is not called, the device chooser will not have any presets
--
-- Parameters
-- * presetCommand - A string containing a shell command
function reason:setPresetCommand(presetCommand)
    reason.createDevice:setPresetCommand(presetCommand)
end

function reason:setPresetFolders(presetFolders)
    reason.createDevice:setPresetFolders(presetFolders)
end

return reason
