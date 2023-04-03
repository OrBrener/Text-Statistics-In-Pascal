--  Name: Or Brener
--  Student Id: 1140102
--  CIS*3190 A4 W23

with ada.Text_IO; use Ada.Text_IO;
with ada.Float_Text_IO; use ada.Float_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;

-- this program
procedure textyzer is 

    type intergerArray20 is array(1..20) of integer;
    
    -- check if the the file is valid and can be opened
    function validFile(filename : unbounded_string) return boolean is
        infp : file_type;
        begin
            -- try to open the file
            open(infp,in_file, to_string(filename));
            close(infp);

            -- file can be opened properly 
            return True;

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

    function isAlpha(char : character) return boolean is
        begin
        return char in 'a' .. 'z' or char in 'A' .. 'Z';
    end isAlpha;

    function isCharNumber(char : character) return boolean is
        begin
        return char in '0' .. '9';
    end isCharNumber;

    function isEndofSentence(char : character) return boolean is
        begin
        return (char = '.' or char = '!' or char = '?');
    end isEndofSentence;

    function isPunctuation(char : character) return boolean is
        begin
        return (isEndofSentence(char) or char = ',' or char = ';' or char = ':');
    end isPunctuation;

    function isNumber(word : unbounded_string) return boolean is
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len := length(word);

        wordString(1..len) := to_String(word);

        if (not isCharNumber (wordString(1))) then
            return false;
        end if;

        if (len = 2) then
            if (not isCharNumber (wordString(2))) then
                return false;
            end if;
        elsif (len > 2) then 

            for index in 3..len-2 loop
                if ((not isCharNumber (wordString(index))) ) then
                    return false;
                end if;
            end loop;
        end if;
        
        return true;
    end isNumber;

    function isWord(word : unbounded_string) return boolean is
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len  := length(word);

        wordString(1..len) := to_String(word);

        for index in 1..len-2 loop
            if (not isAlpha(wordString(index))) then
                return false;
            end if; 
        end loop;

        if ( not isAlpha(wordString(len-1)) and wordString(len-1) /= ',' and wordString(len-1) /= ';' and wordString(len-1) /= ':' and not isEndofSentence(wordString(len-1)) ) then
            return false;
        end if;

        if (wordString(len) /= ' ' and wordString(len) /= '|') then
            return false;
        end if;

        return true;
    end isWord;

    procedure calcNumLettersinWord(word : in unbounded_string; numLettersinWords : in out intergerArray20) is
        numLetters : integer := 0;
        wordString : string(1..100000);
        len : integer := 0;
        begin

        len  := length(word);

        wordString(1..len) := to_String(word);

        for index in 1..len loop
            if (isAlpha(wordString(index)) or isCharNumber(wordString(index))) then
                numLetters := numLetters + 1;
            end if; 
        end loop;

        numLettersinWords(numLetters) :=  numLettersinWords(numLetters) + 1;

    end calcNumLettersinWord;

    procedure analyzeText(filename : in out unbounded_string; numWords : in out integer; numSentences : in out integer; numLetters : in out integer; numLines : in out integer; numNumbers : in out integer; numSpaces : in out integer; numPunctuation : in out integer; numLettersinWords : in out intergerArray20) is
        line : unbounded_string;
        lineString : string(1..100000);
        oneString : unbounded_string;
        infp : file_type;
        lastSpaceIndex : integer := 1;
        begin

            open(infp,in_file, to_string(filename));
            loop
                exit when end_of_file(infp);
                get_line(infp,line);
                lastSpaceIndex := 1;

                lineString(1..length(line)) := to_String(line);
                for index in 1..length(line) loop
                    if (element(line,index) in ' ') then
                        numSpaces := numSpaces + 1;
                        oneString := To_Unbounded_String(lineString(lastSpaceIndex..index));

                        if (isWord (oneString)) then
                            numWords :=  numWords + 1;
                            calcNumLettersinWord(oneString, numLettersinWords);  
                        end if;

                        if (isNumber (oneString)) then
                            numNumbers := numNumbers + 1;
                            calcNumLettersinWord(oneString, numLettersinWords);
                        end if;

                        if isEndofSentence (lineString(index-1)) then
                            numSentences := numSentences + 1;
                        end if;

                        if isPunctuation (lineString(index-1)) then
                            numPunctuation := numPunctuation + 1;
                        end if;

                        for index2 in lastSpaceIndex..index loop
                            if (isAlpha (lineString(index2))) then
                                numLetters := numLetters + 1;
                            end if;
                        end loop;

                        lastSpaceIndex := index+1;

                    end if;
                end loop;
                oneString := To_Unbounded_String(lineString(lastSpaceIndex..length(line)));
                oneString := oneString & '|';
                numLines := numLines + 1;
                if (isWord (oneString)) then
                    numWords :=  numWords + 1;
                    calcNumLettersinWord(oneString, numLettersinWords);   
                end if;
                if (isNumber (oneString)) then
                    numNumbers := numNumbers + 1;
                    calcNumLettersinWord(oneString, numLettersinWords);
                end if;
                if isEndofSentence (lineString(length(line))) then
                    numSentences := numSentences + 1;
                end if;

                if isPunctuation (lineString(length(line))) then
                    numPunctuation := numPunctuation + 1;
                end if;

                for index2 in lastSpaceIndex..length(line) loop
                    if (isAlpha (lineString(index2))) then
                        numLetters := numLetters + 1;
                    end if;
                end loop;
            end loop;

            close(infp);

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
    
    procedure printHist(numLettersinWords : in intergerArray20) is
        begin
        Put_Line ("Histogram - Word Length Distribution");

        for index in 1..20 loop
            Put ("    " & integer'image(index) & "   ");
            if (index < 10) then
                Put (" ");
            end if;
            for numStars in 1..numLettersinWords(index) loop
                Put ("*");
            end loop;
            Put_Line ("");
        end loop;

    end printHist;
    
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

    filename := getFilename;
    analyzeText (filename, numWords, numSentences, numLetters, numLines, numNumbers, numSpaces, numPunctuation, numLettersinWords);
    avgLettersPerWord := float(numLetters)/float(numWords);
    avgWordsPerSentence := float(numWords)/float(numSentences);
    
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

    --  for index in 1..20 loop
    --      Put_Line ("len:" & integer'image(index) & " =" & integer'image(numLettersinWords(index)));
    --  end loop;

    Put_Line ("");
    printHist (numLettersinWords);


    





end textyzer;

