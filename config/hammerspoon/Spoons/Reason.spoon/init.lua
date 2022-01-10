local reason = {}
local log = hs.logger.new('reason', 'info')

-- spoon setup
-- ----- -----

reason.__index = reason
reason.name = "reason config"
reason.version = "1.0"
reason.author = "ethan bailey"
reason.hotkeys = {}

function reason:start()
    reason.devices = hs.json.read('bce_data.json')
    reason.freq = hs.json.read('bce_freq.json')
    reason.chooser = hs.chooser.new(function(choice)
        return reason:create(choice)
    end)
    if hs.application.frontmostApplication():title() == 'Reason' then
        log.d('reason activated')
        for i=1, #reason.hotkeys do reason.hotkeys[i]:enable() end
    end
    reason.watcher = hs.application.watcher.new(function(appName, eventType, app)
        if appName == 'Reason' then
            if eventType == hs.application.watcher.activated then
                log.d('reason activated')
                for i=1, #reason.hotkeys do reason.hotkeys[i]:enable() end
            elseif eventType == hs.application.watcher.deactivated then
                log.d('reason deactivated')
                for i=1, #reason.hotkeys do reason.hotkeys[i]:disable() end
            end
        end
    end)
    reason.watcher:start()
end

function reason:bindHotkeys(m)
    table.insert(reason.hotkeys, hs.hotkey.new(m.bce[1], m.bce[2], reason.show))
end

function reason:show()
    -- rebuild on double press
    if reason.chooser:isVisible() then
        reason:rebuild()
    end
    reason.chooser:choices(reason.devices)
    reason.chooser:show()
end

function reason:create(choice)
    if choice then
        -- select menu item, creating the device in daw
        local app = hs.appfinder.appFromName('Reason')
        log.d(string.format('selected %s', choice['text']))
        app:selectMenuItem(choice['menuSelector'])
        -- update frequency
        if reason.freq[choice['text']] == nil then
            reason.freq[choice['text']] = 0
        else
            reason.freq[choice['text']] = reason.freq[choice['text']] + 1
        end
        hs.json.write(reason.freq, 'bce_freq.json', true, true)
        reason:refresh()
    end
end

function reason:refresh()
    table.sort(reason.devices, function (left, right)
        if reason.freq[left['text']] == nil then
            reason.freq[left['text']] = 0
        end
        if reason.freq[right['text']] == nil then
            reason.freq[right['text']] = 0
        end
        return reason.freq[left['text']] > reason.freq[right['text']]
    end)
    hs.json.write(reason.devices, 'bce_data.json', true, true)
    reason.chooser:choices(reason.devices)
end

function reason:rebuild()
    local app = hs.appfinder.appFromName('Reason')
    if app:getMenuItems() == nil then return end -- quit if no menus are up yet
    local menus = app:getMenuItems()[4]['AXChildren'][1]
    local newList = {}

    -- for i=7, 9 do -- Create -> Instruments, Effects, Utilities
    for i=7, 9 do
        local foundSubmenu = false
        for j=1, #menus[i]['AXChildren'][1] do
            -- iterate until we find the first submenu, which is always Built-in Devices
            local subtitle = menus[i]['AXChildren'][1][j]['AXTitle']
            if subtitle == 'Built-in Devices' then
                foundSubmenu = true
            end
            -- iterate thru the successive submenus
            if foundSubmenu then
                local submenu = menus[i]['AXChildren'][1][j]['AXChildren'][1]
                for k=1, #submenu do
                    if not(submenu[k]['AXTitle'] == '') then -- table contains divider bars, which have a blank title
                        local title = submenu[k]['AXTitle']
                        log.d(title, ': ', menus[i]['AXTitle'])
                        table.insert(newList, {
                                ["text"] = title,
                                ["subText"] = string.format('%s - %s',
                                    menus[i]['AXTitle'],
                                    subtitle
                                    ),
                                ["menuSelector"] = {
                                    "Create",
                                    menus[i]['AXTitle'],
                                    subtitle,
                                    submenu[k]['AXTitle'],
                                }
                            })
                    end
                end
            end
        end
    end
    for i=1, #menus[10]['AXChildren'][1] do
        if not menus[10]['AXChildren'][1][i]['AXTitle'] == '' then
            local title = menus[10]['AXChildren'][1][i]['AXTitle']
            log.d(title)
            table.insert(newList, {
                    ["text"] = title,
                    ["subText"] = "Players",
                    ["menuSelector"] = {
                        "Create", "Players",
                        menus[10]['AXChildren'][1][i]['AXTitle'],
                    }
                })
        end
    end

    -- refresh json
    reason.devices = newList
    reason:refresh()
    hs.alert('rebuilt list')
end

return reason
