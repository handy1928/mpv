-- chapterskip.lua
--
-- Ain't Nobody Got Time for That
--
-- This script skips chapters based on their title.

local categories = {
    openings = '^[Oo][Pp]$/^[Oo][Pp] / [Oo][Pp]$/ [Oo][Pp] /^[Oo]pening$/^[Oo]pening / [Oo]pening$/ [Oo]pening ',
    intros = '^[Ii]ntro$/^[Ii]ntro / [Ii]ntro$/ [Ii]ntro /^[Aa]vant$/^[Aa]vant / [Aa]vant$/ [Aa]vant /^[Pp]rologue$/^[Pp]rologue / [Pp]rologue$/ [Pp]rologue ',
    endings = '^[Ee][Dd]$/^[Ee][Dd] / [Ee][Dd]$/ [Ee][Dd] /^[Ee]nding$/^[Ee]nding / [Ee]nding$/ [Ee]nding ',
    outros = '^[Oo]utro$/^[Oo]utro / [Oo]utro$/ [Oo]utro /^[Ee]pilogue$/^[Ee]pilogue / [Ee]pilogue$/ [Ee]pilogue ',
    preview = '^[Cc]redit$/^[Cc]redit / [Cc]redit$/ [Cc]redit /^[Cc]redits$/^[Cc]redits / [Cc]redits$/ [Cc]redits /^[Cc]losing$/^[Cc]losing / [Cc]losing$/ [Cc]losing /^[Pp][Vv]$/^[Pp][Vv] / [Pp][Vv]$/ [Pp][Vv] /^[Pp]review$/^[Pp]review / [Pp]review$/ [Pp]review ',
    skip = '^[Ss]kip$/^[Ss]kip / [Ss]kip$/ [Ss]kip ',
    recap = '^[Rr]ecap$/^[Rr]ecap / [Rr]ecap$/ [Rr]ecap ',
}

local options = {
    enabled = true,
    skip_once = true,
    categories = "",
    skip = "skip"
}


function matches(i, title)
    for category in string.gmatch(options.skip, " *([^;]*[^; ]) *") do
        if categories[category:lower()] then
            if string.find(category:lower(), "^idx%-") == nil then
                if title then
                    for pattern in string.gmatch(categories[category:lower()], "([^/]+)") do
                        if string.match(title, pattern) then
                            return true
                        end
                    end
                end
            else
                for pattern in string.gmatch(categories[category:lower()], "([^/]+)") do
                    if tonumber(pattern) == i then
                        return true
                    end
                end
            end
        end
    end
end

local skipped = {}
local parsed = {}

function chapterskip(_, current)
    if not options.enabled then return end
    for category in string.gmatch(options.categories, "([^;]+)") do
        name, patterns = string.match(category, " *([^+>]*[^+> ]) *[+>](.*)")
        if name then
            categories[name:lower()] = patterns
        elseif not parsed[category] then
            mp.msg.warn("Improper category definition: " .. category)
        end
        parsed[category] = true
    end
    local chapters = mp.get_property_native("chapter-list")
    local skip = false
    for i, chapter in ipairs(chapters) do
        if (not options.skip_once or not skipped[i]) and matches(i, chapter.title) then
            if i == current + 1 or skip == i - 1 then
                if skip then
                    skipped[skip] = true
                end
                skip = i
            end
        elseif skip then
            mp.set_property("time-pos", chapter.time)
            skipped[skip] = true
            mp.osd_message("Skipped Chapter: "..chapters[skip].title,2)
            return
        end
    end
    if skip then
        if mp.get_property_native("playlist-count") == mp.get_property_native("playlist-pos-1") then
            return mp.set_property("time-pos", mp.get_property_native("duration"))
        end
        mp.commandv("playlist-next")
    end
end


function chapterskip_clear_categories()
    options.skip = ""
    mp.osd_message("Cleared Chapter Skip Categories")
end

function chapterskip_add_categorie(categorie)
    options.skip = options.skip..";"..categorie
    mp.osd_message("Added \""..categorie.."\" to Chapter Skip Categories")
end

function chapterskip_skip_once()
    if options.skip_once then
        mp.osd_message("Chapters in Categories will always be skipped")
    else
        mp.osd_message("Chapters in Categories will only be skipped once")
    end
    options.skip_once = not options.skip_once
end

mp.observe_property("chapter", "number", chapterskip)
mp.register_event("file-loaded", function() skipped = {} end)
mp.register_script_message("chapterskip-clear-categories", chapterskip_clear_categories)
mp.register_script_message("chapterskip-add-categorie", chapterskip_add_categorie)
mp.register_script_message("chapterskip-skip-once", chapterskip_skip_once)