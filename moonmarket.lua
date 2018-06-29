--Больше скриптов от автора можно найти на сайте: http://www.rubbishman.ru/samp
--------------------------------------------------------------------------------
-------------------------------------META---------------------------------------
--------------------------------------------------------------------------------
script_author("rubbishman")
script_dependencies()
script_description("Умный менеджер скриптов")
script_moonloader()
script_name("moonmarket")
script_properties()
script_url()
script_version('dev')
script_properties()
-------------------------------------VAR----------------------------------------
local imgui = require 'imgui'
local key = require 'vkeys'
local selected = 1
local encoding = require 'encoding' -- загружаем библиотеку
encoding.default = 'CP1251' -- указываем кодировку по умолчанию, она должна совпадать с кодировкой файла. CP1251 - это Windows-1251
u8 = encoding.UTF8 -- и создаём короткий псевдоним для кодировщика UTF-8
local lfs = require 'lfs'
local inspect = require 'inspect'
prefix = ""
scriptlist = {}
autoreload = {}
autoreloaddelay = 500
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
      elseif lfs.attributes(file, "mode") == "directory" and file:find('net') == nil then
        --print(prefix..file, " containing:")
        --prefix = prefix.."    "
        dir(lfs.currentdir().."\\"..file)
      end
    end
  end
  lfs.chdir("..")
  --prefix = string.sub(prefix, 1, string.len(prefix)-4)
end
-------------------------------------IMGUI--------------------------------------
--style
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
    if wasKeyPressed(key.VK_MENU) and wasKeyPressed(key.VK_M) then
      main_window_state.v = not main_window_state.v
    end
    imgui.Process = main_window_state.v
  end
  --перезапуск скриптов работает криво, исправить!
  --[[while true do
    wait(0)
    for key, value in pairs(scriptlist) do
      if lfs.attributes(value, "modification") ~= autoreload[key] then
				local scr = find_script_by_path(value)
				--print('Reloading {346cb2}'..scr.name)
				wait(autoreloaddelay)
        scr:reload()
        autoreload[key] = lfs.attributes(value, "modification")
      end
    end
  end]]
end
