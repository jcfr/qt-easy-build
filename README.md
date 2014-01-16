Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Prerequisites
=============

* Windows: Install [chocolatey](http://chocolatey.org/)

```PowerShell
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
```

Usage
=====

* Linux
```
TBD
```

* MacOSX
```
TBD
```

* Windows

1. Open Visual Studio Command Prompt
2. Paste the text from the box below and press enter.

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';iex ((new-object net.webclient).DownloadString('https://raw2.github.com/jcfr/qt-easy-build/master/windows_build_qt.ps1'))"
```

Note that this script will install [jom](http://qt-project.org/wiki/jom) and [StrawberryPerl](http://strawberryperl.com/) using `cinst jom` and `cinst StrawberryPerl`.