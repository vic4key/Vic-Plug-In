unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, TLHelp32, ImgList, Menus, ShellApi, StdCtrls;

type
  TfrmMain = class(TForm)
    Splitter1: TSplitter;
    pnlProcesses: TPanel;
    lvProcesses: TListView;
    pnlModules: TPanel;
    lvModules: TListView;
    tRefresh: TTimer;
    StatusBar1: TStatusBar;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    PatchImagePath1: TMenuItem;
    PopupMenu2: TPopupMenu;
    PatchModuleFilename1: TMenuItem;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function GetDebugPrivilege: Boolean;
    procedure RefreshList;
    procedure GetModuleList(PID: DWORD);
    procedure AddIcon(FileName: String; ListItem: TListItem);
    function GetWinFolder: String;
    function IsInvalidProcess(Value: String): Boolean;
    function GetFileInfo(FileName, BlockName: String): String;
    procedure lvProcessesClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PatchImagePath1Click(Sender: TObject);
    procedure tRefreshTimer(Sender: TObject);
    procedure PatchModuleFilename1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
const
  SystemProcess: String = '[system process]';
  SystemIdleProcess: String = '[system idle process]';
  System: String = 'system';
  SystemFilled: String = '[system]';
  SystemRoot: String = '\systemroot\';
  SystemUnknown: String = '\??\';

implementation

uses untPatchImagePath, untPatchModule;

{$R *.dfm}

function TfrmMain.GetWinFolder: String;
var
  WinArray: Array[0..MAX_PATH] of Char;
begin
  WinArray := '';
  GetWindowsDirectory(WinArray, sizeof(WinArray));
  Result := String(WinArray);
end;

// by MathiasSimmack - Delphi-PRAXiS
{
  Blocks
    CompanyName
    FileDescription
    FileVersion
    InternalName
    LegalCopyright
    OriginalFilename
    ProductName
    ProductVersion
}

function TfrmMain.GetFileInfo(FileName, BlockName: String): String;
var
  dwSize, lpdwHandle: DWORD;
  lpData, lpTranslation, lplpBuffer: Pointer;
const
  VarFileInfoTraslation = '\\VarFileInfo\\Translation';
  VarStringFileInfo = '\\StringFileInfo\\%.4x%.4x\\%s';
begin
  Result := '';
  dwSize := GetFileVersionInfoSize(PChar(FileName), lpdwHandle);
  if dwSize <> 0 then
  begin
    GetMem(lpData, dwSize);
    GetFileVersionInfo(PChar(FileName), 0, dwSize, lpData);
    if lpData <> nil then
    begin
      VerQueryValue(lpData, VarFileInfoTraslation, lpTranslation, dwSize);
      if lpTranslation <> nil then
      begin
        VerQueryValue(lpData, PChar(Format(VarStringFileInfo, [LOWORD(LongInt(lpTranslation^)), HIWORD(LongInt(lpTranslation^)), BlockName])), lplpBuffer, dwSize);
        if lplpBuffer <> nil then
        begin
          SetString(Result, PChar(lplpBuffer), dwSize -1);
        end else
          FreeMem(lpData, dwSize);
      end else
        FreeMem(lpData, dwSize);
    end else
      FreeMem(lpData, dwSize);
  end;
end;

function TfrmMain.GetDebugPrivilege: Boolean;
var
  hToken: THandle;
  TP: TTokenPrivileges;
  lpLuid: TLargeInteger;
  dwReturnLength: DWORD;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    if LookupPrivilegeValue(nil, 'SeDebugPrivilege', lpLuid) then
    begin
      TP.PrivilegeCount := 1;
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      TP.Privileges[0].Luid := lpLuid;
      Result := AdjustTokenPrivileges(hToken, False, TP, sizeof(TP), nil, dwReturnLength);
    end;
    CloseHandle(hToken);
  end;
end;

function TfrmMain.IsInvalidProcess(Value: String): Boolean;
begin
  Result := False;
  if (LowerCase(Copy(Value, 1, Length(Value))) = SystemIdleProcess) or
     (LowerCase(Copy(Value, 1, Length(Value))) = SystemFilled) or
     (LowerCase(Copy(Value, 1, Length(SystemRoot))) = SystemRoot) or
     (LowerCase(Copy(Value, 1, Length(SystemUnknown))) = SystemUnknown) then
     Result := True;
end;

procedure TfrmMain.AddIcon(FileName: String; ListItem: TListItem);
var
  SHFileInfo: TShFileInfo;
  Icon: TIcon;
begin
  Icon := TIcon.Create;
  SHGetFileInfo(PChar(FileName), 0, SHFileInfo, sizeof(SHFileInfo), SHGFI_SMALLICON or SHGFI_ICON);
  Icon.Handle := SHFileInfo.hIcon;
  ListItem.ImageIndex := ImageList1.AddIcon(Icon);
  Icon.Free;
end;

procedure TfrmMain.RefreshList;
var
  PE: TProcessEntry32;
  ME: TModuleEntry32;
  hPE, hME: THandle;
  liProcess: TListItem;
  intProcess, intModules: Integer;
  lpImagePath: PChar;
  ModulePath: String;
begin
  lvProcesses.Clear;
  intProcess := 0;
  intModules := 0;
  StatusBar1.Panels[2].Text := 'Refreshing ...';
  hPE := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  PE.dwSize := sizeof(TProcessEntry32);
  Process32First(hPE, PE);
  repeat
    Inc(intProcess);
    begin
      liProcess := lvProcesses.Items.Add;
      liProcess.Caption := IntToStr(PE.th32ProcessID);
      liProcess.SubItems.Add(PE.szExeFile);
      lpImagePath := PE.szExeFile;
      if CharLower(PChar(Copy(lpImagePath, 0, Length(SystemProcess) +1))) = SystemProcess then
      begin
        liProcess.SubItems.Add('[System idle Process]');
        continue;
      end else
      if CharLower(PChar(Copy(lpImagePath, 0, Length(System) +1))) = System then
      begin
        liProcess.SubItems.Add('[System]');
        continue;
      end else
      begin
        // get ImagePath Name
        hME := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, PE.th32ProcessID);
        ME.dwSize := sizeof(TModuleEntry32);
        Module32First(hMe, ME);
        ModulePath := String(ME.szExePath);
        // Path with \SystemRoot\
        if (LowerCase(Copy(ModulePath, 1, Length(SystemRoot))) = SystemRoot) then
          ModulePath := GetWinFolder + Copy(ModulePath, Length(SystemRoot), Length(ModulePath));
        // Path with \??\
        if (LowerCase(Copy(ModulePath, 1, Length(SystemUnknown))) = SystemUnknown) then
          ModulePath := Copy(ModulePath, Length(SystemUnknown) +1, Length(ModulePath));
        liProcess.SubItems.Add(ME.szExePath);
        liProcess.SubItems.Add(GetFileInfo(ModulePath, 'FileDescription'));
        liProcess.SubItems.Add(GetFileInfo(ModulePath, 'CompanyName'));
        AddIcon(ModulePath, liProcess);
        CloseHandle(hME);
      end;
    end;
    DestroyIcon(Icon.Handle);
  until (not Process32Next(hPE, PE));
  CloseHandle(hPE);
  StatusBar1.Panels[0].Text := 'Processes: ' + IntToStr(intProcess);
  StatusBar1.Panels[1].Text := 'Modules: ' + IntToStr(intModules);
  StatusBar1.Panels[2].Text := 'Idle';
end;

procedure TfrmMain.GetModuleList(PID: DWORD);
var
  ME: TModuleEntry32;
  hME: THandle;
  liModule: TListItem;
  intModules: Integer;
begin
  lvModules.Clear;
  intModules := 0;
  StatusBar1.Panels[2].Text := 'Refreshing ...';
  hME := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, PID);
  ME.dwSize := sizeof(TModuleEntry32);
  Module32First(hMe, ME);
  repeat
    Inc(intModules);
    liModule := lvModules.Items.Add;
    liModule.Caption := ME.szModule;
    liModule.SubItems.Add(ME.szExePath);
    liModule.SubItems.Add(GetFileInfo(ME.szExePath, 'FileDescription'));
    liModule.SubItems.Add(GetFileInfo(ME.szExePath, 'CompanyName'));
    AddIcon(ME.szExePath, liModule);
  until (not Module32Next(hMe, ME));
  StatusBar1.Panels[1].Text := 'Modules: ' + IntToStr(intModules);
  StatusBar1.Panels[2].Text := 'Idle';
end;

procedure TfrmMain.cbOnTopClick(Sender: TObject);
begin
  case cbOnTop.Checked of
    True:  Self.FormStyle:= fsStayOnTop;
    False: Self.FormStyle:= fsNormal;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  SHFileInfo: TSHFileInfo;
  h: THandle;
begin
  // True Color Icons?
  try
    h:= SHGetFileInfo(PChar(Copy(ParamStr(0), 1, 3)), 0, SHFileInfo, sizeof(SHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_ICON);
  finally
    DestroyIcon(SHFileInfo.hIcon);
  end;
  ImageList1.Handle := h;
  ImageList1.Clear;
  // ..
  GetDebugPrivilege;
  RefreshList;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Self.cbOnTopClick(Sender);
end;

procedure TfrmMain.lvProcessesClick(Sender: TObject);
begin
  lvModules.Clear;
  if lvProcesses.Selected = nil then Exit;
  if not IsInvalidProcess(lvProcesses.Selected.SubItems[1]) then
    GetModuleList(StrToInt(lvProcesses.Selected.Caption));
end;

procedure TfrmMain.PopupMenu1Popup(Sender: TObject);
begin
  if lvProcesses.Selected = nil then
  begin
    Popupmenu1.Items[0].Enabled := False;
    Exit;
  end;
  if IsInvalidProcess(lvProcesses.Selected.SubItems[1]) then
    Popupmenu1.Items[0].Enabled := False
  else
    Popupmenu1.Items[0].Enabled := True;
end;

procedure TfrmMain.PatchImagePath1Click(Sender: TObject);
begin
  try
    if lvProcesses.Selected <> nil then
    begin
      if not FileExists(lvProcesses.Selected.SubItems[1]) then Exit;
      frmImagePath:= TfrmImagePath.Create(frmImagePath);
      frmImagePath.Show;
      frmImagePath.lblFileName.Text := lvProcesses.Selected.SubItems[1];
      frmImagePath.dwRemotePID := StrToInt(lvProcesses.Selected.Caption);
      frmImagePath.Show;
    end;
  except
    Exit;
  end;
end;

procedure TfrmMain.tRefreshTimer(Sender: TObject);
begin
  RefreshList;
end;

procedure TfrmMain.PatchModuleFilename1Click(Sender: TObject);
begin
  if lvModules.Selected <> nil then
  begin
    try
      if not FileExists(lvModules.Selected.SubItems[0]) then Exit;
      frmModulePath:= TfrmModulePath.Create(frmImagePath);
      frmModulePath.Show;
      frmModulePath.dwRemotePID := StrToInt(lvProcesses.Selected.Caption);
      frmModulePath.lblOldFileName.Text := lvModules.Selected.SubItems[0];
      frmModulePath.lblFileName.Text := lvModules.Selected.SubItems[0];
      frmModulePath.Show;
    except
      Exit;
    end;
  end;
end;

end.
