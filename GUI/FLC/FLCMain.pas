unit FLCMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, TlHelp32, XPMan;

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
    XPManifest1: TXPManifest;
    OpenDlg: TOpenDialog;
    btnGoto: TButton;
    GroupBox3: TGroupBox;
    cbLoadedModules: TComboBox;
    GroupBox4: TGroupBox;
    lbEntryPoint: TLabeledEdit;
    lbImageBase: TLabeledEdit;
    procedure cbLoadedModulesSelect(Sender: TObject);
    procedure btnGotoClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
    Function LoadedModulesListing(const dwPID: DWORD): Integer; stdcall;
  end;

type TFrom = (O,R,V);

type
  TMod = packed record
    ImageBase: DWORD;
    Name: String;
    Path: String;
  end;

var
  frmFLC: TfrmFLC;
  LItem: TListItem;

  fFrom: TFrom = V;

  szfp: String;

  dwFromAddr, dwOffset,dwRVA,dwVA: DWORD;

  ModuleList: array[0..500] of TMod;
  PEFilePath: String;

  IDH: TImageDosHeader;
  INtH: TImageNtHeaders;
  IFH: TImageFileHeader;
  IOH: TImageOptionalHeader;  
  ISH: array of TImageSectionHeader;

const
  TITLE_TEXT = 'File Location Converter';

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

uses Plugin, mrVic, uFcData, uMapMain;

Procedure FLC(frm: TfrmFLC; szfPath: String); stdcall;
begin
  EmptyEditbox(frm);
  LoadPE(szfPath);
  LoadSectionsInfo(frm,LItem,ISH);
  frm.lbEntryPoint.Text:= fm('%.8x',[IOH.AddressOfEntryPoint]);
  frm.lbImageBase.Text:=  fm('%.8x',[dwImageBase]);
end;

Procedure Converter(
  dwValue: DWord;
  fFr: TFrom;
  SH: array of TImageSectionHeader;
  var dwOffsetReturned, dwRVAReturned, dwVAReturned: DWORD); stdcall;
var
  i, iIndex: ShortInt;
  bFound: Boolean;
  dwSaveVA, dwSaveRVA, dwSaveOffset: DWORD;
begin
  dwOffsetReturned:= 0;
  dwRVAReturned:= 0;
  dwVAReturned:= 0;
  iIndex:= 0;
  bFound:= False;
  case fFr of
    O:
    begin
      dwSaveOffset:= dwValue;
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
        dwVAReturned:= dwRVAReturned + dwImageBase;
      end;
      dwOffsetReturned:= dwSaveOffset;
    end;

    R:
    begin
      dwSaveRVA:= dwValue;
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
        dwVAReturned:= dwValue + dwImageBase;
      end;
      dwRVAReturned:= dwSaveRVA;
    end;

    V:
    begin
      dwSaveVA:= dwValue;
      dwValue:= dwValue - dwImageBase;
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
      dwVAReturned:= dwSaveVA;
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

  SetLength(ISH,IFH.NumberOfSections);

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

  if (dwImageBase = 0) then
    dwImageBase:= IOH.ImageBase;
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

Function TfrmFLC.LoadedModulesListing(const dwPID: DWORD): Integer; stdcall;
var
  hSnap: THandle;
  me: TModuleEntry32;
begin
  Result:= 0;
  
  hSnap:= CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,dwPID);
  if (hSnap = INVALID_HANDLE_VALUE) then
  begin
    Result:= 1;
    Exit;    
  end;

  ZeroMemory(@me,sizeof(me));
  
  me.dwSize:= sizeof(me);

  if (Module32First(hSnap,me) = False) then
  begin
    Result:= 2;
    CloseHandle(hSnap);
    Exit;
  end;

  repeat
    ModuleList[Index].ImageBase:= DWORD(me.modBaseAddr);
    ModuleList[Index].Name:= StrPas(PAnsiChar(@me.szModule));
    ModuleList[Index].Path:= StrPas(PAnsiChar(@me.szExePath));
    frmFLC.cbLoadedModules.Items.Add(Format('%-32s',[ModuleList[Index].Name]));
    Inc(Index);
  until (Module32Next(hSnap,me) = False);

  CloseHandle(hSnap);
end;

procedure TfrmFLC.btnOpenClick(Sender: TObject);
begin
  if OpenDlg.Execute then
  begin
    dwImageBase:= 0;
    szfp:= OpenDlg.FileName;
    Caption:= TITLE_TEXT + ' [' + ExtractFileName(szfp) + '] ';
  end else Exit;
  if (szfp <> '') then FLC(frmFLC,szfp);
end;

procedure TfrmFLC.btnGotoClick(Sender: TObject);
var dwVA: DWORD;
begin
  dwVA:= HexToInt(txtVA.Text);
  if (FindMemory(dwVA) = NIL) then
  begin
    StatusFlash('No memory at the specified address');
    Exit;
  end;

  {$IF __VERSION__ = 1.10}
  case (dwPane) of
    1:
    begin
    end;
    (*
    DMT_CPUDASM:
    begin
      SetCPU(0,dwVA,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
    end;
    DMT_CPUDUMP:
    begin
      SetCPU(0,0,dwVA,0,0,CPU_DUMPHIST or CPU_DUMPFIRST or CPU_DUMPFOCUS);
    end;
    DMT_CPUSTACK:
    begin
      SetCPU(0,0,0,0,dwVA,CPU_STACKFOCUS);
    end
    else
    begin
      Flash('Choose a pane to go to');
    end;
    *)
  end;
  {$IFEND}

  {$IF __VERSION__ = 2.01}
  case (dwPane) of
    DMT_CPUDASM:
    begin
      SetCPU(0,dwVA,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
    end;
    DMT_CPUDUMP:
    begin
      SetCPU(0,0,dwVA,0,0,CPU_DUMPHIST or CPU_DUMPFIRST or CPU_DUMPFOCUS);
    end;
    DMT_CPUSTACK:
    begin
      SetCPU(0,0,0,0,dwVA,CPU_STACKFOCUS);
    end
    else
    begin
      StatusFlash('Choose a pane to go to');
    end;
  end;
  {$IFEND}
end;

procedure TfrmFLC.cbLoadedModulesSelect(Sender: TObject);
begin
  dwImageBase:= ModuleList[cbLoadedModules.ItemIndex].ImageBase;
  PEFilePath:=  ModuleList[cbLoadedModules.ItemIndex].Path;

  lSInfo.Clear;

  try
    //szfp:= fpath;
    szfp:= PEFilePath;
    if (szfp = '') then Exit;
    FLC(frmFLC,szfp);
    Caption:= TITLE_TEXT + ' [' + ExtractFileName(szfp) + '] ';
  except
    Exit;
  end;
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
  txtOffset.Color:= fclNoFocus;
  txtRVA.Color:= fclNoFocus;
  txtVA.Color:= fclFocus;

  SetWindowLongA(btnOpen.Handle,GWL_STYLE,(GetWindowLongA(btnOpen.Handle,GWL_STYLE) or BS_FLAT));
  SetWindowLongA(btnGoto.Handle,GWL_STYLE,(GetWindowLongA(btnGoto.Handle,GWL_STYLE) or BS_FLAT));

  //SetFocus(txtVA.Handle);
  Windows.SetFocus(txtVA.Handle);
end;

procedure TfrmFLC.FormShow(Sender: TObject);
var myPID: DWORD;
begin
  Self.cbOnTopClick(Sender);

  ODData:= GetODData;
  myPID:= ODData.processid;

  if (myPID = 0) then Exit;

  ZeroMemory(@ModuleList,sizeof(ModuleList));
  Index:= 0;

  if (LoadedModulesListing(myPID) = 0) then
  begin
    Self.cbLoadedModules.ItemIndex:= 0;
    dwImageBase:= ModuleList[cbLoadedModules.ItemIndex].ImageBase;
    PEFilePath:=  ModuleList[cbLoadedModules.ItemIndex].Path;
  end;
  
  try
    //szfp:= fpath;
    szfp:= PEFilePath;
    if (szfp = '') then Exit;
    FLC(frmFLC,szfp);
    Caption:= TITLE_TEXT + ' [' + ExtractFileName(szfp) + '] ';
  except
    Exit;
  end;
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

// Ctrl + C -> #3
// Ctrl + V -> #22
// Ctrl + X -> #24
// Ctrl + Z -> #26

procedure TfrmFLC.txtOffsetKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8,#13,#22,#26,#24,#3]) then
  begin
    Key:= #0;
    Beep;
  end;
  if (Key = #13) then
  begin
    btnGotoClick(Sender);
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
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8,#13,#22,#26,#24,#3]) then
  begin
    Key:= #0;
    Beep;
  end;
  if (Key = #13) then
  begin
    btnGotoClick(Sender);
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
  if not (Key in ['0'..'9','A'..'F','a'..'f',#8,#13,#22,#26,#24,#3]) then
  begin
    Key:= #0;
    Beep;
  end;
  if (Key = #13) then
  begin
    btnGotoClick(Sender);
  end;
end;

end.
