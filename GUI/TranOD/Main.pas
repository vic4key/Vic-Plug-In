unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    tbTran: TTrackBar;
    Label1: TLabel;
    Button1: TButton;
    lbValue: TLabel;
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
  Form1: TForm1;
  a: Integer;

implementation

uses mrVic;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lbValue.Caption:= fm('%d',[8*5*100 div 255]) + '%';
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //ReleaseCapture;
  //SendMessageA(Self.Handle,WM_SYSCOMMAND,SC_MOVE or 2,0);
end;

procedure TForm1.tbTranChange(Sender: TObject);
var iVlTran: Integer;
begin
  iVlTran:= 5*tbTran.Position;
  a:= iVlTran;
  iVlTran:= iVlTran*100 div 255;
  lbValue.Caption:= fm('%d',[iVlTran]) + '%';
end;

end.
