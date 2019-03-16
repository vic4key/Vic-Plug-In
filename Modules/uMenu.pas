unit uMenu;

interface

uses Windows, SysUtils, Messages;

type
  TMyMenu = packed record
    Flag: UInt;
    Level: Byte;
    First: Boolean;
    Name: PAnsiChar;
    Module: PAnsiChar;
  end;

const
  MY_MENU_NAME: PAnsiChar = 'APIs';

  IDM_BASEMENU: WORD = 6000;
  MAX_MY_MENU_ITEM   = 300;

var
  bCreatedMenuAPI: Boolean = False;
  pOldWndProc: Pointer = NIL;
  MyMenu: array[0..MAX_MY_MENU_ITEM] of TMyMenu;

Function CreateMyMenu(hWnd: HWND): Boolean; stdcall;
Function DestroyMyMenu(hWnd: HWND): Boolean; stdcall;
Function SubClassing: Boolean; stdcall;

implementation

uses Plugin, uFcData, mrVic;

Function MyExpression(modName, funcName: PAnsiChar): DWORD; stdcall;
var
  modul: String;
  res: TResult;
begin
  try
    ZeroMemory(@res,sizeof(res));

    GetODData;

    modul:= '';
    if (lstrlenA(modName) > 0) then
    begin
      modul:= PacToStr(modName) + '.';
    end;

    Expression(
      @res,
      StringToOleStr(modul + PacToStr(funcName)),
      NIL,0,0,
      ODData.mainthreadid,
      0,0,
      EXPR_DWORD or EXPR_REG);

    Result:= res.uvalue.u;
  except
    DumpExceptionInfomation;
    Result:= 0;
  end;
end;

Function MyWndProc(hw: HWND; msg: UInt; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
var
  menuIndex: WORD;
  iPos: Integer;
  funcAddr: DWORD;
  funcName: array[0..SHORTNAME] of Char;
  modName: PAnsiChar;
const
  extSign: PAnsiChar = '(A/W)';
  msgSttErr: PWideChar = 'Could not set INT3 breakpoint at %S!%S function';
  msgSttSuc: PWideChar = 'Set INT3 breakpoint at %S!%S function';
  msgSucc: PWideChar = '%s: Set INT3 breakpoint at %S!%S function';
  msgErr: PWideChar = '%s: Could not set INT breakpoint at %S!%S function';
begin
  case (wp and $FFF0) of
    SC_CLOSE:
    begin
      //VICMsg('%0.8X | %0.8X | %0.8X - %0.8X',[hw,msg,wp,lp]);
      if (fConfirm = 2) and (msg = WM_SYSCOMMAND) then
      begin
        if (ExitConfirm(hw) = False) then
        begin
          Result:= 0;
          Exit;
        end;
      end;
    end;
  end;
  case msg of
    WM_WINDOWPOSCHANGED:
    begin
      //OutputDebugStringA('WM_WINDOWPOSCHANGED');
      //uFcData.bOllyMoving:= False;
    end;
    WM_WINDOWPOSCHANGING:
    begin
      uFcData.bOllyMoving:= True;
      //OutputDebugStringA('WM_WINDOWPOSCHANGING');
    end;
    WM_GETMINMAXINFO :
    begin
      //uFcData.bOllyMoving:= True;
    end;
    WM_EXITSIZEMOVE:
    begin
      uFcData.bOllyMoving:= False;
    end;
    WM_MOVING:
    begin
      uFcData.bOllyMoving:= True;
    end;
    WM_COMMAND:
    begin
      case LOWORD(wp) of
        $083A: // for Ctrl + Shift + X and File\Exit
        begin
          if (fConfirm = 2) then
          begin
            //VICMsg('%0.8X | %0.8X | %0.8X - %0.8X',[hw,msg,wp,lp]);
            if (ExitConfirm(hw) = False) then
            begin
              Result:= 0;
              Exit;
            end;
          end;
        end;  
      end;

      if (bCreatedMenuAPI = True) then
      begin
        menuIndex:= LOWORD(wp) - IDM_BASEMENU;
        if (menuIndex <= MAX_MY_MENU_ITEM) then
        begin
          if (ODData.processid = 0) then
          begin
            StatusFlash('No Debuggee');
            Result:= 0;
            Exit;
          end;
          try
            if (lstrlenA(MyMenu[menuIndex].Module) <> 0) then
            begin
              modName:= MyMenu[menuIndex].Module;
            end
            else
            begin
              modName:= '*';
            end;
            iPos:= Pos(extSign,MyMenu[menuIndex].Name);
            if (iPos = 0) then // No suffix (A/W)
            begin
              funcAddr:= MyExpression(MyMenu[menuIndex].Module,MyMenu[menuIndex].Name);
              if (funcAddr = 0) then
              begin
                AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,modName,MyMenu[menuIndex].Name);
                StatusFlash(msgSttErr,modName,MyMenu[menuIndex].Name);
              end
              else
              begin
                SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
                AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,modName,MyMenu[menuIndex].Name);
                StatusFlash(msgSttSuc,modName,MyMenu[menuIndex].Name);
              end;
            end
            else // Suffix (A/W)
            begin
              ZeroMemory(@funcName,sizeof(funcName));
              StrCopyA(@funcName,StrLen(MyMenu[menuIndex].Name) + 1,MyMenu[menuIndex].Name);
          
              PWORD(DWORD(@funcName) + DWORD(iPos - 1))^:= $0041; //A
              funcAddr:= MyExpression(MyMenu[menuIndex].Module,funcName);
              if (funcAddr = 0) then
              begin
                AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,modName,funcName);
                StatusFlash(msgSttErr,modName,MyMenu[menuIndex].Name);
              end
              else
              begin
                SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
                AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,modName,funcName);
                StatusFlash(msgSttSuc,modName,MyMenu[menuIndex].Name);
              end;

              PWORD(DWORD(@funcName) + DWORD(iPos - 1))^:= $0057; //W
              funcAddr:= MyExpression(MyMenu[menuIndex].Module,funcName);
              if (funcAddr = 0) then
              begin
                AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,modName,funcName);
                StatusFlash(msgSttErr,modName,MyMenu[menuIndex].Name);
              end
              else
              begin
                SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
                AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,modName,funcName);
                StatusFlash(msgSttSuc,modName,MyMenu[menuIndex].Name);
              end;
            end;
          except
            DumpExceptionInfomation;
          end;
        end;
      end;
    end;
  end;

  Result:= CallWindowProc(pOldWndProc,hw,msg,wp,lp);
end;

Function SubClassing: Boolean; stdcall;
begin
  try
    pOldWndProc:= Pointer(SetWindowLong(hwODbg,GWL_WNDPROC,Integer(@MyWndProc)));
    if (pOldWndProc <> NIL) then Result:= True
    else Result:= False;
  except
    DumpExceptionInfomation;
    Result:= False;
  end;
end;

Procedure InitMyMenu; stdcall;
var
  i: Integer;
  ModName: PAnsiChar;
begin
  try
    i:= 0;
    ZeroMemory(@MyMenu,MAX_MY_MENU_ITEM*sizeof(TMyMenu));
    // Resource
    ModName:= '';
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'FindResource(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'FindResourceEx(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LoadResource'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LockResource'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'FreeResource'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LoadString(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Resource'; Inc(i);
    // Window
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateWindow(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateWindowEx(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ShowWindow'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SendMessage(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetDlgItemText(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetDlgItemText(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetWindowText(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetWindowText(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'FindWindow(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'FindWindowEx(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MessageBox(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MessageBoxEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MessageBoxIndirect(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MessageBeep'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetWindowsHook'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetWindowsHookEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'UnhookWindowsHookEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetWindowLong'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Windows'; Inc(i);
    // Dialog
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'DialogBoxParam(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateDialogParam(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateDialogIndirectParam(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SendDlgItemMessage(A/W)';
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetDlgItem'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Dialog'; Inc(i);
    // Module
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LoadLibrary(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LoadLibraryEx(A/W)';;
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetModuleHandle(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GeProcAddress'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetModuleFileName(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Module32First'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Module32FirstW'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Module32Next'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Module32NextW'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Module'; Inc(i);
    // Process
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateProcess(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateProcessAsUser(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenProcess'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'TerminateProcess'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ExitProcess'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Process32First'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Process32FirstW'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Process32Next'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Process32NextW'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ReadProcessMemory'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WriteProcessMemory'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ShellExecute(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ShellExecuteEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WinExec'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Process'; Inc(i);
    // Thread
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateThread'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SuspendThread'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ResumeThread'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'TerminateThread'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ExitThread'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_beginthreadex'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_endthreadex'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Thread32First'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'Thread32Next'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Thread'; Inc(i);
    // Memory
    ModName:= 'kernel32';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HeapCreate'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GlobalAlloc'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GlobalFree'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'VirtualAllocEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'VirtualFree'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'VirtualQueryEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'VirtualProtectEx'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    ModName:= 'msvcrt';
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'calloc'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'malloc'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'realloc'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'free'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Memory'; Inc(i);
    // Servcice
    ModName:= 'advapi32';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenSCManager(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenService(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'StartService(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'DeleteService'; Inc(i);
    MyMenu[i].Module:= 'kernel32'; MyMenu[i].Name:= 'DeviceIoControl'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Service'; Inc(i);
    // Directory
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateDirectory(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RemoveDirectory(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetCurrentDirectory(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetCurrentDirectory(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFullPathName(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetTempPath(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetSystemDirectory(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetTempFileName(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Directory'; Inc(i);
    // Registry
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegCreateKey(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegCreateKeyEx(A/W)';
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegOpenKey(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegOpenKeyEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegQueryInfoKey(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegSaveKey(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegSaveKeyEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegCloseKey'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegQueryValue(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegQueryValueEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegSetValue(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'RegSetValueEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Registry'; Inc(i);
    // Drive
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetVolumeInformation(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetDriveType(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetLogicalDrives'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetLogicalDriveStrings(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetLogicalDrives'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetVolumeLabel(A/W)'; Inc(i);
    MyMenu[i].Module:= 'kernel32'; MyMenu[i].Name:= 'GetDiskFreeSpace(A/W)'; Inc(i);
    MyMenu[i].Module:= 'kernel32'; MyMenu[i].Name:= 'GetDiskFreeSpaceEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Drive'; Inc(i);
    // MSVCRT
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcpy'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcpy_s'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'lstrcpy(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'StrCpy'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcat'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcat_s'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'lstrcat(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'StrCat'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcmp'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'strcmpi'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'lstrcmp(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'lstrcmpi(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'StrCmp(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memset'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memmove'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memcpy'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memcpy_s'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memcmp'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'memcmp_s'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_memicmp'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'MSVCRT'; Inc(i);
    // Time
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetTimeFormat(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetLocalTime'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetLocalTime'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetSystemTime'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetSystemTime'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFileTime'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetFileTime'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetTimeZoneInformation'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LocalFileTimeToFileTime'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SystemTimeToFileTime'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Time'; Inc(i);
    // File
    ModName:= 'kernel32';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateFile(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ReadFile'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ReadFileEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WriteFile'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WriteFileEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CloseHandle'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetFilePointerEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFileSizeEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFileType'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFileAttributes(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetFileAttributesEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenFile'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ReOpenFile'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenFileById'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'LZOpenFile(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CopyFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MoveFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MoveFileEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'DeleteFile(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetOpenFileName(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetSaveFileName(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_lopen'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_lread'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_lwrite'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '_lclose'; Inc(i);
    ModName:= 'msvcrt';
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'fopen'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'fread'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'fwrite'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'fclose'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'File'; Inc(i);
    // File Mapping
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateFileMapping(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'OpenFileMapping(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'MapViewOfFileEx'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'UnmapViewOfFile'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'File Mapping'; Inc(i);
    // Mailslot
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'CreateMailslot(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'GetMailslotInfo'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'SetMailslotInfo'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Mailslot'; Inc(i);
    // WinSock
    ModName:= 'WS2_32';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WSAStartup'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'WSACleanup'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'socket'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'listen'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'connect'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'select'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'accept'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'bind'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'shutdown'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'closesocket'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'send'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'recv'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'sendto'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'recvfrom'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'gethostbyname'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'gethostname'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'gethostbyaddr'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'getservbyname'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'getservbyport'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'inet_addr'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'inet_ntoa'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'htonl'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'htons'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'WinSock'; Inc(i);
    // WinInet
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpOpenRequest(A/W)'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpQueryInfo(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpAddRequestHeaders(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpSendRequest(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpSendRequestEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpEndRequest(A/W)'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketCompleteUpgrade'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketSend'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketReceive'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketShutdown'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketReceive'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketClose'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'HttpWebSocketQueryCloseStatus'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetOpen(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetOpenUrl(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetCheckConnection(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetConnect(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetCrackUrl(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetCreateUrl(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetFindNextFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetGetConnectedStateEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetGetCookie(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetGetCookieEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetSetCookie(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetSetCookieEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetGoOnline(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetReadFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetReadFileEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetWriteFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetWriteFileEx(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'InternetCloseHandle'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'URLDownloadToFile(A/W)'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'WinInet'; Inc(i);
    // VB APIs
    ModName:= '';
    MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'ThunRTMain'; MyMenu[i].First:= True; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcMsgBox'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarAdd'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarSub'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarMul'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarIdiv'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarAnd'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarOr'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarXor'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarNot'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarNeg'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarPow'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaFpCmpCy'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaStrCmp'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaStrComp'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarCmpEq'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarCmpNe'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTstEq'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTstNe'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaStrTextCmp'; Inc(i);;
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTextCmpEq'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTextCmpNe'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTextTstEq'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarTextTstNe'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaStrCopy'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarCopy'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaVarMove'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbavbal2Str'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaFPInt'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaFpR4'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= '__vbaFpR8'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcHexBstrFromVar'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcHexVarFromVar'; Inc(i);
    MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetTimeBstr'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetTimeValue'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetTimeVar'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetTimer'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetYear'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetPresentDate'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetMonthOfYear'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetMinuteOfHour'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].Name:= 'rtcGetSecondOfMinute'; Inc(i);
    MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'VB APIs';
    { // Template
      ModName:= '';
      MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
      MyMenu[i].Module:= ModName; MyMenu[i].Name:= ''; MyMenu[i].First:= True; Inc(i);
      MyMenu[i].Module:= ModName; MyMenu[i].Name:= ''; Inc(i);
      MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
      MyMenu[i].Module:= ModName; MyMenu[i].Name:= ''; Inc(i);
      MyMenu[i].Module:= ModName; MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Template'; Inc(i);
      Note: If you wanna add to last of the menu array, please remove Inc(i);
    }
  except
    DumpExceptionInfomation;
  end;
end;

Function CreateMyMenu(hWnd: HWND): Boolean; stdcall;
var
  i: WORD;
  MenuLv0, MenuLv1, MenuLv2: HMENU;
begin
  Result:= False;
  try
    // Check my menu created?

    MenuLv0:= GetMenu(hWnd);
    if (MenuLv0 = 0) then
    begin
      Exit;
    end;

    InitMyMenu;

    bCreatedMenuAPI:= True;

    if (bSubClass = False) then bSubClass:= SubClassing;

    MenuLv1:= CreateMenu;
  
    MenuLv2:= 0;
    i:= 0;
    repeat
      if (MyMenu[i].First = True) then MenuLv2:= CreatePopupMenu;
      if (MyMenu[i].FLag = MF_STRING) then AppendMenuA(MenuLv2,MF_STRING,IDM_BASEMENU + i,MyMenu[i].Name);
      if (MyMenu[i].FLag = MF_SEPARATOR) then
      begin
        if (MyMenu[i].Level= 1) then AppendMenuA(MenuLv1,MF_SEPARATOR,0,NIL)
        else AppendMenuA(MenuLv2,MF_SEPARATOR,0,NIL);
      end;
      if (MyMenu[i].FLag = MF_POPUP) then AppendMenuA(MenuLv1,MF_POPUP,MenuLv2,MyMenu[i].Name);
      Inc(i);
    until ((MyMenu[i].Flag = 0) and (MyMenu[i].Name = NIL));

    AppendMenuA(MenuLv0,MF_POPUP,MenuLv1,MY_MENU_NAME);

    DrawMenuBar(hWnd);

    Result:= True;
  except
    Result:= False;
    Exit;
  end;
end;

Function DestroyMyMenu(hWnd: HWND): Boolean; stdcall;
var
  i, myMenuPos: Integer;
  MenuLv0, MenuLv1: HMENU;
  MenuName: array[0..MAXBYTE] of Char;
begin
  Result:= False;

  MenuLv0:= GetMenu(hWnd);

  myMenuPos:= $FF;
  for i:= 0 to GetMenuItemCount(MenuLv0) - 1 do
  begin
    ZeroMemory(@MenuName,sizeof(MenuName));
    GetMenuStringA(MenuLv0,i,@MenuName,sizeof(MenuName),MF_BYPOSITION);
    if (lstrcmpA(MY_MENU_NAME,PAnsiChar(@MenuName)) = 0) then
    begin
      myMenuPos:= i;
      Break;
    end;
  end;

  if (myMenuPos = $FF) then Exit;
  
  MenuLv1:= GetSubMenu(MenuLv0,myMenuPos);

  DestroyMenu(MenuLv1);

  DeleteMenu(MenuLv0,myMenuPos,MF_BYPOSITION);

  DrawMenuBar(hWnd);

  bCreatedMenuAPI:= False;
end;

end.
