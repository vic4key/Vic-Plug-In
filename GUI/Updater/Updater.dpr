program Updater;

uses
  Forms,
  uUpdater in 'uUpdater.pas' {frmUpdater};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmUpdater, frmUpdater);
  Application.Run;
end.
