---@param data MenuData
---@param opts? {submenu?: string; mouse_nav?: boolean; on_close?: string | string[]}
function open_command_menu(data, opts)
	local function run_command(command)
		if type(command) == 'string' then
			mp.command(command)
		else
			---@diagnostic disable-next-line: deprecated
			mp.commandv(unpack(command))
		end
	end
	---@type MenuOptions
	local menu_opts = {}
	if opts then
		menu_opts.mouse_nav = opts.mouse_nav
		if opts.on_close then menu_opts.on_close = function() run_command(opts.on_close) end end
	end
	local menu = Menu:open(data, run_command, menu_opts)
	if opts and opts.submenu then menu:activate_submenu(opts.submenu) end
	return menu
end

---@param opts? {submenu?: string; mouse_nav?: boolean; on_close?: string | string[]}
function toggle_menu_with_items(opts)
	if Menu:is_open('menu') then Menu:close()
	else open_command_menu({type = 'menu', items = config.menu_items}, opts) end
end

---@param options {type: string; title: string; list_prop: string; active_prop?: string; serializer: fun(list: any, active: any): MenuDataItem[]; on_select: fun(value: any); on_move_item?: fun(from_index: integer, to_index: integer, submenu_path: integer[]); on_delete_item?: fun(index: integer, submenu_path: integer[])}
function create_self_updating_menu_opener(options)
	return function()
		if Menu:is_open(options.type) then Menu:close() return end
		local list = mp.get_property_native(options.list_prop)
		local active = options.active_prop and mp.get_property_native(options.active_prop) or nil
		local menu

		local function update() menu:update_items(options.serializer(list, active)) end

		local ignore_initial_list = true
		local function handle_list_prop_change(name, value)
			if ignore_initial_list then ignore_initial_list = false
			else list = value update() end
		end

		local ignore_initial_active = true
		local function handle_active_prop_change(name, value)
			if ignore_initial_active then ignore_initial_active = false
			else active = value update() end
		end

		local initial_items, selected_index = options.serializer(list, active)

		-- Items and active_index are set in the handle_prop_change callback, since adding
		-- a property observer triggers its handler immediately, we just let that initialize the items.
		menu = Menu:open(
			{type = options.type, title = options.title, items = initial_items, selected_index = selected_index},
			options.on_select, {
			on_open = function()
				mp.observe_property(options.list_prop, 'native', handle_list_prop_change)
				if options.active_prop then
					mp.observe_property(options.active_prop, 'native', handle_active_prop_change)
				end
			end,
			on_close = function()
				mp.unobserve_property(handle_list_prop_change)
				mp.unobserve_property(handle_active_prop_change)
			end,
			on_move_item = options.on_move_item,
			on_delete_item = options.on_delete_item,
		})
	end
end

------------------------------------------------------------------------------------------------------
------------------------- Mediainfo ------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

----- string

function is_empty(input)
    if input == nil or input == "" then
        return true
    end
end

function contains(input, find)
    if not is_empty(input) and not is_empty(find) then
        return input:find(find, 1, true)
    end
end

----- file

function file_exists(path)
    if is_empty(path) then return false end
    local file = io.open(path, "r")

    if file ~= nil then
        io.close(file)
        return true
    end
end

function file_write(path, content)
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
end

----- shared

local is_windows = package.config:sub(1,1) == "\\"
local msg = require "mp.msg"
local utils = require "mp.utils"

function get_temp_dir()
    if is_windows then
        return os.getenv("TEMP") .. "\\"
    else
        return "/tmp/"
    end
end

local media_info_cache = {}

function get_media_info()
	local path = mp.get_property("path")

	if media_info_cache[path] then
		return media_info_cache[path]
	end

	local media_info_format = [[General;N: %FileNameExtension%\\nG: %Format%, %FileSize/String%, %Duration/String%, %OverallBitRate/String%, %Recorded_Date%\\n
Video;V: %Format%, %Format_Profile%, %Width%x%Height%, %BitRate/String%, %FrameRate% FPS\\n
Audio;A: %Language/String%, %Format%, %Format_Profile%, %BitRate/String%, %Channel(s)% ch, %SamplingRate/String%, %Title%\\n
Text;S: %Language/String%, %Format%, %Format_Profile%, %Title%\\n]]

	local format_file = get_temp_dir() .. "media-info-format-2.txt"

	if not file_exists(format_file) then
		file_write(format_file, media_info_format)
	end

	if contains(path, "://") or not file_exists(path) then
		return
	end

	local proc_result = mp.command_native({
		name = "subprocess",
		playback_only = false,
		capture_stdout = true,
		args = {"mediainfo", "--inform=file://" .. format_file, path},
	})

	if proc_result.status == 0 then
		local output = proc_result.stdout

		--output = string.gsub(output, ", , ,", ",")
		--output = string.gsub(output, ", ,", ",")
		--output = string.gsub(output, ": , ", ": ")
		--output = string.gsub(output, ", \\n\r*\n", "\\n")
		output = string.gsub(output, "\\n\r*\n", "\\n")
		--output = string.gsub(output, ", \\n", "\\n")
		output = string.gsub(output, "%.000 FPS", " FPS")
		output = string.gsub(output, "MPEG Audio, Layer 3", "MP3")

		media_info_cache[path] = output

		return output
	end
end

------------------------------------------------------------------------------------------------------

function mysplit(inputstr, sep)
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function getBitrate(inputstr)
	local str_index = string.find(inputstr, ',')
	inputstr = string.sub(inputstr, str_index + 2)
	str_index = string.find(inputstr, ',')
	inputstr = string.sub(inputstr, str_index + 2)
	str_index = string.find(inputstr, ',')
	inputstr = string.sub(inputstr, str_index + 2)
	str_index = string.find(inputstr, ',')
	inputstr = string.sub(inputstr, 1, str_index - 1)
	return inputstr
end

function getVideoCodec(inputstr)
	local str_index = string.find(inputstr, ',')
	local str = string.sub(inputstr, str_index + 2)
	str_index = string.find(str, ',') + str_index
	inputstr = string.sub(inputstr, 2, str_index)
	return inputstr
end


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

function create_select_tracklist_type_menu_opener(menu_title, track_type, track_prop, load_command)
	local function serialize_tracklist(tracklist)
		local items = {}

		if load_command then
			items[#items + 1] = {
				title = t('Load'), bold = true, italic = true, hint = t('open file'), value = '{load}', separator = true,
			}
		end
		local media_info_string = get_media_info()
		if media_info_string then
			media_info_string = string.gsub(media_info_string, "\\n", "§")
			media_info_table = mysplit(media_info_string,'§')
		end

		if media_info_table then
			vid_string={}
			aid_string={}
			sid_string={}

			local index_var = 1
			for _, track in ipairs(media_info_table) do
				if track:sub(1,1) == 'V' then
					table.insert(vid_string, track:sub(3))
				end
				if track:sub(1,1) == 'A' then
					table.insert(aid_string, track:sub(3))
				end
				if track:sub(1,1) == 'S' then
					table.insert(sid_string, track:sub(3))
				end
				index_var = index_var + 1
			end
		end

		local first_item_index = #items + 1
		local active_index = nil
		local disabled_item = nil

		-- Add option to disable a subtitle track. This works for all tracks,
		-- but why would anyone want to disable audio or video? Better to not
		-- let people mistakenly select what is unwanted 99.999% of the time.
		-- If I'm mistaken and there is an active need for this, feel free to
		-- open an issue.
		if track_type == 'sub' then
			disabled_item = {title = t('Disabled'), italic = true, muted = true, hint = '—', value = nil, active = true}
			items[#items + 1] = disabled_item
		end

		local tmp_track_type = ''
		local track_type_number = 0
		local index_var = 3
		local vid_index = 1
		local aid_index = 1
		local sid_index = 1
		for _, track in ipairs(tracklist) do
			if track_type == 'all' and track.type ~= tmp_track_type then
				tmp_track_type = track.type
				name = track.type
				if track.type == 'sub' then
					name = '—————————————— Subtitles ——————————————'
					track_type_number = 3
				end
				if track.type == 'audio' then
					name = '———————————————— Audio ————————————————'
					track_type_number = 2
				end
				if track.type == 'video' then
					name = '———————————————— Video ————————————————'
					track_type_number = 1
				end
				items[#items + 1] = {
					title = t(name), bold = true, separator = true, active = false, selectable = false, align='center'
				}
			end

			if track_type == 'all' or track.type == track_type then
				local hint_values = {}
				local function h(value) hint_values[#hint_values + 1] = value end

				if track.type == 'sub' then
					if track.forced then h(t('Forced')) end
					if track.default then h(t('Default')) end
					if track.external then h(t('External')) end
					if track.lang then h(track.lang:upper()) end
					h(track.codec:upper())
					sid_index = sid_index + 1
				end
				if track.type == 'audio' then
					if track.forced then h(t('Forced')) end
					if track.default then h(t('Default')) end
					if track.external then h(t('External')) end
					if track['demux-channel-count'] then h(t(track['demux-channel-count'] == 1 and '%s Channel' or '%s Channels', track['demux-channel-count'])) end
					if track['demux-samplerate'] then h(string.format('%.3gkHz', track['demux-samplerate'] / 1000)) end
					h(track.codec:sub(1,1):upper() .. track.codec:sub(2))
					if track.lang then h(track.lang:upper()) end
					if aid_string and #aid_string >= aid_index then
						bitrate = getBitrate(aid_string[aid_index])
						if bitrate and bitrate ~= '' then h(bitrate) end
					end
					aid_index = aid_index + 1
				end
				if track.type == 'video' then
					if track.lang then h(track.lang:upper()) end
					if track.forced then h(t('Forced')) end
					if track.default then h(t('Default')) end
					if track.external then h(t('External')) end
					if vid_string and #vid_string >= vid_index then
						h(getVideoCodec(vid_string[vid_index]))
					else
						h(track.codec:upper())
					end
					if track['demux-fps'] then h(string.format('%.5g FPS', track['demux-fps'])) end
					if track['demux-h'] then
						h(track['demux-w'] and (track['demux-w'] .. 'x' .. track['demux-h']) or (track['demux-h'] .. 'p'))
					end
					if vid_string and #vid_string >= vid_index then
						bitrate = getBitrate(vid_string[vid_index])
						if bitrate and bitrate ~= '' then h(bitrate) end
					end
					vid_index = vid_index + 1
				end

				items[#items + 1] = {
					title = (track.title and track.title or t('Track %s', track.id)),
					hint = table.concat(hint_values, ', '),
					value = track.id * 10 + track_type_number,
					active = track.selected,
				}

				if track.selected then
					if disabled_item then disabled_item.active = false end
					active_index = #items
				end
			end
			index_var = index_var + 1
		end

		return items, active_index or first_item_index
	end

	local function selection_handler(value)
		if value == '{load}' then
			mp.command(load_command)
		else
			if value then
				value = tostring(value)
				id = tonumber(value:sub(1,1))
				a_track_type = tonumber(value:sub(-1))

				if a_track_type == 1 then
					track_prop = 'vid'
				end
				if a_track_type == 2 then
					track_prop = 'aid'
				end
				if a_track_type == 3 then
					track_prop = 'sid'
				end
			else
				id = nil
			end
			mp.commandv('set', track_prop, id and id or 'no')

			-- If subtitle track was selected, assume user also wants to see it
			if id and (track_type == 'sub' or a_track_type == 3) then
				mp.commandv('set', 'sub-visibility', 'yes')
			end
		end
	end

	if track_type == 'all' then
		menu_title = t('All Tracks')
	end

	return create_self_updating_menu_opener({
		title = menu_title,
		type = track_type,
		list_prop = 'track-list',
		serializer = serialize_tracklist,
		on_select = selection_handler,
	})
end

---@alias NavigationMenuOptions {type: string, title?: string, allowed_types?: string[], active_path?: string, selected_path?: string; on_open?: fun(); on_close?: fun()}

-- Opens a file navigation menu with items inside `directory_path`.
---@param directory_path string
---@param handle_select fun(path: string): nil
---@param opts NavigationMenuOptions
function open_file_navigation_menu(directory_path, handle_select, opts)
	directory = serialize_path(normalize_path(directory_path))
	opts = opts or {}

	if not directory then
		msg.error('Couldn\'t serialize path "' .. directory_path .. '.')
		return
	end

	local files, directories = read_directory(directory.path, opts.allowed_types)
	local is_root = not directory.dirname
	local path_separator = path_separator(directory.path)

	if not files or not directories then return end

	sort_filenames(directories)
	sort_filenames(files)

	-- Pre-populate items with parent directory selector if not at root
	-- Each item value is a serialized path table it points to.
	local items = {}

	if is_root then
		if state.platform == 'windows' then
			items[#items + 1] = {title = '..', hint = t('Drives'), value = '{drives}', separator = true}
		end
	else
		items[#items + 1] = {title = '..', hint = t('parent dir'), value = directory.dirname, separator = true}
	end

	local back_path = items[#items] and items[#items].value
	local selected_index = #items + 1

	for _, dir in ipairs(directories) do
		items[#items + 1] = {title = dir, value = join_path(directory.path, dir), hint = path_separator}
	end

	for _, file in ipairs(files) do
		items[#items + 1] = {title = file, value = join_path(directory.path, file)}
	end

	for index, item in ipairs(items) do
		if not item.value.is_to_parent and opts.active_path == item.value then
			item.active = true
			if not opts.selected_path then selected_index = index end
		end

		if opts.selected_path == item.value then selected_index = index end
	end

	---@type MenuCallback
	local function open_path(path, meta)
		local is_drives = path == '{drives}'
		local is_to_parent = is_drives or #path < #directory_path
		local inheritable_options = {
			type = opts.type, title = opts.title, allowed_types = opts.allowed_types, active_path = opts.active_path,
		}

		if is_drives then
			open_drives_menu(function(drive_path)
				open_file_navigation_menu(drive_path, handle_select, inheritable_options)
			end, {
				type = inheritable_options.type, title = inheritable_options.title, selected_path = directory.path,
				on_open = opts.on_open, on_close = opts.on_close,
			})
			return
		end

		local info, error = utils.file_info(path)

		if not info then
			msg.error('Can\'t retrieve path info for "' .. path .. '". Error: ' .. (error or ''))
			return
		end

		if info.is_dir and not meta.modifiers.ctrl then
			--  Preselect directory we are coming from
			if is_to_parent then
				inheritable_options.selected_path = directory.path
			end

			open_file_navigation_menu(path, handle_select, inheritable_options)
		else
			handle_select(path)
		end
	end

	local function handle_back()
		if back_path then open_path(back_path, {modifiers = {}}) end
	end

	local menu_data = {
		type = opts.type, title = opts.title or directory.basename .. path_separator, items = items,
		selected_index = selected_index,
	}
	local menu_options = {on_open = opts.on_open, on_close = opts.on_close, on_back = handle_back}

	return Menu:open(menu_data, open_path, menu_options)
end

-- Opens a file navigation menu with Windows drives as items.
---@param handle_select fun(path: string): nil
---@param opts? NavigationMenuOptions
function open_drives_menu(handle_select, opts)
	opts = opts or {}
	local process = mp.command_native({
		name = 'subprocess',
		capture_stdout = true,
		playback_only = false,
		args = {'wmic', 'logicaldisk', 'get', 'name', '/value'},
	})
	local items, selected_index = {}, 1

	if process.status == 0 then
		for _, value in ipairs(split(process.stdout, '\n')) do
			local drive = string.match(value, 'Name=([A-Z]:)')
			if drive then
				local drive_path = normalize_path(drive)
				items[#items + 1] = {
					title = drive, hint = t('drive'), value = drive_path, active = opts.active_path == drive_path,
				}
				if opts.selected_path == drive_path then selected_index = #items end
			end
		end
	else
		msg.error(process.stderr)
	end

	return Menu:open(
		{type = opts.type, title = opts.title or t('Drives'), items = items, selected_index = selected_index},
		handle_select
	)
end
