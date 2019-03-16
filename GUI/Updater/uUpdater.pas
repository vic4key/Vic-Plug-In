unit uUpdater;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, WinInet, LibXmlParser, LibXmlComps, ShellAPI;

type
  TfrmUpdater = class(TForm)
    BtnStart: TButton;
    ProgressBarDownload: TProgressBar;
    List: TMemo;
    TrvDoc: TTreeView;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    LbFileName: TLabel;
    LbFileSize: TLabel;
    LbDownloaded: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    LbStatus: TLabel;
    Label3: TLabel;
    LbFileCount: TLabel;
    chkOnTop: TCheckBox;
    Label5: TLabel;
    Label6: TLabel;
    txtSaveDir: TEdit;
    procedure FormShow(Sender: TObject);
    procedure chkOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
  private
    XmlParser: TXmlParser;
    type TStatusType = (
      Error,
      Success,
      Warning,
      Normal);
    Function Download(svFilePath, clFilePath: String; dwSize: DWORD): Boolean; stdcall;
    Function FmtFileSize(Size: DWORD): String; stdcall;
    Procedure SetStatus(StatusMessage: String; StatusType: TStatusType); stdcall;
    Procedure GetDownloadFileList;
  public
    Elements: TObjectList;
    Procedure FillTree;
  end;

type
  TElementNode = class
    content: AnsiString;
    attr: TStringList;
    constructor Create(TheContent: AnsiString; TheAttr: TNvpList);
    destructor Destroy; override;
  end;

type
  TFile = record
    Name: String;
    Size: DWORD;
  end;
  PFile = ^TFile;

const
  KiB = 1024;
  MiB = KiB*KiB;

  Img_Tag          = 0;
  Img_TagWithAttr  = 1;
  Img_UndefinedTag = 2;
  Img_AttrDef      = 3;
  Img_EntityDef    = 4;
  Img_ParEntityDef = 5;
  Img_Text         = 6;
  Img_Comment      = 7;
  Img_PI           = 8;
  Img_DTD          = 9;
  Img_Notation     = 10;
  Img_Prolog       = 11;

  CRLF             = ^M^J;

var
  //URL_ROOT: String;// = 'http://mrvic.byethost8.com/update/p1/';
  URL_FILES: String = '';// = URL_UPDATE + 'files/';
  CLIENT_PATH: String = '';// = 'E:\';

  frmUpdater: TfrmUpdater;
  FileList: array of TFile;

implementation

uses uFcData, mrVic, Plugin, LUEMain;

constructor TElementNode.Create(TheContent: AnsiString; TheAttr: TNvpList);
var i: Integer;
begin
  inherited Create;
  content:= TheContent;
  attr:= TStringList.Create;
  if (TheAttr <> NIL) then
    for i:= 0 to TheAttr.Count - 1 do
      Attr.Add(String(TNvpNode(TheAttr[I]).Name) + ' = ' + String(TNvpNode(TheAttr[I]).Value));
end;

destructor TElementNode.Destroy;
begin
  Attr.Free;
  inherited Destroy;
end;

Procedure TfrmUpdater.FillTree;

Procedure ScanElement(Parent: TTreeNode);
VAR
  Node: TTreeNode;
  Strg: AnsiString;
  EN: TElementNode;
BEGIN
  WHILE XmlParser.Scan DO
  BEGIN
    Node:= NIL;
    CASE XmlParser.CurPartType OF
      ptXmlProlog:
        BEGIN
        Node := TrvDoc.Items.AddChild (Parent, '<?xml?>');
        Node.ImageIndex := Img_Prolog;
        EN := TElementNode.Create (StrSFPas(XmlParser.CurStart, XmlParser.CurFinal), NIL);
        Node.Data := EN;
      END;
      ptDtdc:
        BEGIN
        Node := TrvDoc.Items.AddChild (Parent, 'DTD');
        Node.ImageIndex := Img_Dtd;
        EN := TElementNode.Create(StrSFPas(XmlParser.CurStart, XmlParser.CurFinal), NIL);
        Node.Data := EN;
      END;
      ptStartTag, ptEmptyTag:
      BEGIN
        Node:= TrvDoc.Items.AddChild(Parent,String(XmlParser.CurName));
        IF XmlParser.CurAttr.Count > 0 THEN
        BEGIN
          Node.ImageIndex:= Img_TagWithAttr;
          EN:= TElementNode.Create('',XmlParser.CurAttr);
          Elements.Add(EN);
          Node.Data:= EN;
        END
        ELSE Node.ImageIndex:= Img_Tag;
        IF XmlParser.CurPartType = ptStartTag THEN ScanElement (Node);
      END;
      ptEndTag: Break;
      ptContent, ptCData:
      BEGIN
        if Length(XmlParser.CurContent) > 40 then Strg:= Copy(XmlParser.CurContent,1,40) + #133
        else Strg:= XmlParser.CurContent;
        Node:= TrvDoc.Items.AddChild(Parent,String(Strg));  // !!!
        Node.ImageIndex:= Img_Text;
        EN:= TElementNode.Create(XmlParser.CurContent,NIL);
        Node.Data:= EN;
      END;
      ptComment:
      BEGIN
        Node:= TrvDoc.Items.AddChild(Parent,'Comment');
        Node.ImageIndex:= Img_Comment;
        SetStringSF(Strg,XmlParser.CurStart + 4,XmlParser.CurFinal-3);
        EN:= TElementNode.Create(TrimWs(Strg),NIL);
        Node.Data:= EN;
      END;
      ptPI:
      BEGIN
        Node:= TrvDoc.Items.AddChild(Parent,String(XmlParser.CurName) + ' ' + String(XmlParser.CurContent));
        Node.ImageIndex := Img_PI;
      END;
    END;
    IF (Node <> NIL) THEN Node.SelectedIndex:= Node.ImageIndex;
  END;
END;

begin
  TrvDoc.Items.BeginUpdate;
  TrvDoc.Items.Clear;
  XmlParser.Normalize := TRUE;
  XmlParser.StartScan;
  ScanElement (NIL);
  TrvDoc.Items.EndUpdate;
end;

Procedure TfrmUpdater.GetDownloadFileList;
var
  i: Integer;
  Root, Node, Pro: TTreeNode;
begin
  Root:= TrvDoc.Items.Item[0]; // files
  SetLength(FileList,Root.Count);
  for i:= 0 to Root.Count - 1 do
  begin
    Node:= Root.Item[i]; // file
    if (Node <> NIL) then
    begin
      Pro:= Node.Item[0]; // name
      FileList[i].Name:= Pro.Item[0].Text;
      Pro:= Node.Item[1]; // size
      FileList[i].Size:= DWORD(StrToInt64(Pro.Item[0].Text));
    end;
  end;
end;

Procedure ThreadUpdate; stdcall;
var i, Num: Integer; args, szApplyUpdate, szRealFileName: String;
begin
  frmUpdater.BtnStart.Enabled:= False;

  Num:= Length(FileList);
  for i:= 0 to Num - 1 do
  begin
    szRealFileName := FakeFileToRealFile(FileList[i].Name);
    frmUpdater.LbFileName.Caption:= szRealFileName;
    frmUpdater.LbFileSize.Caption:= frmUpdater.FmtFileSize(FileList[i].Size);
    frmUpdater.LbFileCount.Caption:= Format('%d / %d',[i + 1,Num]);
    if (frmUpdater.Download(
      uUpdater.URL_FILES + FileList[i].Name,
      uUpdater.CLIENT_PATH + szRealFileName,
      FileList[i].Size) = False) then
    begin
      frmUpdater.SetStatus('Update failed. Please try again!',Error);
      frmUpdater.BtnStart.Enabled:= True;
      ExitThread(0);
    end;
    frmUpdater.List.Lines.Add(Format('%-s',[szRealFileName]));
  end;

  frmUpdater.SetStatus('New files download is completed!',Success);

  frmUpdater.BtnStart.Enabled:= True;

  if (MessageBoxA(
    frmUpdater.Handle,
    'New files download is complete.'#13#10#13#10'Would you like to apply update right now?',
    'Vic''s Updater',
    MB_OKCANCEL
  ) = IDOK) then
  begin
    szApplyUpdate := GetApplyUpdatePath;
    //szApplyUpdate := 'F:\ApplyUpdate.exe';

    args := fm('"%s\" "%s\\" %d', [uUpdater.CLIENT_PATH, OLLYDBG_PLUGIN_DIR, GetCurrentProcessId]);

    ShellExecuteA(0,
      'runas',
      StrToPac(szApplyUpdate),
      StrToPac(args),
      StrToPac(ExtractFileDir(szApplyUpdate)),
      SW_NORMAL
    );

    frmUpdater.Close;
  end;

  //ExitThread(0);
end;

procedure TfrmUpdater.chkOnTopClick(Sender: TObject);
begin
  if chkOnTop.Checked then
    Self.FormStyle:= fsStayOnTop
  else
    Self.FormStyle:= fsNormal;
end;

Function TfrmUpdater.Download(svFilePath, clFilePath: String; dwSize: DWORD): Boolean; stdcall;
var
  hFile: THandle;
  phInet, phUrl: HINTERNET;
  dwDownloadedSize, dwTimeout, dwRead: DWORD;
  Percent: Real;
  Buffer: array[0..KiB] of Byte;
begin
  Result:= True;

  try
    //SetStatus('Internet is opening...',Normal);

    phInet:= InternetOpenA('MyAngent',INTERNET_OPEN_TYPE_PRECONFIG,NIL,NIL,0);
    if (phInet = NIL) then
    begin
      SetStatus('Could not open Internet',Error);
      Result:= False;
      Exit;
    end;

    //SetStatus('Internet opened',Success);

    //SetStatus('Session is creating...',Normal);

    phUrl:= InternetOpenUrlA(
      phInet,
      PAnsiChar(svFilePath),
      NIL,
      0,
      INTERNET_FLAG_RELOAD or INTERNET_FLAG_DONT_CACHE,
      0);
    if (phUrl = NIL) then
    begin
      SetStatus('Could not create session',Error);
      InternetCloseHandle(phInet);
      Result:= False;
      Exit;
    end;

    dwTimeout:= 5000; // 5s
    InternetSetOption(phUrl,INTERNET_OPTION_CONNECT_TIMEOUT,@dwTimeout,sizeof(dwTimeout));

    //SetStatus('Session created',Success);

    if (FileExists(clFilePath) = True) then
    begin
      hFile:= FileOpen(clFilePath, fmOpenReadWrite or fmShareDenyNone);
    end
    else
    begin
      hFile:= FileCreate(clFilePath);
    end;
    if (hFile = INVALID_HANDLE_VALUE) then
    begin
      InternetCloseHandle(phUrl);
      InternetCloseHandle(phInet);
      SetStatus('Could not create file',Error);
      Result:= False;
      Exit;
    end;

    SetStatus('Downloading...',Warning);
  
    dwDownloadedSize:= 0;
    dwRead:= 0;
    try
      ProgressBarDownload.Position:= 0;
      repeat
        ZeroMemory(@Buffer,sizeof(Buffer));
        if (InternetReadFile(phUrl,@Buffer,KiB,dwRead) = False) then
        begin
          if (GetLastError = HTTP_STATUS_REQUEST_TIMEOUT) then SetStatus('Timeout',Error)
          else SetStatus('Could not received data',Error);
          Result:= False;
          Exit;
        end;
        if (dwRead <> 0) then
        begin
          FileWrite(hFile,Buffer,dwRead);
          Inc(dwDownloadedSize,dwRead);
          Percent:= 100.0*(dwDownloadedSize / dwSize);
          LbDownloaded.Caption:= Format('%s (%0.2f %%)',[FmtFileSize(dwDownloadedSize),Percent]);
          LbDownloaded.Refresh;
          ProgressBarDownload.Position:= Round(Percent);
          ProgressBarDownload.Refresh;
        end;
      until (dwRead = 0);
    except
      FileClose(hFile);
      InternetCloseHandle(phUrl);
      InternetCloseHandle(phInet);
      SetStatus('Catch an exception when downloading',Error);
      Result:= False;
      Exit;
    end;

    FileClose(hFile);

    //SetStatus('Downloaded',Success);

    //SetStatus('Session is destroying...',Normal);

    InternetCloseHandle(phUrl);

    //SetStatus('Session destroied',Success);

    //SetStatus('Internet is closing...',Normal);

    InternetCloseHandle(phInet);

    //SetStatus('Internet closed',Success);
  except
    BtnStart.Enabled:= True;
  end;
end;

Function TfrmUpdater.FmtFileSize(Size: DWORD): String; stdcall;
begin
  if (Size >= MiB) then Result:= Format('%.2f', [Size / MiB]) + ' MiB'
  else if Size < KiB then Result:= IntToStr(Size) + ' Bytes'
  else Result:= Format('%.2f', [Size / KiB]) + ' KiB';
end;

Procedure TfrmUpdater.SetStatus(StatusMessage: String; StatusType: TStatusType); stdcall;
begin
  case StatusType of
    Error: LbStatus.Font.Color:= clRed;
    Success, Normal: LbStatus.Font.Color:= clGreen;
    Warning: LbStatus.Font.Color:= clBlue;
    else LbStatus.Font.Color:= clWindowText;
  end;
  LbStatus.Caption:= StatusMessage;
  LbStatus.Refresh;
  Sleep(100);
end;

{$R *.dfm}

procedure TfrmUpdater.FormCreate(Sender: TObject);
begin
  SetWindowLongA(BtnStart.Handle,GWL_STYLE,GetWindowLong(BtnStart.Handle,GWL_STYLE) or BS_FLAT);
end;

procedure TfrmUpdater.FormShow(Sender: TObject);
var szTmpPath, szDownloadPath: String;
begin
  try
    szTmpPath := GetTmpPath;
    if szTmpPath = '' then
    begin
      SetStatus('Could not get save path!', Error);
      EnableWindow(frmUpdater.BtnStart.Handle, False);
      Exit;
    end;

    szDownloadPath := szTmpPath + WideCharToString(PLUGIN_NAME);
    if DirectoryExists(szDownloadPath) then DelDir(szDownloadPath);
    if not CreateDir(szDownloadPath) then
    begin
      SetStatus('Could not create save path! ' + TError, Error);
      EnableWindow(frmUpdater.BtnStart.Handle, False);
      Exit;
    end;

    //uUpdater.URL_ROOT:= uFcData.URL_ROOT;
    uUpdater.URL_FILES:= uFcData.URL_FILES;
    uUpdater.CLIENT_PATH:= szDownloadPath + '\'; //uFcData.CLIENT_PATH;

    txtSaveDir.Text:= uUpdater.CLIENT_PATH;

    if not ExtractApplyUpdate(GetApplyUpdatePath) then
    begin
      MessageBoxA(frmUpdater.Handle,
        StrToPac(fm('Auto-update occured a small error!' + DCRLF +
        'Please do it manual: Press [Start] button to download new files' + DCRLF +
        'and go to OllyDbg''s Plugin' + DCRLF +
        'replace ''%s'' by ''%s.TMP''' + DCRLF +
        'Thanks so much!', [StringToOleStr(szPlugInName), StringToOleStr(szPlugInName)])),
        'Vic''s Updater',
      MB_OK + MB_ICONWARNING);
    end;

    Self.chkOnTopClick(Sender);
  except
    SetStatus('Occur an unknown error!', Error);
    EnableWindow(frmUpdater.BtnStart.Handle, False);
  end;
end;

procedure TfrmUpdater.BtnStartClick(Sender: TObject);
var
  ThreadId: DWORD;
  XmlFileList: PAnsiChar;
begin
  SetStatus('Initializing...',Success);

  XmlParser:= TXmlParser.Create;

  SetStatus('Get download file list',Normal);

  XmlFileList:= GetHTML(uFcData.URL_ROOT + uFcData.LIST_FILE);
  if (Length(XmlFileList) = 0) then
  begin
    SetStatus('Could not get download list',Error);
    Exit;
  end;

  XmlParser.LoadFromBuffer(XmlFileList);

  FillTree;

  GetDownloadFileList;

  SetStatus('Got download list',Normal);

  List.Clear;

  CreateThread(NIL,0,@ThreadUpdate,NIL,0,ThreadId);
end;

end.
