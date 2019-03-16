program Demo;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  mrVic;

const
  NAME_TARGET = 'ViCKmD';

var
  fi, fo: Text;
  szLine: String;
  iCount: Integer = 0;
  iPos: Integer = 0;

Procedure Replace(var szMain: String; szFind, szReplace: String); stdcall;
begin
  szMain:= StringReplace(szMain,szFind,szReplace,[rfReplaceAll,rfIgnoreCase]);
end;

Procedure LTrim(var szStr: String; iStart: Integer); stdcall;
var i: Integer;
begin
  for i:= iStart to Length(szStr) do
    if (szStr[i] = #$20) then
      Delete(szStr,iStart,1)
    else
      Break;
end;

Function IsConst(szStr: String): Boolean; stdcall;
var i: Integer;
begin
  Result:= True;
  for i:= 1 to Length(szStr) do
    if not (szStr[i] in ['a'..'f','A'..'F','0'..'9']) then
    begin
      Result:= False;
      Break;
    end;
end;

Function UPos(szSubStr, szStr: String): Integer; stdcall;
begin
  Result:= Pos(UpperCase(szSubStr),UpperCase(szStr));
end;

Procedure FindConst(var szStr: String; szFind: String); stdcall;
var
  i: Integer;
  szConst: String;
begin
  szConst:= '';
  iPos:= UPos(szFind,szStr);
  if (iPos <> 0) then
  begin
    for i:= (iPos + Length(szFind)) to Length(szStr) do
      if (szStr[i] <> #$20) then
        szConst:= szConst + szStr[i];
      if IsConst(szConst) then
      begin
        szStr:= szStr + 'h';
        if (szStr[iPos + Length(szFind)] in ['a'..'f','A'..'F']) then
          Insert('0',szStr,iPos + Length(szFind));
      end;
  end;
end;

begin
  Assign(fo,GetCurrentDir + '\output.txt');
  ReWrite(fo);

  WriteLn(fo,'asm');

  Assign(fi,GetCurrentDir + '\input.txt');
  {$I-}
  Reset(fi);
  {$I+}
  if (IOResult <> 0) then
  begin
    PrintfLn('File not found');
    Exit
  end;
  iCount:= 0;
  while not Eof(fi) do
  begin
    Readln(fi,szLine);

    Delete(szLine,15,17);

    LTrim(szLine,9);

    Replace(szLine,'short ' + NAME_TARGET + '.',' Label_');

    iPos:= UPos('[local',szLine);
    if (iPos = 0) then
    begin
      iPos:= UPos(']',szLine);
      if ((iPos - 1) <> 0) then
        if (szLine[iPos - 1] in ['a'..'f','A'..'F','0'..'9']) then
          Insert('h',szLine,iPos);
    end;

    // 00401022 call <jmp.&KERNEL32.GetModuleHandleA> -> 00401022 call GetModuleHandleA
    iPos:= UPos('call <jmp.&',szLine);
    if (iPos <> 0) then
    begin
      Replace(szLine,'call <jmp.&','call ');
      iPos:= UPos('>',szLine);
      Delete(szLine,iPos,1);
      Delete(szLine,17,UPos('.',szLine) - 16);
    end;

    FindConst(szLine,'offset ' + NAME_TARGET + '.');

    FindConst(szLine,',');

    FindConst(szLine,'push ');

    Replace(szLine,'offset ' + NAME_TARGET + '.','');

    Replace(szLine,'call near','call');

    Replace(szLine,'[local.','[Local');

    Replace(szLine,'call ' + NAME_TARGET + '.','call Label_');

    iPos:= UPos(':[' + NAME_TARGET + '.',szLine);
    if (iPos <> 0) then
    begin
      if (szLine[iPos + Length(':[' + NAME_TARGET + '.')] in ['0'..'9']) then
        Replace(szLine,':[' + NAME_TARGET + '.',':[')
      else
        Replace(szLine,':[' + NAME_TARGET + '.',':[0');
    end;

    Replace(szLine,NAME_TARGET + '.','Label_');

    Insert(' *)',szLine,9);
    Insert('(* ',szLine,1);

    szLine:= #9 + szLine;

    WriteLn(fo,szLine);
    PrintfLn(szLine);
  end;

  WriteLn(fo,'end;');

  Close(fi);
  Close(fo);
  
  Pause;
end.
