local OutputWriter = banana.Define("OutputWriter")

function OutputWriter:Write(...)
    if banana.isGMod then
        Msg(table.concat({...},"\t"))
    else
        io.write(table.concat({...},"\t"))
    end
end

function OutputWriter:WriteFormat(str,...)
    self:Write(str:format(...))
end

function OutputWriter:WriteColorFormat(col,str,...)
    self:WriteColor(col,str:format(...))
end

function OutputWriter:WriteColor(col,...)
    if banana.isGMod then
        MsgC(col,table.concat({...},"\t"))
    else
        self:Write(...)
    end
end

function OutputWriter:WriteColorN(...)
    self:WriteColor(...)
    self:Write("\n")
end

function OutputWriter:WriteN(...)
    self:Write(...)
    self:Write("\n")
end
