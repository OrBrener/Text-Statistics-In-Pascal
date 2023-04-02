--  Name: Or Brener
--  Student Id: 1140102
--  CIS*3190 A4 W23

with ada.Text_IO; use Ada.Text_IO;
--  with ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;
--  with Ada.IO_Exceptions; use Ada.IO_Exceptions;


procedure textyzer is    
    
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
                put_line("Please input the filname you want to anaylize:");
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

    procedure analyzeText(filename : in out unbounded_string) is
        line : unbounded_string;
        infp : file_type;
        begin

            open(infp,in_file, to_string(filename));
            loop
                exit when end_of_file(infp);
                get_line(infp,line);
                put(line);

            end loop;

            close(infp);

            exception 
                    when DEVICE_ERROR =>
                        close(infp);
                        put_line("INVALID FILENAME -- Device Error");
                        filename := getFilename;
                        analyzeText (filename);
                    when NAME_ERROR =>
                        close(infp);
                        put_line("INVALID FILENAME -- Name Error");
                        filename := getFilename;
                        analyzeText (filename);

    end analyzeText;
    
    
    
    filename : unbounded_string;

    begin

    filename := getFilename;
    analyzeText (filename);

end textyzer;

