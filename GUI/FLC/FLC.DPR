program FLC;

uses
  Forms,
  FLCMain in 'FLCMain.pas' {frmFLC},
  uFcData in '..\..\Plugin\uFcData.pas',
  untPeb in '..\PEBPatcher\untPeb.pas',
  untSttUnhooker in '..\PEBPatcher\untSttUnhooker.pas',
  Plugin in '..\..\Plugin\Plugin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmFLC, frmFLC);
  Application.Run;
end.
