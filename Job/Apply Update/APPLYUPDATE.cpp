#include <windows.h>
#include <stdio.h>
#include "CatEngine.h"

/* MinGW build EXE with static library
g++ -Wl,--subsystem,windows ApplyUpdate.cpp -lCatEngine -lpsapi -o ApplyUpdate.exe
*/

const LPCSTR APP_NAME = "[Apply Update for Vic Plug-In 2]";

typedef struct _ENUM_DATA {
    DWORD dwProcessId;
    HWND  hWnd;
} TEnumData;

BOOL CALLBACK fnEnumProc( HWND hWnd, LPARAM lParam )
{
    TEnumData& enumData = *(TEnumData*)lParam;
    DWORD dwProcessId = 0;

    GetWindowThreadProcessId( hWnd, &dwProcessId );

    if (enumData.dwProcessId == dwProcessId) {
        enumData.hWnd = hWnd;
        SetLastError(ERROR_SUCCESS);
        return false;
    }

    return true;
}

HWND FindWindowByProcessId(DWORD dwProcessId) {
    TEnumData enumData = {dwProcessId};
    if (!EnumWindows(fnEnumProc, (LPARAM)&enumData) && (GetLastError() == ERROR_SUCCESS)) {
        return enumData.hWnd;
    }

    return NULL;
}

bool catMoveDirA(const char * lpszSource, const char * lpszDestination)
{
	WIN32_FIND_DATAA wfd;
	CcatFile fsrc, fdst;
	void * pBuffer;
	DWORD dwSize;
	char szSource[MAX_PATH], szSrc[MAX_PATH], szDst[MAX_PATH];

	memset((void*)szSource, 0, MAX_PATH);
	strncpy(szSource, lpszSource, lstrlenA(lpszSource));
	strcat(szSource, "*");

	memset((void*)&wfd, 0, sizeof(wfd));
	HANDLE hFindFile = FindFirstFileA(szSource, &wfd);
	if (hFindFile == INVALID_HANDLE_VALUE) {
		return false;
	}

	do {
		if (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
			/* catMsgA("Dir : '%s'", wfd.cFileName); */
		}
		else {
			memset((void*)szSrc, 0, MAX_PATH);
			strncpy(szSrc, lpszSource, lstrlenA(lpszSource));
			strcat(szSrc, wfd.cFileName);

			memset((void*)szDst, 0, MAX_PATH);
			strncpy(szDst, lpszDestination, lstrlenA(lpszDestination));
			strcat(szDst, wfd.cFileName);

			fsrc.catInit(szSrc, fmOpenExisting, fsRead, faNormal);
			dwSize = fsrc.catGetFileSize();
			pBuffer = malloc(dwSize + 1);
			memset(pBuffer, 0, dwSize + 1);
			fsrc.catRead(pBuffer, dwSize);
			fsrc.catClose();

			fdst.catInit(szDst, fmCreateAlway, fsWrite, faNormal);
			fdst.catWrite(pBuffer, dwSize);
			fdst.catClose();

			free(pBuffer);
		}
		memset((void*)&wfd, 0, sizeof(wfd));
	} while (FindNextFileA(hFindFile, &wfd));

	return true;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	int argc = 0;
	LPSTR * argv = NULL;
	
	#ifdef _MSC_VER
		argc = __argc;
		argv = __argv;
	#endif
	
	#ifdef __MINGW32__
		argc = _argc;
		argv = _argv;
	#endif
	
	if (argc != 4) {
		// Ex.: ApplyUpdate.exe "C:\..\VicPlug-In 2\\" "C:\..\Plugins\\" 5884
		catBoxA(APP_NAME, MB_ICONERROR, "Usage: ApplyUpdate.exe [Old file path] [New file path] [PID]");
		return 1;
	}

	LPSTR szOldFile = (LPSTR)argv[1];
	LPSTR szNewFile = (LPSTR)argv[2];
	DWORD dwPID = atol(argv[3]);

	/* catBoxA(
		"[%s] %s\n\n[%s] %s",
		szOldFile,
		catDirectoryExistsA(szOldFile) ? "YES" : "NO",
		szNewFile,
		catDirectoryExistsA(szNewFile) ? "YES" : "NO"
	); */

	/* if (!catDirectoryExistsA(szOldFile)) {
		catBoxA(APP_NAME, MB_ICONERROR, "The old file '%s' does not exist!", szOldFile);
		return 2;
	}

	if (!catDirectoryExistsA(szNewFile)) {
		catBoxA(APP_NAME, MB_ICONERROR, "The new file '%s' does not exist!", szNewFile);
		return 2;
	} */

	if (!dwPID || dwPID == 0 || dwPID == 4) {
		catBoxA(APP_NAME, MB_ICONERROR, "Process ID %d is not valid!", dwPID);
		return 3;
	}

	HWND hWnd = FindWindowByProcessId(dwPID);
	if (!hWnd) {
		catBoxA(APP_NAME, MB_ICONERROR, "Could not get the Window Handle of Process[%d]!", dwPID);
		return 4;
	}

	char szTitle[MAXBYTE] = {0};
	GetWindowTextA(hWnd, szTitle, MAXBYTE);

	HANDLE hProcess = 0;
	while(true) {
		hProcess = OpenProcess(PROCESS_ALL_ACCESS, false, dwPID);
		if (hProcess != (HANDLE)0) {
			CloseHandle(hProcess);
			if (catBoxA(
				    APP_NAME,
				    MB_OKCANCEL | MB_ICONWARNING,
				    "Close your OllyDbg, wait for it closed completely\
				    and press [OK] to continue...",
				    szTitle
			    ) == IDCANCEL) {
				ExitProcess(0);
			} // else Sleep(1000); "Close your aplication which is titled '%s'
		}
		else break;
	}

	if (!catMoveDirA(szOldFile, szNewFile)) {
		catBoxA(APP_NAME, MB_ICONERROR, "Replace file is failure! (%s)", catLastErrorA());
		return 5;
	}

	if (catBoxA(
		APP_NAME,
		MB_ICONINFORMATION | MB_YESNO,
		"Update Vic Plug-In 2 is complete!\n\nDo you want to read ChangeLog?"
	) == IDYES) {
		const char * CHANGELOG = "ChangeLog.txt\0";
		char szChangeLog[MAX_PATH] = {0};

		memset((void*)szChangeLog, 0, MAX_PATH);
		sprintf((char*)szChangeLog, "%s%s", szNewFile, CHANGELOG);
		/*strncpy(szChangeLog, szNewFile, lstrlenA(szNewFile));
		strncat(szChangeLog, CHANGELOG, lstrlenA(CHANGELOG));
		catBoxA(szChangeLog);*/

		if (catFileExistsA(szChangeLog) == true) {
			const char * WORDPAD = "\\Windows NT\\Accessories\\WORDPAD.EXE\0";
			char szWordPad[MAX_PATH] = {0};
			
			memset((void*)szWordPad, 0, MAX_PATH);
			char *PFs = getenv("ProgramFiles");
			if (PFs != NULL) {
				/*strncpy(szWordPad, PFs, lstrlenA(PFs));
				strncat(szWordPad, WORDPAD, lstrlenA(WORDPAD));*/
				sprintf(szWordPad, "%s%s", PFs, WORDPAD);
				//catBoxA(szWordPad);
			}
			if (catFileExistsA(szWordPad) == true) {
				char szChangeLog_arg[MAX_PATH] = {0};
				memset((void*)szChangeLog_arg, 0, MAX_PATH);
				sprintf(szChangeLog_arg, "\"%s\"", szChangeLog);
				//catBoxA(szChangeLog_arg);
				ShellExecuteA(GetActiveWindow(), "open", szWordPad, szChangeLog_arg, szNewFile, SW_NORMAL);
			}
			else {
				ShellExecuteA(GetActiveWindow(), "open", szChangeLog, NULL, szNewFile, SW_NORMAL);
			}
		}
		else {
			MessageBoxA(GetActiveWindow(), "Sorry, ChangeLog not found!", APP_NAME, MB_ICONERROR);
		}
	}

	return 0;
}