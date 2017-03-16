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
if(!($qtVersion -match "^(4|5)$")){
  throw "'qtVersion' variable incorrectly set to [$qtVersion]. Hint: '4' or '5' value is expected."
}
if(!($bits -match "^(32|64)$")){
  throw "'bits' variable incorrectly set to [$bits]. Hint: '32' or '64' value is expected."
}

$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

# $qtBuildScriptVersion = '6f59ca17b3bcc6b56fa636522dab6a862be0c856'

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

function Ensure-PyExecutableExists {
    Param
    (
        [Parameter( Mandatory = $True )]
        [string]
        $Executable,

        [string]
        $MinimumVersion = ""
    )
    # Initial condition
    $needpython = $False
    $python3 = [version]"3.0.0"

    if ((Get-Command -Name $Executable -ErrorAction SilentlyContinue) -eq $null) 
    { 
      Write-host "Unable to find $( $Executable ) in your PATH."
      $needpython = $True #switch
      return $needpython
    }
    else
    { # get python version
      $p = python -V
      $CurrentVersionString = $p[7]+$p[8]+$p[9]+$p[10]+$p[11]+$p[12]
      $CurrentVersion = [version]$CurrentVersionString
      $RequiredVersion = [version]$MinimumVersion
        If( $CurrentVersion -lt $RequiredVersion -Or $CurrentVersion -gt $python3 )
          {
          Write-host "$( $Executable ) version $( $CurrentVersion ) must be greater than $( $RequiredVersion ) and less than 3.0.0"
          $needpython = $True #switch
          return $needpython
          # Python 3 is not supported by Chromium
          # Python 2 version >=2.7.5 is required to build Qt WebEngine
          }
      return $needpython
    }
}

# download 7zip
Write-Host "Download 7Zip commandline tool"
$7zaExe = Join-Path $destDir '7za.exe'
Download-File 'https://github.com/chocolatey/chocolatey/blob/master/src/tools/7za.exe?raw=true' "$7zaExe"

# Check for and Install(if necessary) the additional tools needed to build Qt5
if($qtVersion -match "^(5)$"){
  $needpython = Ensure-PyExecutableExists -Executable python -MinimumVersion "2.7.5"
  if( $needpython ){
    Write-Host "Download Python distribution"
      if($OSArchitecture -match "64-bit"){
      $pythonBaseName = 'python-2.7.13.amd64'
      }
      else{
      $pythonBaseName = 'python-2.7.13'
      }
      $pythonArchiveName = $pythonBaseName + '.msi'
      $pythonInstallDir = Join-Path $destDir $pythonBaseName
      $pythonArchiveUrl = 'https://www.python.org/ftp/python/2.7.13/' + $pythonArchiveName
      $pythonArchiveFile = Join-Path $destDir $pythonArchiveName
      Download-File $pythonArchiveUrl $pythonArchiveFile

      # Install python with .MSI file
      if (![System.IO.Directory]::Exists($pythonInstallDir)) {
        Write-Host "Installing Python 2.7.13"
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $pythonArchiveFile TARGETDIR=$pythonInstallDir /qn" -Wait -Passthru
      }
      $python = $pythonInstallDir
      $env:Path = "$python;" + $env:Path
  }

  if ((Get-Command "perl.exe" -ErrorAction SilentlyContinue) -eq $null) 
  { 
    Write-Host "Unable to find perl.exe in your PATH"
    # download Strawberry Perl
    Write-Host "Download Strawberry Perl portable tool"
    if($OSArchitecture -match "64-bit"){
      $perlBaseName = 'strawberry-perl-5.24.1.1-64bit-portable'
    }
    else{
      $perlBaseName = 'strawberry-perl-5.24.1.1-32bit-portable'
    }
    $perlArchiveName = $perlBaseName + '.zip'
    $perlInstallDir = Join-Path $destDir $perlBaseName
    $perlArchiveUrl = 'http://strawberryperl.com/download/5.24.1.1/' + $perlArchiveName
    $perlArchiveFile = Join-Path $destDir $perlArchiveName
    Download-File $perlArchiveUrl $perlArchiveFile

    # extract Strawberry Perl package
    if (![System.IO.Directory]::Exists($perlInstallDir)) {
      Write-Host "Extracting $perlArchiveFile to $perlInstallDir..."
      Start-Process "$7zaExe" -ArgumentList "x -o`"$perlInstallDir`" -y `"$perlArchiveFile`"" -Wait
    }
    $perl = Join-Path $perlInstallDir 'perl\bin'
    $perl1 = Join-Path $perlInstallDir 'perl\site\bin'
    $perl2 = Join-Path $perlInstallDir 'c\bin'
    $env:Path = "$perl;$perl1;$perl2;" + $env:Path
  }
}

# Tools needed to build Qt5 or Qt4
# download jom
Write-Host "Download jom commandline tool"
$jomBaseName = 'jom_1_1_2'
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
if($OSArchitecture -match "64-bit"){
  $cmakeBaseName = 'cmake-3.7.2-win64-x64'
}
else{
  $cmakeBaseName = 'cmake-3.7.2-win32-x86'
}
$cmakeArchiveName = $cmakeBaseName + '.zip'
$cmakeInstallDir = Join-Path $destDir $cmakeBaseName
$cmakeArchiveUrl = 'http://www.cmake.org/files/v3.7/' + $cmakeArchiveName
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
# $url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $qtBuildScriptName)
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0' + '/cmake/' + $qtBuildScriptName)
Always-Download-File $url $qtBuildScriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBGetOpenSSLBinariesDownloadURL.cmake'
$scriptFile = Join-Path $destDir $scriptName
# $url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0' + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBQt5ExternalProjectCommand.cmake'
$scriptFile = Join-Path $destDir $scriptName
# $url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/' + $qtBuildScriptVersion + '/cmake/' + $scriptName)
$url = ('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0' + '/cmake/' + $scriptName)
Always-Download-File $url $scriptFile

pushd $destDir

Start-Process "$cmake" -ArgumentList `
  "-DCMAKE_BUILD_TYPE:STRING=$buildType",`
  "-DDEST_DIR:PATH=$destDir",`
  "-DQT_PLATFORM:STRING=$qtPlatform",`
  "-DQT_VERSION:STRING=$qtVersion",`
  "-DBITS:STRING=$bits",`
  "-DJOM_EXECUTABLE:FILEPATH=$jom",`
  "-P", "$qtBuildScriptFile"`
  -NoNewWindow -PassThru -Wait

Write-Host "Uninstalling temporary Python27"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $pythonArchiveFile /qn" -Wait -Passthru

popd
