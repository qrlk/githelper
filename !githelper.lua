--Больше скриптов от автора можно найти в группе ВК: http://vk.com/qrlk.mods
--Больше скриптов от автора можно найти на сайте: http://www.rubbishman.ru/samp
--[[
Script that loads all .lua and .luac MoonLoader scripts from "scripts" folder and it's subfolders. Add "$" to subfolder name to ignore it.
Загружает все lua и luac скрипты из папки scripts и вложенных в неё. Добавьте в название папки $, чтобы игнорировать её.
]]

--------------------------------------------------------------------------------
-------------------------------------META---------------------------------------
--------------------------------------------------------------------------------
--script_name("moonmarket")
--script_description("Умный менеджер скриптов")
script_name("githelper")
script_description([[Загружает все lua и luac скрипты из папки scripts и вложенных в неё. Добавьте в название папки $, чтобы игнорировать её. Script that loads all .lua and .luac MoonLoader scripts from "scripts" folder and it's subfolders. Add "$" to subfolder name to ignore it.]])
script_author("qrlk")
script_version('1.0')
script_dependencies("lfs")
script_url("https://gitlab.com/qrlk/githelper.lua")
-----------------------------------CONFIG---------------------------------------
--Заменяет собой reload_all.lua. Ctrl+R - перезагрузить все скрипты.
reload_all = false
--Будет перезагружать скрипты из папки scripts при их изменении (полезно для dev).
--ML-AutoReload не всегда будет перезагружать скрипты из кастомной папки.
AutoReload = true
--Полностью заменяет ML-AutoReload
AutoReloadAll = false
--задержка AutoReload
autoreloaddelay = 500
-------------------------------------VAR----------------------------------------
--githelper
local lfs = require 'lfs'
prefix = ""
scriptlist = {}
autoreload = {}
--moonmarket
--[[
local imgui = require 'imgui'
local inspect = require 'inspect'
local key = require 'vkeys'
local selected = 1
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8
]]
-------------------------------------MAIN---------------------------------------
function main()
  if not isSampLoaded() then return end
  if reload_all then lua_thread.create(reload_all) end
  dir(getWorkingDirectory().."\\scripts\\")
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
  --[[if wasKeyPressed(key.VK_MENU) and wasKeyPressed(key.VK_M) then
      main_window_state.v = not main_window_state.v
    end
    imgui.Process = main_window_state.v]]
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
-------------------------------------IMGUI--------------------------------------
--[=====[
function apply_custom_style()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
  style.WindowRounding = 2.0
  style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
  style.ChildWindowRounding = 2.0
  style.FrameRounding = 2.0
  style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
  style.ScrollbarSize = 13.0
  style.ScrollbarRounding = 0
  style.GrabMinSize = 8.0
  style.GrabRounding = 1.0
  colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
  colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
  colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00)
  colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.ComboBg] = colors[clr.PopupBg]
  colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.16, 0.29, 0.48, 0.54)
  colors[clr.FrameBgHovered] = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.FrameBgActive] = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.TitleBg] = ImVec4(0.04, 0.04, 0.04, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.16, 0.29, 0.48, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
  colors[clr.CheckMark] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.24, 0.52, 0.88, 1.00)
  colors[clr.SliderGrabActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Button] = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.ButtonHovered] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
  colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Separator] = colors[clr.Border]
  colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
  colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
  colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 0.50)
  colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
  colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()
--main_window
local main_window_state = imgui.ImBool(false)
function imgui.OnDrawFrame()
  if main_window_state.v then
    imgui.SetNextWindowSize(imgui.ImVec2(500, 440))
    imgui.Begin("MoonMarket", main_window_state, imgui.WindowFlags.NoCollapse)
    imgui.BeginChild("left pane", imgui.ImVec2(150, 0), true)
    for i = 1, #script.list() do
      if imgui.Selectable(u8:encode(string.format("%s", script.list()[i]["filename"])), selected == i) then
        selected = i
      end
    end
    imgui.EndChild()
    imgui.SameLine()
    if script.list()[selected] ~= nil then
      imgui.BeginGroup()
      imgui.BeginChild("item view", imgui.ImVec2(0, - imgui.GetItemsLineHeightWithSpacing()))

      imgui.Text(string.format("%s", script.list()[selected]["name"]))
      imgui.Separator()
      imgui.TextWrapped(u8:encode(string.format([[
		Authors: %s
		Dead: %s
		Description: %s
		Directory: %s
		Filename: %s
		Frozen: %s
		Name: %s
		Path: %s
		Version: %s
		Version number: %s
		]],
        inspect(script.list()[selected]["authors"]),
        script.list()[selected]["dead"],
        script.list()[selected]["description"],
        script.list()[selected]["directory"],
        script.list()[selected]["filename"],
        script.list()[selected]["frozen"],
        script.list()[selected]["name"],
        script.list()[selected]["path"],
        script.list()[selected]["version"],
        script.list()[selected]["version_num"]
      )))
      imgui.EndChild()
      imgui.BeginChild("buttons")
      if imgui.Button("Unload") then
        script.list()[selected]:unload()
      end
      imgui.SameLine();
      if imgui.Button("Reload") then
        script.list()[selected]:reload()
      end
      imgui.SameLine();
      if imgui.Button("Load") then
        script.list()[selected]:load()
      end
      imgui.EndChild()
      imgui.EndGroup()
    end
    imgui.End()
  end
end
--]=====]
