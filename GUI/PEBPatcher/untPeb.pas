{

  Process Environment Block (PEB) Patch Unit
  ------------------------------------------
  27th September 2005
  by ErazerZ

  Contact:
    E-Mail: ErazerZ@gmail.com
    Web: http://www.gateofgod.com

  Greets:
    neonew, StTwister, Vito, InTeL, all from GateOfGod

    GateOfGod Crew:
      Coders: Vito, StTwister, InTeL, ErazerZ
      Moderators: Ithcy, cybersoul, SpyDir, xtrm
      Gfx: MaliciousScript, NightWolf

  ------------------------------------------

  Example(s):
    1) Patch a local Process Module:
       PatchModule(GetModuleHandle('ntdll.dll'), 'NewModule.dll');
       1.1)
         You can too hide Modules, when you use:
         PatchModule(GeModuleHandle('ntdll.dll'), nil);

    2) Patch a remote Process Module:
       var
         hProcess: THandle;
       begin
         hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessIDofFirefox);
         PatchModuleRemote(hProcess, 'Firefox.exe', 'Test.dll');

    3) Patch a local ImageBaseName (ProcessPath in the Processmanager)
         PatchImagePath('C:\Program Files\Mozilla Firefox\Firefox.exe');

    4) Patch a remote ImageBaseName
       var
       	 hProcess: THandle;
       begin
         hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, dwProcessIDofFirefox);
         PatchImagePathRemote(hProcess, 'C:\Program Files\Mozilla Firefox\NewFirefox.exe');

  ------------------------------------------

}

unit untPEB;

interface

uses Windows, // WinAPI
     untSttUnhooker; // WinAPI UnHooker - by StTwister

type
  PNtAnsiString = ^TNtAnsiString;
  TNtAnsiString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PAnsiChar;
  end;

type
  PNtUnicodeString = ^TNtUnicodeString;
  TNtUnicodeString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;

type
  PClientId = ^TClientId;
  TClientId = record
    UniqueProcess: THandle;
    UniqueThread: THandle;
  end;

type
  PCurDir = ^TCurDir;
  TCurDir = packed record
    DosPath: TNtUnicodeString;
    Handle : THandle;
  end;

type
  PRtlDriveLetterCurDir = ^TRtlDriveLetterCurDir;
  TRtlDriveLetterCurDir = packed record
    Flags    : Word;
    Length   : Word;
    TimeStamp: Cardinal;
    DosPath  : TNtAnsiString;
  end;

type
  PRtlUserProcessParameters = ^TRtlUserProcessParameters;
  TRtlUserProcessParameters = record
    MaximumLength    : Cardinal;
    Length           : Cardinal;
    Flags            : Cardinal;
    DebugFlags       : Cardinal;
    ConsoleHandle    : THandle;
    ConsoleFlags     : Cardinal;
    StandardInput    : THandle;
    StandardOutput   : THandle;
    StandardError    : THandle;
    CurrentDirectory : TCurDir;
    DllPath          : TNtUnicodeString;
    ImagePathName    : TNtUnicodeString;
    CommandLine      : TNtUnicodeString;
    Environment      : Pointer;
    StartingX        : Cardinal;
    StartingY        : Cardinal;
    CountX           : Cardinal;
    CountY           : Cardinal;
    CountCharsX      : Cardinal;
    CountCharsY      : Cardinal;
    FillAttribute    : Cardinal;
    WindowFlags      : Cardinal;
    ShowWindowFlags  : Cardinal;
    WindowTitle      : TNtUnicodeString;
    DesktopInfo      : TNtUnicodeString;
    ShellInfo        : TNtUnicodeString;
    RuntimeData      : TNtUnicodeString;
    CurrentDirectores: Array [0..31] of TRtlDriveLetterCurDir;
  end;

type
  PPebFreeBlock = ^TPebFreeBlock;
  TPebFreeBlock = record
    Next: PPebFreeBlock;
    Size: Cardinal;
  end;

type
  PLdrModule = ^TLdrModule;
  TLdrModule = packed record
    InLoadOrderModuleList          : TListEntry;      // 0h
    InMemoryOrderModuleList        : TListEntry;      // 8h
    InInitializationOrderModuleList: TListEntry;      // 10h
    BaseAddress                    : THandle;         // 18h
    EntryPoint                     : THandle;         // 1Ch
    SizeOfImage                    : Cardinal;        // 20h
    FullDllName                    : TNtUnicodeString;// 24h
                                   // Length (2)         24h
                                   // MaximumLength (2)  26h
                                   // Buffer (4)         28h
    BaseDllName                    : TNtUnicodeString;// 2Ch
    Flags                          : ULONG;           // 34h
    LoadCount                      : SHORT;           // 38h
    TlsIndex                       : SHORT;           // 3Ah
    HashTableEntry                 : TListEntry;      // 3Ch
    TimeDataStamp                  : ULONG;           // 44h
  end;

type
  PPebLdrData = ^TPebLdrData;
  TPebLdrData = packed record
    Length                         : Cardinal;        // 0h
    Initialized                    : LongBool;        // 4h
    SsHandle                       : THandle;         // 8h
    InLoadOrderModuleList          : TListEntry;      // 0Ch
    InMemoryOrderModuleList        : TListEntry;      // 14h
    InInitializationOrderModuleList: TListEntry;      // 1Ch
  end;

type
  PPeb = ^TPeb;
  TPeb = packed record
    InheritedAddressSpace         : Boolean;
    ReadImageFileExecOptions      : Boolean;
    BeingDebugged                 : Boolean;
    SpareBool                     : Boolean;
    Mutant                        : Pointer;
    ImageBaseAddress              : Pointer;
    Ldr                           : PPebLdrData;
    ProcessParameters             : PRtlUserProcessParameters;
    SubSystemData                 : Pointer;
    ProcessHeap                   : Pointer;
    FastPebLock                   : Pointer;
    FastPebLockRoutine            : Pointer;
    FastPebUnlockRoutine          : Pointer;
    EnvironmentUpdateCount        : Cardinal;
    KernelCallbackTable           : Pointer;
    case Integer of
      4: (
        EventLogSection           : Pointer;
        EventLog                  : Pointer);
      5: (
        SystemReserved            : Array [0..1] of Cardinal;
  { end; }
    FreeList                      : PPebFreeBlock;
    TlsExpansionCounter           : Cardinal;
    TlsBitmap                     : Pointer;
    TlsBitmapBits                 : Array [0..1] of Cardinal;
    ReadOnlySharedMemoryBase      : Pointer;
    ReadOnlySharedMemoryHeap      : Pointer;
    ReadOnlyStaticServerData      : ^Pointer;
    AnsiCodePageData              : Pointer;
    OemCodePageData               : Pointer;
    UnicodeCaseTableData          : Pointer;
    NumberOfProcessors            : Cardinal;
    NtGlobalFlag                  : Cardinal;
    Unknown                       : Cardinal;
    CriticalSectionTimeout        : TLargeInteger;
    HeapSegmentReserve            : Cardinal;
    HeapSegmentCommit             : Cardinal;
    HeapDeCommitTotalFreeThreshold: Cardinal;
    HeapDeCommitFreeBlockThreshold: Cardinal;
    NumberOfHeaps                 : Cardinal;
    MaximumNumberOfHeaps          : Cardinal;
    ProcessHeaps                  : ^Pointer;
    GdiSharedHandleTable          : Pointer;
    ProcessStarterHelper          : Pointer;
    GdiDCAttributeList            : Cardinal;
    LoaderLock                    : Pointer;
    OSMajorVersion                : Cardinal;
    OSMinorVersion                : Cardinal;
    OSBuildNumber                 : Word;
    OSCSDVersion                  : Word;
    OSPlatformId                  : Cardinal;
    ImageSubsystem                : Cardinal;
    ImageSubsystemMajorVersion    : Cardinal;
    ImageSubsystemMinorVersion    : Cardinal;
    ImageProcessAffinityMask      : Cardinal;
    GdiHandleBuffer               : Array [0..33] of Cardinal;
    PostProcessInitRoutine        : ^Pointer;
    TlsExpansionBitmap            : Pointer;
    TlsExpansionBitmapBits        : Array [0..31] of Cardinal;
    SessionId                     : Cardinal;
    AppCompatInfo                 : Pointer;
    CSDVersion                    : TNtUnicodeString);
  end;

type
  PNtTib = ^TNtTib;
  TNtTib = record
    ExceptionList       : Pointer;  // ^_EXCEPTION_REGISTRATION_RECORD
    StackBase           : Pointer;
    StackLimit          : Pointer;
    SubSystemTib        : Pointer;
    case Integer of
      0: (FiberData     : Pointer);
      1: (Version       : ULONG;
    ArbitraryUserPointer: Pointer;
    Self                : PNtTib);
  end;

type
  PTeb = ^TTeb;
  TTeb = record
    Tib               : TNtTib;
    Environment       : PWideChar;
    ClientId          : TClientId;
    RpcHandle         : THandle;
    ThreadLocalStorage: Pointer;  // PPointer
    Peb               : PPeb;
    LastErrorValue    : DWORD;
  end;

// Local ..
function GetTeb: PTeb;
function PatchImagePath(szNewImagePath: PWideChar): Boolean;
function PatchModule(hModule: THandle; szNewModule: PWideChar): Boolean;
// Remote ..
function PatchModuleRemote(hProcess: THandle; szModule, szNewModule: PWideChar): Boolean;
function PatchImagePathRemote(hProcess: THandle; szNewImageBaseName: PWideChar): Boolean;

implementation

{
  ########################################
  Local Process Environment Block Patching
  ########################################
}

function GetTeb: PTeb; assembler
asm
  MOV EAX, FS:[18h] // 18h = TEB, 30h = PEB
  MOV Result, EAX
end;

function PatchImagePath(szNewImagePath: PWideChar): Boolean;
var
  Teb: PTeb;
  Peb: PPeb;
begin
  Result := False;
  Teb := GetTeb;
  Peb := Teb.Peb;
  try
    Peb.ProcessParameters.ImagePathName.Length := lstrlenW(szNewImagePath) * 2;
    Peb.ProcessParameters.ImagePathName.Buffer := szNewImagePath;
    Result := True;
  except end;
end;

// if szNewModule = nil then HideModule ..
function PatchModule(hModule: THandle; szNewModule: PWideChar): Boolean;
var
  Teb: PTeb;
  Peb: PPeb;
  usNewModule: TNtUnicodeString;
  CurModule: TPebLdrData;
  i: Integer;
begin
  Teb := GetTeb;
  Peb := Teb.Peb;
  CurModule := TPebLdrData(Peb.Ldr^);
  i := 0;
  Result := False;
  repeat
    // More than 256 Modules, break ..
    if i >= MAX_PATH then
      Break;
    inc(i);
    // Flink = Forward Link
    // Blink = Backward Link
    if hModule = PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.BaseAddress then
    begin
      usNewModule.Buffer := szNewModule;
      usNewModule.Length := lstrlenW(usNewModule.Buffer) * 2;
      usNewModule.MaximumLength := MAX_PATH * 2;
      if (szNewModule = nil) then
      begin
        // hide module
        PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Blink.Flink := PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Flink;
        PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Flink.Blink := PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Blink;
      end else
      begin
        // normal patch module
        PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.FullDllName := usNewModule;
      end;
      Result := True;
      Break;
    end else
    begin
      CurModule.InLoadOrderModuleList.Flink := CurModule.InLoadOrderModuleList.Flink.Flink;
    end;
  until (not True);
end;

{
  #########################################
  Remote Process Environment Block Patching
  #########################################
}

type
  TRemoteInfo = packed record
    rGetModuleHandleW: function(lpModuleName: PWideChar): HMODULE; stdcall;
    szModule: PWideChar;
    usNewModule: TNtUnicodeString; // New Modulename, when nil then HideModule
    hModule: THandle; // Module to patch
    i: Integer;
    Peb: PPeb;
    CurModule: TPebLdrData;
  end;

procedure RemoteThread(RemoteInfo: Pointer); stdcall;
var
  Teb: PTeb;
begin
  with TRemoteInfo(RemoteInfo^)do
  begin
    asm
      MOV EAX, FS:[18h]
      MOV Teb, EAX
    end;
    Peb := Teb.Peb;
    CurModule := TPebLdrData(Peb.Ldr^);
    i := 0;
    hModule :=  rGetModuleHandleW(szModule);
    repeat
      // More than 256 Modules, break ..
      if i >= MAX_PATH then
        Break;
      inc(i);
      // Flink = Forward Link
      // Blink = Backward Link
      if hModule = PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.BaseAddress then
      begin
        if (usNewModule.Buffer = nil) then
        begin
          // hide module
          PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Blink.Flink := PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Flink;
          PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Flink.Blink := PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.InLoadOrderModuleList.Blink;
        end else
        begin
          // normal patch module
          PLdrModule(CurModule.InLoadOrderModuleList.Flink)^.FullDllName := usNewModule;
        end;
        Break;
      end else
      begin
        CurModule.InLoadOrderModuleList.Flink := CurModule.InLoadOrderModuleList.Flink.Flink;
      end;
    until (not True);
  end;
end;
procedure RemoteThreadEnd; begin end;

function PatchModuleRemote(hProcess: THandle; szModule, szNewModule: PWideChar): Boolean;
var
  RemoteInfo: TRemoteInfo;
  pRecord, pCodeAddress, pInjectBuffer: Pointer;
  dwBytesWritten, TID: DWORD;
  usNewModule: TNtUnicodeString;
begin
  Result := False;
  usNewModule.Buffer := szNewModule;
  usNewModule.Length := lstrlenW(szNewModule) * 2;
  usNewModule.MaximumLength := MAX_PATH * 2;
  @RemoteInfo.rGetModuleHandleW := GetProcAddress(GetModuleHandle(kernel32), 'GetModuleHandleW');
  // write the new modulename ..
  pInjectBuffer := pVirtualAllocEx(hProcess, nil, usNewModule.Length, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pInjectBuffer, usNewModule.Buffer, usNewModule.Length, dwBytesWritten);
  RemoteInfo.usNewModule.Buffer := pInjectBuffer;
  RemoteInfo.usNewModule.Length := usNewModule.Length;
  RemoteInfo.usNewModule.MaximumLength := usNewModule.MaximumLength;
  // write old modulename ...
  pInjectBuffer := pVirtualAllocEx(hProcess, nil, lstrlenW(szModule) * 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pInjectBuffer, szModule, lstrlenW(szModule) * 2, dwBytesWritten);
  RemoteInfo.szModule := pInjectBuffer;
  // write param (the infos from record)
  pRecord := pVirtualAllocEx(hProcess, nil, sizeof(TRemoteInfo), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pRecord, @RemoteInfo, sizeof(TRemoteInfo), dwBytesWritten);
  // write code
  pCodeAddress := pVirtualAllocEx(hProcess, nil, DWORD(@RemoteThreadEnd) - DWORD(@RemoteThread), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pCodeAddress, @RemoteThread, DWORD(@RemoteThreadEnd) - DWORD(@RemoteThread), dwBytesWritten);
  // create new thread
  if pCreateRemoteThread(hProcess, nil, 0, pCodeAddress, pRecord, 0, TID) > 0 then
    Result := True;
end;

type
  TRemoteImagePathInfo = packed record
    szNewImageName: PWideChar; // New Imagebase Filename
    NewLength: Word;
    //BeingDebugged: Boolean;
    //NtGlobalFlag: Cardinal;
  end;

procedure RemoteImagePathThread(RemoteInfo: Pointer); stdcall;
var
  Peb: PPeb;
begin
  with TRemoteImagePathInfo(RemoteInfo^)do
  begin
    asm
      MOV EAX, FS:[30h]
      MOV Peb, EAX
    end;
    Peb.ProcessParameters.ImagePathName.Length := NewLength;
    Peb.ProcessParameters.ImagePathName.Buffer := szNewImageName;
  end;
end;
procedure RemoteImagePathThreadEnd;
begin

end;

function PatchImagePathRemote(hProcess: THandle; szNewImageBaseName: PWideChar): Boolean;
var
  RemoteInfo: TRemoteImagePathInfo;
  pRecord, pCodeAddress, pInjectBuffer: Pointer;
  dwBytesWritten, TID: DWORD;
begin
  Result := False;
  RemoteInfo.NewLength := lstrlenW(szNewImageBaseName) * 2;
  // write the new modulename ..
  pInjectBuffer := pVirtualAllocEx(hProcess, nil, RemoteInfo.NewLength, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pInjectBuffer, szNewImageBaseName, RemoteInfo.NewLength, dwBytesWritten);
  RemoteInfo.szNewImageName := pInjectBuffer;
  // write param (the infos from record)
  pRecord := pVirtualAllocEx(hProcess, nil, sizeof(TRemoteImagePathInfo), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pRecord, @RemoteInfo, sizeof(TRemoteImagePathInfo), dwBytesWritten);
  // write code
  pCodeAddress := pVirtualAllocEx(hProcess, nil, DWORD(@RemoteImagePathThreadEnd) - DWORD(@RemoteImagePathThread), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  pWriteProcessMemory(hProcess, pCodeAddress, @RemoteImagePathThread, DWORD(@RemoteImagePathThreadEnd) - DWORD(@RemoteImagePathThread), dwBytesWritten);
  // create new thread
  if pCreateRemoteThread(hProcess, nil, 0, pCodeAddress, pRecord, 0, TID) > 0 then
    Result := True;
end;


end.
