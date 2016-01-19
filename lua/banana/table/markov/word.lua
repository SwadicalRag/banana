local MarkovWord = banana.Define("MarkovWord")

function MarkovWord:__ctor()
    self.word = "placeholder"
    self.children = {}
    self.childrenLookup = {}
    self.childrenFrequency = {}
    self.totalFrequency = 0
end

function MarkovWord:AddChild(word)
    if not self.childrenLookup[word:GetString()] then
        self.childrenLookup[word:GetString()] = word
        self.children[#self.children+1] = word
        self.childrenFrequency[word:GetString()] = 0
    end

    self.childrenFrequency[word:GetString()] = self.childrenFrequency[word:GetString()] + 1
    self.totalFrequency = self.totalFrequency + 1

    return word
end

function MarkovWord:AddChildString(string)
    local word
    if self.childrenLookup[string] then
        word = self.childrenLookup[string]
    else
        word = banana.New("MarkovWord")
        word:SetString(string)
        self.childrenLookup[string] = word
        self.children[#self.children+1] = word
        self.childrenFrequency[word:GetString()] = 0
    end

    self.childrenFrequency[word:GetString()] = self.childrenFrequency[word:GetString()] + 1
    self.totalFrequency = self.totalFrequency + 1

    return word
end

function MarkovWord:GetChild(string)
    return self.childrenLookup[string]
end

function MarkovWord:GetRandomChild()
    local target,current = math.random(1,math.max(self.totalFrequency,1)),0

    for i=1,#self.children do
        current = current + self.childrenFrequency[self.children[i]:GetString()]
        if current >= target then return self.children[i] end
    end
end

function MarkovWord:SetString(word)
    self.word = word
end

function MarkovWord:GetString()
    return self.word
end
