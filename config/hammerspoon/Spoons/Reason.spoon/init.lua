local reason = {}
local log = hs.logger.new('reason', 'info')

reason.__index = reason
reason.name = "reason config"
reason.version = "1.0"
reason.author = "ethan bailey"
reason.hotkeys = {}


function reason:start()
    reason.createDeviceData = hs.json.read('bce_data.json')
    reason.createDeviceFreq = hs.json.read('bce_freq.json')
    reason.createDeviceChooser = hs.chooser.new(function(choice)
        return reason:createDeviceSelect(choice)
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
    table.insert(reason.hotkeys, hs.hotkey.new(m.bce[1], m.bce[2], reason.createDeviceShow))
    table.insert(reason.hotkeys, hs.hotkey.new(m.open[1], m.open[2], reason.openProject))
end

function reason:openProject()
    -- performs a fuzzy search of all spotlight-indexed reason files
    -- opens the selected file

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

function reason:createDeviceShow()
    -- shows the device chooser
    -- triggers a rebuild on double press

    if reason.createDeviceChooser:isVisible() then
        reason:createDeviceRebuild()
    else
        reason.createDeviceChooser:choices(reason.createDeviceData)
        reason.createDeviceChooser:show()
    end
end

function reason:createDeviceSelect(choice)
    -- creates an instance of the selected device
    -- writes the updated frequency data to bce_freq.json

    if choice then
        local app = hs.appfinder.appFromName('Reason')
        log.d(string.format('selected %s', choice['text']))
        app:selectMenuItem(choice['menuSelector'])
        if reason.createDeviceFreq[choice['text']] == nil then
            reason.createDeviceFreq[choice['text']] = 0
        else
            reason.createDeviceFreq[choice['text']] = reason.createDeviceFreq[choice['text']] + 1
        end

        -- write freq data. also writes to bce_data.json since createDeviceRefresh() is called
        hs.json.write(reason.createDeviceFreq, 'bce_freq.json', true, true)
        reason:createDeviceRefresh()
    end
end

function reason:createDeviceRefresh()
    -- sorts the device table by the frequency data in bce_freq.json
    -- writes the list of choices to bce_data.json

    table.sort(reason.createDeviceData, function (left, right)
        if reason.createDeviceFreq[left['text']] == nil then
            reason.createDeviceFreq[left['text']] = 0
        end
        if reason.createDeviceFreq[right['text']] == nil then
            reason.createDeviceFreq[right['text']] = 0
        end
        return reason.createDeviceFreq[left['text']] > reason.createDeviceFreq[right['text']]
    end)
    hs.json.write(reason.createDeviceData, 'bce_data.json', true, true)
    reason.createDeviceChooser:choices(reason.createDeviceData)
end

function reason:createDeviceRebuild()
    -- rebuilds the device database by scraping the menus

    local app = hs.appfinder.appFromName('Reason')
    if app:getMenuItems() == nil then return end -- quit if no menus are up yet
    local menus = app:getMenuItems()[4]['AXChildren'][1] -- children of "Create" menu
    local newDevices = {}

    -- build Instruments, Effects, and Utilities
    for i=7, 9 do
        local foundSubmenu = false
        for j=1, #menus[i]['AXChildren'][1] do
            -- iterate until we find Built-in Devices
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

    -- build Players
    for i=1, #menus[10]['AXChildren'][1] do
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

    -- update table and refresh
    reason.createDeviceData = newDevices
    reason:createDeviceRefresh()
    hs.alert('rebuilt device list')
end

return reason
