unit pevMain;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ComCtrls, Buttons, shellApi,
    ShlObj, ActiveX, ComObj, XPMan;

type
    TPE_Viewer = class(TForm)
        GroupBox1: TGroupBox;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        Label7: TLabel;
        Edit1: TEdit;
        Edit2: TEdit;
        Edit3: TEdit;
        Edit4: TEdit;
        Edit5: TEdit;
        Edit6: TEdit;
        Edit7: TEdit;
        Label8: TLabel;
        Edit8: TEdit;
        Label9: TLabel;
        Edit9: TEdit;
        Label10: TLabel;
        Edit10: TEdit;
        Label11: TLabel;
        Edit11: TEdit;
        Label12: TLabel;
        Edit12: TEdit;
        Label13: TLabel;
        Edit13: TEdit;
        Label14: TLabel;
        Edit14: TEdit;
        Label15: TLabel;
        Edit15: TEdit;
        Label16: TLabel;
        Edit16: TEdit;
        Label17: TLabel;
        Edit17: TEdit;
        GroupBox2: TGroupBox;
        Label18: TLabel;
        Label19: TLabel;
        Label20: TLabel;
        Label21: TLabel;
        Label22: TLabel;
        Label23: TLabel;
        Label24: TLabel;
        Edit18: TEdit;
        Edit19: TEdit;
        Edit20: TEdit;
        Edit21: TEdit;
        Edit22: TEdit;
        Edit23: TEdit;
        Edit24: TEdit;
        GroupBox3: TGroupBox;
        Label25: TLabel;
        Label26: TLabel;
        Label27: TLabel;
        Label28: TLabel;
        Label29: TLabel;
        Label30: TLabel;
        Label31: TLabel;
        Label32: TLabel;
        Label33: TLabel;
        Label34: TLabel;
        Label35: TLabel;
        Label36: TLabel;
        Label37: TLabel;
        Label38: TLabel;
        Edit25: TEdit;
        Edit26: TEdit;
        Edit27: TEdit;
        Edit28: TEdit;
        Edit29: TEdit;
        Edit30: TEdit;
        Edit31: TEdit;
        Edit32: TEdit;
        Edit33: TEdit;
        Edit34: TEdit;
        Edit35: TEdit;
        Edit36: TEdit;
        Edit37: TEdit;
        Edit38: TEdit;
        Label39: TLabel;
        Edit39: TEdit;
        Label40: TLabel;
        Edit40: TEdit;
        Label41: TLabel;
        Edit41: TEdit;
        Label42: TLabel;
        Edit42: TEdit;
        Label43: TLabel;
        Edit43: TEdit;
        Label44: TLabel;
        Edit44: TEdit;
        Label45: TLabel;
        Edit45: TEdit;
        Label46: TLabel;
        Edit46: TEdit;
        Label47: TLabel;
        Edit47: TEdit;
        Edit48: TEdit;
        Label48: TLabel;
        Label49: TLabel;
        Edit49: TEdit;
        Label50: TLabel;
        Edit50: TEdit;
        Label51: TLabel;
        Edit51: TEdit;
        Label52: TLabel;
        Edit52: TEdit;
        Label53: TLabel;
        Edit53: TEdit;
        Label54: TLabel;
        Edit54: TEdit;
        GroupBox4: TGroupBox;
        ListView1: TListView;
        GroupBox5: TGroupBox;
        Edit55: TEdit;
        OpenDialog1: TOpenDialog;
        Button3: TButton;
        Button1: TButton;
        Button2: TButton;
        GroupBox6: TGroupBox;
        Button4: TButton;
        Button5: TButton;
    XPManifest1: TXPManifest;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
        procedure Button1Click(Sender: TObject);
        procedure Button2Click(Sender: TObject);
        procedure Button3Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure Button4Click(Sender: TObject);
        procedure Button5Click(Sender: TObject);
    private
        { Private declarations }
        procedure LoadPeInfo(AFile: string);
        function FM(Num: DWORD; Switch: Integer): string;
        //function SesctionDescription(SectionName: string): string;
        function CheckValue(Flags: Cardinal; Value: Cardinal): Boolean;
        function GetShortcutTarget(ShortcutFilename: string): string;
        procedure WMDROPFILES(var Message: TWMDROPFILES); message WM_DROPFILES;
    public
        { Public declarations }
        procedure CheckCharactistics;
    end;

var
    PE_Viewer: TPE_Viewer;
    FileName: string;
    NTHeader: TImageNtHeaders;
    hFileMap: THandle = 0;
    fmBuffer: Pointer = NIL;

implementation

uses pevChrts, pevIE, uFcData, uShared, mrVic;
{$R *.dfm}

procedure TPE_Viewer.Button1Click(Sender: TObject);
begin
    if OpenDialog1.Execute then
    begin
        Edit55.Text := OpenDialog1.FileName;
        FileName := OpenDialog1.FileName;
        Button2Click(self);
    end;
end;

procedure TPE_Viewer.Button2Click(Sender: TObject);
begin
    if FileExists(Edit55.Text) then PE_Viewer.LoadPeInfo(Edit55.Text);
end;

{��ʽ����ֵ���}
function TPE_Viewer.FM(Num: DWORD; Switch: Integer): string;
begin
    Result := {'$' +} InttoHex(Num, 8);
end;

{"λ"�İ�����⺯��}
function TPE_Viewer.CheckValue(Flags, Value: Cardinal): Boolean;
begin
    Result := Flags and not Value = 0;
end;

{���������������}
{
function TForm1.SesctionDescription(SectionName: string): string;
begin
    SectionName := Trim(LowerCase(SectionName));
    if SectionName = '.arch' then Result := '�洢ALPHA�ܹ���Ϣ����'
    else if ((SectionName = 'code') or (SectionName = '.code')) then Result := '��������'
    else if ((SectionName = 'bss') or (SectionName = '.bss')) then Result := 'δ��ʼ����������'
    else if ((SectionName = 'data') or (SectionName = '.data')) then Result := '��ʼ����������'
    else if SectionName = '.edata' then Result := '��������������'
    else if SectionName = '.idata' then Result := '���뺯��������'
    else if SectionName = '.pdata' then Result := 'EXECPTION��Ϣ����'
    else if SectionName = '.rdata' then Result := 'ֻ����������'
    else if SectionName = '.reloc' then Result := '�ض�λ����'
    else if SectionName = '.rsrc' then Result := '��ԴĿ¼����'
    else if SectionName = '.text' then Result := '��ִ�д�������'
    else if SectionName = '.tls' then Result := '�ֲ��̴߳洢����'
    else if SectionName = '.xdata' then Result := 'EXECPTION��Ϣ����'
    else if SectionName = '.degug' then Result := '������Ϣ��Ϣ����'

        //����Ϊ�Ǳ�׼���Σ�
    else if SectionName = '.aspack' then Result := '*ASPACKѹ������'
    else if SectionName = 'upx1' then Result := '*UPXѹ������'
    else if SectionName = 'upx0' then Result := '*UPXѹ������'
    else if SectionName = '.yp' then Result := '*yoda''s Protectorѹ������'
    else if SectionName = '.x01' then Result := '*yoda''s Protectorѹ������'
    else if SectionName = '.pelock' then Result := '*PELockѹ������'
    else if SectionName = '.petite' then Result := '*TETiteѹ������'
    else if SectionName = '.rlpack' then Result := '*RLPackѹ������'
    else if SectionName = '.packed' then Result := '*RLPackѹ������'
    else if SectionName = '.ttp' then Result := '*TTProtectѹ������'
    else if SectionName = '.nsp0' then Result := '*������ѹ������'
    else if SectionName = '.nsp1' then Result := '*������ѹ������'
    else if SectionName = '.nsp2' then Result := '*������ѹ������'
    else if SectionName = 'exes' then Result := '*EXEStealthѹ������'
    else Result := '�Զ�������';
end;
}

{����PE�ļ���Ϣ����ʾ}
procedure TPE_Viewer.LoadPeInfo(AFile: string);
var
    hFile: Integer;
    DosHeader: TImageDosHeader;
    //NTHeader: TImageNtHeaders;  ת��ȫ�ֱ���
    PESectionHeader: array of TImageSectionHeader;
    I: Integer;
    Str: string;
begin
    hFile := FileOpen(AFile, fmOpenRead or fmShareDenyNone);
    try
        if FileRead(hFile, DosHeader, SizeOf(DosHeader)) <> SizeOf(DosHeader) then {��ȡDOSHeader}
            raise exception.Create('');
        if FileSeek(hFile, DosHeader._lfanew, soFromBeginning) <> DosHeader._lfanew then {��λ��PE header}
            raise exception.Create('');
        if FileRead(hFile, NTHeader, SizeOf(NTHeader)) <> SizeOf(NTHeader) then {�����ݵ�NTHeader}
            raise exception.Create('');
        SetLength(PESectionHeader, NTHeader.FileHeader.NumberOfSections); {�����}
        for I := 0 to NTHeader.FileHeader.NumberOfSections - 1 do
            {�ڱ���뵽PESectionHeader}
            if FileRead(hFile, PESectionHeader[I], SizeOf(PESectionHeader[I])) <> SizeOf(PESectionHeader[I]) then
                raise exception.Create('');
    except
        FileClose(hFile);
        Application.MessageBox('Error reading PE file!', 'Error', MB_OK + MB_ICONERROR);
        exit;
    end;
    FileClose(hFile);
    if (NTHeader.Signature <> IMAGE_NT_SIGNATURE) then
    begin
        Application.MessageBox('Not A Win32 Executable File!', 'Error', MB_OK + MB_ICONERROR);
        exit;
    end;

    (* /=====��ȡDOS HEADER ��Ϣ======
    _IMAGE_DOS_HEADER = packed record      { DOS .EXE header                  }
        e_magic: Word;                     { Magic number                     }
        e_cblp: Word;                      { Bytes on last page of file       }
        e_cp: Word;                        { Pages in file                    }
        e_crlc: Word;                      { Relocations                      }
        e_cparhdr: Word;                   { Size of header in paragraphs     }
        e_minalloc: Word;                  { Minimum extra paragraphs needed  }
        e_maxalloc: Word;                  { Maximum extra paragraphs needed  }
        e_ss: Word;                        { Initial (relative) SS value      }
        e_sp: Word;                        { Initial SP value                 }
        e_csum: Word;                      { Checksum                         }
        e_ip: Word;                        { Initial IP value                 }
        e_cs: Word;                        { Initial (relative) CS value      }
        e_lfarlc: Word;                    { File address of relocation table }
        e_ovno: Word;                      { Overlay number                   }
        e_res: array [0..3] of Word;       { Reserved words                   }
        e_oemid: Word;                     { OEM identifier (for e_oeminfo)   }
        e_oeminfo: Word;                   { OEM information; e_oemid specific}
        e_res2: array [0..9] of Word;      { Reserved words                   }
        _lfanew: LongInt;                  { File address of new exe header   }
    end; *)

    Edit1.Text := FM(DosHeader.e_magic, 4);
    Edit2.Text := FM(DosHeader.e_cblp, 4);
    Edit3.Text := FM(DosHeader.e_cp, 4);
    Edit4.Text := FM(DosHeader.e_crlc, 4);
    Edit5.Text := FM(DosHeader.e_cparhdr, 4);
    Edit6.Text := FM(DosHeader.e_minalloc, 4);
    Edit7.Text := FM(DosHeader.e_maxalloc, 4);
    Edit8.Text := FM(DosHeader.e_ss, 4);
    Edit9.Text := FM(DosHeader.e_sp, 4);
    Edit10.Text := FM(DosHeader.e_csum, 4);
    Edit11.Text := FM(DosHeader.e_ip, 4);
    Edit12.Text := FM(DosHeader.e_cs, 4);
    Edit13.Text := FM(DosHeader.e_lfarlc, 4);
    Edit14.Text := FM(DosHeader.e_ovno, 4);
    Edit15.Text := FM(DosHeader.e_oemid, 4);
    Edit16.Text := FM(DosHeader.e_oeminfo, 4);
    Edit17.Text := FM(DosHeader._lfanew, 8);



    (*  ========= ��ȡ IMAGE FILE HEADER ��Ϣ========
    typedef struct {
    WORD    Machine; //Target Machine Type
    WORD    NumberOfSections; //Number of Sections
    DWORD   TimeDateStamp; //Creation Time
    DWORD   PointerToSymbolTable; // Point to Symbol Table
    DWORD   NumberOfSymbols; //Number of Symbol Table Entry
    WORD    SizeOfOpitionalHeader; //
    WORD    Characteristics; //
    }CoffHead,*pCoffHead;
    ===============================================     *)

    Edit18.Text := FM(NTHeader.FileHeader.Machine, 4);
    Edit19.Text := FM(NTHeader.FileHeader.NumberOfSections, 4);
    Edit20.Text := FM(NTHeader.FileHeader.TimeDateStamp, 8);
    Edit21.Text := FM(NTHeader.FileHeader.PointerToSymbolTable, 8);
    Edit22.Text := FM(NTHeader.FileHeader.NumberOfSymbols, 8);
    Edit23.Text := FM(NTHeader.FileHeader.SizeOfOptionalHeader, 4);
    Edit24.Text := FM(NTHeader.FileHeader.Characteristics, 4);
    (* =============================================
      Characteristics �ֶΰ���ָ�������ӳ���ļ����Եı��. ������Ŀǰ����ı��:
     ���                            ֵ      ����
     IMAGE_FILE_RELOCS_STRIPPED      0x0001 ��ӳ��, Windows CE, Windows NT ������. ָ���ļ��������������ض�λ����˱�����������������ѡ����ַ. ����û���ַ������, ����������һ������. ������ MS-DOS (Win32s? ���ϵĲ���ϵͳͨ������ʹ��Ԥ�������ַ����˲���������Щӳ��. ����, �� 4.0 �濪ʼ, Windows ��ʹ��һ����ѡ����ַ. Ĭ�ϵ���������Ϊ�Ǵ� EXE �����������ض�λ.
     IMAGE_FILE_EXECUTABLE_IMAGE     0x0002 ��ӳ��. ָ��ӳ���ļ��ǿ��õĲ���������. ����ñ��δ����, ͨ����ʾһ������������.
     IMAGE_FILE_LINE_NUMS_STRIPPED   0x0004 ����ȥ�� COFF ����.
     IMAGE_FILE_LOCAL_SYMS_STRIPPED  0x0008 ����ȥ�����ڱ��ط��ŵ� COFF ���ű����.
     IMAGE_FILE_AGGRESSIVE_WS_TRIM   0x0010 ���Ե�������������.
     IMAGE_FILE_LARGE_ADDRESS_AWARE  0x0020 Ӧ�ó�����Դ��� > 2gb �ĵ�ַ.
     IMAGE_FILE_16BIT_MACHINE        0x0040 ����.
     IMAGE_FILE_BYTES_REVERSED_LO    0x0080 Little endian: ���ڴ��� LSB ������ MSB.
     IMAGE_FILE_32BIT_MACHINE        0x0100 �������� 32-λ-�� ��ϵ.
     IMAGE_FILE_DEBUG_STRIPPED       0x0200 ��ӳ���ļ�����ȥ������Ϣ.
     IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP 0x0400 ���ӳ���ڿ��ƶ�ý����, ���Ʋ��ӽ����ļ�������.
     IMAGE_FILE_SYSTEM               0x1000 ӳ���ļ���һ��ϵͳ�ļ�, ����һ���û�����.
     IMAGE_FILE_DLL                  0x2000 ӳ���ļ���һ����̬���ӿ� (DLL). ��Ȼ������ֱ������, ��������Ϊ����һ����ִ���ļ�.
     IMAGE_FILE_UP_SYSTEM_ONLY       0x4000 �ļ�ֻ�������� UP ������.
     IMAGE_FILE_BYTES_REVERSED_HI    0x8000 Big endian: ���ڴ��� MSB ������  LSB.
     *)

     (*  ========= ��ȡ IMAGE_OPTIONAL_HEADER ��Ϣ========

       _IMAGE_OPTIONAL_HEADER = packed record
         { Standard fields. }
         Magic: Word;                     //���ֵò������ 0x010b
         MajorLinkerVersion: Byte;        //�������İ汾��
         MinorLinkerVersion: Byte;        //�������İ汾��
         SizeOfCode: DWORD;               //��ִ�д���ĳ��ȡ�
         SizeOfInitializedData: DWORD;    //��ʼ�����ݵĳ��� ( ���ݶ� ) ��
         SizeOfUninitializedData: DWORD;  //δ��ʼ�����ݵĳ��� ( BSS�� ) ��
         AddressOfEntryPoint: DWORD;      //�������� RVA ��ַ ,����������ʼִ�С�
         BaseOfCode: DWORD;               //��ִ�д�����ʼλ�á�
         BaseOfData: DWORD;               //��ʼ��������ʼλ��
         { NT additional fields. }
         ImageBase: DWORD;                //���������ѡ�� RVA ��ַ�������ַ�ɱ� Loader �ı䡣
         SectionAlignment: DWORD;         //�μ��غ����ڴ��еĶ��뷽ʽ��
         FileAlignment: DWORD;            //�����ļ��еĶ��뷽ʽ��
         MajorOperatingSystemVersion: Word;     //����ϵͳ�汾
         MinorOperatingSystemVersion: Word;     //����ϵͳ�汾
         MajorImageVersion: Word;         // ����汾
         MinorImageVersion: Word;         // ����汾
         MajorSubsystemVersion: Word;     // ��ϵͳ�汾��
         MinorSubsystemVersion: Word;     // ��ϵͳ�汾��
         Win32VersionValue: DWORD;        // ���ֵ��������Ϊ 0 ��
         SizeOfImage: DWORD;              // ��������ռ���ڴ��С ( �ֽ� ),�������жεĳ���֮��
         SizeOfHeaders: DWORD;            // �����ļ�ͷ�ĳ���֮�� ,�����ڴ��ļ���ʼ����һ���ε�ԭʼ����֮��Ĵ�С��
         CheckSum: DWORD;                 // У��͡������������������� ,�ڿ�ִ���ļ��п���Ϊ 0 ��
         Subsystem: Word;                 // NT ��ϵͳ�������������¼���ֵ��
             ==========================================
           ��ϵͳ��־ֵ 	����
                     0	δ֪
                     1	���أ�������������
                     2	Win32ͼ�ν���
                     3	Windows����̨
                     5	OS/2����̨
                     7	Posix����̨
                     8	���� Win9x ������
                     9	Win CE Ƕ��ʽϵͳ
                     10	EFIӦ�ó���
                     11	EFI���������豸
                     12	EFI����ʱ������
                     13	EFIֻ���洢��
                     14	X-Box
             =========================================
         DllCharacteristics: Word;        //Dll ״̬
         SizeOfStackReserve: DWORD;       //������ջ��С
         SizeOfStackCommit: DWORD;        // ������ʵ������Ķ�ջ�� ,����ʵ��������
         SizeOfHeapReserve: DWORD;        //�����Ѵ�С��
         SizeOfHeapCommit: DWORD;         //ʵ�ʶѴ�С��
         LoaderFlags: DWORD;              // Loader��־��ò��û��
         NumberOfRvaAndSizes: DWORD;      // Ŀ¼����ڸ���
         DataDirectory: packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TImageDataDirectory;
       end;                               //��һ�� IMAGE_DATA_DIRECTORY ����
        ===============================================     *)

    Edit25.Text := FM(NTHeader.OptionalHeader.Magic, 4);
    Edit26.Text := FM(NTHeader.OptionalHeader.MajorLinkerVersion, 2);
    Edit27.Text := FM(NTHeader.OptionalHeader.MinorLinkerVersion, 2);
    Edit28.Text := FM(NTHeader.OptionalHeader.SizeOfCode, 8);
    Edit29.Text := FM(NTHeader.OptionalHeader.SizeOfInitializedData, 8);
    Edit30.Text := FM(NTHeader.OptionalHeader.SizeOfUninitializedData, 8);
    Edit31.Text := FM(NTHeader.OptionalHeader.AddressOfEntryPoint, 8);
    Edit32.Text := FM(NTHeader.OptionalHeader.BaseOfCode, 8);

    Edit33.Text := FM(NTHeader.OptionalHeader.BaseOfData, 8);
    Edit34.Text := FM(NTHeader.OptionalHeader.ImageBase, 8);
    Edit35.Text := FM(NTHeader.OptionalHeader.SectionAlignment, 8);
    Edit36.Text := FM(NTHeader.OptionalHeader.FileAlignment, 8);
    Edit37.Text := FM(NTHeader.OptionalHeader.MajorOperatingSystemVersion, 4);
    Edit38.Text := FM(NTHeader.OptionalHeader.MinorOperatingSystemVersion, 4);
    Edit39.Text := FM(NTHeader.OptionalHeader.MajorImageVersion, 4);
    Edit40.Text := FM(NTHeader.OptionalHeader.MinorImageVersion, 4);

    Edit41.Text := FM(NTHeader.OptionalHeader.MajorSubsystemVersion, 4);
    Edit42.Text := FM(NTHeader.OptionalHeader.MinorSubsystemVersion, 4);
    Edit43.Text := FM(NTHeader.OptionalHeader.Win32VersionValue, 8);
    Edit44.Text := FM(NTHeader.OptionalHeader.SizeOfImage, 8);
    Edit45.Text := FM(NTHeader.OptionalHeader.SizeOfHeaders, 8);
    Edit46.Text := FM(NTHeader.OptionalHeader.CheckSum, 8);
    Edit47.Text := FM(NTHeader.OptionalHeader.Subsystem, 4);
    Edit48.Text := FM(NTHeader.OptionalHeader.DllCharacteristics, 4);

    Edit49.Text := FM(NTHeader.OptionalHeader.SizeOfStackReserve, 8);
    Edit50.Text := FM(NTHeader.OptionalHeader.SizeOfStackCommit, 8);
    Edit51.Text := FM(NTHeader.OptionalHeader.SizeOfHeapReserve, 8);
    Edit52.Text := FM(NTHeader.OptionalHeader.SizeOfHeapCommit, 8);
    Edit53.Text := FM(NTHeader.OptionalHeader.LoaderFlags, 8);
    Edit54.Text := FM(NTHeader.OptionalHeader.NumberOfRvaAndSizes, 8);


    (*  ====================== ��ȡ ���� ��Ϣ======================
      _IMAGE_SECTION_HEADER = packed record
        Name: packed array[0..IMAGE_SIZEOF_SHORT_NAME-1] of Byte;
        Misc: TISHMisc;
        VirtualAddress: DWORD;
        SizeOfRawData: DWORD;
        PointerToRawData: DWORD;
        PointerToRelocations: DWORD;
        PointerToLinenumbers: DWORD;
        NumberOfRelocations: Word;
        NumberOfLinenumbers: Word;
        Characteristics: DWORD;
      end;
      ============================================================= *)

    ListView1.Clear;
    for I := 0 to NTHeader.FileHeader.NumberOfSections - 1 do {�����ڱ�}
    begin
        {�����}
        SetLength(Str, 8);
        move(PESectionHeader[I].Name, Str[1], 8);
        with ListView1.Items.Add do
        begin
            Caption := InttoHex(I + 1, 2); //�������
            SubItems.Add(Str); //������
            //SubItems.Add(SesctionDescription(Str)); //��������
            SubItems.Add(FM(PESectionHeader[I].Misc.PhysicalAddress, 8)); //�����ַ
            SubItems.Add(FM(PESectionHeader[I].VirtualAddress, 8)); //�����ַƫ�ƣ�
            SubItems.Add(FM(PESectionHeader[I].Misc.VirtualSize, 8)); //�����ַ��С��
            SubItems.Add(FM(PESectionHeader[I].PointerToRawData, 8));
            SubItems.Add(FM(PESectionHeader[I].SizeOfRawData, 8));
            SubItems.Add(FM(PESectionHeader[I].Characteristics, 8)); 
            SubItems.Add(FM(PESectionHeader[I].PointerToRelocations, 8));
            SubItems.Add(FM(PESectionHeader[I].PointerToLinenumbers, 8));
        end;
    end;
end;

procedure TPE_Viewer.Button3Click(Sender: TObject);
begin
    if NTHeader.FileHeader.Characteristics = 0 then exit;
    try
      Crtics:= TCrtics.Create(Crtics);
      CheckCharactistics;
      Crtics.Label1.Caption:= inttoHex(NTHeader.FileHeader.Characteristics,4);
        if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
        begin
          Crtics.Show;
        end
        else
        begin
          Crtics.ShowModal;
        end;
    except
      Exit;
    end;
end;

procedure TPE_Viewer.CheckCharactistics;
var
    Chacteristic: WORD;
begin
    Chacteristic := NTHeader.FileHeader.Characteristics;
    if Chacteristic = 0 then exit;
    with Crtics do
    begin
      CheckBox1.Checked := CheckValue(IMAGE_FILE_RELOCS_STRIPPED, NTHeader.FileHeader.Characteristics);
      CheckBox2.Checked := CheckValue(IMAGE_FILE_EXECUTABLE_IMAGE, NTHeader.FileHeader.Characteristics);
      CheckBox3.Checked := CheckValue(IMAGE_FILE_LINE_NUMS_STRIPPED, NTHeader.FileHeader.Characteristics);
      CheckBox4.Checked := CheckValue(IMAGE_FILE_LOCAL_SYMS_STRIPPED, NTHeader.FileHeader.Characteristics);
      CheckBox5.Checked := CheckValue(IMAGE_FILE_AGGRESIVE_WS_TRIM, NTHeader.FileHeader.Characteristics);
      CheckBox6.Checked := CheckValue(IMAGE_FILE_BYTES_REVERSED_LO, NTHeader.FileHeader.Characteristics);
      CheckBox7.Checked := CheckValue(IMAGE_FILE_32BIT_MACHINE, NTHeader.FileHeader.Characteristics);
      CheckBox8.Checked := CheckValue(IMAGE_FILE_DEBUG_STRIPPED, NTHeader.FileHeader.Characteristics);
      CheckBox9.Checked := CheckValue(IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP, NTHeader.FileHeader.Characteristics);
      CheckBox10.Checked := CheckValue(IMAGE_FILE_NET_RUN_FROM_SWAP, NTHeader.FileHeader.Characteristics);
      CheckBox11.Checked := CheckValue(IMAGE_FILE_SYSTEM, NTHeader.FileHeader.Characteristics);
      CheckBox12.Checked := CheckValue(IMAGE_FILE_DLL, NTHeader.FileHeader.Characteristics);
      CheckBox13.Checked := CheckValue(IMAGE_FILE_UP_SYSTEM_ONLY, NTHeader.FileHeader.Characteristics);
      CheckBox14.Checked := CheckValue(IMAGE_FILE_BYTES_REVERSED_HI, NTHeader.FileHeader.Characteristics);
    end;
end;

procedure TPE_Viewer.WMDROPFILES(var Message: TWMDROPFILES);
var
    I: integer;
    buffer: array[0..255] of char;
    Ext: string;
begin
    DragQueryFile(Message.Drop, 0, @buffer, SizeOf(buffer));
    Ext := LowerCase(ExtractFileExt(StrPas(buffer)));

    if (Ext = '.exe') or (Ext = '.dll') or (Ext = '.ocx') or
        (Ext = '.sys') or (Ext = '.vxd') or (Ext = '.drv') then
    begin
        Edit55.Text := buffer;
        FileName := buffer;
        Button2Click(self);
    end else
    if (Ext = '.lnk') then //��ݷ�ʽ
    begin
        FileName:=GetShortcutTarget(Buffer);
        Edit55.Text := FileName;
        Button2Click(self);   
    end else
    begin
        Beep;
        FileName:='';
        for i:= 0 to ComponentCount-1 do
        begin
           if (Components[i] is TEdit) then (Components[I] as TEdit).Text:='';
        end;
        Edit55.Text := 'File Not Supported. Please drag another PE file.';
        PE_Viewer.ListView1.Clear;
    end;
    DragFinish(Message.Drop);
end;
procedure TPE_Viewer.FormCreate(Sender: TObject);
begin
  try
    SetWindowLongA(Button1.Handle,GWL_STYLE,(GetWindowLongA(Button1.Handle,GWL_STYLE) or BS_FLAT));
    SetWindowLongA(Button2.Handle,GWL_STYLE,(GetWindowLongA(Button2.Handle,GWL_STYLE) or BS_FLAT));
    SetWindowLongA(Button3.Handle,GWL_STYLE,(GetWindowLongA(Button3.Handle,GWL_STYLE) or BS_FLAT));
    SetWindowLongA(Button4.Handle,GWL_STYLE,(GetWindowLongA(Button4.Handle,GWL_STYLE) or BS_FLAT));
    SetWindowLongA(Button5.Handle,GWL_STYLE,(GetWindowLongA(Button5.Handle,GWL_STYLE) or BS_FLAT));

    DragAcceptFiles(PE_Viewer.Handle, True);
  except
    Exit;
  end;
end;

procedure TPE_Viewer.FormShow(Sender: TObject);
begin
  Self.cbOnTopClick(Sender);
  
  FileName:= fpath;
  if (FileName <> '') then
  begin
    Edit55.Text:= FileName;
    PE_Viewer.LoadPeInfo(FileName);
  end;
end;

procedure TPE_Viewer.Button4Click(Sender: TObject);
begin
  if not FileExists(FileName) then Exit;
  try
    IETable:= TIETable.Create(IETable);
    IETable.Load(FileName);
    IETable.PageControl1.ActivePage := IETable.TabSheet1;
    IETable.Caption := 'Import Table';
    if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
    begin
      IETable.Show;
    end
    else
    begin
      IETable.ShowModal;
    end;
  except
    Exit;
  end;
end;

procedure TPE_Viewer.Button5Click(Sender: TObject);
begin
    if not FileExists(FileName) then Exit;
    try
      IETable:= TIETable.Create(IETable);
      IETable.Load(FileName);
      IETable.PageControl1.ActivePage := IETable.TabSheet2;
      IETable.Caption := 'Export Table';
      if (pevMain.PE_Viewer.cbOnTop.Checked = True) then
      begin
        IETable.Show;
      end
      else
      begin
        IETable.ShowModal;
      end;
    except
      Exit;
    end;
end;

procedure TPE_Viewer.cbOnTopClick(Sender: TObject);
begin
  hwMain:= Self.Handle;
  case cbOnTop.Checked of
    True:
    begin
      Self.FormStyle:= fsStayOnTop;
      bOnTop:= True;
    end;
    False:
    begin
      Self.FormStyle:= fsNormal;
      bOnTop:= False;
    end;
  end;
end;

function TPE_Viewer.GetShortcutTarget(ShortcutFilename: string): string;
var
    Psl: IShellLink;
    Ppf: IPersistFile;
    WideName: array[0..MAX_PATH] of WideChar;
    pResult: array[0..MAX_PATH - 1] of CHAR;
    Data: TWin32FindData;
const
    IID_IPersistFile: TGUID = (D1: $0000010B; D2: $0000; D3: $0000; D4: ($C0, $00, $00, $00, $00, $00, $00, $46));
begin
    CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IID_IShellLinkA, Psl);
    Psl.QueryInterface(IID_IPersistFile, Ppf);
    MultiByteToWideChar(CP_ACP, 0, PChar(ShortcutFilename), -1, WideName, MAX_PATH);
    Ppf.Load(WideName, STGM_READ);
    Psl.Resolve(0, SLR_ANY_MATCH);
    Psl.GetPath(@pResult, MAX_PATH, Data, SLGP_UNCPRIORITY);
    Result := StrPas(@pResult);
end;

end.

