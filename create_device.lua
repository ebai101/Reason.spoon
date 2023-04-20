local createDevice = {}
local log = hs.logger.new('createDev', 'debug')
local app = hs.appfinder.appFromName('Reason')

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
end

function createDevice:bindHotkeys(maps)
	table.insert(createDevice.hotkeys, hs.hotkey.new(maps.createDevice[1], maps.createDevice[2], createDevice.show))
end

function createDevice:activate()
	for _, v in pairs(createDevice.hotkeys) do v:enable() end
end

function createDevice:deactivate()
	for _, v in pairs(createDevice.hotkeys) do v:disable() end
end

--------------------
-- implementation --
--------------------

function createDevice:show()
	-- shows the device chooser
	-- triggers a rebuild on double press

	if createDevice.chooser:isVisible() then
		createDevice:rebuild()
	else
		createDevice.chooser:choices(createDevice.deviceData)
		createDevice.chooser:show()
	end
end

function createDevice:select(choice)
	-- creates an instance of the selected device/preset
	-- writes the updated frequency data to createDevice.freqFile

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
		app:selectMenuItem(choice['menuSelector'])
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

function createDevice:refresh()
	-- sorts the device table by the frequency data in bce_freq.json
	-- writes the list of choices to createDevice.dataFile

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

local function rebuildPresets()
	-- rebuilds the preset database from the filesystem

	local commandString =
	[[ /opt/homebrew/bin/fd -tf . \
    /Users/ethan/My\ Drive/PATCHES/EFFECTS \
    /Users/ethan/My\ Drive/PATCHES/INSTRUMENTS \
    /Users/ethan/My\ Drive/PATCHES/VOCALS \
    -E "*.wav" -E "*.asd" -E "*RM-20*" -E "*.fxp" ]]
	local command = hs.execute(commandString)
	local presets = {}

	for line in string.gmatch(command, '[^\r\n]+') do
		local name = line:match('^.+/(.+)$')
		table.insert(presets, {
			['text'] = name,
			['subText'] = line,
		})
	end

	return presets
end

local function rebuildDevices()
	-- rebuilds the device database by scraping the menus

	local devices = {}

	if app:getMenuItems() == nil then return devices end -- quit if no menus are up yet
	local menus = app:getMenuItems()[4]['AXChildren'][1] -- children of "Create" menu

	-- build Instruments, Effects, and Utilities
	for i = 7, 9 do
		local foundSubmenu = false
		for j = 1, #menus[i]['AXChildren'][1] do
			-- iterate until we find Built-in Devices
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
	for i = 1, #menus[10]['AXChildren'][1] do
		if not (menus[10]['AXChildren'][1][i]['AXTitle'] == '') then -- table may contain divider bars in the future
			local title = menus[10]['AXChildren'][1][i]['AXTitle']
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

function createDevice:rebuild()
	-- update table and refresh
	local newData = {}

	-- build devices
	for _, v in pairs(createDevice:rebuildDevices()) do
		table.insert(newData, v)
	end

	-- build presets
	for _, v in pairs(createDevice:rebuildPresets()) do
		table.insert(newData, v)
	end

	createDevice.deviceData = newData
	createDevice:refresh()
	hs.alert('rebuilt device list')
end

return createDevice
