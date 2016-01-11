local Logger = namespace.Define("Logger"):Extends("OutputWriter")

Logger.TAG = "LoggerBase"
Logger.CPUTimer = namespace.New "CPUTimer"
Logger.StartTime = Logger.CPUTimer:GetTime()

function Logger:SetTag(tag)
    self.TAG = tag
end

function Logger:GetTimeDelta()
    return self.CPUTimer:GetTime() - self.StartTime
end

function Logger:Log(...)
    self:Write("[")
    self:Write(self.TAG)
    self:Write("] ")
    self:Write("[OUT] ")
    self:WriteFormat("[T+%02.03fs] ",self:GetTimeDelta())
    self:WriteN(...)
end

function Logger:LogDebug(...)
    self:Write("[")
    self:Write(self.TAG)
    self:Write("] ")
    self:Write("[DBG] ")
    self:WriteFormat("[%02.03f] ",self:GetTimeDelta())
    self:WriteN(...)
end

function Logger:LogError(...)
    self:Write("[")
    self:Write(self.TAG)
    self:Write("] ")
    self:Write("[ERR] ")
    self:WriteFormat("[%02.03f] ",self:GetTimeDelta())
    self:WriteN(...)
end

function Logger:__tostring()
    return ("Logger [%s]"):format(self.TAG)
end
