unit untPatchModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, untPEB;

type
  TfrmModulePath = class(TForm)
    Button1: TButton;
    Button2: TButton;
    lblFileName: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    lblOldFileName: TLabeledEdit;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    dwRemotePID: DWORD;
    { Public declarations }
  end;

var
  frmModulePath: TfrmModulePath;

implementation

{$R *.dfm}

procedure TfrmModulePath.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    lblFileName.Text := OpenDialog1.FileName
end;

procedure TfrmModulePath.FormCreate(Sender: TObject);
begin
  SetWindowLongA(Button1.Handle,GWL_STYLE,(GetWindowLongA(Button1.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(Button2.Handle,GWL_STYLE,(GetWindowLongA(Button2.Handle,GWL_STYLE) or BS_FLAT));
end;

procedure TfrmModulePath.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmModulePath.Button1Click(Sender: TObject);
var
  hProcess: THandle;
  OldFileName, FileName: PWideChar;
begin
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, dwRemotePID);
  if hProcess <> 0 then
  begin
    OldFileName := PWideChar(WideString(lblOldFileName.Text));
    FileName := PWideChar(WideString(lblFileName.Text));
    untPEb.PatchModuleRemote(hProcess, OldFileName, FileName);
    MessageBox(Application.Handle, 'The PEB of this module Patched!','PEB', MB_ICONINFORMATION);
  end else
    MessageBox(Application.Handle, 'Cannot patch the PEB of this module','PEB', MB_ICONERROR);
  Close;
end;

end.
