local function include(name)
    if bFS then
        bFS:RunFile(name)
    else
        _G.include(name:sub(2,-1))
    end
end

-- STAGE 1
include("/banana/banana.lua")
banana.isGMod = gmod and true

include("/banana/timer/cpu.lua")
include("/banana/io/outputwriter.lua")
include("/banana/io/logger.lua")
include("/banana/lua/loader.lua")

banana.Logger = banana.New("Logger")
banana.Logger:SetTag("banana")

banana.Logger:Log("Initialising...")

banana.Loader = banana.New("Loader")
banana.Loader:SetTag("bananaLoader")

banana.Loader:SetLoaded("/banana/banana.lua",true)
banana.Loader:SetLoaded("/banana/init.lua",true)
banana.Loader:SetLoaded("/banana/timer/cpu.lua",true)
banana.Loader:SetLoaded("/banana/io/outputwriter.lua",true)
banana.Loader:SetLoaded("/banana/io/logger.lua",true)
banana.Loader:SetLoaded("/banana/lua/loader.lua",true)
banana.Loader:LoadFolderRecursive("/banana/")

banana.Logger:Log("banana has successfully been planted!")

banana.Loader:LoadFolder("/autobanana/")
banana.Loader:LoadFolder("/autobanana/shared/")
if SERVER then
    banana.Loader:LoadFolder("/autobanana/server/",true)
else
    banana.Loader:LoadFolder("/autobanana/client/")
end
banana.Logger:Log("autobanana load complete!")
