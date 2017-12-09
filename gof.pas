program gof_terminal;
uses Classes, sysutils, crt;

type
  stringArray=array[1..256] of string; {new type to return and recieve arrays}

const
  COl=80;
  ROW=30;

var
  input: string;
  mainLoop: boolean=false;

  selectedTemplate: string='default.txt';
  gameField: array[0..ROW-1, 0..COL-1] of char;
  nextGen: array[0..ROW-1, 0..COL-1] of char;

  DEBUG: byte;

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
  if findFirst('templates/*', faAnyFile and faDirectory, info)=0 then
    begin
      repeat
        with info do
          begin
            if (attr and faDirectory)<>faDirectory then begin
              Inc(count);
              templateName[count] := Name;
            end;
          end;
      until findNext(info)<>0;
    end;
  findClose(info);
  size := count; // how many templates actually found
  get_templates := templateName;
end;

{list available templates inside the folder templates}
procedure select_template;
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
    writeln('Waehlen sie eine Vorlage');

    for i:=1 to size do writeln('(', (i), ')', templateName[i]);
    writeln; writeln('(0)Exit');

    write('~~>');
    readln(input);

    loop := false;
    if ((not tryStrToInt(input, choise))or(choise>size)) then
      begin
        writeln; writeln('Geben Sie eine Zahl in den Klammern ein (z.B. 1=', templateName[1], ')');
        loop := true
      end
    else selectedTemplate:=templateName[choise];
  until ((input='0')or(not loop));


end;

{ ============================
I N I T
============================ }
{reads the file and fill the gane field array like the file}
procedure set_field;
var
  tfIN: textFile;
  cIN: char;
    {row and column counter}
  i_col: integer=0;
  j_row: integer=0;
begin
  assign(tfIN, ('templates/'+selectedTemplate));
//  try //TODO handle error
  reset(tfIN);
  while not eof(tfIN) do
    begin
      if DEBUG>=4 then readkey; {debug}

      {all cells on the ourside or dead and still be dead regardless of the file}
      read(tfIN, cIN);
      if(((cIN<>#48)and(cIN<>#10)) and ((i_col=0)or(i_col=COL-1)or(j_row=0)or(j_row=ROW-1))) then
        begin
          if DEBUG>=2 then writeln('  cell is border'); {debug}
          cIN:=#48;
        end;

      if DEBUG=3 then writeln('   char readed: ', cIN); {debug}
      {if hit a new line reset row counter and increment col counter by one}
      if(cIN=#10) then  {#10 == new line | for windows #13#10}
        begin
          if DEBUG>=2 then writeln('   char is new line'); {debug}
          if DEBUG>=2 then writeln('      -i_col: ', i_col); {debug}
          if(i_col<>COL) then break; {if size of the field matrix did not match the max row and col break, because
																				there must be a error}
          Inc(j_row);
          i_col := 0;
          continue;
        end;

      if((cIN<>#48)and(cIN<>#49)and(cIN<>#10)) then
        begin
          if DEBUG=3 then writeln('   is no valid char!'); {debug}
          break; {if the the char is not a zero or one break and print error code}
        end;

      if DEBUG=3 then writeln('     -set cell: iCOL-', i_col, ' jROW-', j_row); {debug}
      gameField[j_row, i_col] := cIN;
      Inc(i_col); {increment col counter after every inserted char}

      if i_col > 100 then break;
//      if DEBUG=3 then readkey;  {debug}
    end;
//    writeln(length(gameField));
//    writeln(length(gameField[0]))

  if DEBUG=3 then writeln('   jROW: ', j_row, ' iCOL: ', i_col); {debug}

  if(not eof(tfIN)) then
    writeln('Fehler beim einlesen der datei "', selectedTemplate, '" bitte pruefen sie die Datei.');

  close(tfIN);

  nextGen:=gameField;
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
      else
        write('#');
    end;
    writeln();
  end;
end;


procedure next_gen;
var
  i_col: integer=1;
  j_row: integer=1;
  living_cells: integer=0;
  loop: boolean=true;
begin
  if DEBUG>=2 then writeln(' calc next gen'); {debug}

  while(j_row<ROW) do begin
    living_cells:=0;
    while((i_col<COL-1)) do begin
      living_cells:=0;
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

    if DEBUG>=2 then writeln(j_row); {debug}
    inc(j_row);
    i_col:=1;
  end;
  nextGen:=gameField;
end;


procedure start_game;
begin
  if DEBUG>=2 then writeln('   init field...'); {debug}
  set_field;
  if DEBUG>=2 then writeln('   field is set...'); {debug}

  repeat
    update_screen;
    delay(100);
    next_gen;
  until keypressed;
end;

//{$I proceduren}

{ ============================
					M A I N
	============================ }
begin
  if(paramcount>0) then DEBUG := strtoint(paramstr(1));
  clrscr;
  writeln('=============WELCOME==============');
  repeat
    writeln(#10, selectedTemplate, #10);
    writeln('(1) Spiel Starten');
    writeln('(2) Vorlage laden');
    writeln('(0) Exit');
    write('~~> ');
    input := readkey; //TODO: change to readln
    writeln(input);
    case input of
      #49: begin
        mainLoop := true;
        start_game;
      end;
      #50: begin
        select_template;
      end;
      '0': break;
    else
      writeln('Geben Sie eine Zahl in den Klammern ein (z.B. 1=Spiel Starten) \n\n');
    end;
  until mainLoop;
end.
