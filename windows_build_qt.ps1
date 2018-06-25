# Qt version (major.minor.revision)
$qtVersion = "5.10.0"

# Building Tools
$pythonVersion = "2.7.15" # if python not in path // if python in path is less than 2.7.5 or Python3
$strawberryPerlVersion = "5.26.2.1" # if perl not in path
$jomVersion = "1.1.2"
$cmakeVersion = "3.11.4"

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

$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

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

function IsPythonNeeded {
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

    if ((Get-Command -Name $Executable -ErrorAction SilentlyContinue) -eq $null) 
    { 
      Write-host "Unable to find $( $Executable ) in your PATH."
      $needpython = $True
    }
    else
    { # check python version
      $version_output = & python -V 2>&1 # Wanting to get this part of output: "Python 2.7.15"
      $CurrentVersionTable = [version]$version_output.ToString().split(" ")[1]
      If( $CurrentVersionTable -lt [version]$MinimumVersion -Or $CurrentVersionTable -ge [version]"3.0.0" )
        {
        # Python 3 is not supported by Chromium
        # Python 2 version >=2.7.5 is required to build Qt WebEngine
        Write-host "$( $Executable ) version $( $CurrentVersion ) must be greater than $( $RequiredVersion ) and less than 3.0.0"
        $needpython = $True
        }
    }
    return $needpython
}

# download 7zip
Write-Host "Download 7Zip commandline tool"
$7zaExe = Join-Path $destDir '7za.exe'
Download-File 'https://github.com/chocolatey/chocolatey/blob/master/src/tools/7za.exe?raw=true' "$7zaExe"

# Check for and Install(if necessary) the additional tools needed to build
$needpython = IsPythonNeeded -Executable python -MinimumVersion "2.7.5"
if( $needpython ){
  Write-Host "Download Python $pythonVersion"
    if($OSArchitecture -match "64-bit"){
    $pythonBaseName = "python-$pythonVersion.amd64"
    }
    else{
    $pythonBaseName = "python-$pythonVersion"
    }
    $pythonArchiveName = "$pythonBaseName.msi"
    $pythonInstallDir = Join-Path $destDir $pythonBaseName
    $pythonArchiveUrl = "https://www.python.org/ftp/python/$pythonVersion/$pythonArchiveName"
    $pythonArchiveFile = Join-Path $destDir $pythonArchiveName
    Download-File $pythonArchiveUrl $pythonArchiveFile

    # Install python with .MSI file
    if (![System.IO.Directory]::Exists($pythonInstallDir)) {
      Write-Host "Installing Python $pythonVersion"
      Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $pythonArchiveFile TARGETDIR=$pythonInstallDir /qn" -Wait -Passthru
    }
    $python = $pythonInstallDir
    $env:Path = "$python;$env:Path"
}

if ((Get-Command "perl.exe" -ErrorAction SilentlyContinue) -eq $null) 
{ 
  Write-Host "Unable to find perl.exe in your PATH"
  # download Strawberry Perl
  Write-Host "Download Strawberry Perl portable tool"
  if($OSArchitecture -match "64-bit"){
    $perlBaseName = "strawberry-perl-$strawberryPerlVersion-64bit-portable"
  }
  else{
    $perlBaseName = "strawberry-perl-$strawberryPerlVersion-32bit-portable"
  }
  $perlArchiveName = $perlBaseName + '.zip'
  $perlInstallDir = Join-Path $destDir $perlBaseName
  $perlArchiveUrl = "http://strawberryperl.com/download/$strawberryPerlVersion/$perlArchiveName"
  $perlArchiveFile = Join-Path $destDir $perlArchiveName
  Download-File $perlArchiveUrl $perlArchiveFile

  # extract Strawberry Perl package
  if (![System.IO.Directory]::Exists($perlInstallDir)) {
    Write-Host "Extracting $perlArchiveFile to $perlInstallDir..."
    Start-Process "$7zaExe" -ArgumentList "x -o`"$perlInstallDir`" -y `"$perlArchiveFile`"" -Wait
  }
  $perl = Join-Path $perlInstallDir 'perl/bin'
  $perl1 = Join-Path $perlInstallDir 'perl/site/bin'
  $perl2 = Join-Path $perlInstallDir 'c/bin'
  $env:Path = "$perl;$perl1;$perl2;$env:Path"
}

# download jom
Write-Host "Download jom commandline tool"
$jomBaseName = "jom_" + $jomVersion.replace(".","_")
$jomArchiveName = "$jomBaseName.zip"
$jomInstallDir = Join-Path $destDir $jomBaseName
$jomArchiveUrl = "http://download.qt.io/official_releases/jom/$jomArchiveName"
$jomArchiveFile = Join-Path $destDir $jomArchiveName
Download-File $jomArchiveUrl $jomArchiveFile
# if first attempt failed, try again from a different server
$jomArchiveUrl = "http://master.qt.io/official_releases/jom/$jomArchiveName"
Download-File $jomArchiveUrl $jomArchiveFile

# extract jom package
if (![System.IO.Directory]::Exists($jomInstallDir)) {
  Write-Host "Extracting $jomArchiveFile to $jomInstallDir..."
  Start-Process "$7zaExe" -ArgumentList "x -o`"$jomInstallDir`" -y `"$jomArchiveFile`"" -Wait
}
$jom = Join-Path $jomInstallDir 'jom.exe'

# download CMake
Write-Host "Download CMake commandline tool"
$cmakeVersionTable = [version]$cmakeVersion
if($OSArchitecture -match "64-bit"){
  $cmakeBaseName = "cmake-$cmakeVersion-win64-x64"
}
else{
  $cmakeBaseName = "cmake-$cmakeVersion-win32-x86"
}
$cmakeArchiveName = "$cmakeBaseName.zip"
$cmakeInstallDir = Join-Path $destDir $cmakeBaseName
$cmakeMajorMinor = $cmakeVersion.substring(0, $cmakeVersion.LastIndexOf("."))
$cmakeArchiveUrl = "http://www.cmake.org/files/v$cmakeMajorMinor/$cmakeArchiveName"
$cmakeArchiveFile = Join-Path $destDir $cmakeArchiveName
Download-File $cmakeArchiveUrl $cmakeArchiveFile

# extract CMake package
if (![System.IO.Directory]::Exists($cmakeInstallDir)) {
  Write-Host "Extracting $cmakeArchiveFile to $destDir..."
  Start-Process "$7zaExe" -ArgumentList "x -o`"$destDir`" -y `"$cmakeArchiveFile`"" -Wait
}
$cmake = Join-Path $cmakeInstallDir 'bin/cmake.exe'

# download cross-platform build script
$qtBuildScriptName = 'build_qt_with_openssl.cmake'
$qtBuildScriptFile = Join-Path $destDir $qtBuildScriptName
$url = ("https://raw.githubusercontent.com/jcfr/qt-easy-build/$qtVersion/cmake/$qtBuildScriptName")

Always-Download-File $url $qtBuildScriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBGetOpenSSLBinariesDownloadURL.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ("https://raw.githubusercontent.com/jcfr/qt-easy-build/$qtVersion/cmake/$scriptName")
Always-Download-File $url $scriptFile

# download cross-platform helper script(s)
$scriptName = 'QEBQt5ExternalProjectCommand.cmake'
$scriptFile = Join-Path $destDir $scriptName
$url = ("https://raw.githubusercontent.com/jcfr/qt-easy-build/$qtVersion/cmake/$scriptName")
Always-Download-File $url $scriptFile

pushd $destDir

$qtMajorVersion = $qtVersion.split(".")[0]
$qtMinorVersion = $qtVersion.split(".")[1]
Start-Process "$cmake" -ArgumentList `
  "-DCMAKE_BUILD_TYPE:STRING=$buildType",`
  "-DDEST_DIR:PATH=$destDir",`
  "-DQT_PLATFORM:STRING=$qtPlatform",`
  "-DQT_VERSION:STRING=$qtVersion",`
  "-DQT_MAJOR_VERSION:STRING=$qtMajorVersion",`
  "-DQT_MINOR_VERSION:STRING=$qtMinorVersion",`
  "-DBITS:STRING=$bits",`
  "-DJOM_EXECUTABLE:FILEPATH=$jom",`
  "-P", "$qtBuildScriptFile"`
  -NoNewWindow -PassThru -Wait

Write-Host "Uninstalling temporary Python27"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $pythonArchiveFile /qn" -Wait -Passthru

popd
