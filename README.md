Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Prerequisites
=============

* Windows: Install [chocolatey](http://chocolatey.org/)

```PowerShell
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
```

Usage
=====

Linux
-----

```
TBD
```

MacOSX
------

```
TBD
```

Windows
-------

1. Open desired Visual Studio Command Prompt
2. Paste the text from the box below
3. Change 'buildType' to either 'Release' or 'Debug'
4. Change 'bits' to either '32' or '64' to match your Visual Studio Prompt
5. and press enter.

* Visual Studio 2010 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform'win32-msvc2010';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw2.github.com/jcfr/qt-easy-build/master/windows_build_qt.ps1'))"
```

* Visual Studio 2010 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform'win32-msvc2010';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw2.github.com/jcfr/qt-easy-build/master/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform'win32-msvc2008';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw2.github.com/jcfr/qt-easy-build/master/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform'win32-msvc2008';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw2.github.com/jcfr/qt-easy-build/master/windows_build_qt.ps1'))"
```

Note that this script will install [jom](http://qt-project.org/wiki/jom) and [StrawberryPerl](http://strawberryperl.com/) using `cinst jom` and `cinst StrawberryPerl`.