local createDevice = {}
local log = hs.logger.new('createDev', 'debug')

createDevice.hotkeys = {}
createDevice.dataFile = 'bce_data.json'
createDevice.freqFile = 'bce_freq.json'

-----------
-- setup --
-----------

function createDevice:start()
    createDevice.deviceData = hs.json.read(createDevice.dataFile)
    createDevice.freqData = hs.json.read(createDevice.freqFile)
    createDevice.chooser = hs.chooser.new(function(choice)
        return createDevice:select(choice)
    end)

    if not (createDevice.presetCommand or createDevice.presetFolders) then
        log.i('no preset folders or command provided')
        log.i('consider running spoon.Reason:setPresetFolders() in your init.lua')
    end
end

function createDevice:bindHotkeys(maps)
    table.insert(createDevice.hotkeys, hs.hotkey.new(maps.createDevice[1], maps.createDevice[2], createDevice.show))
end

function createDevice:activate(app)
    for _, v in pairs(createDevice.hotkeys) do v:enable() end
    createDevice.app = app
end

function createDevice:deactivate()
    for _, v in pairs(createDevice.hotkeys) do v:disable() end
end

--------------------
-- implementation --
--------------------

-- createDevice:show()
-- Method
-- Shows the device chooser
-- If the device chooser is already active (double press) then it calls createDevice:rebuild()
function createDevice:show()
    if createDevice.chooser:isVisible() then
        createDevice:rebuild()
    else
        createDevice.chooser:choices(createDevice.deviceData)
        createDevice.chooser:show()
    end
end

-- createDevice:select(choice)
-- Method
-- Creates an instance of the selected device/preset
-- Writes the updated frequency data to createDevice.freqFile
--
-- Parameters:
-- * choice - A choice from the chooser's choices table
function createDevice:select(choice)
    if not choice then return end
    if choice['menuSelector'] == nil then
        -- open preset
        local openFilename = choice['subText']
        local openCommand = string.format('open -a Reason\\ 12 "%s"', openFilename)
        log.d(openCommand)
        hs.execute(openCommand)
    else
        -- create device
        log.d(string.format('selected %s', choice['text']))
        createDevice.app:selectMenuItem(choice['menuSelector'])
    end

    if createDevice.freqData[choice['text']] == nil then
        createDevice.freqData[choice['text']] = 0
    else
        createDevice.freqData[choice['text']] = createDevice.freqData[choice['text']] + 1
    end

    -- write freq data. also writes to bce_data.json since createDeviceRefresh() is called
    hs.json.write(createDevice.freqData, createDevice.freqFile, true, true)
    createDevice:refresh()
end

-- createDevice:refresh()
-- Method
-- Sorts the device table using the frequency data from createDevice.freqData
-- Writes the list of devices to createDevice.dataFile
function createDevice:refresh()
    table.sort(createDevice.deviceData, function(left, right)
        if createDevice.freqData[left['text']] == nil then
            createDevice.freqData[left['text']] = 0
        end
        if createDevice.freqData[right['text']] == nil then
            createDevice.freqData[right['text']] = 0
        end
        return createDevice.freqData[left['text']] > createDevice.freqData[right['text']]
    end)
    hs.json.write(createDevice.deviceData, createDevice.dataFile, true, true)
    createDevice.chooser:choices(createDevice.deviceData)
end

function createDevice:_rebuildPresets()
    local presets = {}

    -- default to preset command
    if createDevice.presetCommand then
        fileList = hs.execute(createDevice.presetCommand)
        for abspath in string.gmatch(fileList, '[^\r\n]+') do
            local filename = abspath:match('^.+/(.+)$')
            table.insert(presets, {
                ['text'] = filename,
                ['subText'] = abspath,
            })
            log.d(filename)
        end
    elseif createDevice.presetFolders then
        for _, dir in pairs(createDevice.presetFolders) do
            presets = createDevice:_presetWalk(dir, presets)
        end
    else
        log.e('no presets specified! cannot rebuild preset list')
    end

    return presets
end

function createDevice:_presetWalk(dir, presets)
    for filename in hs.fs.dir(dir) do
        local abspath = string.format('%s/%s', dir, filename)
        local uti = hs.fs.fileUTI(abspath)

        if (string.find(uti, 'se.propellerheads.reason') or string.find(uti, 'se.propellerheads.rackextension')) then
            table.insert(presets, {
                ['text'] = filename,
                ['subText'] = abspath,
            })
            log.d(filename)
        elseif string.find(uti, 'public.folder') then
            if not (filename == '.' or filename == '..') then
                createDevice:_presetWalk(abspath, presets)
            end
        end
    end
    return presets
end

function createDevice:_rebuildDevices()
    local devices = {}

    if createDevice.app:getMenuItems() == nil then return devices end -- quit if no menus are up yet
    local menus = createDevice.app:getMenuItems()[4]['AXChildren'][1] -- children of "Create" menu
    -- build Instruments, Effects, and Utilities
    for i = 8, 10 do
        local foundSubmenu = false
        for j = 1, #menus[i]['AXChildren'][1] do
            -- iterate until we find Reason Studios
            local subtitle = menus[i]['AXChildren'][1][j]['AXTitle']
            log.d(subtitle)
            if subtitle == 'Reason Studios' then foundSubmenu = true end
            -- iterate thru this submenu and the successive submenus
            if foundSubmenu then
                local submenu = menus[i]['AXChildren'][1][j]['AXChildren'][1]
                for k = 1, #submenu do
                    if not (submenu[k]['AXTitle'] == '') then -- table contains divider bars, which have a blank title
                        local title = submenu[k]['AXTitle']
                        log.d(title)
                        table.insert(devices, {
                            ['text'] = title,
                            ['subText'] = string.format('%s - %s',
                                menus[i]['AXTitle'],
                                subtitle
                            ),
                            ['menuSelector'] = {
                                'Create',
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
    for i = 1, #menus[11]['AXChildren'][1] do
        if not (menus[11]['AXChildren'][1][i]['AXTitle'] == '') then -- table may contain divider bars in the future
            local title = menus[11]['AXChildren'][1][i]['AXTitle']
            log.d(title)
            table.insert(devices, {
                ['text'] = title,
                ['subText'] = 'Players',
                ['menuSelector'] = {
                    'Create', 'Players',
                    title,
                }
            })
        end
    end

    return devices
end

-- createDevice:rebuild()
-- Method
-- Rebuilds the device list
-- Scrapes the Create menus for available devices
-- Also scans preset directories for available presets
function createDevice:rebuild()
    -- update table and refresh
    local newData = {}

    -- build devices
    for _, v in pairs(createDevice:_rebuildDevices()) do
        table.insert(newData, v)
    end

    -- build presets
    if (createDevice.presetCommand or createDevice.presetFolders) then
        for _, v in pairs(createDevice:_rebuildPresets()) do
            table.insert(newData, v)
        end
    end

    createDevice.deviceData = newData
    createDevice:refresh()
    hs.alert('rebuilt device list')
end

-- createDevice:setPresetCommand()
-- Method
-- Sets the command used to find presets for the device chooser
-- Any command that returns a list of files separated by newlines (e.g. find, fd) will work
-- Note that any commands must be absolute paths, for example "/usr/bin/find" instead of "find"
--
-- Parameters
-- * presetCommand - A string containing a shell command
function createDevice:setPresetCommand(presetCommand)
    createDevice.presetCommand = presetCommand
end

function createDevice:setPresetFolders(presetFolders)
    createDevice.presetFolders = presetFolders
end

return createDevice
