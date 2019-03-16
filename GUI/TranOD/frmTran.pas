unit frmTran;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmTranOD = class(TForm)
    tbTran: TTrackBar;
    Label1: TLabel;
    Button1: TButton;
    lbValue: TLabel;
    CheckBox1: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure tbTranChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTranOD: TfrmTranOD;
  iVlTran: Integer;

implementation

uses mrVic, uFcData, Plugin;

{$R *.dfm}

procedure TfrmTranOD.Button1Click(Sender: TObject);
begin
  {$IF __VERSION__ = 1.10}
  SaveIntCfg(hPlg,TranODcfg,iAlpha);
  {$IFEND}
  {$IF __VERSION__ = 2.01}
  SaveCfg(NIL,PLUGIN_NAME,TranODcfg,'%d',iAlpha);
  {$IFEND}
  Close;
end;

procedure TfrmTranOD.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then FormStyle:= fsStayOnTop else FormStyle:= fsNormal;
end;

procedure TfrmTranOD.FormCreate(Sender: TObject);
begin
  SetWindowLongA(Button1.Handle,GWL_STYLE,(GetWindowLongA(Button1.Handle,GWL_STYLE) or BS_FLAT));
  tbTran.Position:= iAlpha div 5;
  lbValue.Caption:= fm('%d',[100 - (tbTran.Position*5*100 div 255)]) + '%';
end;

procedure TfrmTranOD.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ReleaseCapture;
  SendMessageA(Self.Handle,WM_SYSCOMMAND,SC_MOVE or 2,0);
end;

procedure TfrmTranOD.FormShow(Sender: TObject);
begin
  Self.CheckBox1.OnClick(Sender);
end;

procedure TfrmTranOD.tbTranChange(Sender: TObject);
var iVlTran: Integer;
begin
  iVlTran:= 5*tbTran.Position;
  iAlpha:= iVlTran;
  ViC_Transparent(hwODbg,iAlpha);
  iVlTran:= iVlTran*100 div 255;
  lbValue.Caption:= fm('%d',[100 - iVlTran]) + '%';
end;

end.
