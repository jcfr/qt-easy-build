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

$qtBuildScriptVersion = 'ad6fa7d1983b77998e4b33026b71e17374af0030 '

if (![System.IO.Directory]::Exists($destDir)) {[System.IO.Directory]::CreateDirectory($destDir)}

function Always-Download-File {
param (
  [string]$url,
  [string]$file
  )
  If (Test-Path $file) {
    Remove-Item $file
  }
  Write-Host "Download $url"
  $downloader = new-object System.Net.WebClient
  $downloader.DownloadFile($url, $file)
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

# download and extract patch if Visual Studio 2015
$patch = ""
if($qtPlatform -eq "win32-msvc2015") {
  # download patch
  Write-Host "Download patch commandline tool"
  $patchBaseName = 'patch-2.5.9-7-bin'
  $patchArchiveName = $patchBaseName + '.zip'
  $patchInstallDir = Join-Path $destDir $patchBaseName
  $patchArchiveUrl = 'https://blogs.osdn.jp/2015/01/13/download/' + $patchArchiveName
  $patchArchiveFile = Join-Path $destDir $patchArchiveName
  Download-File $patchArchiveUrl $patchArchiveFile

  # extract patch
  if (![System.IO.Directory]::Exists($patchInstallDir)) {
    Write-Host "Extracting $patchInstallDir to $destDir..."
    Start-Process "$7zaExe" -ArgumentList "x -o`"$destDir\$patchBaseName`" -y `"$patchArchiveFile`"" -Wait
  }
  $patch = Join-Path $patchInstallDir 'bin\patch.exe'
}

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
$cmakeBaseName = 'cmake-2.8.12.1-win32-x86'
$cmakeArchiveName = $cmakeBaseName + '.zip'
$cmakeInstallDir = Join-Path $destDir $cmakeBaseName
$cmakeArchiveUrl = 'http://www.cmake.org/files/v2.8/' + $cmakeArchiveName
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
$url = ('https://raw.githubusercontent.com/huyu398/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $qtBuildScriptName)
Always-Download-File $url $qtBuildScriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBGetOpenSSLBinariesDownloadURL.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ('https://raw.githubusercontent.com/huyu398/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBQt4ExternalProjectCommand.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ('https://raw.githubusercontent.com/huyu398/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

# download patch file if Visual Studio 2015
if($qtPlatform -eq "win32-msvc2015") {
  $scriptName = 'patch_for_win32-msvc2015.diff'
  $scriptFile = Join-Path $destDir $scriptName
  $url = ('https://raw.githubusercontent.com/huyu398/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
  Always-Download-File $url $scriptFile
}

pushd $destDir

Start-Process "$cmake" -ArgumentList `
  "-DCMAKE_BUILD_TYPE:STRING=$buildType",`
  "-DDEST_DIR:PATH=$destDir",`
  "-DQT_PLATFORM:STRING=$qtPlatform",`
  "-DBITS:STRING=$bits",`
  "-DJOM_EXECUTABLE:FILEPATH=$jom",`
  "-DPATCH_EXECUTABLE:FILEPATH=$patch",`
  "-P", "$qtBuildScriptFile"`
  -NoNewWindow -PassThru -Wait

popd
