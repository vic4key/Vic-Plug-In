unit uTbMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ExtCtrls;

type
  TfrmTB = class(TForm)
    btnNotepad: TButton;
    btnFolder: TButton;
    btnCalc: TButton;
    btnCmd: TButton;
    btnExit: TButton;
    Timer1: TTimer;
    gfc: TEdit;
    procedure Timer1Timer(Sender: TObject);
    procedure btnCmdClick(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnNotepadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TODPos = record
    Left, Top, Width, Height: Integer
  end;

var
  frmTB: TfrmTB;
  odrc: TODPos;

Procedure VIC_ShowToolbar;

implementation

uses uFcData;

Procedure VIC_ShowToolbar;
begin
  try
    frmTB:= TfrmTB.Create(frmTB);
    //frmTB.ParentWindow:= hODbg;
    frmTB.Show;
  except
    Exit;
  end;
end;

Procedure ShellCommand(cmdline: String);
var cmdbuffer: array[0..MAX_PATH] of Char;
begin
  GetEnvironmentVariable('COMSPEC',cmdBUffer,SizeOf(cmdBuffer));
  StrCat(cmdbuffer,' /C ');
  StrPCopy(StrEnd(cmdbuffer), cmdline);
  WinExec(cmdbuffer,SW_HIDE);
end;

Procedure GetODRect(HandleOD: hWnd; var stRC: TODPos);
var rc: TRECT;
begin
  ZeroMemory(@stRC,SizeOf(stRC));
  GetWindowRect(HandleOD,rc);
  with stRC do
  begin
    Left:= rc.Left;
    Top:= rc.Top;
    Width:= rc.Right - rc.Left;
    Height:= rc.Bottom - rc.Top;
  end;
end;

Procedure MovingToolbar(Handle: THandle; Frm: TForm);
var
  wp: TWindowPlacement;
  tbTopDelta: Integer;
begin
  if (uFcData.bOllyMoving = False) then Exit;

  //OutputDebugStringA('Moving');

  tbTopDelta:= 0;
  GetODRect(hwODbg,odrc);

  ZeroMemory(@wp, sizeof(wp));
  if GetWindowPlacement(HWND(hwODbg), @wp) then
  begin
    if (wp.showCmd = SW_SHOWMAXIMIZED) then tbTopDelta:= 8 else tbTopDelta:= 0;
  end;

  MoveWindow(
    Handle,
    odrc.Left + odrc.Width - Frm.Width - 145,
    odrc.Top + tbTopDelta,
    frm.Width,
    frm.Height,
    True);

  uFcData.bOllyMoving:= False;
end;

Procedure CombineButton(frmFullRgn: HRGN; frmX, frmY: Integer; btn: TButton); stdcall;
var
  btnRgn: HRGN;
  iX, iY: Integer;
begin
  iX:= frmX + btn.Left;
  iY:= frmY + btn.Top;
  btnRgn:= CreateRectRgn(iX,iY,iX + btn.Width,iY + btn.Height);
  CombineRgn(frmFullRgn,frmFullRgn,btnRgn,RGN_OR);
end;

{$R *.dfm}

procedure TfrmTB.btnCalcClick(Sender: TObject);
begin
  ShellExecuteA(Self.Handle,'open','calc.exe','',NIL,SW_SHOWNORMAL);
  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.btnCmdClick(Sender: TObject);
begin
  ShellCommand('start "' + fdir + '" /normal /d "' + fdir + '"');
  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.btnExitClick(Sender: TObject);
begin
  fTbShow:= 1;
  SendMessageA(frmTB.Handle,WM_CLOSE,0,0);
  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.btnFolderClick(Sender: TObject);
begin
  ShellExecuteA(Self.Handle,PAnsiChar('explore'),PAnsiChar(fdir),NIL,NIL,SW_SHOWNORMAL);
  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.btnNotepadClick(Sender: TObject);
begin
  ShellExecuteA(Self.Handle,'open','notepad.exe','',NIL,SW_SHOWNORMAL);
  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.FormCreate(Sender: TObject);
var
  FullRgn, ClientRgn: THandle;
  Margin, X, Y, MMCSize: Integer;
  ODWnd: TODPos;
begin
  GetODRect(hwODbg,ODWnd);
  Self.Left:= ODWnd.Left + ODWnd.Width - Self.Width - 150;
  Self.Top:=  ODWnd.Top + 2;

  SetWindowLongA(Self.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);
  SetWindowLongA(Self.Handle,GWL_STYLE,Integer(WS_POPUP or WS_VISIBLE));
  SetWindowLongA(Self.Handle,GWL_HWNDPARENT,hwODbg);
  
  SetWindowLongA(btnNotepad.Handle,GWL_STYLE,GetWindowLongA(btnNotepad.Handle,GWL_STYLE) or BS_FLAT);
  SetWindowLongA(btnFolder.Handle,GWL_STYLE,GetWindowLongA(btnFolder.Handle,GWL_STYLE) or BS_FLAT);
  SetWindowLongA(btnCalc.Handle,GWL_STYLE,GetWindowLongA(btnCalc.Handle,GWL_STYLE) or BS_FLAT);
  SetWindowLongA(btnCmd.Handle,GWL_STYLE,GetWindowLongA(btnCmd.Handle,GWL_STYLE) or BS_FLAT);
  SetWindowLongA(btnExit.Handle,GWL_STYLE,GetWindowLongA(btnExit.Handle,GWL_STYLE) or BS_FLAT);

  MMCSize:= GetSystemMetrics(SM_CYSIZE);
  if (MMCSize <> 0) then
  begin
    btnNotepad.Height:= MMCSize;
    btnFolder.Height:= MMCSize;
    btnCalc.Height:= MMCSize;
    btnCmd.Height:= MMCSize;
    btnExit.Height:= MMCSize;
  end;

  Margin:= (Width - ClientWidth) div 2;

  FullRgn:= CreateRectRgn(0,0,Width,Height);

  X:= Margin;
  Y:= Height - ClientHeight - Margin;

  ClientRgn:= CreateRectRgn(X,Y,X + ClientWidth,Y + ClientHeight);

  CombineRgn(FullRgn,FullRgn,ClientRgn,RGN_DIFF);

  CombineButton(FullRgn,X,Y,btnNotepad);
  CombineButton(FullRgn,X,Y,btnFolder);
  CombineButton(FullRgn,X,Y,btnCalc);
  CombineButton(FullRgn,X,Y,btnCmd);
  CombineButton(FullRgn,X,Y,btnExit);

  SetWindowRgn(Handle,FullRgn,True);

  Windows.SetFocus(gfc.Handle);
end;

procedure TfrmTB.Timer1Timer(Sender: TObject);
begin
  MovingToolbar(Self.Handle,frmTB);
end;

end.
