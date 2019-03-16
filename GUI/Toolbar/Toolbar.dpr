program Toolbar;

uses
  Forms,
  uTbMain in 'uTbMain.pas' {frmTB};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmTB, frmTB);
  Application.Run;
end.
