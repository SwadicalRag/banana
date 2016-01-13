local Logger = banana.Define("Logger"):Extends("OutputWriter")

function Logger:__ctor()
    self.TAG = "LoggerBase"
    self.CPUTimer = banana.New "CPUTimer"
    self.StartTime = self.CPUTimer:GetTime()

    self.colors = {
        red = Color and Color(255,0,0),
        green = Color and Color(0,255,0),
        blue = Color and Color(0,0,255),
        yellow = Color and Color(0,255,255),
        white = Color and Color(255,255,255)
    }
end

function Logger:SetTag(tag)
    self.TAG = tag
end

function Logger:GetTimeDelta()
    return self.CPUTimer:GetTime() - self.StartTime
end

function Logger:WriteTag(col)
    self:WriteColor(col,"[")
    self:WriteColor(col,self.TAG)
    self:WriteColor(col,"] ")
end

function Logger:WriteTimeStamp(col)
    self:WriteColorFormat(col,"[T+%02.03fs] ",self:GetTimeDelta())
end

function Logger:Log(...)
    self:WriteTag(self.colors.green)
    self:WriteColor(self.colors.green,"[OUT] ")
    self:WriteTimeStamp(self.colors.green)
    self:WriteColorN(self.colors.white,...)
end

function Logger:LogDebug(...)
    self:WriteTag(self.colors.yellow)
    self:WriteColor(self.colors.yellow,"[DBG] ")
    self:WriteTimeStamp(self.colors.yellow)
    self:WriteColorN(self.colors.white,...)
end

function Logger:LogError(...)
    self:WriteTag(self.colors.red)
    self:WriteColor(self.colors.red,"[ERR] ")
    self:WriteTimeStamp(self.colors.red)
    self:WriteColorN(self.colors.white,...)
end

function Logger:__tostring()
    return ("Logger [%s]"):format(self.TAG)
end
