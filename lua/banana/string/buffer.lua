local StringBuffer = banana.Define("StringBuffer")

function StringBuffer:__ctor()
    self.position = 0
    self.string = banana.New("BitString")
end

function StringBuffer:GetString()
    return self.string
end

function StringBuffer:incrementPosition(n)
    self.position = self.position + 1
end

function StringBuffer:ReadUInt8()
    return self.string:CharAt(self.position),self:incrementPosition(1)
end

function StringBuffer:WriteUInt8(uint8)
    self.string = self.string:AppendCharCode(uint8)
    self:incrementPosition(1)
end
