unit uUDD;

interface

uses Windows, Messages, SysUtils, Dialogs, Controls, uFcData, Plugin, mrVic;

Function fcUddMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;

const
  LUddMenu: array[0..7] of TMenu =
  (
    (name: 'Load'; help: NIL; shortcutid: K_NONE; menucmd: fcUddMenu; submenu: NIL; index: 1),
    (name: 'Delete'; help: NIL; shortcutid: K_NONE; menucmd: fcUddMenu; submenu: NIL; index: 2),
    (name: 'Delete all'; help: NIL; shortcutid: K_NONE; menucmd: fcUddMenu; submenu: NIL; index: 3),
    (name: 'Refresh'; help: NIL; shortcutid: K_NONE; menucmd: fcUddMenu; submenu: NIL; index: 4),
    (name: '|>STANDARD'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 5),
    (name: '>FULLCOPY'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 6),
    (name: '>APPEARANCE'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 7),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

type
  _UDD_DATA = packed record
    line: DWORD;
    size: DWORD;
    types: DWORD;
    eip: DWORD;
    uddname: array[0..SHORTNAME] of WideChar;
    uddsize: DWORD;
    uddtime: TDateTime;
  end;
  TUddData = _UDD_DATA;
  PUddData = ^TUddData;

var
  uddTable: TTable;
  uddData:  TUddData;

Procedure InitUddMDIWindow; stdcall;
Procedure InitUDDSortedData; stdcall;
Procedure DestroyUDDSortedData; stdcall;

implementation

Procedure ScanUddDirectory(const lpwszUddDirectory, lpwszPattern: PWideChar); stdcall; forward;

Function fcUddMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var
  ret: Integer;
  pud: PUddData;
begin
  ret:= MENU_ABSENT;
  case iMode of
    MENU_VERIFY:
    begin
      case dwIndex of
        1, 2, 3:
        begin
          if (GetSortedByIndex(@uddTable.sorted,0) = NIL) then
          begin
            Result:= MENU_ABSENT;
            Exit;
          end;
        end;  
      end;
      ret:= MENU_NORMAL;
    end;
    MENU_EXECUTE:
    begin
      case dwIndex of
        1: // Load
        begin
          pud:= PUddData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
          if (pud <> NIL) then
          begin
            VICBox(hwODbg,'%d <%s>',[pud^.line,WideCharToString(pud^.uddname)]);
          end else StatusFlash('%s: Could not find this UDD. Try again.',PLUGIN_NAME);
        end;
        2: // Delete
        begin
          pud:= PUddData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
          if (pud <> NIL) then
          begin
            if (DeleteFile(Format('%s\%s',[GetUddDirectory,WideCharToString(pud^.uddname)])) = True) then
            begin
              DeleteSortedData(@pT^.sorted,pud^.line,0);
              InvalidateRect(pT^.hw,NIL,True);
            end else StatusFlash('%s: Delete ''%s'' is not success.',PLUGIN_NAME,pud^.uddname);
          end else StatusFlash('%s: Could not find this UDD. Try again.',PLUGIN_NAME);
        end;
        3: // Delete all
        begin
          if (MessageDlg('Are you sure to delete all UDD data?', mtConfirmation,mbOKCancel,0) = mrCancel) then
          begin
            Result:= MENU_NORMAL;
            Exit;
          end;

          if (ViC_DelUddData('*.UDD') = True) then
          begin
            DestroyUDDSortedData;
            InvalidateRect(pT^.hw,NIL,True);
            AddToLog(0,1,'%s: Delete all UDD data is done',PLUGIN_NAME);
          end else StatusFlash('%s: Delete all UDD data failed',PLUGIN_NAME);
        end;
        4: // Refresh
        begin
          InitUDDSortedData;
          InvalidateRect(pT^.hw,NIL,True);
        end;  
      end;
    end;
  end;
  Result:= ret;
end;

Function FileTimeToDateTime(FileTime: TFileTime): TDateTime; stdcall;
var
  ModifiedTime: TFileTime;
  SystemTime: TSystemTime;
begin
  Result:= 0;
  if (FileTime.dwLowDateTime = 0) and (FileTime.dwHighDateTime = 0) then Exit;
  try
    FileTimeToLocalFileTime(FileTime,ModifiedTime);
    FileTimeToSystemTime(ModifiedTime,SystemTime);
    Result:= SystemTimeToDateTime(SystemTime);
  except
    Result:= Now; // Something to return in case of error
  end;
end;

Procedure ScanUddDirectory(const lpwszUddDirectory, lpwszPattern: PWideChar); stdcall;
var
  hFind: THandle;
  wfd: TWin32FindDataW;
  szUddSearchDirectory: array[0..MAX_PATH] of WideChar;
  i: DWORD;
begin
  ZeroMemory(@szUddSearchDirectory,sizeof(szUddSearchDirectory));
  lstrcatW(szUddSearchDirectory,lpwszUddDirectory);
  lstrcatW(szUddSearchDirectory,lpwszPattern);

  ZeroMemory(@wfd,sizeof(wfd));
  hFind:= FindFirstFileW(szUddSearchDirectory,wfd);
  if (hFind = INVALID_HANDLE_VALUE) then
  begin
    Exit;
  end;

  i:= 0;
  repeat
    ZeroMemory(@uddData,sizeof(uddData));
    
    uddData.line:= i;
    uddData.size:= 1;
    lstrcpyW(@uddData.uddname,wfd.cFileName);
    uddData.uddsize:= wfd.nFileSizeHigh shl 32 + wfd.nFileSizeLow;
    uddData.uddtime:= FileTimeToDateTime(wfd.ftLastWriteTime);
    AddSortedData(@uddTable.sorted,@uddData);

    Inc(i);
  until (FindNextFileW(hFind,wfd) = False);

  Windows.FindClose(hFind);
end;

Function UDDSortFunc(const pPrevSh, pNextSh: PSortHdr; const iColumn: Integer): Integer; cdecl;
var
  ret: Integer;
  prev, next: PUddData;
begin
  ret:= 0;

  prev:= PUddData(pPrevSh);
  next:= PUddData(pNextSh);

  case iColumn of
    0: // Name
    begin
      if (lstrcmpW(prev^.uddname,next^.uddname) = -1) then
      begin
        ret:= -1;
      end
      else
      if (lstrcmpW(prev^.uddname,next^.uddname) = 1) then
      begin
        ret:= 1;
      end
    end;
    1: // Size
    begin
      if (prev^.uddsize < next^.uddsize) then
      begin
        ret:= -1;
      end
      else
      if (prev^.uddsize > next^.uddsize) then
      begin
        ret:= 1;
      end
    end;
    2: // Time
    begin
      if (prev^.uddtime < next^.uddtime) then
      begin
        ret:= -1;
      end
      else
      if (prev^.uddtime > next^.uddtime) then
      begin
        ret:= 1;
      end
    end;
  end;
  Result:= ret;
end;

Procedure UDDDestFunc(pSh: PSortHdr); cdecl;
begin
  //DestroyUDDSortedData;
end;

Function UDDWndProc(pT: PTable; hw: HWND; msg: UInt; wp: WPARAM; lp: LPARAM): Integer; cdecl;
var
  ret: Integer;
  pud: PUddData;
begin
  ret:= 0;
  case msg of
    WM_USER_DBLCLK:
    begin
      pud:= PUddData(GetSortedBySelection(@pT^.sorted,pT^.sorted.selected));
      if (pud = NIL) then
      begin
        VICBox(hwODbg,WideCharToString(PLUGIN_NAME),'Could not be selected!');
        Result:= 0;
        Exit;
      end;
      VICBox(hwODbg,WideCharToString(PLUGIN_NAME),'Selected: %d <%s>',[pud^.line,WideCharToString(pud^.uddname)]);
    end;
  end;
  Result:= ret;
end;

Function UDDWndDraw(pWc: PWideChar; pMask: PByte; piSelect: PInteger; pT: PTable; pDh: PDrawHeader; iColum: Integer; pCache: Pointer): Integer; cdecl;
var
  ret: Integer;
  pud: PUddData;
begin
  ret:= 0;

  pud:= PUddData(pDh);

  if (pud = NIL) then
  begin
    Result:= ret;
    Exit;
  end;

  case iColum of
    DF_CACHESIZE, DF_FILLCACHE, DF_FREECACHE, DF_NEWROW:
    begin
      ret:= 0;
    end;
    0: // Address
    begin
      ret:= StrCopyW(pWc,SHORTNAME,pud^.uddname);
    end;
    1: // Command
    begin
      ret:= StrCopyW(pWc,SHORTNAME,StringToOleStr(Format('%d',[pud^.uddsize])));
    end;
    2: // Label
    begin
      ret:= StrCopyW(pWc,SHORTNAME,StringToOleStr(DateTimeToStr(pud^.uddtime)));
    end;
  end;

  Result:= ret;
end;

Procedure InitUDDSortedData; stdcall;
begin
  if (CreateSortedData(@uddTable.sorted,sizeof(uddData),100,UDDSortFunc,UDDDestFunc,0) <> 0) then
  begin
    StatusFlash('%s: Init the UDD list is not success.',PLUGIN_NAME);
    Exit;
  end;

  ScanUddDirectory(StringToOleStr(GetUddDirectory + '\'),'*.UDD');
end;

Procedure DestroyUDDSortedData; stdcall;
begin
  DestroySortedData(@uddTable.sorted);
end;

Procedure InitUddMDIWindow; stdcall;
begin
  ZeroMemory(@uddTable,sizeof(uddTable));

  //InitUDDSortedData;

  StrCopyW(uddTable.name,SHORTNAME,PLUGIN_NAME);

  uddTable.bar.name[0]:= 'Name';
  uddTable.bar.expl[0]:= 'UDD Name';
  uddTable.bar.mode[0]:= BAR_SORT;
  uddTable.bar.defdx[0]:= SHORTNAME;

  uddTable.bar.name[1]:= 'Size (Decan)';
  uddTable.bar.expl[1]:= 'UDD Size';
  uddTable.bar.mode[1]:= BAR_SORT;
  uddTable.bar.defdx[1]:= 15;

  uddTable.bar.name[2]:= 'Time';
  uddTable.bar.expl[2]:= 'UDD Time';
  uddTable.bar.mode[2]:= BAR_SORT;
  uddTable.bar.defdx[2]:= 25;

  uddTable.mode:= TABLE_SAVEALL;
  uddTable.bar.visible:= 1;
  uddTable.bar.nbar:= 3;
  uddTable.custommode:= 0;
  uddTable.customdata:= NIL;
  uddTable.menu:= @LUddMenu;
  uddTable.tableselfunc:= NIL; //@LCWndSelf;
  uddTable.updatefunc:= NIL;   //@LCWndUpdate;
  uddTable.drawfunc:= @UDDWndDraw;
  uddTable.tabfunc:= @UDDWndProc;
end;

end.
