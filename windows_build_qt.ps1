
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

$qtBuildScriptVersion = '463f300dd68ebb210f93d18b7faf1ba7ee962c5a'

if (![System.IO.Directory]::Exists($destDir)) {[System.IO.Directory]::CreateDirectory($destDir)}

cinst jom
cinst StrawberryPerl

function Download-File {
param (
  [string]$url,
  [string]$file
  )
  if (![System.IO.File]::Exists($file)) {
    Write-Host "Downloading $url to $file"
    $downloader = new-object System.Net.WebClient
    $downloader.DownloadFile($url, $file)
  }
}

# download 7zip
Write-Host "Download 7Zip commandline tool"
$7zaExe = Join-Path $destDir '7za.exe'
Download-File 'https://github.com/chocolatey/chocolatey/blob/master/src/tools/7za.exe?raw=true' "$7zaExe"

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
Download-File ('https://raw2.github.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $qtBuildScriptName) $qtBuildScriptFile

pushd $destDir

Start-Process "$cmake" -ArgumentList `
  "-DCMAKE_BUILD_TYPE:STRING=$buildType",`
  "-DDEST_DIR:PATH=$destDir",`
  "-DQT_PLATFORM:STRING=$qtPlatform",`
  "-DBITS:STRING=$bits",`
  "-P", "$qtBuildScriptFile"`
  -NoNewWindow -PassThru -Wait

popd



