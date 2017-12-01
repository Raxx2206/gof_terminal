
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

procedure startGame;
begin

end;
