unit uMenuHook;

interface

uses Windows, SysUtils, mrVic;

type TTrackPopupMenuEx = Function(
  hMenu: HMENU;
  fuFlags: UINT;
  x, y: Integer;
  hWnd: HWND;
  lptpm: PTPMParams): BOOL; stdcall;

type
  TBreakpointMenuID = packed record
    Name: String;
    Index: DWORD;
  end;

var
  oTrackPopupMenuEx: TTrackPopupMenuEx = NIL;
  MyBreakPointMenuID: array[0..8] of TBreakpointMenuID;

Function InstallMenuHook: Boolean;
Function RemoveMenuHook: Boolean;
Procedure InitMyBreakpointMenuID;

implementation

Procedure InitMyBreakpointMenuID;
begin
  ZeroMemory(@MyBreakPointMenuID,sizeof(MyBreakPointMenuID));
	MyBreakPointMenuID[0].name:= '- INT3 Delete all';
	MyBreakPointMenuID[1].name:= '- INT3 Import';
	MyBreakPointMenuID[2].name:= '- INT3 Export';
	MyBreakPointMenuID[3].name:= '- HWBP Delete all';
	MyBreakPointMenuID[4].name:= '- HWBP Import';
	MyBreakPointMenuID[5].name:= '- HWBP Export';
	MyBreakPointMenuID[6].name:= '- MBP Delete all';
	MyBreakPointMenuID[7].name:= '- MBP Import';
	MyBreakPointMenuID[8].name:= '- MBP Export';
end;

Function HTrackPopupMenuEx(hMenu: HMENU; fuFlags: UINT; x, y: Integer; hWnd: HWND; lptpm: PTPMParams): BOOL; stdcall;
var
  hMyMenu: THandle;
  i, j, z: Integer;
  Buffer: array[0..MAXBYTE] of Char;
  mii: TMenuInfo;
begin
  for i:= 0 to GetMenuItemCount(hMenu) - 1 do
  begin
    GetMenuStringA(hMenu,i,Buffer,MAXBYTE,MF_BYPOSITION);
    if (GetMenuItemID(hMenu,i) = DWORD(-1)) and (StrPas(Buffer) = 'Vic Plug-In 2') then
    begin
      hMyMenu:= GetSubMenu(hMenu,i);
      for j:= 0 to GetMenuItemCount(hMyMenu) - 1 do
      begin
        VICMsg('%0.8X',[GetMenuState(hMyMenu,j,MF_BYPOSITION)]);
      end;
    end;
  end;
  Result:= oTrackPopupMenuEx(hMenu,fuFlags,x,y,hwnd,lptpm);
end;

Function InstallMenuHook: Boolean;
begin
  if VIC.API_HookInline(user32,'TrackPopupMenuEx',@HTrackPopupMenuEx,@oTrackPopupMenuEx) then
  begin
    VICMsg('InstallHook::TrackPopupMenuEx::Success');
    Result:= True;
  end
  else
  begin
    VICMsg('InstallHook::TrackPopupMenuEx::Failure');
    Result:= False;
  end;
end;

Function RemoveMenuHook: Boolean;
begin
  if VIC.API_HookInline(user32,'TrackPopupMenuEx',@HTrackPopupMenuEx,@oTrackPopupMenuEx) then
  begin
    VICMsg('RemoveHook::TrackPopupMenuEx::Success');
    Result:= True;
  end
  else
  begin
    VICMsg('RemoveHook::TrackPopupMenuEx::Failure');
    Result:= False;
  end;
end;

end.
