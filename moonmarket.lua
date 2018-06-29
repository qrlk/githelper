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
-------------------------------------MAIN---------------------------------------
function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  local path = getWorkingDirectory().."/scripts"
  for file in lfs.dir(path) do
    if lfs.attributes(file, "mode") == "file" then print("found file, "..file)
    elseif lfs.attributes(file, "mode") == "directory" then print("found dir, "..file, " containing:")
      for l in lfs.dir(path..file) do
        print("", l)
      end
    end
  end
end
