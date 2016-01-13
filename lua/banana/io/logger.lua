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

function Logger:Log(...)
    self:WriteColor(self.colors.green,"[")
    self:WriteColor(self.colors.green,self.TAG)
    self:WriteColor(self.colors.green,"] ")
    self:WriteColor(self.colors.green,"[OUT] ")
    self:WriteColorFormat(self.colors.green,"[T+%02.03fs] ",self:GetTimeDelta())
    self:WriteColorN(self.colors.white,...)
end

function Logger:LogDebug(...)
    self:WriteColor(self.colors.yellow,"[")
    self:WriteColor(self.colors.yellow,self.TAG)
    self:WriteColor(self.colors.yellow,"] ")
    self:WriteColor(self.colors.yellow,"[DBG] ")
    self:WriteColorFormat(self.colors.yellow,"[%02.03f] ",self:GetTimeDelta())
    self:WriteColorN(self.colors.white,...)
end

function Logger:LogError(...)
    self:WriteColor(self.colors.red,"[")
    self:WriteColor(self.colors.red,self.TAG)
    self:WriteColor(self.colors.red,"] ")
    self:WriteColor(self.colors.red,"[ERR] ")
    self:WriteColorFormat(self.colors.red,"[%02.03f] ",self:GetTimeDelta())
    self:WriteColorN(self.colors.white,...)
end

function Logger:__tostring()
    return ("Logger [%s]"):format(self.TAG)
end
