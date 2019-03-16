unit uLC;

interface

uses Windows, Messages, SysUtils, uFcData, Plugin, mrVic, uMapMain;

Function fcLCMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;

const
  LLCMenu: array[0..10] of TMenu =
  (
    (name: 'Follow'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 1),
    (name: 'Refresh'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 2),
    (name: '|Delete'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 3),
    (name: 'Delete all'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 4),
    (name: '|Import'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 5),
    (name: 'Export'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 6),
    (name: '|Find'; help: NIL; shortcutid: K_NONE; menucmd: fcLCMenu; submenu: NIL; index: 7),
    (name: '|>STANDARD'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 8),
    (name: '>FULLCOPY'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 9),
    (name: '>APPEARANCE'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 10),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

type
  _LC_DATA = packed record
    line: DWORD;
    size: DWORD;
    types: DWORD;
    eip: DWORD;
    address: DWORD;
    command: array[0..MAXCMDSIZE] of WideChar;
    lc: array[0..MAXBYTE] of WideChar;
  end;
  TLCData = _LC_DATA;
  PLCData = ^TLCData;

  _LC_MAP_SEC = packed record
    StartIndex: WORD;
    StartOffset: DWORD;
    Length: DWORD;  
    Name: array[0..7] of Char;    
    Classes: array[0..3] of Char; 
  end;
  TLCMapSec = _LC_MAP_SEC;
  PLCMapSec = ^TLCMapSec;

  _LC_MAP_DATA = packed record
    IndexSec: WORD;    // XXXX
    OffsetSec: DWORD;  // XXXXXXXX
    Desc: array[0..MAXBYTE] of Char; // *
  end;
  TLCMapData = _LC_MAP_DATA;
  PLCMapData = ^TLCMapData;

var
  labelTable: TTable;
  commentTable: TTable;
  lcData: TLCData;

  dwSessionAddress: DWORD = 0;

Procedure InitLabelMDIWindow; stdcall;
Procedure InitCommentMDIWindow; stdcall;
Procedure OpenLabelListWindow; stdcall;
Procedure OpenCommentListWindow; stdcall;

implementation

Procedure ImportLCData; stdcall; forward;
Procedure ExportLCData(pTableData: PTable); stdcall; forward;
Procedure FindLCData(pTableData: PTable; str: PWideChar); stdcall; forward;
Procedure InitLabelSortedData; stdcall;forward;
Procedure InitCommentSortedData; stdcall;forward;
Procedure DestroyLabelSortedData; stdcall; forward;
Procedure DestroyCommentSortedData; stdcall; forward;
Function DeleteLCSortedData(pTableData: PTable): Integer; stdcall; forward;

Function fcLCMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var
  countDeleted, ret, len: Integer;
  pLC: PLCData;
begin
  ret:= MENU_ABSENT;
  case iMode of
    MENU_VERIFY:
    begin
      ret:= MENU_NORMAL;
      case dwIndex of
        5, 7: ret := MENU_ABSENT;
        1, 3, 4, 6:
        begin
          if (pT^.hw = labelTable.hw) then
          begin
            if (GetSortedByIndex(@labelTable.sorted,0) = NIL) then ret:= MENU_ABSENT;
          end;
          if (pT^.hw = commentTable.hw) then
          begin
            if (GetSortedByIndex(@commentTable.sorted,0) = NIL) then ret:= MENU_ABSENT;
          end;
        end;  
      end;
      //Result := ret;
    end;
    MENU_EXECUTE:
    begin
      ret:= MENU_NOREDRAW;
      case dwIndex of
        1: // Follow
        begin
          pLC:= PLCData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
          if (pLC = NIL) then
          begin
            StatusFlash('%s: Follow fail',PLUGIN_NAME);
            Result:= ret;
            Exit;
          end;
          SetCPU(0,pLC^.address,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
        end;
        2: // Refresh
        begin
          if (pT^.hw = labelTable.hw) then InitLabelSortedData;
          if (pT^.hw = commentTable.hw) then InitCommentSortedData;
          InvalidateRect(pT^.hw,NIL,True);
        end;
        3: // Delete
        begin
          pLC:= PLCData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
          if (pLC <> NIL) then
          begin
            if (pT^.hw = labelTable.hw) then InsertNameW(pLC^.address,NM_LABEL,'');
            if (pT^.hw = commentTable.hw) then InsertNameW(pLC^.address,NM_COMMENT,'');
            DeleteSortedData(@pT^.sorted,pLC^.line,0);
            InvalidateRect(pT^.hw,NIL,True);
            ret:= MENU_REDRAW;
          end else StatusFlash('%s: Delete fail',PLUGIN_NAME);
        end;
        4: // Delete all
        begin
          if (MessageBoxW(hwODbg,'Are you sure to delete all?',PLUGIN_NAME,MB_ICONQUESTION or MB_OKCANCEL) = IDCANCEL) then
          begin
            Result:= MENU_NORMAL;
            Exit;
          end;

          len:= pT^.sorted.n;
          countDeleted:= DeleteLCSortedData(pT);

          if (pT^.hw = labelTable.hw) then DestroyLabelSortedData;
          if (pT^.hw = commentTable.hw) then DestroyCommentSortedData;
          
          InvalidateRect(pT^.hw,NIL,True);
          
          VICBox('Deleted %d/%d of all',[countDeleted,len]);
        end;
        5: // Import
        begin
          //ImportLCData;
          MessageBoxA(hwODbg, 'This function is not available now!', 'LC', MB_ICONINFORMATION);
        end;
        6: // Export
        begin
          ExportLCData(pT);
        end;
        7: // Find
        begin
          FindLCData(pT,'');
        end;
      end;
    end;
  end;
  Result:= ret;
end;

Procedure FindLCData(pTableData: PTable; str: PWideChar); stdcall;
var
  i: Integer;
  lc: PLCData;
  a, b: String;
begin
  try
    for i:= 0 to pTableData^.sorted.n - 1 do
    begin
      lc:= PLCData(GetSortedByIndex(@pTableData^.sorted,i));
      if (lc = NIL) then Continue;
      a:= WideCharToString(lc.lc);
      b:= WideCharToString(str);
      if (Pos(b,a) = 0) then
      begin
        if (pTableData^.hw = labelTable.hw) then
        begin
          //..
        end;
        if (pTableData^.hw = commentTable.hw) then
        begin
          //..
        end;
      end;
    end;
  except
    DumpExceptionInfomation;
  end;
end;

Procedure ImportLCData; stdcall;
begin
  {try
    frmMapLoader:= TfrmMapLoader.Create(frmMapLoader);
    frmMapLoader.Show;
  except
    Exit;
  end;} 
  VICBox(hwODbg,'Import');
end;

Procedure ExportLCData(pTableData: PTable); stdcall;
var
  i, j, hFile: Integer;
  pmod: PModule;
  psec: PSectHdr;
  lcData: PLCData;
  lcMapData: TLCMapData;
  lcMapSec: TLCMapSec;
  paDesc: PAnsiChar;
  szFilePath: String;
  pwFilePath: array[0..MAX_PATH] of WideChar;
  Buffer: array[0..2*MAXBYTE] of Char;
begin
  ZeroMemory(@pwFilePath,sizeof(pwFilePath));
  szFilePath:= '';
  
  BrowseFileName('Export Map File',pwFilePath,NIL,NIL,'*.map',hwODbg,BRO_SAVE);
  szFilePath:= WideCharToString(PWideChar(@pwFilePath));

  if (szFilePath = '') then Exit;

  pmod:= FindModule(dwSessionAddress);
  //pmod:= FindMainModule;
  if (pmod = NIL) then
  begin
    StatusInfo('%s: Could not find module for address %0.8X',PLUGIN_NAME,dwSessionAddress);
    Exit;
  end;

  if (pTableData^.hw = labelTable.hw) then Insert('.LABEL',szFilePath,Length(szFilePath) - 3);
  if (pTableData^.hw = commentTable.hw) then Insert('.COMMENT',szFilePath,Length(szFilePath) - 3);

  case ConfirmOverWrite(StringToOleStr(szFilePath)) of
    1, 2: hFile:= FileCreate(szFilePath);
    else Exit;
  end;

  if (hFile = -1) then
  begin
    StatusFlash('%s: Could not export map file. Try again.',PLUGIN_NAME);
    Exit;
  end;

  StatusInfo('%s: Map file is exporting...',PLUGIN_NAME);

  try
    ZeroMemory(@Buffer,sizeof(Buffer));
    Sprintf(@Buffer,#13#10' Start         Length     Name                   Class'#13#10);
    FileWrite(hFile,Buffer,lstrlenA(Buffer));

    for j:= 0 to pmod^.nsect - 1 do
    begin
      psec:= PSectHdr(DWORD(pmod^.sect) + DWORD(j)*sizeof(TSectHdr));
      if (psec = NIL) then Continue;
      ZeroMemory(@lcMapSec,sizeof(lcMapSec));
      lcMapSec.StartIndex:= j + 1;
      lcMapSec.StartOffset:= 0;
      lcMapSec.Length:= psec^.size;
      StrCopyA(lcMapSec.Name,lstrlenW(psec^.sectname) + 1,StrToPac(WideCharToString(psec^.sectname)));
      StrCopyA(lcMapSec.Classes,5,'NONE');

      ZeroMemory(@Buffer,sizeof(Buffer));
      Sprintf(@Buffer,' %0.4X:%0.8X %0.8XH %-8s                NONE'#13#10,
        lcMapSec.StartIndex,
        lcMapSec.StartOffset,
        lcMapSec.Length,
        lcMapSec.Name);
        //lcMapSec.Classes);
      FileWrite(hFile,Buffer,lstrlenA(Buffer));
    end;

    ZeroMemory(@Buffer,sizeof(Buffer));
    Sprintf(@Buffer,#13#10'  Address         Publics by Value'#13#10);
    FileWrite(hFile,Buffer,lstrlenA(Buffer));

    for i:= 0 to pTableData^.sorted.n - 1 do
    begin
      ZeroMemory(@lcMapData,sizeof(lcMapData));

      lcData:= GetSortedByIndex(@pTableData^.sorted,i);
      if (lcData = NIL) then Continue;

      for j:= 0 to pmod^.nsect - 1 do
      begin
        psec:= PSectHdr(DWORD(pmod^.sect) + DWORD(j)*sizeof(TSectHdr));
        if (psec = NIL) then Continue;
        if (lcData.address > psec^.base) then
        begin
          lcMapData.IndexSec:= j + 1;
          lcMapData.OffsetSec:= lcData.address - psec^.base;
        end;
      end;
    
      paDesc:= StrToPac(WideCharToString(lcData^.lc));
      StrCopyA(lcMapData.Desc,lstrlenA(paDesc) + 1,paDesc);

      Sprintf(@Buffer,' %0.4X:%0.8X       %-s'#13#10,lcMapData.IndexSec,lcMapData.OffsetSec,lcMapData.Desc);
      FileWrite(hFile,Buffer,lstrlenA(Buffer));
    end;

    ZeroMemory(@lcMapData,sizeof(lcMapData));
    for j:= 0 to pmod^.nsect - 1 do
    begin
      psec:= PSectHdr(DWORD(pmod^.sect) + DWORD(j)*sizeof(TSectHdr));
      if (psec = NIL) then Continue;
      if (pmod^.entry > psec^.base) then
      begin
        lcMapData.IndexSec:= j + 1;
        lcMapData.OffsetSec:= pmod^.entry - psec^.base;
      end;
    end;

    Sprintf(@Buffer,#13#10'Program entry point at %0.4X:%0.8X'#13#10,lcMapData.IndexSec,lcMapData.OffsetSec);
    FileWrite(hFile,Buffer,lstrlenA(Buffer));    
  except
    DumpExceptionInfomation;
    FileClose(hFile);
  end;
  
  FileClose(hFile);

  StatusInfo('%s: Exported map file to ''%s''',PLUGIN_NAME,StringToOleStr(ExtractFileName(szFilePath)));
end;

Function DeleteLCSortedData(pTableData: PTable): Integer; stdcall;
var
  i: Integer;
  lc: PLCData;
begin
  Result:= 0;
  try
    if (pTableData^.sorted.n = 0) then Exit;
    i:= pTableData^.sorted.n - 1;
    repeat
      lc:= PLCData(GetSortedByIndex(@pTableData^.sorted,i));
      if (lc = NIL) then Continue;
      if (pTableData^.hw = labelTable.hw) then InsertNameW(lc^.address,NM_LABEL,'');
      if (pTableData^.hw = commentTable.hw) then InsertNameW(lc^.address,NM_COMMENT,'');
      DeleteSortedData(@pTableData^.sorted,i,0);
      Dec(i);
      Inc(Result);
    until (i < 0);
  except
    DumpExceptionInfomation;
    Result:= 0;
  end;
end;

Function LCSortFunc(const pPrevSh, pNextSh: PSortHdr; const iColumn: Integer): Integer; cdecl;
var
  ret: Integer;
  prev, next: PLCData;
begin
  ret:= 0;

  prev:= PLCData(pPrevSh);
  next:= PLCData(pNextSh);

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
    2: // Labels or Comments
    begin
      if (lstrcmpW(prev^.lc,next^.lc) = -1) then
      begin
        ret:= -1;
      end
      else
      if (lstrcmpW(prev^.lc,next^.lc) = 1) then
      begin
        ret:= 1;
      end
    end;
  end;

  Result:= ret;
end;

Procedure LCDestFunc(pSh: PSortHdr); cdecl;
begin
  // ...
end;

Function LabelWndProc(pT: PTable; hw: HWND; uiMsg: UInt; wPr: WPARAM; lPr: LPARAM): Integer; cdecl;
var
  ret: DWORD;
  pLC: PLCData;
begin
  ret:= 0;
  case uiMsg of
    WM_USER_CREATE:
    begin
      SetAutoUpdate(@labelTable,1);
    end;
    WM_USER_UPD:
    begin
      UpdateTable(@labelTable,1);
    end;
    WM_CLOSE:
    begin
      DestroyLabelSortedData;
    end;
    WM_USER_DBLCLK:
    begin
      pLC:= PLCData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
      if (pLC = NIL) then
      begin
        StatusFlash('%s: Follow failed',PLUGIN_NAME);
        Result:= ret;
        Exit;
      end;
      SetCPU(0,pLC^.address,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
    end;
  end;
  Result:= ret;
end;

Function LabelWndDraw(pWc: PWideChar; pMask: PByte; piSelect: PInteger; pT: PTable; pDh: PDrawHeader; iColum: Integer; pCache: Pointer): Integer; cdecl;
var
  ret, len: Integer;
  plb: PLCData;
  dis: TDisasm;
  cmd: array[0..MAXCMDSIZE] of Byte;
begin
  ret:= 0;

  plb:= PLCData(pDh);
  if (plb = NIL) then
  begin
    Result:= ret;
    Exit;
  end;
  
  case iColum of
    DF_CACHESIZE:
    begin
      ret:= sizeof(TDisasm);
    end;
    DF_FILLCACHE, DF_FREECACHE:
    begin
      //..
    end;
    DF_NEWROW:
    begin
      try
        ZeroMemory(@cmd,sizeof(cmd));
        ZeroMemory(@dis,sizeof(dis));
        len:= ReadMemory(@cmd,plb^.address,sizeof(cmd),MM_SILENT or MM_PARTIAL);
        if (len = 0) then
        begin
          StrcopyW(dis.result,TEXTLEN,'???');
          StrcopyW(dis.comment,TEXTLEN,'');
        end
        else
        begin
          Disasm(@cmd,len,plb^.address,FindDecode(plb^.address,NIL),@dis,DA_TEXT or DA_OPCOMM or DA_MEMORY,NIL,NIL);
        end;
      except
        DumpExceptionInfomation;
      end;
      ret:= 0;
    end;
    0: //  Address
    begin
      ret:= StrCopyW(pWc,9,StringToOleStr(Format('%0.8X',[plb^.address])));
    end;
    1: // Disassembly
    begin
      ret:= StrCopyW(pWc,lstrlenW(dis.result) + 1,dis.result);
    end;
    2: // Labels
    begin
      ret:= StrCopyW(pWc,lstrlenW(plb^.lc) + 1,plb^.lc);
    end;
  end;

  Result:= ret;
end;

Function CommentWndProc(pT: PTable; hw: HWND; uiMsg: UInt; wPr: WPARAM; lPr: LPARAM): Integer; cdecl;
var
  ret: DWORD;
  pLC: PLCData;
begin
  ret:= 0;
  case uiMsg of
    WM_USER_CREATE:
    begin
      SetAutoUpdate(@commentTable,1);
    end;
    WM_USER_UPD:
    begin
      UpdateTable(@commentTable,1);
    end;
    WM_CLOSE:
    begin
      DestroyCommentSortedData;
    end;
    WM_USER_DBLCLK:
    begin
      pLC:= PLCData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
      if (pLC = NIL) then
      begin
        StatusFlash('%s: Follow fail',PLUGIN_NAME);
        Result:= ret;
        Exit;
      end;
      SetCPU(0,pLC^.address,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
    end;
  end;
  Result:= ret;
end;

Function CommentWndDraw(pWc: PWideChar; pMask: PByte; piSelect: PInteger; pT: PTable; pDh: PDrawHeader; iColum: Integer; pCache: Pointer): Integer; cdecl;
var
  ret, len: Integer;
  pcm: PLCData;
  dis: TDisasm;
  cmd: array[0..MAXCMDSIZE] of Byte;
begin
  ret:= 0;

  pcm:= PLCData(pDh);
  if (pcm = NIL) then
  begin
    Result:= ret;
    Exit;    
  end;

  case iColum of
    DF_CACHESIZE:
    begin
      ret:= sizeof(TDisasm);
    end;
    DF_FILLCACHE, DF_FREECACHE:
    begin
      ret:= 0;
    end;
    DF_NEWROW:
    begin
      try
        ZeroMemory(@cmd,sizeof(cmd));
        ZeroMemory(@dis,sizeof(dis));
        len:= ReadMemory(@cmd,pcm^.address,sizeof(cmd),MM_SILENT or MM_PARTIAL);
        if (len = 0) then
        begin
          StrcopyW(dis.result,TEXTLEN,'???');
          StrcopyW(dis.comment,TEXTLEN,'');
        end
        else
        begin
          Disasm(@cmd,len,pcm^.address,FindDecode(pcm^.address,NIL),@dis,DA_TEXT or DA_OPCOMM or DA_MEMORY,NIL,NIL);
        end;
      except
        DumpExceptionInfomation;
      end;
      ret:= 0;
    end;
    0: //  Address
    begin
      ret:= StrCopyW(pWc,9,StringToOleStr(Format('%0.8X',[pcm^.address])));
    end;
    1: // Disassembly
    begin
      ret:= StrCopyW(pWc,lstrlenW(dis.result) + 1,dis.result);
    end;
    2: // Comments
    begin
      ret:= StrCopyW(pWc,lstrlenW(pcm^.lc) + 1,pcm^.lc);
    end;
  end;
  Result:= ret;
end;

Procedure InitLabelSortedData; stdcall;
var
  i, Index, LineCount: DWORD;
  pmod: PModule;
  psec: PSectHdr;
  da: TDisasm;
  crLabel: array[0..MAXBYTE] of WideChar;
  crMem: array[0..MAXCMDSIZE] of Byte;
begin
  try
    if (CreateSortedData(@labelTable.sorted,sizeof(lcData),100,@LCSortFunc,@LCDestFunc,0) <> 0) then
    begin
      StatusFlash('%s: Init Label Data failed',PLUGIN_NAME);
      Exit;
    end;

    ODData:= GetODData;
    if (ODData.process = 0) then
    begin
      StatusFlash('No Debuggee');
      Exit;
    end;

    pmod:= FindModule(dwSessionAddress);
    //pmod:= FindMainModule;
    if (pmod = NIL) then
    begin
      StatusFlash('%s: Could not find module for address %0.8X',PLUGIN_NAME,dwSessionAddress);
      Exit;
    end;

    LineCount:= 0;
    for Index:= 0 to pmod^.nsect - 1 do
    begin
      psec:= PSectHdr(DWORD(pmod^.sect) + Index*sizeof(TSectHdr));
      for i:= psec^.base to (psec^.base + psec^.size) do
      begin
        if ((i - psec^.base) mod (psec^.size div 1000) = 0) then StatusProgress(
          (i - psec^.base) div (psec^.size div 1000),
          StringToOleStr(Format(
            'Finding in <%s>[%s] section (%d/%d)... ',
            [pmod^.modname,
            psec^.sectname,
            Index + 1,
            pmod^.nsect])
        ));

        ZeroMemory(@da,sizeof(da));
        ZeroMemory(@crMem,sizeof(crMem));
        if (ReadMemory(@crMem,i,MAXCMDSIZE,MM_SILENT or MM_PARTIAL) = 0) then Continue;
        Disasm(@crMem,MAXCMDSIZE,i,NIL,@da,DA_TEXT,NIL,NIL);

        ZeroMemory(@crLabel,sizeof(crLabel));
        if (FindNameW(i,NM_LABEL,crLabel,sizeof(crLabel)) = 0) then Continue;      

        ZeroMemory(@lcData,sizeof(lcData));

        lcData.line:= LineCount;
        lcData.size:= 1;
        lcData.address:= i;
        StrCopyW(@lcData.command,24,da.result);
        StrCopyW(@lcData.lc,MAXBYTE,crLabel);

        AddSortedData(@labelTable.sorted,@lcData);
        Inc(LineCount);
      end;
    end;

    StatusProgress(0, NIL);

    if (LineCount = 0) then StatusFlash('%s: Have no label',PLUGIN_NAME)
    else AddToLog(0, DRAW_HILITE, '%s: Found %d labels in ''%s''', PLUGIN_NAME, LineCount, pmod^.modname);
  except
    StatusFlash('Open Label window failed');
    DumpExceptionInfomation;
  end;
end;

Procedure DestroyLabelSortedData; stdcall;
begin
  DestroySortedData(@labelTable.sorted);
end;

Procedure InitLabelMDIWindow; stdcall;
begin
  ZeroMemory(@labelTable,sizeof(labelTable));

  StrCopyW(labelTable.name,SHORTNAME,PLUGIN_NAME);

  labelTable.bar.name[0]:= 'Address';
  labelTable.bar.expl[0]:= 'Label address';
  labelTable.bar.mode[0]:= BAR_SORT;
  labelTable.bar.defdx[0]:= 9;

  labelTable.bar.name[1]:= 'Disassembly';
  labelTable.bar.expl[1]:= 'Command at the bookmark address';
  labelTable.bar.mode[1]:= BAR_FLAT;
  labelTable.bar.defdx[1]:= 40;

  labelTable.bar.name[2]:= 'Label';
  labelTable.bar.expl[2]:= 'Label of command';
  labelTable.bar.mode[2]:= BAR_SORT;
  labelTable.bar.defdx[2]:= MAXBYTE;

  labelTable.mode:= TABLE_SAVEALL;
  labelTable.bar.visible:= 1;
  labelTable.bar.nbar:= 3;
  labelTable.custommode:= 0;
  labelTable.customdata:= NIL;
  labelTable.menu:= @LLCMenu;
  labelTable.tableselfunc:= NIL;  //@LCWndSelf;
  labelTable.updatefunc:= NIL;    //@LCWndUpdate;
  labelTable.drawfunc:= @LabelWndDraw;
  labelTable.tabfunc:= @LabelWndProc;
end;

Procedure OpenLabelListWindow; stdcall;
const LABEL_WINDOW_CAPTION: PWideChar = 'All Labels';
var Buffer: array[0..MAXBYTE] of WideChar;
begin
  dwSessionAddress:= dwSelectedAddr;
  InitLabelSortedData;
  try
    ZeroMemory(@Buffer,sizeof(Buffer));
    Swprintf(@Buffer,'%s, module ''%s''',LABEL_WINDOW_CAPTION,FindModule(dwSessionAddress)^.modname);
    if (labelTable.hw = 0) then
    begin
      if (CreateTableWindow(@labelTable,0,labelTable.bar.nbar,0,'ICO_PLUGIN',Buffer) = 0) then
      begin
        StatusFlash('%s: Label List Window create failed',PLUGIN_NAME);
      end;
    end else ActivateTableWindow(@labelTable);
  except
    Exit;
  end;
end;

Procedure InitCommentSortedData; stdcall;
var
  i, Index, LineCount: DWORD;
  pmod: PModule;
  psec: PSectHdr;
  da: TDisasm;
  crComment: array[0..MAXBYTE] of WideChar;
  crMem: array[0..MAXCMDSIZE] of Byte;
begin
  try
    if (CreateSortedData(@commentTable.sorted,sizeof(lcData),100,LCSortFunc,LCDestFunc,0) <> 0) then
    begin
      StatusFlash('%s: Init Comment Data failed',PLUGIN_NAME);
      Exit;
    end;

    ODData:= GetODData;
    if (ODData.process = 0) then
    begin
      StatusFlash('No Debuggee');
      Exit;
    end;

    pmod:= FindModule(dwSessionAddress);
    //pmod:= FindMainModule;
    if (pmod = NIL) then
    begin
      StatusFlash('%s: Could not find module for address %0.8X',PLUGIN_NAME,dwSessionAddress);
      Exit;
    end;

    LineCount:= 0;
    for Index:= 0 to pmod^.nsect - 1 do
    begin
      psec:= PSectHdr(DWORD(pmod^.sect) + Index*sizeof(TSectHdr));
      for i:= psec^.base to (psec^.base + psec^.size) do
      begin
        if ((i - psec^.base) mod (psec^.size div 1000) = 0) then StatusProgress(
          (i - psec^.base) div (psec^.size div 1000),
          StringToOleStr(Format(
            'Finding in <%s>[%s] section (%d/%d)... ',
            [pmod^.modname,
            psec^.sectname,
            Index + 1,
            pmod^.nsect])
        ));

        ZeroMemory(@da,sizeof(da));
        ZeroMemory(@crMem,sizeof(crMem));
        if (ReadMemory(@crMem,i,MAXCMDSIZE,MM_SILENT or MM_PARTIAL) = 0) then Continue;
        Disasm(@crMem,MAXCMDSIZE,i,NIL,@da,DA_TEXT or DA_OPCOMM,NIL,NIL);

        ZeroMemory(@crComment,sizeof(crComment));
        if (FindNameW(i,NM_COMMENT,crComment,sizeof(crComment)) = 0) then Continue;

        ZeroMemory(@lcData,sizeof(lcData));

        lcData.line:= LineCount;
        lcData.size:= 1;
        lcData.address:= i;
        StrCopyW(@lcData.command,40,da.result);
        StrCopyW(@lcData.lc,MAXBYTE,crComment);

        AddSortedData(@commentTable.sorted,@lcData);
        Inc(LineCount);
      end;
    end;

    StatusProgress(0, NIL);

    if (LineCount = 0) then StatusFlash('%s: No User-defined Comment',PLUGIN_NAME)
    else AddToLog(0, DRAW_HILITE, '%s: Found %d comments in ''%s''', PLUGIN_NAME, LineCount, pmod^.modname);
  except
    StatusFlash('Open Comment window failed');
    DumpExceptionInfomation;
  end;
end;

Procedure DestroyCommentSortedData; stdcall;
begin
  DestroySortedData(@commentTable.sorted);
end;

Procedure InitCommentMDIWindow; stdcall;
begin
  ZeroMemory(@commentTable,sizeof(commentTable));

  StrCopyW(commentTable.name,SHORTNAME,PLUGIN_NAME);

  commentTable.bar.name[0]:= 'Address';
  commentTable.bar.expl[0]:= 'Comments address';
  commentTable.bar.mode[0]:= BAR_SORT;
  commentTable.bar.defdx[0]:= 9;

  commentTable.bar.name[1]:= 'Disassembly';
  commentTable.bar.expl[1]:= 'Command at the bookmark address';
  commentTable.bar.mode[1]:= BAR_FLAT;
  commentTable.bar.defdx[1]:= 40;

  commentTable.bar.name[2]:= 'Comment';
  commentTable.bar.expl[2]:= 'Comment of command';
  commentTable.bar.mode[2]:= BAR_SORT;
  commentTable.bar.defdx[2]:= MAXBYTE;

  commentTable.mode:= TABLE_SAVEALL;
  commentTable.bar.visible:= 1;
  commentTable.bar.nbar:= 3;
  commentTable.custommode:= 0;
  commentTable.customdata:= NIL;
  commentTable.menu:= @LLCMenu;
  commentTable.tableselfunc:= NIL;  //@LCWndSelf;
  commentTable.updatefunc:= NIL;    //@LCWndUpdate;
  commentTable.drawfunc:= @CommentWndDraw;
  commentTable.tabfunc:= @CommentWndProc;
end;

Procedure OpenCommentListWindow; stdcall;
const COMMENT_WINDOW_CAPTION: PWideChar = 'All Comments';
var Buffer: array[0..MAXBYTE] of WideChar;
begin
  dwSessionAddress:= dwSelectedAddr;
  InitCommentSortedData;
  try
    ZeroMemory(@Buffer,sizeof(Buffer));
    Swprintf(@Buffer,'%s, module ''%s''',COMMENT_WINDOW_CAPTION,FindModule(dwSessionAddress)^.modname);
    if (commentTable.hw = 0) then
    begin
      if (CreateTableWindow(@commentTable,0,commentTable.bar.nbar,0,'ICO_PLUGIN',Buffer) = 0) then
      begin
        StatusFlash('%s: Comment List Window create failed',PLUGIN_NAME);
      end;
    end else ActivateTableWindow(@commentTable);
  except
    DumpExceptionInfomation;
    Exit
  end;
end;

end.
