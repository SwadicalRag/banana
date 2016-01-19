local MarkovChain = banana.Define("MarkovChain")

function MarkovChain:__ctor()
    self.defaultDepth = 3

    self.firstWords = {}
    self.firstWordsLookup = {}
    self.firstWordFrequencies = {}
    self.totalFirstWordFrequency = 0
    self.realFirstWords = {}
    self.realFirstWordsLookup = {}
    self.realFirstWordFrequencies = {}
    self.totalRealFirstWordFrequency = 0
end

function MarkovChain:Learn(sentence,notFirst,noRecurse)
    local currentWord
    for word in sentence:gmatch("%S+") do
        if currentWord then
            currentWord = currentWord:AddChildString(word)
        else
            if notFirst then
                if self.firstWordsLookup[word] then
                    currentWord = self.firstWordsLookup[word]
                else
                    currentWord = banana.New("MarkovWord")
                    currentWord:SetString(word)
                    self.firstWords[#self.firstWords+1] = currentWord
                    self.firstWordFrequencies[word] = 0
                    self.firstWordsLookup[word] = currentWord
                end

                self.totalFirstWordFrequency = self.totalFirstWordFrequency + 1
                self.firstWordFrequencies[word] = self.firstWordFrequencies[word] + 1
            else
                if self.realFirstWordsLookup[word] then
                    currentWord = self.realFirstWordsLookup[word]
                else
                    currentWord = banana.New("MarkovWord")
                    currentWord:SetString(word)
                    self.realFirstWords[#self.realFirstWords+1] = currentWord
                    self.realFirstWordFrequencies[word] = 0
                    self.realFirstWordsLookup[word] = currentWord
                end

                self.totalRealFirstWordFrequency = self.totalRealFirstWordFrequency + 1
                self.realFirstWordFrequencies[word] = self.realFirstWordFrequencies[word] + 1

                self:Learn(sentence,true,true)
            end
        end
    end

    if not noRecurse then
        local oneWordLessSentence = sentence:match("%S+%s+(.+)")
        if oneWordLessSentence and (oneWordLessSentence ~= "") then
            self:Learn(oneWordLessSentence,true)
        end
    end
end

function MarkovChain:GetRandomFirstWord()
    local target,current = math.random(1,math.max(self.totalFirstWordFrequency,1)),0

    for i=1,#self.firstWords do
        current = current + self.firstWordFrequencies[self.firstWords[i]:GetString()]
        if current >= target then return self.firstWords[i] end
    end

    return false
end

function MarkovChain:GetRandomRealFirstWord()
    local target,current = math.random(1,math.max(self.totalRealFirstWordFrequency,1)),0

    for i=1,#self.realFirstWords do
        current = current + self.realFirstWordFrequencies[self.realFirstWords[i]:GetString()]
        if current >= target then return self.realFirstWords[i] end
    end

    return false
end

function MarkovChain:resetWordChain(wordChain)
    local newWordChain = {}

    table.remove(wordChain,1)

    for i,word in ipairs(wordChain) do
        if #newWordChain == 0 then
            newWordChain[1] = self.firstWordsLookup[wordChain[1]:GetString()]
        else
            newWordChain[#newWordChain+1] = newWordChain[#newWordChain]:GetChild(wordChain[i]:GetString())
        end
    end

    return newWordChain
end

function MarkovChain:Generate(start,maxLength,depth)
    local outputChain,wordChain = {},{}

    if start then
        for word in start:gmatch("%S+") do
            if #outputChain == 0 then
                if self.realFirstWordsLookup[word] then
                    wordChain[1] = self.realFirstWordsLookup[word]
                    outputChain[1] = word
                else
                    return start
                end
            else
                local child = wordChain[#wordChain]:GetChild(word)

                if child then
                    wordChain[#wordChain+1] = child
                    outputChain[#outputChain+1] = word
                else
                    return start
                end
            end

            if #wordChain >= (depth or self.defaultDepth) then
                wordChain = self:resetWordChain(wordChain)
            end
        end
    else
        wordChain[1] = self:GetRandomRealFirstWord()
        outputChain[1] = wordChain[1]:GetString()
    end

    while true do
        local child = wordChain[#wordChain]:GetRandomChild()

        if child then
            wordChain[#wordChain+1] = child
            outputChain[#outputChain+1] = child:GetString()
        else
            break
        end

        if #wordChain >= (depth or self.defaultDepth) then
            wordChain = self:resetWordChain(wordChain)
        end

        if maxLength and (#outputChain >= maxLength) then
            break
        end
    end

    return table.concat(outputChain," ")
end
