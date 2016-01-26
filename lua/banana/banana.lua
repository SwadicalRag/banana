local type = type
local pairs = pairs
local assert = assert
local tostring = tostring
local getmetatable = getmetatable
local setmetatable = setmetatable

local banana = {}
local BANANA_NAMESPACE,BANANA_CLASS = 0,1

banana.Protected = {
    Extends = true,
    GetName = true
}

local function copy(source,lookup)
    lookup = lookup or {}
    if type(source) ~= "table" then return source end
    if lookup[source] then return lookup[source] end
    local target = {}
    lookup[source] = target

    for key,value in pairs(source) do
        target[copy(key,lookup)] = copy(value,lookup)
    end

    setmetatable(target,copy(getmetatable(source)) or {})

    return target
end

function banana.__new(enum)
    return setmetatable({},{
        __banana = enum
    })
end

banana.RootNamespace = banana.__new(BANANA_NAMESPACE)

function banana.resolveNamespace(name)
    assert(string.match(name,"[A-Za-z0-9:]+"),"Class names must be alphanumeric!")
    local namespace = banana.RootNamespace

    for chunk,sep in string.gmatch(name,"([A-Za-z0-9]+)(:+)") do
        if sep and sep ~= "::" then error("Bad namespace separation convention "..sep) end
        namespace[chunk] = namespace[chunk] or banana.__new(BANANA_NAMESPACE)
        if not banana.is(namespace[chunk],BANANA_NAMESPACE) then error("Namespace "..name.." passes through a class!") end
        namespace = namespace[chunk]
    end

    return namespace,string.match(name,"([A-Za-z0-9]+)$")
end

function banana.resolveNamespaceEx(name)
    assert(string.match(name,"[A-Za-z0-9:]+"),"Class names must be alphanumeric!")
    local namespace = banana.RootNamespace

    for chunk,sep in string.gmatch(name,"([A-Za-z0-9]+)(:*)") do
        if sep and sep ~= "::" and sep ~= "" then break end
        namespace[chunk] = namespace[chunk] or banana.__new(BANANA_NAMESPACE)
        if not banana.is(namespace[chunk],BANANA_NAMESPACE) then error("Namespace "..name.." passes through a class!") end
        namespace = namespace[chunk]
    end

    return namespace
end

function banana.Define(fullname)
    local classMeta = {}
    classMeta.__banana = BANANA_CLASS

    function classMeta:__tostring()
        return "Base Class "..fullname
    end
    classMeta.__extends = {}
    function classMeta:__index(k)
        for _,parentClass in ipairs(classMeta.__extends) do
            if parentClass[k] then return parentClass[k] end
        end
    end

    local space,name = banana.resolveNamespace(name)

    local class = setmetatable({},classMeta)
    space[name] = class

    function class:GetName()
        return fullname
    end

    function class:Extends(extends)
        local extNamespace,name = banana.resolveNamespace(extends)
        if extNamespace[name] then
            classMeta.__extends[#classMeta.__extends+1] = extNamespace[name]
        else
            error("Unknown class "..extends)
        end

        return class
    end

    function classMeta:__newindex(k,v)
        assert(banana.Protected[k],"Cannot modify protected member '"..k.."'")
        rawset(self,k,v)
    end

    return class
end

function banana.New(name)
    assert(space[name],"Class "..tostring(name).." does not exist!")
    local instance = copy(space[name])

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

function banana.PrintNamespace(namespace,depth,prepend,ntype)
    depth = depth or -1
    prepend = prepend or ""
    local space = (type(namespace) == "string") and banana.resolveNamespaceEx(namespace) or namespace
    local indent = ("    "):rep(depth)

    ntype = ntype or "Namespace"

    print(indent.."== "..ntype.." "..(((type(namespace) == "string") and namespace) or prepend:sub(1,-3)).." ==")
    depth = depth + 1

    indent = ("    "):rep(depth)
    for k,v in pairs(space) do
        if type(v) == "table" then
            if banana.__is(BANANA_CLASS) then
                banana.PrintNamespace(v,depth + 1,k.."::","Class")
            elseif banana.__is(BANANA_NAMESPACE) then
                banana.PrintNamespace(v,depth + 1,k.."::","Namespace")
            end
        elseif type(v) == "function" then
            print(indent..prepend..k.." -> Method")
        end
    end
end

banana.Clone = copy

return banana
