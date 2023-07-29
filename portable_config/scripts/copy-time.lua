-- copy-time (Windows version)

-- Copies current timecode in HH:MM:SS.MS format to clipboard

-------------------------------------------------------------------------------
-- Script adapted by Alex Rogers (https://github.com/linguisticmind)
-- Modified from https://github.com/Arieleg/mpv-copyTime
-- Released under GNU GPL 3.0

require "mp"

function copy_time()
  local time_pos = mp.get_property_number("time-pos")
  local time_in_seconds = time_pos
  local time_seg = time_pos % 60
  time_pos = time_pos - time_seg
  local time_hours = math.floor(time_pos / 3600)
  time_pos = time_pos - (time_hours * 3600)
  local time_minutes = time_pos/60
  time_seg,time_ms=string.format("%.03f", time_seg):match"([^.]*).(.*)"
  time = string.format("%02d:%02d:%02d.%s", time_hours, time_minutes, time_seg, time_ms)
  mp.commandv("script-message", "set-clipboard", time)
end


mp.add_key_binding("Ctrl+c", "copy-time", copy_time)
