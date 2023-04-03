--  Name: Or Brener
--  Student Id: 1140102
--  CIS*3190 A4 W23

with ada.Text_IO; use Ada.Text_IO;
with ada.Float_Text_IO; use ada.Float_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;

--  this program outputs text statistics for a given text file
--  Stats ouputed: 
--  number of letters (characters)
--  number of words
--  number of sentences
--  number of lines
--  number of punctuation
--  number of spaces
--  average number of letters per word
--  average number of words per sentence
--  a histogram showing the word length distribution
procedure textyzer is 

    -- 20 element array of type integer
    -- used to store trhe word length frequency
    type intergerArray20 is array(1..20) of integer;
    
    -- check if the the file is valid and can be opened
    function validFile(filename : unbounded_string) return boolean is
        infp : file_type;
        begin
        -- try to open the file
        open(infp,in_file, to_string(filename));
        close(infp);

        -- file can be opened properly 
        return true;

        -- file cannot be opened properly
        exception 
            when DEVICE_ERROR =>
                put_line("INVALID FILENAME -- Device Error");
                return False;
            when NAME_ERROR =>
                put_line("INVALID FILENAME -- Name Error");
                return False;

    end validFile;
    
    -- prompts the user for a filename, checks the existence of the file.
    -- and returns that filename to the main function. 
    -- If no file exists with that name, the user is re-prompted.
    function getFilename return unbounded_string is
        filename : unbounded_string;
        keeplooping : integer := 1;
        begin
        -- keep asking for a filename until a valid one is given
        while (keeplooping = 1) loop
            put_line("Please input the filename you want to analyze:");
            get_line(filename);
            keeplooping := 0;
            if (not validFile(filename)) then
                Put_Line ("Please try again");
                keeplooping := 1;
            end if;
        end loop;

        -- return a valid filename
        return filename;
    end getFilename;

    -- return true if the character is alphabetic (a-z or A-Z)
    function isAlpha(char : character) return boolean is
        begin
        return char in 'a' .. 'z' or char in 'A' .. 'Z';
    end isAlpha;

    -- return true if the character is numberic (0-9)
    function isCharNumber(char : character) return boolean is
        begin
        return char in '0' .. '9';
    end isCharNumber;

    -- return true if the character is a end of sentence character (. or ! or ?)
    function isEndofSentence(char : character) return boolean is
        begin
        return (char = '.' or char = '!' or char = '?');
    end isEndofSentence;

    -- return true if the character is a punctuation character (, or ; or :)
    function isPunctuation(char : character) return boolean is
        begin
        return (isEndofSentence(char) or char = ',' or char = ';' or char = ':');
    end isPunctuation;

    -- return true if the string only has numeric characters
    function isNumber(word : unbounded_string) return boolean is
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len := length(word);

        -- convert unboundedString to String
        wordString(1..len) := to_String(word);

        -- need to first check the first 2 characters
        -- the string can end in a punctuation + newline ("|") or space

        -- if the first character is not a number, the whole word is not a number
        if (not isCharNumber (wordString(1))) then
            return false;
        end if;

        -- if the second character is not a number, the whole word is not a number
        if (len = 2) then
            if (not isCharNumber (wordString(2))) then
                return false;
            end if;
        
        -- check if the rest of the word is all numbers 
        elsif (len > 2) then 
            for index in 3..len-2 loop
                if ((not isCharNumber (wordString(index))) ) then
                    return false;
                end if;
            end loop;
        end if;
        
        -- all the characters are numbers, return true
        return true;
    end isNumber;

    -- return true if the string only has alphabetic characters 
    function isWord(word : unbounded_string) return boolean is
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len  := length(word);

        -- convert unboundedString to String
        wordString(1..len) := to_String(word);

        -- check if all the characters are alphabetic
        for index in 1..len-2 loop
            if (not isAlpha(wordString(index))) then
                return false;
            end if; 
        end loop;

        -- check that the second last chacter is either alphabetic or punctuation or end of sentence character  
        if ( not isAlpha(wordString(len-1)) and wordString(len-1) /= ',' and wordString(len-1) /= ';' and wordString(len-1) /= ':' and not isEndofSentence(wordString(len-1)) ) then
            return false;
        end if;

        -- check that last chacter is newline ("|") or space
        if (wordString(len) /= ' ' and wordString(len) /= '|') then
            return false;
        end if;

        -- all characters are alphabetic, return true
        return true;
    end isWord;

    -- calcualte the number of letters in the word
    -- store frequency of word length in the array numLettersinWords
    -- return the number of letters in the word
    function calcNumLettersinWord(word : in unbounded_string; numLettersinWords : in out intergerArray20) return integer is
        numLetters : integer := 0;
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len  := length(word);

        -- convert unboundedString to String
        wordString(1..len) := to_String(word);

        -- for all the characters in the word, if it is alphanumeric, sum it to numLetters
        for index in 1..len loop
            if (isAlpha(wordString(index)) or isCharNumber(wordString(index))) then
                numLetters := numLetters + 1;
            end if; 
        end loop;

        -- store the frequncy of word length 
        -- each index (1-20) is the word length, and the value is the frequency
        numLettersinWords(numLetters) :=  numLettersinWords(numLetters) + 1;
        
        --  return the number of letters in the word
        return numLetters;

    end calcNumLettersinWord;

    -- calculate the stats of a single word
    -- calculates: numWords, numLetters, numNumbers, numLettersinWord, numSentences, numPunctuation
    procedure getStats(oneWordUnboundedString : in unbounded_string; lineString : string; index : in integer; numWords : in out integer; numSentences : in out integer; numLetters : in out integer; numNumbers : in out integer; numPunctuation : in out integer; numLettersinWords : in out intergerArray20) is
        numLetterInWord : integer := 0;
        begin

        -- if it is a word:
        -- increment numWords
        -- claculate the number of letters in the word
        -- increment numLetters (total) by number of letters in the word
        if (isWord (oneWordUnboundedString)) then
            numWords :=  numWords + 1;
            numLetterInWord := calcNumLettersinWord(oneWordUnboundedString, numLettersinWords);
            numLetters := numLetters + numLetterInWord;   
        end if;

        -- if it is a number:
        -- increment numNumbers
        -- claculate the number of letters in the number
        if (isNumber (oneWordUnboundedString)) then
            numNumbers := numNumbers + 1;
            numLetterInWord := calcNumLettersinWord(oneWordUnboundedString, numLettersinWords);
        end if;

        if isEndofSentence (lineString(index)) then
            numSentences := numSentences + 1;
        end if;

        if isPunctuation (lineString(index)) then
            numPunctuation := numPunctuation + 1;
        end if;

    end getStats;

    -- reads the whole file and calculates all the statistics
    procedure analyzeText(filename : in out unbounded_string; numWords : in out integer; numSentences : in out integer; numLetters : in out integer; numLines : in out integer; numNumbers : in out integer; numSpaces : in out integer; numPunctuation : in out integer; numLettersinWords : in out intergerArray20) is
        infp : file_type;
        line : unbounded_string;
        lineString : string(1..100000);
        oneWordUnboundedString : unbounded_string;
        lastSpaceIndex : integer := 1;
        begin
        -- open the file
        -- if there is a problem, an exception is caught and retried  
        open(infp,in_file, to_string(filename));
        
        -- loop through all the lines of the file
        loop exit when end_of_file(infp);
            -- get the line and convert it to a string (from unboundedString)
            get_line(infp,line);
            lineString(1..length(line)) := to_String(line);

            -- reset the index of the last space
            lastSpaceIndex := 1;

            -- for all characters in the line
            for index in 1..length(line) loop
                -- if there is a space:
                -- increment numSpaced
                -- create an unboundedString of that one word
                if (element(line,index) in ' ') then
                    numSpaces := numSpaces + 1;
                    oneWordUnboundedString := To_Unbounded_String(lineString(lastSpaceIndex..index));

                    -- get and upadate the stats of the one word
                    getStats(oneWordUnboundedString, lineString, index-1, numWords, numSentences, numLetters, numNumbers, numPunctuation, numLettersinWords);

                    -- the last space is now the end of oneWordUnboundedString
                    lastSpaceIndex := index+1;
                end if;

                -- loop and get the next word. Keep doing this for all words in the line
            end loop;

            -- the last word in the line goes until length(line)
            oneWordUnboundedString := To_Unbounded_String(lineString(lastSpaceIndex..length(line)));
            -- append a newline character
            oneWordUnboundedString := oneWordUnboundedString & '|';
            numLines := numLines + 1;
            -- get and upadate the stats of the last word in the line
            
            getStats(oneWordUnboundedString, lineString, length(line), numWords, numSentences, numLetters, numNumbers, numPunctuation, numLettersinWords);
        -- finished all lines and words in the file
        end loop;

        close(infp);

        -- exception thrown when having issues openning the file
        -- close the file, write an error message, prompt for another valid filename and call analyzeText again
        exception 
            when DEVICE_ERROR =>
                close(infp);
                put_line("INVALID FILENAME -- Device Error");
                filename := getFilename;
                analyzeText (filename, numWords, numSentences, numLetters, numLines, numNumbers, numSpaces, numPunctuation, numLettersinWords);
            when NAME_ERROR =>
                close(infp);
                put_line("INVALID FILENAME -- Name Error");
                filename := getFilename;
                analyzeText (filename, numWords, numSentences, numLetters, numLines, numNumbers, numSpaces, numPunctuation, numLettersinWords);

    end analyzeText;
    
    -- print historgram for the word length distribution
    procedure printHist(numLettersinWords : in intergerArray20) is
        begin
        Put_Line ("Histogram - Word Length Distribution");

        -- for all lengths of words, print the frequency (*)
        for index in 1..20 loop
            Put ("    " & integer'image(index) & "   ");
            
            -- add an extra space to line it up
            if (index < 10) then
                Put (" ");
            end if;
            
            for numStars in 1..numLettersinWords(index) loop
                Put ("*");
            end loop;
            Put_Line ("");
        end loop;

    end printHist;
    
    ------------ MAIN FUNCTION ------------

    -- initilize all variables
    filename : unbounded_string;
    numWords : integer := 0;
    numSentences : integer := 0;
    numLetters : integer := 0;
    numLines : integer := 0;
    numNumbers : integer := 0;
    numSpaces : integer := 0;
    numPunctuation : integer := 0;
    numLettersinWords : intergerArray20 := (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    avgLettersPerWord : float := 0.0;
    avgWordsPerSentence : float := 0.0;

    begin

    -- get the filename (make sure it is valid), anaylze the file
    filename := getFilename;
    analyzeText (filename, numWords, numSentences, numLetters, numLines, numNumbers, numSpaces, numPunctuation, numLettersinWords);
    avgLettersPerWord := float(numLetters)/float(numWords);
    avgWordsPerSentence := float(numWords)/float(numSentences);
    
    -- print all the statistics
    Put_Line ("T e x t  S t a t i s t i c s");
    Put_Line ("----------------------------");
    Put_Line ("Number of letters =" & integer'image(numLetters));
    Put_Line ("Number of words =" & integer'image(numWords));
    Put_Line ("Number of numbers =" & integer'image(numNumbers));
    Put_Line ("Number of sentences =" & integer'image(numSentences));
    Put_Line ("Number of lines =" & integer'image(numLines));
    Put_Line ("Number of punctuation =" & integer'image(numPunctuation));
    Put_Line ("Number of spaces =" & integer'image(numSpaces));
    Put ("Average letters per word ="); Put(avgLettersPerWord, aft => 2, exp => 0); Put_Line ("");
    Put ("Average words per sentence = "); Put(avgWordsPerSentence, aft => 2, exp => 0); Put_Line ("");
    Put_Line ("");
    printHist (numLettersinWords);

end textyzer;

