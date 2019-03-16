program MapLoader;

uses
  Forms,
  uMapMain in 'uMapMain.pas' {frmMapLoader},
  MapLoader in 'MapLoader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMapLoader, frmMapLoader);
  Application.Run;
end.
