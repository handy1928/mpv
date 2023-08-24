
--[[

    Show media info on screen
    -------------------------
    Prints detailed media info on the screen.
    
    Depends on the CLI tool 'mediainfo':
    https://mediaarea.net/en/MediaInfo/Download

    In input.conf add:
    i script-message-to misc print-media-info

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
        return input:match "^[%s,,]*(.-)[%s,,]*$"
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


----- Print media info on screen

local media_info_cache = {}

function get_media_info()
    local path = mp.get_property("path")

    if media_info_cache[path] then
        return media_info_cache[path]
    end

    local media_info_format = [[General;N: %FileNameExtension%\\nG: %Format%, %FileSize/String%, %Duration/String%, %OverallBitRate/String%\\n
Video;V: ~%Format%~, ~%Format_Profile%~, ~%HDR_Format_Profile%%HDR_Format_Level%%HDR_Format_Settings%%HDR_Format_Compatibility%~, ~%Width%x%Height%~, ~%BitRate/String%~, ~%FrameRate% FPS~, ~%StreamSize/String%~, ~%ScanType/String%~, ~%ScanOrder/String%~\\n
Audio;A: ~%Language/String%~, ~%Format%~, ~%Format_Profile%~, ~%BitRate/String%~, ~%Channel(s)% Channels~, ~%SamplingRate/String%~, ~%Title%~, ~%StreamSize/String%~\\n
Text;S: ~%Language/String%~, ~%Format%~, ~%Format_Profile%~, ~%Title%~, ~%StreamSize/String%~\\n]]

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
        output = string.gsub(output, ": , ", ": ")
        output = string.gsub(output, ", \\n\r*\n", "\\n")
        output = string.gsub(output, "\\n\r*\n", "\\n")
        output = string.gsub(output, ", \\n", "\\n")
        output = string.gsub(output, "%.000 FPS", " FPS")
        output = string.gsub(output, "MPEG Audio, Layer 3", "MP3")
        output = string.gsub(output, ", Blu%-ray / ", ", ")
        output = string.gsub(output, "HDR10 / HDR10", "HDR10")
        output = string.gsub(output, "Progressive", "")

        media_info_cache[path] = output

        return output
    end
end

function formatMediainfoStringIndexNumber(inputstr, index)
    endIndex = -1
    for i = index, 1, -1 do
        startIndex = string.find(inputstr, '~', endIndex + 1)
        endIndex = string.find(inputstr, '~', startIndex + 1)
    end

    return string.sub(inputstr, startIndex + 1, endIndex - 1)
end
