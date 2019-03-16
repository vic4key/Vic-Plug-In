unit uBP;

interface

uses Windows, SysUtils, Plugin, uFcData, mrVic;

type
  TBPFileHeader = packed record
    Signature: DWORD;
    Length: DWORD;
    MainModule: array[0..SHORTNAME]of WideChar; 
  end;

  TINT3BreakpointSave = packed record
    Offset: DWORD;
    Info: TBPoint;
    Module: array[0..SHORTNAME] of WideChar;
  end;

  THardBreakpointSave = packed record
    Offset: DWORD;
    Info: TBHard;
    Module: array[0..SHORTNAME] of WideChar;
  end;

  TMemBreakpointSave = packed record
    Offset: DWORD;
    Info: TBMem;
    Module: array[0..SHORTNAME] of WideChar;
  end;

const
  BP_INT3_SIGN = $33544E49; // 'INT3'
  BP_HWBP_SIGN = $50425748; // 'HWBP'
  BP_MBP_SIGN  = $0050424D; // 'MBP'

  BP_INT3 = 1;
  BP_HWBP = 2;
  BP_MBP  = 3;

Procedure DeleteBreakpoint(bpType: DWORD); stdcall;
Procedure ImportBreakpoint(bpType: DWORD); stdcall;
Procedure ExportBreakpoint(bpType: DWORD); stdcall;

implementation

Function OffsetToVA(Offset: DWORD; Module: PWideChar): DWORD; stdcall;
var
  i: Integer;
  pmod: PModule;
  psect: PSectHdr;
begin
  Result:= 0;
  
  pmod:= FindModuleByName(Module);
  if (pmod = NIL) then Exit;

  if (pmod^.nsect = 0) then Exit;

  psect:= pmod^.sect;
  for i:= 0 to pmod^.nsect - 1 do
  begin
    if (Offset >= psect.fileoffset) then
    begin
      Result:= (Offset - psect.fileoffset) + psect.base;
    end;
    Inc(psect);
  end;
end;

Procedure DeleteBreakpoint(bpType: DWORD); stdcall;
var
  i: Integer;
  sbp: PBPoint;
  hbp: PBHard;
  mbp: PBMem;
begin
  case bpType of
    BP_INT3:
    begin
      try
        ODData:= GetODData;

        if (MessageBoxW(
          hwODbg,
          StringToOleStr(fm('Have %d INT3 breakpoint(s). Are you sure to delete all?',[ODData.bpoint.sorted.n])),
          PLUGIN_NAME,
          MB_YESNO or MB_ICONQUESTION) = IDNO) then Exit;

        for i:= ODData.bpoint.sorted.n - 1 downto 0 do
        begin
          sbp:= PBPoint(GetSortedByIndex(@ODData.bpoint.sorted,i));
          RemoveInt3Breakpoint(sbp^.addr,sbp^.types);
        end;
      except
        Exit;
      end;
    end;
    BP_HWBP:
    begin
      try
        ODData:= GetODData;

        if (MessageBoxW(
          hwODbg,
          StringToOleStr(fm('Have %d Hardware breakpoint(s). Are you sure to delete all?',[ODData.bphard.sorted.n])),
          PLUGIN_NAME,
          MB_YESNO or MB_ICONQUESTION) = IDNO) then Exit;

        for i:= ODData.bphard.sorted.n - 1 downto 0 do
        begin
          hbp:= PBHard(GetSortedByIndex(@ODData.bphard.sorted,i));
          RemoveHardBreakpoint(hbp^.index);
        end;
      except
        Exit;
      end;
    end;
    BP_MBP:
    begin
      try
        ODData:= GetODData;

        if (MessageBoxW(
          hwODbg,
          StringToOleStr(fm('Have %d Memory breakpoint(s). Are you sure to delete all?',[ODData.bpmem.sorted.n])),
          PLUGIN_NAME,
          MB_YESNO or MB_ICONQUESTION) = IDNO) then Exit;

        for i:= ODData.bpmem.sorted.n - 1 downto 0 do
        begin
          mbp:= PBMem(GetSortedByIndex(@ODData.bpmem.sorted,i));
          RemoveMemBreakpoint(mbp^.addr);
        end;
      except
        Exit;
      end;
    end;
  end;
end;

Procedure ImportBreakpoint(bpType: DWORD); stdcall;
var
  pwFilePath: array[0..MAX_PATH] of WideChar;
  szFilePath: String;

  address: DWORD;
  i, hFile, iImportedCount: Integer;
  fileHeader: TBPFileHeader;

  Module: PModule;

  Int3Info: TINT3BreakpointSave;
  HwbpInfo: THardBreakpointSave;
  MbpInfo: TMemBreakpointSave;
begin
  ZeroMemory(@pwFilePath,sizeof(pwFilePath));
  iImportedCount:= 0;
  case bpType of
    BP_INT3:
    begin
      //Module:= FindMainModule;
      //MessageBoxW(phwODbg^,StringToOleStr(ExtractFilePath(WideCharToString(Module^.path))),PLUGIN_NAME,MB_OK);
      BrowseFileName('Import INT3 breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_FILE or BRO_SINGLE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));
      if (szFilePath = '') then Exit;

      hFile:= FileOpen(szFilePath,fmOpenRead);
      if (hFile = -1) then
      begin
        StatusFlash('Could not open your INT3 breakpoints file');
        Exit;
      end;

      ZeroMemory(@fileHeader,sizeof(fileHeader));

      FileRead(hFile,fileHeader,sizeof(fileHeader));
      case fileHeader.Signature of
        BP_INT3_SIGN:
        begin
          // File is available
        end;
        BP_HWBP_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is Hardware breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
        BP_MBP_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is Memory breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end
        else
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. Didn''t support this file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
      end;

      Module:= FindMainModule;

      if (lstrcmpW(fileHeader.MainModule,Module.modname) <> 0) then
      begin
        if (MessageBoxA(hwODbg,
          PAnsiChar(fm('Warning: ''%s'' breakpoint file isn''t of ''%s''.'#13#10'If you continue, it can be misstake or fail.'#13#10'Do you want to continue to import?',
            [ExtractFileName(szFilePath),
            WideCharToString(Module^.modname)])),
          PAnsiChar(WideCharToString(PLUGIN_NAME)),
          MB_ICONWARNING or MB_OKCANCEL) = IDCANCEL) then
        begin
          FileClose(hFile);
          Exit;
        end;
      end;

      for i:= 0 to fileHeader.Length - 1 do
      begin
        ZeroMemory(@Int3Info,sizeof(Int3Info));
        FileRead(hFile,Int3Info,sizeof(TINT3BreakpointSave));

        address:= OffsetToVA(Int3Info.Offset,Int3Info.Module);
        if (address = 0) then
        begin
          address:= OffsetToVA(Int3Info.Offset,Module^.modname);
          if (address = 0) then Continue;
        end;

        SetInt3Breakpoint(
          address,
          Int3Info.Info.types,
          Int3Info.Info.fnindex,
          Int3Info.Info.limit,
          Int3Info.Info.count,
          NIL,NIL,NIL);

        Inc(iImportedCount);
      end;

      AddToLog(0,DRAW_HILITE,'%s: Imported %d/%d INT3 breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);
      StatusInfo('%s: Imported %d/%d INT3 breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);

      FileClose(hFile);
    end;
    BP_HWBP:
    begin
      BrowseFileName('Import Hardware breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_FILE or BRO_SINGLE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));
      if (szFilePath = '') then Exit;

      hFile:= FileOpen(szFilePath,fmOpenRead);
      if (hFile = -1) then
      begin
        StatusFlash('Could not open your Hardware breakpoints file');
        Exit;
      end;

      ZeroMemory(@fileHeader,sizeof(fileHeader));

      FileRead(hFile,fileHeader,sizeof(fileHeader));
      case fileHeader.Signature of
        BP_INT3_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is INT3 breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
        BP_HWBP_SIGN:
        begin
          // File is available
        end;
        BP_MBP_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is Hardware breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end
        else
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. Didn''t support this file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
      end;

      Module:= FindMainModule;

      if (lstrcmpW(fileHeader.MainModule,Module.modname) <> 0) then
      begin
        if (MessageBoxA(hwODbg,
          PAnsiChar(fm('Warning: ''%s'' breakpoint file isn''t of ''%s''.'#13#10'If you continue, it can be misstake or fail.'#13#10'Do you want to continue to import?',
            [ExtractFileName(szFilePath),
            WideCharToString(Module^.modname)])),
          PAnsiChar(WideCharToString(PLUGIN_NAME)),
          MB_ICONWARNING or MB_OKCANCEL) = IDCANCEL) then
        begin
          FileClose(hFile);
          Exit;
        end;
      end;

      for i:= 0 to fileHeader.Length - 1 do
      begin
        ZeroMemory(@HwbpInfo,sizeof(HwbpInfo));
        FileRead(hFile,HwbpInfo,sizeof(THardBreakpointSave));

        address:= OffsetToVA(HwbpInfo.Offset,HwbpInfo.Module);
        if (address = 0) then
        begin
          address:= OffsetToVA(HwbpInfo.Offset,Module^.modname);
          if (address = 0) then Continue;
        end;

        SetHardBreakpoint(
          HwbpInfo.Info.index,
          HwbpInfo.Info.size,
          HwbpInfo.Info.types,
          HwbpInfo.Info.fnindex,
          address,
          HwbpInfo.Info.limit,
          HwbpInfo.Info.count,
          NIL,NIL,NIL);

        Inc(iImportedCount);
      end;

      AddToLog(0,DRAW_HILITE,'%s: Imported %d/%d Hardware breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);
      StatusInfo('%s: Imported %d/%d Hardware breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);

      FileClose(hFile);
    end;
    BP_MBP:
    begin
      BrowseFileName('Import Memory breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_FILE or BRO_SINGLE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));
      if (szFilePath = '') then Exit;

      hFile:= FileOpen(szFilePath,fmOpenRead);
      if (hFile = -1) then
      begin
        StatusFlash('Could not open your Memory breakpoints file');
        Exit;
      end;

      ZeroMemory(@fileHeader,sizeof(fileHeader));

      FileRead(hFile,fileHeader,sizeof(fileHeader));
      case fileHeader.Signature of
        BP_INT3_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is INT3 breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
        BP_HWBP_SIGN:
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. This is Memory breakpoint file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
        BP_MBP_SIGN:
        begin
          // File is available
        end
        else
        begin
          MessageBoxW(
            hwODbg,
            'Wrong file type. Didn''t support this file type',
            PLUGIN_NAME,
            MB_ICONERROR);
          FileClose(hFile);
          Exit;
        end;
      end;

      Module:= FindMainModule;

      if (lstrcmpW(fileHeader.MainModule,Module.modname) <> 0) then
      begin
        if (MessageBoxA(hwODbg,
          PAnsiChar(fm('Warning: ''%s'' breakpoint file isn''t of ''%s''.'#13#10'If you continue, it can be misstake or fail.'#13#10'Do you want to continue to import?',
            [ExtractFileName(szFilePath),
            WideCharToString(Module^.modname)])),
          PAnsiChar(WideCharToString(PLUGIN_NAME)),
          MB_ICONWARNING or MB_OKCANCEL) = IDCANCEL) then
        begin
          FileClose(hFile);
          Exit;
        end;
      end;

      for i:= 0 to fileHeader.Length - 1 do
      begin
        ZeroMemory(@HwbpInfo,sizeof(MbpInfo));
        FileRead(hFile,MbpInfo,sizeof(TMemBreakpointSave));

        address:= OffsetToVA(MbpInfo.Offset,MbpInfo.Module);
        if (address = 0) then
        begin
          address:= OffsetToVA(MbpInfo.Offset,Module^.modname);
          if (address = 0) then Continue;
        end;

        SetMemBreakpoint(
          address,
          MbpInfo.Info.size,
          MbpInfo.Info.types,
          MbpInfo.Info.limit,
          MbpInfo.Info.count,
          NIL,NIL,NIL);

        Inc(iImportedCount);
      end;

      AddToLog(0,DRAW_HILITE,'%s: Imported %d/%d Memory breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);
      StatusInfo('%s: Imported %d/%d Memory breakpoint(s)',PLUGIN_NAME,iImportedCount,fileHeader.Length);

      FileClose(hFile);
    end;  
  end;
end;

Procedure ExportBreakpoint(bpType: DWORD); stdcall;
var
  Int3Info: TINT3BreakpointSave;
  HwbpInfo: THardBreakpointSave;
  MbpInfo: TMemBreakpointSave;

  Sbp: PBPoint;
  Hbp: PBHard;
  Mbp: PBMem;

  Module: PModule;

  i, hFile: Integer;
  pwFilePath: array[0..MAX_PATH] of WideChar;
  szFilePath: String;

  fileHeader: TBPFileHeader;
begin
  ZeroMemory(@fileHeader,sizeof(fileHeader));
  ZeroMemory(@pwFilePath,sizeof(pwFilePath));
  szFilePath:= '';

  case bpType of
    BP_INT3:
    begin
      BrowseFileName('Export INT3 breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_SAVE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));

      if (szFilePath = '') then Exit;

      Insert('.INT3',szFilePath,Length(szFilePath) - 2);

      case ConfirmOverWrite(StringToOleStr(szFilePath)) of
        1, 2: hFile:= FileCreate(szFilePath);
        else Exit;
      end;

      if (hFile = -1) then
      begin
        StatusFlash('Could not export INT3 breakpoints. Try again.');
        Exit;
      end;

      Module:= FindMainModule;

      ODData:= GetODData;

      fileHeader.Signature:= BP_INT3_SIGN;
      fileHeader.Length:= ODData.bpoint.sorted.n;
      CopyMemory(@fileHeader.MainModule,@Module^.modname,sizeof(fileHeader.MainModule));

      FileWrite(hFile,fileHeader,sizeof(fileHeader));

      for i:= 0 to ODData.bpoint.sorted.n - 1 do
      begin
        Sbp:= PBPoint(GetSortedByIndex(@ODData.bpoint.sorted,i));
        Module:= FindModule(Sbp^.addr);

        //VICMsg('%d %0.8X <%s>',[Module^.nsect,Module^.base,WideCharToString(PWideChar(@Module^.modname))]);

        ZeroMemory(@Int3Info,sizeof(Int3Info));

        Int3Info.Offset:= FindFileOffset(Module,Sbp^.addr);
        CopyMemory(@Int3Info.Info,Sbp,sizeof(TBPoint));
        CopyMemory(@Int3Info.Module,@Module.modname,SHORTNAME*sizeof(WideChar));

        FileWrite(hFile,Int3Info,sizeof(Int3Info));
      end;

      AddToLog(0,1,'%s: Exported %d INT3 breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bpoint.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));
      StatusInfo('%s: Exported %d INT3 breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bpoint.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));

      FileClose(hFile);
    end;
    BP_HWBP:
    begin
      BrowseFileName('Export Hardware breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_SAVE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));

      if (szFilePath = '') then Exit;

      Insert('.HWBP',szFilePath,Length(szFilePath) - 2);

      case ConfirmOverWrite(StringToOleStr(szFilePath)) of
        1, 2: hFile:= FileCreate(szFilePath);
        else Exit;
      end;

      if (hFile = -1) then
      begin
        StatusFlash('Could not export Hardware breakpoints. Try again.');
        Exit;
      end;

      Module:= FindMainModule;

      ODData:= GetODData;

      fileHeader.Signature:= BP_HWBP_SIGN;
      fileHeader.Length:= ODData.bphard.sorted.n;
      CopyMemory(@fileHeader.MainModule,@Module^.modname,sizeof(fileHeader.MainModule));

      FileWrite(hFile,fileHeader,sizeof(fileHeader));

      for i:= 0 to ODData.bphard.sorted.n - 1 do
      begin
        Hbp:= PBHard(GetSortedByIndex(@ODData.bphard.sorted,i));
        Module:= FindModule(Hbp^.addr);

        ZeroMemory(@HwbpInfo,sizeof(HwbpInfo));

        HwbpInfo.Offset:= FindFileOffset(Module,Hbp^.addr);
        CopyMemory(@HwbpInfo.Info,Hbp,sizeof(TBHard));
        CopyMemory(@HwbpInfo.Module,@Module.modname,SHORTNAME*sizeof(WideChar));

        FileWrite(hFile,HwbpInfo,sizeof(HwbpInfo));
      end;

      AddToLog(0,1,'%s: Exported %d Hardware breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bphard.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));
      StatusInfo('%s: Exported %d Hardware breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bphard.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));

      FileClose(hFile);
    end;
    BP_MBP:
    begin
      BrowseFileName('Export Memory breakpoints',pwFilePath,NIL,NIL,'*.bp',hwODbg,BRO_SAVE);
      szFilePath:= WideCharToString(PWideChar(@pwFilePath));

      if (szFilePath = '') then Exit;

      Insert('.MBP',szFilePath,Length(szFilePath) - 2);

      case ConfirmOverWrite(StringToOleStr(szFilePath)) of
        1, 2: hFile:= FileCreate(szFilePath);
        else Exit;
      end;

      if (hFile = -1) then
      begin
        StatusFlash('Could not export Memory breakpoints. Try again.');
        Exit;
      end;

      Module:= FindMainModule;

      ODData:= GetODData;

      fileHeader.Signature:= BP_MBP_SIGN;
      fileHeader.Length:= ODData.bpmem.sorted.n;
      CopyMemory(@fileHeader.MainModule,@Module^.modname,sizeof(fileHeader.MainModule));

      FileWrite(hFile,fileHeader,sizeof(fileHeader));

      for i:= 0 to ODData.bpmem.sorted.n - 1 do
      begin
        Mbp:= PBMem(GetSortedByIndex(@ODData.bpmem.sorted,i));
        Module:= FindModule(Mbp^.addr);

        ZeroMemory(@MbpInfo,sizeof(MbpInfo));

        MbpInfo.Offset:= FindFileOffset(Module,Mbp^.addr);
        CopyMemory(@MbpInfo.Info,Mbp,sizeof(TBMem));
        CopyMemory(@MbpInfo.Module,@Module.modname,SHORTNAME*sizeof(WideChar));

        FileWrite(hFile,MbpInfo,sizeof(MbpInfo));
      end;

      AddToLog(0,1,'%s: Exported %d Memory breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bpmem.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));
      StatusInfo('%s: Exported %d Memory breakpoint(s) to file ''%s''',PLUGIN_NAME,ODData.bpmem.sorted.n,StringToOleStr(ExtractFileName(szFilePath)));

      FileClose(hFile);
    end;
  end;
end;

end.
