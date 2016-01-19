local type = type
local pairs = pairs
local assert = assert
local tostring = tostring
local getmetatable = getmetatable
local setmetatable = setmetatable

banana = {}

banana.Classes = {}

local function copy(source,lookup)
    lookup = lookup or {}
    if type(source) ~= "table" then return source end
    if lookup[source] then return lookup[source] end
    local target = {}
    lookup[source] = target

    setmetatable(target,copy(getmetatable(source)) or {})

    for key,value in pairs(source) do
        target[copy(key,lookup)] = copy(value,lookup)
    end

    return target
end

function banana.Define(name)
    local class = setmetatable({},{
        __tostring = function(self)
            return "Base Class "..name
        end
    })

    banana.Classes[name] = class

    function class:Extends(extends)
        local from = copy(banana.Classes[extends] or {})

        for k,v in pairs(from) do
            self[k] = v
        end

        return class
    end

    return class
end

function banana.New(name)
    assert(banana.Classes[name],"Class "..tostring(name).." does not exist!")
    local instance = copy(banana.Classes[name])

    setmetatable(instance,{
        __tostring = function(self)
            if self.__tostring then
                return self:__tostring()
            else
                return "Class Instance "..name
            end
        end,
        __gc = instance.__gc,
        __concat = instance.__concat
    })

    if instance.__ctor then instance:__ctor() end

    return instance
end

function banana.Peel()
    local peel = copy(banana)
    peel.Classes = {}
    return peel
end

banana.Clone = copy

return banana
