
#define MyAppName "WoW UI Installer"
#define MyAppVerName "WoW UI Installer 1.0"
#define MyAppPublisher "Azerothsoft"
#define WizardImageLarge "Main.bmp"
#define WizardImageSmall "Main-Small.bmp"
#define ExecutableName "WoWUIInstaller"

; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING
; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING
; DON'T CHANGE ANYTHING BELOW HERE IF YOU DON'T KNOW WHAT YOUR DOING

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
WizardImageFile={#WizardImageLarge}
WizardSmallImageFile={#WizardImageSmall}
OutputBaseFilename={#ExecutableName}
Uninstallable=no

[Files]
Source: "{#WoWLocalWTFDir}\*.*"; DestDir: "{code:GetWoWDir}\WTF"; Flags: ignoreversion recursesubdirs; Components: wtfinstall
Source: "{#WoWLocalAddonDir}\*.*"; DestDir: "{code:GetWoWDir}\Interface\Addons"; Flags: ignoreversion recursesubdirs; Components: addonsinstall

[InstallDelete]
Name: "{code:GetWoWDir}\WTF"; Type: filesandordirs; Components: wtfdelete
;Name: "{code:GetWoWDir}\Interface\Addons"; Type: filesandordirs; Components: addonsdelete

[Components]
Name: "wtfinstall"; Description: "Install Settings(WTF Folder)"; Types: installonly;
Name: "addonsinstall"; Description: "Install Addons"; Types: installonly;
Name: "wtfdelete"; Description: "Delete Settings Before Installation"; Types: deleteonly;
Name: "addonsdelete"; Description: "Delete Addons Before Installation"; Types: deleteonly;

[Types]
Name: "deleteandinstall"; Description: "Full Installation"
Name: "installonly"; Description: "Install Addons/Setttings Only"
Name: "deleteonly"; Description: "Delete Old Addons and Settings Only"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to the [name] Setup Wizard
WelcomeLabel2=This will install your WoW Addons and WTF settings on your computer.%n%nIt is recommended that you close all other applications before continuing.

[Code]
(*var
RemoveSettingsPage: TInputOptionWizardPage;
  *)
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

(*
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

 *)

function InitializeSetup(): Boolean;
begin
  if GetWoWDir('') = '' then
  begin
    MsgBox('World of Warcraft installation could NOT be found!', mbError, MB_OK);
    Result := False
  end
  else begin
    Result := True
  end;
end;




