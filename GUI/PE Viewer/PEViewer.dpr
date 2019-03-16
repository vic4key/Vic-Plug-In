program PEViewer;

uses
  Forms,
  pevChrts in 'pevChrts.pas' {Crtics},
  pevie in 'pevie.pas' {IETable},
  pevMain in 'pevMain.pas' {PE_Viewer},
  untPeb in '..\PEBPatcher\untPeb.pas',
  untSttUnhooker in '..\PEBPatcher\untSttUnhooker.pas';

{$R *.res}

begin
  Application.Initialize;
  //Application.Title := 'PE文件信息速览';
  Application.CreateForm(TPE_Viewer, PE_Viewer);
  Application.CreateForm(TCrtics, Crtics);
  Application.CreateForm(TIETable, IETable);
  Application.Run;
end.
