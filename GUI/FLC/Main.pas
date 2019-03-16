unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XPMan;

type
  TfrmFLC = class(TForm)
    GroupBox1: TGroupBox;
    rdOffset: TRadioButton;
    rdRVA: TRadioButton;
    rdVA: TRadioButton;
    txtOffset: TEdit;
    txtRVA: TEdit;
    txtVA: TEdit;
    GroupBox2: TGroupBox;
    lSInfo: TListView;
    btnOpen: TButton;
    cbOnTop: TCheckBox;
    lbEntryPoint: TLabel;
    XPManifest1: TXPManifest;
    OpenDlg: TOpenDialog;
    procedure btnOpenClick(Sender: TObject);
    procedure txtVAChange(Sender: TObject);
    procedure txtRVAChange(Sender: TObject);
    procedure txtOffsetChange(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure txtVAKeyPress(Sender: TObject; var Key: Char);
    procedure txtRVAKeyPress(Sender: TObject; var Key: Char);
    procedure txtOffsetKeyPress(Sender: TObject; var Key: Char);
    procedure rdVAClick(Sender: TObject);
    procedure rdRVAClick(Sender: TObject);
    procedure rdOffsetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type TFrom = (O,R,V);

var
  frmFLC: TfrmFLC;
  LItem: TListItem;

  fFrom: TFrom;

  szfp: String;

  dwFromAddr, dwOffset,dwRVA,dwVA: DWORD;

  IDH: TImageDosHeader;
  INtH: TImageNtHeaders;
  IFH: TImageFileHeader;
  IOH: TImageOptionalHeader;  
  ISH: array of TImageSectionHeader;

const
  TITLE_TEXT = '[VIC] File Location Converter';

  fclFocus   = clWhite;
  fclNoFocus = clSilver;

Procedure Converter(
  dwValue: DWord;
  fFr: TFrom;
  SH: array of TImageSectionHeader;
  var dwOffsetReturned, dwRVAReturned, dwVAReturned: DWORD); stdcall;
Procedure LoadPE(szFilePath: String); stdcall;
Procedure EmptyEditbox(frm: TfrmFLC); stdcall;
Procedure LoadSectionsInfo(
  frm: TFrmFLC;
  item: TListItem;
  SH: array of TImageSectionHeader); stdcall;
Procedure FLC(frm: TfrmFLC; szfPath: String); stdcall;

implementation

uses mrvic, SomeFunction;

Procedure FLC(frm: TfrmFLC; szfPath: String); stdcall;
begin
  EmptyEditbox(frm);
  LoadPE(szfPath);
  LoadSectionsInfo(frm,LItem,ISH);
  frm.lbEntryPoint.Caption:= fm('RVA Entry Point %.8x',[IOH.AddressOfEntryPoint]);
end;

Function HexToInt(const HexStr: String): LongInt;
var
  iNdx: Integer;
  cTmp: Char;
begin
  Result:= 0;
  if (HexStr = '') then Exit;
  for iNdx:= 1 to Length(HexStr) do
  begin
    cTmp:= HexStr[iNdx];
    case cTmp of
      '0'..'9': Result:= 16 * Result + (Ord(cTmp) - $30);
      'A'..'F': Result:= 16 * Result + (Ord(cTmp) - $37);
      'a'..'f': Result:= 16 * Result + (Ord(cTmp) - $57);
    else Exit;
    end;
  end;
end;

Procedure Converter(
  dwValue: DWord;
  fFr: TFrom;
  SH: array of TImageSectionHeader;
  var dwOffsetReturned, dwRVAReturned, dwVAReturned: DWORD); stdcall;
var
  i, iIndex: ShortInt;
  bFound: Boolean;
begin
  dwOffsetReturned:= 0;
  dwRVAReturned:= 0;
  dwVAReturned:= 0;
  iIndex:= 0;
  bFound:= False;
  case fFr of
    O:
    begin
      for i:= 0 to High(SH) do
      begin
        if (dwValue >= SH[i].PointerToRawData)
        and (dwValue <= (SH[i].PointerToRawData + SH[i].SizeOfRawData - 1)) then
        begin
          bFound:= True;
          iIndex:= i;
          Break;
        end;
      end;
      if bFound then
      begin
        dwRVAReturned:= dwValue - SH[iIndex].PointerToRawData + SH[iIndex].VirtualAddress;
        dwVAReturned:= dwRVAReturned + IOH.ImageBase;
      end;
    end;

    R:
    begin
      for i:= 0 to High(SH) do
      begin
        if (dwValue >= SH[i].VirtualAddress)
        and (dwValue < SH[i].VirtualAddress + SH[i].Misc.VirtualSize - 1) then
        begin
          bFound:= True;
          iIndex:= i;
          Break;
        end;
      end;
      if bFound then
      begin
        dwOffsetReturned:= dwValue - SH[iIndex].VirtualAddress + SH[iIndex].PointerToRawData;
        dwVAReturned:= dwValue + IOH.ImageBase;
      end;
    end;

    V:
    begin
      dwValue:= dwValue - IOH.ImageBase;
      for i:= 0 to High(SH) do
      begin
        if (dwValue >= SH[i].VirtualAddress)
        and (dwValue < SH[i].VirtualAddress + SH[i].Misc.VirtualSize - 1) then
        begin
          bFound:= True;
          iIndex:= i;
          Break;
        end;
      end;
      if bFound then
      begin
        dwOffsetReturned:= dwValue - SH[iIndex].VirtualAddress + SH[iIndex].PointerToRawData;
        dwRVAReturned:= dwValue;
      end;
    end;
  end;
end;

Procedure LoadPE(szFilePath: String); stdcall;
var
  hFile: HMODULE;
  hFileMap: THandle;
  dwAddrFirstOfTheSection: DWORD;
  i: ShortInt;
begin
  hFile:= FileOpen(szFilePath,fmOpenRead or fmShareDenyNone);
  if (hFile = 0) then
    VICMsg('PE::FileOpen::Failure')
  else
  begin
    hFileMap:= CreateFileMappingA(hFile,NIL,PAGE_READONLY,0,0,'');
    if (hFileMap = 0) then
      VICMsg('PE::CreateFileMappingA::Failure' + TError)
    else
    begin
      hFile:= DWord(MapViewOfFile(hFileMap,FILE_MAP_READ,0,0,0));
      if (hFile = 0) then
      begin
        VICMsg('PE::MapViewOfFile::Failure' + TError);
        hFile:= GetModuleHandleA(PAnsiChar(szFilePath));
        if (hFile = 0) then
        begin
          VICMsg('PE::GetModuleHandleA::Failure' + TError);
          hFile:= LoadLibraryA(PAnsiChar(szFilePath));
          if (hFile = 0) then
          begin
            VICMsg('PE::LoadLibraryA::Failure' + TError);
            Exit;
          end;
        end;
      end;
    end;
  end;

  IDH:= PImageDosHeader(hFile)^;

  if (IDH.e_magic <> IMAGE_DOS_SIGNATURE) then
  begin
    VICMsg('PE::TImageDosHeader::Failure');
    Exit;
  end;

  INtH:= PImageNtHeaders(hFile + DWord(IDH._lfanew))^;
  if (INtH.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    VICMsg('PE::TImageNtHeaders::Failure');
    Exit;
  end;

  IFH:= PImageFileHeader(DWord(@INtH.FileHeader))^;

  IOH:= PImageOptionalHeader(DWord(@INtH.OptionalHeader))^;

  SetLength(ISH,IFH.NumberOfSections - 1);

  dwAddrFirstOfTheSection:=
    hFile + DWord(
      IDH._lfanew +
      SizeOf(INtH.Signature) +
      SizeOf(IFH)) +
      IFH.SizeOfOptionalHeader;

  for i:= 0 to High(ISH) do
  begin
    ISH[i]:= PImageSectionHeader(
      dwAddrFirstOfTheSection +
      DWord(i*SizeOf(TImageSectionHeader)))^;
  end;
end;


Procedure EmptyEditbox(frm: TfrmFLC); stdcall;
begin
  frm.txtOffset.Text:= '';
  frm.txtRVA.Text:= '';
  frm.txtVA.Text:= '';
end;

Procedure LoadSectionsInfo(
  frm: TFrmFLC;
  item: TListItem;
  SH: array of TImageSectionHeader); stdcall;
var i: ShortInt;
begin
  for i:= 0 to High(SH) do
  begin
    item:= frm.lSInfo.Items.Add;
    item.Caption:= String(StrPas(PAnsiChar(@SH[i].Name)));
    item.SubItems.Add(fm('%.8X',[SH[i].VirtualAddress]));
    item.SubItems.Add(fm('%.8X',[SH[i].Misc.VirtualSize]));
    item.SubItems.Add(fm('%.8X',[SH[i].PointerToRawData]));
    item.SubItems.Add(fm('%.8X',[SH[i].SizeOfRawData]));
    Item.SubItems.Add(fm('%.8X',[SH[i].Characteristics]));
  end;
end;

{$R *.dfm}

procedure TfrmFLC.btnOpenClick(Sender: TObject);
begin
  if OpenDlg.Execute then
  begin
    szfp:= OpenDlg.FileName;
    Caption:= TITLE_TEXT + ' [' + ExtractFileName(szfp) + '] ';
  end else Exit;
  if (szfp <> '') then FLC(frmFLC,szfp);
end;

procedure TfrmFLC.cbOnTopClick(Sender: TObject);
begin
  if cbOnTop.Checked then
    frmFLC.FormStyle:= fsStayOnTop
  else
    frmFLC.FormStyle:= fsNormal;
end;

procedure TfrmFLC.FormCreate(Sender: TObject);
begin
  txtOffset.Color:= fclFocus;
  txtRVA.Color:= fclNoFocus;
  txtVA.Color:= fclNoFocus;

  FormStyle:= fsStayOnTop;
  szfp:= fpath;
  FLC(frmFLC,szfp);
  Caption:= TITLE_TEXT + ' [' + ExtractFileName(szfp) + '] ';;
end;

procedure TfrmFLC.rdOffsetClick(Sender: TObject);
begin
  EmptyEditbox(frmFLC);

  txtOffset.ReadOnly:= False;
  txtRVA.ReadOnly:= True;
  txtVA.ReadOnly:= True;

  txtOffset.Color:= fclFocus;
  txtRVA.Color:= fclNoFocus;
  txtVA.Color:= fclNoFocus;

  fFrom:= O;
end;

procedure TfrmFLC.rdRVAClick(Sender: TObject);
begin
  EmptyEditbox(frmFLC);

  txtOffset.ReadOnly:= True;
  txtRVA.ReadOnly:= False;
  txtVA.ReadOnly:= True;

  txtOffset.Color:= fclNoFocus;
  txtRVA.Color:= fclFocus;
  txtVA.Color:= fclNoFocus;

  fFrom:= R;
end;

procedure TfrmFLC.rdVAClick(Sender: TObject);
begin
  EmptyEditbox(frmFLC);

  txtOffset.ReadOnly:= True;
  txtRVA.ReadOnly:=    True;
  txtVA.ReadOnly:=     False;

  txtOffset.Color:= fclNoFocus;
  txtRVA.Color:= fclNoFocus;
  txtVA.Color:= fclFocus;

  fFrom:= V;
end;

procedure TfrmFLC.txtOffsetChange(Sender: TObject);
begin
  if (fFrom <> O) then Exit;
  dwFromAddr:= HexToInt(txtOffset.Text);
  Converter(dwFromAddr,fFrom,ISH,dwOffset,dwRVA,dwVA);
  if (dwRVA <> 0) or (dwVA <> 0) then
  begin
    txtRVA.Text:= fm('%.8x',[dwRVA]);
    txtVA.Text:= fm('%.8x',[dwVA]);
  end
  else
  begin
    txtRVA.Text:= '';
    txtVA.Text:= '';
  end;
end;

procedure TfrmFLC.txtOffsetKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8]) then
  begin
    Key:= #0;
    Beep;
  end;
end;

procedure TfrmFLC.txtRVAChange(Sender: TObject);
begin
  if (fFrom <> R) then Exit;
  dwFromAddr:= HexToInt(txtRVA.Text);
  Converter(dwFromAddr,fFrom,ISH,dwOffset,dwRVA,dwVA);
  if (dwOffset <> 0) or (dwVA <> 0) then
  begin
  txtOffset.Text:= fm('%.8x',[dwOffset]);
  txtVA.Text:= fm('%.8x',[dwVA]);
  end
  else
  begin
    txtOffset.Text:= '';
    txtVA.Text:= '';
  end;
end;

procedure TfrmFLC.txtRVAKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8]) then
  begin
    Key:= #0;
    Beep;
  end;
end;

procedure TfrmFLC.txtVAChange(Sender: TObject);
begin
  if (fFrom <> V) then Exit;
  dwFromAddr:= HexToInt(txtVA.Text);
  Converter(dwFromAddr,fFrom,ISH,dwOffset,dwRVA,dwVA);
  if (dwOffset <> 0) or (dwRVA <> 0) then
  begin
    txtOffset.Text:= fm('%.8x',[dwOffset]);
    txtRVA.Text:= fm('%.8x',[dwRVA]);
  end
  else
  begin
    txtOffset.Text:= '';
    txtRVA.Text:= '';
  end;
end;

procedure TfrmFLC.txtVAKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8]) then
  begin
    Key:= #0;
    Beep;
  end;
end;

end.
