unit uMenu;

interface

uses Windows, SysUtils, Messages;

type
  TMyMenu = packed record
    Flag: UInt;
    Level: Byte;
    First: Boolean;
    Name: PAnsiChar;
  end;

const
  IDM_BASEMENU: WORD   = 6000;
  MAX_MY_MENU_ITEM     = 300;

var
  pOldWndProc: Pointer = NIL;
  MyMenu: array[0..MAX_MY_MENU_ITEM] of TMyMenu;

Function  CreateMyMenu(hWnd: HWND): Boolean; stdcall;

implementation

uses Plugin, uFcData, mrVic;

Function MyExpression(funcName: PAnsiChar): DWORD; stdcall;
var res: TResult;
begin
  ZeroMemory(@res,sizeof(res));
  
  GetODData;

  Expression(
    @res,
    StringToOleStr(PacToStr(funcName)),
    NIL,0,0,
    ODData.mainthreadid,
    0,0,
    EXPR_DWORD or EXPR_REG);

  Result:= res.uvalue.u;
end;

Function MyWndProc(hw: HWND; msg: UInt; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
var
  menuIndex: WORD;
  iPos: Integer;
  funcAddr: DWORD;
  funcName: array[0..SHORTNAME] of Char;
const
  extSign: PAnsiChar = '(A/W)';
  msgSttErr: PWideChar = 'Could not set Int3 breakpoint at %S function';
  msgSucc: PWideChar = '%s: Set Int3 breakpoint at %S function';
  msgErr: PWideChar = '%s: Could not set Int3 breakpoint at %S function';
begin
  case msg of
    WM_COMMAND:
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
        
        iPos:= Pos(extSign,MyMenu[menuIndex].Name);
        if (iPos = 0) then // No suffix (A/W)
        begin
          funcAddr:= MyExpression(MyMenu[menuIndex].Name);
          if (funcAddr = 0) then
          begin
            AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,MyMenu[menuIndex].Name);
            StatusFlash(msgSttErr,MyMenu[menuIndex].Name);
          end
          else
          begin
            SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
            AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,MyMenu[menuIndex].Name);
          end;
        end
        else // Suffix (A/W)
        begin
          ZeroMemory(@funcName,sizeof(funcName));
          StrCopyA(@funcName,StrLen(MyMenu[menuIndex].Name) + 1,MyMenu[menuIndex].Name);
          
          PWORD(DWORD(@funcName) + DWORD(iPos - 1))^:= $0041; //A
          funcAddr:= MyExpression(funcName);
          if (funcAddr = 0) then
          begin
            AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,funcName);
            StatusFlash(msgSttErr,MyMenu[menuIndex].Name)
          end
          else
          begin
            SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
            AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,funcName);
          end;

          PWORD(DWORD(@funcName) + DWORD(iPos - 1))^:= $0057; //W
          funcAddr:= MyExpression(funcName);
          if (funcAddr = 0) then
          begin
            AddToLog(0,DRAW_HILITE,msgErr,PLUGIN_NAME,funcName);
            StatusFlash(msgSttErr,MyMenu[menuIndex].Name);
          end
          else
          begin
            SetInt3Breakpoint(funcAddr,BP_MANUAL or BP_BREAK,0,0,0,NIL,NIL,NIL);
            AddToLog(funcAddr,DRAW_NORMAL,msgSucc,PLUGIN_NAME,funcName);
          end;
        end;
      end;
    end;
  end;

  Result:= CallWindowProc(pOldWndProc,hw,msg,wp,lp);
end;

Procedure SubClassing; stdcall;
begin
  pOldWndProc:= Pointer(SetWindowLong(phwODbg^,GWL_WNDPROC,Integer(@MyWndProc)));
end;

Procedure InitMyMenu; stdcall;
var i: Integer;
begin
  SubClassing;
  i:= 0;
  ZeroMemory(@MyMenu,MAX_MY_MENU_ITEM*sizeof(TMyMenu));
  // Resource
  MyMenu[i].Name:= 'FindResourceEx(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'LoadResource'; Inc(i);
  MyMenu[i].Name:= 'LockResource'; Inc(i);
  MyMenu[i].Name:= 'FreeResource'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Resource'; Inc(i);
  // Window
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateWindowEx(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'ShowWindow'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'SendMessage(A/W)'; Inc(i);
  MyMenu[i].Name:= 'SetDlgItemText(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetDlgItemText(A/W)'; Inc(i);
  MyMenu[i].Name:= 'SetWindowText(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetWindowText(A/W)'; Inc(i);
  MyMenu[i].Name:= 'FindWindowEx(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'MessageBoxEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'MessageBoxIndirect(A/W)'; Inc(i);
  MyMenu[i].Name:= 'MessageBeep'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'SetWindowsHookEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'UnhookWindowsHookEx'; Inc(i);
  MyMenu[i].Name:= 'SetWindowLong(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Windows'; Inc(i);
  // Dialog
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'DialogBoxParam(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'CreateDialogParam(A/W)'; Inc(i);
  MyMenu[i].Name:= 'CreateDialogIndirectParam(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'SendDlgItemMessage(A/W)';
  MyMenu[i].Name:= 'GetDlgItem'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Dialog'; Inc(i);
  // Module
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'LoadLibraryEx(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GetModuleHandle(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GeProcAddress'; Inc(i);
  MyMenu[i].Name:= 'GetModuleFileName(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'Module32First'; Inc(i);
  MyMenu[i].Name:= 'Module32Next'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Module'; Inc(i);
  // Process
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateProcess(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'CreateProcessAsUser(A/W)'; Inc(i);
  MyMenu[i].Name:= 'OpenProcess'; Inc(i);
  MyMenu[i].Name:= 'TerminateProcess'; Inc(i);
  MyMenu[i].Name:= 'ExitProcess'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'Process32First'; Inc(i);
  MyMenu[i].Name:= 'Process32Next'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'ReadProcessMemory'; Inc(i);
  MyMenu[i].Name:= 'WriteProcessMemory'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'ShellExecuteEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'WinExec'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Process'; Inc(i);
  // Thread
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateThread'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'SuspendThread'; Inc(i);
  MyMenu[i].Name:= 'ResumeThread'; Inc(i);
  MyMenu[i].Name:= 'TerminateThread'; Inc(i);
  MyMenu[i].Name:= 'ExitThread'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= '_beginthreadex'; Inc(i);
  MyMenu[i].Name:= '_endthreadex'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'Thread32First'; Inc(i);
  MyMenu[i].Name:= 'Thread32Next'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Thread'; Inc(i);
  // Memory
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'GlobalAlloc'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GlobalFree'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'VirtualAllocEx'; Inc(i);
  MyMenu[i].Name:= 'VirtualFree'; Inc(i);
  MyMenu[i].Name:= 'VirtualQueryEx'; Inc(i);
  MyMenu[i].Name:= 'VirtualProtectEx'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Memory'; Inc(i);
  // Directory
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateDirectory(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GetCurrentDirectory(A/W)'; Inc(i);
  MyMenu[i].Name:= 'SetCurrentDirectory(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetFullPathName(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetTempPath(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetSystemDirectory(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetTempFileName(A/W)'; Inc(i);
  MyMenu[i].Name:= 'RemoveDirectory(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Directory'; Inc(i);
  // Registry
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'RegCreateKeyEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'RegOpenKeyEx(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'RegQueryInfoKey(A/W)'; Inc(i);
  MyMenu[i].Name:= 'RegSaveKeyEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'RegCloseKey'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'RegQueryValueEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'RegSetValueEx(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Registry'; Inc(i);
  // Drive
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'GetVolumeInformation(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GetDriveType(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetLogicalDrives'; Inc(i);
  MyMenu[i].Name:= 'GetLogicalDriveStrings(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Drive'; Inc(i);
  // MSVCRT
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'strcpy'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'strcpy_s'; Inc(i);
  MyMenu[i].Name:= 'lstrcpy(A/W)'; Inc(i);
  MyMenu[i].Name:= 'StrCpy'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'strcat'; Inc(i);
  MyMenu[i].Name:= 'strcat_s'; Inc(i);
  MyMenu[i].Name:= 'lstrcat(A/W)'; Inc(i);
  MyMenu[i].Name:= 'StrCat'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'strcmp'; Inc(i);
  MyMenu[i].Name:= 'strcmpi'; Inc(i);
  MyMenu[i].Name:= 'lstrcmp(A/W)'; Inc(i);
  MyMenu[i].Name:= 'lstrcmpi(A/W)'; Inc(i);
  MyMenu[i].Name:= 'StrCmp(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'memset'; Inc(i);
  MyMenu[i].Name:= 'memmove'; Inc(i);
  MyMenu[i].Name:= 'memcpy'; Inc(i);
  MyMenu[i].Name:= 'memcpy_s'; Inc(i);
  MyMenu[i].Name:= 'memcmp'; Inc(i);
  MyMenu[i].Name:= 'memcmp_s'; Inc(i);
  MyMenu[i].Name:= '_memicmp'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'MSVCRT'; Inc(i);
  // Time
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'GetTimeFormat(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GetLocalTime'; Inc(i);
  MyMenu[i].Name:= 'SetLocalTime'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'GetSystemTime'; Inc(i);
  MyMenu[i].Name:= 'SetSystemTime'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'GetFileTime'; Inc(i);
  MyMenu[i].Name:= 'SetFileTime'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'GetTimeZoneInformation'; Inc(i);
  MyMenu[i].Name:= 'LocalFileTimeToFileTime'; Inc(i);
  MyMenu[i].Name:= 'SystemTimeToFileTime'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Time'; Inc(i);
  // File I/O
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateFile(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'ReadFileEx'; Inc(i);
  MyMenu[i].Name:= 'WriteFileEx'; Inc(i);
  MyMenu[i].Name:= 'CopyFile(A/W)'; Inc(i);
  MyMenu[i].Name:= 'MoveFileEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'DeleteFile(A/W)'; Inc(i);
  MyMenu[i].Name:= 'CloseHandle'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'GetOpenFileName(A/W)'; Inc(i);
  MyMenu[i].Name:= 'GetSaveFileName(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'File I/O'; Inc(i);
  // File Mapping
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateFileMapping'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'MapViewOfFileEx'; Inc(i);
  MyMenu[i].Name:= 'UnmapViewOfFile'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'File Mapping'; Inc(i);
  // Mailslot
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'CreateMailslot'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'GetMailslot'; Inc(i);
  MyMenu[i].Name:= 'SetMailslot'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'Mailslot'; Inc(i);
  // WinSock
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'WSAStartup'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'WSACleanup'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'socket'; Inc(i);
  MyMenu[i].Name:= 'listen'; Inc(i);
  MyMenu[i].Name:= 'connect'; Inc(i);
  MyMenu[i].Name:= 'select'; Inc(i);
  MyMenu[i].Name:= 'accept'; Inc(i);
  MyMenu[i].Name:= 'bind'; Inc(i);
  MyMenu[i].Name:= 'shutdown'; Inc(i);
  MyMenu[i].Name:= 'closesocket'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'send'; Inc(i);
  MyMenu[i].Name:= 'recv'; Inc(i);
  MyMenu[i].Name:= 'sendto'; Inc(i);
  MyMenu[i].Name:= 'recvfrom'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'gethostbyname'; Inc(i);
  MyMenu[i].Name:= 'gethostname'; Inc(i);
  MyMenu[i].Name:= 'gethostbyaddr'; Inc(i);
  MyMenu[i].Name:= 'getservbyname'; Inc(i);
  MyMenu[i].Name:= 'getservbyport'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'inet_addr'; Inc(i);
  MyMenu[i].Name:= 'inet_ntoa'; Inc(i);
  MyMenu[i].Name:= 'htonl'; Inc(i);
  MyMenu[i].Name:= 'htons'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'WinSock'; Inc(i);
  // WinInet
  MyMenu[i].FLag:= MF_SEPARATOR; MyMenu[i].Level:= 1; Inc(i);
  MyMenu[i].Name:= 'HttpOpenRequest(A/W)'; MyMenu[i].First:= True; Inc(i);
  MyMenu[i].Name:= 'HttpQueryInfo(A/W)'; Inc(i);
  MyMenu[i].Name:= 'HttpAddRequestHeaders(A/W)'; Inc(i);
  MyMenu[i].Name:= 'HttpSendRequestEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'HttpEndRequest(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketCompleteUpgrade'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketSend'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketReceive'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketShutdown'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketReceive'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketClose'; Inc(i);
  MyMenu[i].Name:= 'HttpWebSocketQueryCloseStatus'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'InternetOpen(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetOpenUrl(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetCheckConnection(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetConnect(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetCrackUrl(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetCreateUrl(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetFindNextFile(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetGetConnectedStateEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetGetCookieEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetSetCookieEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetGoOnline(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetReadFileEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetWriteFileEx(A/W)'; Inc(i);
  MyMenu[i].Name:= 'InternetCloseHandle'; Inc(i);
  MyMenu[i].FLag:= MF_SEPARATOR; Inc(i);
  MyMenu[i].Name:= 'URLDownloadToFile(A/W)'; Inc(i);
  MyMenu[i].FLag:= MF_POPUP; MyMenu[i].Name:= 'WinInet';
end;

Function CreateMyMenu(hWnd: HWND): Boolean; stdcall;
var
  i: WORD;
  MenuLv0, MenuLv1, MenuLv2: HMENU;
begin
  Result:= False;
  MenuLv0:= GetMenu(hWnd);
  if (MenuLv0 = 0) then
  begin
    Exit;
  end;

  InitMyMenu;

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

  AppendMenuA(MenuLv0,MF_POPUP,MenuLv1,'APIs');

  DrawMenuBar(hWnd);

  Result:= True;
end;

end.
