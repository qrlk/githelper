--Больше скриптов от автора можно найти на сайте: http://www.rubbishman.ru/samp
--------------------------------------------------------------------------------
-------------------------------------META---------------------------------------
--------------------------------------------------------------------------------
script_name("moonmarket")
script_version("0")
script_author("rubbishman")
script_description("")
-------------------------------------VAR----------------------------------------
local lfs = require 'lfs'
-------------------------------------MAIN---------------------------------------
function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
	local path = getWorkingDirectory()
  for file in lfs.dir(path.."\\scripts") do
    if lfs.attributes(file, "mode") == "file" then print("found file, "..file)
    elseif lfs.attributes(file, "mode") == "directory" then print("found dir, "..file, " containing:")
    end
  end
  while true do
    wait(0)
  end
end
