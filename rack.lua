local rack = {}
local log = hs.logger.new('rack', 'debug')

rack.hotkeys = {}
rack.colorPicker = dofile(hs.spoons.resourcePath('color_picker.lua'))

-----------
-- setup --
-----------

function rack:bindHotkeys(maps)
    table.insert(rack.hotkeys, rack:color(maps))
    table.insert(rack.hotkeys, rack:autoRoute(maps))
    table.insert(rack.hotkeys, rack:browsePatches(maps))
    table.insert(rack.hotkeys, rack:disconnectDevice(maps))
    table.insert(rack.hotkeys, rack:resetDevice(maps))
    table.insert(rack.hotkeys, rack:createMixChannel(maps))
    table.insert(rack.hotkeys, rack:combine(maps))
end

function rack:activate(app)
    for _, v in pairs(rack.hotkeys) do v:enable() end
    rack.app = app
    log.d('rack activated')
end

function rack:deactivate()
    for _, v in pairs(rack.hotkeys) do v:disable() end
    log.d('rack deactivated')
end

--------------
-- keybinds --
--------------

-- rack:autoRoute(m)
-- Method
-- Auto-routes the currently selected devices
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:autoRoute(m)
    return hs.hotkey.new(m.autoRoute[1], m.autoRoute[2], function()
        rack.app:selectMenuItem({ 'Edit', 'Auto-route Device' })
        log.d('auto routed')
    end)
end

-- rack:browsePatches(m)
-- Method
-- Opens the patch browser with focus on the current device
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:browsePatches(m)
    return hs.hotkey.new(m.browsePatches[1], m.browsePatches[2], function()
        rack.app:selectMenuItem({ 'Edit', 'Browse Patches…' })
        log.d('browsing patches')
    end)
end

-- rack:disconnectDevice(m)
-- Method
-- Disconnects all cables from the selected device
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:disconnectDevice(m)
    return hs.hotkey.new(m.disconnectDevice[1], m.disconnectDevice[2], function()
        rack.app:selectMenuItem({ 'Edit', 'Disconnect Device' })
        log.d('disconnected device')
    end)
end

-- rack:resetDevice(m)
-- Method
-- Resets the selected device to its init patch
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:resetDevice(m)
    return hs.hotkey.new(m.resetDevice[1], m.resetDevice[2], function()
        rack.app:selectMenuItem({ 'Edit', 'Reset Device' })
        log.d('reset device')
    end)
end

-- rack:createMixChannel(m)
-- Method
-- Creates a new mix channel
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:createMixChannel(m)
    return hs.hotkey.new(m.createMixChannel[1], m.createMixChannel[2], function()
        rack.app:selectMenuItem({ 'Create', 'Create Mix Channel' })
        log.d('created mix channel')
    end)
end

-- rack:combine(m)
-- Method
-- Combines the selected rack devices in a new combinator
-- If a combinator is selected, it uncombines the devices
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:combine(m)
    return hs.hotkey.new(m.combine[1], m.combine[2], function()
        local ok = rack.app:findMenuItem({ 'Edit', 'Combine' })
        if ok.enabled then
            rack.app:selectMenuItem({ 'Edit', 'Combine' })
            log.d('combined devices')
        else
            rack.app:selectMenuItem({ 'Edit', 'Uncombine' })
            log.d('uncombined devices')
        end
    end)
end

-- rack:color(m)
-- Method
-- Activates a colorPicker (hs.chooser) with available track colors
-- The selected color is then applied to the selected tracks
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function rack:color(m)
    return hs.hotkey.new(m.color[1], m.color[2], function()
        local picker = rack.colorPicker:setup(rack.app, 'Track Color')
        rack.colorPicker:show()
        log.d('showing rack device color picker')
    end)
end

return rack
