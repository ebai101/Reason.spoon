local createDevice = {}
local log = hs.logger.new("createDev", "debug")
local fzy = dofile(hs.spoons.resourcePath("fzy.lua"))

createDevice.hotkeys = {}
createDevice.repo = dofile(hs.spoons.resourcePath("repo.lua"))

local FZY_WEIGHT = 0.6
local FREQ_WEIGHT = 0.4

-----------
-- setup --
-----------

function createDevice:start()
	self.repo:open()

	self.chooser = hs.chooser
		.new(function(choice)
			return self:select(choice)
		end)
		:queryChangedCallback(function()
			self:queryChanged()
		end)

	if not (self.presetCommand or self.presetFolders) then
		log.i("no preset folders or command provided")
		log.i("consider running spoon.Reason:setPresetFolders() in your init.lua")
	end

	self:refresh()
end

function createDevice:bindHotkeys(maps)
	table.insert(
		self.hotkeys,
		hs.hotkey.new(maps.createDevice[1], maps.createDevice[2], hs.fnutils.partial(self.show, self))
	)
end

function createDevice:activate(app)
	for _, v in pairs(self.hotkeys) do
		v:enable()
	end
	self.app = app
	self.repo:open()
end

function createDevice:deactivate()
	for _, v in pairs(self.hotkeys) do
		v:disable()
	end
	self.repo:close()
end

--------------------
-- implementation --
--------------------

function createDevice:show()
	if self.chooser:isVisible() then
		log.d("rebuilding device list")
		local start = hs.timer.absoluteTime()
		self:rebuild()
		hs.alert("rebuilt device list")
		local elapsed = hs.timer.absoluteTime() - start
		print("insert took " .. elapsed / 1000000 .. " ms")
	else
		self.chooser:show()
	end
end

function createDevice:select(choice)
	if not choice then
		return
	end

	log.d(string.format("selected %s", choice["text"]))

	if choice["isPreset"] == 1 then
		-- open preset
		local openFilename = choice["subText"]
		local openCommand = string.format('open -a Reason\\ 14 "%s"', openFilename)
		log.d(openCommand)
		hs.execute(openCommand)
	else
		-- create device
		self.app:selectMenuItem(choice["menuSelector"])
	end

	self.repo:updateFreq(choice["uri"])
	self:refresh()
end

function createDevice:refresh()
	self.deviceData = self.repo:getDevices()
	self.chooser:choices(self.deviceData)
end

function createDevice:queryChanged()
	local query = self.chooser:query()
	if query == "" then
		self.chooser:choices(self.deviceData)
		return
	end

	local results = {}
	for i = 1, #self.deviceData do
		local dev = self.deviceData[i]
		local line = dev["text"]
		if fzy.has_match(query, line) then
			dev["score"] = fzy.score(query, line)
			local logFreq = 1
			if dev["freq"] ~= nil then
				logFreq = hs.math.log(dev["freq"] + 1)
			end
			dev["weightedRank"] = (dev["score"] * FZY_WEIGHT) + (logFreq * FREQ_WEIGHT)
			table.insert(results, dev)
		end
	end

	table.sort(results, function(a, b)
		return a["weightedRank"] > b["weightedRank"]
	end)
	self.chooser:choices(results)
end

function createDevice:rebuild()
	local newData = {}

	-- build devices
	for _, v in pairs(self:_rebuildDevices()) do
		table.insert(newData, v)
	end

	-- build presets
	if self.presetCommand or self.presetFolders then
		for _, v in pairs(createDevice:_rebuildPresets()) do
			table.insert(newData, v)
		end
	end

	self.repo:insertDevices(newData)
	self.deviceData = newData
	self.chooser:choices(self.deviceData)
end

function createDevice:_rebuildPresets()
	local presets = {}

	-- default to preset command
	if self.presetCommand then
		local fileList = hs.execute(self.presetCommand) or ""
		for abspath in string.gmatch(fileList, "[^\r\n]+") do
			local filename = abspath:match("^.+/(.+)$")
			table.insert(presets, {
				["text"] = filename,
				["subText"] = abspath,
				["uri"] = abspath,
				["isPreset"] = true,
			})
			-- log.d(filename)
		end
	elseif self.presetFolders then
		for _, dir in pairs(self.presetFolders) do
			presets = self:_presetWalk(dir, presets)
		end
	else
		log.e("no presets specified! cannot rebuild preset list")
	end

	return presets
end

function createDevice:_presetWalk(dir, presets)
	for filename in hs.fs.dir(dir) do
		local abspath = string.format("%s/%s", dir, filename)
		local uti = hs.fs.fileUTI(abspath) or ""

		if string.find(uti, "se.propellerheads.reason") or string.find(uti, "se.propellerheads.rackextension") then
			table.insert(presets, {
				["text"] = filename,
				["subText"] = abspath,
				["uri"] = abspath,
				["isPreset"] = true,
			})
			-- log.d(filename)
		elseif string.find(uti, "public.folder") then
			if not (filename == "." or filename == "..") then
				self:_presetWalk(abspath, presets)
			end
		end
	end
	return presets
end

function createDevice:_rebuildDevices()
	local devices = {}

	if self.app:getMenuItems() == nil then
		return devices
	end -- quit if no menus are up yet
	local menus = self.app:getMenuItems()[4]["AXChildren"][1] -- children of "Create" menu
	-- build Instruments, Effects, and Utilities
	for i = 8, 10 do
		local foundSubmenu = false
		for j = 1, #menus[i]["AXChildren"][1] do
			-- iterate until we find Reason Studios
			local subtitle = menus[i]["AXChildren"][1][j]["AXTitle"]
			-- log.d(subtitle)
			if subtitle == "Reason Studios" then
				foundSubmenu = true
			end
			-- iterate thru this submenu and the successive submenus
			if foundSubmenu then
				local submenu = menus[i]["AXChildren"][1][j]["AXChildren"][1]
				for k = 1, #submenu do
					if not (submenu[k]["AXTitle"] == "") then -- table contains divider bars, which have a blank title
						local title = submenu[k]["AXTitle"]
						local subText = string.format("%s - %s", menus[i]["AXTitle"], subtitle)
						local menuSelector = {
							"Create",
							menus[i]["AXTitle"],
							subtitle,
							submenu[k]["AXTitle"],
						}
						local uri = table.concat(menuSelector, ":")

						-- log.d(title)
						table.insert(devices, {
							["text"] = title,
							["subText"] = subText,
							["menuSelector"] = menuSelector,
							["uri"] = uri,
							["isPreset"] = false,
						})
					end
				end
			end
		end
	end

	-- build Players
	for i = 1, #menus[11]["AXChildren"][1] do
		if not (menus[11]["AXChildren"][1][i]["AXTitle"] == "") then -- table may contain divider bars in the future
			local title = menus[11]["AXChildren"][1][i]["AXTitle"]
			local subText = "Players"
			local menuSelector = {
				"Create",
				"Player Devices",
				title,
			}
			local uri = table.concat(menuSelector, ":")

			-- log.d(title)
			table.insert(devices, {
				["text"] = title,
				["subText"] = subText,
				["menuSelector"] = menuSelector,
				["uri"] = uri,
				["isPreset"] = false,
			})
		end
	end

	return devices
end

return createDevice
