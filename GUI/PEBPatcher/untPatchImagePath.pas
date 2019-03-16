unit untPatchImagePath;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, untPEB;

type
  TfrmImagePath = class(TForm)
    Button1: TButton;
    Button2: TButton;
    lblFileName: TLabeledEdit;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    dwRemotePID: DWORD;
    { Public declarations }
  end;

var
  frmImagePath: TfrmImagePath;

implementation

{$R *.dfm}

procedure TfrmImagePath.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmImagePath.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    lblFileName.Text:= OpenDialog1.FileName;
end;

procedure TfrmImagePath.FormCreate(Sender: TObject);
begin
  SetWindowLongA(Button1.Handle,GWL_STYLE,(GetWindowLongA(Button1.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(Button2.Handle,GWL_STYLE,(GetWindowLongA(Button2.Handle,GWL_STYLE) or BS_FLAT));
end;

procedure TfrmImagePath.Button1Click(Sender: TObject);
var
  hProcess: THandle;
  FileName: PWideChar;
begin
  hProcess:= OpenProcess(PROCESS_ALL_ACCESS,False,dwRemotePID);
  if hProcess <> 0 then
  begin
    FileName:= PWideChar(WideString(lblFileName.Text));
    untPeb.PatchImagePathRemote(hProcess,FileName);
    MessageBox(Application.Handle,'The PEB of ImagePath patched!','PEB',MB_ICONINFORMATION);
  end else MessageBox(Application.Handle,'Cannot patch the PEB of ImagePath','PEB Patched', MB_ICONERROR);
  Close;
end;

end.
