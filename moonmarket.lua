--Больше скриптов от автора можно найти на сайте: http://www.rubbishman.ru/samp
--------------------------------------------------------------------------------
-------------------------------------META---------------------------------------
--------------------------------------------------------------------------------
script_name("moonmarket")
script_version("0")
script_author("rubbishman")
script_description("Загружает скрипты из папки scripts")
-------------------------------------VAR----------------------------------------
local lfs = require 'lfs'
local inspect = require 'inspect'
prefix = ""
scriptlist = {}
autoreload = {}
-------------------------------------MAIN---------------------------------------
function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  dir(getWorkingDirectory().."\\scripts\\")
  for key, value in pairs(scriptlist) do
    print('Загружаю '..value)
    script.load(value)
    autoreload[key] = lfs.attributes(value, "modification")
  end
  while true do
    wait(0)
    for key, value in pairs(scriptlist) do
      if lfs.attributes(value, "modification") ~= autoreload[key] then
				local scr = find_script_by_path(value)
				print('Reloading {346cb2}'..scr.name)
        scr:reload()
        autoreload[key] = lfs.attributes(value, "modification")
      end
    end
  end
end
-----------------------------------HELPERS--------------------------------------
--эта функция исследует папку и все вложенные в неё папки, достаёт пути к скриптам lua и luac и заносит в таблицу scriptlist
function dir(path)
  lfs.chdir(path)
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".."then
      if lfs.attributes(file, "mode") == "file" then
        --print(prefix..file)
        if file:find(".lua", 1, true) or file:find(".luac", 1, true) then
          table.insert(scriptlist, lfs.currentdir().."\\"..file)
        end
      elseif lfs.attributes(file, "mode") == "directory" then
        --print(prefix..file, " containing:")
        --prefix = prefix.."    "
        dir(lfs.currentdir().."\\"..file)
      end
    end
  end
  lfs.chdir("..")
  --prefix = string.sub(prefix, 1, string.len(prefix)-4)
end
--ищём скрипт по пути, источник: AutoReboot.lua FYP'a
function find_script_by_path(path)
  for _, s in ipairs(script.list()) do
    if s.path == path then
      return s
    end
  end
  return nil
end
