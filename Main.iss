
;#define MyAppName "WoW UI Installer"
;#define MyAppVerName "WoW UI Installer 1.0"
;#define MyAppPublisher "Azerothsoft"
;#define WizardImageLarge "Main.bmp"
;#define WizardImageSmall "Main-Small.bmp"
;#define ExecutableName "WoWUIInstaller"

;Here you can modify what error messages say
#define WoWDirNotFoundError "Your World of Warcraft directory could not be found!. Please run World of Warcraft at least once then run this installer again!"

; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING
; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING
; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING

#define WoWLocalInstallDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath", "Not Found")
#define WoWLocalAddonDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath") + "Interface\Addons"
#define WoWLocalWTFDir ReadReg(HKEY_LOCAL_MACHINE, "SOFTWARE\Blizzard Entertainment\World of Warcraft", "InstallPath") + "WTF"

#if WoWLocalInstallDir == "Not Found"
  #error "Could not find your WoW install directory! Please run WoW then recompile this installer!"
#endif

[Setup]
#ifdef MyAppName
  AppName={#MyAppName}
#else
  AppName="WoW UI Installer"
#endif

#ifdef MyAppVerName
  AppVerName={#MyAppVerName}
#else
  AppVerName="WoW UI Installer 1.0"
#endif

#ifdef MyAppPublisher
  AppPublisher={#MyAppPublisher}
#endif

#ifdef WizardImageLarge
  WizardImageFile={#WizardImageLarge}
#endif

#ifdef WizardImageSmall
  WizardSmallImageFile={#WizardImageSmall}
#endif

#ifdef ExecutableName
  OutputBaseFilename={#ExecutableName}
#endif

CreateAppDir=no
Compression=lzma
SolidCompression=yes
Uninstallable=no

[Files]
Source: "{#WoWLocalWTFDir}\*.*"; DestDir: "{code:GetWoWDir}\WTF"; Flags: ignoreversion recursesubdirs
Source: "{#WoWLocalAddonDir}\*.*"; DestDir: "{code:GetWoWDir}\Interface\Addons"; Flags: ignoreversion recursesubdirs

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to the [name] Setup Wizard
WelcomeLabel2=This will install your WoW Addons and WTF settings on your computer.%n%nIt is recommended that you close all other applications before continuing.

[Code]
var
RemoveSettingsPage: TInputOptionWizardPage;

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
  Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Blizzard Entertainment\World of Warcraft');

  if Result = True then
  begin
	Result := DirExists(GetWoWDir(''))
  end;

  if Result = False then
	MsgBox('{#WoWDirNotFoundError}', mbError, MB_OK);
end;

procedure InitializeWizard;
begin
  RemoveSettingsPage := CreateInputOptionPage(wpWelcome,
	'Previous Settings and Addons', 'Should the WTF and Addons directories be deleted before install?',
	'Please specify if the WTF and/or the Addons directory should be deleted before installing, then click Next.',
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

