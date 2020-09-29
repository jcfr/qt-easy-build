Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Usage
=====

Linux and macOS
---------------

1. Open a terminal and copy the text below:

```
curl -s https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/Build-qt.sh -o Build-qt.sh && chmod u+x Build-qt.sh
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

Supported Configurations:

| Qt 5.10.0                               |
| ----------------------------------------|
| win32-msvc2017 w/openssl                |
| win32-msvc2015 w/openssl                |
| win32-msvc2013 w/openssl w/o qtwebengine|

* Visual Studio 2017 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2017';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

* Visual Studio 2017 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2017';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

* Visual Studio 2015 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2015';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

* Visual Studio 2015 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2015';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

* Visual Studio 2013 64-bit Release

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Release';$qtPlatform='win32-msvc2013';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

* Visual Studio 2013 64-bit Debug

```PowerShell
@powershell -Command "$destDir='C:\D\Support';$buildType='Debug';$qtPlatform='win32-msvc2013';$bits='64';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jcfr/qt-easy-build/5.10.0/windows_build_qt.ps1'))"
```

### Notes ###

* the minimum glibc version [supported by QtWebEngine is 2.17](https://github.com/qt/qtwebengine/commit/6d9fe6ba35024efc8e0a26435b51e25aa3ea7f09#diff-fb760d5130a8d1bf9c6f4be03ebcdc20). This excludes building QtWebEngine on less than CentOS 7, for example (local glibc version may be checked with `ldd --version`).

* the minimum MSVC version [supported by QtWebEngine is 2015](https://github.com/qt/qtwebengine/commit/3b4ca800635003844ed54d2e056ee3f6559b108b#diff-355124f6d939bcdc011b1a18983461d4). This excludes building QtWebEngine on less than MSVC2015

* `buildType` can be set to either 'Release' or 'Debug'

* `bits` can be set to either '32' or '64'

* The script will install [jom](http://qt-project.org/wiki/jom) downloading it from http://download.qt.io/official_releases/jom/.

* Make sure that your Windows `%PATH%` environment variable does not contain any quotation marks! This
  might break both the executables path or even the include paths and make the [CMake script fail](https://github.com/jcfr/qt-easy-build/issues/19#issuecomment-213411046).
  Even if your `%PATH%` contains whitespaces (e.g. `C:\Program Files (x86)\...`) no quotes are needed.
