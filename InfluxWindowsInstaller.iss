#define ServiceName "InfluxDBService"
#define AppTitle "InfluxDB OSS"
#define AppVer "2.7.10"
#define DefaultDir "InfluxDB"
#define SourceInfluxDir ".\InfluxDB_bin"
#define SourceShawlDir ".\Shawl_bin"
#define OutputFolder ".\dist"
#define OutputShawlExecutable "{app}\Shawl\shawl.exe"
#define OutputShawlLicense "LICENSE2"
#define OutputInfluxExecutable "{app}\influxd.exe"

[Setup]
AppName={#AppTitle}
AppVersion={#AppVer}
DefaultDirName={autopf}\{#DefaultDir}
DefaultGroupName={#AppTitle}
UninstallDisplayIcon=.\Assets\influxdb.ico
OutputDir={#OutputFolder}
OutputBaseFilename={#AppTitle}_Installer
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
Source: "{#SourceInfluxDir}\*"; DestDir: "{app}\"; Flags: ignoreversion
Source: "{#SourceShawlDir}\*"; DestDir: "{app}\Shawl\"; Flags: ignoreversion
Source: "{#SourceShawlDir}\{#OutputShawlLicense}"; DestDir: "{app}\Shawl\"; Flags: ignoreversion

[Run]
Filename: "{#OutputShawlExecutable}"; Parameters: "add --name {#ServiceName} -- ""{#OutputInfluxExecutable}"""; WorkingDir: "{app}"; StatusMsg: "Registering {#ServiceName} service..."; Check: ServiceRegistrationCheck; Flags: shellexec runhidden waituntilterminated

[UninstallRun]
Filename: "sc.exe"; Parameters: "delete {#ServiceName}"; Flags: runhidden; RunOnceId: "Remove{#ServiceName}"

[Code]
var
  SecondLicensePage: TOutputMsgMemoWizardPage;
  License2AcceptedRadio: TRadioButton;
  License2NotAcceptedRadio: TRadioButton;
  StartServicePage: TInputOptionWizardPage;
  ErrorCode: Integer;

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

  StartServicePage := CreateInputOptionPage(
    wpSelectTasks,
    'Service Startup',
    'How do you want to register the InfluxDB service?',
    'Check the boxes to select the ways you want to start the service.',
    False,
    False
  );

  StartServicePage.AddEx('Manual', 0, True);
  StartServicePage.AddEx('Automatic (delayed stard)', 0, True);
  StartServicePage.Add('Start the service immediately');
  StartServicePage.Values[1] := True;
  StartServicePage.Values[2] := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = SecondLicensePage.ID then
  begin
    CheckLicense2Accepted(nil);
  end;
end;

function ServiceRegistrationCheck: Boolean;
begin
  try
    Result := True;
    if StartServicePage.Values[1] then
    begin
      if not ShellExec('', 'sc.exe', 'config {#ServiceName} start= delayed-auto', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to register the service in automatic (delayed stard) mode. Please try from the Windows services manager.', mbError, MB_OK);
        Result := False;
      end;
    end
    else
    begin
      if not ShellExec('', 'sc.exe', 'config {#ServiceName} start= demand', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to register the service in manual mode. Please try from the Windows services manager.', mbError, MB_OK);
        Result := False;
      end;
    end;

    if StartServicePage.Values[2] and Result then
      if not ShellExec('', 'sc.exe', 'start {#ServiceName}', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
      begin
        MsgBox('Error: Unable to start the service. Please try from the Windows services manager.', mbError, MB_OK);
        Result := False;
      end;
  except
      MsgBox('Error: An error occurred while registering the service.', mbError, MB_OK);
      Result := False;
  end;
end;
