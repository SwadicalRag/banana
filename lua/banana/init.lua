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

banana.Logger = banana.New "Logger"
banana.Logger:SetTag("banana")

banana.Logger:Log("Initialising...")
