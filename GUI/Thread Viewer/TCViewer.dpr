program TCViewer;

uses
  Forms,
  uThreadMain in 'uThreadMain.pas' {frmThreadViewer},
  uTimerConfig in 'uTimerConfig.pas' {frmTimerConfig},
  Plugin in '..\..\Vic.Plug-In.2.xx\Plugin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmThreadViewer, frmThreadViewer);
  Application.CreateForm(TfrmTimerConfig, frmTimerConfig);
  Application.Run;
end.
