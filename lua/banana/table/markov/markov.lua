local MarkovChain = banana.Define("MarkovChain")

function MarkovChain:__ctor()
    self.firstWords = {}
    self.firstWordsLookup = {}
    self.firstWordFrequencies = {}
    self.totalFirstWordFrequency = 0
end

function MarkovChain:Learn(sentence)
    local currentWord
    for word in sentence:gmatch("%S+") do
        if currentWord then
            currentWord = currentWord:AddChildString(word)
        else
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
        end
    end

    local oneWordLessSentence = sentence:match("%S+%s+(.+)")
    if oneWordLessSentence and (oneWordLessSentence ~= "") then
        self:Learn(oneWordLessSentence)
    end
end

function MarkovChain:GetRandomFirstWord()
    local target,current = math.random(1,self.totalFirstWordFrequency),0

    for i=1,#self.firstWords do
        current = current + self.firstWordFrequencies[self.firstWords[i]:GetString()]
        if current >= target then return self.firstWords[i] end
    end

    return false
end

function MarkovChain:resetWordChain(wordChain)
    local newWordChain = {}

    for i,word in ipairs(wordChain) do
        if i == 1 then
            newWordChain[1] = self.firstWordsLookup[wordChain[1]:GetString()]
        else
            newWordChain[#newWordChain+1] = newWordChain[#newWordChain]:GetChild(wordChain[i]:GetString())
        end
    end

    table.remove(newWordChain,1)

    return newWordChain
end

function MarkovChain:Generate(start,maxLength,depth)
    local outputChain,wordChain = {},{}

    if start then
        for word in start:gmatch("%S+") do
            if #outputChain == 0 then
                if self.firstWordsLookup[word] then
                    wordChain[1] = self.firstWordsLookup[word]
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

            if #wordChain > (depth or 2) then
                wordChain = self:resetWordChain(wordChain)
            end
        end
    else
        wordChain[1] = self:GetRandomFirstWord()
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

        if #wordChain >= (depth or 2) then
            wordChain = self:resetWordChain(wordChain)
        end

        if maxLength and (#outputChain >= maxLength) then
            break
        end
    end

    return table.concat(outputChain," ")
end
