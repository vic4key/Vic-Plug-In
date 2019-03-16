unit uDCMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, ClipBrd;

type
  TfrmDC = class(TForm)
    GroupBox1: TGroupBox;
    mmData: TMemo;
    GroupBox2: TGroupBox;
    XPManifest1: TXPManifest;
    Lang: TComboBox;
    GroupBox3: TGroupBox;
    btnCopy: TButton;
    btnPaste: TButton;
    btnClear: TButton;
    btnConverter: TButton;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure LangChange(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnConverterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const CRLF = #13#10;

var
  frmDC: TfrmDC;
  nIndex: Byte = 0;

implementation

uses uFcData;

Function FixLine(szString: String): String;
var i, iCount: Integer;
const MAX_CHAR_IN_LINE: Integer = 80;
begin
  iCount:= 1;
  Result:= '';
  for i:= 1 to Length(szString) do
  begin
    Result:= Result + szString[i];
    //StringReplace(Result,#13#10#32,#13#10,[rfReplaceAll]);
    if (i >= iCount*MAX_CHAR_IN_LINE) and (szString[i] = ',') then
    begin
      Result:= TrimRight(Result) + CRLF;
      Inc(iCount);
    end;
  end;
end;

Function FixHexString(lpHexString: String): String;
var i: LongInt;
begin
  if (Length(lpHexString) < 2) then Exit;
  for i:= 1 to Length(lpHexString) - 2 do
    if (lpHexString[i] <> ' ')
    and (lpHexString[i + 1] <> ' ')
    and (lpHexString[i + 2] <> ' ') then
      Insert(' ',lpHexString,i + 2);
  Result:= lpHexString;
end;

Function Data2DelphiPascal(lpStrData: String): String;
var i, NumberOfArray: LongInt;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  if (lpStrData = '') then
  begin
    Result:= '';
    Exit;
  end;
  NumberOfArray:= 0;
  for i:= 1 to Length(lpStrData) do
    if (lpStrData[i] = ' ') then Inc(NumberOfArray);
  Inc(NumberOfArray);
  lpStrData:= StringReplace(lpStrData,' ',',$',[rfReplaceAll]);
  Result:= 'Data: array[0..' + IntToStr(NumberOfArray - 1) + '] of Byte = (' + '$' + lpStrData + ');';
  Result:= FixLine(Result);
end;

Function Data2CCPlus(lpStrData: String): String;
var i, NumberOfArray: LongInt;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  if (lpStrData = '') then
  begin
    Result:= '';
    Exit;
  end;  
  NumberOfArray:= 0;
  for i:= 1 to Length(lpStrData) do
    if (lpStrData[i] = ' ') then Inc(NumberOfArray);
  lpStrData:= StringReplace(lpStrData,' ',',0x',[rfReplaceAll]);
  Result:= 'unsigned char Data[' + IntToStr(NumberOfArray + 1) + '] = {' + '0x' + lpStrData + '};';
  Result:= FixLine(Result);
end;

Function Data2CS(lpStrData: String): String;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  lpStrData:= StringReplace(lpStrData,' ',',0x',[rfReplaceAll]);
  Result:= 'byte[] Data = {' + '0x' + lpStrData + '};';
  Result:= FixLine(Result);
end;

Function Data2Asm(lpStrData: String): String;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  lpStrData:= StringReplace(lpStrData,' ','h, db ',[rfReplaceAll]);
  Result:= 'Data ' + 'db ' + lpStrData + 'h';
  Result:= FixLine(Result);
end;

Function Data2Lua(lpStrData: String): String;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  lpStrData:= StringReplace(lpStrData,' ',',0x',[rfReplaceAll]);
  Result:= 'Data = {' + '0x' + lpStrData + '}';
  Result:= FixLine(Result);
end;

Function Data2Python(lpStrData: String): String;
begin
  TrimLeft(lpStrData);
  TrimRight(lpStrData);
  lpStrData:= StringReplace(lpStrData,CRLF,'',[rfReplaceAll]);
  lpStrData:= FixHexString(lpStrData);
  lpStrData:= StringReplace(lpStrData,' ',',0x',[rfReplaceAll]);
  Result:= 'Data = [' + '0x' + lpStrData + ']';
  Result:= FixLine(Result);
end;

{$R *.dfm}

procedure TfrmDC.btnClearClick(Sender: TObject);
begin
  mmData.Clear;
end;

procedure TfrmDC.btnConverterClick(Sender: TObject);
var strData: String;
begin
  mmData.Clear;
  mmData.Lines.Text:= szBuffer;
  if (Length(mmData.Lines.GetText) = 0) then Exit;  
  case nIndex of
    0: strData:= Data2DelphiPascal(mmData.Lines.GetText);
    1: strData:= Data2CCPlus(mmData.Lines.GetText);
    2: strData:= Data2CS(mmData.Lines.GetText);
    3: strData:= Data2Asm(mmData.Lines.GetText);
    4: strData:= Data2Lua(mmData.Lines.GetText);
    5: strData:= Data2Python(mmData.Lines.GetText);
    else MessageBoxA(frmDC.Handle, 'Please choose a programming language!', 'Data Converter', MB_ICONWARNING);
  end;
  mmData.Clear;
  mmData.Lines.Add(strData);
end;

procedure TfrmDC.btnPasteClick(Sender: TObject);
begin
  szBuffer:= Clipboard.AsText;
  mmData.Lines.Text:= szBuffer;
end;

procedure TfrmDC.cbOnTopClick(Sender: TObject);
begin
  case cbOnTop.Checked of
    True:  Self.FormStyle:= fsStayOnTop;
    False: Self.FormStyle:= fsNormal;
  end;
end;

procedure TfrmDC.FormCreate(Sender: TObject);
begin
  SetWindowLongA(btnClear.Handle,GWL_STYLE,(GetWindowLongA(btnClear.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(btnCopy.Handle,GWL_STYLE,(GetWindowLongA(btnCopy.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(btnPaste.Handle,GWL_STYLE,(GetWindowLongA(btnPaste.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(btnConverter.Handle,GWL_STYLE,(GetWindowLongA(btnConverter.Handle,GWL_STYLE) or BS_FLAT));

  mmData.Clear;
  mmData.Lines.Text:= szBuffer;
  nIndex:= Lang.ItemIndex;  
end;

procedure TfrmDC.FormShow(Sender: TObject);
begin
  Self.cbOnTopClick(Sender);
end;

procedure TfrmDC.LangChange(Sender: TObject);
begin
  nIndex:= Lang.ItemIndex;
  btnConverter.Caption:= '[Convert the Data To Array Of ' + Lang.Text + ']';
end;

procedure TfrmDC.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText:= mmData.Lines.GetText;
end;

end.
