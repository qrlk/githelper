# githelper
A **[moonloader](https://gtaforums.com/topic/890987-moonloader/)** script that loads all your scripts from the 'moonloader/scripts' folder and its subfolders, allowing you to work with git repositories.

To avoid loading from a folder, add the '$' symbol to its name.

![](https://i.imgur.com/nch6Bp8.png)

**Deps:** [CLEO 4+](http://cleo.li/?lang=ru), [SAMPFUNCS 5+](https://blast.hk/threads/17/), [LuaFileSystem](https://blast.hk/threads/16031/).

## Configuration
The script can be configured to replace classic developer scripts.

```lua
-- Replaces reload_all. lua. Ctrl+R-reload all scripts.
reload_all = false
-- Replaces SF Integration
SF_integration = false
-- Will reload scripts from the scripts folder when they are changed (useful for dev).
-- ML-AutoReload will not always reload scripts from a custom folder.
AutoReload = true
-- Completely replaces ML-AutoReload
AutoReloadAll = false
-- delay AutoReload
autoreloaddelay = 1000
```
