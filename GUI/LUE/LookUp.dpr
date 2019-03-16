program LookUp;

uses
  Forms,
  LUEMain in 'LUEMain.pas' {frmLUE};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLUE, frmLUE);
  Application.CreateForm(TfrmLUE, frmLUE);
  Application.Run;
end.
