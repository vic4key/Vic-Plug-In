{*****************************************************************}
{                                                                 }
{       SttUnhooker unit by StTwister                             }
{       http://gateofgod.com                                      }
{       StTwister2003@yahoo.co.uk                                 }
{                                                                 }
{       Unhooks APIs for both local and remote processes          }
{                                                                 }
{*****************************************************************}
unit untSttUnhooker;

// if the DISPLAY_ERRORS flag is enabled, any error/warning will show up
{$DEFINE DISPLAY_ERRORS}

interface

uses
  Windows;

function UnHookAPI(strModuleName, strFuncName: string): boolean;
function UnHookAPIEx(hProcess: THandle; strModuleName, strFuncName: string): boolean;
function GetRealProcAddress(strModuleName, strFuncName: string): Pointer;
function GetRealProcAddressEx(hProcess: THandle; strModuleName, strFuncName: string): Pointer;

var
  pCreateRemoteThread: function(hProcess: THandle; lpThreadAttributes: Pointer; dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;
  pVirtualAllocEx: function(hProcess: THandle; lpAddress: Pointer; dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;
  pWriteProcessMemory: function(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer; nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;

implementation

type
  TSmallArray = array[1..20] of byte;

  PRemoteInfo = ^TRemoteInfo;
  TRemoteInfo = record
    pGetModuleHandle: function(lpModuleName: PAnsiChar): cardinal; stdcall;
    pGetProcAddress: function(hModule: cardinal; lpProcName: PAnsiChar): Pointer; stdcall;
    pGetModuleFileName: function(hModule: cardinal; lpFilename: PAnsiChar; nSize: cardinal): cardinal; stdcall;
    lpModuleName, lpFuncName, lpFilename: PChar;
    lpFuncAddress: Pointer;
    dwLength: DWORD;
  end;


const
  Opcodes1: array [0..255] of word =
  (
    (16913),(17124),(8209),(8420),(33793),(35906),(0),(0),(16913),(17124),(8209),(8420),(33793),(35906),(0),(0),(16913),
    (17124),(8209),(8420),(33793),(35906),(0),(0),(16913),(17124),(8209),(8420),(33793),(35906),(0),(0),(16913),
    (17124),(8209),(8420),(33793),(35906),(0),(32768),(16913),(17124),(8209),(8420),(33793),(35906),(0),(32768),(16913),
    (17124),(8209),(8420),(33793),(35906),(0),(32768),(529),(740),(17),(228),(1025),(3138),(0),(32768),(24645),
    (24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(69),
    (69),(69),(69),(69),(69),(69),(69),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(24645),(0),
    (32768),(228),(16922),(0),(0),(0),(0),(3072),(11492),(1024),(9444),(0),(0),(0),(0),(5120),
    (5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(5120),(1296),
    (3488),(1296),(1440),(529),(740),(41489),(41700),(16913),(17124),(8209),(8420),(17123),(8420),(227),(416),(0),
    (57414),(57414),(57414),(57414),(57414),(57414),(57414),(32768),(0),(0),(0),(0),(0),(0),(32768),(33025),
    (33090),(769),(834),(0),(0),(0),(0),(1025),(3138),(0),(0),(32768),(32768),(0),(0),(25604),
    (25604),(25604),(25604),(25604),(25604),(25604),(25604),(27717),(27717),(27717),(27717),(27717),(27717),(27717),(27717),(17680),
    (17824),(2048),(0),(8420),(8420),(17680),(19872),(0),(0),(2048),(0),(0),(1024),(0),(0),(16656),
    (16800),(16656),(16800),(33792),(33792),(0),(32768),(8),(8),(8),(8),(8),(8),(8),(8),(5120),
    (5120),(5120),(5120),(33793),(33858),(1537),(1602),(7168),(7168),(0),(5120),(32775),(32839),(519),(583),(0),
    (0),(0),(0),(0),(0),(8),(8),(0),(0),(0),(0),(0),(0),(16656),(416)
  );

  Opcodes2: array [0..255] of word =
  (
    (280),(288),(8420),(8420),(65535),(0),(0),(0),(0),(0),(65535),(65535),(65535),(272),(0),(1325),(63),
    (575),(63),(575),(63),(63),(63),(575),(272),(65535),(65535),(65535),(65535),(65535),(65535),(65535),(16419),
    (16419),(547),(547),(65535),(65535),(65535),(65535),(63),(575),(47),(575),(61),(61),(63),(63),(0),
    (32768),(32768),(32768),(0),(0),(65535),(65535),(65535),(65535),(65535),(65535),(65535),(65535),(65535),(65535),(8420),
    (8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(8420),(16935),
    (63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(63),(237),
    (237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(101),(237),(1261),
    (1192),(1192),(1192),(237),(237),(237),(0),(65535),(65535),(65535),(65535),(65535),(65535),(613),(749),(7168),
    (7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(7168),(16656),
    (16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(16656),(0),
    (0),(32768),(740),(18404),(17380),(49681),(49892),(0),(0),(0),(17124),(18404),(17380),(32),(8420),(49681),
    (49892),(8420),(17124),(8420),(8932),(8532),(8476),(65535),(65535),(1440),(17124),(8420),(8420),(8532),(8476),(41489),
    (41700),(1087),(548),(1125),(9388),(1087),(33064),(24581),(24581),(24581),(24581),(24581),(24581),(24581),(24581),(65535),
    (237),(237),(237),(237),(237),(749),(8364),(237),(237),(237),(237),(237),(237),(237),(237),(237),
    (237),(237),(237),(237),(237),(63),(749),(237),(237),(237),(237),(237),(237),(237),(237),(65535),
    (237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(237),(0)
  );

  Opcodes3: array [0..9] of array [0..15] of word =
  (
    ((1296),(65535),(16656),(16656),(33040),(33040),(33040),(33040),(1296),(65535),(16656),(16656),(33040),(33040),(33040),(33040)),
    ((3488),(65535),(16800),(16800),(33184),(33184),(33184),(33184),(3488),(65535),(16800),(16800),(33184),(33184),(33184),(33184)),
    ((288),(288),(288),(288),(288),(288),(288),(288),(54),(54),(48),(48),(54),(54),(54),(54)),
    ((288),(65535),(288),(288),(272),(280),(272),(280),(48),(48),(0),(48),(0),(0),(0),(0)),
    ((288),(288),(288),(288),(288),(288),(288),(288),(54),(54),(54),(54),(65535),(0),(65535),(65535)),
    ((288),(65535),(288),(288),(65535),(304),(65535),(304),(54),(54),(54),(54),(0),(54),(54),(0)),
    ((296),(296),(296),(296),(296),(296),(296),(296),(566),(566),(48),(48),(566),(566),(566),(566)),
    ((296),(65535),(296),(296),(272),(65535),(272),(280),(48),(48),(48),(48),(48),(48),(65535),(65535)),
    ((280),(280),(280),(280),(280),(280),(280),(280),(566),(566),(48),(566),(566),(566),(566),(566)),
    ((280),(65535),(280),(280),(304),(296),(304),(296),(48),(48),(48),(48),(0),(54),(54),(65535))
  );

function LowerCase(const S: string): string;
var
  Ch: Char;
  i: Integer;
  Source, Dest: PChar;
begin
  i := Length(S);
  SetLength(Result, i);
  Source := PChar(S);
  Dest := PChar(Result);
  while i <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'A') and (Ch <= 'Z') then
      Inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(i);
  end;
end;


// displays an error message if the DISPLAY_ERRORS flag is enabled
procedure Error(strError: string);
begin
{$IFDEF DISPLAY_ERRORS}
  // change this line if you want the error to appear in a different way than a messagebox.
  // For example, you could use Write() in console apps or append to a log file
  MessageBox(0, PChar(strError), 'Error', MB_ICONERROR);
{$ENDIF}
end;

// as small LDE to calculate the length of CPU instructions
// taken from Aphex's afxCodeHook unit (http://www.iamaphex.com)
function SizeOfCode(Code: pointer): longword;
var
  Opcode: word;
  Modrm: byte;
  Fixed, AddressOveride: boolean;
  Last, OperandOveride, Flags, Rm, Size, Extend: longword;
begin
  try
    Last := longword(Code);
    if Code <> nil then
    begin
      AddressOveride := False;
      Fixed := False;
      OperandOveride := 4;
      Extend := 0;
      repeat
        Opcode := byte(Code^);
        Code := pointer(longword(Code) + 1);
        if Opcode = $66 then
        begin
          OperandOveride := 2;
        end
        else if Opcode = $67 then
        begin
          AddressOveride := True;
        end
        else
        begin
          if not ((Opcode and $E7) = $26) then
          begin
            if not (Opcode in [$64..$65]) then
            begin
              Fixed := True;
            end;
          end;
        end;
      until Fixed;
      if Opcode = $0f then
      begin
        Opcode := byte(Code^);
        Flags := Opcodes2[Opcode];
        Opcode := Opcode + $0f00;
        Code := pointer(longword(Code) + 1);
      end
      else
      begin
        Flags := Opcodes1[Opcode];
      end;
      if ((Flags and $0038) <> 0) then
      begin
        Modrm := byte(Code^);
        Rm := Modrm and $7;
        Code := pointer(longword(Code) + 1);
        case (Modrm and $c0) of
          $40: Size := 1;
          $80:
            begin
              if AddressOveride then
              begin
                Size := 2;
              end
              else
                Size := 4;
              end;
          else
          begin
            Size := 0;
          end;
        end;
        if not (((Modrm and $c0) <> $c0) and AddressOveride) then
        begin
          if (Rm = 4) and ((Modrm and $c0) <> $c0) then
          begin
            Rm := byte(Code^) and $7;
          end;
          if ((Modrm and $c0 = 0) and (Rm = 5)) then
          begin
            Size := 4;
          end;
          Code := pointer(longword(Code) + Size);
        end;
        if ((Flags and $0038) = $0008) then
        begin
          case Opcode of
            $f6: Extend := 0;
            $f7: Extend := 1;
            $d8: Extend := 2;
            $d9: Extend := 3;
            $da: Extend := 4;
            $db: Extend := 5;
            $dc: Extend := 6;
            $dd: Extend := 7;
            $de: Extend := 8;
            $df: Extend := 9;
          end;
          if ((Modrm and $c0) <> $c0) then
          begin
            Flags := Opcodes3[Extend][(Modrm shr 3) and $7];
          end
          else
          begin
            Flags := Opcodes3[Extend][((Modrm shr 3) and $7) + 8];
          end;
        end;
      end;
      case (Flags and $0C00) of
        $0400: Code := pointer(longword(Code) + 1);
        $0800: Code := pointer(longword(Code) + 2);
        $0C00: Code := pointer(longword(Code) + OperandOveride);
        else
        begin
          case Opcode of
            $9a, $ea: Code := pointer(longword(Code) + OperandOveride + 2);
            $c8: Code := pointer(longword(Code) + 3);
            $a0..$a3:
              begin
                if AddressOveride then
                begin
                  Code := pointer(longword(Code) + 2)
                end
                else
                begin
                  Code := pointer(longword(Code) + 4);
                end;
              end;
          end;
        end;
      end;
    end;
    Result := longword(Code) - Last;
  except
    Result := 0;
  end;
end;

// unhooks some APIs used for remote unhooking, so FWs don't catch it
procedure InitInjectionAPIs;
begin
  pVirtualAllocEx := GetRealProcAddress('kernel32', 'VirtualAllocEx');
  pWriteProcessMemory := GetRealProcAddress('kernel32', 'WriteProcessMemory');
  pCreateRemoteThread := GetRealProcAddress('kernel32', 'CreateRemoteThread');
end;

// this is a function that will be injected in the remote thread to get the function address
// and full path to library file
procedure RemoteThread(Param: Pointer); stdcall;
begin
  With TRemoteInfo(Param^) do
  begin
    lpFuncAddress := pGetProcAddress(pGetModuleHandle(lpModuleName), lpFuncName);
    dwLength := pGetModuleFileName(pGetModuleHandle(lpModuleName), lpFileName, 4096);
  end;
end;

// null function used to calculate the size of the RemoteThread function
procedure RemoteThreadEnd; stdcall;
begin
end;

function GetRemoteProcAddress(hProcess: THandle; strModuleName, strFuncName: string;
  var strFileName: string): pointer;
var
  RemoteInfo: TRemoteInfo;
  dwBytesWritten, dwSize: DWORD;
  lpRemoteInfo, lpFunc: Pointer;
  TID: cardinal;
begin
  // if we are unhooking local process, we don't need to inject a function
  if hProcess = GetCurrentProcess then
  begin
    Result := GetProcAddress(GetModuleHandle(Pchar(strModuleName)), PChar(strFuncName));
    SetLength(strFileName, 4096);
    dwBytesWritten := GetModuleFileName(GetModuleHandle(PChar(strModuleName)), PChar(strFileName), 4096);
    SetLength(strFileName, dwBytesWritten);
    exit;
  end;

  // fill API addresses into RemoteInfo
  RemoteInfo.pGetModuleHandle := GetProcAddress(GetModuleHandle('kernel32'), 'GetModuleHandleA');
  RemoteInfo.pGetProcAddress := GetProcAddress(GetModuleHandle('kernel32'), 'GetProcAddress');
  RemoteInfo.pGetModuleFileName := GetProcAddress(GetModuleHandle('kernel32'), 'GetModuleFileNameA');

  // allocate memory for the strings in the remote process
  RemoteInfo.lpModuleName := pVirtualAllocEx(hProcess, nil, Length(strModuleName)+1, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  RemoteInfo.lpFuncName := pVirtualAllocEx(hProcess, nil, Length(strFuncName)+1, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  RemoteInfo.lpFileName := pVirtualAllocEx(hProcess, nil, 4096, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);

  // write strings to remote process
  pWriteProcessMemory(hProcess, RemoteInfo.lpModuleName, PChar(strModuleName), Length(strModuleName) + 1, dwBytesWritten);
  pWriteProcessMemory(hProcess, RemoteInfo.lpFuncName, PChar(strFuncName), Length(strFuncName), dwBytesWritten);

  // allocate memory for the remote info structure in the remote process
  lpRemoteInfo := pVirtualAllocEx(hProcess, nil, SizeOf(TRemoteInfo), MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);

  // write remote info structure to the remote process
  pWriteProcessMemory(hProcess, lpRemoteInfo, @RemoteInfo, SizeOf(RemoteInfo), dwBytesWritten);

  // calculate the size of the remote function
  dwSize := DWORD(@RemoteThreadEnd) - DWORD(@RemoteThread);

  // allocate meory for the remote function in the remote process
  lpFunc := pVirtualAllocEx(hProcess, nil, dwSize, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);

  // write remote function to the remote process
  pWriteProcessMemory(hProcess, lpFunc, @RemoteThread, dwSize, dwBytesWritten);

  // execute the remote function
  TID := pCreateRemoteThread(hProcess, nil, 0, lpFunc, lpRemoteInfo, 0, TID);

  // wait for the remote thread to terminate
  WaitForSingleObject(TID, INFINITE);

  // get back the results
  ReadProcessMemory(hProcess, lpRemoteInfo, @RemoteInfo, SizeOf(RemoteInfo), dwBytesWritten);

  Result := RemoteInfo.lpFuncAddress;

  // get the module path
  SetLength(strFileName, RemoteInfo.dwLength);
  ReadProcessMemory(hProcess, RemoteInfo.lpFilename, PChar(strFileName), RemoteInfo.dwLength, dwBytesWritten);

  // clean up
  VirtualFreeEx(hProcess, RemoteInfo.lpModuleName, Length(strModuleName)+1, MEM_RELEASE);
  VirtualFreeEx(hProcess, RemoteInfo.lpFuncName, Length(strFuncName)+1, MEM_RELEASE);
  VirtualFreeEx(hProcess, RemoteInfo.lpFileName, 4096, MEM_RELEASE);
  VirtualFreeEx(hProcess, lpRemoteInfo, SizeOf(TRemoteInfo), MEM_RELEASE);
  VirtualFreeEx(hProcess, lpFunc, dwSize, MEM_RELEASE);
end;

// read the first bytes of the function to see if it's hooked or not
function ReadFunctionBytes(hProcess: Thandle; strModuleName, strFuncName: string;
  var SmallArray: TSmallArray; var lpFuncAddress: Pointer; var strFileName: string): boolean;
var
  dwBytesRead: dword;
begin
  Result := False;

  // if module is kernel32, we don't need to inject a routine to get the function
  // address since kernel32 APIs have the same address in all processes
  if (LowerCase(strModuleName) = 'kernel32') or (LowerCase(strModuleName) = 'kernel32.dll') then
  begin
    lpFuncAddress := GetProcAddress(GetModuleHandle(PChar(strModuleName)), PChar(strFuncName));
    SetLength(strFileName, 4096);
    dwBytesRead := GetModuleFileName(GetModuleHandle(Pchar(strModuleName)), PChar(strFileName), 4096);
    SetLength(strFileName, 4096);
  end
  else
  begin
    lpFuncAddress := GetRemoteProcAddress(hProcess, strModuleName, strFuncName, strFileName);
  end;

  if lpFuncAddress = nil then
  begin
    Error('Cannot get the address of function '+strFuncName+' function!');
    exit;
  end;

  // read the first 20 bytes of the function to detect if function is hooked and to calculate
  // how many bytes need to be rewritten
  ReadProcessMemory(hProcess, lpFuncAddress, @SmallArray, SizeOf(SmallArray), dwBytesRead);
  if dwBytesRead <> SizeOf(SmallArray) then
  begin
    Error('Cannot read from remote function address!');
    exit;
  end;

  Result := True;
end;

// reads the original start bytes of an API directly from the library file
function ReadOriginalFunctionBytes(strModuleName, strFuncName, strFileName: string;
  var SmallArray: TSmallArray; intNops: Integer): boolean;

  function GetFieldOffset(const Struct; const Field): Cardinal;
  begin
    Result := Cardinal(@Field) - Cardinal(@Struct);
  end;

  // replacement of IMAGE_FIRST_SECTION macro
  function GetImageFirstSection(NtHeader: PImageNtHeaders): PImageSectionHeader;
  begin
    Result := PImageSectionHeader(Cardinal(NtHeader) +
      GetFieldOffset(NtHeader^, NtHeader^.OptionalHeader) +
      NtHeader^.FileHeader.SizeOfOptionalHeader);
  end;

var
  hFile: THandle;
  lpstrFuncName: PChar;
  lpData, lpFunc: Pointer;
  dwSize,dwBytesRead, dwVirtualOffset, dwPhysicalOffset, dwFuncOrdinal: DWORD;
  i: Integer;
  bFound: Boolean;
  DosHeader: PImageDosHeader;
  NTHeader: PImageNtHeaders;
  ExportDir: PImageExportDirectory;
  Directory: PImageDataDirectory;
  SectionHeader: PImageSectionHeader;
begin
  Result := False;

  // open the file in read mode
  hFile := CreateFile(PChar(strFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile = INVALID_HANDLE_VALUE then
  begin
    Error('Cannot open file '+strModuleName+'!');
    CloseHandle(hFile);
    exit;
  end;

  // copy to memory
  dwSize := GetFileSize(hFile, nil);
  lpData := GetMemory(dwSize);
  ReadFile(hFile, lpData^, dwSize, dwBytesRead, nil);
  CloseHandle(hFile);
  if dwBytesRead <> dwSize then
  begin
    Error('Cannot read from file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  // load the MZ and PE headers
  DosHeader := lpData;
  if DosHeader.e_magic <> IMAGE_DOS_SIGNATURE then
  begin
    Error('Invalid MZ header in file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;
  NTHeader := Pointer(Integer(lpData) + DosHeader._lfanew);
  if NTHeader.Signature <> IMAGE_NT_SIGNATURE then
  begin
    Error('Invalid PE header in file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  // get the export table virtual address
  Directory := @NTHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
  if Directory.Size = 0 then
  begin
    Error('No export table found in file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;
  dwVirtualOffset := Directory.VirtualAddress;

  // find the section where the export table is located
  // dwVirtualOffset = offset where the export table would normally reside in memory
  // dwPhysicalOffset = offset where export table is located in current app memory (as if it was a file)
  dwPhysicalOffset := 0;
  SectionHeader := GetImageFirstSection(NtHeader);
  for i := 1 to NTHeader.FileHeader.NumberOfSections do
  begin
    if (dwVirtualOffset >= SectionHeader.VirtualAddress) and (dwVirtualOffset < SectionHeader.VirtualAddress + SectionHeader.SizeOfRawData) then
    begin
      dwPhysicalOffset := SectionHeader.PointerToRawData + (dwVirtualOffset - SectionHeader.VirtualAddress);
      break;
    end;
    SectionHeader := Pointer(DWORD(SectionHeader) + SizeOf(TImageSectionHeader));
  end;

  if dwPhysicalOffset = 0 then
  begin
    Error('Cannot find section where export table is located in file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  ExportDir := Pointer(DWORD(lpData) + dwPhysicalOffset);

  // loop through all functions to find right function (with the name strFuncName)
  bFound := False;
  lpFunc := Pointer(DWORD(ExportDir) + (DWORD(ExportDir.AddressOfNames) - dwVirtualOffset));
  for i := 1 to ExportDir.NumberOfNames do
  begin
    lpstrFuncName := Pointer(DWORD(ExportDir) + (DWORD(lpFunc^) - dwVirtualOffset));
    if lpstrFuncName = strFuncName then
    begin
      bFound := True;
      break;
    end;
    lpFunc := Pointer(DWORD(lpFunc) + SizeOf(DWORD));
  end;

  if not bFound then
  begin
    Error('Function '+strFuncName+' not found in the export table of the file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  // find the function ordinal associated to the function name
  lpFunc := Pointer(DWORD(ExportDir) + (DWORD(ExportDir.AddressOfNameOrdinals) - dwVirtualOffset));
  lpFunc := Pointer(Integer(lpFunc) + (i - 1) * SizeOf(WORD));
  dwFuncOrdinal := WORD(lpFunc^) + ExportDir.Base;
  if (dwFuncOrdinal < ExportDir.Base) or (dwFuncOrdinal > ExportDir.Base + ExportDir.NumberOfFunctions - 1) then
  begin
    Error('No function ordinal found for function '+strFuncName+' in the file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  // get the function entry address using the function ordinal
  lpFunc := Pointer(DWORD(ExportDir) + (DWORD(ExportDir.AddressOfFunctions) - dwVirtualOffset + (dwFuncOrdinal - ExportDir.Base) * SizeOf(DWORD)));

  // finally we got the function address. Now we must find the coresponding section and copy
  // the function code
  dwPhysicalOffset := 0;
  SectionHeader := GetImageFirstSection(NtHeader);
  for i := 1 to NTHeader.FileHeader.NumberOfSections do
  begin
    if (DWORD(lpFunc^) >= SectionHeader.VirtualAddress) and (DWORD(lpFunc^) < SectionHeader.VirtualAddress + SectionHeader.SizeOfRawData) then
    begin
      dwPhysicalOffset := SectionHeader.PointerToRawData + (DWORD(lpFunc^) - SectionHeader.VirtualAddress);
      break;
    end;
    SectionHeader := Pointer(DWORD(SectionHeader) + SizeOf(TImageSectionHeader));
  end;

  if dwPhysicalOffset = 0 then
  begin
    Error('Cannot find function '+strFuncName+' code in the file '+strModuleName+'!');
    FreeMem(lpData, dwSize);
    exit;
  end;

  // finally we can copy our needed data into SmallArray
  CopyMemory(@SmallArray, Pointer(DWORD(lpData) + dwPhysicalOffset), intNops);

  // free the loaded file
  FreeMem(lpData, dwSize);
  Result := True;

end;

// unhooks an API, given the module name and function name
// only unhooks overwriting/extended overwriting hooks
function UnHookAPI(strModuleName, strFuncName: string): boolean;
begin
  Result := UnHookAPIEx(GetCurrentProcess, strModuleName, strFuncName);
end;

// unhooks an API of a remote process, given the modeule name and function name
// only unhooks overwriting/extended overwriting hooks
function UnHookAPIEx(hProcess: THandle; strModuleName, strFuncName: string): boolean;
var
  SmallArray: TSmallArray;
  intNops: Integer;
  dwBytesWritten: DWORD;
  lpFuncAddress: Pointer;
  strFileName: string;
begin
  Result := False;

  // read the first 20 bytes of the function
  // also gets the address of the function in the remote process and the full path to library
  if not ReadFunctionBytes(hProcess, strModuleName, strFuncName, SmallArray, lpFuncAddress, strFileName) then
    exit;

  // if the function is hooked, it contains a JMP as the first operations
  // therefore, if the first byte is not $E9, then we know the function is not hooked
  if SmallArray[1] <> $E9 then
  begin
    Result := True;
    exit;
  end;

  // read how many NOPs exist after the JMP so we can know how many bytes need to be rewritten
  intNops := 0;
  while SmallArray[6 + intNops] = $90 do
    inc(intNops);
  // intNops + 5 = total number of bytes that need to be rewritten
  intNops := intNops + 5;

  if not ReadOriginalFunctionBytes(strModuleName, strFuncName, strFileName, SmallArray, intNops) then
    exit;

  pWriteProcessMemory(hProcess, lpFuncAddress, @SmallArray, intNops, dwBytesWritten);
  if dwBytesWritten <> DWORD(intNops) then
  begin
    Error('Cannot write data to remote API location');
    exit;
  end;

  Result := True;
end;

// Creates a new function that behaves exactly like the original one, given the module name
// and function name, but without being hooked.
// Use this function rather than UnHookAPI if u want to have access to both hooked and unhooked
// functions or if u don;t want the function to be rehooked
function GetRealProcAddress(strModuleName, strFuncName: string): Pointer;
begin
  Result := GetRealProcAddressEx(GetCurrentProcess, strModuleName, strFuncName);
end;

function GetRealProcAddressEx(hProcess: THandle; strModuleName, strFuncName: string): Pointer;
var
  SmallArray: TSmallArray;
  dwBytesWritten, dwLength, dwLen: DWORD;
  lpFuncAddress, lpNewFuncAddress, lpAddr: Pointer;
  strFileName: string;
begin
  Result := nil;

  // read the first 20 bytes of the function
  // also gets the address of the function in the remote process and the full path to library
  if not ReadFunctionBytes(hProcess, strModuleName, strFuncName, SmallArray, lpFuncAddress, strFileName) then
    exit;

  if not ReadOriginalFunctionBytes(strModuleName, strFuncName, strFileName, SmallArray, 20) then
    exit;

  // use a LDE to find the length of the instructions that have benn overwirtten by the JMP
  lpAddr := @SmallArray;
  dwLength := 0;
  While dwLength < 5 do
  begin
    dwLen := SizeOfCode(lpAddr);
    if dwLen = 0 then
      exit;
    dwLength := dwLength + dwLen;
    lpAddr := Pointer(DWORD(lpAddr) + dwLen);
  end;

  // allocate memory for the new function
  if @pVirtualAllocEx <> nil then
    lpNewFuncAddress := pVirtualAllocEx(hProcess, nil, dwLength + 5, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE)
  else
    lpNewFuncAddress := VirtualAllocEx(hProcess, nil, dwLength + 5, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if lpNewFuncAddress = nil then
  begin
    Error('Cannot allocate memory for the new function');
    exit;
  end;

  // after we've got the bytes that were modified, we need to link them back to the original
  // function with a JMP ($E9)
  SmallArray[dwLength + 1] := $E9;
  DWORD(Pointer(DWORD(@SmallArray) + dwLength + 1)^) := DWORD(lpFuncAddress) - DWORD(lpNewFuncAddress) - 5;

  // finally write the created function to the remote process
  if @pWriteProcessMemory <> nil then
    pWriteProcessMemory(hProcess, lpNewFuncAddress, @SmallArray, dwLength + 5, dwBytesWritten)
  else
    WriteProcessMemory(hProcess, lpNewFuncAddress, @SmallArray, dwLength + 5, dwBytesWritten);
  if dwBytesWritten <> DWORD(dwLength + 5) then
  begin
    Error('Cannot write data to remote API location');
    exit;
  end;

  Result := lpNewFuncAddress;
end;

initialization
  InitInjectionAPIs;

end.
