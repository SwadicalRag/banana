local type = type
local pairs = pairs
local assert = assert
local tostring = tostring
local getmetatable = debug and debug.getmetatable or getmetatable
local setmetatable = setmetatable

banana = {}
local BANANA_NAMESPACE,BANANA_CLASS = 0,1

banana.Protected = {
    Extends = true,
    GetInternalClassName = true,
    __meta = true
}

banana.IgnoreKeys = {
    __ctor = true,
    __tostring = true,
    __gc = true
}

local function copy(source,doMeta,lookup)
    lookup = lookup or {}
    if type(source) ~= "table" then return source end
    if lookup[source] then return lookup[source] end
    local target = {}
    lookup[source] = target

    for key,value in pairs(source) do
        target[copy(key,doMeta,lookup)] = copy(value,doMeta,lookup)
    end

    if doMeta ~= false then
        setmetatable(target,copy(getmetatable(source),true,lookup) or {})
    end

    return target
end

function banana.__new(enum)
    return setmetatable({},{
        __banana = enum
    })
end

function banana.__is(tbl,enum)
    return getmetatable(tbl) and getmetatable(tbl).__banana == enum
end

banana.RootNamespace = banana.__new(BANANA_NAMESPACE)

function banana.resolveNamespace(name)
    assert(string.match(name,"[A-Za-z0-9:]+"),"Class names must be alphanumeric!")
    local namespace = banana.RootNamespace

    for chunk,sep in string.gmatch(name,"([A-Za-z0-9]+)(:+)") do
        if sep and sep ~= "::" then error("Bad namespace separation convention "..sep) end
        namespace[chunk] = namespace[chunk] or banana.__new(BANANA_NAMESPACE)
        if not banana.__is(namespace[chunk],BANANA_NAMESPACE) then error("Namespace "..name.." passes through a class!") end
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
        if not banana.__is(namespace[chunk],BANANA_NAMESPACE) then error("Namespace "..name.." passes through a class!") end
        namespace = namespace[chunk]
    end

    return namespace
end

function banana.Define(fullname)
    local class = {}
    local classMeta = {}
    class.__meta = classMeta
    classMeta.__banana = BANANA_CLASS
    classMeta.__extends = {}

    function classMeta:__tostring()
        return "Base Class "..fullname
    end

    function classMeta:__index(k)
        for _,parentClass in ipairs(classMeta.__extends) do
            if parentClass[k] then return parentClass[k] end
        end
    end

    function classMeta:__newindex(k,v)
        assert(not banana.Protected[k],"Cannot modify protected member '"..k.."'")
        rawset(self,k,v)
    end

    function class:GetInternalClassName()
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

    local space,name = banana.resolveNamespace(fullname)

    setmetatable(class,classMeta)
    space[name] = class

    return class
end

function banana.New(fullname)
    local space,name = banana.resolveNamespace(fullname)

    assert(space[name],"Class "..tostring(fullname).." does not exist!")
    local instance = copy(space[name],false)

    local meta = instance.__meta
    meta.__gc = meta.__tostring or instance.__gc
    meta.__concat = meta.__tostring or instance.__concat
    meta.__tostring = meta.__tostring or instance.__tostring
    instance.__meta = nil
    setmetatable(instance,meta)

    for _,parentClass in ipairs(meta.__extends) do
        if parentClass.__ctor then
            parentClass.__ctor(instance)
        end
    end

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

function banana.forEachClass(cb,namespace)
    namespace = (((type(namespace) == "string") and banana.resolveNamespaceEx(namespace)) or namespace) or banana.RootNamespace

    for k,v in pairs(namespace) do
        if type(v) == "table" then
            if banana.__is(v,BANANA_CLASS) then
                cb(v)
            elseif banana.__is(v,BANANA_NAMESPACE) then
                banana.forEachClass(cb,v)
            end
        end
    end
end

banana.Clone = copy

return banana
