unit MapLoader;

interface

uses
  Windows, SysUtils, CommDlg, uFcData, Plugin, mrVic;

type tagLine = packed record
  Seg: DWORD;
  Offset: DWORD;
  Description: PAnsiChar;
end;
TLine = tagLine;
PLine = ^TLine;

const CONST_ADDRESS = 'Address'; // Determine 'Address         Publics by Value'

var
  IDH: TImageDosHeader;
  INtH: TImageNtHeaders;
  IFH: TImageFileHeader;
  IOH: TImageOptionalHeader;  
  ISH: array of TImageSectionHeader;

  PEFilePath: String = '';
  MapFilePath: String = '';

Function DoImport(szPathFile: String; bType: Boolean): DWORD; stdcall;
Function ImportMapFile(bType: Boolean): DWORD; stdcall;
Function ImportingThread: DWORD; stdcall;
Procedure LoadPE(szFilePath: String); stdcall;

implementation

Procedure LoadPE(szFilePath: String); stdcall;
var
  hFile: HMODULE;
  hFileMap: THandle;
  dwAddrFirstOfTheSection: DWORD;
  i: ShortInt;
begin
  hFile:= FileOpen(szFilePath,fmOpenRead or fmShareDenyNone);
  if (hFile = 0) then
    VICMsg('PE::FileOpen::Failure')
  else
  begin
    hFileMap:= CreateFileMappingA(hFile,NIL,PAGE_READONLY,0,0,'');
    if (hFileMap = 0) then
      VICMsg('PE::CreateFileMappingA::Failure' + TError)
    else
    begin
      hFile:= DWORD(MapViewOfFile(hFileMap,FILE_MAP_READ,0,0,0));
      if (hFile = 0) then
      begin
        VICMsg('PE::MapViewOfFile::Failure' + TError);
        hFile:= GetModuleHandleA(PAnsiChar(szFilePath));
        if (hFile = 0) then
        begin
          VICMsg('PE::GetModuleHandleA::Failure' + TError);
          hFile:= LoadLibraryA(PAnsiChar(szFilePath));
          if (hFile = 0) then
          begin
            VICMsg('PE::LoadLibraryA::Failure' + TError);
            Exit;
          end;
        end;
      end;
    end;
  end;

  IDH:= PImageDosHeader(hFile)^;

  if (IDH.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VICMsg('PE::TImageDosHeader::Failure');
    Exit;
  end;

  INtH:= PImageNtHeaders(hFile + DWORD(IDH._lfanew))^;
  if (INtH.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VICMsg('PE::TImageNtHeaders::Failure');
    Exit;
  end;

  IFH:= PImageFileHeader(DWORD(@INtH.FileHeader))^;

  IOH:= PImageOptionalHeader(DWORD(@INtH.OptionalHeader))^;

  SetLength(ISH,IFH.NumberOfSections);

  dwAddrFirstOfTheSection:=
    hFile + DWORD(
      IDH._lfanew +
      SizeOf(INtH.Signature) +
      SizeOf(IFH)) +
      IFH.SizeOfOptionalHeader;

  for i:= 0 to High(ISH) do
  begin
    ISH[i]:= PImageSectionHeader(
      dwAddrFirstOfTheSection +
      DWORD(i*SizeOf(TImageSectionHeader)))^;
  end;

  if (dwImageBase = 0) then
    dwImageBase:= IOH.ImageBase;
end;

Function RemoveSpaceChar(const Line: PAnsiChar): PAnsiChar; stdcall;
var
  i, j: Integer;
  LineRemovedSpaceChar: array[0..MAXBYTE] of Char;
begin
  ZeroMemory(@LineRemovedSpaceChar[0],MAXBYTE);
  j:= 0;
  for i:= 0 to Length(Line) - 1 do
  begin
    if (Line[i] <> ' ') then
    begin
      LineRemovedSpaceChar[j]:= Line[i];
      Inc(j);
    end;
  end;
  Result:= PAnsiChar(@LineRemovedSpaceChar[0]);
end;

Function DoImport(szPathFile: String; bType: Boolean): DWORD; stdcall;
var
  f: TEXT;
  Line: array[0..MAXBYTE] of Char;
  FixedLine: PAnsiChar;
  MyLine: TLine;
  dwPosOfAddress, dwAddr, dwCount: DWORD;
begin
  Result:= 0;
  
  Assign(f,szPathFile);
  {$I-}
  Reset(f);
  {$I+}
  if (IOResult <> 0) then
  begin
    StatusFlash('Map file not found...');
    Exit;
  end;

  if (bType = True) then
  begin
    {$IF __VERSION__ = 1.10}
    //InfoLine('Importing labels from map file...');
    {$IFEND}
    {$IF __VERSION__ = 2.01}
    //Info('Importing labels from map file...');
    {$IFEND}
  end
  else
  begin
    {$IF __VERSION__ = 1.10}
    //InfoLine('Importing comments from map file...');
    {$IFEND}
    {$IF __VERSION__ = 2.01}
    //Info('Importing comments from map file...');
    {$IFEND}
  end;

  dwPosOfAddress:= 0;
  dwCount:= 0;
  repeat
    ZeroMemory(Pointer(@MyLine),sizeof(MyLine));
    ZeroMemory(Pointer(@Line),MAXBYTE);

    ReadLn(f,Line);

    FixedLine:= RemoveSpaceChar(Line);

    if (dwPosOfAddress = 0) then
    begin
      dwPosOfAddress:= Pos(CONST_ADDRESS,FixedLine);
    end;
    
    if (dwPosOfAddress <> 0) then
    begin
      if (FixedLine[0] = '0') and ((FixedLine[4] = ':')) then
      begin
        MyLine.Seg:= HexToInt(Copy(FixedLine,1,4));
        MyLine.Offset:= HexToInt(Copy(FixedLine,6,8));
        MyLine.Description:= FixedLine + 13;

        dwAddr:= dwImageBase + ISH[MyLine.Seg - 1].VirtualAddress + MyLine.Offset;

        if bType then
        begin
          {$IF __VERSION__ = 1.10}
          InsertName(dwAddr,NM_LABEL,MyLine.Description);
          {$IFEND}
          {$IF __VERSION__ = 2.01}
          InsertNameW(dwAddr,NM_LABEL,StringToOleStr(StrPas(MyLine.Description)));
          {$IFEND}
        end
        else
        begin
          {$IF __VERSION__ = 1.10}
          InsertName(dwAddr,NM_COMMENT,MyLine.Description);
          {$IFEND}
          {$IF __VERSION__ = 2.01}
          InsertNameW(dwAddr,NM_COMMENT,StringToOleStr(StrPas(MyLine.Description)));
          {$IFEND}
        end;
        
        //VICMsg('%0.4X:%0.8X <%s>',[MyLine.Seg,MyLine.Offset,MyLine.Description]);
        //VICMsg('%0.8X:%s',[dwAddr,MyLine.Description]);
        Inc(dwCount);
      end;
    end;
  until (EOF(f));

  Close(f);

  if (bType = True) then
  begin
    {$IF __VERSION__ = 1.10}
    //InfoLine('Have %d(d) labels imported from map file',dwCount);
    AddToLog(0,DRAW_HILITE,'%s: Have %d labels imported from map file',PLUGIN_NAME,dwCount);
    {$IFEND}
    {$IF __VERSION__ = 2.01}
    //Info('Have %d(d) labels imported from map file',dwCount);
    AddToLog(0,DRAW_HILITE,'%s: Have %d labels imported from map file',PLUGIN_NAME,dwCount);
    {$IFEND}
  end
  else
  begin
    {$IF __VERSION__ = 1.10}
    //InfoLine('Have %d(d) comments imported from map file',dwCount);
    AddToLog(0,DRAW_HILITE,'%s: Have %d comments imported from map file',PLUGIN_NAME,dwCount);
    {$IFEND}
    {$IF __VERSION__ = 2.01}
    //Info('Have %d(d) comments imported from map file',dwCount);
    AddToLog(0,DRAW_HILITE,'%s: Have %d comments imported from map file',PLUGIN_NAME,dwCount);
    {$IFEND}
  end;

  Result:= dwCount;
end;

Function ImportMapFile(bType: Boolean): DWORD; stdcall;
begin
  Result:=0;
  if (PEFilePath <> '') then
  begin
    LoadPE(PEFilePath);
    if (MapFilePath <> '') then
    begin
      Result:= DoImport(MapFilePath,bType);
    end;
  end;
end;

Function ImportingThread: DWORD; stdcall;
begin
  if (fImportType = True) then
  begin
    Result:= ImportMapFile(fImportType);
    if (Result <> 0) then
      StatusFlash('Labels have been imported')
    else
      StatusFlash('Cancel or can not import labels');
  end
  else
  begin
    Result:= ImportMapFile(fImportType);
    if (Result <> 0) then
      StatusFlash('Comments have been imported')
    else
      StatusFlash('Cancel or can not import comments');
  end;
end;

end.
