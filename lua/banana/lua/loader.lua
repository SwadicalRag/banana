local Loader = banana.Define("Loader")

function Loader:__ctor()
    self.Logger = banana.New("Logger")
    self.Logger:SetTag("Loader")

    self.Loaded = {}
end

function Loader:SetTag(...)
    self.Logger:SetTag(...)
end

function Loader:SetLoaded(path,status)
    self.Loaded[path] = status
end

function Loader:IsLoaded(path)
    return self.Loaded[path] or false
end

function Loader:LoadFile(path)
    if self:IsLoaded(path) then return end
    self.Logger:LogDebug("Loading "..path.."...")
    self:SetLoaded(path,true)
    if bFS then
        bFS:RunFile(path)
    else
        include(path:sub(2,-1))
        AddCSLuaFile(path:sub(2,-1))
    end
end

function Loader:LoadFolder(path) -- path ends with /
    local files,folders = file.Find("lua/"..path.."*","GAME")

    for _,fileName in ipairs(files) do
        self:LoadFile(path..fileName)
    end
end

function Loader:LoadFolderRecursive(path) -- path ends with /
    local files,folders = file.Find("lua/"..path.."*","GAME")

    for _,fileName in ipairs(files) do
        self:LoadFile(path..fileName)
    end

    for _,folderName in ipairs(folders) do
        self:LoadFolderRecursive(path..folderName.."/")
    end
end