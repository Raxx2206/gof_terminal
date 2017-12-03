program gof_terminal;
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, sysutils, crt;

type
  stringArray = array[1..256] of string; // new type to return and recieve arrays

const
  COl = 80;
  ROW = 30;

var
  input : char;
  mainLoop : boolean = false;

  selectedTemplate:string = 'default.txt';
  gameField :array[0..ROW-1,0..COL-1] of char;

  DEBUG:byte;


{$I proceduren}

// list available templates inside the folder templates
procedure selectTemplate;
var
  templateName:stringArray;
  input:string;
  choise:LongInt = 0; // converted input
  size:integer = 0; // how many templates are found
  t:string; // temp var to print array

  i:integer = 0;
  loop:boolean = false;
begin
  writeln;
  templateName := getTemplates(size);
  repeat
    clrscr;
    writeln('Waehlen sie eine Vorlage');

    for i:=1 to size do writeln('(', (i), ')', templateName[i]);
    writeln; writeln('(0)Exit');

    write('~~>');
    readln(input);

    loop:=false;
    if ((not tryStrToInt(input,choise)) or (choise > size)) then
    begin
      writeln; writeln('Geben Sie eine Zahl in den Klammern ein (z.B. 1=', templateName[1], ')');
      loop:=true
    end;
  until ((input='0') or (not loop));
  

end;

{ MAIN }
begin
  if(paramcount > 0) then DEBUG:=strtoint(paramstr(1));
  clrscr;
  writeln('=============WELCOME==============');
  repeat
    writeln('(1) Spiel Starten');
    writeln('(2) Vorlage laden');
    writeln('(0) Exit');
    write('~~> ');
    input := readkey; //TODO: change to readln
    writeln(input);
    case input of
      #49 :
      begin
        mainLoop := true;
        startGame;
      end;
      #50 :
      begin
        selectTemplate;
      end;
      '0' : break;
    else writeln('Geben Sie eine Zahl in den Klammern ein (z.B. 1=Spiel Starten) \n\n');
    end;
  until mainLoop;
end.
