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
    reason.createEffectDevices = hs.json.read('bce_data.json')
    reason.createEffectFreq = hs.json.read('bce_freq.json')
    reason.createEffectChooser = hs.chooser.new(function(choice)
        return reason:createEffectSelect(choice)
    end)
    if hs.application.frontmostApplication():title() == 'Reason' then
        log.d('reason activated')
        for i=1, #reason.hotkeys do reason.hotkeys[i]:enable() end
    end
    reason.watcher = hs.application.watcher.new(function(appName, eventType)
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
    table.insert(reason.hotkeys, hs.hotkey.new(m.bce[1], m.bce[2], reason.createEffectShow))
    table.insert(reason.hotkeys, hs.hotkey.new(m.open[1], m.open[2], reason.openProject))
end

function reason:openProject()
    local frontWindow = hs.window.frontmostWindow()
    local openerWindow = hs.window('reason open file')

    if openerWindow == nil then
        hs.task.new('/usr/local/bin/alacritty', nil, {'--config-file', os.getenv('HOME')..'/.config/alacritty/reason.yml'}):start()
    elseif openerWindow ~= frontWindow then
        openerWindow:focus()
    elseif openerWindow == frontWindow then
        openerWindow:application():hide()
    end
end

function reason:createEffectShow()
    -- rebuild on double press
    if reason.createEffectChooser:isVisible() then
        reason:createEffectRebuild()
    end
    reason.createEffectChooser:choices(reason.createEffectDevices)
    reason.createEffectChooser:show()
end

function reason:createEffectSelect(choice)
    if choice then
        -- select menu item, creating the device in daw
        local app = hs.appfinder.appFromName('Reason')
        log.d(string.format('selected %s', choice['text']))
        app:selectMenuItem(choice['menuSelector'])
        -- update frequency
        if reason.createEffectFreq[choice['text']] == nil then
            reason.createEffectFreq[choice['text']] = 0
        else
            reason.createEffectFreq[choice['text']] = reason.createEffectFreq[choice['text']] + 1
        end
        hs.json.write(reason.createEffectFreq, 'bce_freq.json', true, true)
        reason:createEffectRefresh()
    end
end

function reason:createEffectRefresh()
    table.sort(reason.createEffectDevices, function (left, right)
        if reason.createEffectFreq[left['text']] == nil then
            reason.createEffectFreq[left['text']] = 0
        end
        if reason.createEffectFreq[right['text']] == nil then
            reason.createEffectFreq[right['text']] = 0
        end
        return reason.createEffectFreq[left['text']] > reason.createEffectFreq[right['text']]
    end)
    hs.json.write(reason.createEffectDevices, 'bce_data.json', true, true)
    reason.createEffectChooser:choices(reason.createEffectDevices)
end

function reason:createEffectRebuild()
    local app = hs.appfinder.appFromName('Reason')
    if app:getMenuItems() == nil then return end -- quit if no menus are up yet
    local menus = app:getMenuItems()[4]['AXChildren'][1]
    local newDevices = {}

    for i=7, 9 do -- Create -> Instruments, Effects, Utilities
        local foundSubmenu = false
        for j=1, #menus[i]['AXChildren'][1] do
            -- iterate until we find the first submenu, which is always Built-in Devices
            local subtitle = menus[i]['AXChildren'][1][j]['AXTitle']
            if subtitle == 'Built-in Devices' then foundSubmenu = true end
            -- iterate thru this submenu and the successive submenus
            if foundSubmenu then
                local submenu = menus[i]['AXChildren'][1][j]['AXChildren'][1]
                for k=1, #submenu do
                    if not(submenu[k]['AXTitle'] == '') then -- table contains divider bars, which have a blank title
                        local title = submenu[k]['AXTitle']
                        log.d(title)
                        table.insert(newDevices, {
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
    for i=1, #menus[10]['AXChildren'][1] do -- Create -> Players
        if not(menus[10]['AXChildren'][1][i]['AXTitle'] == '') then -- table may contain divider bars in the future
            local title = menus[10]['AXChildren'][1][i]['AXTitle']
            log.d(title)
            table.insert(newDevices, {
                    ["text"] = title,
                    ["subText"] = "Players",
                    ["menuSelector"] = {
                        "Create", "Players",
                        title,
                    }
                })
        end
    end

    -- refresh json
    reason.createEffectDevices = newDevices
    reason:createEffectRefresh()
    hs.alert('rebuilt list')
end

return reason
