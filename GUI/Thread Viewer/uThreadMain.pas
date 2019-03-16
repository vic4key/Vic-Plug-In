unit uThreadMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TlHelp32, ExtCtrls, Menus, Plugin;

type
  TfrmThreadViewer = class(TForm)
    GroupBox1: TGroupBox;
    cbThreads: TComboBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    TxtEAX: TEdit;
    TxtEBX: TEdit;
    TxtECX: TEdit;
    TxtEDX: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    TxtESI: TEdit;
    TxtEDI: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    TxtESP: TEdit;
    TxtEBP: TEdit;
    TxtEIP: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    TxtDr0: TEdit;
    TxtDr1: TEdit;
    TxtDr2: TEdit;
    TxtDr3: TEdit;
    TxtDr4: TEdit;
    TxtDr5: TEdit;
    TxtDr6: TEdit;
    TxtDr7: TEdit;
    Label18: TLabel;
    Label19: TLabel;
    LbEntry: TLabel;
    Label21: TLabel;
    LbTIB: TLabel;
    Label23: TLabel;
    LbPriority: TLabel;
    Label25: TLabel;
    LbState: TLabel;
    chkbOnTop: TCheckBox;
    Label20: TLabel;
    LbStatus: TLabel;
    tmLoop: TTimer;
    MainMenu1: TMainMenu;
    Action1: TMenuItem;
    mnReload: TMenuItem;
    mnStop: TMenuItem;
    mnResume: TMenuItem;
    Option1: TMenuItem;
    mnTimer: TMenuItem;
    procedure mnResumeClick(Sender: TObject);
    procedure mnStopClick(Sender: TObject);
    procedure mnTimerClick(Sender: TObject);
    procedure mnReloadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbThreadsCloseUp(Sender: TObject);
    procedure cbThreadsDropDown(Sender: TObject);
    procedure tmLoopTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkbOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbThreadsChange(Sender: TObject);
  private
    type TStatusType = (
      Error,
      Success,
      Warning,
      Normal);

    var dwThreadID: DWORD;
    
    Procedure CleanViewer;
    Procedure ThreadViewer(pTI: PThread);
    Procedure DoMyJob(dwThreadID: DWORD);
    Procedure SetStatus(StatusMessage: String; StatusType: TStatusType);
  public
    { Public declarations }
  end;

var
  frmThreadViewer: TfrmThreadViewer;
  PID: DWORD = 0;

implementation

uses uTimerConfig, uFcData, mrVic;

Procedure TfrmThreadViewer.CleanViewer;
begin
  LbEntry.Caption:= '00000000';
  LbTIB.Caption:= '00000000';
  LbPriority.Caption:= '-';
  LbState.Caption:= '-';

  TxtEAX.Text:= '';
  TxtEBX.Text:= '';
  TxtECX.Text:= '';
  TxtEDX.Text:= '';

  TxtESI.Text:= '';
  TxtEDI.Text:= '';

  TxtESP.Text:= '';
  TxtEBP.Text:= '';
  TxtEIP.Text:= '';

  TxtDr0.Text:= '';
  TxtDr1.Text:= '';
  TxtDr2.Text:= '';
  TxtDr3.Text:= '';
  TxtDr4.Text:= '';
  TxtDr5.Text:= '';
  TxtDr6.Text:= '';
  TxtDr7.Text:= '';
end;

Function MyGetThreadState(p: PThread): String;
begin
  if (p^.suspendcount = 0) then
  begin
    Result:= 'Running';
  end
  else
  begin
    Result:= 'Suspended';
  end;
end;

Function MyGetThreadPriority(p: PThread): String;
begin
  case GetThreadPriority(p^.thread) of
    THREAD_PRIORITY_ABOVE_NORMAL: Result:= 'Above';
    THREAD_PRIORITY_BELOW_NORMAL: Result:= 'Below';
    THREAD_PRIORITY_HIGHEST: Result:= 'Highest';
    THREAD_PRIORITY_IDLE: Result:= 'Idle';
    THREAD_PRIORITY_LOWEST: Result:= 'Lowest';
    THREAD_PRIORITY_NORMAL: Result:= 'Normal';
    THREAD_PRIORITY_TIME_CRITICAL: Result:= 'Critical';
    else Result:= '-';
  end;
end;

Procedure TfrmThreadViewer.ThreadViewer(pTI: PThread);
begin
  LbEntry.Caption:= IntToHex(pTI^.entry,8);
  LbTIB.Caption:= IntToHex(pTI^.tib,8);
  LbPriority.Caption:= MyGetThreadPriority(pTI);
  //LbState.Caption:= MyGetThreadState(pTI);

  TxtEAX.Text:= IntToHex(pTI^.context.Eax,8);
  TxtEBX.Text:= IntToHex(pTI^.context.Ebx,8);
  TxtECX.Text:= IntToHex(pTI^.context.Ecx,8);
  TxtEDX.Text:= IntToHex(pTI^.context.Edx,8);

  TxtESI.Text:= IntToHex(pTI^.context.Esi,8);
  TxtEDI.Text:= IntToHex(pTI^.context.Edi,8);

  TxtESP.Text:= IntToHex(pTI^.context.Esp,8);
  TxtEBP.Text:= IntToHex(pTI^.context.Ebp,8);
  TxtEIP.Text:= IntToHex(pTI^.context.Eip,8);

  TxtDr0.Text:= IntToHex(pTI^.context.Dr0,8);
  TxtDr1.Text:= IntToHex(pTI^.context.Dr1,8);
  TxtDr2.Text:= IntToHex(pTI^.context.Dr2,8);
  TxtDr3.Text:= IntToHex(pTI^.context.Dr3,8);
  TxtDr4.Text:= IntToHex(pTI^.dr[4],8);
  TxtDr5.Text:= IntToHex(pTI^.dr[5],8);
  TxtDr6.Text:= IntToHex(pTI^.dr[6],8);
  TxtDr7.Text:= IntToHex(pTI^.context.Dr7,8);
end;

Procedure TfrmThreadViewer.SetStatus(StatusMessage: String; StatusType: TStatusType);
begin
  case StatusType of
    Error: LbStatus.Font.Color:= clRed;
    Success: LbStatus.Font.Color:= clGreen;
    Warning: LbStatus.Font.Color:= clYellow;
    else LbStatus.Font.Color:= clWindowText;
  end;
  LbStatus.Caption:= StatusMessage;
end;

procedure TfrmThreadViewer.tmLoopTimer(Sender: TObject);
begin
  DoMyJob(dwThreadID);
end;

Procedure TfrmThreadViewer.DoMyJob(dwThreadID: DWORD);
var pTI: PThread;
begin
  CleanViewer;

  SetStatus('Nothing',Success);

  if (dwThreadID = 0) or (dwThreadID = $FFFFFFFF) then
  begin
    Exit;
  end;

  pTI:= FindThread(dwThreadID);
  if (pTI = NIL) then
  begin
    SetStatus('Could not read context',Error);
    Exit;
  end;

  SetStatus('Read context is success',Success);

  ThreadViewer(pTI);

end;

{$R *.dfm}

procedure TfrmThreadViewer.cbThreadsChange(Sender: TObject);
begin
  CleanViewer;
  
  SetStatus('Nothing',Success);

  dwThreadID:= HexToInt(cbThreads.Text);

  mnStop.Enabled:= True;
  mnResume.Enabled:= False;
end;

procedure TfrmThreadViewer.cbThreadsCloseUp(Sender: TObject);
begin
  tmLoop.Enabled:= True;
end;

procedure TfrmThreadViewer.cbThreadsDropDown(Sender: TObject);
begin
  tmLoop.Enabled:= False;
end;

procedure TfrmThreadViewer.chkbOnTopClick(Sender: TObject);
begin
  if (chkbOnTop.Checked = True) then
  begin
    Self.FormStyle:= fsStayOnTop;
  end
  else
  begin
    Self.FormStyle:= fsNormal;
  end;
end;

procedure TfrmThreadViewer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  tmLoop.Enabled:= False;
end;

procedure TfrmThreadViewer.FormCreate(Sender: TObject);
begin
  Self.chkbOnTop.OnClick(Sender);

  SetStatus('Nothing',Normal);
end;

procedure TfrmThreadViewer.FormShow(Sender: TObject);
var
  hSnap: THandle;
  te: TThreadEntry32;
begin
  mnStop.Enabled:= False;
  mnResume.Enabled:= False;
  tmLoop.Enabled:= False;

  cbThreads.Clear;
  CleanViewer;

  ODData:= GetODData;

  PID:= ODData.processid;

  hSnap:= CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD,PID);
  if (hSnap = INVALID_HANDLE_VALUE) then
  begin
    SetStatus('Could not create process snapshot',Error);
    Exit;
  end;

  //SetStatus('Create process snapshot is success',Success);

  ZeroMemory(@te,sizeof(te));

  te.dwSize:= sizeof(te);

  if (Thread32First(hSnap,te) = False) then
  begin
    SetStatus('Could not found thread',Error);
    CloseHandle(hSnap);
    Exit;
  end;

  //SetStatus('Found thread',Success);

  repeat
    if (te.th32OwnerProcessID = PID) then
    begin
      cbThreads.Items.Add(IntToHex(te.th32ThreadID,8));
    end;
  until (Thread32Next(hSnap,te) = False);

  CloseHandle(hSnap);
end;

procedure TfrmThreadViewer.mnReloadClick(Sender: TObject);
begin
  tmLoop.Enabled:= False;
  CleanViewer;

  Self.OnShow(Sender);

  if (cbThreads.ItemIndex = -1) then
  begin
    SetStatus('Nothing',Normal);
    Exit;
  end;

  Self.cbThreads.OnChange(Sender);
end;

procedure TfrmThreadViewer.mnResumeClick(Sender: TObject);
begin
  tmLoop.Enabled:= True;
  mnStop.Enabled:= True;
  mnResume.Enabled:= False;
end;

procedure TfrmThreadViewer.mnStopClick(Sender: TObject);
begin
  tmLoop.Enabled:= False;
  mnResume.Enabled:= True;
  mnStop.Enabled:= False;
end;

procedure TfrmThreadViewer.mnTimerClick(Sender: TObject);
begin
  tmLoop.Enabled:= False;

  if (Self.chkbOnTop.Checked = True) then
  begin
    frmTimerConfig.Show;
  end
  else
  begin
    frmTimerConfig.ShowModal;
  end;
end;

end.
