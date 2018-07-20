--Больше скриптов от автора можно найти в группе ВК: http://vk.com/qrlk.mods
--Больше скриптов от автора можно найти на сайте: http://www.rubbishman.ru/samp
--------------------------------------------------------------------------------
-------------------------------------META---------------------------------------
--------------------------------------------------------------------------------
script_name("githelper")
script_description([[Загружает все lua и luac скрипты из папки scripts и вложенных в неё. Добавьте в название папки $, чтобы игнорировать её. Script that loads all .lua and .luac MoonLoader scripts from "scripts" folder and it's subfolders. Add "$" to subfolder name to ignore it.]])
script_author("qrlk")
script_version('1.2')
script_dependencies("lfs")
script_url("https://gitlab.com/qrlk/githelper.lua")
script_properties('work-in-pause')

require "lib.moonloader"
-----------------------------------CONFIG---------------------------------------
--Заменяет собой reload_all.lua. Ctrl+R - перезагрузить все скрипты.
reload_all = true
--Заменяет собой SF Integration
SF_integration = true
--Будет перезагружать скрипты из папки scripts при их изменении (полезно для dev).
--ML-AutoReload не всегда будет перезагружать скрипты из кастомной папки.
AutoReload = true
--Полностью заменяет ML-AutoReload
AutoReloadAll = true
--задержка AutoReload
autoreloaddelay = 1000
-------------------------------------VAR----------------------------------------
local lfs = require 'lfs'
prefix = ""
scriptlist = {}
autoreload = {}
if SF_integration then
  require "lib.sampfuncs"
  logDebugMessages = false
  COLOR_MSG = 0xC0C0C0
  COLOR_SCRIPTMSG = 0x7DD156
  COLOR_SENDER = 0xE0E0E0
end
-------------------------------------MAIN---------------------------------------
function main()
  if not isSampLoaded() then return end
  if reload_all then lua_thread.create(reload_all) end
  dir(getWorkingDirectory().."\\scripts\\")
  if SF_integration and isSampfuncsLoaded() then
    sampfuncsRegisterConsoleCommand("lua", do_lua)
    sampfuncsRegisterConsoleCommand(">>", do_lua)
  end
  for key, value in pairs(scriptlist) do
    print('Загружаю '..value)
    script.load(value)
    autoreload[key] = lfs.attributes(value, "modification")
  end
  if AutoReloadAll then
    for file in lfs.dir(getWorkingDirectory()) do
      if lfs.attributes(file, "mode") == "file" then
        if file:find(".lua", 1, true) or file:find(".luac", 1, true) then
          table.insert(scriptlist, lfs.currentdir().."\\"..file)
          autoreload[#scriptlist] = lfs.attributes(lfs.currentdir().."\\"..file, "modification")
        end
      end
    end
  end
  while true and AutoReload do
    wait(0)
    for key, value in pairs(scriptlist) do
      if lfs.attributes(value, "modification") ~= autoreload[key] then
        if not doesFileExist(value) then
          --print(scr.filename.." deleted. Unloading..")
        else
          local scr = find_script_by_path(value)
          if scr then
            print('Reloading '..scr.filename)
            wait(autoreloaddelay)
            scr:reload()
            autoreload[key] = lfs.attributes(value, "modification")
          else
            script.load(value)
          end
        end
      end
    end
  end
  wait(-1)
end
-----------------------------------HELPERS--------------------------------------
function dir(path)
  lfs.chdir(path)
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." then
      if lfs.attributes(file, "mode") == "file" then
        --print(prefix..file)
        if file:find(".lua", 1, true) or file:find(".luac", 1, true) then
          table.insert(scriptlist, lfs.currentdir().."\\"..file)
        end
      elseif lfs.attributes(file, "mode") == "directory" and file:find('$', 1, true) == nil then
        --print(prefix..file, " containing:")
        prefix = prefix.."    "
        dir(lfs.currentdir().."\\"..file)
      end
    end
  end
  lfs.chdir("..")
  prefix = string.sub(prefix, 1, string.len(prefix) - 4)
end
function find_script_by_path(path)
  for _, s in ipairs(script.list()) do
    if s.path == path then
      return s
    end
  end
  return nil
end
function reload_all()
  while true do
    wait(40)
    if isKeyDown(17) and isKeyDown(82) then -- CTRL+R
      while isKeyDown(17) and isKeyDown(82) do wait(80) end
      reloadScripts()
    end
  end
end
---------------------------------SF INTEGRATION---------------------------------
--author: fyp
function log_message(msg, tagtext, tagcolor, sender)
  local str = string.format("{%06X}[ML] ", COLOR_MSG)
  if tagtext then
    str = str .. string.format("{%06X}(%s) ", tagcolor, tagtext)
  end
  if sender then
    str = str .. string.format("{%06X}%s: ", COLOR_SENDER, sender.name)
  end
  sampfuncsLog(string.format("%s{%06X}%s", str, COLOR_MSG, msg))
end


--- Callbacks
function do_lua(code)
  if code:sub(1, 1) == '=' then
    code = "print(" .. code:sub(2, - 1) .. ")"
  end
  local func, err = load(code)
  if func then
    local result, err = pcall(func)
    if not result then
      onSystemMessage(err, TAG.TYPE_ERROR, thisScript())
    end
  else
    onSystemMessage(err, TAG.TYPE_ERROR, thisScript())
  end
end


--- Events
function onSystemMessage(msg, type, sender)
  if SF_integration and isSampfuncsLoaded() and isOpcodesAvailable() and (type ~= TAG.TYPE_DEBUG or logDebugMessages) then
    local tagtxt = get_tag_text(type)
    local tagclr = get_tag_color(type) or COLOR_MSG
    log_message(msg, tagtxt, tagclr, sender)
  end
end

function onScriptMessage(msg, sender)
  if SF_integration and isSampfuncsLoaded() and isOpcodesAvailable() then
    log_message(msg, "script", COLOR_SCRIPTMSG, sender)
  end
end


--- Functions
local tags = {
  [TAG.TYPE_INFO] = {"info", 0xA9EFF5},
  [TAG.TYPE_DEBUG] = {"debug", 0xAFA9F5},
  [TAG.TYPE_ERROR] = {"error", 0xFF7070},
  [TAG.TYPE_WARN] = {"warn", 0xF5C28E},
  [TAG.TYPE_SYSTEM] = {"system", 0xFA9746},
  [TAG.TYPE_FATAL] = {"fatal", 0x040404},
  [TAG.TYPE_EXCEPTION] = {"exception", 0xF5A9A9}
}

function get_tag_text(n)
  local tag = tags[n]
  return tag ~= nil and tag[1] or nil
end

function get_tag_color(n)
  local tag = tags[n]
  return tag ~= nil and tag[2] or nil
end
