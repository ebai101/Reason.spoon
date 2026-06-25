local repo = {}

local log = hs.logger.new("repo", "debug")

repo.path = "reason_freq_data.db"
repo.connected = false

function repo:open()
	if self.connected then
		log.d("repo already connected")
		return
	end

	self.db = hs.sqlite3.open(self.path)

	-- schema
	if
		self.db:exec([=[
        create table if not exists devices (
            id integer primary key,
            uri text unique not null,
            chooser_text text not null,
            chooser_subtext text,
            is_preset boolean not null,
            menu_selector text
        );

        create table if not exists frequencies (
            uri text unique not null,
            freq integer not null,
            constraint frequencies_devices_fk foreign key (uri) references devices(uri)
        );
    ]=]) ~= hs.sqlite3.OK
	then
		error("error creating table: " .. self.db:errmsg())
	end

	-- performance optimizations
	if
		self.db:exec([[
        PRAGMA synchronous = OFF;
        PRAGMA journal_mode = MEMORY;
        PRAGMA temp_store = MEMORY;
        PRAGMA cache_size = -2000;
    ]]) ~= hs.sqlite3.OK
	then
		error("error changing table pragmas: " .. self.db:errmsg())
	end

	-- indexes
	local indexes = {
		"create index if not exists idx_devices_uri on devices(uri);",
		"create index if not exists idx_devices_is_preset on devices(is_preset);",
		"create index if not exists idx_frequencies_freq on frequencies(freq);",
	}
	for _, idx in ipairs(indexes) do
		if self.db:exec(idx) ~= hs.sqlite3.OK then
			error("error creating index: " .. self.db:errmsg())
		end
	end

	-- insert statement
	self.insertStmt = self.db:prepare([[
        insert or replace into devices
            (uri, chooser_text, chooser_subtext, is_preset, menu_selector)
        values
            (?, ?, ?, ?, ?)
        ]])
	if not self.insertStmt then
		error("failed to prepare insert statement: " .. self.db:errmsg())
	end

	-- update freq statement
	self.updateFreqStmt = self.db:prepare([[
        insert into frequencies (uri, freq)
        values (?, 1)
        on conflict(uri) do update
        set freq = freq + 1;
    ]])
	if not self.updateFreqStmt then
		error("failed to prepare update freq statement: " .. self.db:errmsg())
	end

	self.connected = true
	log.d("connected to repo at " .. self.path)
end

function repo:getDevices()
	local data = {}

	for row in
		self.db:nrows([[
    select
        d.uri,
        d.chooser_text as text,
        d.chooser_subtext as subText,
        f.freq,
        d.is_preset as isPreset,
        d.menu_selector as menuSelector
    from devices d
    left join frequencies f on f.uri = d.uri
    order by
        is_preset asc,
        freq desc
    ]])
	do
		if row["menuSelector"] ~= nil then
			local parsed = hs.json.decode(row["menuSelector"])
			row["menuSelector"] = parsed
		end
		table.insert(data, row)
	end

	return data
end

function repo:insertDevices(objects)
	if #objects == 0 then
		return
	end

	self.db:exec("begin transaction")

	if
		self.db:exec([[
        create temporary table if not exists temp_devices (
            uri text primary key,
            chooser_text text not null,
            chooser_subtext text,
            is_preset boolean not null,
            menu_selector text
        ) without rowid
    ]]) ~= hs.sqlite3.OK
	then
		error("failed to create temporary table: " .. self.db:errmsg())
	end

	local tempInsert = self.db:prepare([[
        insert into temp_devices
            (uri, chooser_text, chooser_subtext, is_preset, menu_selector)
        values (?, ?, ?, ?, ?)
    ]])
	if not tempInsert then
		error("failed to prepare insert statement: " .. self.db:errmsg())
	end

	for _, obj in ipairs(objects) do
		local menuSelectorJSON = nil
		if obj.menuSelector ~= nil then
			menuSelectorJSON = hs.json.encode(obj.menuSelector)
		end
		tempInsert:bind_values(obj.uri, obj.text, obj.subText, obj.isPreset, menuSelectorJSON)
		tempInsert:step()
		tempInsert:reset()
	end

	tempInsert:finalize()

	if
		self.db:exec([[
        update devices
        set
            chooser_text = (
                select t.chooser_text
                from temp_devices t
                where t.uri = devices.uri
            ),
            chooser_subtext = (
                select t.chooser_subtext
                from temp_devices t
                where t.uri = devices.uri
            ),
            is_preset = (
                select t.is_preset
                from temp_devices t
                where t.uri = devices.uri
            ),
            menu_selector = (
                select t.menu_selector
                from temp_devices t
                where t.uri = devices.uri
            )
        where exists (
            select 1
            from temp_devices t
            where t.uri = devices.uri
        );

        insert into devices (uri, chooser_text, chooser_subtext, is_preset, menu_selector)
        select t.*
        from temp_devices t
        where not exists (
            select 1
            from devices d
            where d.uri = t.uri
        );
    ]]) ~= hs.sqlite3.OK
	then
		error("failed to update devices table: " .. self.db:errmsg())
	end

	self.db:exec("drop table temp_devices")
	self.db:exec("commit")
end

function repo:updateFreq(uri)
	self.updateFreqStmt:bind_values(uri)
	local result = self.updateFreqStmt:step()
	if result ~= hs.sqlite3.DONE then
		error("error updating device freq: " .. self.db:errmsg())
	end
	self.updateFreqStmt:reset()
end

function repo:close()
	if not self.connected then
		log.d("repo already disconnected")
		return
	end

	if self.insertStmt then
		self.insertStmt:finalize()
		self.insertStmt = nil
	end

	if self.updateFreqStmt then
		self.updateFreqStmt:finalize()
		self.updateFreqStmt = nil
	end

	if self.db then
		self.db:close()
		self.db = nil
	end

	self.connected = false
	log.d("disconnected from repo")
end

return repo
