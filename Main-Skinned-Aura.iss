
#define MyAppName "WoW UI Installer Aura"
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
OutputBaseFilename=WoWUIInstallerAura
Uninstallable=no

[Files]
Source: "{#WoWLocalWTFDir}\*.*"; DestDir: "{code:GetWoWDir}\WTF"; Flags: ignoreversion recursesubdirs
;Source: "{#WoWLocalAddonDir}\*.*"; DestDir: "{code:GetWoWDir}\Interface\Addons"; Flags: ignoreversion recursesubdirs

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




