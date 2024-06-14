msg = require 'mp.msg'
utils = require 'mp.utils'
require 'mp.options'

local python = "C:\\Python312\\python.exe"
local csscript = "C:\\PortablePrograms\\StartMenu\\mpv\\portable_config\\scripts\\keypress.py"

function cs_cmd(cmd)
    local command = {
        python, csscript, cmd
    }
    
    local process = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        args = command,
        capture_stdout = true,
        capture_stderr = true,
    })
    msg.error(cmd)          
end


function next_episode()
    cs_cmd("next_episode")
end

function previous_episode()
    cs_cmd("previous_episode")
end

mp.add_key_binding(nil, "next_episode", next_episode)
mp.add_key_binding(nil, "previous_episode", previous_episode)
