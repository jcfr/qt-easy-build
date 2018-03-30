# Sanity checks
if(!$destDir){
  throw "'destDir' variable not set."
}
if(!($buildType -match "^(Debug|Release)$")){
  throw "'buildType' variable incorrectly set to [$buildType]. Hint: 'Release' or 'Debug' value is expected."
}
if(!$qtPlatform){
  throw "'qtPlatform' variable not set."
}
if(!($bits -match "^(32|64)$")){
  throw "'bits' variable incorrectly set to [$bits]. Hint: '32' or '64' value is expected."
}

$qtBuildScriptVersion = '6f59ca17b3bcc6b56fa636522dab6a862be0c856'

if (![System.IO.Directory]::Exists($destDir)) {[System.IO.Directory]::CreateDirectory($destDir)}

function Always-Download-File {
param (
  [string]$url,
  [string]$file
  )
  If (Test-Path $file) {
    Remove-Item $file
  }

  $securityProtocolSettingsOriginal = [System.Net.ServicePointManager]::SecurityProtocol

  try {
    # Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192), finally SSL 3.0 (48)
    # Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
    # exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
    # installed (.NET 4.5 is an in-place upgrade).
    [System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192 -bor 48
  } catch {
    Write-Warning 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5 and PowerShell v3, (2) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (3) use the Download + PowerShell method of install. See https://chocolatey.org/install for all install options.'
  }

  Write-Host "Download $url"
  $downloader = new-object System.Net.WebClient
  $downloader.DownloadFile($url, $file)

  [System.Net.ServicePointManager]::SecurityProtocol = $securityProtocolSettingsOriginal
}

function Download-File {
param (
  [string]$url,
  [string]$file
  )
  if (![System.IO.File]::Exists($file)) {
    Always-Download-File $url $file
  }
}

# download 7zip
Write-Host "Download 7Zip commandline tool"
$7zaExe = Join-Path $destDir '7za.exe'
Download-File 'https://github.com/chocolatey/chocolatey/blob/master/src/tools/7za.exe?raw=true' "$7zaExe"

# download jom
Write-Host "Download jom commandline tool"
$jomBaseName = 'jom_1_1_0'
$jomArchiveName = $jomBaseName + '.zip'
$jomInstallDir = Join-Path $destDir $jomBaseName
$jomArchiveUrl = 'http://download.qt.io/official_releases/jom/' + $jomArchiveName
$jomArchiveFile = Join-Path $destDir $jomArchiveName
Download-File $jomArchiveUrl $jomArchiveFile

# if first attempt failed, try again from a different server
$jomArchiveUrl = 'http://master.qt.io/official_releases/jom/' + $jomArchiveName
Download-File $jomArchiveUrl $jomArchiveFile

# extract jom package
if (![System.IO.Directory]::Exists($jomInstallDir)) {
  Write-Host "Extracting $jomArchiveFile to $jomInstallDir..."
  Start-Process "$7zaExe" -ArgumentList "x -o`"$jomInstallDir`" -y `"$jomArchiveFile`"" -Wait
}
$jom = Join-Path $jomInstallDir 'jom.exe'

# download CMake
Write-Host "Download CMake commandline tool"
$cmakeBaseName = 'cmake-3.11.0-win32-x86'
$cmakeArchiveName = $cmakeBaseName + '.zip'
$cmakeInstallDir = Join-Path $destDir $cmakeBaseName
$cmakeArchiveUrl = 'http://www.cmake.org/files/v3.11/' + $cmakeArchiveName
$cmakeArchiveFile = Join-Path $destDir $cmakeArchiveName
Download-File $cmakeArchiveUrl $cmakeArchiveFile

# extract CMake package
if (![System.IO.Directory]::Exists($cmakeInstallDir)) {
  Write-Host "Extracting $cmakeArchiveFile to $destDir..."
  Start-Process "$7zaExe" -ArgumentList "x -o`"$destDir`" -y `"$cmakeArchiveFile`"" -Wait
}
$cmake = Join-Path $cmakeInstallDir 'bin\cmake.exe'

# download cross-platform build script
$qtBuildScriptName = 'build_qt_with_openssl.cmake'
$qtBuildScriptFile = Join-Path $destDir $qtBuildScriptName
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $qtBuildScriptName)
Always-Download-File $url $qtBuildScriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBGetOpenSSLBinariesDownloadURL.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBQt4ExternalProjectCommand.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

pushd $destDir

Start-Process "$cmake" -ArgumentList `
  "-DCMAKE_BUILD_TYPE:STRING=$buildType",`
  "-DDEST_DIR:PATH=$destDir",`
  "-DQT_PLATFORM:STRING=$qtPlatform",`
  "-DBITS:STRING=$bits",`
  "-DJOM_EXECUTABLE:FILEPATH=$jom",`
  "-P", "$qtBuildScriptFile"`
  -NoNewWindow -PassThru -Wait

popd
