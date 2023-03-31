program trailtext(input, output);
var
   ch: char;
   charsinword : integer;
   wordsinsent : integer;
   totalchars : integer;
   totalwords : integer;
   totalsents : integer;
   longword : integer;
   longsent : integer;
   avgchar : real;
   avgword : real;

begin
   charsinword := 0;
   wordsinsent := 0;
   totalchars := 0;
   totalwords := 0;
   totalsents := 0;
   longword := 0;
   longsent := 0;
  
   writeln('input text:':29);
   writeln;

   ch := ' ';
   while not eof(input) do
      begin
         while ch in ['.','!','?',' '] do
         begin
            read(ch);
            write(ch)
         end;
   if not( ch in [',',':',';']) then
      charsinword := charsinword + 1;
   while not eoln(input)
         and not (ch in ['.','!','?',' ']) do
      begin
      read(ch);
      write(ch);
      if ch in ['A'..'Z','a'..'z'] then
         charsinword := charsinword + 1
      end;

   wordsinsent := wordsinsent + 1;
   totalchars := totalchars + charsinword;
   if longword < charsinword then
      longword := charsinword;
   charsinword := 0;

   if ch in ['.','!','?'] then
      begin
      totalsents := totalsents + 1;
      totalwords := totalwords + wordsinsent;
      if longsent < wordsinsent then
         longsent := wordsinsent;
      wordsinsent := 0
      end;

   if eoln(input) then
      begin
      read(ch);
      writeln
   end
end;

avgchar := totalchars /totalwords;
avgword := totalwords /totalsents;

writeln('text statistics:':29);
writeln('totals     ':20);
writeln('characters':28, totalchars:7); 
writeln('words     ':28, totalwords:7); 
writeln('sentences ':28, totalsents:7); 
writeln('averages':20);
writeln('characters/word':28, avgchar:10:2); 
writeln('words/sentence ':28, avgword:10:2);
writeln('maxima':20);
writeln('characters/word':28, longword:7); 
writeln('words/sentence ':28, longsent:7);
end.
