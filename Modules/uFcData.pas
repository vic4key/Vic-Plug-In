unit uFcData;

(*
{$IF __VERSION__ = 1.10}

{$IFEND}
{$IF __VERSION__ = 2.01}

{$IFEND}
*)

interface

uses Windows, Classes, Messages, SysUtils, IniFiles, WinInet, ShellAPI,
  TlHelp32, Clipbrd, untPEB, Plugin, mrVic;

//const __VERSION__ = 2.01;

const
  SystemHandleInformation = 16;
  ProcessBasicInformation = 0;
  
  {$IF __VERSION__ = 1.10}
  MAXPATH = MAX_PATH;
  {$IFEND}

type
  PHINST = ^HINST;
  {$IF __VERSION__ = 1.10}
  LPTCHAR = PAnsiChar;
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  LPTCHAR = PWideChar;
  {$IFEND}

  PROCESS_BASIC_INFORMATION = record
    ExitStatus: DWORD;
    PebBaseAddress: PPEB;
    AffinityMask: DWORD;
    BasePriority: DWORD;
    uUniqueProcessId: ULong;
    uInheritedFromUniqueProcessId: ULong;
  end;
  TProcessBasicInformation = PROCESS_BASIC_INFORMATION;

  TMem = packed record
    size: Byte;
    buffer: array[0..MAXBYTE] of Char;
  end;

  T2 = 0..2;

const
  USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; rv:40.0) Gecko/20100101 Firefox/40.0';
  KERNEL32 = 'kernel32.dll';
  CRLF  = ^M^J;
  DCRLF = CRLF + CRLF;

  {$IF __VERSION__ = 1.10}
  PLUGIN_NAME = 'Vic Plug-In';
  VERSION     = '1.06';
  ODVERSION   = '1.10';
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  PLUGIN_NAME:  LPTCHAR = 'Vic Plug-In 2';
  VERSION:      LPTCHAR = '2.06';
  ODVERSION:    LPTCHAR = '2.xx'; // Do not edit
  {$IFEND}

  MAX_HOST = 5;
  URL_DOMAINS : array[1..MAX_HOST] of String = (
    'http://viclab.biz',
    'http://vic.wc.lt',
    'http://vic4key.esy.es',
    'http://vic.zz.vc',
    'http://vic4key.byethost32.com'
    {'http://localhost'}
  );

  URL_ROOT_PATH = '/update/p1/';
  URL_FILE_PATH = 'files/';
  CLIENT_PATH = '';

  VERSION_FILE = 'version.php';
  LIST_FILE    = 'list.php';

  AUTHOR: LPTCHAR      = 'Vic aka vic4key';
  TEAM: LPTCHAR        = 'CiN1';
  MAIL: LPTCHAR        = 'vic4key[at]gmail.com';
  BLOG: LPTCHAR        = 'http://viclab.biz';
  WEBSITE: LPTCHAR     = 'http://cin1team.biz';
  ODVERSCOPE: LPTCHAR  = '(Official)';
  DATEUPDATE: LPTCHAR  = '23/09/2015 00:00';

  szQesDelUdd: LPTCHAR = 'Are you sure to delete all UDD data?';
  szDelDone:   LPTCHAR = 'All UDD data (*.udd, *.bak) is deleted!' + DCRLF +
  'Note: After you deleted, all data in this working session will be delete.' + CRLF +
  'So on, let''s restart OllyDbg after execute this action!';
  szDelError:  LPTCHAR = 'UDD folder not found, could not delete UDD data.';
  szNotAvailable: LPTCHAR = 'This function is not available now!';

  // VicPlugIn 2's key in OllyDbg.ini
  MaxMainODcfg = 'Maximize ollydbg window';
  MaxMDIODcfg  = 'Maximize current MDI window';
  TranODcfg    = 'Transparent ollydbg window';
  TbarODcfg    = 'Show toolbar on ollydbg title';
  AddrInfODcfg = 'Show address info in status bar';
  ApiMenu      = 'Use APIs menu in OllyDbg menu bar';
  ConfirmExit  = 'Apply confirm exit for OllyDbg';

  {$IF __VERSION__ = 1.10}
  szPlginName: String = 'VicPlugIn1xx';
  MAIN_MENU =
    '1 - Show the toolbar,|,' +
    '2 - Maximize OllyDbg window when staring,|,' +
    '3 - Maximize OllyDbg child windows when staring,|,' +
    '4 - Make the transparency for OllyDbg window,|,' +
    '5 - Deletes all the UDD (*.udd & *.bak),|,' +
    '6 - DATA Converter,|,' +
    '7 - DLL Process Viewer,|,' +
    '8 - File Location Converter'#9'Alt + G,|,' +
    '9 - PE Viewer,|,' +
    '10 - PEB Patcher,|,' +
    '11 - Lookup Error Code,|,' +
    '12 - Finding the Delphi Point Events,|,' +
    ' - Map file importer{' +
      '13 - Import labels,|,' +
      '14 - Import comments},|,' +
    ' - Address copier{' +
      '15 - Copy VA,|,' +
      '16 - Copy RVA,|,' +
      '17 - Copy Offset},|,' +
    '18 - Vist my forum && blog,|,' +
    '19 - Infomation';
  SUB_MENU = '0 ViC Plug-In {' + MAIN_MENU + '}';
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  HideThePEB   = 'Hide the PEB';
  {$IFEND}

var
  {$IF __VERSION__ = 1.10}
  hPlg: HMODULE = 0;
  hwODbg: HWND = 0;
  hwClient: HWND = 0;
  hODbgMdl: HMODULE = 0;
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  ODData: TODData;
  {$IFEND}
  hwODbg: HWND = 0;
  hwClient: HWND = 0;
  hiODbg: HINST = 0;
  paOllyPath: PAnsiChar = NIL;
  pwMenuType: PWideChar = NIL;

  URL_ROOT: String = '';
  URL_FILES : String = '';
  OLLYDBG_DIR: String = '';
  OLLYDBG_PLUGIN_DIR: String = '';

  fdir:  String = '';
  fpath: String = '';
  fname: String = '';
  szBuffer:  String = '';
  szUddFileName: String = '';
  szVicPluginPath: String = '';
  szVicPluginRealPath: String = '';
  szPlugInName: String = '';

  hImportThread: THandle = 0;
  dwAddrPointE: DWORD = 0;
  dwImageBase: DWORD = 0;
  dwSelectedAddr: DWORD = 0;
  dwStartAddr: DWORD = 0;
  dwEndAddr: DWORD = 0;
  dwPane: DWORD = 0;

  bOllyMoving: Boolean = False;
  bSubClass: Boolean = False;
  bDelAllUdd: Boolean = False;
  bDelCurrentUdd: Boolean = False;
  iAlpha: Integer = 255;
  fTbShow: T2 = 2;
  fAddressInfo: T2 = 2;
  fAPIMenu: T2 = 2;
  fConfirm: T2 = 2;
  bMaxOD: Boolean = False;
  bMaxMDI: Boolean = True;
  bAntiDebugBits: Boolean = False;
  fImportType: Boolean = True;
  bMapImporting: Boolean = False;

Function  ViC_Transparent(Wnd: THandle; iAlpha: Integer = 255): Boolean; stdcall;
Function  ViC_DelUddData(Pattern: String): Boolean; stdcall;
Function  ViC_GetPathMe: String; stdcall;
Procedure MaximizeMDI(HandleMDI: HWND); stdcall;
Procedure MaximizeOD(HandleOD: HWND); stdcall;
Function  StringToPWideChar(szStr: string; iNewSize: Integer): PWideChar; stdcall;
Function  GetImageBase(HandleBase: DWORD): DWORD; stdcall;
Function  GetModuleBaseAddress(dwPID: DWORD; szModuleName: String): DWORD; stdcall;
Function  SetTextToClipboardA(szText: String): Boolean; stdcall;
procedure SetTextToClipboardW(const Text: PWideChar);stdcall;
Function  GetHexDumpString(dwStart, dwEnd: DWORD): String; stdcall;
Function  SetTextToClipboard(szText: String): Boolean; stdcall;
Function  GetUddDirectory: String; stdcall;
Function  CopyAsmCodeRipped(addr, len: DWORD): String; stdcall;
Function  GetMemoryAddress(ImageBase, AddrSelected: DWORD): DWORD; stdcall;
Function  FPT(dwPID, dwStartAddress: DWORD; arArraySignature: array of Byte; iNextByte: Integer; nType: Byte): DWORD; stdcall;
Function  CheckFlags(Value, Flags: DWORD): Boolean; stdcall;
Procedure DeleteRecentDebuggeeFile; stdcall;
Function  ExitConfirm(hw: HWND): Boolean; stdcall;
Function  GetMemoryTypes(MemSpecial: DWORD): String; stdcall;
Function  FakeFileToRealFile(s: String): String; stdcall;
Function  ExtractApplyUpdate(szAppUpdate: String): Boolean stdcall;
Function  GetCurrentModuleHandle: HMODULE; stdcall;
Function  GetCurrentModuleName: PAnsiChar; stdcall;
Function  GetApplyUpdatePath: String; stdcall;
Function  GetTmpPath: String; stdcall;
Function  CopyDir(const fromDir, toDir: String): Boolean; stdcall;
Function  MoveDir(const fromDir, toDir: String): Boolean; stdcall;
Function  DelDir(dir: String): Boolean; stdcall;
Function  GetHTML(szURL: String): PAnsiChar; stdcall;
Function  IsHostAvailable(szURL: String): Boolean; stdcall;
Function StringToDateTime(s: String): TDateTime; stdcall;
Function  GetModuleHandleExA(Flags: DWORD; Name: PAnsiChar; var Handle: HMODULE): Boolean; stdcall; external KERNEL32 name 'GetModuleHandleExA';
Function  GetModuleHandleExW(Flags: DWORD; Name: PWideChar; var Handle: HMODULE): Boolean; stdcall; external KERNEL32 name 'GetModuleHandleExW';

{$IF __VERSION__ = 1.10}
Procedure GetFileInfo;
Function  GetOllyDbgDir: String;
{$IFEND}
{$IF __VERSION__ = 2.01}
Function  GetSelectionAddress(pdmp: PDump): DWORD; stdcall;
Procedure BypassAntiDebugBit(p_Thread: PThread); stdcall;
{$IFEND}

implementation

Function StringToDateTime(s: String): TDateTime; stdcall;
var MySettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID, MySettings);
  MySettings.DateSeparator := '/';
  MySettings.TimeSeparator := ':';
  MySettings.ShortDateFormat := 'dd/MM/yyyy';
  MySettings.ShortTimeFormat := 'hh:mm';
  Result := SysUtils.StrToDateTime(s, MySettings);
end;

Function IsHostAvailable(szURL: String): Boolean; stdcall;
var
  dwCode: array[0..3] of Char;
  hSession, hFile: HINTERNET;
  dwIndex, dwCodelen: DWORD;
  rCode: String;
begin
  Result := False;
  if (Pos('https://',LowerCase(szURL)) = 0) then
  else if (Pos('http://',LowerCase(szURL)) = 0) then szURL:= 'http://' + szURL;
  hSession:= InternetOpenA(USER_AGENT, INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);
  if (hSession <> NIL) then
  begin
    hFile:= InternetOpenUrlA(hSession,StrToPac(szURL),NIL,0,INTERNET_FLAG_RELOAD,0);
    dwIndex:= 0;
    dwCodeLen:= 10;
    HttpQueryInfo(hFile,HTTP_QUERY_STATUS_CODE,@dwCode,dwCodeLen,dwIndex);
    rCode:= PAnsiChar(@dwCode);
    if (rCode = '200') or (rCode = '302') then Result := True;
    if (Assigned(hFile)) then InternetCloseHandle(hFile);
  end;
  InternetCloseHandle(hSession);
end;

Function GetHTML(szURL: String): PAnsiChar; stdcall;
var
  Buffer: array[0..2*MAXBYTE] of AnsiChar;
  dwCode: array[0..3] of Char;
  hSession, hFile: HInternet;
  dwIndex, dwCodelen, dwRead, dwNumber: DWORD;
  rCode, Str, ResStr: String;
begin
  ResStr:= '';
  if (Pos('http://',LowerCase(szURL)) = 0) then szURL:= 'http://' + szURL;
  hSession:= InternetOpenA(USER_AGENT, INTERNET_OPEN_TYPE_PRECONFIG, NIL, NIL, 0);
  if (hSession <> NIL) then
  begin
    hFile:= InternetOpenUrlA(hSession,StrToPac(szURL),NIL,0,INTERNET_FLAG_RELOAD,0);
    dwIndex:= 0;
    dwCodeLen:= 10;
    HttpQueryInfo(hFile,HTTP_QUERY_STATUS_CODE,@dwCode,dwCodeLen,dwIndex);
    rCode:= PAnsiChar(@dwCode);
    dwNumber:= SizeOf(Buffer) - 1;
    if (rCode = '200') or (rCode = '302') then
    begin
      while (InternetReadfile(hFile,@Buffer,dwNumber,dwRead)) do
      begin
        if (dwRead = 0) then Break;
        Buffer[dwRead]:= #0;
        Str:= PAnsiChar(@Buffer);
        ResStr:= ResStr + Str;
      end;
    end;
    if (Assigned(hFile)) then InternetCloseHandle(hFile);
  end;
  InternetCloseHandle(hSession);
  Result:= StrToPac(ResStr);
end;

Function CopyDir(const fromDir, toDir: String): Boolean; stdcall;
var fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_MULTIDESTFILES;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

Function MoveDir(const fromDir, toDir: String): Boolean; stdcall;
var fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_MULTIDESTFILES;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

Function DelDir(dir: String): Boolean; stdcall;
var fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

Function GetHexDumpString(dwStart, dwEnd: DWORD): String; stdcall;
var
  i, dwSize: DWORD;
  HexBuffer: array of Byte;
begin
  Result:= '';

  dwSize:= dwEnd - dwStart;

  if (dwSize = 0) then Exit;

  SetLength(HexBuffer,dwSize);

  ReadMemory(@HexBuffer[0],dwStart,dwSize,MM_SILENT);

  for i:= 0 to (dwSize - 1) do
    Result:= Result + fm('%.2X ',[HexBuffer[i]]);
end;

{$IF __VERSION__ = 1.10}
Procedure GetFileInfo;
begin
  fpath:= PacToStr(PAnsiChar(PluginGetValue(VAL_EXEFILENAME)));
  if (fpath = '') then fpath:= GetModuleName(hODbgMdl);
  fdir:= ExtractFileDir(fpath) + '\';
  fname:= ExtractFileName(fpath);
end;

Function GetOllyDbgDir: String; stdcall;
begin
  Result:= ExtractFileDir(GetModuleName(hODbgMdl)) + '\';
end;
{$IFEND}
{$IF __VERSION__ = 2.01}
Function GetSelectionAddress(pdmp: PDump): DWORD; stdcall;
var
  hClipbrd: HGLOBAL;
  p_Global: Pointer;
  szAddr: ShortString;
begin
  try
    hClipbrd:= CopyDumpSelection(pdmp,CDS_NOGRAPH);
    p_Global:= GlobalLock(hClipbrd);
    szAddr:= Copy(WideCharToString(p_Global),1,8);
    GlobalUnlock(hClipbrd);
    Result:= HexToInt(szAddr);
  except
    Result:= 0;
    Exit;
  end;
end;

Procedure BypassAntiDebugBit(p_Thread: PThread); stdcall;
const
  ZeroValue: Byte = $00;
  ProcessHeapFlag: Byte = $02;
var dwPeb, dwProcessHeap: DWORD;  
begin
  ReadMemory(@dwPeb,p_Thread^.tib + $30,4,MM_SILENT);

  if (dwPeb > $70000000) then
  begin
    WriteMemory(@ZeroValue,dwPeb + $02,1,MM_SILENT); // BeingDebugged flag

    WriteMemory(@ZeroValue,dwPeb + $68,1,MM_SILENT); // NtGlobal flag

    WriteMemory(@dwProcessHeap,dwPeb + $18,4,MM_SILENT); // ProcessHeap

    WriteMemory(@ProcessHeapFlag,dwProcessHeap + $0C,1,MM_SILENT); // ProcessHeap Flag

    //WriteMem(@ZeroValue,dwProcessHeap + $10,1,MM_FAILGUARD); // ProcessHeap Force Flag
  end;
end;
{$IFEND}

Function SetTextToClipboardA(szText: String): Boolean; stdcall;
var
  hClipbrd: HGLOBAL;
  dwSize: DWORD;
begin
  Result:= False;
  if OpenClipboard(hwODbg) then
  begin
    EmptyClipboard;
    dwSize:= Length(szText) + 1;
    if (dwSize <> 0) then
    begin
      hClipbrd:= GlobalAlloc(MEM_COMMIT,dwSize);
      if (hClipbrd <> 0) then
      begin
        memcpy(Pointer(hClipbrd),PAnsiChar(szText),dwSize);
        if (SetClipboardData(CF_TEXT,hClipbrd) <> 0) then Result:= True;
      end;
    end;
    CloseClipboard;
  end;
end;

procedure SetTextToClipboardW(const Text: PWideChar); stdcall;
var
  Count: Integer;
  Handle: HGLOBAL;
  Ptr: Pointer;
begin
  Count:= (Length(Text)+1)*SizeOf(WideChar);
  Handle:= GlobalAlloc(GMEM_MOVEABLE, Count);
  if (Handle = 0) then Exit;
  try
    Ptr:= GlobalLock(Handle);
    Move(PWideChar(Text)^,Ptr^,Count);
    GlobalUnlock(Handle);
    Clipboard.SetAsHandle(CF_UNICODETEXT,Handle);
  except
    GlobalFree(Handle);
    raise;
  end;
end;

Function GetModuleBaseAddress(dwPID: DWORD; szModuleName: String): DWORD; stdcall;
var
  hModuleSnap: HMODULE;
  me32: TModuleEntry32;
begin
  Result:= 0;

  hModuleSnap:= CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwPID);
  if (hModuleSnap = INVALID_HANDLE_VALUE) then
  begin
    //VICMsg('CreateToolhelp32Snapshot::Failure');
    Exit;
  end;

  ZeroMemory(@me32,sizeof(me32));
  me32.dwSize:= sizeof(TModuleEntry32);

  if not Module32First(hModuleSnap,me32) then
  begin
    CloseHandle(hModuleSnap);
    //VICMsg('Module32First::Failure');
    Exit;
  end;

  repeat
    if (PacToStr(PAnsiChar(@me32.szModule)) = szModuleName) then
    begin
      Result:= DWORD(me32.modBaseAddr);
      Break;
    end;
  until not Module32Next(hModuleSnap,me32);

  CloseHandle(hModuleSnap);
end;

Function GetImageBase(HandleBase: DWORD): DWORD; stdcall;
var
  IDH: TImageDosHeader;
  INtH: TImageNtHeaders;
  IOH: TImageOptionalHeader;
begin
  Result:= 0;
  IDH:= PImageDosHeader(HandleBase)^;
  if (IDH.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VICMsg('GetImageBase::IDH::Failure');
    Exit;
  end;
  INtH:= PImageNtHeaders(HandleBase + DWORD(IDH._lfanew))^;
  if (INtH.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VICMsg('GetImageBase::INtH::Failure');
    Exit;
  end;
  IOH:= TImageOptionalHeader(INtH.OptionalHeader);
  Result:= IOH.ImageBase;
end;

Function StringToPWideChar(szStr: string; iNewSize: Integer): PWideChar; stdcall;
var
  pw: PWideChar;
  iSize: integer;
begin
  iSize:= Length(szStr) + 1;
  iNewSize:= 2*iSize;
  pw:= AllocMem(iNewSize);
  MultiByteToWideChar(CP_ACP,0,PAnsiChar(szStr),iSize,pw,iNewSize);
  Result:= pw;
end;

Function FPT(dwPID, dwStartAddress: DWord; arArraySignature: array of Byte; iNextByte: Integer; nType: Byte): DWord; stdcall;
const SIZE_SCAN = $FFFFFF;
var hProcess: THandle;
begin
  hProcess:= OpenProcess(PROCESS_ALL_ACCESS,False,dwPID);
  Result:= VIC.FindPattern(hProcess,dwStartAddress,SIZE_SCAN,arArraySignature);
  if Result = 0 then Exit;
  if (iNextByte > 0) then Result:= Result + DWORD(iNextbyte)
  else Result:= Result - DWORD(0 - iNextByte);
  if (nType = 1) then
  //RPM(hProcess, Result, @Result, 4);
  ReadMemory(@Result, Result, 4, MM_SILENT);
  CloseHandle(hProcess);
end;

Procedure MaximizeMDI(HandleMDI: HWND); stdcall;
var hMDIAct: HWND;
begin
  begin                                                    // In OllyDbg 1.10, MDI Client
    hMDIAct:= SendMessageA(HandleMDI,WM_MDIGETACTIVE,0,0); // not have show in _ODBG_Plugininit
    if (hMDIAct <> 0) then                                 // callback function, return false
      if bMaxMDI then ShowWindow(hMDIAct,SW_SHOWMAXIMIZED);
      // else ShowWindow(hMDIAct,SW_SHOWNORMAL);
  end;
end;

Procedure MaximizeOD(HandleOD: HWND); stdcall;
begin
  begin
    if (HandleOD <> 0) then
      if bMaxOD then ShowWindow(HandleOD,SW_SHOWMAXIMIZED);
      //else ShowWindow(HandleOD,SW_SHOWNORMAL);
  end;
end;

Function ViC_Transparent(Wnd: THandle; iAlpha: Integer = 255): Boolean; stdcall;
type TSetLayeredWindowAttributes = Function(
  hwnd: HWND;
  crKey: COLORREF;
  bAlpha: Byte;
  dwFlags: Longint): LongInt; stdcall;
var
  hUser32: HModule;
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
begin
  Result:= False;
  hUser32:= GetModuleHandleA('user32.dll');
  if (hUser32 <> 0) then
  begin @SetLayeredWindowAttributes:= GetProcAddress(hUser32,'SetLayeredWindowAttributes');
    if (@SetLayeredWindowAttributes <> NIL) then
    begin
      SetWindowLongA(Wnd,GWL_EXSTYLE,GetWindowLongA(Wnd,GWL_EXSTYLE) or WS_EX_LAYERED);
      SetLayeredWindowAttributes(Wnd,0,iAlpha,LWA_ALPHA);
      Result:= True;
    end;
  end;
end;

Function GetUddDirectory: String; stdcall;
var UddDirectory: array[0..MAXPATH] of WideChar;
begin
  Result:= '';

  ZeroMemory(@UddDirectory,sizeof(UddDirectory));

  LoadStrCfg('History','Data directory',UddDirectory,MAXBYTE);

  Result:= WideCharToString(UddDirectory);
end;

Function ViC_DelUddData(Pattern: String): Boolean; stdcall;
var
  TSearch: TSearchRec;
  szPathFolder: String;
const _faReadOnly = 1;
begin
  szPathFolder:= GetUddDirectory;
  if (szPathFolder = '') then
  begin
    Result:= False;
    Exit;
  end;
  FindFirst(szPathFolder + '\' + Pattern,faAnyFile + _faReadOnly,TSearch);
  DeleteFile(szPathFolder + '\' + TSearch.Name);
  while (FindNext(TSearch) = 0) do
  begin
    DeleteFile(szPathFolder + '\' + TSearch.Name);
  end;
  FindClose(TSearch);
  Result:= True;
end;

Function ViC_GetPathMe: String; stdcall;
var
  p_OllyDir: Pointer;
  arrollydir: array[0..MAX_PATH - 1] of Char;
begin
  Result:= '';
  {$IF __VERSION__ = 1.10}
  p_OllyDir:= NIL;
  //...
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  ODData:= GetODData;
  p_OllyDir:= ODData.ollydir;
  {$IFEND}
  if (p_OllyDir = NIL) then
  begin
    VICMsg('OllyDir::Failure');
    Exit;
  end;
  memcpy(@arrollydir,p_OllyDir,MAX_PATH - 1);
  Result:= WideCharToString(PWideChar(@arrollydir)) + '\';
end;

Function SetTextToClipboard(szText: String): Boolean; stdcall;
var
  hClipbrd: HGLOBAL;
  dwSize: DWORD;
begin
  Result:= False;
  try
  if OpenClipboard(hwODbg) then
  begin
    EmptyClipboard;
    dwSize:= Length(szText) + 1;
    if (dwSize <> 0) then
    begin
      hClipbrd:= GlobalAlloc(MEM_COMMIT,dwSize);
      if (hClipbrd <> 0) then
      begin
        memcpy(Pointer(hClipbrd),PAnsiChar(szText),dwSize);
        if (SetClipboardData(CF_TEXT,hClipbrd) <> 0) then Result:= True;
      end;
    end;
    CloseClipboard;
  end;
  except
    DumpExceptionInfomation;
  end;
end;

Function _CopyAsmCodeRipped(addr, len: DWORD): String; stdcall;
var
  declength, cmdlen, pos: DWORD;
  da: TDisasm;
  dec: PByte;
  cmd: Pointer;
begin
  Result:= '';
  try
    if (len = 0) then len:= MAXCMDSIZE;

    cmd:= AllocMem(len + 1);

    ZeroMemory(cmd,len*sizeof(Byte));

    len:= ReadMemory(cmd,addr,len,MM_SILENT or MM_PARTIAL);
    if (len = 0) then Exit;

    ZeroMemory(@da,sizeof(da));

    pos:= 0;
    while (pos < len) do
    begin
      dec:= FindDecode(addr + pos,@declength);
      if (dec <> NIL) and (declength < len) then dec:= NIL;

      cmdlen:= Disasm(Ptr(DWORD(cmd) + pos),MAXCMDSIZE,addr + pos,dec,@da,DA_TEXT,NIL,NIL);
      if (cmdlen = 0) then Exit;

      //VICMsg('%0.8X %s',[da.ip,WideCharToString(da.result)]);
      Result:= Result + #13#10 + WideCharToString(da.result);

      Inc(pos,cmdlen);
    end;

    FreeMem(cmd,len + 1);
  except
    DumpExceptionInfomation;
  end;
end;

Function CopyAsmCodeRipped(addr, len: DWORD): String; stdcall;
var
  declength, cmdlen, pos: DWORD;
  da: TDisasm;
  dec: PByte;
  cmd: Pointer;
begin
  Result:= '';
  
  try
    if (len = 0) then len:= MAXCMDSIZE;

    cmd:= AllocMem(len + 1);

    ZeroMemory(cmd,len*sizeof(Byte));
  
    len:= ReadMemory(cmd,addr,len,MM_SILENT or MM_PARTIAL);
    if (len = 0) then Exit;

    ZeroMemory(@da,sizeof(da));

    pos:= 0;
    while (pos < len) do
    begin
      dec:= FindDecode(addr + pos,@declength);
      if (dec <> NIL) and (declength < len) then dec:= NIL;

      cmdlen:= Disasm(Ptr(DWORD(cmd) + pos),MAXCMDSIZE,addr + pos,dec,@da,DA_TEXT,NIL,NIL);
      if (cmdlen = 0) then Exit;

      //VICMsg('%0.8X %s (%0.8X) (%0.8X)',[da.ip,WideCharToString(da.result),da.memconst,da.jmpaddr]);

      Inc(pos,cmdlen);
    end;

    SetTextToClipboardA(Result);

    FreeMem(cmd,len + 1);
  except
    DumpExceptionInfomation;
  end;
end;

Function GetMemoryAddress(ImageBase, AddrSelected: DWORD): DWORD; stdcall;
var
  da: TDisasm;
  len: Integer;
  addr: DWORD;
  cmd: array[0..MAXCMDSIZE] of Byte;
begin
  Result:= 0;
  try
    ZeroMemory(@cmd,sizeof(cmd));

    len:= ReadMemory(@cmd,dwSelectedAddr,MAXCMDSIZE,MM_SILENT or MM_PARTIAL);
    if (len = 0) then Exit;

    Disasm(@cmd,MAXCMDSIZE,dwSelectedAddr,NIL,@da,DA_TEXT,NIL,NIL);

    //VICMsg('%0.8X %s (%0.8X) (%0.8X) ImageBase(%0.8X)',[da.ip,WideCharToString(da.result),da.memconst,addr,ImageBase]);
    //VICMsg('%0.8X %0.8X %0.8X',[da.op[0].opconst,da.op[1].opconst,da.op[2].opconst]);

    if (da.memconst >= ImageBase) then
    begin
      addr:= da.memconst;
    end
    else
    if (da.op[0].opconst >= ImageBase) then
    begin
      addr:= da.op[0].opconst;  
    end
    else
    if (da.op[1].opconst >= ImageBase) then
    begin
      addr:= da.op[1].opconst;
    end
    else
    if (da.op[2].opconst >= ImageBase) then
    begin
      addr:= da.op[2].opconst;
    end
    else
    begin
      addr:= HexToInt(WideCharToString(da.op[0].text));
      if (addr < ImageBase) then
      begin
        addr:= 0;
      end
    end;

    Result:= addr;
  except
    DumpExceptionInfomation;
  end;
end;

Function CheckFlags(Value, Flags: DWORD): Boolean; stdcall;
begin
  Result:= Flags and not Value = 0;
end;

Function GetMemoryTypes(MemSpecial: DWORD): String; stdcall;
begin
  Result:= '';
  {
  //if (CheckFlags(MemSpecial,MEM_ANYMEM) = True) then Result:= Result + '' + ' |';
  //if (CheckFlags(MemSpecial,MEM_CODE) = True) then Result:= Result + '' + ' |';
  //if (CheckFlags(MemSpecial,MEM_DATA) = True) then Result:= Result + '' + ' |';
  if (CheckFlags(MemSpecial,MEM_SFX) = True) then Result:= Result + 'self-extractor' + ' |';
  if (CheckFlags(MemSpecial,MEM_IMPDATA) = True) then Result:= Result + 'import' + ' |';
  if (CheckFlags(MemSpecial,MEM_EXPDATA) = True) then Result:= Result + 'export' + ' |';
  if (CheckFlags(MemSpecial,MEM_RSRC) = True) then Result:= Result + 'resource' + ' |';
  if (CheckFlags(MemSpecial,MEM_RELOC) = True) then Result:= Result + 'reloc' + ' |';
  if (CheckFlags(MemSpecial,MEM_STACK) = True) then Result:= Result + 'stack' + ' |';
  if (CheckFlags(MemSpecial,MEM_STKGUARD) = True) then Result:= Result + 'Guarding-stack' + ' |';
  //if (CheckFlags(MemSpecial,MEM_THREAD) = True) then Result:= Result + '' + ' |';
  if (CheckFlags(MemSpecial,MEM_HEADER) = True) then Result:= Result + 'coff-header' + ' |';
  if (CheckFlags(MemSpecial,MEM_DEFHEAP) = True) then Result:= Result + 'default-heap' + ' |';
  if (CheckFlags(MemSpecial,MEM_HEAP) = True) then Result:= Result + 'heap' + ' |';
  if (CheckFlags(MemSpecial,MEM_NATIVE) = True) then Result:= Result + 'native' + ' |';
  if (CheckFlags(MemSpecial,MEM_GAP) = True) then Result:= Result + 'free' + ' |';
  //if (CheckFlags(MemSpecial,MEM_SECTION) = True) then Result:= Result + '' + ' |';
  if (CheckFlags(MemSpecial,MEM_GUARDED) = True) then Result:= Result + 'guarded' + ' |';
  if (CheckFlags(MemSpecial,MEM_TEMPGUARD) = True) then Result:= Result + 'temporarily-guarded';
  }

  if (CheckFlags(MemSpecial,MSP_NONE) = True) then Result:= Result + 'unknown' + '|';
  if (CheckFlags(MemSpecial,MSP_PEB) = True) then Result:= Result + 'peb' + '|';
  if (CheckFlags(MemSpecial,MSP_SHDATA) = True) then Result:= Result + 'user-shared-data' + '|';
  if (CheckFlags(MemSpecial,MSP_PROCPAR) = True) then Result:= Result + 'parameters' + '|';
  if (CheckFlags(MemSpecial,MSP_ENV) = True) then Result:= Result + 'environment' + '|';
  Result[Length(Result)]:= Chr(0);
end;

Procedure DeleteRecentDebuggeeFile; stdcall;
const
  HISTORY_SECTION: PWideChar = 'History';
  EXECUTABLE_KEY: String = 'Executable[%d]';
  ARGUMENTS_KEY: String = 'Arguments[%d]';
  CURRENTDIR_KEY: String = 'Current dir[%d]';
var
  i, ret: Integer;
  Buffer: array[0..MAXBYTE] of WideChar;
begin
  if (MessageBoxW(
    hwODbg,
    'Are you sure to delete recent debuggee files?',
    PLUGIN_NAME,
    MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = IDNO) then Exit;

  for i:= 0 to 5 do
  begin
    ZeroMemory(@Buffer,sizeof(Buffer));
    ret:= LoadStrCfg(HISTORY_SECTION,StringToOleStr(Format(EXECUTABLE_KEY,[i])),Buffer,MAXBYTE);
    if (ret <> 0) then FileSaveCfg(StringToOleStr(Format(EXECUTABLE_KEY,[i])),'');
    ret:= LoadStrCfg(HISTORY_SECTION,StringToOleStr(Format(ARGUMENTS_KEY,[i])),Buffer,MAXBYTE);
    if (ret <> 0) then FileSaveCfg(StringToOleStr(Format(ARGUMENTS_KEY,[i])),'');
    ret:= LoadStrCfg(HISTORY_SECTION,StringToOleStr(Format(CURRENTDIR_KEY,[i])),Buffer,MAXBYTE);
    if (ret <> 0) then FileSaveCfg(StringToOleStr(Format(CURRENTDIR_KEY,[i])),'');
  end;

  MessageBoxW(hwODbg,'Deleted recent debuggee files!',PLUGIN_NAME,MB_ICONINFORMATION);
end;

Function ExitConfirm(hw: HWND): Boolean; stdcall;
begin
  ODData:= GetODData;
  if (ODData.process = 0) then
  begin
    Result:= True;
    Exit;
  end;
  if (MessageBoxW(
    hw,
    'Debugging in a session. Do you want to exit?',
    PLUGIN_NAME,
    MB_ICONQUESTION or MB_OKCANCEL) = IDOK) then Result:= True
  else Result:= False;
end;

Function FakeFileToRealFile(s: String): String; stdcall;
var szRealFileName: String;
begin
  szRealFileName := s;
  if (UpperCase(ExtractFileExt(s)) = '.D-L-L') then szRealFileName:= ChangeFileExt(s, '.dll')
  else if (UpperCase(ExtractFileExt(s)) = '.E-X-E') then szRealFileName:= ChangeFileExt(s, '.exe');
  Result := szRealFileName;
  szVicPluginRealPath:= OLLYDBG_PLUGIN_DIR + '\' + Result;
  szVicPluginPath:= OLLYDBG_PLUGIN_DIR + '\' + Result;
end;

Function GetCurrentModuleHandle: HMODULE; stdcall;
var hMod: HMODULE;
const GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = $00000004;
begin
  Result:= 0;
  if not GetModuleHandleExA(
    GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
    @GetCurrentModuleHandle,
    hMod
  ) then Exit;
  Result := hMod;
end;

Function GetCurrentModuleName: PAnsiChar; stdcall;
var lpFileName: array[0..MAXPATH] of Char;
begin
  ZeroMemory(@lpFileName, MAXPATH);
  if GetModuleFileNameA(GetCurrentModuleHandle, lpFileName, MAXPATH) <> 0 then
  Result := StrToPac(ExtractFileName(StrPas(lpFileName)))
  else Result := '';
end;

Function ExtractApplyUpdate(szAppUpdate: String): Boolean stdcall;
var
  hLib: HMODULE;
  rs: TResourceStream;
  fs: TFileStream;
begin
  Result:= False;
  try
    hLib := GetCurrentModuleHandle;
    if (hLib = 0) then Exit;

    rs := TResourceStream.Create(hLib, 'APPLYUPDATE', RT_RCDATA);
    if (rs = NIL) then
    begin
      FreeLibrary(hLib);
      Exit;
    end;

    fs := TFileStream.Create(szAppUpdate, fmCreate);
    fs.CopyFrom(rs, 0);
    fs.Free;

    rs.Free;
    FreeLibrary(hLib);

    if not FileExists(szAppUpdate) then Exit;
  except
    Exit;
  end;
  Result := True;
end;

Function GetApplyUpdatePath: String; stdcall;
var lpTempPath: array[0..MAXPATH] of Char;
const APPLYUPDATE: String = 'ApplyUpdate.exe';
begin
  ZeroMemory(@lpTempPath, MAXPATH);
  GetTempPath(MAXPATH, lpTempPath);
  Result := StrPas(lpTempPath) + APPLYUPDATE;
end;

Function ExtractApplyUpdate2: Boolean stdcall;
var
  hLib: HMODULE;
  hRes: HRSRC;
  hGlo: HGLOBAL;
  //size: DWORD;
  pData: Pointer;
begin
  Result:= False;
  GetCurrentModuleName;

  hLib := GetCurrentModuleHandle;
  if (hLib = 0) then
  begin
    VICMsg('LoadLibrary -> FAILED');
    Exit;
  end;

  hRes := FindResource(hLib, 'APPLYUPDATE', RT_RCDATA);
  if (hRes = 0) then
  begin
    VICMsg('FindResource -> FAILED');
    Exit;
  end;

  //size := SizeofResource(hLib, hRes);

  hGlo := LoadResource(hLib, hRes);
  if (hGlo = 0) then
  begin
    VICMsg('LoadResource -> FAILED');
    Exit;
  end;

  pData := LockResource(hGlo);
  if (pData = NIL) then
  begin
    VICMsg('LockResource -> FAILED');
    Exit;
  end;

  Result:= True;
end;

Function GetTmpPath: String; stdcall;
var lpPath: array[0..MAXPATH] of Char;
begin
  Result := '';
  ZeroMemory(@lpPath, MAXPATH);
  if GetTempPath(MAXPATH, lpPath) = 0 then Exit;
  Result := StrPas(lpPath);
end;

end.
