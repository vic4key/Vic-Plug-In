unit uEventBD;

interface

uses Windows, Messages, SysUtils, Plugin;

Function fcEVMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;

const
  EvMenu: array[0..4] of TMenu =
  (
    (name: 'Follow'; help: NIL; shortcutid: K_NONE; menucmd: fcEVMenu; submenu: NIL; index: 1),
    (name: '|>STANDARD'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 2),
    (name: '>FULLCOPY'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 3),
    (name: '>APPEARANCE'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 4),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  { This is pattern to find vmtSelfPtr
  
  CPU Disasm
  Address   Hex dump           Command
  00402C44  |.  8B15 3C634000  mov edx,dword ptr ds:[CB-Sty-R.off_40633C]
  00402C4A  |.  E8 07240000    call CB-Sty-R.Vcl::Forms::TApplication::CreateForm(System::TMetaClass*,void*)
  00402C4F  |.  A1 9CA54000    mov eax,dword ptr ds:[<&vcl200_bpl.Vcl::Forms::Application>]
  00402C54  |.  8B00           mov eax,dword ptr ds:[eax]
  00402C56  |.  E8 F5230000    call CB-Sty-R.Vcl::Forms::TApplication::Run(void)

  8B 15 ?? ?? ?? ?? E8 ?? ?? ?? ?? A1 ?? ?? ?? ?? 8B 00
  +2
  }

  aPatternSelfPtr: array[1..18] of Byte = ($8B,$15,$00,$00,$00,$00,$E8,$00,$00,$00,$00,$A1,$00,$00,$00,$00,$8B,$00);
  dPatternSelfPtr: DWORD = 2;

type
  TMethodHeader = packed record
    Size: WORD;
    Entry: DWORD;
    Len: BYTE;
    Name: array[0..MAXBYTE] of Char;
  end;

  PMethodTable = ^TMethodTable;
  TMethodTable = packed record
    Count: WORD;
    Data: record end;
  end;

  PVmt = ^TVmt;
  TVmt = packed record
    SelfPtr           : TClass;
    IntfTable         : Pointer;
    AutoTable         : Pointer;
    InitTable         : Pointer;
    TypeInfo          : Pointer;
    FieldTable        : Pointer;
    MethodTable       : PMethodTable;
    DynamicTable      : Pointer;
    ClassName         : PShortString;
    InstanceSize      : PLongint;
    {
    Parent            : PClass;
    SafeCallException : PSafeCallException;
    AfterConstruction : PAfterConstruction;
    BeforeDestruction : PBeforeDestruction;
    Dispatch          : PDispatch;
    DefaultHandler    : PDefaultHandler;
    NewInstance       : PNewInstance;
    FreeInstance      : PFreeInstance;
    Destroy           : PDestroy;
    UserDefinedVirtuals: array[0..999] of procedure;
    }
  end;

  _EV_DATA = packed record
    line: DWORD;
    size: DWORD;
    types: DWORD;
    eip: DWORD;
    address: DWORD;
    name: array[0..MAXBYTE] of WideChar;
    labell: array[0..MAXBYTE] of WideChar;
    comment: array[0..MAXBYTE] of WideChar;
  end;
  TEVData = _EV_DATA;
  PEVData = ^TEVData;

  TSubSystem = (
    NATIVE      = $0001,
    WINDOWS_GUI = $0002,
    WINDOWS_CUI = $0003,
    OS2_CUI     = $0005,
    POSIX_CUI   = $0007,
    SS_UNKNOWN  = $FFFF
  );

Procedure InitEVMDIWindow; stdcall;
Function InitEVSortedData: Boolean; stdcall;
Procedure OpenEVWindow; stdcall;
Function  DetermineSubSystem: Boolean; stdcall;

Procedure DestroyEVSortedData; stdcall;
Function  EVSortFunc(const pPrevSh, pNextSh: PSortHdr; const iColumn: Integer): Integer; cdecl;
Procedure EVDestFunc(pSh: PSortHdr); cdecl;

var
  evTable: TTable;
  evData: TEVData;

implementation

uses uFcData, mrVic;

Function DetermineSubSystem: Boolean; stdcall;
var
  hLib: HMODULE;
  DH: TImageDosHeader;
  NtH: TImageNtHeaders;
begin
  Result := False;

  hLib := FindMainModule.base;
  if (hLib = 0) then Exit;

  ZeroMemory(@DH, sizeof(DH));
  ReadMemory(@DH, hLib, sizeof(DH), MM_SILENT);

  ZeroMemory(@NtH, sizeof(NtH));
  ReadMemory(@NtH, hLib + DWORD(DH._lfanew), sizeof(NtH), MM_SILENT);
  
  Result := (TSubSystem(NtH.OptionalHeader.Subsystem) = WINDOWS_GUI);
end;

Function fcEVMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var
  ret: Integer;
  pEV: PEVData;
begin
  ret:= MENU_ABSENT;
  case iMode of
    MENU_VERIFY:
    begin
      case dwIndex of
        1:
        begin
          if (pT^.hw = evTable.hw) then
          begin
            if (GetSortedByIndex(@evTable.sorted,0) = NIL) then
            begin
              Result:= MENU_ABSENT;
              Exit;
            end;
          end;
        end;  
      end;
      ret:= MENU_NORMAL;
    end;
    MENU_EXECUTE:
    begin
      ret:= MENU_NOREDRAW;
      case dwIndex of
        1: // Follow
        begin
          pEV:= PEVData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
          if (pEV = NIL) then
          begin
            StatusFlash('%s: Follow fail',PLUGIN_NAME);
            Result:= ret;
            Exit;
          end;
          SetCPU(0,pEV^.address,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
        end;
      end;
    end;
  end;
  Result:= ret;
end;

Function EvWndProc(pT: PTable; hw: HWND; uiMsg: UInt; wPr: WPARAM; lPr: LPARAM): Integer; cdecl;
var
  ret: DWORD;
  pEV: PEVData;
begin
  ret:= 0;
  case uiMsg of
    WM_USER_CREATE:
    begin
      SetAutoUpdate(@evTable,1);
    end;
    WM_USER_UPD:
    begin
      UpdateTable(@evTable,1);
    end;
    WM_CLOSE:
    begin
      DestroyEVSortedData;
    end;
    WM_USER_DBLCLK:
    begin
      pEV:= PEVData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
      if (pEV = NIL) then
      begin
        StatusFlash('%s: Follow failed',PLUGIN_NAME);
        Result:= ret;
        Exit;
      end;
      SetCPU(0,pEV^.address,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
    end;
  end;
  Result:= ret;
end;

Function EvWndDraw(pWc: PWideChar; pMask: PByte; piSelect: PInteger; pT: PTable; pDh: PDrawHeader; iColum: Integer; pCache: Pointer): Integer; cdecl;
var
  ret: Integer;
  pev: PEVData;
begin
  ret:= 0;

  pev:= PEVData(pDh);
  if (pev = NIL) then
  begin
    Result:= ret;
    Exit;
  end;
  
  case iColum of
    DF_CACHESIZE:
    begin
      //...
    end;
    DF_FILLCACHE, DF_FREECACHE:
    begin
      //...
    end;
    DF_NEWROW:
    begin
      //...
    end;
    0: // Address
    begin
      ret:= StrCopyW(pWc,9,StringToOleStr(Format('%0.8X',[pev^.address])));
    end;
    1: // Name
    begin
      ret:= StrCopyW(pWc,lstrlenW(pev^.name) + 1,StringToOleStr(pev^.name));
    end;
    2: // Label
    begin
      ret:= StrCopyW(pWc,lstrlenW(pev^.labell) + 1,StringToOleStr(pev^.labell));
    end;
    3: // Comment
    begin
      ret:= StrCopyW(pWc,lstrlenW(pev^.comment) + 1,StringToOleStr(pev^.comment));
    end;
  end;

  Result:= ret;
end;

Procedure InitEVMDIWindow; stdcall;
begin
  ZeroMemory(@evTable,sizeof(evTable));

  StrCopyW(evTable.name,SHORTNAME,PLUGIN_NAME);

  evTable.bar.name[0]:= 'Address';
  evTable.bar.expl[0]:= 'Event address';
  evTable.bar.mode[0]:= BAR_SORT;
  evTable.bar.defdx[0]:= 9;

  evTable.bar.name[1]:= 'Name';
  evTable.bar.expl[1]:= 'Event Name';
  evTable.bar.mode[1]:= BAR_SORT;
  evTable.bar.defdx[1]:= 50;

  evTable.bar.name[2]:= 'Label';
  evTable.bar.expl[2]:= 'Event Label';
  evTable.bar.mode[2]:= BAR_SORT;
  evTable.bar.defdx[2]:= 50;

  evTable.bar.name[3]:= 'Comment';
  evTable.bar.expl[3]:= 'Event Comment';
  evTable.bar.mode[3]:= BAR_SORT;
  evTable.bar.defdx[3]:= MAXBYTE;

  evTable.mode:= TABLE_SAVEALL;
  evTable.bar.visible:= 1;
  evTable.bar.nbar:= 4;
  evTable.custommode:= 0;
  evTable.customdata:= NIL;
  evTable.menu:= @EvMenu;
  evTable.tableselfunc:= NIL;
  evTable.updatefunc:= NIL;
  evTable.drawfunc:= @EvWndDraw;
  evTable.tabfunc:= @EvWndProc;
end;

Procedure DestroyEVSortedData; stdcall;
begin
  DestroySortedData(@evTable.sorted);
end;

Function EVSortFunc(const pPrevSh, pNextSh: PSortHdr; const iColumn: Integer): Integer; cdecl;
var
  ret: Integer;
  prev, next: PEVData;
begin
  ret:= 0;

  prev:= PEVData(pPrevSh);
  next:= PEVData(pNextSh);

  case iColumn of
    0: // Address
    begin
      if (prev^.address < next^.address) then
      begin
        ret:= -1;
      end
      else
      if (prev^.address > next^.address) then
      begin
        ret:= 1;
      end
    end;
    1: // Label
    begin
      if (lstrcmpW(prev^.name,next^.name) = -1) then
      begin
        ret:= -1;
      end
      else
      if (lstrcmpW(prev^.name,next^.name) = 1) then
      begin
        ret:= 1;
      end
    end;
    2: // Label
    begin
      if (lstrcmpW(prev^.labell,next^.labell) = -1) then
      begin
        ret:= -1;
      end
      else
      if (lstrcmpW(prev^.labell,next^.labell) = 1) then
      begin
        ret:= 1;
      end
    end;
    3: // Comment
    begin
      if (lstrcmpW(prev^.comment,next^.comment) = -1) then
      begin
        ret:= -1;
      end
      else
      if (lstrcmpW(prev^.comment,next^.comment) = 1) then
      begin
        ret:= 1;
      end
    end;
  end;

  Result:= ret;
end;

Procedure EVDestFunc(pSh: PSortHdr); cdecl;
begin
  // ...
end;

Function InitEVSortedData: Boolean; stdcall;
var
  pmmod: PModule;
  psec: PSectHdr;
  vmt: TVmt;
  MT: TMethodTable;
  MH: TMethodHeader;
  NextSize: WORD;
  i, dwSelfPtr, NextEntry: DWORD;
begin
  Result := False;
  try
    if (CreateSortedData(@evTable.sorted,sizeof(evData),100,@EVSortFunc,@EVDestFunc,0) <> 0) then
    begin
      StatusFlash('%s: Initialize CB/D VCL Event Data failured',PLUGIN_NAME);
      Exit;
    end;

    ODData:= GetODData;
    if (ODData.process = 0) then
    begin
      StatusFlash('No Debuggee');
      Exit;
    end;

    dwSelfPtr := 0;
    ZeroMemory(@vmt, sizeof(vmt));
    ZeroMemory(@MT, sizeof(MT));

    pmmod := FindMainModule;
    if (pmmod = NIL) then
    begin
      StatusFlash('Failed, no main module!');
      Exit;
    end;
  
    if (pmmod.entry <> 0) then
    begin
      ODData := GetODData;
      if (ODData.processid = 0) then Exit;
      dwSelfPtr := FPT(ODData.processid, pmmod.entry, aPatternSelfPtr, dPatternSelfPtr, 1); // Find start from OEP
      if (dwSelfPtr <> 0) then // Not found then find in .itext section
      begin
        psec:= pmmod.sect;
        for i := 0 to pmmod.nsect - 1 do
        begin
          if (lstrcmpW(psec.sectname, '.itext') = 0) then
          begin
            dwSelfPtr := FPT(ODData.processid, psec.base, aPatternSelfPtr, dPatternSelfPtr, 1);
            if (dwSelfPtr <> 0) then break;
          end;
          Inc(psec);
        end;
      end;
    end;

    // Find from OEP and .itext section not found then find allmodule
    if (dwSelfPtr = 0) then dwSelfPtr := FPT(ODData.processid, pmmod.base, aPatternSelfPtr, dPatternSelfPtr, 1);
    if (dwSelfPtr = 0) then
    begin
      //StatusFlash('Sorry, nothing here. Maybe this is not a Delphi/C++ Builder application');
      MessageBoxW(
        hwODbg,
        'Sorry, found nothing here! Maybe your target is not a C++ Builder / Delphi VCL GUI application or it has packed/protected!' + DCRLF +
        'Note: Recommend you should:' + CRLF +
        '1. Disable or Delete all active INT3 breakpoints' + CRLF +
        '2. First run if your target has packed/protected' + CRLF +
        'and try again!',
        PLUGIN_NAME,
        MB_ICONWARNING);
      Exit;
    end;

    {
    CPU Disasm
    Address   Hex dump            Command                   Comments
    0052A694      08              db 08                     ; Backspace
    0052A695      00              db 00

    0052A696      12              db 12
    0052A697      00              db 00
    0052A698   .  C8A75200        dd _____.0052A7C8
    0052A69C      0B              db 0B
    0052A69D   .  43 6C 6F 73 65  ascii "Close1Click)",0    ; ASCII "Close1Click)"
    0052A6AA   .  D0A75200        dd _____.0052A7D0
    0052A6AE   .  22              db 22
    0052A6AF   .  73 70 44 79 6E  ascii "spDynamicSkinFor"  ; ASCII "spDynamicSkinForm1CaptionTabChange"
    0052A6BF   .  6D 31 43 61 70  ascii "m1CaptionTabChan"
    0052A6CF   .  67 65           ascii "ge"

    0052A6D1      11              db 11
    0052A6D2      00              db 00
    0052A6D3   .  00A85200        dd _____.0052A800         ; Entry point
    0052A6D7   .  0A              db 0A
    0052A6D8   .  46 6F 72 6D 43  ascii "FormCreate"        ; ASCII "FormCreate"
    }

    {$IF __VERSION__ = 1.10}
    { Nothing here }
    {$IFEND}
    {$IF __VERSION__ = 2.01}
    ReadMemory(@vmt, dwSelfPtr, sizeof(vmt), MM_SILENT);
    ReadMemory(@MT, DWORD(vmt.MethodTable), sizeof(MT), MM_SILENT);
    //VICBox('SelfPtr = %08X, MethodTable = %08X, Mt.count = %d', [DWORD(vmt.SelfPtr), DWORD(vmt.MethodTable), MT.Count]);
    NextEntry:= DWORD(vmt.MethodTable) + sizeof(MT.Count);
    ReadMemory(@NextSize, NextEntry, sizeof(NextSize), MM_SILENT);
    ZeroMemory(@MH, sizeof(MH));
    for i := 0 to MT.Count - 1 do
    begin
      StatusProgress((i + 1) * (1000 div MT.Count), 'Processing...');

      ZeroMemory(@MH, sizeof(MH));
      ReadMemory(@MH, NextEntry, NextSize, MM_SILENT);
      MH.Name[MH.Len] := Chr(0);
      
      Inc(NextEntry, MH.Size);
      ReadMemory(@NextSize, NextEntry, sizeof(NextSize), MM_SILENT);

      ZeroMemory(@evData, sizeof(evData));
      evData.line:= i;
      evData.size:= 1;
      evData.address:= MH.Entry;
      StrCopyW(@evData.name,MAXBYTE,StringToOleStr(MH.Name));
      FindNameW(MH.Entry,NM_LABEL,evData.labell,sizeof(evData.labell));
      FindNameW(MH.Entry,NM_COMMENT,evData.comment,sizeof(evData.comment));
      
      AddSortedData(@evTable.sorted,@evData);
    end;
    StatusProgress(0, NIL);
    AddToLog(0, DRAW_HILITE, '%s: Found %d event(s)', PLUGIN_NAME, MT.Count);
    {$IFEND}
    Result := True;
  except
    StatusFlash('Open CB/D VCL GUI Event window failed');
    DumpExceptionInfomation;
  end;
end;

Procedure OpenEVWindow; stdcall;
const LABEL_WINDOW_CAPTION: PWideChar = 'CB/D VCL GUI Events';
var Buffer: array[0..MAXBYTE] of WideChar;
begin
  if not InitEVSortedData then Exit;
  try
    ZeroMemory(@Buffer,sizeof(Buffer));
    //Swprintf(@Buffer,'%s, module %s',LABEL_WINDOW_CAPTION,FindMainModule.modname);
    Swprintf(@Buffer,'%s',LABEL_WINDOW_CAPTION);
    if (evTable.hw = 0) then
    begin
      if (CreateTableWindow(@evTable,0,evTable.bar.nbar,0,'ICO_PLUGIN',Buffer) = 0) then
      begin
        StatusFlash('%s: CB/D VCL GUI Event Window create failed',PLUGIN_NAME);
      end;
    end else ActivateTableWindow(@evTable);
  except
    Exit;
  end;
end;

end.
