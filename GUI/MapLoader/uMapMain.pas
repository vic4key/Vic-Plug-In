unit uMapMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TlHelp32;

type
  TfrmMapLoader = class(TForm)
    GroupBox1: TGroupBox;
    cbLoadedModules: TComboBox;
    btnLoad: TButton;
    GroupBox2: TGroupBox;
    rbLabel: TRadioButton;
    rbComment: TRadioButton;
    Label1: TLabel;
    lbStatus: TLabel;
    GroupBox3: TGroupBox;
    txtMapFile: TEdit;
    btnOpenMapFile: TButton;
    OpenDialog1: TOpenDialog;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure OpenDialog1Close(Sender: TObject);
    procedure OpenDialog1Show(Sender: TObject);
    procedure btnOpenMapFileClick(Sender: TObject);
    procedure cbLoadedModulesSelect(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TMod = packed record
    ImageBase: DWORD;
    Name: String;
    Path: String;
  end;

const
  ORIGINAL_TITLE: TCaption = 'Map File Importer';

var
  frmMapLoader: TfrmMapLoader;
  ModuleList: array[0..500] of TMod;
  Index: Integer = 0;
  LineMapped: DWORD = 0;

implementation

uses Plugin, uFcData, MapLoader, mrVic;

Function LoadedModulesListing(const dwPID: DWORD): Integer; stdcall;
var
  hSnap: THandle;
  me: TModuleEntry32;
begin
  Result:= 0;
  
  hSnap:= CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwPID);
  if (hSnap = INVALID_HANDLE_VALUE) then
  begin
    Result:= 1;
    Exit;    
  end;

  ZeroMemory(@me,sizeof(me));
  
  me.dwSize:= sizeof(me);

  if (Module32First(hSnap,me) = False) then
  begin
    Result:= 2;
    CloseHandle(hSnap);
    Exit;
  end;

  repeat
    ModuleList[Index].ImageBase:= DWORD(me.modBaseAddr);
    ModuleList[Index].Name:= StrPas(PAnsiChar(@me.szModule));
    ModuleList[Index].Path:= StrPas(PAnsiChar(@me.szExePath));
    frmMapLoader.cbLoadedModules.Items.Add(Format('%0.8X - %s',[ModuleList[Index].ImageBase,ModuleList[Index].Name]));
    Inc(Index);
  until (Module32Next(hSnap,me) = False);

  CloseHandle(hSnap);
end;

Procedure SetStatus(StatusMessage: String);
begin
  frmMapLoader.lbStatus.Caption:= StatusMessage;
end;

Procedure fnMapThread;
begin
  frmMapLoader.btnLoad.Enabled:= False;
  frmMapLoader.cbLoadedModules.Enabled:= False;
  frmMapLoader.btnOpenMapFile.Enabled:= False;

  SetStatus('Working... Don''t close while done.');
  LineMapped:= ImportingThread;
  if (LineMapped <> 0) then
  begin
    if (fImportType = True) then
    begin
      SetStatus(Format('Have %d labels imported from map file',[LineMapped]));
    end
    else
    begin
      SetStatus(Format('Have %d comments imported from map file',[LineMapped]));
    end;
  end
  else
  begin
    SetStatus('Cancel to import map file');
  end;

  frmMapLoader.btnLoad.Enabled:= True;
  frmMapLoader.cbLoadedModules.Enabled:= True;
  frmMapLoader.btnOpenMapFile.Enabled:= True;

  CloseHandle(hImportThread);
end;

{$R *.dfm}

procedure TfrmMapLoader.btnLoadClick(Sender: TObject);
var dwThreadId: DWORD;
begin
  if (dwImageBase = 0) then
  begin
    StatusFlash('Modules image base is invalid');
    MessageBeep(MB_ICONASTERISK);
    Exit;
  end;

  if (MapFilePath = '') then
  begin
    SetStatus('Please choose a map file');
    btnOpenMapFile.OnClick(Sender);
    if (MapFilePath = '') then
    begin
      Exit;
    end;
  end;

  if (rbLabel.Checked = True) then
  begin
    fImportType:= True;
  end
  else
  begin
    fImportType:= False;
  end;
  
  hImportThread:= CreateThread(NIL,0,@fnMapThread,NIL,0,dwThreadId);
end;

procedure TfrmMapLoader.btnOpenMapFileClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:= ExtractFilePath(PEFilePath);
  OpenDialog1.Title:= Format('Open map file for %s',[ExtractFileName(PEFilePath)]);
  if (OpenDialog1.Execute(Self.Handle) = True) then
  begin
    MapFilePath:= OpenDialog1.FileName;
    txtMapFile.Text:= MapFilePath;
  end;
  
  if (MapFilePath = '') then
  begin
    SetStatus('Please choose a map file');
    MessageBeep(MB_ICONWARNING);
  end;
end;

procedure TfrmMapLoader.cbLoadedModulesSelect(Sender: TObject);
begin
  SetStatus('Nothing');

  btnOpenMapFile.Enabled:= True;
  txtMapFile.Text:= '';
  MapFilePath:= '';

  dwImageBase:= ModuleList[cbLoadedModules.ItemIndex].ImageBase;
  PEFilePath:=  ModuleList[cbLoadedModules.ItemIndex].Path;

  Self.Caption:= Format('%s [%s]',[ORIGINAL_TITLE,ExtractFileName(PEFilePath)]);
end;

procedure TfrmMapLoader.cbOnTopClick(Sender: TObject);
begin
  if (cbOnTop.Checked = True) then
  begin
    Self.FormStyle:= fsStayOnTop;
  end
  else
  begin
    Self.FormStyle:= fsNormal;
  end;
end;

procedure TfrmMapLoader.FormCreate(Sender: TObject);
begin
  SetWindowLong(btnLoad.Handle,GWL_STYLE,GetWindowLong(btnLoad.Handle,GWL_STYLE) or BS_FLAT);
  SetWindowLong(btnOpenMapFile.Handle,GWL_STYLE,GetWindowLong(btnOpenMapFile.Handle,GWL_STYLE) or BS_FLAT);
end;

procedure TfrmMapLoader.FormShow(Sender: TObject);
var myPID: DWORD;
begin
  if (cbLoadedModules.Items.Count <> 0) then
  begin
    Exit;  
  end;

  Self.cbOnTopClick(Sender);

  SetStatus('Nothing');
  txtMapFile.Text:= '';
  MapFilePath:= '';

  ODData:= GetODData;
  myPID:= ODData.processid;

  if (myPID = 0) then
  begin
    SetStatus('No process');
    Exit;
  end;

  Self.Caption:= Format('%s [%s]',[ORIGINAL_TITLE,ExtractFileName(WideCharToString(ODData.executable))]);

  btnLoad.Enabled:= True;

  ZeroMemory(@ModuleList,sizeof(ModuleList));
  Index:= 0;

  if (LoadedModulesListing(myPID) = 0) then
  begin
    Self.cbLoadedModules.ItemIndex:= 0;
    dwImageBase:= ModuleList[cbLoadedModules.ItemIndex].ImageBase;
    PEFilePath:=  ModuleList[cbLoadedModules.ItemIndex].Path;

    btnOpenMapFile.Enabled:= True;
  end;
end;

procedure TfrmMapLoader.OpenDialog1Close(Sender: TObject);
begin
  if (cbOnTop.Checked = True) then
  begin
    Self.Show;
  end;
end;

procedure TfrmMapLoader.OpenDialog1Show(Sender: TObject);
begin
  if (cbOnTop.Checked = True) then
  begin
    Self.Hide;
  end;
end;

end.
