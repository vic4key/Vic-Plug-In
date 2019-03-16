(*******************************************)
(*  Name: ViC Plug-In 2.xx                 *)
(*  Type: DLL | Dynamic Link Library       *)
(*  Author: Vic aka vic4key                *)
(*  Website: cin1team.biz                  *)
(*  Mail: vic4key@gmail.com                *)
(*******************************************)

library VicPlugIn2;

{%File 'VicPlugIn2.bdsproj'}

{$R 'APPLYUPDATE.RES'}

uses
{$REGION 'uses'}
  Windows,
  SysUtils,
  Dialogs,
  Controls,
  ShellAPI,
  Messages,
  Forms,
  mrVic,
  Plugin in 'Plugin.pas',
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
  uFcData in '..\Modules\uFcData.pas',
  uShared in '..\GUI\PE Viewer\uShared.pas',
  uThreadMain in '..\GUI\Thread Viewer\uThreadMain.pas' {frmThreadViewer},
  uTimerConfig in '..\GUI\Thread Viewer\uTimerConfig.pas' {frmTimerConfig},
  uDCMain in '..\GUI\DATA Converter\uDCMain.pas' {frmDC},
  uUpdate in '..\Modules\uUpdate.pas',
  uMenu in '..\Modules\uMenu.pas',
  MapLoader in '..\GUI\MapLoader\MapLoader.pas',
  uMapMain in '..\GUI\MapLoader\uMapMain.pas' {frmMapLoader},
  uEventBD in '..\Modules\uEventBD.pas',
  uLC in '..\Modules\uLC.pas',
  uUDD in '..\Modules\uUDD.pas',
  uBP in '..\Modules\uBP.pas',
  uUpdater in '..\GUI\Updater\uUpdater.pas' {frmUpdater};

{$ENDREGION}

Function fcMainMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcBypassDbgMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcCpyDataMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcDeleteUddMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcBpManagerMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcConstNumberMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;
Function fcMapFileMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl; forward;

const
{$Region 'const'}
  LMapFileMenu: array[0..3] of TMenu =
  (
    (name: '|Map File Importer'; help: NIL; shortcutid: K_NONE; menucmd: fcMapFileMenu; submenu: NIL; index: 1),
    (name: '|Open Label window'; help: NIL; shortcutid: K_NONE; menucmd: fcMapFileMenu; submenu: NIL; index: 2),
    (name: 'Open Comment window'; help: NIL; shortcutid: K_NONE; menucmd: fcMapFileMenu; submenu: NIL; index: 3),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LConstNumberMenu: array[0..3] of TMenu =
  (
    (name: '|Follow in Disassembler at XXXXXXXXh'; help: NIL; shortcutid: K_NONE; menucmd: fcConstNumberMenu; submenu: NIL; index: 1),
    (name: 'Follow in Dump at XXXXXXXXh'; help: NIL; shortcutid: K_NONE; menucmd: fcConstNumberMenu; submenu: NIL; index: 2),
    (name: '|Copy XXXXXXXXh to clipboard'; help: NIL; shortcutid: K_NONE; menucmd: fcConstNumberMenu; submenu: NIL; index: 3),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LBypassDbgMenu: array[0..1] of TMenu =
  (
    (name: '|Hide the PEB'; help: NIL; shortcutid: K_NONE; menucmd: fcBypassDbgMenu; submenu: NIL; index: 1),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LBpManagerMenu: array[0..9] of TMenu =
  (
    (name: '|INT3 Delete all'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 1),
    (name: 'INT3 Import'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 2),
    (name: 'INT3 Export'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 3),
    (name: '|HWBP Delete all'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 4),
    (name: 'HWBP Import'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 5),
    (name: 'HWBP Export'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 6),
    (name: '|MBP Delete all'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 7),
    (name: 'MBP Import'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 8),
    (name: 'MBP Export'; help: NIL; shortcutid: K_NONE; menucmd: fcBpManagerMenu; submenu: NIL; index: 9),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LDeleteUddMenu: array[0..4] of TMenu =
  (
    (name: '|Delete UDD data of the current session'; help: NIL; shortcutid: K_NONE; menucmd: fcDeleteUddMenu; submenu: NIL; index: 1),
    (name: 'Delete all UDD data'; help: NIL; shortcutid: K_NONE; menucmd: fcDeleteUddMenu; submenu: NIL; index: 2),
    (name: 'Open UDD data list'; help: NIL; shortcutid: K_NONE; menucmd: fcDeleteUddMenu; submenu: NIL; index: 3),
    (name: '|Delete recent debuggee files'; help: NIL; shortcutid: K_NONE; menucmd: fcDeleteUddMenu; submenu: NIL; index: 4),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LCpyDataMenu: array[0..6] of TMenu =
  (
    (name: '|VA Address'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 1),
    (name: 'RVA Address'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 2),
    (name: 'Offset Address'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 3),
    (name: '|ANSI String'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 4),
    (name: 'UNICODE String'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 5),
    (name: '|Code Ripped'; help: NIL; shortcutid: K_NONE; menucmd: fcCpyDataMenu; submenu: NIL; index: 6),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );

  LMainMenu: array[0..22] of TMenu =
  (
    (name: '|Show the toolbar in the title of OllyDbg window'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 1),
    (name: '|Maximize OllyDbg window when staring'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 2),
    (name: '|Maximize OllyDbg child windows when staring'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 3),
    (name: '|Show address info in status bar'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 4),
    (name: '|Use APIs menu in OllyDbg menu bar'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 5),
    (name: '|Apply confirm exit for OllyDbg'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 6),
    (name: '|Make the transparency for OllyDbg window'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 7),
    (name: '|Debuggee Data'; help: NIL; shortcutid: K_NONE; menucmd: fcDeleteUddMenu; submenu: @LDeleteUddMenu; index: 8),
    (name: '|Data Converter'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 9),
    (name: '|DLL Process Viewer'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 10),
    (name: '|File Location Converter'; help: NIL; shortcutid: KK_DIRECT or KK_ALT or Ord('G'); menucmd: fcMainMenu; submenu: NIL; index: 11),
    (name: '|PE Viewer'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 12),
    (name: '|Thread Viewer'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 13),
    (name: '|Lookup Error Code'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 14),
    (name: '|Find events of C++ Builder / Delphi VCL GUI application'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 15),
    (name: '|Advanced Map File Importer'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: @LMapFileMenu; index: 16),
    (name: '|Bypass Anti Debugging'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: @LBypassDbgMenu; index: 17),
    (name: '|Data Copier'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: @LCpyDataMenu; index: 18),
    (name: '|Breakpoint Manager'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: @LBpManagerMenu; index: 19),
    (name: '|Follow Me'; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: @LConstNumberMenu; index: 20),
    (name: '|Check for update'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 21),
    (name: '|Infomation'; help: NIL; shortcutid: K_NONE; menucmd: fcMainMenu; submenu: NIL; index: 22),
    (name: NIL; help: NIL; shortcutid: K_NONE; menucmd: NIL; submenu: NIL; index: 0)
  );
{$EndRegion}

Function fcMapFileMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;
      ODData:= GetODData;
      if (ODData.processid = 0) then Result:= MENU_ABSENT;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      case dwIndex of
        1:
        begin
          try
            frmMapLoader:= TfrmMapLoader.Create(frmMapLoader);
            frmMapLoader.Show;
          except
            Exit;
          end;
        end;
        2:
        begin
          OpenLabelListWindow;
        end;
        3:
        begin
          OpenCommentListWindow;
        end                                                           
        else Result:= MENU_ABSENT;
      end;
    end
    else Result:= MENU_ABSENT;
  end;
end;

Function fcConstNumberMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var
  memAddr: DWORD;
  pmod: PModule;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;

      ODData:= GetODData;
      if (ODData.processid = 0) then Result:= MENU_ABSENT;

      pmod:= FindMainModule;
      if (pmod = NIL) then Exit;
      dwImageBase:= pmod^.base;

      case dwPane of
        DMT_CPUDUMP, DMT_CPUSTACK:
        begin
          ReadMemory(@memAddr,dwSelectedAddr,4,MM_SILENT or MM_PARTIAL);
        end
        else
        begin
          memAddr:= GetMemoryAddress(dwImageBase,dwSelectedAddr);
        end;
      end;

      pmod:= FindModule(memAddr);
      if (pmod = NIL) then
      begin
        Result:= MENU_ABSENT;
        Exit;
      end;

      case dwIndex of
        1:
        begin
          StrCopyW(pwText,lstrlenW(LConstNumberMenu[0].name),StringToOleStr(Format('Follow in Disassembler at %0.8Xh',[memAddr])));
        end;
        2:
        begin
          StrCopyW(pwText,lstrlenW(LConstNumberMenu[1].name),StringToOleStr(Format('Follow in Dump at %0.8Xh',[memAddr])));
        end;
        3:
        begin
          StrCopyW(pwText,lstrlenW(LConstNumberMenu[2].name),StringToOleStr(Format('Copy %0.8Xh to clipboard',[memAddr])));
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;

      case dwPane of
        DMT_CPUDUMP, DMT_CPUSTACK:
        begin
          ReadMemory(@memAddr,dwSelectedAddr,4,MM_SILENT or MM_PARTIAL);
        end
        else
        begin
          memAddr:= GetMemoryAddress(dwImageBase,dwSelectedAddr);
        end;
      end;

      pmod:= FindModule(memAddr);
      if (pmod = NIL) then
      begin
        StatusFlash('Follow failed');
        Result:= MENU_ABSENT;
        Exit;
      end;
      
      case dwIndex of
        1:
        begin
          try
            SetCPU(0,memAddr,0,0,0,CPU_ASMHIST or CPU_ASMCENTER or CPU_ASMFOCUS);
          except
            StatusFlash('Could not follow %0.8Xh in Disassembler',memAddr);
          end;
        end;
        2:
        begin
          try
             //SetCPU(0,memAddr,0,0,0,CPU_DUMPHIST);
             SetCPU(0,0,memAddr,0,0,CPU_DUMPHIST or CPU_DUMPFIRST or CPU_DUMPFOCUS);
             //MessageBoxW(hwODbg,szNotAvailable,PLUGIN_NAME,MB_ICONINFORMATION);
          except
            StatusFlash('Could not follow %0.8Xh in Dump',memAddr);
          end;
        end;     
        3:
        begin
          try
            if (SetTextToClipboardA(Format('%0.8X',[memAddr])) = True) then
            begin
              StatusFlash('Copied %0.8Xh to clipboard',[memAddr]);
            end
            else
            begin
              StatusFlash('Could not copy %0.8Xh to clipboard',[memAddr]);
            end;
          except
            StatusFlash('Could not copy %0.8Xh to clipboard',memAddr);
          end;
        end;
      end;
    end else Result:= MENU_ABSENT;
  end;
end;

Function fcBpManagerMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_ABSENT;
      ODData:= GetODData;
      if (ODData.processid = 0) then
      begin
        Result:= MENU_ABSENT;
      end
      else
      begin
        if (pwMenuType = PWM_DISASM)
        or (pwMenuType = PWM_DUMP)
        or (pwMenuType = PWM_STACK)
        or (pwMenuType = PWM_BPOINT)then
        begin
          case dwIndex of
            1, 3:
            begin
              ODData:= GetODData;
              if (ODData.bpoint.sorted.n = 0) then
              begin
                Result:= MENU_GRAYED;
              end
              else
              begin
                Result:= MENU_NORMAL;
              end;
            end;
            2: Result:= MENU_NORMAL;
          end;
        end;

        if (pwMenuType = PWM_DISASM)
        or (pwMenuType = PWM_DUMP)
        or (pwMenuType = PWM_STACK)
        or (pwMenuType = PWM_BPHARD)then
        begin
          case dwIndex of
            4, 6:
            begin
              ODData:= GetODData;
              if (ODData.bphard.sorted.n = 0) then
              begin
                Result:= MENU_GRAYED;
              end
              else
              begin
                Result:= MENU_NORMAL;
              end;
            end;
            5: Result:= MENU_NORMAL;
          end;
        end;

        if (pwMenuType = PWM_DISASM)
        or (pwMenuType = PWM_DUMP)
        or (pwMenuType = PWM_STACK)
        or (pwMenuType = PWM_BPMEM)then
        begin
          case dwIndex of
            7, 9:
            begin
              ODData:= GetODData;
              if (ODData.bpmem.sorted.n = 0) then
              begin
                Result:= MENU_GRAYED;
              end
              else
              begin
                Result:= MENU_NORMAL;
              end;
            end;
            8: Result:= MENU_NORMAL;
          end;
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      case dwIndex of
        1: // Delete INT3
        begin
          DeleteBreakpoint(BP_INT3);
        end;
        2: // Import INT3
        begin
          ImportBreakpoint(BP_INT3);
        end;
        3: // Export INT3
        begin
          ExportBreakpoint(BP_INT3);
        end;
        4: // Delete HWBP
        begin
          DeleteBreakpoint(BP_HWBP);
        end;
        5: // Import HWBP
        begin
          ImportBreakpoint(BP_HWBP);
        end;
        6: // Export HWBP
        begin
          ExportBreakpoint(BP_HWBP);
        end;
        7: // Delete MBP
        begin
          DeleteBreakpoint(BP_MBP);
        end;
        8: // Import MBP
        begin
          ImportBreakpoint(BP_MBP);
        end;
        9: // Export MBP
        begin
          ExportBreakpoint(BP_MBP);
        end;  
      end;
    end else Result:= MENU_ABSENT;
  end;
end;

Function fcBypassDbgMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;
      case dwIndex of
        1:
        begin
          ODData:= GetODData;
          if (ODData.processid = 0) then
          begin
            Result:= MENU_ABSENT;
          end;

          if (bAntiDebugBits = True) then Result:= MENU_CHECKED;
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      case dwIndex of
        1:
        begin
          bAntiDebugBits:= not bAntiDebugBits;
          SaveCfg(NIL,PLUGIN_NAME,HideThePEB,'%d',Integer(bAntiDebugBits));
          if bAntiDebugBits then MessageBoxW(hwODbg,'You must re-load your ollydbg',PLUGIN_NAME,MB_ICONWARNING);
        end;
        //2: VICBox('<None>');
      end;
    end else Result:= MENU_ABSENT;
  end;
end;

Function fcCpyDataMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var
  dwVA, dwRVA, dwOffset: DWORD;
  i, dwLenBuffer: DWORD;
  Buffer: array of Char;
  szText: String;
  lpwText: PWideChar;
  pmod: PModule;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;
      case dwIndex of
        1, 2, 3, 4, 5, 6:
        begin
          ODData:= GetODData;
          if (ODData.processid = 0) then
          begin
            Result:= MENU_ABSENT;
          end
          else
          begin
            if (pwMenuType = PWM_DISASM)
            or (pwMenuType = PWM_DUMP)
            or (pwMenuType = PWM_STACK) then
            begin
              Result:= MENU_NORMAL;
            end
            else
            begin
              Result:= MENU_ABSENT;
            end;
          end;
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      try
        pmod:= FindModule(dwSelectedAddr);
        if (pmod = NIL) then
        begin
          StatusFlash('Failed to copy, module not found');
          Exit;
        end;
        fpath:= WideCharToString(pmod^.path);
        dwImageBase:= pmod^.base;
        FLCMain.LoadPE(fpath);
        FLCMain.Converter(dwSelectedAddr,V,FLCMain.ISH,dwOffset,dwRVA,dwVA);
        //VICMsg('VA = %.8X, RVA = %.8X, Offset = %.8X',[dwVA,dwRVA,dwOffset]);
      except
        Exit;
        DumpExceptionInfomation;
      end;
      case dwIndex of
        1: // Copy VA
        begin
          if SetTextToClipboardA(fm('%.8X',[dwVA])) then
            StatusFlash('Copied VA = %.8X to clipboard',dwVA)
          else
            StatusFlash('Failure to copy the VA to clipboard');
        end;
        2: // Copy RVA
        begin
          if (dwRVA <> 0) then
          begin
            if SetTextToClipboardA(fm('%.8X',[dwRVA])) then
              StatusFlash('Copied RVA = %.8X to clipboard',dwRVA)
            else
              StatusFlash('Failure to copy the RVA to clipboard');
          end else StatusFlash('The address out of the main module');
        end;
        3: // Copy Offset
        begin
          if (dwOffset <> 0) then
          begin
            if SetTextToClipboardA(fm('%.8X',[dwOffset])) then
              StatusFlash('Copied Offset = %.8X to clipboard',dwOffset)
            else
              StatusFlash('Failure to copy the Offset to clipboard');
          end else StatusFlash('The address out of the main module');
        end;
        4: // Copy ANSI String
        begin
          dwLenBuffer:= dwEndAddr - dwStartAddr;
          if not IsBadReadPtr(Ptr(dwStartAddr),dwLenBuffer) then
          begin
            SetLength(Buffer,dwLenBuffer);
            ZeroMemory(Buffer,dwLenBuffer);
            ReadMemory(@Buffer[0],dwStartAddr,dwLenBuffer,MM_SILENT);
            SetTextToClipboardA('');
            for i:= 0 to (dwLenBuffer - 1) do
              if (Buffer[i] <> #0) then
              begin
                szText:= StrPas(PAnsiChar(@Buffer[i]));
                //VICBox(GetActiveWindow,szText);
                SetTextToClipboardA(szText);
                StatusFlash('The ANSI string copied to clipboard');
                Break;
              end;
          end;
        end;
        5: // Copy UNICODE String
        begin
          dwLenBuffer:= dwEndAddr - dwStartAddr;
          if not IsBadReadPtr(Ptr(dwStartAddr),dwLenBuffer) then
          begin
            SetLength(Buffer,dwLenBuffer);
            ZeroMemory(Buffer,dwLenBuffer);
            ReadMemory(@Buffer[0],dwStartAddr,dwLenBuffer,MM_SILENT);
            SetTextToClipboardW('');
            for i:= 0 to (dwLenBuffer - 2) do
            begin
              if (Buffer[i] <> #0) then
              begin
                lpwText:= PWideChar(@Buffer[i]);
                //VICBox(GetActiveWindow,szText);
                SetTextToClipboardW(lpwText);
                StatusFlash('The UNICODE string copied to clipboard');
                Break;
              end;
            end;
          end;
        end;
        6:
        begin
          MessageBoxW(hwODbg,szNotAvailable,PLUGIN_NAME,MB_ICONINFORMATION);
          //dwLenBuffer:= dwEndAddr - dwStartAddr;
          //VICMsg('%s',[CopyAsmCodeRipped(dwStartAddr,dwLenBuffer)]);
        end;
      end;
    end else Result:= MENU_ABSENT;
  end;
end;

Function fcMainMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var Buffer: array[0..MAXBYTE] of WideChar;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;
      case dwIndex of
        1: if (fTbShow = 2) then Result:= MENU_CHECKED;
        2: if (bMaxOD = True) then Result:= MENU_CHECKED;
        3: if (bMaxMDI = True) then Result:= MENU_CHECKED;
        4: if (fAddressInfo = 2) then Result:= MENU_CHECKED;
        5: if (fAPIMenu = 2) then Result:= MENU_CHECKED;
        6: if (fConfirm = 2) then Result:= MENU_CHECKED;
        9, 11, 12, 13, 15, 16, 17, 18, 20:
        begin
          ODData:= GetODData;
          if (ODData.processid = 0) then
          begin
            Result:= MENU_ABSENT;
          end
          else
          begin
            case dwIndex of
              9, 11, 18, 20: // DATA Converter, File Location Converter, Data Copier, Memory Const
              begin
                if (pwMenuType = PWM_MAIN)
                or (pwMenuType = PWM_DISASM)
                or (pwMenuType = PWM_DUMP)
                or (pwMenuType = PWM_STACK) then
                begin
                  Result:= MENU_NORMAL;
                end
                else
                begin
                  Result:= MENU_GRAYED;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      {$Region 'List'}
      case dwIndex of
        1: // Show the toolbar
        begin
          try
            fTbShow:= 3 - fTbShow;
            if (fTbShow = 2) then VIC_ShowToolbar;
            SaveCfg(NIL,PLUGIN_NAME,TbarODcfg,'%d',Integer(fTbShow));
          except
            Exit;
          end;
        end;
        2: // Maximize OllyDbg window when staring
        begin
          bMaxOD:= not bMaxOD;
          MaximizeOD(HWND(hwODbg));
          SaveCfg(NIL,PLUGIN_NAME,MaxMainODcfg,'%d',Integer(bMaxOD));
        end;
        3: // Maximize OllyDbg child windows when staring
        begin
          bMaxMDI:= not bMaxMDI;
          MaximizeMDI(HWND(hwClient));
          SaveCfg(NIL,PLUGIN_NAME,MaxMDIODcfg,'%d',Integer(bMaxMDI));
        end;
        4: // Show address info in status bar
        begin
            fAddressInfo:= 3 - fAddressInfo;
            SaveCfg(NIL,PLUGIN_NAME,AddrInfODcfg,'%d',Integer(fAddressInfo));
        end;
        5: // Use APIs menu in OllyDbg menu bar
        begin
            fAPIMenu:= 3 - fAPIMenu;
            if (fAPIMenu = 2) then CreateMyMenu(hwODbg)
            else DestroyMyMenu(hwODbg);
            SaveCfg(NIL,PLUGIN_NAME,ApiMenu,'%d',Integer(fAPIMenu));
        end;
        6: // Apply confirm exit for OllyDbg
        begin
          fConfirm:= 3 - fConfirm;
          SaveCfg(NIL,PLUGIN_NAME,ConfirmExit,'%d',Integer(fConfirm));
        end;
        7: // Make the transparency for OllyDbg window
        begin
          try
            frmTranOD:= TfrmTranOD.Create(frmTranOD);
            frmTranOD.Show;
          except
            Exit;
          end;
        end;
        // 8:  UDD Deletion
        9: // DATA Converter
        begin
          try
            szBuffer:= GetHexDumpString(dwStartAddr,dwEndAddr);
            Delete(szBuffer,Length(szBuffer),1); 
            frmDC:= TfrmDC.Create(frmDC);
            frmDC.Show;
          except
            Exit;
          end;
        end;
        10: // DLL Process Viewer
        begin
          try
            CreateDir(ViC_GetPathMe + 'log');
            DLLPV:= TDLLPV.Create(DLLPV);
            DLLPV.Show;
          except
            Exit;
          end;
        end;
        11: // File Location Converter
        begin
          try
            frmFLC:= TfrmFLC.Create(frmFLC);
            frmFLC.Show;
          except
            Exit;
          end;
        end;
        12: // PE Viewer
        begin
          try
            PE_Viewer:= TPE_Viewer.Create(PE_Viewer);
            PE_Viewer.Show;
          except
            Exit;
          end;
        end;
        13: // Thread Viewer
        begin
          try
            frmThreadViewer:= TfrmThreadViewer.Create(frmThreadViewer);
            frmThreadViewer.Show;
            frmTimerConfig:= TfrmTimerConfig.Create(frmTimerConfig);
          except
            Exit;
          end;
        end;
        14: // Lookup Error Code
        begin
          try
            frmLUE:= TfrmLUE.Create(frmLUE);
            frmLUE.Show;
          except
            Exit;
          end;
        end;
        15: // Finding Events for B/D executable file
        begin
          try
            if (DetermineSubSystem = True) then OpenEVWindow
            else StatusFlash('Debuggee is not a Windows GUI application');
            //StatusFlash('Debugge is not a C++ Builder/Delphi VCL GUI application');
          except
            Exit;
          end;
        end;
        // 16: Advanced Map File Importer
        // 17: Bypass anti debugging
        // 18: Address copier
        // 19: Breakpoint Manager
        // 20: Constant Address
        21: // Check for update
        begin
          if (Updater = True) then
          begin
            try
              frmUpdater:= TfrmUpdater.Create(frmUpdater);
              frmUpdater.Show;
            except
              Exit;
            end;
          end;
        end;
        22: // Infomation
        begin
          Swprintf(
          Buffer,
          '%s Version %s for OllyDbg %s %s' + DCRLF +
          'Update: %s' + DCRLF +
          'Author: %s' + DCRLF +
          'Team: %s' + DCRLF +
          'Contact: %s' + DCRLF +
          'Homepage: %s' + DCRLF +
          'Blog: %s',
          PLUGIN_NAME,VERSION,ODVERSION,ODVERSCOPE,DATEUPDATE,AUTHOR,TEAM,MAIL,WEBSITE,BLOG);
          MessageBoxW(hwODbg,Buffer,PLUGIN_NAME,MB_ICONINFORMATION);
        end;
      end;
    end;
    {$EndRegion}
    else Result:= MENU_ABSENT;
  end;
end;

Function fcDeleteUddMenu(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;
var szUddFileExt: String;
begin
  case iMode of
    MENU_VERIFY:
    begin
      Result:= MENU_NORMAL;
      case dwIndex of
        1:
        begin
          ODData:= GetODData;
          if (ODData.processid = 0) then
          begin
            Result:= MENU_GRAYED;
          end;
        end;
      end;
    end;
    MENU_EXECUTE:
    begin
      Result:= MENU_NOREDRAW;
      case dwIndex of
        1:
        begin
          ODData:= GetODData;
          szUddFileName:= ExtractFileName(WideCharToString(PWideChar(ODData.executable)));
          szUddFileExt:= ExtractFileExt(szUddFileName);
          szUddFileName:= Copy(szUddFileName,1,Length(szUddFileName) - Length(szUddFileExt));

          if (MessageBoxW(
            hwODbg,
            StringToOleStr(Format('Are you sure to delete UDD data of current session (%s)' + #13#10#13#10 +
            'Note: Restart (Ctrl + F2) required after delete',[szUddFileName])),
            PLUGIN_NAME,
            MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = IDNO) then Exit;


          if (ViC_DelUddData(Format('%s.UDD',[szUddFileName])) = True) then
          begin
            bDelCurrentUdd:= True;
            VICBox(
              hwODbg,
              WideCharToString(PLUGIN_NAME),
                'Delete UDD data of current session (%s) is successfully' + #13#10#13#10 +
                'Please restart OllyDbg (Ctrl + F2) to done',
                [szUddFileName]);
          end
          else
          begin
            VICBox(
              hwODbg,
              WideCharToString(PLUGIN_NAME),
              'Delete UDD data of current session (%s) is failure',[szUddFileName]);
          end;
        end;
        2:
        begin
          if (MessageBoxW(hwODbg,
            'Are you sure to delete all UDD data?',
            PLUGIN_NAME,
            MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = IDNO) then Exit;

          if (ViC_DelUddData('*.UDD') = True) then
          begin
            bDelAllUdd:= True;
            AddToLog(0,1,'%s: Delete all UDD data is done',PLUGIN_NAME);
            VICBox(hwODbg,WideCharToString(PLUGIN_NAME),'Delete all UDD data is successfully');
          end
          else
          begin
            StatusFlash('%s: Delete all UDD data is failure',PLUGIN_NAME);
            VICBox(hwODbg,WideCharToString(PLUGIN_NAME),'Delete all UDD data is failure');
          end;
        end;
        3:
        begin
          InitUDDSortedData;
          
          if (uddTable.hw = 0) then
          begin
            if (CreateTableWindow(@uddTable,0,uddTable.bar.nbar,0,'ICO_PLUGIN','UDDs List') = 0) then
            begin
              StatusFlash('%s: UDDs List created is error',PLUGIN_NAME);
            end;
          end else ActivateTableWindow(@uddTable);
        end;
        4:
        begin
          DeleteRecentDebuggeeFile;
        end;
      end;
    end else Result:= MENU_ABSENT;
  end;
end;

Function VIC_PluginQuery(iODVersion: Integer; pdwFeatures: PDWord; pwPluginName, dwPluginVersion: PWideChar): Integer; cdecl;
begin
  Result:= 0;
  try
    if (iODVersion < ODBG_VERSION) then
    begin
      AddToLog(0,1,'%s: Error: This plugin not compatiable for this version',PLUGIN_NAME);
      Exit;
    end;
    lstrcpynW(pwPluginName,PLUGIN_NAME,SHORTNAME);
    lstrcpynW(dwPluginVersion,VERSION,SHORTNAME);

    Result:= PLUGIN_VERSION;
  except
    DumpExceptionInfomation;
  end;
end;

Function VIC_PluginInit: Integer; cdecl;
begin
  Result:= 0;
  try
    ZeroMemory(Pointer(@ODData),sizeof(ODData));
    ODData:= GetODData;

    paOllyPath:= ODData.executable;
    hwODbg:= ODData.hwollymain;
    hwClient:= ODData.hwclient;
    hiODbg:= ODData.hollyinst;

    ODData:= GetODData;
    OLLYDBG_DIR:= WideCharToString(PWideChar(ODData.ollydir));
    OLLYDBG_PLUGIN_DIR:= WideCharToString(PWideChar(ODData.plugindir));

    szPlugInName:= StrPas(GetCurrentModuleName);

    fdir:= GetCurrentDir + '\';
    if (paOllyPath = NIL) or (hwClient = 0) then
    begin
      AddToLog(0,DRAW_GRAY,'Initialize ''%s'' is failure!',PLUGIN_NAME);
      Exit;
    end;

    AddToLog(0,DRAW_GRAY,'');
    AddToLog(0,DRAW_HILITE,'%s - Version %s for OllyDbg %s %s',PLUGIN_NAME,VERSION,ODVERSION,ODVERSCOPE);
    AddToLog(0,DRAW_GRAY,' - Update : %s',DATEUPDATE);
    AddToLog(0,DRAW_GRAY,' - Author : %s',AUTHOR);
    AddToLog(0,DRAW_GRAY,' - Email  : %s',MAIL);
    AddToLog(0,DRAW_GRAY,' - Team   : %s',TEAM);
    AddToLog(0,DRAW_GRAY,' - Home   : %s',WEBSITE);
    AddToLog(0,DRAW_GRAY,' - Blog   : %s',BLOG);
    AddToLog(0,DRAW_GRAY,'');

    LoadCfg(NIL,PLUGIN_NAME,HideThePEB,'%d',@bAntiDebugBits);

    LoadCfg(NIL,PLUGIN_NAME,MaxMainODcfg,'%d',@bMaxOD);
    MaximizeOD(hwODbg);

    LoadCfg(NIL,PLUGIN_NAME,MaxMDIODcfg,'%d',@bMaxMDI);
    MaximizeMDI(HWND(hwClient));

    LoadCfg(NIL,PLUGIN_NAME,TranODcfg,'%d',@iAlpha);
    ViC_Transparent(hwODbg,iAlpha);       

    LoadCfg(NIL,PLUGIN_NAME,AddrInfODcfg,'%d',@fAddressInfo);
    if (fAddressInfo = 0) then fAddressInfo:= 2;

    LoadCfg(NIL,PLUGIN_NAME,ApiMenu,'%d',@fAPIMenu);
    if (fAPIMenu = 2) then CreateMyMenu(hwODbg);
    if (fAPIMenu = 0) then fAPIMenu:= 2;

    LoadCfg(NIL,PLUGIN_NAME,TbarODcfg,'%d',@fTbShow);
    if (fTbShow = 0) then fTbShow:= 2;
    if (fTbShow = 2) then VIC_ShowToolbar;

    LoadCfg(NIL,PLUGIN_NAME,ConfirmExit,'%d',@fConfirm);

    InitUddMDIWindow;
    InitLabelMDIWindow;
    InitCommentMDIWindow;
    InitEVMDIWindow;

    if (uFcData.bSubClass = False) then uFcData.bSubClass:= uMenu.SubClassing;
  except
    DumpExceptionInfomation;
  end;
end;

Function VIC_PluginMenu(MenuType: PWideChar): PMenu; cdecl;
begin
  Result:= NIL;
  try
    pwMenuType:= MenuType;
    if (Menutype = PWM_MAIN)
    //or (Menutype = PWM_BPHARD)
    //or (Menutype = PWM_BPMEM)
    //or (Menutype = PWM_BPOINT)
    //or (Menutype = PWM_REGISTERS)
    or (Menutype = PWM_DISASM)
    or (Menutype = PWM_DUMP)
    or (Menutype = PWM_INFO)
    or (Menutype = PWM_LOG)
    or (Menutype = PWM_ATTACH)
    or (Menutype = PWM_MEMORY)
    or (Menutype = PWM_MODULES)
    or (Menutype = PWM_NAMELIST)
    or (Menutype = PWM_PATCHES)
    or (Menutype = PWM_PROFILE)
    or (Menutype = PWM_SEARCH)
    or (Menutype = PWM_SOURCE)
    or (Menutype = PWM_SRCLIST)
    or (Menutype = PWM_STACK)
    or (Menutype = PWM_THREADS)
    or (Menutype = PWM_TRACE)
    or (Menutype = PWM_WATCH)
    or (Menutype = PWM_WINDOWS) then Result:= @LMainMenu
    else
    begin
      if (pwMenuType = PWM_BPOINT)
      or (pwMenuType = PWM_BPHARD)
      or (pwMenuType = PWM_BPMEM) then Result:= @LBpManagerMenu;
    end;
  except
    DumpExceptionInfomation;
  end;
end;

Procedure VIC_PluginMainLoop(const DebugEvent: DEBUG_EVENT); cdecl;
begin
  try
    fpath:= WideCharToString(PWideChar(ODData.executable));
    fdir:= ExtractFilePath(fpath);
    fname:= ExtractFileName(fpath);

    ODData:= GetODData;
    //dwImageBase:= GetModuleBaseAddress(dwPID,fname);
  except
    DumpExceptionInfomation;
  end;
end;

Procedure VIC_PluginReset; cdecl;
begin
  try
    if (bDelAllUdd = True) then
    begin
      ViC_DelUddData('*.UDD');
      bDelAllUdd:= False;
    end;
  
    if (bDelCurrentUdd = True) then
    begin
      ViC_DelUddData(Format('%s.UDD',[szUddFileName]));
      bDelCurrentUdd:= False;
      szUddFileName:= '';
    end;

    DeleteSortedData(@uddTable.sorted,0,$FFFFFFFF);
  except
    DumpExceptionInfomation;
  end;
end;

Function VIC_PluginClose: Integer; cdecl;
begin
  Result:= 0;
  try
    if (fTbShow <> 1) then SendMessageA(frmTB.Handle,WM_CLOSE,0,0);
    SaveCfg(NIL,PLUGIN_NAME,MaxMainODcfg,'%d',Integer(bMaxOD));
    SaveCfg(NIL,PLUGIN_NAME,MaxMDIODcfg,'%d',Integer(bMaxMDI));
    SaveCfg(NIL,PLUGIN_NAME,TranODcfg,'%d',Integer(iAlpha));
    SaveCfg(NIL,PLUGIN_NAME,TbarODcfg,'%d',Integer(fTbShow));
    SaveCfg(NIL,PLUGIN_NAME,AddrInfODcfg,'%d',Integer(fAddressInfo));
    SaveCfg(NIL,PLUGIN_NAME,HideThePEB,'%d',Integer(bAntiDebugBits));
    SaveCfg(NIL,PLUGIN_NAME,ApiMenu,'%d',Integer(fAPIMenu));
    SaveCfg(NIL,PLUGIN_NAME,ConfirmExit,'%d',Integer(fConfirm));

    if (frmUpdater <> NIL) and (frmUpdater.Showing = True) then frmUpdater.Close;
    if (frmMapLoader <> NIL) and (frmMapLoader.Showing = True) then frmMapLoader.Close;
    if (frmModulePath <> NIL) and (frmModulePath.Showing = True) then frmModulePath.Close;
    if (frmImagePath <> NIL) and (frmImagePath.Showing = True) then frmImagePath.Close;
    if (frmThreadViewer <> NIL) and (frmThreadViewer.Showing = True) then frmThreadViewer.Close;
    if (frmTimerConfig <> NIL) and (frmTimerConfig.Showing) then frmTimerConfig.Close;
    if (frmTranOD <> NIL) and (frmTranOD.Showing = True) then frmTranOD.Close;
    if (frmLUE <> NIL) and (frmLUE.Showing = True) then frmLUE.Close;
    if (frmFLC <> NIL) and (frmFLC.Showing = True) then frmFLC.Close;
    if (frmTB <> NIL) and (frmTB.Showing = True) then frmTB.Close;
  except
    DumpExceptionInfomation;
  end;
end;

Procedure VIC_PluginDestroy; cdecl;
begin
  if (bDelAllUdd = True) then
  begin
    ViC_DelUddData('*.UDD');
    bDelAllUdd:= False;
  end;

  if (bDelCurrentUdd = True) then
  begin
    ViC_DelUddData(Format('%s.UDD',[szUddFileName]));
    bDelCurrentUdd:= False;
    szUddFileName:= '';
  end;

  if (IsSortedInit(@uddTable.sorted) <> 0) then
  begin
    DestroyUDDSortedData;
  end;
end;

Function VIC_PluginDump(pd: PDump; s: PWideChar; mask: PByte; n: Integer; select: PInteger; addr: DWORD; column: Integer): Integer; cdecl;
var
  i, dec, len: Integer;
  psect, psectthis: PSectHdr;
  pmod: PModule;
  pmem: PMemory;
  symb: array[0..MAXBYTE] of WideChar;
  szFlags: String;
begin
  Result:= 0;

  dwSelectedAddr:= pd^.sel0;
  dwStartAddr:= pd^.sel0;
  dwEndAddr:= pd^.sel1;

  case (pd^.menutype and DMT_CPUMASK) of
    DMT_CPUDASM:
    begin
      dwPane:= DMT_CPUDASM;
      //OutputDebugStringA('CPU Disasm');
    end;
    DMT_CPUDUMP:
    begin
      dwPane:= DMT_CPUDUMP;
      //OutputDebugStringA('CPU Dump');
    end;
    DMT_CPUSTACK:
    begin
      dwPane:= DMT_CPUSTACK;
      //OutputDebugStringA('CPU Stack');
    end
  end;

  if (fAddressInfo = 2) then
  begin
    len:= dwEndAddr - dwStartAddr;

    pmod:= FindModule(dwSelectedAddr);
    if (pmod = NIL) then
    begin
      //ODData:= GetODData;
      pmem:= FindMemory(dwSelectedAddr);
      if (pmem <> NIL) then
      begin
        szFlags:= GetMemoryTypes(pmem^.special);
        //VICMsg('Special: %X',[pmem^.special]);
      end
      else
      begin
        szFlags:= 'unknown';
      end;
      if (ODData.process <> 0) then
      StatusInfo('Unknown [block (%S) -> %0.8X] len = %X (%d.)',szFlags,dwSelectedAddr,len,len);
      Exit;
    end;

    if (pmod^.nsect = 0) then Exit;

    psectthis:= NIL;
    psect:= pmod^.sect;
    for i:= 0 to pmod^.nsect - 1 do
    begin
      if (dwSelectedAddr >= psect^.base) then psectthis:= psect;
      Inc(psect);
    end;

    if (psectthis = NIL) then
    begin
      Exit;
    end;

    szFlags:= '';
    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_MEM_READ) = True) then
    begin
      szFlags:= szFlags + 'r';
    end;

    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_MEM_WRITE) = True) then
    begin
      szFlags:= szFlags + 'w';
    end;

    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_MEM_EXECUTE) = True) then
    begin
      szFlags:= szFlags + 'e';
    end;

    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_CNT_INITIALIZED_DATA) = True) then
    begin
      szFlags:= szFlags + 'i';
    end;

    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_CNT_UNINITIALIZED_DATA) = True) then
    begin
      szFlags:= szFlags + 'u';
    end;

    if (CheckFlags(psectthis^.characteristics,IMAGE_SCN_MEM_SHARED) = True) then
    begin
      szFlags:= szFlags + 's';
    end;

    dec:= DecodeAddress(dwSelectedAddr,0,DM_SYMBOL,@symb,MAXBYTE,NIL);

    if (dec = 0) then
    begin
      StatusInfo(
        '<%s>[%s (%s) -> %0.8X] len = %X (%d.)',
        pmod^.modname,
        psectthis^.sectname,
        StringToOleStr(szFlags),
        dwSelectedAddr,len,len
      );
    end
    else
    begin
      StatusInfo(
        '<%s>[%s (%s) -> %0.8X (%s)] len = %X (%d.)',
        pmod^.modname,
        psectthis^.sectname,
        StringToOleStr(szFlags),
        dwSelectedAddr,symb,len,len
      );
    end;
  end;
end;

exports
  VIC_PluginInit name 'ODBG2_Plugininit',
  VIC_PluginQuery name 'ODBG2_Pluginquery',
  VIC_PluginMenu name 'ODBG2_Pluginmenu',
  VIC_PluginDump name 'ODBG2_Plugindump',
  VIC_PluginReset name 'ODBG2_Pluginreset',
  VIC_PluginMainLoop name 'ODBG2_Pluginmainloop',
  VIC_PluginClose name 'ODBG2_Pluginclose',
  VIC_PluginDestroy name 'ODBG2_Plugindestroy';
end.
