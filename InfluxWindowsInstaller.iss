#define AppId "225E5AB3-F87B-4C34-A34E-9F655DF12C4E"
#define ServiceName "InfluxDBService"
#define AppTitle "InfluxDB OSS"
#define AppVer "2.7.10"
#define SourceInfluxDir ".\InfluxDB_bin"
#define SourceShawlDir ".\Shawl_bin"
#define OutputFolder ".\dist"
#define OutputShawlExecutable "{app}\Shawl\shawl.exe"
#define OutputShawlLicense "LICENSE2"
#define OutputInfluxExecutable "{app}\influxd.exe"

[Setup]
AppId={#AppId}
AppName={#AppTitle}
AppVersion={#AppVer}
DefaultDirName={autopf}\{#AppTitle}
DefaultGroupName={#AppTitle}
UninstallDisplayIcon=.\Assets\influxdb.ico
OutputDir={#OutputFolder}
OutputBaseFilename={#AppTitle}-{#AppVer}-setup
Compression=lzma
WizardStyle=modern
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile="{#SourceInfluxDir}\LICENSE"
DisableWelcomePage=no
SetupIconFile=.\Assets\influxdb.ico
WizardImageFile=.\Assets\influxdb_large.bmp
WizardSmallImageFile=.\Assets\influxdb_small.bmp

[Files]
Source: "{#SourceInfluxDir}\*"; DestDir: "{app}\"; 
Source: "{#SourceShawlDir}\*"; DestDir: "{app}\Shawl\"; 
Source: "{#SourceShawlDir}\{#OutputShawlLicense}"; DestDir: "{app}\Shawl\"; 

[Tasks]
Name: "service_auto"; Description: "Register the service in automatic startup"; GroupDescription: "Service Configuration:"; Flags: exclusive
Name: "service_manual"; Description: "Register the service in manual startup"; GroupDescription: "Service Configuration:"; Flags: unchecked exclusive
Name: "service_start"; Description: "Start the service immediately"; GroupDescription: "Service Startup:"; 

[Run]
Filename: "{#OutputShawlExecutable}"; Parameters: "add --name {#ServiceName} -- ""{#OutputInfluxExecutable}"""; WorkingDir: "{app}"; StatusMsg: "Registering {#ServiceName} service..."; AfterInstall: ServiceRegistration; Flags: shellexec runhidden waituntilterminated

[UninstallRun]
Filename: "sc.exe"; Parameters: "delete {#ServiceName}"; Flags: runhidden; RunOnceId: "Remove{#ServiceName}"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
var
  SecondLicensePage: TOutputMsgMemoWizardPage;
  License2AcceptedRadio: TRadioButton;
  License2NotAcceptedRadio: TRadioButton;
  ErrorCode: Integer;
  IsUpdating: Boolean;
  IsRepairing: Boolean;
  
procedure UpdatePageTextsForRepair();
begin
  if IsRepairing then
  begin
    // Modify welcome page texts
    WizardForm.WelcomeLabel1.Caption := 'Riparazione di {#AppTitle}';
    WizardForm.WelcomeLabel2.Caption := 'L installazione rileva che questa versione è già presente. Proseguirà in modalità riparazione.';

    // Customize other page titles and descriptions
    WizardForm.PageTitles[wpSelectDir] := 'Seleziona la cartella di riparazione';
    WizardForm.PageDescriptions[wpSelectDir] := 'Seleziona la cartella in cui è già installato {#AppTitle} per continuare con la riparazione.';

    WizardForm.PageTitles[wpSelectProgramGroup] := 'Configura gruppo di programmi per riparazione';
    WizardForm.PageDescriptions[wpSelectProgramGroup] := 'Scegli il gruppo di programmi in cui verranno aggiornati i collegamenti per {#AppTitle}.';

    WizardForm.PageTitles[wpReady] := 'Pronto per la riparazione';
    WizardForm.PageDescriptions[wpReady] := 'Il programma è pronto per riparare {#AppTitle}. Fai clic su Avanti per continuare.';
  end;
end;  
  
function InitializeSetup: Boolean;
var 
  Version: String;
begin
  IsUpdating := False;
  IsRepairing := False;
  Result := True;
  if RegValueExists(HKEY_LOCAL_MACHINE,'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#AppId}_is1', 'DisplayVersion') then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#AppId}_is1', 'DisplayVersion', Version);
    if Version = '{#AppVer}' then
    begin
      IsRepairing := True;
    end
    else if Version > '{#AppVer}' then
    begin
      MsgBox(ExpandConstant('A newer version of {#AppTitle} is already installed. Installer version: {#AppVer}. Current version: ' + Version + '.'), mbInformation, MB_OK);
      Result := False;
    end
    else
    begin
      IsUpdating := True;
    end;
  end;
end;

procedure CheckLicense2Accepted(Sender: TObject);
begin
  WizardForm.NextButton.Enabled := License2AcceptedRadio.Checked;
end;

function CloneLicenseRadioButton(Source: TRadioButton): TRadioButton;
begin
  Result := TRadioButton.Create(WizardForm);
  Result.Parent := SecondLicensePage.Surface;
  Result.Caption := Source.Caption;
  Result.Left := Source.Left;
  Result.Top := Source.Top;
  Result.Width := Source.Width;
  Result.Height := Source.Height;
  Result.Anchors := Source.Anchors;
  Result.OnClick := @CheckLicense2Accepted;
end;

procedure InitializeWizard();
var
  LicenseFileName: string;
  LicenseFilePath: string;
begin
  SecondLicensePage := CreateOutputMsgMemoPage(wpLicense, SetupMessage(msgWizardLicense), SetupMessage(msgLicenseLabel), SetupMessage(msgLicenseLabel3), '');
  SecondLicensePage.RichEditViewer.Height := WizardForm.LicenseMemo.Height;

  LicenseFileName := '{#OutputShawlLicense}';
  ExtractTemporaryFile(LicenseFileName);
  LicenseFilePath := ExpandConstant('{tmp}\' + LicenseFileName);
  SecondLicensePage.RichEditViewer.Lines.LoadFromFile(LicenseFilePath);
  DeleteFile(LicenseFilePath);

  License2AcceptedRadio := CloneLicenseRadioButton(WizardForm.LicenseAcceptedRadio);
  License2NotAcceptedRadio := CloneLicenseRadioButton(WizardForm.LicenseNotAcceptedRadio);
  License2NotAcceptedRadio.Checked := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = SecondLicensePage.ID then
    CheckLicense2Accepted(nil);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := ((PageID = wpSelectTasks) or (PageID = wpReady))and IsUpdating;
  Log('coa')
end;

procedure ServiceRegistration();
var
  CanContinue: Boolean;
begin
  CanContinue := not IsUpdating;
  if CanContinue then
  begin 
    if WizardIsTaskSelected('service_auto') then
    begin
      if not ShellExec('', 'sc.exe', 'config {#ServiceName} start= delayed-auto', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to set the service to automatic (delayed start). Please try from the Windows services manager.', mbError, MB_OK);
        CanContinue := False;
      end
    end
    else if WizardIsTaskSelected('service_manual') then
    begin
      if not ShellExec('', 'sc.exe', 'config {#ServiceName} start= demand', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to set the service to manual. Please try from the Windows services manager.', mbError, MB_OK);
        CanContinue := False;
      end;
    end;

    if WizardIsTaskSelected('service_start') and CanContinue then
    begin
      if not ShellExec('', 'sc.exe', 'start {#ServiceName}', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to start the service. Please try from the Windows services manager.', mbError, MB_OK);
        CanContinue := False;
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if not ShellExec('', 'sc.exe', 'stop {#ServiceName}', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      MsgBox('Error: Unable to stop the service. Please try from the Windows services manager.', mbError, MB_OK);
  end;
end;
