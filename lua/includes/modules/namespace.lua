if not setfenv then
    function setfenv(_,env)
        _ENV = env
    end
end

if not module then
    function module(name,seeall)
        local moduleTbl = {}
        local _G = _G
        _G[name] = moduleTbl

        setfenv(1,setmetatable({},{
            __newindex = function(self,k,v)
                moduleTbl[k] = v
            end,
            __index = function(self,k)
                if seeall then
                    return _G[k] or moduleTbl[k]
                else
                    return moduleTbl[k]
                end
            end
        }))

        return moduleTbl
    end
end

local type = type
local pairs = pairs
local assert = assert
local tostring = tostring
local getmetatable = getmetatable
local setmetatable = setmetatable

module("namespace")

Classes = {}

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

function Define(name)
    local class = setmetatable({},{
        __tostring = function(self)
            return "Base Class "..name
        end
    })

    Classes[name] = class

    function class:Extends(extends)
        local from = copy(Classes[extends] or {})

        for k,v in pairs(from) do
            self[k] = v
        end

        return class
    end

    return class
end

function New(name)
    assert(Classes[name],"Class "..tostring(name).." does not exist!")
    local instance = copy(Classes[name])

    setmetatable(instance,{
        __tostring = function(self)
            if self.__tostring then
                return self:__tostring()
            else
                return "Class Instance "..name
            end
        end
    })

    return instance
end
