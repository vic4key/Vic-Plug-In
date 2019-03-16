unit uTimerConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uThreadMain;

type
  TfrmTimerConfig = class(TForm)
    Label1: TLabel;
    TxtTimer: TEdit;
    Button1: TButton;
    LbTime: TLabel;
    Label2: TLabel;
    procedure TxtTimerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Procedure Calculation(Time: DWORD);
  public
    iTime: DWORD;
  end;

var
  frmTimerConfig: TfrmTimerConfig;

implementation

Procedure TfrmTimerConfig.Calculation(Time: DWORD);
begin
  LbTime.Caption:= Format('%0.2d : %0.2d : %0.2d : %0.3d',
  [(Time mod 60*60*60*1000),
  Time mod 60*60*1000,
  Time mod 60*1000,
  Time mod 1000]);
end;

{$R *.dfm}

procedure TfrmTimerConfig.Button1Click(Sender: TObject);
begin
  frmThreadViewer.tmLoop.Interval:= iTime;
  Self.Close;
end;

procedure TfrmTimerConfig.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmThreadViewer.tmLoop.Enabled:= True;
  frmThreadViewer.mnStop.Enabled:= True;
  if (frmThreadViewer.chkbOnTop.Checked = True) then
  begin
    frmThreadViewer.Show;
  end;
end;

procedure TfrmTimerConfig.FormCreate(Sender: TObject);
begin
  TxtTimer.Text:= IntToStr(frmThreadViewer.tmLoop.Interval); // <--
  Calculation(frmThreadViewer.tmLoop.Interval);
end;

procedure TfrmTimerConfig.FormShow(Sender: TObject);
begin
  if (frmThreadViewer.chkbOnTop.Checked = True) then
  begin
    frmThreadViewer.Hide;
  end;
end;

procedure TfrmTimerConfig.TxtTimerChange(Sender: TObject);
begin
  iTime:= StrToInt(TxtTimer.Text); // <--
  Calculation(iTime);
end;

end.
