unit uUpdate;

interface

uses Windows, SysUtils, WinInet;

var URL_VERSION: String = '';

Function Updater: Boolean; stdcall;
Function IsConnectedToInternet: Boolean; stdcall;

implementation

uses mrVic, uFcData, Plugin;

Function IsConnectedToInternet: Boolean; stdcall;
var lpdwFlags: DWORD;
begin
  lpdwFlags:= INTERNET_CONNECTION_MODEM or INTERNET_CONNECTION_LAN or INTERNET_CONNECTION_PROXY;
  Result:= InternetGetConnectedState(@lpdwFlags,0);
end;

Function Updater: Boolean; stdcall;
var
  i: Integer;
  Data: String;
  hFrmUpdater: HWND;
  Buffer: array[0..MAXBYTE] of WideChar;
  ClientDateTime, ServerDateTime: TDateTime;
begin
  Result:= False;

  StatusInfo('Initialize for update...');

  hFrmUpdater := FindWindowA('TfrmUpdater', NIL);
  if hFrmUpdater <> 0 then
  begin
    //MessageBoxA(hFrmUpdater, 'Updater is running!', 'Vic''s Updater', MB_ICONWARNING);
    //Exit;
  end;

  StatusInfo('Checking for Internet connection...');

  if (IsConnectedToInternet = False) then
  begin
    MessageBoxW(GetActiveWindow,
      'Please connect to Internet. You''re being not connected.',
      PLUGIN_NAME,
      MB_ICONWARNING);
    Exit;
  end;

  StatusInfo('Checking the update server...');

  uFcData.URL_ROOT  := '';
  uFcData.URL_FILES := '';
  for i := 1 to MAX_HOST do
  begin
    StatusInfo('Checking server #%d', i);
    if IsHostAvailable(URL_DOMAINS[i] + URL_ROOT_PATH) = True then
    begin
      uFcData.URL_ROOT  := uFcData.URL_DOMAINS[i] + URL_ROOT_PATH;
      uFcData.URL_FILES := uFcData.URL_ROOT + uFcData.URL_FILE_PATH;
      Break;
    end;
  end;

  if (Length(uFcData.URL_ROOT) = 0) and (i = MAX_HOST) then
  begin
    StatusInfo('All update server has been disabled...', i);
    MessageBoxA(
      hwODbg,
      'The update server has been disabled by author. Please try again later. Thanks!',
      'Vic''s Updater',
      MB_ICONWARNING
      );
    Exit;
  end;

  StatusInfo('Sever #%d is being available...', i);

  uUpdate.URL_VERSION:= uFcData.URL_ROOT + uFcData.VERSION_FILE;

  StatusInfo('Checking %s version...', PLUGIN_NAME);

  Data:= PacToStr(GetHTML(uUpdate.URL_VERSION));
  if (Length(Data) = 0) then
  begin
    MessageBoxW(GetActiveWindow,
      'The update server is not available!' + DCRLF +
      'Please report this issue to author.' + DCRLF + 'Thanks!',
      PLUGIN_NAME,
      MB_ICONERROR);
    Exit;  
  end;

  try
    ServerDateTime:= StringToDateTime(Data);
    ClientDateTime:= StringToDateTime(WideCharToString(uFcData.DATEUPDATE));
  except
    on E: EConvertError do
    begin
      MessageBoxW(GetActiveWindow,'Could not check for release time!' + DCRLF +
        'Please report this issue to author.' + DCRLF + 'Thanks!',
        PLUGIN_NAME,
        MB_ICONERROR);
      Exit;
    end;
  end;

  StatusInfo('');
  
  if (ClientDateTime = ServerDateTime) then {DateUtils.CompareDateTime(A,B)}
  begin
    ZeroMemory(@Buffer,sizeof(Buffer));
    Swprintf(Buffer,'You''re using the latest version of %s',PLUGIN_NAME);
    MessageBoxW(GetActiveWindow,Buffer,PLUGIN_NAME,MB_ICONINFORMATION);
    Exit;
  end
  else
  begin
    ZeroMemory(@Buffer,sizeof(Buffer));
    Swprintf(Buffer,
      '%s %s you''re using release at %s' + DCRLF +
      'A new version (can be a small update) release at %s' + DCRLF +
      'Would you like to update now?',
      PLUGIN_NAME,
      VERSION,
      uFcData.DATEUPDATE,
      StringToOleStr(Data));
    if (MessageBoxW(GetActiveWindow,Buffer,PLUGIN_NAME,MB_ICONQUESTION or MB_YESNO) = IDNO) then Exit;
  end;

  Result:= True;
end;

end.
