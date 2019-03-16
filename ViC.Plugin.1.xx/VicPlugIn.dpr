(*******************************************)
(*	Name: ViC Plug-In 1.xx                 *)
(*	Type: DLL | Dynamic Link Library       *)
(*	Author: Vic aka vic4key                *)
(*	Website: cin1team.biz                  *)
(*	Mail: vic4key@gmail.com                *)
(*******************************************)

library VicPlugIn;

{%File 'VicPlugIn.bdsproj'}

uses
  Windows,
  SysUtils,
  Classes,
  ShellAPI,
  Messages,
  Dialogs,
  mrVic,
  Plugin in 'Plugin.pas',
  dtMain in '..\GUI\DATA Converter\dtMain.pas' {DATAConverter},
  u_c_basic_object in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\classes\u_c_basic_object.pas',
  u_c_display in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\classes\u_c_display.pas',
  u_c_log in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\classes\u_c_log.pas',
  u_characters in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_characters.pas',
  u_dir in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_dir.pas',
  u_display_hex_2 in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_display_hex_2.pas',
  u_file in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_file.pas',
  u_strings in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_strings.pas',
  u_types_constants in '..\GUI\DLL_Process_Viewer\helpers\colibri_helpers\units\u_types_constants.pas',
  u_c_process_list in '..\GUI\DLL_Process_Viewer\us\colibri_utilities\dll_process_viewer\p_dll_process_viewer\u_c_process_list.pas',
  u_dll_process_viewer in '..\GUI\DLL_Process_Viewer\us\colibri_utilities\dll_process_viewer\p_dll_process_viewer\u_dll_process_viewer.pas' {DLLPV},
  FLCMain in '..\GUI\FLC\FLCMain.pas' {frmFLC},
  LUEMain in '..\GUI\LUE\LUEMain.pas' {frmLUE},
  pevChrts in '..\GUI\PE Viewer\pevChrts.pas' {Crtics},
  pevie in '..\GUI\PE Viewer\pevie.pas' {IETable},
  pevMain in '..\GUI\PE Viewer\pevMain.pas' {PE_Viewer},
  untMain in '..\GUI\PEBPatcher\untMain.pas' {frmMain},
  untPatchImagePath in '..\GUI\PEBPatcher\untPatchImagePath.pas' {frmImagePath},
  untPatchModule in '..\GUI\PEBPatcher\untPatchModule.pas' {frmModulePath},
  untPeb in '..\GUI\PEBPatcher\untPeb.pas',
  untSttUnhooker in '..\GUI\PEBPatcher\untSttUnhooker.pas',
  uTbMain in '..\GUI\Toolbar\uTbMain.pas' {frmTB},
  frmTran in '..\GUI\TranOD\frmTran.pas' {frmTranOD},
  uFcData in '..\Modules\uFcData.pas';

{$ENDREGION}

Procedure VIC_PluginAction(iOrigin, iAction: Integer; pItem: Pointer); cdecl;
var
  Buffer: array[0..MAXBYTE] of Char;
  dwVA, dwRVA, dwOffset, dwStartAddr, dwEndAddr, dwThreadId: DWORD;
begin
  case iAction of
    1:
    begin                      
      try
        fTbShow:= 3 - fTbShow;
        if (fTbShow = 2) then VIC_ShowToolbar;
        SaveIntCfg(hPlg,TbarODcfg,Integer(fTbShow));
      except
        Exit;
      end;
    end;
    2:
    begin
      bMaxOD:= not bMaxOD;
      MaximizeOD(phwODbg^);
      SaveIntCfg(hPlg,MaxMainODcfg,Integer(bMaxOD));
    end;
    3:
    begin
      bMaxMDI:= not bMaxMDI;
      MaximizeMDI(HWND(phwClient^));
      SaveIntCfg(hPlg,MaxMDIODcfg,Integer(bMaxMDI));
    end;
    4:
    begin
      try
        frmTranOD:= TfrmTranOD.Create(frmTranOD);
        frmTranOD.Show;
      except
        Exit;
      end;
    end;
    5:
    begin
      try
        if (MessageDlg(szQesDelUdd,mtConfirmation,mbOKCancel,0) = 1) then
        begin
          bDelUdd:= True;
          if (ViC_DelUddData = True) then
            MessageBoxA(phwODbg^,PAnsiChar(szDelDone),PAnsiChar(PLUGIN_NAME),MB_ICONINFORMATION)
          else
            MessageBoxA(phwODbg^,PAnsiChar(szDelError),PAnsiChar(PLUGIN_NAME),MB_ICONERROR)
        end;
      except
        Exit;
      end;
    end;
    6:
    begin
      try
        dwStartAddr:= PDWORD(Pointer(DWORD(pItem) + $385))^; // 385h = Offset of start selected address.
        dwEndAddr:= PDWORD(Pointer(DWORD(pItem) + $389))^;   // 389h = Offset of end selected address.

        szBuffer:= GetHexDumpString(dwStartAddr,dwEndAddr);
        Delete(szBuffer,Length(szBuffer),1);

        DATAConverter:= TDATAConverter.Create(DATAConverter);
        DATAConverter.Show;
      except
        Exit;
      end;
    end;
    7:
    begin
      try
        CreateDir(GetOllyDbgDir + 'log');
        DLLPV:= TDLLPV.Create(DLLPV);
        DLLPV.Show;
      except
        Exit;
      end;
    end;
    8:
    begin
      try
        frmFLC:= TfrmFLC.Create(frmFLC);
        frmFLC.Show;
      except
        Exit;
      end;
    end;
    9:
    begin
      try
        PE_Viewer:= TPE_Viewer.Create(PE_Viewer);
        PE_Viewer.Show;
      except
        Exit;
      end;
    end;
    10:
    begin
      try
        frmMain:= TfrmMain.Create(frmMain);
        frmMain.Show;
      except
        Exit;
      end;
    end;
    11:
    begin
      try
        frmLUE:= TfrmLUE.Create(frmLUE);
        frmLUE.Show;
      except
        Exit;
      end;
    end;
    12:
    begin
      DelphiPointEvents;
    end;
    // Map Importer
    13, 14:
    begin
      case iAction of
        13:
        begin
          fImportType:= True;
          hImportThread:= CreateThread(NIL,0,@ImportingThread,NIL,0,dwThreadId);
        end;
        14:
        begin
          fImportType:= False;
          hImportThread:= CreateThread(NIL,0,@ImportingThread,NIL,0,dwThreadId);
        end;
      end;
    end;
    // Address copier
    15, 16, 17:
    begin
      {$REGION File Location Converter}
      case iOrigin of
        PM_DISASM, PM_CPUDUMP, PM_CPUSTACK:
        begin
          dwSelectedAddr:= PDWORD(Pointer(DWORD(pItem) + $385))^; // 385h/389h = The offset start/end of the selection block.
          FLCMain.LoadPE(fpath);
          FLCMain.Converter(dwSelectedAddr,V,FLCMain.ISH,dwOffset,dwRVA,dwVA);
          //VICMsg('Selected = %.8X, VA = %.8X, RVA = %.8X, Offset = %.8X',[dwSelectedAddr,dwVA,dwRVA,dwOffset]);
          case iAction of
            15:
            begin
              if (SetTextToClipboard(fm('%.8X',[dwVA])) = True) then
                Flash(StrToPac(fm('Copied VA = %.8X to clipboard',[dwVA])))
              else
                Flash(StrToPac('Failure to copy the VA to clipboard'));
            end;
            16:
            begin
              if (dwRVA <> 0) then
              begin
                if SetTextToClipboard(fm('%.8X',[dwRVA])) then
                  Flash(StrToPac(fm('Copied RVA = %.8X to clipboard',[dwRVA])))
                else
                  Flash(StrToPac('Failure to copy the RVA to clipboard'));
              end else Flash(StrToPac('The address out of the section header'));
            end;
            17:
            begin
              if (dwOffset <> 0) then
              begin
                if SetTextToClipboard(fm('%.8X',[dwOffset])) then
                  Flash(StrToPac(fm('Copied Offset = %.8X to clipboard',[dwOffset])))
                else
                  Flash(StrToPac('Failure to copy the Offset to clipboard'));
              end else Flash(StrToPac('The address out of the section header'));
            end;
          end;
        end else VICBox(phwODbg^,'Only activate on CPU Window');
      end;
      {$ENDREGION}
    end;
    18:
    begin
      try
        ShellExecuteA(phwODbg^,PAnsiChar('open'),PAnsiChar(WEBSITE),NIL,NIL,SW_SHOWNORMAL);
        ShellExecuteA(phwODbg^,PAnsiChar('open'),PAnsiChar(BLOG),NIL,NIL,SW_SHOWNORMAL);
      except
        Exit;
      end;
    end;
    19:
    begin
      Sprintf(
      Buffer,
      '%s Version %s for OllyDbg %s' + DCRLF +
      'Update: %s' + DCRLF +
      'Author: %s' + DCRLF +
      'Team: %s' + DCRLF +
      'Contact: %s' + DCRLF +
      'Homepage: %s' + DCRLF +
      'Blog: %s',
      PLUGIN_NAME,VERSION,ODVERSION,DATEUPDATE,AUTHOR,TEAM,MAIL,WEBSITE,BLOG);
      MessageBoxA(phwODbg^,Buffer,PLUGIN_NAME,MB_ICONINFORMATION);
    end;
  end;
end;

Function VIC_PluginData(paShortName: PAnsiChar): Integer; cdecl;
begin
  StrLCopy(paShortName,StrToPac(PLUGIN_NAME),32);
  Result:= PLUGIN_VERSION;
end;

Function VIC_PluginInit(iODVersion: Integer; hWndOD: HWND; pdwFeatures: PDWORD): Integer; cdecl;
begin
  Result:= 0;
  if (iODVersion < PLUGIN_VERSION) then
  begin
    AddToLog(0,1,'%s: Error: This plugin not compatiable for this version',PLUGIN_NAME);
    Result:= -1;
    Exit;
  end;

  fdir:= GetCurrentDir + '\';

  phwODbg:= @hwODbg;
  phwODbg^:= hWndOD;

  phwClient:= @hwClient;
  phwClient^:= HWND(PluginGetValue(VAL_HWCLIENT));

  hODbgMdl:= GetModuleHandleA(NIL);

  hPlg:= GetModuleHandleA(StrToPac(szPlginName));

  bMaxOD:= Boolean(LoadIntCfg(hPlg,MaxMainODcfg,0));
  MaximizeOD(phwODbg^);

  bMaxMDI:= Boolean(LoadIntCfg(hPlg,MaxMDIODcfg,0));
  MaximizeMDI(phwClient^);

  iAlpha:= LoadIntCfg(hPlg,TranODcfg,0);
  if (iAlpha = 0) then iAlpha:= 255;
  ViC_Transparent(phwODbg^,iAlpha);

  fTbShow:= T2(LoadIntCfg(hPlg,TbarODcfg,0));
  if (fTbShow = 0) then fTbShow:= 2;
  if (fTbShow = 2) then VIC_ShowToolbar;

  AddToLog(0,2,'');
  AddToLog(0,0,'%s - Version %s for OllyDbg Version %s',PLUGIN_NAME,VERSION,ODVERSION);
  AddToLog(0,2,' - Update: %s',DATEUPDATE);
  AddToLog(0,2,' - Author: %s | %s <%s>',AUTHOR,TEAM,MAIL);
  AddToLog(0,2,' - Homepage: %s',WEBSITE);
  AddToLog(0,2,' - Blog: %s',BLOG);
  AddToLog(0,2,'');
end;

Function VIC_PluginShortcut(iOrigin, iCtrl, iAlt, iShift, iKey: Integer; item: Pointer): Integer; cdecl;
begin
  Result:= 0;
  if (iOrigin = PM_MAIN)
  and (iCtrl  = 0)
  and (iAlt   = 1) // ALT
  and (iShift = 0)
  and (iKey   = $47) then // KEY = g or G
  begin
    try
      frmFLC:= TfrmFLC.Create(frmFLC);
      frmFLC.Show;
    except
      Exit;
    end;
    Result:= 1;
  end;
end;

Function VIC_PluginMenu(iOrigin: Integer; paData: PAnsiChar; pItem: Pointer): Integer; cdecl;
begin                                                                  
  Result:= 1;
  case iOrigin of
    PM_MAIN: StrCopy(paData,MAIN_MENU);
    PM_DUMP: StrCopy(paData,SUB_MENU);
    PM_MODULES: StrCopy(paData,SUB_MENU);
    PM_MEMORY: StrCopy(paData,SUB_MENU);
    PM_THREADS: StrCopy(paData,SUB_MENU);
    PM_BREAKPOINTS: StrCopy(paData,SUB_MENU);
    PM_REFERENCES: StrCopy(paData,SUB_MENU);
    PM_RTRACE: StrCopy(paData,SUB_MENU);
    PM_WATCHES: StrCopy(paData,SUB_MENU);
    PM_WINDOWS: StrCopy(paData,SUB_MENU);
    PM_DISASM: StrCopy(paData,SUB_MENU);
    PM_CPUDUMP: StrCopy(paData,SUB_MENU);
    PM_CPUSTACK: StrCopy(paData,SUB_MENU);
    PM_CPUREGS: StrCopy(paData,SUB_MENU);
  else Result:= 0;
  end;
end;

Function VIC_PluginClose: Integer; cdecl;
begin
  Result:= 0;

  if (fTbShow <> 1) then SendMessageA(frmTB.Handle,WM_CLOSE,0,0);

  SaveIntCfg(hPlg,MaxMainODcfg,Integer(bMaxOD));
  SaveIntCfg(hPlg,MaxMDIODcfg,Integer(bMaxMDI));
  SaveIntCfg(hPlg,TranODcfg,Integer(iAlpha));
  SaveIntCfg(hPlg,TbarODcfg,Integer(fTbShow));
end;

Function VIC_PluginPausedEx(iReasonEx, iDummy: Integer; pReg: p_reg; pDe: PDebugEvent): Integer; cdecl;
var
  mem: TMem;
  iLen: Integer;
  szName: String;
  paEvent: PAnsiChar;
  dwPid: DWORD;
begin
  Result:= 0;
  
  if (GetStatus = STAT_STOPPED) then
  begin
    GetFileInfo;
    dwPid:= DWORD(PluginGetValue(VAL_PROCESSID));
    dwImageBase:= GetModuleBaseAddress(dwPid,fname);
  end;

  if (GetStatus = STAT_FINISHED) then bFoundPointE:= False;

  if bFoundPointE and (pDe^.Exception.ExceptionRecord.ExceptionCode = STATUS_BREAKPOINT) then
  begin
      Setbreakpoint(pReg^.r[0],TY_DISABLED,#0);

      ZeroMemory(@mem,sizeof(mem));
      ReadMemory(@mem.size,pReg^.r[2],1,MM_DELANAL);
      ReadMemory(@mem.buffer,pReg^.r[2] + 1,mem.size,MM_DELANAL);

      szName:= fname;
      iLen:= Length(szName);
      Delete(szName,iLen - 3,4);

      paEvent:= StrToPac(szName + '::' + PacToStr(PAnsiChar(@mem.buffer)));

      InsertName(pReg^.r[0],NM_COMMENT,paEvent);
      InsertName(pReg^.r[0],NM_LABEL,paEvent);
  end;
end;

Procedure VIC_PluginReset; cdecl;
begin
  bDelUdd:= False;
end;

Procedure VIC_PluginDestroy; cdecl;
begin
  if (bDelUdd = True) then
  begin
    ViC_DelUddData;
    bDelUdd:= False;
  end;
end;

exports
  VIC_PluginData name '_ODBG_Plugindata',
  VIC_PluginInit name '_ODBG_Plugininit',
  VIC_PluginMenu name '_ODBG_Pluginmenu',
  VIC_PluginReset name '_ODBG_Pluginreset',
  VIC_PluginClose name '_ODBG_Pluginclose',
  VIC_PluginAction name '_ODBG_Pluginaction',
  VIC_PluginDestroy name '_ODBG_Plugindestroy',
  VIC_PluginShortcut name '_ODBG_Pluginshortcut',
  VIC_PluginPausedEx name '_ODBG_Pausedex';
end.