unit LUEMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmLUE = class(TForm)
    GroupBox1: TGroupBox;
    txtCode: TEdit;
    GroupBox2: TGroupBox;
    btnLookup: TButton;
    txtFmMsg: TMemo;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLookupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLUE: TfrmLUE;

implementation

uses mrVic, uFcData;

{$R *.dfm}

procedure TfrmLUE.btnLookupClick(Sender: TObject);
var
  uiErrorCode: UInt;
  Buffer: array[0..MAXBYTE] of Char;
begin
  if (txtCode.Text = '') then
  begin
    MessageBoxW(GetActiveWindow,'Please input the error code!',PLUGIN_NAME,MB_ICONWARNING);
    Exit;
  end;

  uiErrorCode:= StrToInt(txtCode.Text);

  ZeroMemory(@Buffer,sizeof(Buffer));
  
  FormatMessageA(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NIL,
    uiErrorCode,
    LANG_USER_DEFAULT,
    @Buffer,
    sizeof(Buffer),
    NIL);

  if (lstrlenA(Buffer) = 0) then
  begin
    MessageBoxW(GetActiveWindow,'The error code you''re entered is invalid!',PLUGIN_NAME,MB_ICONHAND);
    Exit;
  end;

  txtFmMsg.Clear;
  txtFmMsg.Lines.SetText(Buffer);
end;

procedure TfrmLUE.cbOnTopClick(Sender: TObject);
begin
  if cbOnTop.Checked then
    Self.FormStyle:= fsStayOnTop
  else
    Self.FormStyle:= fsNormal;
end;

procedure TfrmLUE.FormCreate(Sender: TObject);
begin
  SetWindowLongA(btnLookup.Handle,GWL_STYLE,(GetWindowLongA(btnLookup.Handle,GWL_STYLE) or BS_FLAT));
  txtFmMsg.Clear;
end;

procedure TfrmLUE.FormShow(Sender: TObject);
begin
  Self.cbOnTopClick(Sender);
end;

end.
