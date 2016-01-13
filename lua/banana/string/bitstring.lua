local BitString = banana.Define("BitString")

function BitString:__ctor()
    self.bits = {}
    self.bitCount = 1
end

function BitString:toBitsEx(num,padding)
    local out = {}
    for bit=padding,1,-1 do
        out[bit] = math.fmod(num,2)
        num = (num - out[bit])/2
    end

    return out
end

function BitString:toBits(num)
    local out = {}
    for bit=8,1,-1 do
        out[bit] = math.fmod(num,2)
        num = (num - out[bit])/2
    end

    return out
end

function BitString:toDecimal(n1,n2,n3,n4,n5,n6,n7,n8)
    return n8 + n7*2 + n6*4 + n5*8 + n4*16 + n3*32 + n2*64 + n1*128
    --return n1 + n2*2 + n3*4 + n4*8 + n5*16 + n6*32 + n7*64 + n8*128
end

function BitString:AppendBit(bit)
    self.bits[self.bitCount] = bit
    self.bitCount = self.bitCount + 1
end

function BitString:AppendChars(str)
    for i=1,#str do
        local byte = str:byte(i)

        local bits = self:toBits(byte)

        for i2=1,8 do
            self:AppendBit(bits[i2])
        end
    end
end

function BitString:AppendChar(char)
    local byte = char:byte()

    local bits = self:toBits(byte)

    for i2=1,8 do
        self:AppendBit(bits[i2])
    end
end

function BitString:AppendCharCode(byte)
    local bits = self:toBits(byte)

    for i2=1,8 do
        self:AppendBit(bits[i2])
    end
end

function BitString:__concat(str)
    local newString = banana.Clone(self)

    newString:AppendChars(str)

    return newString
end

function BitString:BitAt(i)
    return self.bits[i]
end

function BitString:CharAt(i)
    i = math.min(self.bitCount,math.max(1,i * 8))
    return string.char(self:toDecimal(
        self.bits[i] or 0,
        self.bits[i+1] or 0,
        self.bits[i+2] or 0,
        self.bits[i+3] or 0,
        self.bits[i+4] or 0,
        self.bits[i+5] or 0,
        self.bits[i+6] or 0,
        self.bits[i+7] or 0
    ))
end

function BitString:ToString()
    local out = ""
    for i=1,self.bitCount,8 do
        out = out..string.char(self:toDecimal(
            self.bits[i] or 0,
            self.bits[i+1] or 0,
            self.bits[i+2] or 0,
            self.bits[i+3] or 0,
            self.bits[i+4] or 0,
            self.bits[i+5] or 0,
            self.bits[i+6] or 0,
            self.bits[i+7] or 0
        ))
    end
    return out
end

BitString.__tostring = BitString.ToString
