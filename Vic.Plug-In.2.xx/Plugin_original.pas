unit Plugin;

interface

uses Windows;

const __VERSION__ = 2.01;

{$Region 'const'}
const
  OllyDbg = 'OllyDbg.exe';
  PLUGIN_VERSION = $02010001;       // Version 2.01.0001 of plugin interface
  ODBG_VERSION   = 201;

  MAXPATH = MAX_PATH;

  MENU_VERIFY    = 0;               // Check if menu item applies
  MENU_EXECUTE   = 1;               // Execute menu item
  MENU_ABSENT    = 0;               // Item doesn't appear in menu
  MENU_NORMAL    = 1;               // Ordinary menu item
  MENU_CHECKED   = 2;               // Checked menu item
  MENU_CHKPARENT = 3;               // Checked menu item + checked parent
  MENU_GRAYED    = 4;               // Inactive menu item
  MENU_SHORTCUT  = 5;               // Shortcut only, not in menu
  MENU_NOREDRAW  = 0;               // Do not redraw owning window
  MENU_REDRAW    = 1;               // Redraw owning window    

  PWM_ATTACH    = 'ATTACH';       // List of processes in Attach window
  PWM_BPHARD    = 'BPHARD';       // Hardware breakpoints
  PWM_BPMEM     = 'BPMEM';        // Memory breakpoints
  PWM_BPOINT    = 'BPOINT';       // INT3 breakpoints
  PWM_DISASM    = 'DISASM';       // CPU Disassembler pane
  PWM_DUMP      = 'DUMP';         // All dumps except CPU disasm & stack
  PWM_INFO      = 'INFO';         // CPU Info pane
  PWM_LOG       = 'LOG';          // Log window
  PWM_MAIN      = 'MAIN';         // Main OllyDbg menu
  PWM_MEMORY    = 'MEMORY';       // Memory window
  PWM_MODULES   = 'MODULES';      // Modules window
  PWM_NAMELIST  = 'NAMELIST';     // List of names (labels)
  PWM_PATCHES   = 'PATCHES';      // List of patches
  PWM_PROFILE   = 'PROFILE';      // Profile window
  PWM_REGISTERS = 'REGISTERS';    // Registers, including CPU
  PWM_SEARCH    = 'SEARCH';       // Search tabs
  PWM_SOURCE    = 'SOURCE';       // Source code window
  PWM_SRCLIST   = 'SRCLIST';      // List of source files
  PWM_STACK     = 'STACK';        // CPU Stack pane
  PWM_THREADS   = 'THREADS';      // Threads window
  PWM_TRACE     = 'TRACE';        // Run trace window
  PWM_WATCH     = 'WATCH';        // Watches
  PWM_WINDOWS   = 'WINDOWS';      // List of windows

  TEXTLEN       = 256;             // Max length of text string incl. '\0'
  DATALEN       = 4096;            // Max length of data record (max 65535)
  ARGLEN        = 1024;            // Max length of argument string
  MAXMULTIPATH  = 8192;            // Max length of multiple selection
  SHORTNAME     = 32;              // Max length of short or module name

  NREG          = 8;               // Number of registers (of any type)
  NSEG          = 6;               // Number of valid segment registers
  NHARD         = 4;               // Number of hardware breakpoints

  NMEMFIELD     = 2;

// Shortcut descriptions.
  KK_KEYMASK    = $0000FFFF; // Mask to extract key
  KK_CHAR       = $00010000; // Process as WM_CHAR
  KK_SHIFT      = $00020000; // Shortcut includes Shift key
  KK_CTRL       = $00040000; // Shortcut includes Ctrl key
  KK_ALT        = $00080000; // Shortcut includes Alt key
  KK_WIN        = $00100000; // Shortcut includes WIN key
  KK_NOSH       = $00200000; // Shortcut ignores Shift in main menu
  KK_UNUSED     = $7FC00000; // Unused shortcut data bits
  KK_DIRECT     = $80000000; // Direct shortcut in menu                                   
// Global shortcuts. They may be re-used by plugins.
  K_NONE        = 0;         // No shortcut

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// MODULES ////////////////////////////////////

  SHT_MERGENEXT = $00000001;      // Merge section with the next

  NCALLMOD      = 24; // Max number of saved called modules

// .NET stream identifiers. Don't change the order and the values of the
// first three items (NS_STRINGS, NS_GUID and NS_BLOB)!
  NS_STRINGS    = 0; // Stream with ASCII strings
  NS_GUID       = 1; // Stream with GUIDs
  NS_BLOB       = 2; // Data referenced by MetaData
  NS_US         = 3; // Stream with UNICODE strings
  NS_META       = 4; // Stream with MetaData tables

  NETSTREAM     = 5; // Number of default .NET streams

// Indices of .NET MetaData tables.
  MDT_MODULE     = 0; // Module table
  MDT_TYPEREF    = 1; // TypeRef table
  MDT_TYPEDEF    = 2; // TypeDef table
  MDT_FIELDPTR   = 3; // FieldPtr table
  MDT_FIELD      = 4; // Field table
  MDT_METHODPTR  = 5; // MethodPtr table
  MDT_METHOD     = 6; // MethodDef table
  MDT_PARAMPTR   = 7; // ParamPtr table
  MDT_PARAM      = 8; // Param table
  MDT_INTERFACE  = 9; // InterfaceImpl table
  MDT_MEMBERREF  = 10; // MemberRef table
  MDT_CONSTANT   = 11; // Constant table
  MDT_CUSTATTR   = 12; // CustomAttribute table
  MDT_MARSHAL    = 13; // FieldMarshal table
  MDT_DECLSEC    = 14; // DeclSecurity table
  MDT_CLASSLAY   = 15; // ClassLayout table
  MDT_FIELDLAY   = 16; // FieldLayout table
  MDT_SIGNATURE  = 17; // StandAloneSig table
  MDT_EVENTMAP   = 18; // EventMap table
  MDT_EVENTPTR   = 19; // EventPtr table
  MDT_EVENT      = 20; // Event table
  MDT_PROPMAP    = 21; // PropertyMap table
  MDT_PROPPTR    = 22; // PropertyPtr table
  MDT_PROPERTY   = 23; // Property table
  MDT_METHSEM    = 24; // MethodSemantics table
  MDT_METHIMPL   = 25; // MethodImpl table
  MDT_MODREF     = 26; // ModuleRef table
  MDT_TYPESPEC   = 27; // TypeSpec table
  MDT_IMPLMAP    = 28; // ImplMap table
  MDT_RVA        = 29; // FieldRVA table
  MDT_ENCLOG     = 30; // ENCLog table
  MDT_ENCMAP     = 31; // ENCMap table
  MDT_ASSEMBLY   = 32; // Assembly table
  MDT_ASMPROC    = 33; // AssemblyProcessor table
  MDT_ASMOS      = 34; // AssemblyOS table
  MDT_ASMREF     = 35; // AssemblyRef table
  MDT_REFPROC    = 36; // AssemblyRefProcessor table
  MDT_REFOS      = 37; // AssemblyRefOS table
  MDT_FILE       = 38; // File table
  MDT_EXPORT     = 39; // ExportedType table
  MDT_RESOURCE   = 40; // ManifestResource table
  MDT_NESTED     = 41; // NestedClass table
  MDT_GENPARM    = 42; // GenericParam table
  MDT_METHSPEC   = 43; // MethodSpec table
  MDT_CONSTR     = 44; // GenericParamConstraint table
  MDT_UNUSED     = 63; // Used only in midx[]

  MDTCOUNT       = 64; // Number of .NET MetaData tables

////////////////////////////////////////////////////////////////////////////////
/////////////////////// TAGGED DATA FILES AND RESOURCES ////////////////////////

  MI_SIGNATURE   = $00646F4D;     // Signature of tagged file
  MI_VERSION     = $7265560A;     // File version
  MI_FILENAME    = $6C69460A;     // Record with ful; name of executable
  MI_FILEINFO    = $7263460A;     // Length, date, CRC (t_fileinfo)
  MI_DATA        = $7461440A;     // Name or data (t_nameinfo)
  MI_CALLBRA     = $7262430A;     // Cal; brackets
  MI_LOOPBRA     = $72624C0A;     // Loop brackets
  MI_PROCDATA    = $6372500A;     // Procedure data (set of t_procdata)
  MI_INT3BREAK   = $336E490A;     // INT3 breakpoint (t_bpoint)
  MI_MEMBREAK    = $6D70420A;     // Memory breakpoint (t_bpmem)
  MI_HWBREAK     = $6870420A;     // Hardware breakpoint (t_bphard)
  MI_ANALYSIS    = $616E410A;     // Record with analysis data
  MI_SWITCH      = $6977530A;     // Switch (addr+dt_switch)
  MI_CASE        = $7361430A;     // Case (addr+dt_case)
  MI_MNEMO       = $656E4D0A;     // Decoding of mnemonics (addr+dt_mnemo)
  MI_JMPDATA     = $74644A0A;     // Jump data
  MI_NETSTREAM   = $74734E0A;     // .NET streams (t_netstream)
  MI_METADATA    = $74644D0A;     // .NET MetaData tables (t_metadata)
  MI_BINSAV      = $7673420A;     // Last entered binary search patterns
  MI_MODDATA     = $61624D0A;     // Module base, size and path
  MI_PREDICT     = $6472500A;     // Predicted command execution results
  MI_LASTSAV     = $61734C0A;     // Last entered strings (t_nameinfo)
  MI_SAVEAREA    = $7661530A;     // Save area (t_savearea)
  MI_RTCOND      = $6374520A;     // Run trace pause condition
  MI_RTPROT      = $7074520A;     // Run trace protoco; condition
  MI_WATCH       = $6374570A;     // Watch in watch window
  MI_LOADDLL     = $64644C0A;     // Packed loaddll.exe
  MI_PATCH       = $7461500A;     // Patch data (compressed t_patch)
  MI_PLUGIN      = $676C500A;     // Plugin prefix descriptor
  MI_END         = $646E450A;     // End of tagged file

////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// DATA FUNCTIONS ////////////////////////////////

// Name and data types. Do not change order, it's important! Always keep values
// of demangled names 1 higher than originals, and NM_ALIAS higher than
// NM_EXPORT - name search routines rely on these facts!
  NM_NONAME      = $00; // Means that name is absent
  DT_NONE        = $00; // Ditto
  NM_LABEL       = $21; // User-defined label
  NM_EXPORT      = $22; // Exported name
  NM_DEEXP       = (NM_EXPORT + 1);   // Demangled exported name
  DT_EORD        = (NM_EXPORT + 2);   // Exported ordinal = $(ulong)
  NM_ALIAS       = (NM_EXPORT + 3);   // Alias of NM_EXPORT
  NM_IMPORT      = $26; // Imported name = $(module.function)
  NM_DEIMP       = (NM_IMPORT + 1);   // Demangled imported name
  DT_IORD        = (NM_IMPORT + 2);   // Imported ordinal = $(struct dt_iord)
  NM_DEBUG       = $29; // Name from debug data
  NM_DEDEBUG     = (NM_DEBUG + 1);    // Demangled name from debug data
  NM_ANLABEL     = $2B; // Name added by Analyser
  NM_COMMENT     = $30; // User-defined comment
  NM_ANALYSE     = $31; // Comment added by Analyser
  NM_MARK        = $32; // Important parameter
  NM_CALLED      = $33; // Name of called function
  DT_ARG         = $34; // Name and type of argument or data
  DT_NARG        = $35; // Guessed number of arguments at CALL
  NM_RETTYPE     = $36; // Type of data returned in EAX
  NM_MODCOMM     = $37; // Automatical module comments
  NM_TRICK       = $38; // Parentheses of tricky sequences
  DT_SWITCH      = $40; // Switch descriptor = $(struct dt_switch)
  DT_CASE        = $41; // Case descriptor = $(struct dt_case)
  DT_MNEMO       = $42; // Alternative mnemonics data = $(dt_mnemo)
  NM_DLLPARMS    = $44; // Parameters of Call DLL dialog
  DT_DLLDATA     = $45; // Parameters of Call DLL dialog

  DT_DBGPROC     = $4A; // t_function from debug, don't save!

  NM_INT3BASE    = $51; // Base for INT3 breakpoint names
  NM_INT3COND    = (NM_INT3BASE + 0); // INT3 breakpoint condition
  NM_INT3EXPR    = (NM_INT3BASE + 1); // Expression to log at INT3 breakpoint
  NM_INT3TYPE    = (NM_INT3BASE + 2); // Type used to decode expression
  NM_MEMBASE     = $54; // Base for memory breakpoint names
  NM_MEMCOND     = (NM_MEMBASE + 0);  // Memory breakpoint condition
  NM_MEMEXPR     = (NM_MEMBASE + 1);  // Expression to log at memory break
  NM_MEMTYPE     = (NM_MEMBASE + 2);  // Type used to decode expression
  NM_HARDBASE    = $57; // Base for hardware breakpoint names
  NM_HARDCOND    = (NM_HARDBASE + 0); // Hardware breakpoint condition
  NM_HARDEXPR    = (NM_HARDBASE + 1); // Expression to log at hardware break
  NM_HARDTYPE    = (NM_HARDBASE + 2); // Type used to decode expression

  NM_LABELSAV    = $60; // NSTRINGS last user-defined labels
  NM_ASMSAV      = $61; // NSTRINGS last assembled commands
  NM_ASRCHSAV    = $62; // NSTRINGS last assemby searches
  NM_COMMSAV     = $63; // NSTRINGS last user-defined comments
  NM_WATCHSAV    = $64; // NSTRINGS last watch expressions
  NM_GOTOSAV     = $65; // NSTRINGS last GOTO expressions
  DT_BINSAV      = $66; // NSTRINGS last binary search patterns
  NM_CONSTSAV    = $67; // NSTRINGS last constants to search
  NM_STRSAV      = $68; // NSTRINGS last strings to search
  NM_ARGSAV      = $69; // NSTRINGS last arguments = $(ARGLEN!)
  NM_CURRSAV     = $6A; // NSTRINGS last current dirs = $(MAXPATH!)

  NM_SEQSAV      = $6F; // NSTRINGS last sequences = $(DATALEN!)

  NM_RTCOND1     = $70; // First run trace pause condition
  NM_RTCOND2     = $71; // Second run trace pause condition
  NM_RTCOND3     = $72; // Third run trace pause condition
  NM_RTCOND4     = $73; // Fourth run trace pause condition
  NM_RTCMD1      = $74; // First run trace match command
  NM_RTCMD2      = $75; // Second run trace match command
  NM_RANGE0      = $76; // Low range limit
  NM_RANGE1      = $77; // High range limit

  DT_ANYDATA     = $FF; // Special marker, not a real data

  NMOFS_COND     = 0; // Offset to breakpoint condition
  NMOFS_EXPR     = 1; // Offset to breakpoint log expression
  NMOFS_TYPE     = 2; // Offset to expression decoding type

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// CPU //////////////////////////////////////

// Mode bits for Setcpu().
  CPU_ASMHIST    = $00000001; // Add change to Disassembler history
  CPU_ASMCENTER  = $00000004; // Make address in the middle of window
  CPU_ASMFOCUS   = $00000008; // Move focus to Disassembler
  CPU_DUMPHIST   = $00000010; // Add change to Dump history
  CPU_DUMPFIRST  = $00000020; // Make address the first byte in Dump
  CPU_DUMPFOCUS  = $00000080; // Move focus to Dump
  CPU_STACKFOCUS = $00000100; // Move focus to Stack
  CPU_STACKCTR   = $00000200; // Center stack instead moving to top
  CPU_REGAUTO    = $00001000; // Automatically switch to FPU/MMX/3DNow!
  CPU_NOCREATE   = $00002000; // Don't create CPU window if absent
  CPU_REDRAW     = $00004000; // Redraw CPU window immediately
  CPU_NOFOCUS    = $00008000; // Don't assign focus to main window
  CPU_RUNTRACE   = $00010000; // asmaddr is run trace backstep
  CPU_NOTRACE    = $00020000; // Stop run trace display

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// COMMENTS ///////////////////////////////////

// Comments types used by Commentaddress().
  COMM_USER      = $00000001; // Add user-defined comment
  COMM_MARK      = $00000002; // Add important arguments
  COMM_PROC      = $00000004; // Add procedure description
  COMM_ALL       = $FFFFFFFF; // Add all possible comments

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// SORTED DATA //////////////////////////////////

  SDM_INDEXED    = $00000001; // Indexed sorted data
  SDM_EXTADDR    = $00000002; // Address is extended by TY_AEXTMASK
  SDM_NOSIZE     = $00000004; // Header without size and type
  SDM_NOEXTEND   = $00000008; // Don't reallocate memory, fail instead

// Address extension.
  TY_AEXTMASK    = $000000FF; // Mask to extract address extension
// General item types.
  TY_NEW         = $00000100; // Item is new
  TY_CONFIRMED   = $00000200; // Item still exists
  TY_EXTADDR     = $00000400; // Address extension active
  TY_SELECTED    = $00000800; // Reserved for multiple selection
// Module-related item types (used in t_module and t_premod).
  MOD_MAIN       = $00010000; // Main module
  MOD_SFX        = $00020000; // Self-extractable file
  MOD_SFXDONE    = $00040000; // SFX file extracted
  MOD_RUNDLL     = $00080000; // DLL loaded by LOADDLL.EXE
  MOD_SYSTEMDLL  = $00100000; // System DLL
  MOD_SUPERSYS   = $00200000; // System DLL that uses special commands
  MOD_DBGDATA    = $00400000; // Debugging data is available
  MOD_ANALYSED   = $00800000; // Module is already analysed
  MOD_NODATA     = $01000000; // Module data is not yet available
  MOD_HIDDEN     = $02000000; // Module is loaded in stealth mode
  MOD_NETAPP     = $04000000; // .NET application
  MOD_RESOLVED   = $40000000; // All static imports are resolved
// Memory-related item types (used in t_memory), see also t_memory.special.
  MEM_ANYMEM     = $0FFFF000; // Mask for memory attributes
  MEM_CODE       = $00001000; // Contains image of code section
  MEM_DATA       = $00002000; // Contains image of data section
  MEM_SFX        = $00004000; // Contains self-extractor
  MEM_IMPDATA    = $00008000; // Contains import data
  MEM_EXPDATA    = $00010000; // Contains export data
  MEM_RSRC       = $00020000; // Contains resources
  MEM_RELOC      = $00040000; // Contains relocation data
  MEM_STACK      = $00080000; // Contains stack of some thread
  MEM_STKGUARD   = $00100000; // Guarding page of the stack
  MEM_THREAD     = $00200000; // Contains data block of some thread
  MEM_HEADER     = $00400000; // Contains COFF header
  MEM_DEFHEAP    = $00800000; // Contains default heap
  MEM_HEAP       = $01000000; // Contains non-default heap
  MEM_NATIVE     = $02000000; // Contains JIT-compiled native code
  MEM_GAP        = $08000000; // Free or reserved space
  MEM_SECTION    = $10000000; // Section of the executable file
  MEM_GUARDED    = $40000000; // NT only: guarded memory block
  MEM_TEMPGUARD  = $80000000; // NT only: temporarily guarded block
// Thread-related item types (used in t_thread).
  THR_MAIN       = $00010000; // Main thread
  THR_NETDBG     = $00020000; // .NET debug helper thread
  THR_ORGHANDLE  = $00100000; // Original thread's handle, don't close
// Window-related item types (used in t_window).
  WN_UNICODE     = $00010000; // UNICODE window
// Procedure-related item types (used in t_procdata).
  PD_CALLBACK    = $00001000; // Used as a callback
  PD_RETSIZE     = $00010000; // Return size valid
  PD_TAMPERRET   = $00020000; // Tampers with the return address
  PD_NORETURN    = $00040000; // Calls function without return
  PD_PURE        = $00080000; // Doesn't modify memory & make calls
  PD_ESPALIGN    = $00100000; // Aligns ESP on entry
  PD_ARGMASK     = $07E00000; // Mask indicating valid narg
  PD_FIXARG      = $00200000; // narg is fixed number of arguments
  PD_FORMATA     = $00400000; // narg-1 is ASCII printf format
  PD_FORMATW     = $00800000; // narg-1 is UNICODE printf format
  PD_SCANA       = $01000000; // narg-1 is ASCII scanf format
  PD_SCANW       = $02000000; // narg-1 is UNICODE scanf format
  PD_COUNT       = $04000000; // narg-1 is count of following args
  PD_GUESSED     = $08000000; // narg and type are guessed, not known
  PD_NGUESS      = $10000000; // nguess valid
  PD_VARGUESS    = $20000000; // nguess variable, set to minimum!=0
  PD_NPUSH       = $40000000; // npush valid
  PD_VARPUSH     = $80000000; // npush valid, set to maximum
// Argument prediction-related types (used in t_predict).
  PR_PUSHBP      = $00010000; // PUSH EBP or ENTER executed
  PR_MOVBPSP     = $00020000; // MOV EBP,ESP or ENTER executed
  PR_SETSEH      = $00040000; // Structured exception handler set
  PR_RETISJMP    = $00100000; // Return is (mis)used as a jump
  PR_DIFFRET     = $00200000; // Return changed, destination unknown
  PR_JMPTORET    = $00400000; // Jump to original return address
  PR_TAMPERRET   = $00800000; // Retaddr on stack accessed or modified
  PR_BADESP      = $01000000; // ESP of actual generation is invalid
  PR_RET         = $02000000; // Return from subroutine
  PR_STEPINTO    = $10000000; // Step into CALL command
// Breakpoint-related types (used in t_bpoint, t_bpmem and t_bphard).
  BP_BASE        = $0000F000; // Mask to extract basic breakpoint type
  BP_MANUAL      = $00001000; // Permanent breakpoint
  BP_ONESHOT     = $00002000; // Stop and reset this bit
  BP_TEMP        = $00004000; // Reset this bit and continue
  BP_TRACE       = $00008000; // Used for hit trace
  BP_SET         = $00010000; // Code INT3 is in memory, cmd is valid
  BP_DISABLED    = $00020000; // Permanent breakpoint is disabled
  BP_COND        = $00040000; // Conditional breakpoint
  BP_PERIODICAL  = $00080000; // Periodical (pauses each passcount)
  BP_ACCESSMASK  = $00E00000; // Access conditions (memory+hard)
  BP_READ        = $00200000; // Break on read memory access
  BP_WRITE       = $00400000; // Break on write memory access
  BP_EXEC        = $00800000; // Break on code execution
  BP_BREAKMASK   = $03000000; // When to pause execution
  BP_NOBREAK     = $00000000; // No pause
  BP_CONDBREAK   = $01000000; // Pause if condition is true
  BP_BREAK       = $03000000; // Pause always
  BP_LOGMASK     = $0C000000; // When to log value of expression
  BP_NOLOG       = $00000000; // Don't log expression
  BP_CONDLOG     = $04000000; // Log expression if condition is true
  BP_LOG         = $0C000000; // Log expression always
  BP_ARGMASK     = $30000000; // When to log arguments of a function
  BP_NOARG       = $00000000; // Don't log arguments
  BP_CONDARG     = $10000000; // Log arguments if condition is true
  BP_ARG         = $30000000; // Log arguments always
  BP_RETMASK     = $C0000000; // When to log return value of a function
  BP_NORET       = $00000000; // Don't log return value
  BP_CONDRET     = $40000000; // Log return value if condition is true
  BP_RET         = $C0000000; // Log return value always
  BP_MANMASK     = (BP_PERIODICAL or BP_BREAKMASK or BP_LOGMASK or BP_ARGMASK or BP_RETMASK);
  BP_CONFIRM     = TY_CONFIRMED;    // Internal OllyDbg use
// Search-related types (used in t_search).
  SE_ORIGIN      = $00010000; // Search origin
  SE_STRING      = $00020000; // Data contains string address
  SE_FLOAT       = $00040000; // Data contains floating constant
  SE_GUID        = $00080000; // Data contains GUID
  SE_CONST       = $01000000; // Constant, not referencing command
// Source-related types (used in t_source).
  SRC_ABSENT     = $00010000; // Source file is absent
// Namelist-related types (used in t_namelist).
  NL_EORD        = $00010000; // Associated export ordinal available
  NL_IORD        = $00020000; // Associated import ordinal available

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// BREAKPOINTS //////////////////////////////////

// Actions that must be performed if breakpoint of type BP_ONESHOT or BP_TEMP
// is hit.
  BA_PERMANENT   = $00000001;      // Permanent INT3 BP_TEMP on system call
  BA_PLUGIN      = $80000000;      // Pass notification to plugin

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// MEMORY FUNCTIONS ///////////////////////////////

// Mode bits used in calls to Readmemory(), Readmemoryex() and Writememory().
  MM_REPORT      = $0000; // Display error message if unreadable
  MM_SILENT      = $0001; // Don't display error message
  MM_NORESTORE   = $0002; // Don't remove/set INT3 breakpoints
  MM_PARTIAL     = $0004; // Allow less data than requested
  MM_WRITETHRU   = $0008; // Write immediately to memory
  MM_REMOVEINT3  = $0010; // Writememory(): remove INT3 breaks
  MM_ADJUSTINT3  = $0020; // Writememory(): adjust INT3 breaks
  MM_FAILGUARD   = $0040; // Fail if memory is guarded
// Mode bits used in calls to Readmemoryex().
  MM_BPMASK      = BP_ACCESSMASK;   // Mask to extract memory breakpoints
  MM_BPREAD      = BP_READ;         // Fail if memory break on read is set
  MM_BPWRITE     = BP_WRITE;        // Fail if memory break on write is set
  MM_BPEXEC      = BP_EXEC;         // Fail if memory break on exec is set

// Special types of memory block.
  MSP_NONE       = 0; // Not a special memory block
  MSP_PEB        = 1; // Contains Process Environment Block
  MSP_SHDATA     = 2; // Contains KUSER_SHARED_DATA
  MSP_PROCPAR    = 3; // Contains Process Parameters
  MSP_ENV        = 4; // Contains environment

////////////////////////////////////////////////////////////////////////////////
///////////////////////// SORTED DATA WINDOWS (TABLES) /////////////////////////

  NBAR           = 17; // Max allowed number of segments in bar

  BAR_FLAT       = $00000000; // Flat segment
  BAR_BUTTON     = $00000001; // Segment sends WM_USER_BAR
  BAR_SORT       = $00000002; // Segment re-sorts sorted data
  BAR_DISABLED   = $00000004; // Bar segment disabled
  BAR_NORESIZE   = $00000008; // Bar column cannot be resized
  BAR_SHIFTSEL   = $00000010; // Selection shifted 1/2 char to left
  BAR_WIDEFONT   = $00000020; // Twice as wide characters
  BAR_SEP        = $00000040; // Treat '|' as separator
  BAR_ARROWS     = $00000080; // Arrows if segment is shifted
  BAR_PRESSED    = $00000100; // Bar segment pressed, used internally
  BAR_SPMASK     = $0000F000; // Mask to extract speech type
  BAR_SPSTD      = $00000000; // Standard speech with all conversions
  BAR_SPASM      = $00001000; // Disassembler-oriented speech
  BAR_SPEXPR     = $00002000; // Expression-oriented speech
  BAR_SPEXACT    = $00003000; // Pass to speech engine as is
  BAR_SPELL      = $00004000; // Text, spell symbol by symbol
  BAR_SPHEX      = $00005000; // Hexadecimal, spell symbol by symbol
  BAR_SPNONE     = $0000F000; // Column is excluded from speech

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////// DUMP /////////////////////////////////////

  DU_STACK       = $80000000; // Used for internal purposes
  DU_NOSMALL     = $40000000; // Used for internal purposes
  DU_MODEMASK    = $3C000000; // Mask for mode bits
  DU_SMALL       = $20000000; // Small-size dump
  DU_FIXADDR     = $10000000; // Fix first visible address
  DU_BACKUP      = $08000000; // Display backup instead of actual data
  DU_USEDEC      = $04000000; // Show contents using decoding data
  DU_COMMMASK    = $03000000; // Mask for disassembly comments
  DU_COMMENT     = $00000000; // Show comments
  DU_SOURCE      = $01000000; // Show source
  DU_DISCARD     = $00800000; // Discardable by Esc
  DU_PROFILE     = $00400000; // Show profile
  DU_TYPEMASK    = $003F0000; // Mask for dump type
  DU_HEXTEXT     = $00010000; // Hexadecimal dump with ASCII text
  DU_HEXUNI      = $00020000; // Hexadecimal dump with UNICODE text
  DU_TEXT        = $00030000; // Character dump
  DU_UNICODE     = $00040000; // Unicode dump
  DU_INT         = $00050000; // Integer signed dump
  DU_UINT        = $00060000; // Integer unsigned dump
  DU_IHEX        = $00070000; // Integer hexadecimal dump
  DU_FLOAT       = $00080000; // Floating-point dump
  DU_ADDR        = $00090000; // Address dump
  DU_ADRASC      = $000A0000; // Address dump with ASCII text
  DU_ADRUNI      = $000B0000; // Address dump with UNICODE text
  DU_DISASM      = $000C0000; // Disassembly
  DU_DECODE      = $000D0000; // Same as DU_DISASM but for decoded data
  DU_COUNTMASK   = $0000FF00; // Mask for number of items/line
  DU_SIZEMASK    = $000000FF; // Mask for size of single item

  DU_MAINPART    = (DU_TYPEMASK or DU_COUNTMASK or DU_SIZEMASK);

  DUMP_HEXA8     = $00010801; // Hex/ASCII dump, 8 bytes per line
  DUMP_HEXA16    = $00011001; // Hex/ASCII dump, 16 bytes per line
  DUMP_HEXU8     = $00020801; // Hex/UNICODE dump, 8 bytes per line
  DUMP_HEXU16    = $00021001; // Hex/UNICODE dump, 16 bytes per line
  DUMP_ASC32     = $00032001; // ASCII dump, 32 characters per line
  DUMP_ASC64     = $00034001; // ASCII dump, 64 characters per line
  DUMP_UNI16     = $00041002; // UNICODE dump, 16 characters per line
  DUMP_UNI32     = $00042002; // UNICODE dump, 32 characters per line
  DUMP_UNI64     = $00044002; // UNICODE dump, 64 characters per line
  DUMP_INT16     = $00050802; // 16-bit signed integer dump, 8 items
  DUMP_INT16S    = $00050402; // 16-bit signed integer dump, 4 items
  DUMP_INT32     = $00050404; // 32-bit signed integer dump, 4 items
  DUMP_INT32S    = $00050204; // 32-bit signed integer dump, 2 items
  DUMP_UINT16    = $00060802; // 16-bit unsigned integer dump, 8 items
  DUMP_UINT16S   = $00060402; // 16-bit unsigned integer dump, 4 items
  DUMP_UINT32    = $00060404; // 32-bit unsigned integer dump, 4 items
  DUMP_UINT32S   = $00060204; // 32-bit unsigned integer dump, 2 items
  DUMP_IHEX16    = $00070802; // 16-bit hex integer dump, 8 items
  DUMP_IHEX16S   = $00070402; // 16-bit hex integer dump, 4 items
  DUMP_IHEX32    = $00070404; // 32-bit hex integer dump, 4 items
  DUMP_IHEX32S   = $00070204; // 32-bit hex integer dump, 2 items
  DUMP_FLOAT32   = $00080404; // 32-bit floats, 4 items
  DUMP_FLOAT32S  = $00080104; // 32-bit floats, 1 item
  DUMP_FLOAT64   = $00080208; // 64-bit floats, 2 items
  DUMP_FLOAT64S  = $00080108; // 64-bit floats, 1 item
  DUMP_FLOAT80   = $0008010A; // 80-bit floats
  DUMP_ADDR      = $00090104; // Address dump
  DUMP_ADDRASC   = $000A0104; // Address dump with ASCII text
  DUMP_ADDRUNI   = $000B0104; // Address dump with UNICODE text
  DUMP_DISASM    = $000C0110; // Disassembly (max. 16 bytes per cmd)
  DUMP_DECODE    = $000D0110; // Decoded data (max. 16 bytes per line)

  // Types of dump menu in t_dump.menutype.
  DMT_FIXTYPE    = $00000001; // Fixed dump type, no change
  DMT_STRUCT     = $00000002; // Dump of the structure
  DMT_CPUMASK    = $00070000; // Dump belongs to CPU window
  DMT_CPUDASM    = $00010000; // This is CPU Disassembler pane
  DMT_CPUDUMP    = $00020000; // This is CPU Dump pane
  DMT_CPUSTACK   = $00040000; // This is CPU Stack pane

  // Modes of Scrolldumpwindow().
  SD_REALIGN     = $01; // Realign on specified address
  SD_CENTERY     = $02; // Center destination vertically

  // Modes of t_dump.dumpselfunc() and Reportdumpselection().
  SCH_SEL0       = $01; // t_dump.sel0 changed
  SCH_SEL1       = $02; // t_dump.sel1 changed

  // Modes of Copydumpselection().
  CDS_TITLES     = $00000001;       // Prepend window name and column titles
  CDS_NOGRAPH    = $00000002;       // Replace graphical symbols by spaces

// Constants used for scrolling and selection.
	MOVETOP        = $8000;           // Move selection to top of table
	MOVEBOTTOM     = $7FFF;           // Move selection to bottom of table

	DF_CACHESIZE   = (-4);            // Request for draw cache size
	DF_FILLCACHE   = (-3);            // Request to fill draw cache
	DF_FREECACHE   = (-2);            // Request to free cached resources
	DF_NEWROW      = (-1);            // Request to start new row in window

// Reasons why t_table.tableselfunc() was called.
	TSC_KEY        = 1;               // Keyboard key pressed
	TSC_MOUSE      = 2;               // Selection changed by mouse
	TSC_CALL       = 3;               // Call to selection move function

  TABLE_USERDEF  = $00000001;      // User-drawn table
  TABLE_STDSCR   = $00000002;      // User-drawn but standard scrolling
  TABLE_SIMPLE   = $00000004;      // Non-sorted, address is line number
  TABLE_DIR      = $00000008;      // Bottom-to-top table
  TABLE_COLSEL   = $00000010;      // Column-wide selection
  TABLE_BYTE     = $00000020;      // Allows for bytewise scrolling
  TABLE_FASTSEL  = $00000040;      // Update when selection changes
  TABLE_RIGHTSEL = $00000080;      // Right click can select items
  TABLE_RFOCUS   = $00000100;      // Right click sets focus
  TABLE_NOHSCR   = $00000200;      // Table contains no horizontal scroll
  TABLE_NOVSCR   = $00000400;      // Table contains no vertical scroll
  TABLE_NOBAR    = $00000800;      // Bar is always hidden
  TABLE_STATUS   = $00001000;      // Table contains status bar
  TABLE_MMOVX    = $00002000;      // Table is moveable by mouse in X
  TABLE_MMOVY    = $00004000;      // Table is moveable by mouse in Y
  TABLE_WANTCHAR = $00008000;      // Table processes characters
  TABLE_SAVEAPP  = $00010000;      // Save appearance to .ini
  TABLE_SAVEPOS  = $00020000;      // Save position to .ini
  TABLE_SAVECOL  = $00040000;      // Save width of columns to .ini
  TABLE_SAVESORT = $00080000;      // Save sort criterium to .ini
  TABLE_SAVECUST = $00100000;      // Save table-specific data to .ini
  TABLE_GRAYTEXT = $00200000;      // Text in table is grayed
  TABLE_NOGRAY   = $00400000;      // Text in pane is never grayed
  TABLE_UPDFOCUS = $00800000;      // Update frame pane on focus change
  TABLE_AUTOUPD  = $01000000;      // Table allows periodical autoupdate
  TABLE_SYNTAX   = $02000000;      // Table allows syntax highlighting
  TABLE_PROPWID  = $04000000;      // Column width means proportional width
  TABLE_INFRAME  = $10000000;      // Table belongs to the frame window
  TABLE_BORDER   = $20000000;      // Table has sunken border
  TABLE_KEEPOFFS = $80000000;      // Keep xshift, offset, colsel

  TABLE_MOUSEMV  = (TABLE_MMOVX or TABLE_MMOVY);
  TABLE_SAVEALL  = (TABLE_SAVEAPP or TABLE_SAVEPOS or TABLE_SAVECOL or TABLE_SAVESORT);

  DRAW_COLOR    = $0000001F;      // Mask to extract colour/bkgnd index
  // Direct colour/background pairs.
  DRAW_NORMAL   = $00000000;      // Normal text
  DRAW_HILITE   = $00000001;      // Highlighted text
  DRAW_GRAY     = $00000002;      // Grayed text
  DRAW_EIP      = $00000003;      // Actual EIP
  DRAW_BREAK    = $00000004;      // Unconditional breakpoint
  DRAW_COND     = $00000005;      // Conditional breakpoint
  DRAW_BDIS     = $00000006;      // Disabled breakpoint
  DRAW_IPBREAK  = $00000007;      // Breakpoint at actual EIP
  DRAW_AUX      = $00000008;      // Auxiliary colours
  DRAW_SELUL    = $00000009;      // Selecion and underlining
  // Indirect pairs used to highlight commands.
  DRAW_PLAIN    = $0000000C;      // Plain commands
  DRAW_JUMP     = $0000000D;      // Unconditional jump commands
  DRAW_CJMP     = $0000000E;      // Conditional jump commands
  DRAW_PUSHPOP  = $0000000F;      // PUSH/POP commands
  DRAW_CALL     = $00000010;      // CALL commands
  DRAW_RET      = $00000011;      // RET commands
  DRAW_FPU      = $00000012;      // FPU, MMX, 3DNow! and SSE commands
  DRAW_SUSPECT  = $00000013;      // Bad, system and privileged commands
  DRAW_FILL     = $00000014;      // Filling commands
  DRAW_MOD      = $00000015;      // Modified commands
  // Indirect pairs used to highlight operands.
  DRAW_IREG     = $00000018;      // General purpose registers
  DRAW_FREG     = $00000019;      // FPU, MMX and SSE registers
  DRAW_SYSREG   = $0000001A;      // Segment and system registers
  DRAW_STKMEM   = $0000001B;      // Memory accessed over ESP or EBP
  DRAW_MEM      = $0000001C;      // Any other memory
  DRAW_MCONST   = $0000001D;      // Constant pointing to memory
  DRAW_CONST    = $0000001E;      // Any other constant
  DRAW_APP      = $00000060;      // Mask to extract appearance
  DRAW_TEXT     = $00000000;      // Plain text
  DRAW_ULTEXT   = $00000020;      // Underlined text
  DRAW_GRAPH    = $00000060;      // Graphics (text consists of G_xxx)
  DRAW_SELECT   = $00000080;      // Use selection background
  DRAW_MASK     = $00000100;      // Mask in use
  DRAW_VARWIDTH = $00000200;      // Variable width possible
  DRAW_EXTSEL   = $00000800;      // Extend mask till end of column
  DRAW_TOP      = $00001000;      // Draw upper half of the two-line text
  DRAW_BOTTOM   = $00002000;      // Draw lower half of the two-line text
  DRAW_INACTIVE = $00004000;      // Gray everything except hilited text
  DRAW_RAWDATA  = $00008000;      // Don't convert glyphs and multibytes
  DRAW_NEW      = $00010000;      // Use highlighted foreground

  // Full type of predicted data.
	PST_GENMASK   = $FFFFFC00;      // Mask for ESP generation
	PST_GENINC    = $00000400;      // Increment of ESP generation
	PST_UNCERT    = $00000200;      // Uncertain, probably modified by call
	PST_NONSTACK  = $00000100;      // Not a stack, internal use only
	PST_REL       = $00000080;      // Fixup/reladdr counter of constant
	PST_BASE      = $0000007F;      // Mask for basical description
  PST_SPEC      = $00000040;      // Special contents, type in PST_GENMASK
  PST_VALID     = $00000020;      // Contents valid
  PST_ADDR      = $00000010;      // Contents is in memory
  PST_ORIG      = $00000008;      // Based on reg contents at entry point
  PST_OMASK     = $00000007;      // Mask to extract original register

  // Types of special contents when PST_SPEC is set.
  PSS_SPECMASK  = PST_GENMASK;     // Mask for type of special contents
  PSS_SEHPTR    = $00000400;      // Pointer to SEH chain

  NSTACK        = 12;              // Number of predicted stack entries
  NSTKMOD       = 24;              // Max no. of predicted stack mod addr
  NMEM          = 2;               // Number of predicted memory locations

////////////////////////////////////////////////////////////////////////////////
/////////////////////// DEBUGGING AND TRACING FUNCTIONS ////////////////////////

  NIGNORE       = 32;              // Max. no. of ignored exception ranges
  NRTPROT       = 64;              // No. of protocolled address ranges

  FP_SYSBP      = 0;               // First pause on system breakpoint
  FP_TLS        = 1;               // First pause on TLS callback, if any
  FP_ENTRY      = 2;               // First pause on program entry point
  FP_WINMAIN    = 3;               // First pause on WinMain, if known
  FP_NONE       = 4;               // Run program immediately

  AP_SYSBP      = 0;               // Attach pause on system breakpoint
  AP_CODE       = 1;               // Attach pause on program code
  AP_NONE       = 2;               // Run attached program immediately

  DP_LOADDLL    = 0;               // Loaddll pause on Loaddll entry point
  DP_ENTRY      = 1;               // Loaddll pause on DllEntryPoint()
  DP_LOADED     = 2;               // Loaddll pause after LoadLibrary()
  DP_NONE       = 3;               // Run Loaddll immediately

  DR6_SET       = $FFFF0FF0;      // DR6 bits specified as always 1
  DR6_TRAP      = $00004000;      // Single-step trap
  DR6_BD        = $00002000;      // Debug register access detected
  DR6_BHIT      = $0000000F;      // Some hardware breakpoint hit
  DR6_B3        = $00000008;      // Hardware breakpoint 3 hit
  DR6_B2        = $00000004;      // Hardware breakpoint 2 hit
  DR6_B1        = $00000002;      // Hardware breakpoint 1 hit
  DR6_B0        = $00000001;      // Hardware breakpoint 0 hit

  DR7_GD        = $00002000;      // Enable debug register protection
  DR7_SET       = $00000400;      // DR7 bits specified as always 1
  DR7_EXACT     = $00000100;      // Local exact instruction detection
  DR7_G3        = $00000080;      // Enable breakpoint 3 globally
  DR7_L3        = $00000040;      // Enable breakpoint 3 locally
  DR7_G2        = $00000020;      // Enable breakpoint 2 globally
  DR7_L2        = $00000010;      // Enable breakpoint 2 locally
  DR7_G1        = $00000008;      // Enable breakpoint 1 globally
  DR7_L1        = $00000004;      // Enable breakpoint 1 locally
  DR7_G0        = $00000002;      // Enable breakpoint 0 globally
  DR7_L0        = $00000001;      // Enable breakpoint 0 locally

  DR7_IMPORTANT = (DR7_G3 or DR7_L3 or DR7_G2 or DR7_L2 or DR7_G1 or DR7_L1 or DR7_G0 or DR7_L0);

  NCOND         = 4;               // Number of run trace conditions
  NRANGE        = 2;               // Number of memory ranges
  NCMD          = 2;               // Number of commands
  NMODLIST      = 24;              // Number of modules in pause list

// Run trace condition bits.
  RTC_COND1     = $00000001;      // Stop run trace if condition 1 is met
  RTC_COND2     = $00000002;      // Stop run trace if condition 2 is met
  RTC_COND3     = $00000004;      // Stop run trace if condition 3 is met
  RTC_COND4     = $00000008;      // Stop run trace if condition 4 is met
  RTC_CMD1      = $00000010;      // Stop run trace if command 1 matches
  RTC_CMD2      = $00000020;      // Stop run trace if command 2 matches
  RTC_INRANGE   = $00000100;      // Stop run trace if in range
  RTC_OUTRANGE  = $00000200;      // Stop run trace if out of range
  RTC_COUNT     = $00000400;      // Stop run trace if count is reached
  RTC_MEM1      = $00001000;      // Access to memory range 1
  RTC_MEM2      = $00002000;      // Access to memory range 2
  RTC_MODCMD    = $00008000;      // Attempt to execute modified command

// Run trace protocol types.
  RTL_ALL       = 0;               // Log all commands
  RTL_JUMPS     = 1;               // Taken jmp/call/ret/int + destinations
  RTL_CDEST     = 2;               // Call destinations only
  RTL_MEM       = 3;               // Access to memory

// Hit trace outside the code section.
  HTNC_RUN      = 0;               // Continue trace the same way as code
  HTNC_PAUSE    = 1;               // Pause hit trace if outside the code
  HTNC_TRACE    = 2;               // Trace command by command (run trace)

// SFX extraction mode.
  SFM_RUNTRACE  = 0;               // Use run trace to extract SFX
  SFM_HITTRACE  = 1;               // Use hit trace to extract SFX

// Modes of font usage in dialog windows, if applies.
  DFM_SYSTEM    = 0;               // Use system font
  DFM_PARENT    = 1;               // Use font of parent window
  DFM_FIXED     = 2;               // Use dlgfontindex
  DFM_FIXALL    = 3;               // Use dlgfontindex for all controls

  HEXLEN        = 1024;            // Max length of hex edit string, bytes

  NSEARCHCMD    = 128;             // Max number of assembler search models

////////////////////////////////////////////////////////////////////////////////
////////////////////////// ASSEMBLER AND DISASSEMBLER //////////////////////////

  MAXCMDSIZE    = 16;            // Maximal length of valid 8= $86 command
  MAXSEQSIZE    = 256;           // Maximal length of command sequence
  INT3          = $CC;           // Code of 1-byte INT3 breakpoint
  NOP           = $90;           // Code of 1-byte NOP command
  NOPERAND      = 4;             // Maximal allowed number of operands
  NEGLIMIT      = (-16384);      // Limit to decode offsets as negative
  DECLIMIT      = 65536;         // Limit to decode integers as decimal

  // Registers.
  REG_UNDEF     = (-1);          // Codes of general purpose registers
  REG_EAX       = 0;
  REG_ECX       = 1;
  REG_EDX       = 2;
  REG_EBX       = 3;
  REG_ESP       = 4;
  REG_EBP       = 5;
  REG_ESI       = 6;
  REG_EDI       = 7;

  REG_BYTE      = $80;            // Flag used in switch analysis

  REG_AL        = 0;              // Symbolic indices of 8-bit registers
  REG_CL        = 1;
  REG_DL        = 2;
  REG_BL        = 3;
  REG_AH        = 4;
  REG_CH        = 5;
  REG_DH        = 6;
  REG_BH        = 7;

  SEG_UNDEF     = (-1);           // Codes of segment/selector registers
  SEG_ES        = 0;
  SEG_CS        = 1;
  SEG_SS        = 2;
  SEG_DS        = 3;
  SEG_FS        = 4;
  SEG_GS        = 5;

  // Pseudoregisters, used in search for assembler commands.
  REG_R8        = NREG;            // 8-bit pseudoregister R8
  REG_R16       = NREG;            // 16-bit pseudoregister R16
  REG_R32       = NREG;            // 32-bit pseudoregister R32
  REG_ANY       = NREG;            // Pseudoregister FPUREG, MMXREG etc.
  SEG_ANY       = NREG;            // Segment pseudoregister SEG
  REG_RA        = (NREG+1);        // 32-bit semi-defined pseudoregister RA
  REG_RB        = (NREG+2);        // 32-bit semi-defined pseudoregister RB

  NPSEUDO       = (NREG+3);        // Total count of resisters & pseudoregs

//  IS_REAL(r)     ((r)<REG_R32)   // Checks for real register
//  IS_PSEUDO(r)   ((r)>=REG_R32)  // Checks for pseudoregister (undefined)
//  IS_SEMI(r)     ((r)>=REG_RA)   // Checks for semi-defined register

  D_NONE       = $00000000;      // No special features
  // General type of command, only one is allowed.
  D_CMDTYPE    = $0000001F;      // Mask to extract type of command
  D_CMD        = $00000000;      // Ordinary (none of listed below)
  D_MOV        = $00000001;      // Move to or from integer register
  D_MOVC       = $00000002;      // Conditional move to integer register
  D_SETC       = $00000003;      // Conditional set integer register
  D_TEST       = $00000004;      // Used to test data (CMP, TEST, AND...)
  D_STRING     = $00000005;      // String command with REPxxx prefix
  D_JMP        = $00000006;      // Unconditional near jump
  D_JMPFAR     = $00000007;      // Unconditional far jump
  D_JMC        = $00000008;      // Conditional jump on flags
  D_JMCX       = $00000009;      // Conditional jump on (E)CX (and flags)
  D_PUSH       = $0000000A;      // PUSH exactly 1 (d)word of data
  D_POP        = $0000000B;      // POP exactly 1 (d)word of data
  D_CALL       = $0000000C;      // Plain near call
  D_CALLFAR    = $0000000D;      // Far call
  D_INT        = $0000000E;      // Interrupt
  D_RET        = $0000000F;      // Plain near return from call
  D_RETFAR     = $00000010;      // Far return or IRET
  D_FPU        = $00000011;      // FPU command
  D_MMX        = $00000012;      // MMX instruction, incl. SSE extensions
  D_3DNOW      = $00000013;      // 3DNow! instruction
  D_SSE        = $00000014;      // SSE, SSE2, SSE3 etc. instruction
  D_IO         = $00000015;      // Accesses I/O ports
  D_SYS        = $00000016;      // Legal but useful in system code only
  D_PRIVILEGED = $00000017;      // Privileged (non-Ring3) command
  D_DATA       = $0000001C;      // Data recognized by Analyser
  D_PSEUDO     = $0000001D;      // Pseudocommand, for search models only
  D_PREFIX     = $0000001E;      // Standalone prefix
  D_BAD        = $0000001F;      // Bad or unrecognized command
  // Additional parts of the command.
  D_SIZE01     = $00000020;      // Bit = $01 in la;st cmd is data size
  D_POSTBYTE   = $00000040;      // Command continues in postbyte
  // For string commands, either long or short form can be selected.
  D_LONGFORM   = $00000080;      // Long form of string command
  // Decoding of some commands depends on data or address size.
  D_SIZEMASK   = $00000F00;      // Mask for data/address size dependence
  D_DATA16     = $00000100;      // Requires 16-bit data size
  D_DATA32     = $00000200;      // Requires 32-bit data size
  D_ADDR16     = $00000400;      // Requires 16-bit address size
  D_ADDR32     = $00000800;      // Requires 32-bit address size
  // Prefixes that command may, must or must not possess.
  D_MUSTMASK     = $0000F000;      // Mask for fixed set of prefixes
  D_NOMUST     = $00000000;      // No obligatory prefixes (default)
  D_MUST66     = $00001000;      // (SSE) Requires 66, no F2 or F3
  D_MUSTF2     = $00002000;      // (SSE) Requires F2, no 66 or F3
  D_MUSTF3     = $00003000;      // (SSE) Requires F3, no 66 or F2
  D_MUSTNONE   = $00004000;      // (MMX,SSE) Requires no 66, F2 or F3
  D_NEEDF2     = $00005000;      // (SSE) Requires F2, no F3
  D_NEEDF3     = $00006000;      // (SSE) Requires F3, no F2
  D_NOREP      = $00007000;      // Must not include F2 or F3
  D_MUSTREP    = $00008000;      // Must include F3 (REP)
  D_MUSTREPE   = $00009000;      // Must include F3 (REPE)
  D_MUSTREPNE  = $0000A000;      // Must include F2 (REPNE)
  D_LOCKABLE   = $00010000;      // Allows for F0 (LOCK, memory only)
  D_BHINT      = $00020000;      // Allows for branch hints (2E, 3E)
  // Decoding of some commands with ModRM-SIB depends whether register or memory.
  D_MEMORY     = $00040000;      // Mod field must indicate memory
  D_REGISTER   = $00080000;      // Mod field must indicate register
  // Side effects caused by command.
  D_FLAGMASK   = $00700000;      // Mask to extract modified flags
  D_NOFLAGS    = $00000000;      // Flags S,Z,P,O,C remain unchanged
  D_ALLFLAGS   = $00100000;      // Modifies flags S,Z,P,O,C
  D_FLAGZ      = $00200000;      // Modifies flag Z only
  D_FLAGC      = $00300000;      // Modifies flag C only
  D_FLAGSCO    = $00400000;      // Modifies flag C and O only
  D_FLAGD      = $00500000;      // Modifies flag D only
  D_FLAGSZPC   = $00600000;      // Modifies flags Z, P and C only (FPU)
  D_NOCFLAG    = $00700000;      // S,Z,P,O modified, C unaffected
  D_FPUMASK    = $01800000;      // Mask for effects on FPU stack
  D_FPUSAME    = $00000000;      // Doesn't rotate FPU stack (default)
  D_FPUPOP     = $00800000;      // Pops FPU stack
  D_FPUPOP2    = $01000000;      // Pops FPU stack twice
  D_FPUPUSH    = $01800000;      // Pushes FPU stack
  D_CHGESP     = $02000000;      // Command indirectly modifies ESP
  // Command features.
  D_HLADIR     = $04000000;      // Nonstandard order of operands in HLA
  D_WILDCARD   = $08000000;      // Mnemonics contains W/D wildcard ('*')
  D_COND       = $10000000;      // Conditional (action depends on flags)
  D_USESCARRY  = $20000000;      // Uses Carry flag
  D_USEMASK    = $C0000000;      // Mask to detect unusual commands
  D_RARE       = $40000000;      // Rare or obsolete in Win32 apps
  D_SUSPICIOUS = $80000000;      // Suspicious command
  D_UNDOC      = $C0000000;      // Undocumented command

  // Type of operand, only one is allowed.
  B_ARGMASK    = $000000FF;      // Mask to extract type of argument
  B_NONE       = $00000000;      // Operand absent
  B_AL         = $00000001;      // Register AL
  B_AH         = $00000002;      // Register AH
  B_AX         = $00000003;      // Register AX
  B_CL         = $00000004;      // Register CL
  B_CX         = $00000005;      // Register CX
  B_DX         = $00000006;      // Register DX
  B_DXPORT     = $00000007;      // Register DX as I/O port address
  B_EAX        = $00000008;      // Register EAX
  B_EBX        = $00000009;      // Register EBX
  B_ECX        = $0000000A;      // Register ECX
  B_EDX        = $0000000B;      // Register EDX
  B_ACC        = $0000000C;      // Accumulator (AL/AX/EAX)
  B_STRCNT     = $0000000D;      // Register CX or ECX as REPxx counter
  B_DXEDX      = $0000000E;      // Register DX or EDX in DIV/MUL
  B_BPEBP      = $0000000F;      // Register BP or EBP in ENTER/LEAVE
  B_REG        = $00000010;      // 8/16/32-bit register in Reg
  B_REG16      = $00000011;      // 16-bit register in Reg
  B_REG32      = $00000012;      // 32-bit register in Reg
  B_REGCMD     = $00000013;      // 16/32-bit register in last cmd byte
  B_REGCMD8    = $00000014;      // 8-bit register in last cmd byte
  B_ANYREG     = $00000015;      // Reg field is unused, any allowed
  B_INT        = $00000016;      // 8/16/32-bit register/memory in ModRM
  B_INT8       = $00000017;      // 8-bit register/memory in ModRM
  B_INT16      = $00000018;      // 16-bit register/memory in ModRM
  B_INT32      = $00000019;      // 32-bit register/memory in ModRM
  B_INT1632    = $0000001A;      // 16/32-bit register/memory in ModRM
  B_INT64      = $0000001B;      // 64-bit integer in ModRM, memory only
  B_INT128     = $0000001C;      // 128-bit integer in ModRM, memory only
  B_IMMINT     = $0000001D;      // 8/16/32-bit int at immediate addr
  B_INTPAIR    = $0000001E;      // Two signed 16/32 in ModRM, memory only
  B_SEGOFFS    = $0000001F;      // 16:16/16:32 absolute address in memory
  B_STRDEST    = $00000020;      // 8/16/32-bit string dest, [ES:(E)DI]
  B_STRDEST8   = $00000021;      // 8-bit string destination, [ES:(E)DI]
  B_STRSRC     = $00000022;      // 8/16/32-bit string source, [(E)SI]
  B_STRSRC8    = $00000023;      // 8-bit string source, [(E)SI]
  B_XLATMEM    = $00000024;      // 8-bit memory in XLAT, [(E)BX+AL]
  B_EAXMEM     = $00000025;      // Reference to memory addressed by [EAX]
  B_LONGDATA   = $00000026;      // Long data in ModRM, mem only
  B_ANYMEM     = $00000027;      // Reference to memory, data unimportant
  B_STKTOP     = $00000028;      // 16/32-bit int top of stack
  B_STKTOPFAR  = $00000029;      // Top of stack (16:16/16:32 far addr)
  B_STKTOPEFL  = $0000002A;      // 16/32-bit flags on top of stack
  B_STKTOPA    = $0000002B;      // 16/32-bit top of stack all registers
  B_PUSH       = $0000002C;      // 16/32-bit int push to stack
  B_PUSHRET    = $0000002D;      // 16/32-bit push of return address
  B_PUSHRETF   = $0000002E;      // 16:16/16:32-bit push of far retaddr
  B_PUSHA      = $0000002F;      // 16/32-bit push all registers
  B_EBPMEM     = $00000030;      // 16/32-bit int at [EBP]
  B_SEG        = $00000031;      // Segment register in Reg
  B_SEGNOCS    = $00000032;      // Segment register in Reg, but not CS
  B_SEGCS      = $00000033;      // Segment register CS
  B_SEGDS      = $00000034;      // Segment register DS
  B_SEGES      = $00000035;      // Segment register ES
  B_SEGFS      = $00000036;      // Segment register FS
  B_SEGGS      = $00000037;      // Segment register GS
  B_SEGSS      = $00000038;      // Segment register SS
  B_ST         = $00000039;      // 80-bit FPU register in last cmd byte
  B_ST0        = $0000003A;      // 80-bit FPU register ST0
  B_ST1        = $0000003B;      // 80-bit FPU register ST1
  B_FLOAT32    = $0000003C;      // 32-bit float in ModRM, memory only
  B_FLOAT64    = $0000003D;      // 64-bit float in ModRM, memory only
  B_FLOAT80    = $0000003E;      // 80-bit float in ModRM, memory only
  B_BCD        = $0000003F;      // 80-bit BCD in ModRM, memory only
  B_MREG8x8    = $00000040;      // MMX register as 8 8-bit integers
  B_MMX8x8     = $00000041;      // MMX reg/memory as 8 8-bit integers
  B_MMX8x8DI   = $00000042;      // MMX 8 8-bit integers at [DS:(E)DI]
  B_MREG16x4   = $00000043;      // MMX register as 4 16-bit integers
  B_MMX16x4    = $00000044;      // MMX reg/memory as 4 16-bit integers
  B_MREG32x2   = $00000045;      // MMX register as 2 32-bit integers
  B_MMX32x2    = $00000046;      // MMX reg/memory as 2 32-bit integers
  B_MREG64     = $00000047;      // MMX register as 1 64-bit integer
  B_MMX64      = $00000048;      // MMX reg/memory as 1 64-bit integer
  B_3DREG      = $00000049;      // 3DNow! register as 2 32-bit floats
  B_3DNOW      = $0000004A;      // 3DNow! reg/memory as 2 32-bit floats
  B_XMM0I32x4  = $0000004B;      // XMM0 as 4 32-bit integers
  B_XMM0I64x2  = $0000004C;      // XMM0 as 2 64-bit integers
  B_XMM0I8x16  = $0000004D;      // XMM0 as 16 8-bit integers
  B_SREGF32x4  = $0000004E;      // SSE register as 4 32-bit floats
  B_SREGF32L   = $0000004F;      // Low 32-bit float in SSE register
  B_SREGF32x2L = $00000050;      // Low 2 32-bit floats in SSE register
  B_SSEF32x4   = $00000051;      // SSE reg/memory as 4 32-bit floats
  B_SSEF32L    = $00000052;      // Low 32-bit float in SSE reg/memory
  B_SSEF32x2L  = $00000053;      // Low 2 32-bit floats in SSE reg/memory
  B_SREGF64x2  = $00000054;      // SSE register as 2 64-bit floats
  B_SREGF64L   = $00000055;      // Low 64-bit float in SSE register
  B_SSEF64x2   = $00000056;      // SSE reg/memory as 2 64-bit floats
  B_SSEF64L    = $00000057;      // Low 64-bit float in SSE reg/memory
  B_SREGI8x16  = $00000058;      // SSE register as 16 8-bit sigints
  B_SSEI8x16   = $00000059;      // SSE reg/memory as 16 8-bit sigints
  B_SSEI8x16DI = $0000005A;      // SSE 16 8-bit sigints at [DS:(E)DI]
  B_SSEI8x8L   = $0000005B;      // Low 8 8-bit ints in SSE reg/memory
  B_SSEI8x4L   = $0000005C;      // Low 4 8-bit ints in SSE reg/memory
  B_SSEI8x2L   = $0000005D;      // Low 2 8-bit ints in SSE reg/memory
  B_SREGI16x8  = $0000005E;      // SSE register as 8 16-bit sigints
  B_SSEI16x8   = $0000005F;      // SSE reg/memory as 8 16-bit sigints
  B_SSEI16x4L  = $00000060;      // Low 4 16-bit ints in SSE reg/memory
  B_SSEI16x2L  = $00000061;      // Low 2 16-bit ints in SSE reg/memory
  B_SREGI32x4  = $00000062;      // SSE register as 4 32-bit sigints
  B_SREGI32L   = $00000063;      // Low 32-bit sigint in SSE register
  B_SREGI32x2L = $00000064;      // Low 2 32-bit sigints in SSE register
  B_SSEI32x4   = $00000065;      // SSE reg/memory as 4 32-bit sigints
  B_SSEI32x2L  = $00000066;      // Low 2 32-bit sigints in SSE reg/memory
  B_SREGI64x2  = $00000067;      // SSE register as 2 64-bit sigints
  B_SSEI64x2   = $00000068;      // SSE reg/memory as 2 64-bit sigints
  B_SREGI64L   = $00000069;      // Low 64-bit sigint in SSE register
  B_EFL        = $0000006A;      // Flags register EFL
  B_FLAGS8     = $0000006B;      // Flags (low byte)
  B_OFFSET     = $0000006C;      // 16/32 const offset from next command
  B_BYTEOFFS   = $0000006D;      // 8-bit sxt const offset from next cmd
  B_FARCONST   = $0000006E;      // 16:16/16:32 absolute address constant
  B_DESCR      = $0000006F;      // 16:32 descriptor in ModRM
  B_1          = $00000070;      // Immediate constant 1
  B_CONST8     = $00000071;      // Immediate 8-bit constant
  B_CONST8_2   = $00000072;      // Immediate 8-bit const, second in cmd
  B_CONST16    = $00000073;      // Immediate 16-bit constant
  B_CONST      = $00000074;      // Immediate 8/16/32-bit constant
  B_CONSTL     = $00000075;      // Immediate 16/32-bit constant
  B_SXTCONST   = $00000076;      // Immediate 8-bit sign-extended to size
  B_CR         = $00000077;      // Control register in Reg
  B_CR0        = $00000078;      // Control register CR0
  B_DR         = $00000079;      // Debug register in Reg
  // Type modifiers, used for interpretation of contents, only one is allowed.
  B_MODMASK    = $000F0000;      // Mask to extract type modifier
  B_NONSPEC    = $00000000;      // Non-specific operand
  B_UNSIGNED   = $00010000;      // Decode as unsigned decimal
  B_SIGNED     = $00020000;      // Decode as signed decimal
  B_BINARY     = $00030000;      // Decode as binary (full hex) data
  B_BITCNT     = $00040000;      // Bit count
  B_SHIFTCNT   = $00050000;      // Shift count
  B_COUNT      = $00060000;      // General-purpose count
  B_NOADDR     = $00070000;      // Not an address
  B_JMPCALL    = $00080000;      // Near jump/call/return destination
  B_JMPCALLFAR = $00090000;      // Far jump/call/return destination
  B_STACKINC   = $000A0000;      // Unsigned stack increment/decrement
  B_PORT       = $000B0000;      // I/O port
  // Validity markers.
  B_MEMORY     = $00100000;      // Memory only, reg version different
  B_REGISTER   = $00200000;      // Register only, mem version different
  B_MEMONLY    = $00400000;      // Warn if operand in register
  B_REGONLY    = $00800000;      // Warn if operand in memory
  B_32BITONLY  = $01000000;      // Warn if 16-bit operand
  B_NOESP      = $02000000;      // ESP is not allowed
  // Miscellaneous options.
  B_SHOWSIZE   = $08000000;      // Always show argument size in disasm
  B_CHG        = $10000000;      // Changed, old contents is not used
  B_UPD        = $20000000;      // Modified using old contents
  B_PSEUDO     = $40000000;      // Pseoudooperand, not in assembler cmd
  B_NOSEG      = $80000000;      // Don't add offset of selector

  // Analysis data. Note that DEC_PBODY==DEC_PROC|DEC_PEND; this allows for
  // automatical merging of overlapping procedures. Also note that DEC_NET is
  // followed, if necessary, by a sequence of DEC_NEXTDATA and not DEC_NEXTCODE!
  DEC_TYPEMASK = $1F;            // Type of analyzed byte
  DEC_UNKNOWN  = $00;            // Not analyzed, treat as command
  DEC_NEXTCODE = $01;            // Next byte of command
  DEC_NEXTDATA = $02;            // Next byte of data
  DEC_FILLDATA = $03;            // Not recognized, treat as byte data
  DEC_INT      = $04;            // First byte of integer
  DEC_SWITCH   = $05;            // First byte of switch item or count
  DEC_DATA     = $06;            // First byte of integer data
  DEC_DB       = $07;            // First byte of byte string
  DEC_DUMP     = $08;            // First byte of byte string with dump
  DEC_ASCII    = $09;            // First byte of ASCII string
  DEC_ASCCNT   = $0A;            // Next chunk of ASCII string
  DEC_UNICODE  = $0B;            // First byte of UNICODE string
  DEC_UNICNT   = $0C;            // Next chunk of UNICODE string
  DEC_FLOAT    = $0D;            // First byte of floating number
  DEC_GUID     = $10;            // First byte of GUID
  DEC_NETCMD   = $18;            // First byte of .NET (CIL) command
  DEC_JMPNET   = $19;            // First byte of .NET at jump destination
  DEC_CALLNET  = $1A;            // First byte of .NET at call destination
  DEC_COMMAND  = $1C;            // First byte of ordinary command
  DEC_JMPDEST  = $1D;            // First byte of cmd at jump destination
  DEC_CALLDEST = $1E;            // First byte of cmd at call destination
  DEC_FILLING  = $1F;            // Command used to fill gaps
  DEC_PROCMASK = $60;            // Procedure analysis
  DEC_NOPROC   = $00;            // Outside the procedure
  DEC_PROC     = $20;            // Start of procedure
  DEC_PEND     = $40;            // End of procedure
  DEC_PBODY    = $60;            // Body of procedure
  DEC_TRACED   = $80;            // Hit when traced

	DA_TEXT        = $00000001;      // Decode command to text and comment
	DA_HILITE      = $00000002;      // Use syntax highlighting (set t_disasm)
	DA_OPCOMM      = $00000004;      // Comment operands
	DA_DUMP        = $00000008;      // Dump command to hexadecimal text
	DA_MEMORY      = $00000010;      // OK to read memory and use labels
	DA_NOIMPORT    = $00000020;      // When reading memory, hold the imports
	DA_RTLOGMEM    = $00000040;      // Use memory saved by run trace
	DA_NOSTACKP    = $00000080;      // Hide "Stack" prefix in comments
	DA_STEPINTO    = $00000100;      // Enter CALL when predicting registers
	DA_SHOWARG     = $00000200;      // Use predict if address ESP/EBP-based
	DA_NOPSEUDO    = $00000400;      // Skip pseudooperands
	DA_FORHELP     = $00000800;      // Decode operands for command help

	USEDECODE      = PByte(1);    // Request to get decoding automatically

  // Symbol decoding mode, used by Decodethreadname(), Decodeaddress() and
  // Decoderelativeoffset().
  // Bits that determine when to decode and comment name at all.
  DM_VALID       = $00000001;      // Only decode if memory exists
  DM_INMOD       = $00000002;      // Only decode if in module
  DM_SAMEMOD     = $00000004;      // Only decode if in same module
  DM_SYMBOL      = $00000008;      // Only decode if direct symbolic name
  DM_NONTRIVIAL  = $00000010;      // Only decode if nontrivial form
  // Bits that control name format.
  DM_BINARY      = $00000100;      // Don't use symbolic form
  DM_DIFBIN      = $00000200;      // No symbolic form if different module
  DM_WIDEFORM    = $00000400;      // Extended form (8 digits by hex)
  DM_CAPITAL     = $00000800;      // First letter in uppercase if possible
  DM_OFFSET      = $00001000;      // Add 'OFFSET' if data
  DM_JUMPIMP     = $00002000;      // Check if points to JMP to import
  DM_DYNAMIC     = $00004000;      // Check if points to JMP to DLL
  DM_ORDINAL     = $00008000;      // Add ordinal to thread's name
  // Bits that control whether address is preceded with module name.
  DM_NOMODNAME   = $00000000;      // Never add module name
  DM_DIFFMODNAME = $00010000;      // Add name only if different module
  DM_MODNAME     = $00020000;      // Always add module name
  // Bits that control comments.
  DM_STRING      = $00100000;      // Check if pointer to ASCII or UNICODE
  DM_STRPTR      = $00200000;      // Check if points to pointer to text
  DM_FOLLOW      = $00400000;      // Check if follows to different symbol
  DM_ENTRY       = $00800000;      // Check if unnamed entry to subroutine
  DM_EFORCE      = $01000000;      // Check if named entry, too
  DM_DIFFMOD     = $02000000;      // Check if points to different module
  DM_RELOFFS     = $04000000;      // Check if points inside subroutine

  // Standard commenting mode. Note: DM_DIFFMOD and DM_RELOFFS are not included.
  DM_COMMENT     = (DM_STRING or DM_STRPTR or DM_FOLLOW or DM_ENTRY);

  // Address decoding mode, used by Labeladdress().
  ADDR_SYMMASK   = $00000003;      // Mask to extract sym presentation mode
  ADDR_HEXSYM    = $00000000;      // Hex, followed by symbolic name
  ADDR_SYMHEX    = $00000001;      // Symbolic name, followed by hex
  ADDR_SINGLE    = $00000002;      // Symbolic name, or hex if none
  ADDR_HEXONLY   = $00000003;      // Only hexadecimal address
  ADDR_MODNAME   = $00000004;      // Add module name to symbol
  ADDR_FORCEMOD  = $00000008;      // (ADDR_SINGLE) Always add module name
  ADDR_GRAYHEX   = $00000010;      // Gray hex
  ADDR_HILSYM    = $00000020;      // Highlight symbolic name
  ADDR_NODEFMEP  = $00000100;      // Do not show <ModuleEntryPoint>
  ADDR_BREAK     = $00000200;      // Mark as unconditional breakpoint
  ADDR_CONDBRK   = $00000400;      // Mark as conditional breakpoint
  ADDR_DISBRK    = $00000800;      // Mark as disabled breakpoint
  ADDR_EIP       = $00001000;      // Mark as actual EIP
  ADDR_CHECKEIP  = $00002000;      // Mark as EIP if EIP of CPU thread
  ADDR_SHOWNULL  = $00004000;      // Display address 0

  // Mode bits and return value of Browsefilename().
  BRO_MODEMASK   = $F0000000;      // Mask to extract browsing mode
  BRO_FILE       = $00000000;      // Get file name
  BRO_EXE        = $10000000;      // Get name of executable
  BRO_TEXT       = $20000000;      // Get name of text log
  BRO_GROUP      = $30000000;      // Get one or several obj or lib files
  BRO_MULTI      = $40000000;      // Get one or several files
  BRO_SAVE       = $08000000;      // Get name in save mode
  BRO_SINGLE     = $00800000;      // Single file selected
  BRO_MULTIPLE   = $00400000;      // Multiple files selected
  BRO_APPEND     = $00080000;      // Append to existing file
  BRO_ACTUAL     = $00040000;      // Add actual contents
  BRO_TABS       = $00020000;      // Separate columns with tabs
  BRO_GROUPMASK  = $000000FF;      // Mask to extract groups
  BRO_GROUP1     = $00000001;      // Belongs to group 1
  BRO_GROUP2     = $00000002;      // Belongs to group 2
  BRO_GROUP3     = $00000004;      // Belongs to group 3
  BRO_GROUP4     = $00000008;      // Belongs to group 4

  // String decoding modes.
  DS_DIR         = 0;              // Direct quote
  DS_ASM         = 1;              // Assembler style
  DS_C           = 2;              // C style

	GWL_USR_TABLE  = 0;               // Offset to pointer to t_table

  // Custom messages.
  WM_USER        = $0400;
  WM_USER_CREATE = (WM_USER+100);
	WM_USER_HSCR   = (WM_USER+101);   // Update horizontal scroll
	WM_USER_VSCR   = (WM_USER+102);   // Update vertical scroll
	WM_USER_MOUSE  = (WM_USER+103);   // Mouse moves, set custom cursor
	WM_USER_VINC   = (WM_USER+104);   // Scroll contents of window by lines
	WM_USER_VPOS   = (WM_USER+105);   // Scroll contents of window by position
	WM_USER_VBYTE  = (WM_USER+106);   // Scroll contents of window by bytes
	WM_USER_SETS   = (WM_USER+107);   // Start selection in window
	WM_USER_CNTS   = (WM_USER+108);   // Continue selection in window
	WM_USER_MMOV   = (WM_USER+109);   // Move window's contents by mouse
	WM_USER_MOVS   = (WM_USER+110);   // Keyboard scrolling and selection
	WM_USER_KEY    = (WM_USER+111);   // Key pressed
	WM_USER_BAR    = (WM_USER+112);   // Message from bar segment as button
	WM_USER_DBLCLK = (WM_USER+113);   // Doubleclick in column
	WM_USER_SELXY  = (WM_USER+114);   // Get coordinates of selection
	WM_USER_FOCUS  = (WM_USER+115);   // Set focus to child of frame window
	WM_USER_UPD    = (WM_USER+116);   // Autoupdate contents of the window
	WM_USER_MTAB   = (WM_USER+117);   // Middle click on tab in tab parent
// Custom broadcasts and notifications.
	WM_USER_CHGALL = (WM_USER+132);   // Update all windows
	WM_USER_CHGCPU = (WM_USER+133);   // CPU thread has changed
	WM_USER_CHGMEM = (WM_USER+134);   // List of memory blocks has changed
	WM_USER_BKUP   = (WM_USER+135);   // Global backup is changed
	WM_USER_FILE   = (WM_USER+136);   // Query for file dump
	WM_USER_NAMES  = (WM_USER+137);   // Query for namelist window
	WM_USER_SAVE   = (WM_USER+138);   // Query for unsaved data
	WM_USER_CLEAN  = (WM_USER+139);   // End of process, close related windows
	WM_USER_HERE   = (WM_USER+140);   // Query for windows to restore
	WM_USER_CLOSE  = (WM_USER+141);   // Internal substitute for WM_CLOSE

////////////////////////////////////////////////////////////////////////////////
////////////////////// EXPRESSIONS, WATCHES AND INSPECTORS /////////////////////

	NEXPR          = 16;             // Max. no. of expressions in EMOD_MULTI

// Mode of expression evaluation.
	EMOD_CHKEXTRA  = $00000001;      // Report extra characters on line
	EMOD_NOVALUE   = $00000002;      // Don't convert data to text
	EMOD_NOMEMORY  = $00000004;      // Don't read debuggee's memory
	EMOD_MULTI     = $00000008;      // Allow multiple expressions

	EXPR_TYPEMASK  = $0F;            // Mask to extract type of expression
  EXPR_INVALID = $00;              // Invalid or undefined expression
  EXPR_BYTE    = $01;              // 8-bit integer byte
  EXPR_WORD    = $02;              // 16-bit integer word
  EXPR_DWORD   = $03;              // 32-bit integer doubleword
  EXPR_FLOAT4  = $04;              // 32-bit floating-point number
  EXPR_FLOAT8  = $05;              // 64-bit floating-point number
  EXPR_FLOAT10 = $06;              // 80-bit floating-point number
  EXPR_SEG     = $07;              // Segment
  EXPR_ASCII   = $08;              // Pointer to ASCII string
  EXPR_UNICODE = $09;              // Pointer to UNICODE string
  EXPR_TEXT    = $0A;              // Immediate UNICODE string
	EXPR_REG       = $10;            // Origin is register
	EXPR_SIGNED    = $20;            // Signed integer

	EXPR_SIGDWORD  = (EXPR_DWORD or EXPR_SIGNED);
{$EndRegion}

{$Region 'type'}
type
  PHINST = ^HINST;
  PHWND  = ^HWND;

  _STATUS = (                            //  Thread process status
    STAT_IDLE,                           //  0: No process to debug
    STAT_LOADING,                        //  1: Loading new process
    STAT_ATTACHING,                      //  2: Attaching to the running process
    STAT_RUNNING,                        //  3: All threads are running
    STAT_RUNTHR,                         //  4: Single thread is running
    STAT_STEPIN,                         //  5: Stepping into, single thread
    STAT_STEPOVER,                       //  6: Stepping over, single thread
    STAT_ANIMIN,                         //  7: Animating into, single thread
    STAT_ANIMOVER,                       //  8: Animating over, single thread
    STAT_TRACEIN,                        //  9: Tracing into, single thread
    STAT_TRACEOVER,                      // 10: Tracing over, single thread
    STAT_SFXRUN,                         // 11: SFX using run trace, single thread
    STAT_SFXHIT,                         // 12: SFX using hit trace, single thread
    STAT_SFXKNOWN,                       // 13: SFX to known entry, single thread
    STAT_TILLRET,                        // 14: Stepping until return, single thread
    STAT_OVERRET,                        // 15: Stepping over return, single thread
    STAT_TILLUSER,                       // 16: Stepping till user code, single thread
    STAT_PAUSING,                        // 17: Process is requested to pause
    STAT_PAUSED,                         // 18: Process paused on debugging event
    STAT_FINISHED,                       // 19: Process is terminated but in memory
    STAT_CLOSING                         // 20: Process is requested to close/detach
  );
  TStatus = _STATUS;

  TUnionUValueOfOperand = packed record
  case Integer of
    0: (u: DWORD);                       // Value of operand (integer form)
    1: (s: Integer);                     // Value of operand (signed form)
    2: (value: array[0..15] of Byte);    // Value of operand (general form)
  end;

  _OPERAND = packed record            // Description of disassembled operand
    // Description of operand.
    features: DWORD;                  // Operand features, set of OP_xxx
    arg: DWORD;                       // Operand type, set of B_xxx
    optype: Integer;                  // DEC_INT, DEC_FLOAT or DEC_UNKNOWN
    opsize: Integer;                  // Total size of data, bytes
    granularity: Integer;             // Size of element (opsize exc. MMX/SSE)
    reg: Integer;                     // REG_xxx (also ESP in POP) or REG_UNDEF
    use: DWORD;                       // List of used regs (not in address!)
    modifies: DWORD;                  // List of modified regs (not in addr!)
    // Description of memory address.
    seg: Integer;                     // Selector (SEG_xxx)
    scale: array[0..NREG - 1] of Byte; // Scales of registers in memory address
    aregs: DWORD;                     // List of registers used in address
    opconst: DWORD;                   // Constant or const part of address
    // Value of operand.
    offset: DWORD;                    // Offset to selector (usually addr)
    selector: DWORD;                  // Immediate selector in far jump/call
    addr: DWORD;                      // Address of operand in memory
    uvalue: TUnionUValueOfOperand;
    actual: array[0..16 - 1] of Byte; // Actual memory (if OP_ACTVALID)
    // Textual decoding.
    text: array[0..TEXTLEN - 1] of WideChar;    // Operand, decoded to text
    comment: array[0..TEXTLEN - 1] of WideChar; // Commented address and contents
  end;
  TOperand = _OPERAND;
  POperand = ^TOperand;

  _DISASM = packed record        // Disassembled command
    // In the case that DA_HILITE flag is set, fill these members before calling
    // Disasm(). Parameter hilitereg has priority over hiliteindex.
    hilitereg: DWORD;            // One of OP_SOMEREG if reg highlighting
    hiregindex: Integer;         // Index of register to highlight
    hiliteindex: Integer;        // Index of highlighting scheme (0: none)
    // Starting from this point, no need to initialize the members of t_disasm.
    ip: DWORD;                   // Address of first command byte
    size: DWORD;                 // Full length of command, bytes
    cmdtype: DWORD;              // Type of command, D_xxx
    exttype: DWORD;              // More features, set of DX_xxx
    prefixes: DWORD;             // List of prefixes, set of PF_xxx
    nprefix: DWORD;              // Number of prefixes, including SSE2
    memfixup: DWORD;             // Offset of first 4-byte fixup or -1
    immfixup: DWORD;             // Offset of second 4-byte fixup or -1
    errors: Integer;             // Set of DAE_xxx
    warnings: Integer;           // Set of DAW_xxx
    // Note that used registers are those which contents is necessary to create
    // result. Modified registers are those which value is changed. For example,
    // command MOV EAX,[EBX+ECX] uses EBX and ECX and modifies EAX. Command
    // ADD ESI,EDI uses ESI and EDI and modifies ESI.
    use: DWORD;                  // List of used registers
    modifies: DWORD;             // List of modified registers
    // Useful shortcuts.
    condition: Integer;          // Condition, one of DAF_xxx
    jmpaddr: DWORD;              // Jump/call destination or 0
    memconst: DWORD;             // Constant in memory address or 0
    stackinc: DWORD;             // Data size in ENTER/RETN/RETF
    // Operands.
    op: array[0..NOPERAND - 1] of TOperand;         // Operands
    // Textual decoding.
    dump: array[0..TEXTLEN - 1] of WideChar;        // Hex dump of the command
    result: array[0..TEXTLEN - 1] of WideChar;      // Fully decoded command as text
    mask: array[0..TEXTLEN - 1] of Byte;            // Mask to highlight result
    maskvalid: Integer;                             // Mask corresponds to result
    comment: array[0..TEXTLEN - 1] of WideChar;     // Comment that applies to whole command
  end;
  TDisasm = _DISASM;
  PDisasm = ^TDisasm;

  _RUN = packed record             // Run status of debugged application
    status: TStatus;               // Operation mode, one of STAT_xxx
    threadid: DWORD;               // ID of single running thread, 0 if all
    tpausing: DWORD;               // Tick count when pausing was requested
    wakestep: Integer;             // 0: wait, 1: waked, 2: warned
    eip: DWORD;                    // EIP at last debugging event
    ecx: DWORD;                    // ECX at last debugging event
    restoreint3addr: DWORD;        // Address of temporarily removed INT3
    stepoverdest: DWORD;           // Destination of STAT_STEPOVER
    updatebppage: Integer;         // Update temporarily removed bppage's
    de: TDebugEvent;               // Information from WaitForDebugEvent()
    indebugevent: Integer;         // Paused on event, threads suspended
    netevent: Integer;             // Event is from .NET debugger
    isappexception: Integer;       // Exception in application, AE_xxx
    ulastexception: DWORD;         // Last exception in application or 0
    suspended: Integer;            // Suspension counter
    suspendonpause: Integer;       // Whether first suspension on pause
    updatedebugreg: Integer;       // 1: set, -1: reset HW breakpoints
    dregmodified: Integer;         // Debug regs modified by application
  end;
  PRun = ^TRun;
  TRun = _RUN;

  _MEMFIELD = packed record          // Descriptor of memory field
    addr: DWORD;                     // Address of data in memory
    size: DWORD;                     // Data size (0 - no data)
    data: array[0..16 - 1] of Byte;  // Data
  end;
  TMemField = _MEMFIELD;
  PMemFiekd = ^TMemField;

// Thread registers.
  _REG = packed record                   // Excerpt from context
    status: DWORD;                       // Status of registers, set of RV_xxx
    threadid: DWORD;                     // ID of thread that owns registers
    ip: DWORD;                           // Instruction pointer (EIP)
    r: array[0..NREG - 1] of DWORD;      // EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI
    flags: DWORD;                        // Flags
    s: array[0..NSEG - 1] of DWORD;      // Segment registers ES,CS,SS,DS,FS,GS
    base: array[0..NSEG - 1] of DWORD;   // Segment bases
    limit: array[0..NSEG - 1] of DWORD;  // Segment limits
    big: array[0..NSEG - 1] of Byte;     // Default size (0-16, 1-32 bit)
    dummy: array[0..2 - 1] of Byte;      // Reserved, used for data alignment
    top: Integer;                        // Index of top-of-stack
    f: array[0..NREG - 1] of Double;     // Float registers, f[top] - top of stack
    tag: array[0..NREG - 1] of Byte;     // Float tags (0x3 - empty register)
    fst: DWORD;                          // FPU status word
    fcw: DWORD;                          // FPU control word
    ferrseg: DWORD;                      // Selector of last detected FPU error
    feroffs: DWORD;                      // Offset of last detected FPU error
    dr: array[0..NREG - 1] of DWORD;     // Debug registers
    lasterror: DWORD;                    // Last thread error or 0xFFFFFFFF
    ssereg: array[0..NREG - 1] of array[0..16 - 1] of Byte; // SSE registers
    mxcsr: DWORD;                        // SSE control and status register
    mem: array[0..NMEMFIELD - 1] of TMemField; // Known memory fields from run trace
  end;
  TReg = _REG;
  PReg = ^TReg;

  _THREAD = packed record          // Information about active threads
    threadid: DWORD;               // Thread identifier
    dummy: DWORD;                  // Always 1
    types: DWORD;                  // Service information, TY_xxx+THR_xxx
    ordinal: Integer;              // Thread's ordinal number (1-based)
    name: array[0..SHORTNAME - 1] of WideChar; // Short name of the thread
    thread: THandle;               // Thread handle, for OllyDbg only!
    tib: DWORD;                    // Thread Information Block
    entry:DWORD;                   // Thread entry point
    context: TContext;             // Actual context of the thread
    reg: TReg;                     // Actual contents of registers
    regvalid: Integer;             // Whether reg and context are valid
    oldreg: TReg;                  // Previous contents of registers
    oldregvalid: Integer;          // Whether oldreg is valid
    suspendrun: Integer;           // Suspended for run (0 or 1)
    suspendcount: Integer;         // Temporarily suspended (0..inf)
    suspenduser: Integer;          // Suspended by user (0 or 1)
    trapset: Integer;              // Single-step trap set by OllyDbg
    trapincontext: Integer;        // Trap is catched in exception context
    rtprotocoladdr: DWORD;         // Address of destination to protocol
    ignoreonce: Integer;           // Ignore list, IGNO_xxx
    drvalid: Integer;              // Contents of dr is valid
    dr: array[0..NREG - 1] of DWORD; // Expected state of DR0..3,7
    hwmasked: Integer;             // Temporarily masked hardware breaks
    hwreported: Integer;           // Reported breakpoint expressions
    // Thread-related information gathered by Updatethreaddata().
    hw: HWND;                      // One of windows owned by thread
    usertime: DWORD;               // Time in user mode, 100u units or -1
    systime: DWORD;                // Time in system mode, 100u units or -1
    // Thread-related information gathered by Listmemory().
    stacktop: DWORD;               // Top of thread's stack
    stackbottom: DWORD;            // Bottom of thread's stack
  end;
  TThread = _THREAD;
  PThread = ^TThread;

  _NETSTREAM = packed record            // Location of default .NET stream
    base: DWORD;                 // Base address in memory
    size: DWORD;                 // Stream size, bytes
  end;
  TNetStream = _NETSTREAM;
  PNetStream = ^TNetStream;

  _METADATA = packed record      // Descriptor of .NET MetaData table
    base: DWORD;                 // Location in memory or NULL if absent
    rowcount: DWORD;             // Number of rows or 0 if absent
    rowsize: DWORD;              // Size of single row, bytes, or 0
    nameoffs: WORD;              // Offset of name field
    namesize: WORD;              // Size of name or 0 if absent
  end;
  TMetaData = _METADATA;
  PMetaData = ^TMetaData;

  _SECTHDR = packed record      // Extract from IMAGE_SECTION_HEADER
    sectname: array[0..12 - 1] of WideChar; // Null-terminated section name
    base: DWORD;                // Address of section in memory
    size: DWORD;                // Size of section loaded into memory
    types: DWORD;               // Set of SHT_xxx
    fileoffset: DWORD;          // Offset of section in file
    rawsize: DWORD;             // Size of section in file
    characteristics: DWORD;     // Set of IMAGE_SCN_xxx
  end;
  TSectHdr = _SECTHDR;
  PSectHdr = ^TSectHdr;

	_JMP = packed record           // Descriptor of recognized jump or call
		from: DWORD;                 // Address of jump/call command
		dest: DWORD;                 // Adress of jump/call destination
		types: Byte;                 // Jump/call type, one of JT_xxx
	end;
	TJmp = _JMP;
	PJmp = ^TJmp;

	_EXE = packed record // Description of executable module
		base: DWORD;                 // Module base
		size: DWORD;                 // Module size
		path: array[0..MAX_PATH - 1] of WideChar;        // Full module path
	end;
	TExe = _EXE;
	PExe = ^TExe;

	_JMPDATA = packed record          // Jump table
		modbase: DWORD;                // Base of module owning jump table
		modsize: DWORD;                // Size of module owning jump table
		jmpdata: PJmp;                 // Jump data, sorted by source
		jmpindex: PInteger;            // Indices to jmpdata, sorted by dest
		maxjmp: Integer;               // Total number of elements in arrays
		njmp: Integer;                 // Number of used elements in arrays
		nsorted: Integer;              // Number of sorted elements in arrays
		dontsort: Integer;             // Do not sort data implicitly
		exe: PExe;                     // Pointed modules, unsorted
		maxexe: Integer;               // Allocated number of elements in exe
		nexe: Integer;                 // Number of used elements in exe
	end;
	TJmpData = _JMPDATA;
	PJmpData = ^TJmpData;

  PNestHdr = ^TNested;

	NDDEST = Procedure(p_NesThdr: PNesThdr);

	_NESTED = packed record          // Descriptor of nested data
    n: Integer;                    // Actual number of elements
		nmax: Integer;                 // Maximal number of elements
		itemsize: DWORD;               // Size of single element
		data: Pointer;                 // Ordered nested data
		version: DWORD;                // Changes on each modification
		destfunc: ^NDDEST;             // Destructor function or NULL
	end;
	TNested = _NESTED;

	_SIMPLE = packed record          // Simple data container
		heap: ^Byte;                   // Data heap
		itemsize: DWORD;               // Size of data element, bytes
    maxitem: Integer;              // Size of allocated data heap, items
		nitem: Integer;                // Actual number of data items
		sorted: Integer;               // Whether data is sorted
	end;
	TSimple = _SIMPLE;
	PSimple = ^TSimple;

	_SORTHDR = packed record         // Header of sorted data item
		addr: DWORD;                   // Base address of the entry
		size: DWORD;                   // Size of the entry
		types: DWORD;                  // Type and address extension, TY_xxx
	end;
	TSortHdr = _SORTHDR;
	PSortHdr = ^TSortHdr;
	
	_SORTHDR_NOSIZE = packed record  // Header of SDM_NOSIZE item
		addr: DWORD;                   // Base address of the entry
	end;
	TSortHdrNoSize = _SORTHDR_NOSIZE;
	PSortHdrNoSize = ^TSortHdrNoSize;

	SORTFUNC = Function(const pPrevSh, pNextSh: PSortHdr; const iColumn: Integer): Integer; cdecl;
	DESTFUNC = Procedure(pSh: PSortHdr); cdecl;

//#define AUTOARRANGE    ((SORTFUNC *)1) // Autoarrangeable sorted data

//	NBLOCK         = 2048;               // Max number of data blocks
//	BLOCKSIZE      = 1048576;            // Size of single data block, bytes

	_SORTED = packed record// Descriptor of sorted data
		n: Integer;                    // Actual number of entries
		nmax: Integer;                 // Maximal number of entries
		itemsize: DWORD;               // Size of single entry
		mode: Integer;                 // Storage mode, set of SDM_xxx
		data: Pointer;                 // Sorted data, NULL if SDM_INDEXED
		block: ^Pointer;               // NBLOCK sorted data blocks, or NULL
		nblock: Integer;               // Number of allocated blocks
		version: DWORD;                // Changes on each modification
		dataptr: ^Pointer;             // Pointers to data, sorted by address
		selected: Integer;             // Index of selected entry
		seladdr: DWORD;                // Base address of selected entry
		selsubaddr: DWORD;             // Subaddress of selected entry
    sortfunc: ^SortFunc;           // Function which sorts data or NULL
    destfunc: ^DestFunc;           // Destructor function or NULL
		sort: Integer;                 // Sorting criterium (column)
		sorted: Integer;               // Whether indexes are sorted
		sortindex: PInteger;           // Indexes, sorted by criterium
	end;
	TSorted = _SORTED;
	PSorted = ^TSorted;

  _MODULE = packed record        // Descriptor of executable module
    base: DWORD;                 // Base address of module
    size: DWORD;                 // Size of memory occupied by module
    types: DWORD;                // Service information, TY_xxx+MOD_xxx
    modname: array[0..SHORTNAME - 1] of WideChar;   // Short name of the module
    path: array[0..MAXPATH - 1] of WideChar;        // Full name of the module
    version: array[0..TEXTLEN - 1] of WideChar;     // Version of executable file
    fixupbase: DWORD;            // Base of image in executable file
    codebase: DWORD;             // Base address of module code block
    codesize: DWORD;             // Size of module code block
    entry: DWORD;                // Address of <ModuleEntryPoint> or 0
    sfxentry: DWORD;             // Address of SFX-packed entry or 0
    winmain: DWORD;              // Address of WinMain or 0
    database: DWORD;             // Base address of module data block
    edatabase: DWORD;            // Base address of export data table
    edatasize: DWORD;            // Size of export data table
    idatatable: DWORD;           // Base address of import data table
    iatbase: DWORD;              // Base of Import Address Table
    iatsize: DWORD;              // Size of IAT
    relocbase: DWORD;            // Base address of relocation table
    relocsize: DWORD;            // Size of relocation table
    resbase: DWORD;              // Base address of resources
    ressize: DWORD;              // Size of resources
    tlsbase: DWORD;              // Base address of TLS directory table
    tlssize: DWORD;              // Size of TLS directory table
    tlscallback: DWORD;          // Address of first TLS callback or 0
    netentry: DWORD;             // .NET entry (MOD_NETAPP only)
    clibase: DWORD;              // .NET CLI header base (MOD_NETAPP)
    clisize: DWORD;              // .NET CLI header base (MOD_NETAPP)
    netstr: array[0..NETSTREAM - 1] of TNetStream;   // Locations of default .NET streams
    metadata: array[0..MDTCOUNT - 1] of TMetaData;   // Descriptors of .NET MetaData tables
    sfxbase: DWORD;              // Base of memory block with SFX
    sfxsize: DWORD;              // Size of memory block with SFX
    rawhdrsize: DWORD;           // Size of PE header in file
    memhdrsize: DWORD;           // Size of PE header in memory
    nsect: Integer;              // Number of sections in the module
    sect: PSectHdr;              // Extract from section headers
    nfixup: Integer;             // Number of 32-bit fixups
    fixup: PDWORD;               // Array of 32-bit fixups
    jumps: TJmpData;             // Jumps and calls from this module
    loopnest: TNested;           // Loop brackets
    argnest: TNested;            // Call argument brackets
    predict: TSimple;            // Predicted ESP, EBP & results (sd_pred)
    strings: TSorted;            // Resource strings (t_string)
    saveudd: Integer;            // UDD-relevant data is changed
    ncallmod: Integer;           // No. of called modules (max. NCALLMOD)
    callmod: array[0..NCALLMOD - 1] of array[0..SHORTNAME - 1] of WideChar; // List of called modules
  end;
  TModule = _MODULE;
  PModule = ^TModule;

  PTable = ^TTable;
  PDump = ^TDump;
  PMenu = ^TMenu;

  TABFUNC = Function(pt: PTable; hw: HWND; msg: UInt; wp: WPARAM; lp: LPARAM): DWORD; cdecl;
  UPDATEFUNC = Function(pt: PTable): Integer; cdecl;
  DRAWFUNC = Function(arg1: PWideChar; arg2: PByte; arg3: PInteger; arg4: PTable; arg5: PSortHdr; arg6: Integer; arg7: Pointer): Integer; cdecl;
  TABSELFUNC = Procedure(pt: PTable; selected: Integer; reason: Integer); cdecl;
  DUMPSELFUNC = Procedure(arg1: PDump; mode: Integer); cdecl;
  MENUFUNC = Function(pT: PTable; pwText: PWideChar; dwIndex: DWORD; iMode: Integer): Integer; cdecl;

  _MENU = packed record            // Menu descriptor
    name: PWideChar;               // Menu command
    help: PWideChar;               // Explanation of command
    shortcutid: DWORD;             // Shortcut identifier, K_xxx
    menucmd: MENUFUNC;             // Function that executes menu command
    submenu: PMenu;                // Pointer to descriptor of popup menu
    case Boolean Of
      True:  (index: Integer);     // Argument passed to menu function
      False: (hSubMenu: HMENU);    // Handle of pulldown menu
    end;
	TMenu = _MENU;

	_BAR = packed record             // Descriptor of columns in table window
		// These variables must be filled before table window is created.
		nbar: Integer;                 // Number of columns
		visible: Integer;              // Bar visible
		name: array[0..NBAR - 1] of PWideChar;         // Column names (may be NULL)
		expl: array[0..NBAR - 1] of PWideChar;         // Explanations of columns
		mode: array[0..NBAR - 1] of Integer;           // Combination of bits BAR_xxx
		defdx: array[0..NBAR - 1] of Integer;          // Default widths of columns, chars
		// These variables are initialized by window creation function.
		dx: array[0..NBAR - 1] of Integer;             // Actual widths of columns, pixels
		captured: Integer;             // One of CAPT_xxx
		active: Integer;               // Info about where mouse was captured
		scrollvx: Integer;             // X scrolling speed
		scrollvy: Integer;             // Y scrolling speed
		prevx: Integer;                // Previous X mouse coordinate
		prevy: Integer;                // Previous Y mouse coordinate
	end;
	TBar = _BAR;
	PBar = ^TBar;
	
	_TABLE = packed record           // Window with sorted data and bar
		// These variables must be filled before table window is created.
		name: array[0..SHORTNAME - 1] of WideChar; // Name used to save/restore position
		mode: Integer;                 // Combination of bits TABLE_xxx
		sorted: TSorted;               // Sorted data
		subtype: Integer;              // User-defined subtype
		bar: TBar;                     // Description of bar
		bottomspace: Integer;          // Height of free space on the bottom
		minwidth: Integer;             // Minimal width of the table, pixels
		tabfunc: ^TABFUNC;             // Custom message function or NULL
		updatefunc: ^UPDATEFUNC;       // Data update function or NULL
		drawfunc: ^DRAWFUNC;           // Drawing function
		tableselfunc: ^TABSELFUNC;     // Callback indicating selection change
		menu: PMenu;                   // Menu descriptor
		// Table functions neither initialize nor use these variables.
		custommode: DWORD;             // User-defined custom data
		customdata: Pointer;           // Pointer to more custom data
		// These variables are initialized and/or used by table functions.
		hparent: HWND;                 // Handle of MDI container or NULL
		hstatus: HWND;                 // Handle of status bar or NULL
		hw: HWND;                      // Handle of child table or NULL
		htooltip: HWND;                // Handle of tooltip window or NULL
		font: Integer;                 // Index of font used by window
		scheme: Integer;               // Colour scheme used by window
		hilite: Integer;               // Highlighting scheme used by window
		hscroll: Integer;              // Whether horizontal scroll visible
		xshift: Integer;               // Shift in X direction, pixels
		offset: Integer;               // First displayed row
		colsel: Integer;               // Column in TABLE_COLSEL window
		version: DWORD;                // Version of sorted on last update
		timerdraw: DWORD;              // Timer redraw is active (period, ms)
		rcprev: TRect;                 // Temporary storage for old position
    rtback: Integer;
	end;
	TTable = _TABLE;

	_DUMP = packed record            // Descriptor of dump data and window
		base: DWORD;                   // Start of memory block or file
		size: DWORD;                   // Size of memory block or file
		dumptype: DWORD;               // Dump type, DU_xxx+count+size=DUMP_xxx
		menutype: DWORD;               // Menu type, set of DMT_xxx
		itemwidth: DWORD;              // Width of one item, characters
		threadid: DWORD;               // Use decoding and registers if not 0
		table: TTable;                 // Dump window is a custom table
		addr: DWORD;                   // Address of first visible byte
		sel0: DWORD;                   // Address of first selected byte
		sel1: DWORD;                   // Last selected byte (not included!)
		selstart: DWORD;               // Addr of first byte of selection start
		selend: DWORD;                 // Addr of first byte of selection end
		filecopy: PAnsiChar;           // Copy of the file or NULL
		path: array[0..MAXPATH - 1] of WideChar;        // Name of displayed file
		backup: PByte;                 // Old backup of memory/file or NULL
		strname: array[0..SHORTNAME - 1] of WideChar;   // Name of the structure to decode
		decode: PByte;                 // Local decoding information or NULL
		bkpath: array[0..MAXPATH - 1] of WideChar;      // Name of last used backup file
		relreg: Integer;               // Addresses relative to register
		reladdr: DWORD;                // Addresses relative to this address
		hilitereg: DWORD;              // One of OP_SOMEREG if reg highlighting
		hiregindex: Integer;           // Index of register to highlight
		graylimit: DWORD;              // Gray data below this address
    dumpselfunc: ^DUMPSELFUNC;     // Callback indicating change of sel0
	end;
	TDump = _DUMP;

	_MEMORY = packed record        // Descriptor of memory block
		base: DWORD;                 // Base address of memory block
		size: DWORD;                 // Size of memory block
		types: DWORD;                // Service information, TY_xxx+MEM_xxx
		special: Integer;            // Extension of type, one of MSP_xxx
		owner: DWORD;                // Address of owner of the memory
		initaccess: DWORD;           // Initial read/write access
		access: DWORD;               // Actual status and read/write access
		threadid: DWORD;             // Block belongs to this thread or 0
		sectname: array[0..SHORTNAME - 1] of WideChar;  // Null-terminated section name
		copy: PByte;                 // Copy used in CPU window or NULL
		decode: PByte;               // Decoding information or NULL
	end;
	TMemory = _MEMORY;
	PMemory = ^TMemory;

  PBlock = ^TBlock;

	_BLOCK = packed record            // Block descriptor
		index: Integer;                 // Index of pos record in the .ini file
		types: Integer;                 // One of BLK_xxx
		percent: Integer;               // Percent of block in left/top subblock
		offset: Integer;                // Offset of dividing line, pixels
		blk1: PBlock;                   // Top/left subblock, NULL if leaf
		minp1: Integer;                 // Min size of 1st subblock, pixels
		maxc1: Integer;                 // Max size of 1st subblock, chars, or 0
		blk2: PBlock;                   // Bottom/right subblock, NULL if leaf
		minp2: Integer;                 // Min size of 2nd subblock, pixels
		maxc2: Integer;                 // Max size of 2nd subblock, chars, or 0
		table: PTable;                  // Descriptor of table window
		tabname: array[0..SHORTNAME - 1] of WideChar;   // Tab (tab window only)
		title: array[0..TEXTLEN - 1] of WideChar;       // Title (tab window) or speech name
		status: array[0..TEXTLEN - 1] of WideChar;      // Status (tab window only)
	end;
	TBlock = _BLOCK;

  TWNDPROC = Function(hW: HWND; uiMsg: UInt; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;

	_FRAME = packed record            // Descriptor of frame or tab window
  // These variables must be filled before frame window is created.
		name: array[0..SHORTNAME - 1] of WideChar;      // Name used to save/restore position
		herebit: Integer;               // Must be 0 for plugins
		mode: Integer;                  // Combination of bits TABLE_xxx
		block: PBlock;                  // Pointer to block tree
		menu: PMenu;                    // Menu descriptor (tab window only)
		scheme: Integer;                // Colour scheme used by window
  // These variables are initialized by frame creation function.
		hw: HWND;                       // Handle of MDI container or NULL
		htab: HWND;                     // Handle of tab control
		htabwndproc: TWNDPROC;          // Original WndProc of tab control
		capturedtab: Integer;           // Tab captured on middle mouse click
		hstatus: HWND;                  // Handle of status bar or NULL
		active: PBlock;                 // Active table (has focus) or NULL
		captured: PBlock;               // Block that captured mouse or NULL
		captureoffset: Integer;         // Offset on mouse capture
		capturex: Integer;              // Mouse screen X coordinate on capture
		capturey: Integer;              // Mouse screen Y coordinate on capture
		title: array[0..TEXTLEN - 1] of WideChar; // Frame or tab window title
	end;
	TFrame = _FRAME;
	PFrame = ^TFrame;

  _UDDSAVE = packed record // .udd file descriptor used by plugins
    files: Pointer;        // .udd file
    uddprefix: DWORD;      // .udd tag prefix
  end;
  TUddSave = _UDDSAVE;
  PUddSave = ^TUddSave;

  _DRAWHEADER = packed record	// Draw descriptor for TABLE_USERDEF
    line: Integer;    // Line in window
    n: Integer;				// Total number of visible lines
    nextaddr: DWORD;	// First address on next line, or 0
    // Following elements can be freely used by drawing routine. They do not
    // change between calls within one table.
    addr: DWORD;			// Custom data
    s: array[0..TEXTLEN - 1] of BYTE;	// Custom data
  end;
  TDrawHeader = _DRAWHEADER;
  PDrawHeader = ^TDrawHeader;

  _STACK = packed record
    soffset: Integer;            // Offset of data on stack (signed!)
    sstate: DWORD;               // State of stack data, set of PST_xxx
    sconst: DWORD;               // Constant related to stack data
  end;
  TStack = _STACK;
  PStack = ^TStack;


  _MEM = packed record
    maddr: DWORD;                // Address of doubleword variable
    mstate: DWORD;               // State of memory, set of PST_xxx
    mconst: DWORD;               // Constant related to memory data
  end;
  TMem = _MEM;
  PMem = ^TMem;

  _PREDICT = packed record       // Prediction of execution
    addr: DWORD;                 // Predicted EIP or NULL if uncertain
    one: DWORD;                  // Must be 1
    types: DWORD;                // Type of prediction, TY_xxx/PR_xxx
    rstate: array[0..NREG - 1] of DWORD;         // State of register, set of PST_xxx
    rconst: array[0..NREG - 1] of DWORD;         // Constant related to register
    jmpstate: DWORD;             // State of EIP after jump or return
    jmpconst: DWORD;             // Constant related to jump or return
    espatpushbp: DWORD;          // Offset of ESP at PUSH EBP
    nstack: Integer;             // Number of valid stack entries
    stack: array[0..NSTACK - 1] of TStack;
    nstkmod: Integer;            // Number of valid stkmod addresses
    stkmod: array[0..NSTKMOD - 1] of DWORD;             // Addresses of stack modifications
    nmem: Integer;               // Number of valid memory entries
    mem: array[0..NMEM - 1] of TMem;
    resstate: DWORD;             // State of result of command execution
    resconst: DWORD;             // Constant related to result
  end;
  TPredict = _PREDICT;
  PPredict = ^TPredict;

  _EMU = packed record           // Parameters passed to emulation routine
    operand: array[0..NOPERAND - 1] of DWORD;    // I/O: Operands
    opsize: DWORD;               // IN:  Size of operands
    memaddr: DWORD;              // OUT: Save address, or 0 if none
    memsize: DWORD;              // OUT: Save size (1, 2 or 4 bytes)
    memdata: DWORD;              // OUT: Data to save
  end;
  TEmu = _EMU;
  PEmu = ^TEmu;

  TRACEFUNC = Procedure(arg1: PDWORD; arg2: PDWORD; arg3: PPredict; arg4: PDisasm);
  EMUFUNC = Procedure(arg1: PEmu; arg2: PReg); cdecl;

  _BINCMD = packed record        // Description of 80x86 command
    name: PWideChar;             // Symbolic name for this command
    cmdtype: DWORD;              // Command's features, set of D_xxx
    length: DWORD;               // Length of main code (before ModRM/SIB)
    mask: DWORD;                 // Mask for first 4 bytes of the command
    code: DWORD;                 // Compare masked bytes with this
    postbyte: DWORD;             // Postbyte
    arg: array[0..NOPERAND - 1] of DWORD;        // Types of arguments, set of B_xxx
    trace: ^TRACEFUNC;           // Result prediction function
    emu: ^EMUFUNC;               // Command emulation function
  end;
  TBinCmd = _BINCMD;
  PBinCmd = ^TBinCmd;

  _FONT = packed record            // Font descriptor
    logfonts: LOGFONT;             // System font description
    stockindex: Integer;           // Index for system stock fonts
    hadjtop: Integer;              // Height adjustment on top, pixels
    hadjbot: Integer;              // Height adjustment on bottom, pixels
    name: array[0..TEXTLEN - 1] of WideChar;        // Internal font name
    hfont: HFONT;                  // Font handle
    isstock: Integer;              // Don't destroy hfont, taken from stock
    isfullunicode: Integer;        // Whether UNICODE is fully supported
    width: Integer;                // Average font width
    height: Integer;               // Font height
    t_font: Integer;
  end;
  TFont = _FONT;
  PFont = ^TFont;

  _RANGE = packed record
    rmin: DWORD;                   // Low range limit
    rmax: DWORD;                   // High range limit (INCLUDED!)
  end;
  TRange = _RANGE;
  PRange = ^TRange;

  _MODOP = packed record        // Operand in assembler model
    features: Byte;             // Operand features, set of AMP_xxx
    reg: Byte;                  // (Pseudo)register operand
    scale: array[0..NPSEUDO - 1] of Byte;       // Scales of (pseudo)registers in address
    opconst: DWORD;             // Constant or const part of address
  end;
  TModOp = _MODOP;
  PModOp = ^TModOp;

// Assembler command model.
  _ASMMOD = packed record       // Description of assembled command
    code: array[0..MAXCMDSIZE - 1] of Byte; // Binary code
    mask: array[0..MAXCMDSIZE - 1] of Byte; // Mask for binary code (0: bit ignored)
    prefixes: DWORD;            // List of prefixes, set of PF_xxx
    ncode: Byte;                // Length of code w/o prefixes, bytes
    features: Byte;             // Code features, set of AMF_xxx
    postbyte: Byte;             // Postbyte (if AMF_POSTBYTE set)
    nop: Byte;                  // Number of operands (no pseudooperands)
    op: array[0..NOPERAND - 1] of TModOp; // Description of operands
  end;
  TAsmMod = _ASMMOD;
  PAsmMod = ^TAsmMod;

  _ASMLIST = packed record      // Descriptor of the sequence of models
    pasm: PAsmMod;              // Pointer to the start of the sequence
    len: Integer;               // Length of the sequence, models
    comment: array[0..TEXTLEN - 1] of WideChar; // Comment to the sequence
  end;
  TAsmList = _ASMLIST;
  PAsmList = ^TAsmList;

  _RTCOND = packed record      // Run trace break condition
    // These fields are saved to .udd data directly.
    options: Integer;          // Set of RTC_xxx
    inrange0: DWORD;           // Start of in range
    inrange1: DWORD;           // End of in range (not included)
    outrange0: DWORD;          // Start of out range
    outrange1: DWORD;          // End of out range (not included)
    count: DWORD;              // Stop count
    currcount: DWORD;          // Actual command count
    memaccess: array[0..NRANGE - 1] of Integer; // Type of access (0:R, 1:W, 2:R/W)
    memrange0: array[0..NRANGE - 1] of DWORD;   // Start of memory range
    memrange1: array[0..NRANGE - 1] of DWORD;   // End of memory range
    // These fields are saved to .udd data truncated by first null.
    cond: array[0..NCOND - 1] of array[0..TEXTLEN - 1] of WideChar;   // Conditions as text
    cmd: array[0..NCMD - 1] of array[0..TEXTLEN - 1] of WideChar;     // Matching commands
    // These fields are not saved to .udd data.
    ccomp: array[0..NCOND - 1] of array[0..TEXTLEN - 1] of Byte;      // Precompiled conditions
    validmodels: Integer;      // Valid command models, RTC_xxx
    model: array[0..NCMD - 1] of array[0..NSEARCHCMD - 1] of TAsmMod; // Command search models
    nmodel: array[0..NCMD - 1] of Integer;      // Number of slots in each model
  end;
  TRTCond = _RTCOND;
  PRTCond = ^TRTCond;

  _RTPROT = packed record      // Run trace protocol condition
    tracelogtyp: DWORD;        // Commands to protocol, one of RTL_xxx
    memrange: DWORD;           // 0x1: range 1, 0x2: range 2 active
    memaccess: array[0..NRANGE - 1] of Integer; // Type of access (0:R, 1:W, 2:R/W)
    memrange0: array[0..NRANGE - 1] of DWORD;   // Start of memory range
    memrange1: array[0..NRANGE - 1] of DWORD;   // End of memory range
    rangeactive: Integer;      // Log only commands in the range
    range: array[0..NRTPROT - 1] of TRange;     // Set of EIP ranges to protocol
  end;
  TRTProt = _RTPROT;
  PRTProt = ^TRTProt;

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// BREAKPOINTS //////////////////////////////////

  _BPOINT = packed record        // INT3 breakpoints
    addr     : DWORD;            // Address of breakpoint
    size     : DWORD;            // Must be 1
    types     : DWORD;           // Type of breakpoint, TY_xxx+BP_xxx
    fnindex  : WORD;             // Index of predefined function
    cmd      : BYTE;             // First byte of original command
    patch    : BYTE;             // Used only in .udd files
    limit    : DWORD;            // Original pass count (0 if not set)
    count    : DWORD;            // Actual pass count
  end;
  TBPoint = _BPOINT;
  PBPoint = ^TBPoint;

  _BPMEM = packed record         // Memory breakpoints
    addr     : DWORD;            // Address of breakpoint
    size     : DWORD;            // Size of the breakpoint, bytes
    types     : DWORD;           // Type of breakpoint, TY_xxx+BP_xxx
    limit    : DWORD;            // Original pass count (0 if not set)
    count    : DWORD;            // Actual pass count
  end;
  TBMem = _BPMEM;
  PBMem = ^TBMem;

  _BPPAGE = packed record        // Pages with modified attributes
    base     : DWORD;            // Base address of memory page
    size     : DWORD;            // Always PAGESIZE
    types     : DWORD;           // Set of TY_xxx+BP_ACCESSMASK
    oldaccess: DWORD;            // Initial access
    newaccess: DWORD;            // Modified (actual) access
  end;
  TBPage = _BPPAGE;
  PBPage = ^TBPage;

  _BPHARD = packed record        // Hardware breakpoints
    index    : DWORD;            // Index of the breakpoint (0..NHARD-1)
    dummy    : DWORD;            // Must be 1
    types     : DWORD;           // Type of the breakpoint, TY_xxx+BP_xxx
    addr     : DWORD;            // Address of breakpoint
    size     : DWORD;            // Size of the breakpoint, bytes
    fnindex  : Integer;          // Index of predefined function
    limit    : DWORD;            // Original pass count (0 if not set)
    count    : DWORD;            // Actual pass count
    modbase  : DWORD;            // Module base, used by .udd only
    path: array[0..MAXPATH - 1] of WideChar;        // Full module name, used by .udd only
  end;
  TBHard = _BPHARD;
  PBHard = ^TBHard;

  _ODDATA = packed record
    ///////////////////////////////// DISASSEMBLER /////////////////////////////////
    bincmd: TBinCmd;               // List of 80x86 commands

    regname: Pointer;              // Names of 8/16/32-bit registers
    segname: Pointer;              // Names of segment registers
    fpuname: Pointer;              // FPU regs (ST(n) and STn forms)
    mmxname: Pointer;              // Names of MMX/3DNow! registers
    ssename: Pointer;              // Names of SSE registers
    crname: Pointer;               // Names of control registers
    drname: Pointer;               // Names of debug registers
    sizename: Pointer;             // Data size keywords
    sizekey: Pointer;              // Keywords for immediate data
    sizeatt: Pointer;              // Keywords for immediate data, AT&T
    /////////////////////////////// OLLYDBG SETTINGS ///////////////////////////////
    ollyfile: Pointer;             // Path to OllyDbg
    ollydir: Pointer;              // OllyDbg directory w/o backslash
    systemdir: Pointer;            // Windows system directory
    plugindir: Pointer;            // Plugin data dir without backslash
    
    hollyinst: HINST;              // Current OllyDbg instance
    hwollymain: HWND;              // Handle of the main OllyDbg window
    hwclient: HWND;                // Handle of MDI client or NULL
    ottable: Pointer;              // Class of table windows
    cpufeatures: DWORD;            // CPUID feature information
    ischild: Integer;              // Whether child debugger
    
    asciicodepage: PDWORD;         // Code page to display ASCII dumps
                                   // Requires <stdio.h>
    tracefile: PDWORD;             // System log file or NULL
    restorewinpos: PDWORD;         // Restore window position & appearance
    ////////////////////////////// OLLYDBG STRUCTURES //////////////////////////////
    font: Pointer;                 // Fixed fonts used in table windows
    sysfont: TFont;                // Proportional system font
    titlefont: TFont;              // Proportional, 2x height of sysfont
    fixfont: TFont;                // Fixed system font
    color: Pointer;                // Colours used by OllyDbg
    scheme: Pointer;               // Colour schemes used in table windows
    hilite: Pointer;               // Colour schemes used for highlighting
    /////////////////////////////////// DEBUGGEE ///////////////////////////////////
    executable: Pointer;           // Path to main (.exe) file
    arguments: Pointer;            // Command line passed to debuggee

    netdbg: Integer;              // .NET debugging active
    rundll: Integer;              // Debugged file is a DLL
    process: THandle;             // Handle of Debuggee or NULL
    processid: DWORD;             // Process ID of Debuggee or 0
    mainthreadid: DWORD;          // Thread ID of main thread or 0
    run: TRun;                    // Run status of debugged application
    skipsystembp: Integer;        // First system INT3 not yet hit

    debugbreak: DWORD;            // Address of DebugBreak() in Debuggee
    dbgbreakpoint: DWORD;         // Address of DbgBreakPoint() in Debuggee
    kiuserexcept: DWORD;          // Address of KiUserExceptionDispatcher()
    zwcontinue: DWORD;            // Address of ZwContinue() in Debuggee
    uefilter: DWORD;              // Address of UnhandledExceptionFilter()
    ntqueryinfo: DWORD;           // Address of NtQueryInformationProcess()
    corexemain: DWORD;            // Address of MSCOREE:_CorExeMain()
    peblock: DWORD;               // Address of PE block in Debuggee
    kusershareddata: DWORD;       // Address of KUSER_SHARED_DATA
    userspacelimit: DWORD;        // Size of virtual process memory
    
    rtcond: TRTCond;               // Run trace break condition
    rtprot: TRTProt;               // Run trace protocol condition
    ///////////////////////////////// DATA TABLES //////////////////////////////////
    list: TTable;                  // List descriptor
    premod: TSorted;               // Preliminary module data
    module: TTable;                // Loaded modules
    aqueue: TSorted;               // Modules that are not yet analysed
    thread: TTable;                // Active threads
    memory: TTable;                // Allocated memory blocks
    win: TTable;                   // List of windows
    bpoint: TTable;                // INT3 breakpoints
    bpmem: TTable;                 // Memory breakpoints
    bppage: TSorted;               // Memory pages with changed attributes
    bphard: TTable;                // Hardware breakpoints
    watch: TTable;                 // Watch expressions
    patch: TTable;                 // List of patches from previous runs
    procdata: TSorted;             // Descriptions of analyzed procedures
    source: TTable;                // List of source files
    srccode: TTable;               // Source code
  end;
  TODData = _ODDATA;
  PODData = ^TODData;

////////////////////////////////////////////////////////////////////////////////
////////////////////// EXPRESSIONS, WATCHES AND INSPECTORS /////////////////////

  TUnionUValueOfResult = packed record
  case Integer of
    1: (data: array[0..10 -1] of Byte); // Value as set of bytes
    2: (u: DWORD);                      // Value as address or unsigned integer
    3: (l: DWORD);                      // Value as signed integer
    4: (f: Extended);                   // Value as 80-bit float
  end;

  _RESULT = packed record          // Result of expression's evaluation
    lvaltype: Integer;             // Type of expression, EXPR_xxx
    lvaladdr: DWORD;               // Address of lvalue or NULL
    datatype: Integer;             // Type of data, EXPR_xxx
    repcount: Integer;             // Repeat count (0..32, 0 means default)
    uvalue: TUnionUValueOfResult;
    value: array[0..TEXTLEN - 1] of WideChar; // Value decoded to string
  end;
  TResult = _RESULT;
  PResult = ^TResult;

  _WATCH = packed record  // Watch descriptor
    addr: DWORD;          // 0-based watch index
    size: DWORD;          // Reserved, always 1
    types: DWORD;         // Service information, TY_xxx
    expr: array[0..TEXTLEN - 1] of WideChar; // Watch expression
  end;
  TWatch = _WATCH;
  PWatch = ^TWatch;
{$EndRegion}

Function  GetODData: TODData; cdecl;
Procedure AddToLog(dwAddr: DWord; const iColour: Integer; pwFormat: PWideChar); cdecl varargs;
Function  LoadCfg(FileName, Section, Key, Format: PWideChar): Integer; cdecl varargs;
Function  SaveCfg(FileName, Section, Key, Format: PWideChar): Integer; cdecl varargs;
Function  LoadStrCfg(section, key, s: PWideChar; length: Integer): Integer; cdecl;
Function  FileSaveCfg(key, name: PWideChar): Integer; cdecl;
Function  SetInt3Breakpoint(addr, types: DWORD; fnindex, limit, count: Integer; condition, expr, exprtype: PWideChar): Integer; cdecl;
Function  RemoveInt3Breakpoint(addr, types: DWORD): Integer; cdecl;
Function  SetHardBreakpoint(index: Integer; size, types: DWORD; fnindex: Integer; addr: DWORD; limit, count: Integer; condition, expression, exprtype: PWideChar): Integer; cdecl;
Function  RemoveHardBreakpoint(index: Integer): Integer; cdecl;
Function  SetMemBreakpoint(addr, size, types: DWORD; limit, count: Integer; condition, expression, exprtype: PWideChar): Integer; cdecl;
Function  RemoveMemBreakpoint(addr: DWORD): Integer; cdecl;
Function  LabelAddress(text: PWideChar; addr, reladdr: DWORD; relreg, index: Integer; mask: PByte; select: PInteger; mode: DWORD): Integer; cdecl;
Function  CommentAddress(addr: DWORD; typelist: Integer; comment: PWideChar; len: Integer): Integer; cdecl;
Procedure SetCPU(threadid, asmaddr, dumpaddr, selsize, stackaddr: DWORD; mode: Integer); cdecl;
Function  InsertNameW(addr: DWORD; types: Integer; pwS: PWideChar): Integer; cdecl;
Function  ReadMemory(buf: Pointer; addr, size: DWORD; mode: Integer): DWORD; cdecl;
Function  GetCpuThreadId: DWORD; cdecl;
Function  FindThread(threadid: DWORD): PThread; cdecl;
Function  FindThreadByOrdinal(ordinal: Integer): PThread; cdecl;
Function  ThreadRegisters(threadid: DWORD): PReg; cdecl;
Function  DecodeThreadName(s: PWideChar; threadid: DWORD; mode: Integer): Integer; cdecl;
Procedure RegisterModifiedByUser(pthr: PThread); cdecl;
Function  FindModule(addr: DWORD): PModule; cdecl;
Function  FindModuleByName(shortname: PWideChar): PModule; cdecl;
Function  FindMainModule: PModule; cdecl;
Function  FindFileOffset(pmod: PModule; addr: DWORD): DWORD; cdecl;
Function  CopyDumpSelection(pd: PDump; mode: Integer): HGLOBAL; cdecl;
Function  FindMemory(addr: DWORD): PMemory; cdecl;
Function  GetCpuDisAsmDump: PDump; cdecl;
Function  GetCpuDisAsmSelection: DWORD; cdecl;
Function  Unicodebuffertoascii(hUnicodeBufer: HGLOBAL): HGLOBAL; cdecl;
Procedure StatusInfo(Format: PWideChar); cdecl; varargs;
Procedure StatusFlash(Format: PWideChar); cdecl; varargs;
Procedure StatusMessage(addr: DWORD; Format: PWideChar); cdecl; varargs;
Procedure StatusProgress(promille: Integer; Format: PWideChar); cdecl; varargs;
Procedure Moveprogress(promille: Integer); cdecl; varargs;
Function  WriteMemory(const buf: Pointer; addr, size: DWORD; mode: Integer): DWORD; cdecl;
Function  GetActiveFrame(pf: PFrame): PTable; cdecl;
Function  CopyTableSelection(pt: PTable; column: Integer): HGLOBAL; cdecl;
Function  CreateTableWindow(pt: PTable; nrow, ncolumn: Integer; hi: HINST; icon, title: PWideChar): HWND; cdecl;
Function  ActivateTableWindow(pt: PTable): HWND; cdecl;
Function  Disasm(cmd: PByte; cmdsize: DWORD; cmdip: DWORD; cmddec: PByte; cmdda: PDisAsm; cmdmode: Integer; cmdreg: PReg; cmdpredict: PPredict): DWORD; cdecl;
Function  FindDecode(addr: DWORD; psize: PDWORD): PByte; cdecl;
Function  DecodeRelativeOffset(addr: DWORD; addrmode: Integer; symb: PWideChar; nsymb: Integer): Integer; cdecl;
Function  DecodeAddress(addr, amod: DWORD; mode: Integer; symb: PWideChar; nsymb: Integer; comment: PWideChar): Integer; cdecl;
Function  DecodeArgLocal(ip, offs, datasize: DWORD; name: PWideChar; len: Integer): Integer; cdecl;
Function  CreateSortedData(sd: PSorted; itemsize: DWORD; nexp: Integer; sort_func: SortFunc; dest_func: DestFunc; mode: Integer): Integer; cdecl;
Function  AddSortedData(sd: PSorted; item: Pointer): Pointer; cdecl;
Procedure DeleteSortedData(sd: PSorted; addr, subaddr: DWORD); cdecl;
Function  DeleteSortedDataRange(sd: PSorted; addr0, addr1: DWORD): Integer; cdecl;
Function  ReplaceSortedDataRange(sd: PSorted; data: Pointer; n: Integer; addr0, addr1: DWORD): Integer; cdecl;
Procedure ReNumerateSortedData(sd: PSorted); cdecl;
Function  ConfirmSortedData(sd: PSorted; confirm: Integer): Integer; cdecl;
Function  DeleteNonConfirmedSortedData(sd: PSorted): Integer; cdecl;
Procedure UnmarkNewSortedData(sd: PSorted); cdecl;
Function  FindSortedData(sd: PSorted; addr, subaddr: DWORD): Pointer; cdecl;
Function  FindSortedDatarange(sd: PSorted; addr0, addr1: DWORD): Pointer; cdecl;
Function  FindSortedIndexRange(sd: PSorted; addr0, addr1: DWORD): Integer; cdecl;
Function  GetSortedBySelection(sd: PSorted; index: Integer): Pointer; cdecl;
Function  GetSortedByIndex(sd: PSorted; index: Integer): Pointer; cdecl;
Function  IsSortedInit(sd: PSorted): Integer; cdecl;
Procedure DestroySortedData(sd: PSorted); cdecl;
Function  StrCopyA(dest: PAnsiChar; n: Integer; const src: PAnsiChar): Integer; cdecl;
Function  StrCopyW(dest: PWideChar; n: Integer; const src: PWideChar): Integer; cdecl;
Function  StrLenA(const src: PAnsiChar; n: Integer): Integer; cdecl;
Function  StrLenW(const src: PWideChar; n: Integer): Integer; cdecl;
Function  HexPrintA(s: PAnsiChar; u: DWORD): Integer; cdecl;
Function  HexPrintW(s: PWideChar; u: DWORD): Integer; cdecl;
Function  HexPrint4A(s: PAnsiChar; u: DWORD): Integer; cdecl;
Function  HexPrint4W(s: PWideChar; u: DWORD): Integer; cdecl;
Function  HexPrint8A(s: PAnsiChar; u: DWORD): Integer; cdecl;
Function  HexPrint8W(s: PWideChar; u: DWORD): Integer; cdecl;
Function  SignedHexA(s: PAnsiChar; u: DWORD): Integer; cdecl;
Function  SignedHexW(s: PWideChar; u: DWORD): Integer; cdecl;
Procedure SwapMem(base: Pointer; size, i1, i2: Integer); cdecl;
Function  HexDumpA(s: PAnsiChar; code: PByte; n: Integer): Integer; cdecl;
Function  HexDumpW(s: PWideChar; code: PByte; n: Integer): Integer; cdecl;
Function  BitCount(u: DWORD): Integer; cdecl;
Procedure SetAutoUpdate(pt: PTable; autoupdate: Integer); cdecl;
Procedure UpdateTable(pt: PTable; force: Integer); cdecl;
Function  BrowseFileName(title, names, args, currdir, defext: PWideChar; hw: HWND; mode: DWORD): Integer; cdecl;
Function  BrowseDirectory(hw: HWND; comment, dir: PWideChar): Integer; cdecl;
Procedure RelativizePath(path: PWideChar); cdecl;
Procedure AbsolutizePath(path: PWideChar); cdecl;
Function  ConfirmOverWrite(path: PWideChar): Integer; cdecl;
Function  CExpression(expression: PWideChar; cexpr: PByte; nexpr: Integer; explen: PInteger; err: PWideChar; mode: DWORD): Integer; cdecl;
Function  ExpressionCount(cexpr: PByte): Integer; cdecl;
Function  EExpression(result: PResult; expl: PWideChar; cexpr: PByte; indexs: Integer; data: PByte; base, size, threadid, a, b, mode: DWORD): Integer; cdecl;
Function  Expression(result: PResult; expression: PWideChar; data: PByte; base, size, threadid, a, b, mode: DWORD): Integer; cdecl;
Function  FastExpression(result: PResult; addr: DWORD; types: Integer; threadid: DWORD): Integer; cdecl;
Function  FindLabel(addr: DWORD; name: PWideChar; firsttype: Integer): Integer; cdecl;
Function  FindNameW(addr: DWORD; types: Integer; name: PWideChar; nname: Integer): Integer; cdecl;

implementation

Function GetODData: TODData; cdecl;
var
  hmOllyDbg: HMODULE;
  ODData: TODData;
begin
  try
  	hmOllyDbg:= GetModuleHandleA(NIL);
    ZeroMemory(Pointer(@ODData),sizeof(ODData));
    
    ODData.bincmd:= PBinCmd(GetProcAddress(hmOllyDbg,'_bincmd'))^;         // List of 80x86 commands
    ODData.regname:= GetProcAddress(hmOllyDbg,'_regname');                 // Names of 8/16/32-bit registers
    ODData.segname:= GetProcAddress(hmOllyDbg,'_segname');                 // Names of segment registers
    ODData.fpuname:= GetProcAddress(hmOllyDbg,'_fpuname');                 // FPU regs (ST(n) and STn forms)
    ODData.mmxname:= GetProcAddress(hmOllyDbg,'_mmxname');                 // Names of MMX/3DNow! registers
    ODData.ssename:= GetProcAddress(hmOllyDbg,'_ssename');                 // Names of SSE registers
    ODData.crname:= GetProcAddress(hmOllyDbg,'_crname');                   // Names of control registers
    ODData.drname:= GetProcAddress(hmOllyDbg,'_drname');                   // Names of debug registers
    ODData.sizename:= GetProcAddress(hmOllyDbg,'_sizename');               // Data size keywords
    ODData.sizekey:= GetProcAddress(hmOllyDbg,'_sizekey');                 // Keywords for immediate data
    ODData.sizeatt:= GetProcAddress(hmOllyDbg,'_sizeatt');                 // Keywords for immediate data, AT&T
    /////////////////////////////// OLLYDBG SETTINGS ///////////////////////////////
    ODData.ollyfile:= GetProcAddress(hmOllyDbg,'_ollyfile');               // Path to OllyDbg
    ODData.ollydir:= GetProcAddress(hmOllyDbg,'_ollydir');                 // OllyDbg directory w/o backslash
    ODData.systemdir:= GetProcAddress(hmOllyDbg,'_systemdir');             // Windows system directory
    ODData.plugindir:= GetProcAddress(hmOllyDbg,'_plugindir');             // Plugin data dir without backslash

    ODData.hollyinst:= PHINST(GetProcAddress(hmOllyDbg,'_hollyinst'))^;    // Current OllyDbg instance
    ODData.hwollymain:= PHWND(GetProcAddress(hmOllyDbg,'_hwollymain'))^;   // Handle of the main OllyDbg window
    ODData.hwclient:= PHWND(GetProcAddress(hmOllyDbg,'_hwclient'))^;       // Handle of MDI client or NULL
    ODData.ottable:= GetProcAddress(hmOllyDbg,'_ottable');                 // Class of table windows
    ODData.cpufeatures:= PDWORD(GetProcAddress(hmOllyDbg,'_cpufeatures'))^;  // CPUID feature information
    ODData.ischild:= PINT(GetProcAddress(hmOllyDbg,'_ischild'))^;          // Whether child debugger

    ODData.asciicodepage:= GetProcAddress(hmOllyDbg,'_asciicodepage');     // Code page to display ASCII dumps
                                                                // Requires <stdio.h>
    ODData.tracefile:= GetProcAddress(hmOllyDbg,'_tracefile');             // System log file or NULL
    ODData.restorewinpos:= GetProcAddress(hmOllyDbg,'_restorewinpos');     // Restore window position & appearance
    ////////////////////////////// OLLYDBG STRUCTURES //////////////////////////////
    ODData.font:= GetProcAddress(hmOllyDbg,'_font');                       // Fixed fonts used in table windows
    ODData.sysfont:= PFont(GetProcAddress(hmOllyDbg,'_sysfont'))^;         // Proportional system font
    ODData.titlefont:= PFont(GetProcAddress(hmOllyDbg,'_titlefont'))^;     // Proportional, 2x height of sysfont
    ODData.fixfont:= PFont(GetProcAddress(hmOllyDbg,'_fixfont'))^;         // Fixed system font
    ODData.color:= GetProcAddress(hmOllyDbg,'_color');                     // Colours used by OllyDbg
    ODData.scheme:= GetProcAddress(hmOllyDbg,'_scheme');                   // Colour schemes used in table windows
    ODData.hilite:= GetProcAddress(hmOllyDbg,'_');                         // Colour schemes used for highlighting
    /////////////////////////////////// DEBUGGEE ///////////////////////////////////
    ODData.executable:= GetProcAddress(hmOllyDbg,'_executable');           // Path to main (.exe) file
    ODData.arguments:= GetProcAddress(hmOllyDbg,'_arguments');             // Command line passed to debuggee
    ODData.netdbg:= PINT(GetProcAddress(hmOllyDbg,'_netdbg'))^;                     // .NET debugging active
    ODData.rundll:= PINT(GetProcAddress(hmOllyDbg,'_rundll'))^;                     // Debugged file is a DLL
    ODData.process:= PHandle(GetProcAddress(hmOllyDbg,'_process'))^;                // Handle of Debuggee or NULL
    ODData.processid:= PDWORD(GetProcAddress(hmOllyDbg,'_processid'))^;             // Process ID of Debuggee or 0
    ODData.mainthreadid:= PDWORD(GetProcAddress(hmOllyDbg,'_mainthreadid'))^;       // Thread ID of main thread or 0
    ODData.run:= PRun(GetProcAddress(hmOllyDbg,'_run'))^;                           // Run status of debugged application
    ODData.skipsystembp:= PINT(GetProcAddress(hmOllyDbg,'_skipsystembp'))^;         // First system INT3 not yet hit
    ODData.debugbreak:= PDWORD(GetProcAddress(hmOllyDbg,'_debugbreak'))^;           // Address of DebugBreak() in Debuggee
    ODData.dbgbreakpoint:= PDWORD(GetProcAddress(hmOllyDbg,'_dbgbreakpoint'))^;     // Address of DbgBreakPoint() in Debuggee
    ODData.kiuserexcept:= PDWORD(GetProcAddress(hmOllyDbg,'_kiuserexcept'))^;       // Address of KiUserExceptionDispatcher()
    ODData.zwcontinue:= PDWORD(GetProcAddress(hmOllyDbg,'_zwcontinue'))^;           // Address of ZwContinue() in Debuggee
    ODData.uefilter:= PDWORD(GetProcAddress(hmOllyDbg,'_uefilter'))^;               // Address of UnhandledExceptionFilter()
    ODData.ntqueryinfo:= PDWORD(GetProcAddress(hmOllyDbg,'_ntqueryinfo'))^;         // Address of NtQueryInformationProcess()
    ODData.corexemain:= PDWORD(GetProcAddress(hmOllyDbg,'_corexemain'))^;           // Address of MSCOREE:_CorExeMain()
    ODData.peblock:= PDWORD(GetProcAddress(hmOllyDbg,'_peblock'))^;                 // Address of PE block in Debuggee
    ODData.kusershareddata:= PDWORD(GetProcAddress(hmOllyDbg,'_kusershareddata'))^; // Address of KUSER_SHARED_DATA
    ODData.userspacelimit:= PDWORD(GetProcAddress(hmOllyDbg,'_userspacelimit'))^;   // Size of virtual process memory
    ODData.rtcond:= PRTCond(GetProcAddress(hmOllyDbg,'_rtcond'))^;                  // Run trace break condition
    ODData.rtprot:= PRTProt(GetProcAddress(hmOllyDbg,'_rtprot'))^;                  // Run trace protocol condition
    ///////////////////////////////// DATA TABLES //////////////////////////////////
    ODData.list:= PTable(GetProcAddress(hmOllyDbg,'_list'))^;                       // List descriptor
    ODData.premod:= PSorted(GetProcAddress(hmOllyDbg,'_premod'))^;                  // Preliminary module data
    ODData.module:= PTable(GetProcAddress(hmOllyDbg,'_module'))^;                   // Loaded modules
    ODData.aqueue:= PSorted(GetProcAddress(hmOllyDbg,'_aqueue'))^;                  // Modules that are not yet analysed
    ODData.thread:= PTable(GetProcAddress(hmOllyDbg,'_thread'))^;                   // Active threads
    ODData.memory:= PTable(GetProcAddress(hmOllyDbg,'_memory'))^;                   // Allocated memory blocks
    ODData.win:= PTable(GetProcAddress(hmOllyDbg,'_win'))^;                         // List of windows
    ODData.bpoint:= PTable(GetProcAddress(hmOllyDbg,'_bpoint'))^;                   // INT3 breakpoints
    ODData.bpmem:= PTable(GetProcAddress(hmOllyDbg,'_bpmem'))^;                     // Memory breakpoints
    ODData.bppage:= PSorted(GetProcAddress(hmOllyDbg,'_bppage'))^;                  // Memory pages with changed attributes
    ODData.bphard:= PTable(GetProcAddress(hmOllyDbg,'_bphard'))^;                   // Hardware breakpoints
    ODData.watch:= PTable(GetProcAddress(hmOllyDbg,'_watch'))^;                     // Watch expressions
    ODData.patch:= PTable(GetProcAddress(hmOllyDbg,'_patch'))^;                     // List of patches from previous runs
    ODData.procdata:= PSorted(GetProcAddress(hmOllyDbg,'_procdata'))^;              // Descriptions of analyzed procedures
    ODData.source:= PTable(GetProcAddress(hmOllyDbg,'_source'))^;                   // List of source files
    ODData.srccode:= PTable(GetProcAddress(hmOllyDbg,'_srccode'))^;                 // Source code
    Result:= ODData;
    FreeLibrary(hmOllyDbg);
  except
    FillChar(ODData,SizeOf(ODData),0);
    Result:= ODData;
  end;
end;

Procedure AddToLog; cdecl; varargs; external OllyDbg name 'Addtolist';
Function  LoadCfg; cdecl; external OllyDbg name 'Getfromini';
Function  SaveCfg; cdecl; external OllyDbg name 'Writetoini';
Function  LoadStrCfg; cdecl; external OllyDbg name 'Stringfromini';
Function  FileSaveCfg; cdecl; external OllyDbg name 'Filetoini';
Function  SetInt3Breakpoint; cdecl; external OllyDbg name 'Setint3breakpoint';
Function  RemoveInt3Breakpoint; cdecl; external OllyDbg name 'Removeint3breakpoint';
Function  Sethardbreakpoint; cdecl; external OllyDbg name 'Sethardbreakpoint';
Function  RemoveHardBreakpoint; cdecl; external OllyDbg name 'Removehardbreakpoint';
Function  SetMemBreakpoint; cdecl; external OllyDbg name 'Setmembreakpoint';
Function  RemoveMemBreakpoint; cdecl; external OllyDbg name 'Removemembreakpoint';
Function  LabelAddress; cdecl; external OllyDbg name 'Labeladdress';
Function  CommentAddress; cdecl; external OllyDbg name 'Commentaddress';
Procedure SetCPU; cdecl; external OllyDbg name 'Setcpu';
Function  InsertNameW; cdecl; external OllyDbg name 'InsertnameW';
Function  ReadMemory; cdecl; external OllyDbg name 'Readmemory';
Function  WriteMemory; cdecl; external OllyDbg name 'Writememory';
Function  GetCpuThreadId; cdecl; external OllyDbg name 'Getcputhreadid';
Function  FindThread; cdecl; external OllyDbg name 'Findthread';
Function  FindThreadByOrdinal; cdecl; external OllyDbg name 'Findthreadbyordinal';
Function  ThreadRegisters; cdecl; external OllyDbg name 'Threadregisters';
Function  DecodeThreadName; cdecl; external OllyDbg name 'Decodethreadname';
Procedure RegisterModifiedByUser; cdecl; external OllyDbg name 'Registermodifiedbyuser';
Function  FindModule; cdecl; external OllyDbg name 'Findmodule';
Function  FindModuleByName; cdecl; external OllyDbg name 'Findmodulebyname';
Function  FindMainModule; cdecl; external OllyDbg name 'Findmainmodule';
Function  FindFileOffset; cdecl; external OllyDbg name 'Findfileoffset';
Function  CopyDumpSelection; cdecl; external OllyDbg name 'Copydumpselection';
Function  FindMemory; cdecl; external OllyDbg name 'Findmemory';
Function  GetCpuDisAsmDump; cdecl; external OllyDbg name 'Getcpudisasmdump';
Function  GetCpuDisAsmSelection; cdecl; external OllyDbg name 'Getcpudisasmselection';
Function  UnicodeBufferToAscii; cdecl; external OllyDbg name 'Unicodebuffertoascii';
Procedure StatusMessage; cdecl; varargs; external OllyDbg name 'Message';
Procedure StatusInfo; cdecl; varargs; external OllyDbg name 'Tempinfo';
Procedure StatusFlash; cdecl; varargs; external OllyDbg name 'Flash';
Procedure StatusProgress; cdecl; varargs; external OllyDbg name 'Progress';
Procedure MoveProgress; cdecl; varargs; external OllyDbg name 'Moveprogress';
Function  GetActiveFrame; cdecl; external OllyDbg name 'Getactiveframe';
Function  CopyTableSelection; cdecl; external OllyDbg name 'Copytableselection';
Function  CreateTableWindow; cdecl; external OllyDbg name 'Createtablewindow';
Function  ActivateTableWindow; cdecl; external OllyDbg name 'Activatetablewindow';
Function  Disasm; cdecl; external OllyDbg name 'Disasm';
Function  FindDecode; cdecl; external OllyDbg name 'Finddecode';
Function  DecodeRelativeOffset; cdecl; external OllyDbg name 'Decoderelativeoffset';
Function  DecodeAddress; cdecl; external OllyDbg name 'Decodeaddress';
Function  DecodeArgLocal; cdecl; external OllyDbg name 'Decodearglocal';
Function  CreateSortedData; cdecl; external OllyDbg name 'Createsorteddata';
Function  AddSortedData; cdecl; external OllyDbg name 'Addsorteddata';
Procedure DeleteSortedData; cdecl; external OllyDbg name 'Deletesorteddata';
Function  DeleteSortedDataRange; cdecl; external OllyDbg name 'Deletesorteddatarange';
Function  ReplaceSortedDataRange; cdecl; external OllyDbg name 'Replacesorteddatarange';
Procedure ReNumerateSortedData; cdecl; external OllyDbg name 'Renumeratesorteddata';
Function  ConfirmSortedData; cdecl; external OllyDbg name 'Confirmsorteddata';
Function  DeleteNonConfirmedSortedData; cdecl; external OllyDbg name 'Deletenonconfirmedsorteddata';
Procedure UnmarkNewSortedData; cdecl; external OllyDbg name 'Unmarknewsorteddata';
Function  FindSortedData; cdecl; external OllyDbg name 'Findsorteddata';
Function  FindSortedDatarange; cdecl; external OllyDbg name 'Findsorteddatarange';
Function  FindSortedIndexRange; cdecl; external OllyDbg name 'Findsortedindexrange';
Function  GetSortedBySelection; cdecl; external OllyDbg name 'Getsortedbyselection';
Function  IsSortedInit; cdecl; external OllyDbg name 'Issortedinit';
Function  GetSortedByIndex; cdecl; external OllyDbg name 'Getsortedbyindex';
Procedure DestroySortedData; cdecl; external OllyDbg name 'Destroysorteddata';
Function  StrCopyA; cdecl; external OllyDbg name 'StrcopyA';
Function  StrCopyW; cdecl; external OllyDbg name 'StrcopyW';
Function  StrLenA; cdecl; external OllyDbg name 'StrlenA';
Function  StrLenW; cdecl; external OllyDbg name 'StrlenW';
Function  HexPrintA; cdecl; external OllyDbg name 'HexprintA';
Function  HexPrintW; cdecl; external OllyDbg name 'HexprintW';
Function  HexPrint4A; cdecl; external OllyDbg name 'Hexprint4A';
Function  HexPrint4W; cdecl; external OllyDbg name 'Hexprint4W';
Function  HexPrint8A; cdecl; external OllyDbg name 'Hexprint8A';
Function  HexPrint8W; cdecl; external OllyDbg name 'Hexprint8W';
Function  SignedHexA; cdecl; external OllyDbg name 'SignedhexA';
Function  SignedHexW; cdecl; external OllyDbg name 'SignedhexW';
Procedure SwapMem; cdecl; external OllyDbg name 'Swapmem';
Function  HexDumpA; cdecl; external OllyDbg name 'HexdumpA';
Function  HexDumpW; cdecl; external OllyDbg name 'HexdumpW';
Function  BitCount; cdecl; external OllyDbg name 'Bitcount';
Procedure SetAutoUpdate; cdecl; external OllyDbg name 'Setautoupdate';
Procedure UpdateTable; cdecl; external OllyDbg name 'Updatetable';
Function  BrowseFileName; cdecl; external OllyDbg name 'Browsefilename';
Function  BrowseDirectory; cdecl; external OllyDbg name 'Browsedirectory';
Procedure RelativizePath; cdecl; external OllyDbg name 'Relativizepath';
Procedure AbsolutizePath; cdecl; external OllyDbg name 'Absolutizepath';
Function  ConfirmOverWrite; cdecl; external OllyDbg name 'Confirmoverwrite';
Function  CExpression; cdecl; external OllyDbg name 'Cexpression';
Function  ExpressionCount; cdecl; external OllyDbg name 'Exprcount';
Function  EExpression; cdecl; external OllyDbg name 'Eexpression';
Function  Expression; cdecl; external OllyDbg name 'Expression';
Function  FastExpression; cdecl; external OllyDbg name 'Fastexpression';
Function  FindLabel; cdecl; external OllyDbg name 'Findlabel';
Function  FindNameW; cdecl; external OllyDbg name 'FindnameW';

end.
