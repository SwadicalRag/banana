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

function Loader:ShareFile(path,csl_override)
    if banana.isGMod and (csl_override ~= true) then
        AddCSLuaFile(path:sub(2,-1))
    end
end

function Loader:LoadFile(path,csl_override)
    if self:IsLoaded(path) then return end
    self.Logger:LogDebug("Loading "..path.."...")
    self:SetLoaded(path,true)
    if bFS then
        bFS:RunFile(path)
    else
        include(path:sub(2,-1))
    end
    self:ShareFile(path,csl_override)
end

function Loader:LoadFolder(path,csl_override) -- path ends with /
    if bFS then
        local exists,isfolder = bFS:Exists(path:sub(1,-2))
        if not exists or not isfolder then return end
        bFS:ChangeDir(path)
        for _,fileName in ipairs(bFS:Files()) do
            self:LoadFile(path..fileName)
        end
        bFS:ChangeDir("/")
    else
        local files,folders = file.Find(path:sub(2,-1).."*","LUA")

        for _,fileName in ipairs(files) do
            self:LoadFile(path..fileName,csl_override)
        end
    end
end

function Loader:LoadFolderRecursive(path,csl_override) -- path ends with /
    if bFS then
        local exists,isfolder = bFS:Exists(path:sub(1,-2))
        if not exists or not isfolder then return end
        bFS:ChangeDir(path)
        for _,fileName in ipairs(bFS:Files()) do
            self:LoadFile(path..fileName)
        end

        for _,folderName in ipairs(bFS:Folders()) do
            self:LoadFolderRecursive(path..folderName.."/")
        end
        bFS:ChangeDir("/")
    else
        local files,folders = file.Find(path:sub(2,-1).."*","LUA")

        for _,fileName in ipairs(files) do
            self:LoadFile(path..fileName,csl_override)
        end

        for _,folderName in ipairs(folders) do
            self:LoadFolderRecursive(path..folderName.."/")
        end
    end
end

function Loader:ShareFolder(path,csl_override) -- path ends with /
    if bFS then return end
    if not banana.isGMod then return end
    local files,folders = file.Find(path:sub(2,-1).."*","LUA")

    for _,fileName in ipairs(files) do
        self:ShareFile(path..fileName,csl_override)
    end
end

function Loader:ShareFolderRecursive(path,csl_override) -- path ends with /
    if bFS then return end
    if not banana.isGMod then return end
    local files,folders = file.Find(path:sub(2,-1).."*","LUA")

    for _,fileName in ipairs(files) do
        self:ShareFile(path..fileName,csl_override)
    end

    for _,folderName in ipairs(folders) do
        self:ShareFolderRecursive(path..folderName.."/")
    end
end
