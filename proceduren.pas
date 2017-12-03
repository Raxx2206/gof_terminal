
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

procedure setField;
var
  tfIN:textFile;
  cIN:char;
  i:integer = 0;
  j:integer = 0;
begin
  assign(tfIN, ('templates/'+selectedTemplate));
//  try
    reset(tfIN);
    while not eof(tfIN) do
    begin
      read(tfIN, cIN);
      if(cIN=#10) then
      begin
        Inc(i);
        i:=0;
      end;
      if((cIN<>'0') or (cIN<>'1')) then break;
      gameField[i,j]:=cIN;
      Inc(i);
      if((i>=ROW) or (j>=COL)) then break;
    end;

    if(not eof(tfIN)) then
      writeln('Fehler beim einlesen der datei ', selectedTemplate, ' bitte pruefen sie die Datei.');

    close(tfIN);
end;

procedure startGame;
begin
  setField;
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

