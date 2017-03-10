Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Prerequisites
=============

* Windows: Build system has been updated and `chocolatey` is **NOT** a requirement anymore. `jom` wil be downloaded.
directly.

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

1. Open desired Visual Studio Command Prompt (for 64 bit Qt, use the 64 bit Command Prompt, for 32 bit Qt, use the 32 bit Command Prompt)
2. Paste the corresponding text from the box below and press enter.

Supported Configurations:

| Qt 5 (5.8.0)            | Qt 4 (4.8.7)            |
| ------------------------|:-----------------------:|
| win32-msvc2017 w/openssl|                         |
| win32-msvc2015 w/openssl| win32-msvc2015 w/openssl|
| win32-msvc2013 w/openssl| win32-msvc2013 w/openssl|
|                         | win32-msvc2012 w/openssl|

* Visual Studio 2017 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2017';$qtVersion='5';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2017 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2017';$qtVersion='5';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2015 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2015';$qtVersion='5';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2015 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2015';$qtVersion='5';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2013 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2013';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2013 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2013';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2012 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2012';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2012 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2012';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

<!--* Visual Studio 2010 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2010';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2010 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2010';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2008';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2008';$qtVersion='4';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7-5.8.0/windows_build_qt.ps1'))"
```-->

### Notes ###

* `buildType` can be set to either 'Release' or 'Debug'

* `qtPlatform` can be set to either '5' or '4'

* `bits` can be set to either '32' or '64'

* The script will install [jom](http://qt-project.org/wiki/jom) using `cinst jom`.

* Make sure that your Windows `%PATH%` environment variable does not contain any quotation marks! This
  might break both the executables path or even the include paths and make the [CMake script fail](https://github.com/jcfr/qt-easy-build/issues/19#issuecomment-213411046).
  Even if your `%PATH%` contains whitespaces (e.g. `C:\Program Files (x86)\...`) no quotes are needed.
