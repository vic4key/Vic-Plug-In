program p_dll_process_viewer;

uses
  Forms,
  u_dll_process_viewer in 'u_dll_process_viewer.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDLLPV,DLLPV);
  Application.Run;
end.
