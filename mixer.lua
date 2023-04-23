local mixer = {}
local log = hs.logger.new('mixer', 'debug')
local app = hs.appfinder.appFromName('Reason')

mixer.hotkeys = {}
mixer.colorPicker = dofile(hs.spoons.resourcePath('color_picker.lua'))

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

-- mixer:color(m)
-- Method
-- Activates a colorPicker (hs.chooser) with available channel colors
-- The selected color is then applied to the selected channels
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function mixer:color(m)
    return hs.hotkey.new(m.color[1], m.color[2], function()
        mixer.colorPicker:setup('Channel color')
        mixer.colorPicker:show()
        log.d('showing mixer channel color picker')
    end)
end

-- mixer:createMixChannel(m)
-- Method
-- Creates a new mixer channel
--
-- Parameters:
-- * m - A table of hotkey mappings
--
-- Returns:
-- * An hs.hotkey object, to be addded to this module's hotkeys table
function mixer:createMixChannel(m)
    return hs.hotkey.new(m.createMixChannel[1], m.createMixChannel[2], function()
        app:selectMenuItem({ 'Create', 'Create Mix Channel' })
        log.d('created mix channel')
    end)
end

return mixer
