program gof_terminal;
uses
  Classes, sysutils, crt;

type
  stringArray=array[1..256] of string; {new type to return and recieve arrays}

const
  COl=80;
  ROW=30;

var
  selectedTemplate: string='default.txt';
  gameField: array[0..ROW-1, 0..COL-1] of char;
  nextGen: array[0..ROW-1, 0..COL-1] of char;

{ ============================
          I N I T
============================ }
{reads the file and fill the gane field array like the file}
procedure set_field(var is_error:boolean);
var
  tfIN: textFile;
  cIN: char;
    {row and column counter}
  i_col: integer=0;
  j_row: integer=0;

begin
  assign(tfIN, ('templates/'+selectedTemplate));
  {$I+}
  try
    reset(tfIN);
    while not eof(tfIN) do
      begin
        read(tfIN, cIN);
        {all cells on the ourside or dead and still be dead regardless of the file}
        if ((i_col=0)or(i_col=COL-1)) then cIN:=#50;

        {if hit a new line reset row counter and increment col counter by one}
        if(cIN=#10) then  {#10 == new line | for windows #13#10}
          begin
            if(i_col<>COL) then break; {if size of the field matrix did not match the max row and col break, because
                                          there must be a error}

            Inc(j_row);
            i_col := 0;
            continue;
          end;

        if((cIN<>#48)and(cIN<>#49)and(cIN<>#10)and(cIN<>#50)) then
          begin
            break; {if the the char is not a zero or one break and print error code}
          end;

        {all cells on the ourside or dead and still be dead regardless of the file}
        if ((j_row=0)or(j_row=ROW-1)) then cIN:=#50;
        gameField[j_row, i_col] := cIN;
        Inc(i_col); {increment col counter after every inserted char}
      end;
    nextGen := gameField;
  except
    on E: EInOutError do is_error := true;
  end;
  if(not eof(tfIN)or(is_error)) then
    begin
      write('Fehler beim einlesen der datei "', selectedTemplate, '", bitte pruefen sie die Datei.');
      readkey;
      close(tfIN);
      is_error:=true;
    end;
end;

{ ============================
    G A M E  L O G I C
============================ }
procedure update_screen;
var
  i: integer=0;
  j: integer=0;
begin
  clrscr;
  for i:=0 to ROW-1 do begin
    for j:=0 to COL-1 do begin
      if gameField[i, j]=#48 then write(' ')
        else if gameField[i,j]=#50 then write('%')
      else
        write('#');
    end;
    writeln();
  end;
  write('Zum beenden beliebige Tase druecken...');
end;

procedure next_gen;
var
  i_col: integer=1;
  j_row: integer=1;
  living_cells: integer=0;
begin

  while(j_row<ROW-1) do begin
    living_cells := 0;
    while((i_col<COL-1)) do begin
      living_cells := 0;
      if (nextGen[j_row-1, i_col-1]=#49)   then inc(living_cells);
      if (nextGen[j_row-1, i_col]=#49)     then inc(living_cells);
      if (nextGen[j_row-1, i_col+1]=#49)   then inc(living_cells);
      if (nextGen[j_row, i_col-1]=#49)     then inc(living_cells);
      if (nextGen[j_row, i_col+1]=#49)     then inc(living_cells);
      if (nextGen[j_row+1, i_col-1]=#49)   then inc(living_cells);
      if (nextGen[j_row+1, i_col]=#49)     then inc(living_cells);
      if (nextGen[j_row+1, i_col+1]=#49)   then inc(living_cells);

      if (nextGen[j_row, i_col]=#49) then begin
        if(living_cells<2) then gameField[j_row, i_col] := #48
        else if(living_cells=2)or(living_cells=3) then gameField[j_row, i_col] := #49
        else if(living_cells>=4) then gameField[j_row, i_col] := #48;
      end
      else if(living_cells=3) then gameField[j_row, i_col] := #49;
      inc(i_col);
    end;

    inc(j_row);
    i_col := 1;
  end;
  nextGen := gameField;
end;

procedure start_game;
var is_error:boolean=false;
begin
  set_field(is_error);
  if not is_error then
    begin
      repeat
        update_screen;
        delay(200);
        next_gen;
      until keypressed;
    end
end;

{ ============================
	M E N U
============================ }
{returns a string array with all files inside the folder 'template' and set a int parameter to the amount of how many
files are found}
function get_templates(var size: integer): stringArray;
var
  info: TSearchRec;
  count: Longint;
  templateName: stringArray;
begin
  count := 0;
  if findFirst('templates/*', (faAnyFile), info)=0 then
    begin
      repeat
        with info do
          begin
            if ((attr)and(faDirectory))<>faDirectory then begin
              if Name<>'null.txt' then
              begin
                Inc(count);
                templateName[count] := Name;
              end;
            end;
          end;
      until findNext(info)<>0;
    end;
  findClose(info);
  size := count; // how many templates actually found
  get_templates := templateName;
end;

{list available templates inside the folder templates}
procedure select_template_menu;
var
  templateName: stringArray;
  input: string;
  choise: LongInt=0; {converted input}
  size: integer=0; {how many templates are found}

  i: integer=0;
  loop: boolean=false;
begin
  writeln;
  templateName := get_templates(size);
  repeat
    clrscr;
    writeln(#10, 'Vorlage: ', selectedTemplate, #10, '------------------', #10);
    writeln('Waehlen sie eine Vorlage');

    for i:=1 to size do begin
      if templateName[i]<>'null.txt' then writeln('(', (i), ')', templateName[i]);
    end;
    writeln('(0)Exit');

    write('~~> ');
    readln(input);
    if ((not tryStrToInt(input, choise))or(choise>size)or(choise<0)) then
      begin
        write('Geben Sie eine Zahl in den Klammern ein (z.B. 1=', templateName[1], ')');
        readkey;
      end
    else
      if choise=0 then loop := true
      else
        selectedTemplate := templateName[choise];
  until loop;
end;

procedure main_menu;
var
  main_loop: boolean=false;
  input_str: string;
  input_int: longint=0;
begin
  repeat
    if keypressed then readkey; {remove key from buffer}
    clrscr;
    writeln(#10, 'Vorlage: ', selectedTemplate, #10, '------------------');
    writeln('Source Code: www.github.com/Raxx2206/gof_terminal', #10, '------------------', #10);
    writeln('(1) Spiel Starten');
    writeln('(2) Vorlage aendern');
    writeln('(0) Exit');

    if input_int=-1 then writeln(#10, ' Geben Sie eine Zahl in den Klammern ein wie 1 um das Spiel zu starten.', #10);

    write('~~> ');
    readln(input_str);
    if not trystrtoint(input_str, input_int) then input_int := -1 {input_int=-1 indicate an error}
    else
      begin
        case input_int of
          0: begin
            writeln('Goodbye!');
            main_loop := true;
          end;
          1: start_game;
          2: select_template_menu;
        else
          input_int := -1;
        end;
      end;

  until main_loop;
end;

{ ============================
	M A I N
============================ }
begin
  clrscr;
  writeln('=============WELCOME==============');

  main_menu;
end.

{how to compile: fpc -Mobjfpc gof.pas}
