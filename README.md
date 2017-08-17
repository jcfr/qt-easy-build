Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Usage
=====

Linux and macOS
---------------

1. Open a terminal and copy the text below:

```
curl -s https://raw.githubusercontent.com/jcfr/qt-easy-build/5.9.1/Build-qt.sh -o Build-qt.sh && chmod u+x Build-qt.sh
./Build-qt.sh -j 4
```

To display script options:

```
./Build-qt.sh --help
```

Windows
-------

1. Open desired Visual Studio Command Prompt (for 64 bit Qt, use the 64 bit Command Prompt, for 32 bit Qt, use the 32 bit Command Prompt)
2. Paste the corresponding text from the box below and press enter.

* Visual Studio 2013 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2013';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2013 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2013';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2012 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2012';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2012 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2012';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2010 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2010';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2010 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2010';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2008';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

* Visual Studio 2008 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2008';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/4.8.7/windows_build_qt.ps1'))"
```

### Notes ###

* `buildType` can be set to either 'Release' or 'Debug'

* `bits` can be set to either '32' or '64'

* The script will install [jom](http://qt-project.org/wiki/jom) downloading it from http://download.qt.io/official_releases/jom/.

* Make sure that your Windows `%PATH%` environment variable does not contain any quotation marks! This
  might break both the executables path or even the include paths and make the [CMake script fail](https://github.com/jcfr/qt-easy-build/issues/19#issuecomment-213411046).
  Even if your `%PATH%` contains whitespaces (e.g. `C:\Program Files (x86)\...`) no quotes are needed.
