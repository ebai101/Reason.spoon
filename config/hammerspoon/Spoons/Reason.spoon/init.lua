local reason = {}
local log = hs.logger.new('reason', 'debug')

-- spoon setup
-- ----- -----

reason.__index = reason
reason.name = "reason config"
reason.version = "1.0"
reason.author = "ethan bailey"

function reason:start()
    self.app = hs.appfinder.appFromName('Reason')
    self.bceList = hs.json.read('bce_data.json')
    self.bceChooser = hs.chooser.new(function(choice)
        if choice then
            -- select menu item, creating the device in daw
            log.d(string.format('choice %s selected', choice))
            self.app:selectMenuItem(choice['menuSelector'])

            -- update frequency
            print(choice)
        end
    end)

    self.watcher = hs.application.watcher.new(function(appName, eventType, app)
        if appName == 'Reason' then
            if eventType == hs.application.watcher.activated then
                log.d('reason activated')
                self.bceHotkey:enable()
            elseif eventType == hs.application.watcher.deactivated then
                log.d('reason deactivated')
                self.bceHotkey:disable()
            end
        end
    end)
    self.watcher:start()
end

function reason:bindHotkeys(m)
    self.bceHotkey = hs.hotkey.new(m.bce[1], m.bce[2], self.showBCEChooser)
end


-- bce setup
-- --- -----

function reason:showBCEChooser()
    -- rebuild on double press
    if self.bceChooser:isVisible() then
        self:bceRebuild()
    end

    self.bceChooser:choices(self.bceList)
    self.bceChooser:show()
end


function reason:bceRebuild()
    reason.app = hs.appfinder.appFromName('Reason') -- refresh the app instance
    reason.bceList = {} -- delete list cache
    if reason.app:getMenuItems() == nil then return end -- quit if no menus are up yet
    local menus = reason.app:getMenuItems()[4]['AXChildren'][1]
    local newList = {}

    for i=7, 9 do
        for j=11, #menus[i]['AXChildren'][1] do
            for k=1, #menus[i]['AXChildren'][1][j]['AXChildren'][1] do
                if not(menus[i]['AXChildren'][1][j]['AXChildren'][1][k]['AXTitle'] == '') then
                    local title = menus[i]['AXChildren'][1][j]['AXChildren'][1][k]['AXTitle']
                    log.d(title)
                    reason.bceList[title] = {
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
                            },
                            ["freq"] = reason.bceList[title]["freq"]
                        }
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
                    },
                    ["freq"] = reason.bceList[title]["freq"]
                })
        end
    end

    -- refresh json
    hs.json.write(newList, 'bce_data.json', false, true)
    reason.bceChooser:choices(newList)
    hs.alert('reloaded')
end

return reason
