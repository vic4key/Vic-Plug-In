program DATAConverter;

uses
  Forms,
  uDCMain in 'uDCMain.pas' {frmDC};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDC, frmDC);
  Application.Run;
end.
