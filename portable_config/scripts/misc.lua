
--[[

    https://github.com/stax76/mpv-scripts

    This script consist of various small unrelated features.

    Not used code sections can be removed.

    Bindings must be added manually to input.conf.



    Show media info on screen
    -------------------------
    Prints detailed media info on the screen.
    
    Depends on the CLI tool 'mediainfo':
    https://mediaarea.net/en/MediaInfo/Download

    In input.conf add:
    i script-message-to misc print-media-info



    Restart mpv
    -----------
    Restarts mpv restoring the properties path, time-pos,
    pause and volume, the playlist is not restored.

    r script-message-to misc restart-mpv



    Execute Lua code
    ----------------
    Allows to execute Lua Code directly from input.conf.

    It's necessary to add a binding to input.conf:
    #Navigates to the last file in the playlist
    END script-message-to misc execute-lua-code "mp.set_property_number('playlist-pos', mp.get_property_number('playlist-count') - 1)"



    When seeking displays position and duration like so:
    ----------------------------------------------------
    70:00 / 80:00

    Which is different from most players which use:

    01:10:00 / 01:20:00

    input.conf:
    Right no-osd seek 5; script-message-to misc show-position

]]--

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

function trim(input)
    if not is_empty(input) then
        return input:match "^%s*(.-)%s*$"
    end
end

function split(input, sep)
    local tbl = {}

    if not is_empty(input) then
        for str in string.gmatch(input, "([^" .. sep .. "]+)") do
            table.insert(tbl, str)
        end
    end

    return tbl
end

----- math

function round(value)
    return value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
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

function file_read(file_path)
    local file = assert(io.open(file_path, "r"))
    local content = file:read("*all")
    file:close()
    return content
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

----- Execute Lua code

mp.register_script_message("execute-lua-code", function (code)
    loadstring(code)()
end)

----- Alternative seek OSD message

function pad_zero(value)
    local value = round(value)

    if value > 9 then
        return "" .. value
    else
        return "0" .. value
    end
end

function format_pos(value)
    local seconds = round(value)

    if seconds < 0 then
        seconds = 0
    end

    local pos_min_floor = math.floor(seconds / 60)
    local sec_rest = seconds - pos_min_floor * 60

    return pad_zero(pos_min_floor) .. ":" .. pad_zero(sec_rest)
end

function show_pos()
    local position = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")

    if position > duration then
        position = duration
    end

    if position ~= 0 then
        mp.osd_message(format_pos(position) .. " / " .. format_pos(duration))
    end
end

mp.register_script_message("show-position", function (mode)
    mp.add_timeout(0.05, show_pos)
end)

----- Print media info on screen

local media_info_cache = {}

function show_text(text, duration, font_size)
    mp.command('show-text "${osd-ass-cc/0}{\\\\fs' .. font_size ..
        '}${osd-ass-cc/1}' .. text .. '" ' .. duration)
end

function get_media_info()
    local path = mp.get_property("path")

    if media_info_cache[path] then
        return media_info_cache[path]
    end

    local media_info_format = [[General;N: %FileNameExtension%\\nG: %Format%, %FileSize/String%, %Duration/String%, %OverallBitRate/String%, %Recorded_Date%\\n
Video;V: %Format%, %Format_Profile%, %HDR_Format_Profile%%HDR_Format_Level%%HDR_Format_Settings%%HDR_Format_Compatibility%, %Width%x%Height%, %BitRate/String%, %FrameRate% FPS, %StreamSize/String%\\n
Audio;A: %Language/String%, %Format%, %Format_Profile%, %BitRate/String%, %Channel(s)% ch, %SamplingRate/String%, %Title%, %StreamSize/String%\\n
Text;S: %Language/String%, %Format%, %Format_Profile%, %Title%, %StreamSize/String%\\n]]

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

        output = string.gsub(output, " / ", ".", 1)
        output = string.gsub(output, " / ", ", ", 2)
        output = string.gsub(output, ", , ,", ",")
        output = string.gsub(output, ", ,", ",")
        output = string.gsub(output, ": , ", ": ")
        output = string.gsub(output, ", \\n\r*\n", "\\n")
        output = string.gsub(output, "\\n\r*\n", "\\n")
        output = string.gsub(output, ", \\n", "\\n")
        output = string.gsub(output, "%.000 FPS", " FPS")
        output = string.gsub(output, "MPEG Audio, Layer 3", "MP3")
        output = string.gsub(output, ", Blu%-ray / ", ", ")
        output = string.gsub(output, "HDR10 / HDR10", "HDR10")

        media_info_cache[path] = output

        return output
    end
end

mp.register_script_message("print-media-info", function ()
    show_text(get_media_info(), 5000, 16)
end)

----- Restart mpv

mp.register_script_message("restart-mpv", function ()
    local restart_args = {
        "mpv",
        "--pause=" .. mp.get_property("pause"),
        "--volume=" .. mp.get_property("volume"),
    }

    local playlist_pos = mp.get_property_number("playlist-pos")

    if playlist_pos > -1 then
        table.insert(restart_args, "--start=" .. mp.get_property("time-pos"))
        table.insert(restart_args, mp.get_property("path"))
    end

    mp.command_native({
        name = "subprocess",
        playback_only = false,
        detach = true,
        args = restart_args,
    })

    mp.command("quit")
end)
