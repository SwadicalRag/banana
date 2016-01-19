local self = banana.Define("StringArithmeticParser")

function self:CheckForMultiplicationAndDivision(str)
    return str:match("([%d%.]+)%s*([%*%/])%s*([%d%.]+)") and true
end

function self:HandleMultiplicationAndDivision(str)
    str = str:gsub("([%d%.]+)%s*([%*%/])%s*([%d%.]+)",function(n1,op,n2)
        if op == "*" then
            return tonumber(n1) * tonumber(n2)
        else
            return tonumber(n1) / tonumber(n2)
        end
    end)

    return str
end

function self:CheckForAdditionAndSubtraction(str)
    return str:match("([%d%.]+)%s*([%+%-])%s*([%d%.]+)") and true
end

function self:HandleAdditionAndSubtraction(str)
    str = str:gsub("([%d%.]+)%s*([%+%-])%s*([%d%.]+)",function(n1,op,n2)
        if op == "+" then
            return tonumber(n1) + tonumber(n2)
        else
            return tonumber(n1) - tonumber(n2)
        end
    end)

    return str
end

function self:Evaluate(str)
    if tonumber(str) then return tonumber(str) end
    if not str:match("^[%s%d%-%+%*%/]+$") then error("Cannot parse "..str) end

    repeat
        str = self:HandleMultiplicationAndDivision(str)
    until not self:CheckForMultiplicationAndDivision(str)

    repeat
        str = self:HandleAdditionAndSubtraction(str)
    until not self:CheckForAdditionAndSubtraction(str)

    return tonumber(str)
end
