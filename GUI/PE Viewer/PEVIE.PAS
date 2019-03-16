unit pevie;
{导入函数表处理单元}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ComCtrls, uShared;

{PE导出表声明}
type
    PImageExportDirectory = ^TImageExportDirectory;
    TImageExportDirectory = packed record
        Characteristics: DWORD;
        TimeDateStamp: DWORD;
        MajorVersion: WORD;
        MinorVersion: WORD;
        Name: DWORD;
        Base: DWORD;
        NumberOfFunctions: DWORD;
        NumberOfNames: DWORD;
        AddressOfFunctions: DWORD;
        AddressOfNames: DWORD;
        AddressOfNameOrdinals: DWORD;
    end;

    PImportByName = ^TImportByName;
    TImportByName = packed record
        ProcedureHint: WORD;
        ProcedureName: array[0..1] of char;
    end;

    PImageImportDescriptor = ^TImageImportDescriptor;
    TImageImportDescriptor = packed record
        OriginalFirstThunk: DWORD;
        TimeDateStamp: DWORD;
        ForwarderChain: DWORD;
        DLLName: DWORD;
        FirstThunk: DWORD;
    end;

    PImageThunkData = ^TImageThunkData;
    TImageThunkData = record
        case Integer of
            1: (ForwarderString: DWORD; );
            2: (Function_: DWORD; );
            3: (Ordinal: DWORD; );
            4: (AddressOfData: DWORD; );
    end;
    PImageBaseRelocation = ^TImageBaseRelocation;
    TImageBaseRelocation = packed record
        VirtualAddress: DWORD;
        SizeOfBlock: DWORD;
        TypeOffset: array[0..1] of WORD; //不定长
    end;

    TPESection = record //自定义
        ObjectName: string;
        Address: PChar;
        PhysicalSize: Integer;
        PointerToRawData: Integer;
    end;

    TNameOrID = (niName, niID);
    TPEImport = record
        NameOrID: TNameOrID;
        Name: string;
        ID: Integer;
    end;
    TPEImports = record {记录一个Dll文件所调用的函数个数}
        DLLName: string;
        Entries: array of TPEImport; {函数数据}
    end;

    TPEExport = record
        Name: string;
        RelativeID: Integer;
        ID: Integer;
        Address: DWORD; {相对地址}
    end;

type
    TIETable = class(TForm)
        PageControl1: TPageControl;
        TabSheet1: TTabSheet;
        ListView1: TListView;
        TabSheet2: TTabSheet;
        ListView2: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
        procedure Load(AFileName: string);
    end;

var
    IETable: TIETable;
    PEImports: array of TPEImports;
    PEExport: array of TPEExport;
    Section: array of TPESection;
implementation

{$R *.dfm}

{ TForm3 }
procedure TIETable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (bOnTop= True) then
  begin
    ShowWindow(hwMain,SW_SHOWNORMAL);
  end;
end;

procedure TIETable.FormCreate(Sender: TObject);
begin
  if (bOnTop = True) then
  begin
    Self.FormStyle:= fsStayOnTop;
  end
  else
  begin
    Self.FormStyle:= fsNormal;
  end;
end;

procedure TIETable.FormShow(Sender: TObject);
begin
  if (bOnTop = True) then
  begin
    ShowWindow(hwMain,SW_HIDE);
  end;
end;

procedure TIETable.Load(AFileName: string);
type
    TImageSectionHeaderArray = array[0..1] of TImageSectionHeader;
    PImageSectionHeaderArray = ^TImageSectionHeaderArray;
var
    FileStream: TFileStream;
    ImageDosHeader: TImageDosHeader;
    ImageNtHeaders: TImageNtHeaders;
    ImageBase: PChar;
    FileBase: PChar;
    ImageSize: Integer;
    HeaderSize: Integer;
    NTHeader: PImageNtHeaders;
    I, J: Integer;
    ImportEntry: PImageImportDescriptor;
    LookupEntry: PDWord;
    ImportByName: PImportByName;
    SectionTable: PImageSectionHeaderArray;

    ExportEntry: PImageExportDirectory;
    AddressOfFunctions: PChar;
    AddressOfNames: PChar;
    AddressOfNameOrdinals: PChar;
    Found: boolean;
begin
    ListView1.Clear;
    for I := 0 to High(PEImports) do
        SetLength(PEImports[I].Entries, 0);
    SetLength(PEImports, 0);

    FileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
    with FileStream do
    begin
       ReadBuffer(ImageDosHeader, sizeof(TImageDosHeader));
        {以下检验是否是合法的PE文件}
        if ImageDosHeader.e_magic <> IMAGE_DOS_SIGNATURE then
        begin
            //showmessage('未知的文件格式.');
            FileStream.free;
            exit;
        end;
        if ImageDosHeader._lfanew >= Size then
        begin
            //showmessage('未知的文件格式.');
            FileStream.free;
            exit;
        end;
        Position := ImageDosHeader._lfanew;
        ReadBuffer(ImageNtHeaders, sizeof(TImageNtHeaders));
        {检验 NT Header.}
        if ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE then
        begin
            //showmessage('此文件不是WIN32 PE可执行文件.');
            FileStream.free;
            exit;
        end; 

        ImageBase := Pointer(ImageNtHeaders.OptionalHeader.ImageBase);
        ImageSize := ImageNtHeaders.OptionalHeader.SizeOfImage;
        HeaderSize := ImageNtHeaders.OptionalHeader.SizeOfHeaders;
        {在ImageBaseAdress中分配内存}
        FileBase := VirtualAlloc(ImageBase, ImageSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
        {返回映射后的基地址}
        if FileBase = nil then
        begin
            {由系统自动分配内存页}
            FileBase := VirtualAlloc(nil, ImageSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
            if FileBase = nil then
            begin
                MessageBox(0,'Error Allocating RAM.','Error',MB_OK+MB_ICONERROR);
                FileStream.free;
                exit;
            end;
        end;
        Position := 0;
        ReadBuffer(PPointer(FileBase)^, HeaderSize); {读取数据到文件头中}
        {把文件指针定位到NtHeader}
        NTHeader := PImageNtHeaders(FileBase + PImageDosHeader(FileBase)^._lfanew);
        {从文件中读取信息并保存在变量中}
        SetLength(Section, NTHeader^.FileHeader.NumberOfSections);
        SectionTable := PImageSectionHeaderArray(LongWord(NTHeader) + sizeof(TImageNtHeaders));
        for I := 0 to High(Section) do
        begin
            SetLength(Section[I].ObjectName, 8);
            Move(SectionTable^[I].Name, Section[I].ObjectName[1], 8);
            SetLength(Section[I].ObjectName, StrLen(PChar(Section[I].ObjectName)));
            Section[I].PhysicalSize := SectionTable^[I].SizeOfRawData;
            //       Section[I].VirtualSize := SectionTable^[I].Misc.VirtualSize;
            Section[I].Address := FileBase + SectionTable^[I].VirtualAddress;
            Section[I].PointerToRawData := SectionTable^[I].PointerToRawData;
            Position := SectionTable^[I].PointerToRawData;
            ReadBuffer(PPointer(Section[I].Address)^, Section[I].PhysicalSize);
            //       Section[I].Characteristics := SectionTable^[I].Characteristics;
        end;
        if NTHeader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress <> 0 then
        begin
            ImportEntry := PImageImportDescriptor(FileBase +
                NTHeader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
            {读取导入表入口，直到空为止}
            while ImportEntry^.DLLName <> 0 do
            begin
                {新导入表入口}
                SetLength(PEImports, Length(PEImports) + 1);
                PEImports[High(PEImports)].DLLName := FileBase + ImportEntry^.DLLName;
                if ImportEntry^.OriginalFirstThunk <> 0 then
                    LookupEntry := PDWord(FileBase + ImportEntry^.OriginalFirstThunk)
                else LookupEntry := PDWord(FileBase + ImportEntry^.FirstThunk);
                {继续读取此Dll直到为空}
                while LookupEntry^ <> 0 do
                begin
                    {函数入口}
                    SetLength(PEImports[High(PEImports)].Entries, Length(PEImports[High(PEImports)].Entries) + 1);
                    with PEImports[High(PEImports)].Entries[High(PEImports[High(PEImports)].Entries)] do
                    begin
                        if (LookupEntry^ and $80000000) <> 0 then
                        begin
                            NameOrID := niID;
                            ID := LookupEntry^ and $7FFFFFFF; {为ID，屏蔽最高位}
                            with IETable.ListView1.Items.Add do
                            begin
                                Caption :='ID= '+Trim(InttoHex(ID, 4))+ ' (' + Trim(Format('%-34d', [ID])) +')';
                                SubItems.Add(Trim(Format('%-28s', [(PEImports[High(PEImports)].DLLName)])));
                                SubItems.Add('nil');
                                SubItems.Add(InttoHex(LookupEntry^, 8));
                            end;
                        end else
                        begin
                            NameOrID := niName;
                            ImportByName := PImportByName(FileBase + LookupEntry^);
                            Name := ImportByName^.ProcedureName; {头两个字节存储ID，其后紧跟为名字}
                            with IETable.ListView1.Items.Add do
                            begin
                                Caption := Trim(Format('%-36s', [ImportByName^.ProcedureName]));
                                SubItems.Add(Trim(Format('%-18s', [PEImports[High(PEImports)].DLLName])));
                                SubItems.Add(Format('%.4X', [ImportByName^.ProcedureHint]));
                                SubItems.Add(Format('%.8X', [LookupEntry^]));
                            end;
                        end;
                    end;
                    Inc(LookupEntry);
                end; //end with
                Inc(ImportEntry);
            end; //end while
        end;

        if NTHeader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress <> 0 then
        begin
            ExportEntry := PImageExportDirectory(FileBase +
                NTHeader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
            {ExportEntry指向导出表的位置}
            AddressOfNames := FileBase + ExportEntry^.AddressOfNames;
            AddressOfNameOrdinals := FileBase + ExportEntry^.AddressOfNameOrdinals;
            AddressOfFunctions := FileBase + ExportEntry^.AddressOfFunctions;

            {导出的函数的个数}
            SetLength(PEExport, ExportEntry^.NumberOfFunctions);
            for I := 0 to ExportEntry^.NumberOfNames - 1 do {以名字导出的函数的个数}
            begin
                {保存导出地址}
                PEExport[I].Name := FileBase + PDWord(AddressOfNames + I * 4)^;
                {以ID来查找的导出函数}
                PEExport[I].RelativeID := PWord(AddressOfNameOrdinals + I * 2)^;
                PEExport[I].ID := PEExport[I].RelativeID + Integer(ExportEntry^.Base - 1);
                {函数所处一地址}
                PEExport[I].Address := PDWord(AddressOfFunctions + PEExport[I].RelativeID * 4)^; //相对地址,+FileBase=绝对地址
                with IETable.ListView2.Items.Add do
                begin
                    Caption := Trim(Format('%-36s', [PEExport[I].Name]));
                    SubItems.Add(Trim(Format('%.5d', [PEExport[I].ID])));
                    SubItems.Add(Format('%.8X',[DWORD(PEExport[I].Address)]));
                end;
            end;
            for I := 0 to ExportEntry^.NumberOfFunctions - 1 do {搜索以编号导出的函数}
            begin
                Found := false;
                for J := 0 to ExportEntry^.NumberOfNames - 1 do
                begin
                    if I = PEExport[J].RelativeID then
                    begin
                        Found := true;
                        break;
                    end;
                end;
                if not Found then
                begin
                    PEExport[I].Name := '';
                    PEExport[I].RelativeID := I;
                    PEExport[I].ID := PEExport[I].RelativeID + Integer(ExportEntry^.Base - 1);
                    PEExport[I].Address := PDWord(AddressOfFunctions + PEExport[I].ID * 4)^; //相对地址,+FileBase=绝对地址
                    with IETable.ListView2.Items.Add do
                    begin
                        Caption := Trim(Format('%-36s', ['']));
                        SubItems.Add(Trim(Format('%.5d', [PEExport[I].ID - Integer(ExportEntry^.Base - 1)])));
                        SubItems.Add(InttoHex(DWORD(PEExport[I].Address), 8));
                    end;
                end;
            end;
        end;
    end;
    VirtualFree(FileBase, 0, MEM_RELEASE);
    FileStream.free;
end;

procedure TIETable.PageControl1Change(Sender: TObject);
begin
   if PageControl1.ActivePage = IETable.TabSheet1 then
   IETable.Caption:='Import Table' else
   IETable.Caption:='Export Table';
end;

end.

