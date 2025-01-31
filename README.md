Script allowing to very easily build qt with openssl support on Linux, Windows or MacOSX

Usage
=====

Linux and macOS
---------------

1. Open a terminal and copy the text below:

```
curl -s https://raw.githubusercontent.com/jcfr/qt-easy-build/5.15.16/Build-qt.sh -o Build-qt.sh && chmod u+x Build-qt.sh
```
> [!IMPORTANT]
> [git](https://git-scm.com/) is required to apply patches for 5.15.16. Download the [patches directory](https://github.com/jcfr/qt-easy-build/tree/5.15.16/patches) and place the directory next to the downloaded Build-qt.sh script.

Build for x86_64 on x86_64
---------------
```
./Build-qt.sh -j 4
```
Build for x86_64 on Apple Silicon (arm64):
---------------

Install x86_64 build dependencies using x86_64 Homebrew:
```
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
brew install ninja
```
Remain in x86_x64 /bin/bash. Example usage building Qt for x86_64 on Apple Silicon running macOS 15 with macOS 15.2 SDK and setting deployment target to macOS 13:
```
./Build-qt.sh -a x86_64 -s macosx15.2 -d 13 -j 4
```

Script Options
---------------
```
./Build-qt.sh --help
```

Troubleshooting
---------------
To avoid running into the error of "Too many open files", increase the value of `ulimit -n`. For example, this may include changing the value from 256 to 4096 by way of `ulimit -n 4096`.
```
global/qlogging.cpp:121:65: fatal error: cannot open file '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk/usr/include/sys/syscall.h': Too many open files
  121 | #if defined(Q_OS_LINUX) && (defined(__GLIBC__) || __has_include(<sys/syscall.h>))
      |                                                                 ^
1 error generated.
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

* the minimum glibc version [supported by QtWebEngine is 2.17](https://github.com/qt/qtwebengine/commit/6d9fe6ba35024efc8e0a26435b51e25aa3ea7f09#diff-fb760d5130a8d1bf9c6f4be03ebcdc20). This excludes building QtWebEngine on less than CentOS 7, for example (local glibc version may be checked with `ldd --version`).

* `buildType` can be set to either 'Release' or 'Debug'

* `bits` can be set to either '32' or '64'

* The script will install [jom](http://qt-project.org/wiki/jom) downloading it from http://download.qt.io/official_releases/jom/.

* Make sure that your Windows `%PATH%` environment variable does not contain any quotation marks! This
  might break both the executables path or even the include paths and make the [CMake script fail](https://github.com/jcfr/qt-easy-build/issues/19#issuecomment-213411046).
  Even if your `%PATH%` contains whitespaces (e.g. `C:\Program Files (x86)\...`) no quotes are needed.
