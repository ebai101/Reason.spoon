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
    reason.app = hs.appfinder.appFromName('Reason')
    reason.bceData = hs.json.read('bce_data.json')
    reason.bceFreq = hs.json.read('bce_freq.json')
    reason.bceChooser = hs.chooser.new(function(choice)
        return reason:bceCreate(choice)
    end)

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
    table.insert(reason.hotkeys, hs.hotkey.new(m.bce[1], m.bce[2], reason.bceShow))
end

-- bce setup
-- --- -----

function reason:bceShow()
    -- rebuild on double press
    if reason.bceChooser:isVisible() then
        reason:bceRebuild()
        hs.alert('rebuilt list')
    end

    reason.bceChooser:choices(reason.bceData)
    reason.bceChooser:show()
end

function reason:bceCreate(choice)
    if choice then
        -- select menu item, creating the device in daw
        log.d(string.format('selected %s', choice['text']))
        reason.app:selectMenuItem(choice['menuSelector'])

        -- update frequency
        if reason.bceFreq[choice['text']] == nil then
            reason.bceFreq[choice['text']] = 0
        else
            reason.bceFreq[choice['text']] = reason.bceFreq[choice['text']] + 1
        end
        hs.json.write(reason.bceFreq, 'bce_freq.json', false, true)
        reason:bceRefresh()
    end
end

function reason:bceRefresh()
    table.sort(reason.bceData, function (left, right)
        return reason.bceFreq[left['text']] > reason.bceFreq[right['text']]
    end)
    hs.json.write(reason.bceData, 'bce_data.json', false, true)
    reason.bceChooser:choices(reason.bceData)
end

function reason:bceRebuild()
    reason.app = hs.appfinder.appFromName('Reason') -- refresh the app instance
    if reason.app:getMenuItems() == nil then return end -- quit if no menus are up yet
    local menus = reason.app:getMenuItems()[4]['AXChildren'][1]
    local newList = {}

    for i=7, 9 do
        for j=11, #menus[i]['AXChildren'][1] do
            for k=1, #menus[i]['AXChildren'][1][j]['AXChildren'][1] do
                if not(menus[i]['AXChildren'][1][j]['AXChildren'][1][k]['AXTitle'] == '') then
                    local title = menus[i]['AXChildren'][1][j]['AXChildren'][1][k]['AXTitle']
                    log.d(title)

                    table.insert(newList, {
                            ["text"] = title,
                            ["subText"] = string.format('%s - %s',
                                menus[i]['AXTitle'],
                                menus[i]['AXChildren'][1][j]['AXTitle']
                                ),
                            ["menuSelector"] = {
                                "Create",
                                menus[i]['AXTitle'],
                                menus[i]['AXChildren'][1][j]['AXTitle'],
                                menus[i]['AXChildren'][1][j]['AXChildren'][1][k]['AXTitle'],
                            }
                        })
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
    reason.bceData = newList
    reason:bceRefresh()
end

return reason
