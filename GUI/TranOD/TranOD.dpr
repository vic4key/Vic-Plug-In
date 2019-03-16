program TranOD;

uses
  Forms,
  frmTran in 'frmTran.pas' {frmTranOD},
  uFcData in '..\..\Plugin\uFcData.pas',
  untPeb in '..\PEBPatcher\untPeb.pas',
  untSttUnhooker in '..\PEBPatcher\untSttUnhooker.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmTranOD, frmTranOD);
  Application.Run;
end.
