program PEBPatcher;

uses
  Forms,
  untMain in 'untMain.pas' {frmMain},
  untPEB in 'untPeb.pas',
  untSttUnhooker in 'untSttUnhooker.pas',
  untPatchImagePath in 'untPatchImagePath.pas' {frmImagePath},
  untPatchModule in 'untPatchModule.pas' {frmModulePath};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmImagePath, frmImagePath);
  Application.CreateForm(TfrmModulePath, frmModulePath);
  Application.Run;
end.
