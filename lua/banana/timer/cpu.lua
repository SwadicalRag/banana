local CPUTimer = namespace.Define("CPUTimer")

function CPUTimer:GetTime()
    if banana.isGMod then
        return SysTime()
    else
        return os.clock()
    end
end
