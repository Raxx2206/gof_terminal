
function getTemplates(var size:integer) : stringArray;
//type
//  templateArray = array[1..256] of string;
var
  info:TSearchRec;
  count:Longint;
  templateName:stringArray;
begin
  count:=0;
  if findFirst('templates/*', faAnyFile and faDirectory, info)=0 then
  begin
    repeat
      with info do
      begin
        if (attr and faDirectory) <> faDirectory then begin
          Inc(count);
          templateName[count] := Name;
        end;
      end;
    until findNext(info)<>0;
  end;
  findClose(info);
  size:=count;  // how many templates actually found
  getTemplates:=templateName;
end;

procedure printField;
var
  i:integer = 0;
  j:integer = 0;
begin
  for i:=0 to ROW-1 do begin
    for j:=0 to COL-1 do begin
      write(gameField[i,j]);
    end;
    writeln();
  end;
end;

procedure setField;
var
  tfIN:textFile;
  cIN:char;
  i_col:integer = 0;
  j_row:integer = 0;
begin
  assign(tfIN, ('templates/'+selectedTemplate));
//  try
    reset(tfIN);
    while not eof(tfIN) do
    begin
      read(tfIN, cIN);
      if DEBUG then writeln('   char readed: ', cIN); {debug}

      // if hit a new line reset row counter and increment col counter by one
      if(cIN=#10) then  // #10 == new line | for windows #13#10
      begin
        if DEBUG then writeln('   char is new line'); {debug}
        if DEBUG then writeln('i_col: ', i_col);  {debug}
        if(i_col<>COL) then break;  // if size of the field matrix did not match the max row and col break, because there must be a error
        Inc(j_row);
        i_col:=0;
        continue;
      end;

      if((cIN<>#48) and (cIN<>#49) and (cIN<>#10)) then
      begin
        if DEBUG then writeln('   is no valid char!'); {debug}
        break;  // if the the char is not a zero or one break and print error code
      end;

      if DEBUG then writeln('   set cell', i_col, ' ', j_row);  {debug}
      gameField[j_row,i_col]:=cIN;
      Inc(i_col); // increment row col counter after every inserted char

//      if DEBUG then readkey;  {debug}
    end;
//    writeln(length(gameField));
//    writeln(length(gameField[0]));

    if DEBUG then writeln('   i: ', i_col, 'j: ', j_row);  {debug}

    printField;
    if(not eof(tfIN)) then
      writeln('Fehler beim einlesen der datei "', selectedTemplate, '" bitte pruefen sie die Datei.');

    close(tfIN);
end;

procedure startGame;
begin
  setField;
end;


