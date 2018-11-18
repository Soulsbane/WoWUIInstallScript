
#define MyAppName "WoW UI Installer"
#define MyAppVerName "WoW UI Installer 1.0"
#define MyAppPublisher "Azerothsoft"
#define WoWLocalInstallDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath")
#define WoWLocalAddonDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath") + "Interface\Addons"
#define WoWLocalWTFDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath") + "WTF"

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
CreateAppDir=no
Compression=lzma
SolidCompression=yes
WizardImageFile=Main.bmp
WizardSmallImageFile=Main-Small.bmp
OutputBaseFilename=WoWUIInstaller
Uninstallable=no

[Files]
Source: "{#WoWLocalWTFDir}\*.*"; DestDir: "{code:GetWoWDir}\WTF"; Flags: ignoreversion recursesubdirs
Source: "{#WoWLocalAddonDir}\*.*"; DestDir: "{code:GetWoWDir}\Interface\Addons"; Flags: ignoreversion recursesubdirs

; Add the ISSkin DLL used for skinning Inno Setup installations.
Source: "..\Common\ISSkin\ISSkin.dll"; DestDir: {app}; Flags: dontcopy
Source: "..\Common\ISSkin\Office2007.cjstyles"; DestDir: {tmp}; Flags: dontcopy

[InstallDelete]
;Type: filesandordirs; Name: "{#WoWLocalWTFDir}"


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to the [name] Setup Wizard
WelcomeLabel2=This will install your WoW Addons and WTF settings on your computer.%n%nIt is recommended that you close all other applications before continuing.

[Code]
var
RemoveSettingsPage: TInputOptionWizardPage;
//DeleteWTFFolder: Boolean;
//DeleteAddonsFolder: Boolean;


// Importing LoadSkin API from ISSkin.DLL
procedure LoadSkin(lpszPath: String; lpszIniFileName: String);
external 'LoadSkin@files:isskin.dll stdcall';

// Importing UnloadSkin API from ISSkin.DLL
procedure UnloadSkin();
external 'UnloadSkin@files:isskin.dll stdcall';

// Importing ShowWindow Windows API from User32.DLL
function ShowWindow(hWnd: Integer; uType: Integer): Integer;
external 'ShowWindow@user32.dll stdcall';

function GetWoWDir(Param: String): String;
var
wowDir: String;

begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Blizzard Entertainment\World of Warcraft', 'InstallPath', wowDir) then
  begin
    Result := wowDir;
  end
  else begin
    Result := ''
  end;
end;

procedure InitializeWizard;
begin
  RemoveSettingsPage := CreateInputOptionPage(wpWelcome,
    'Previous Settings and Addons', 'Should the WTF and Addons directories be deleted before install?',
    'Please specify if you would like either the WTF or the Addons directory to be deleted before installing, then click Next.',
    False, False);
  RemoveSettingsPage.Add('Delete WTF Directory');
  RemoveSettingsPage.Add('Delete Addon Directory');

  RemoveSettingsPage.Values[0] := True;
  RemoveSettingsPage.Values[1] := True;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
  var
    wowDir: String;
begin
    wowDir := GetWoWDir('');
  if RemoveSettingsPage.Values[0] or RemoveSettingsPage.Values[1] then
  begin
    if MsgBox('Are you sure you want to delete? Clicking OK will delete selected directories!', mbConfirmation, MB_YESNO) = IDYES then
    begin
      if RemoveSettingsPage.Values[0] then
      begin
        DelTree(wowDir + '\WTF', True, True, True);
      end;
      if RemoveSettingsPage.Values[1] then
      begin
        DelTree(wowDir + '\Interface\Addons', True, True, True);
      end;
      MsgBox('Finished deleting!', mbError, MB_OK);
    end;
  end;
end;

function InitializeSetup(): Boolean;
begin
  if GetWoWDir('') = '' then
  begin
    MsgBox('World of Warcraft installation could NOT be found!', mbError, MB_OK);
    Result := False
  end
  else begin
  	ExtractTemporaryFile('Office2007.cjstyles'); // For skinning
  	LoadSkin(ExpandConstant('{tmp}\Office2007.cjstyles'), 'NormalBlack.ini');  // And again
    Result := True
  end;
end;

// Only needed for skinning
procedure DeinitializeSetup();
begin
	ShowWindow(StrToInt(ExpandConstant('{wizardhwnd}')), 0);
	UnloadSkin();
end;




