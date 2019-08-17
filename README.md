
# Qt Easy build

You will find here scripts allowing to very easily build Qt with OpenSSL support on Linux, Windows or macOS

# Maintained Qt build scripts

Scripts available for these Qt versions:

* [5.12.7][5127]
* [4.8.7][487]

[5127]: https://github.com/jcfr/qt-easy-build/tree/5.12.7#readme
[487]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme

| Qt Version   | Linux                                                   | macOS                                                   | Windows CI |
|--------------|---------------------------------------------------------|---------------------------------------------------------|------------|
| 5.12.7       | [![Build Status][5127_linux_i_azure]][5127_linux_azure] | [![Build Status][5127_macos_i_azure]][5127_macos_azure] | [![Build Status][5127_windows_i_azure]][5127_windows_azure]         |
| 4.8.7        | NA                                                      | NA                                                      | NA         |

[5127_linux_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_build/latest?definitionId=1&branchName=5.12.7
[5127_linux_i_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_apis/build/status/jamesobutler.qt-easy-build?branchName=5.12.7&jobName=Linux

[5127_macos_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_build/latest?definitionId=1&branchName=5.12.7
[5127_macos_i_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_apis/build/status/jamesobutler.qt-easy-build?branchName=5.12.7&jobName=macOS

[5127_windows_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_build/latest?definitionId=1&branchName=5.12.7
[5127_windows_i_azure]: https://dev.azure.com/jamesobutler/qt-easy-build/_apis/build/status/jamesobutler.qt-easy-build?branchName=5.12.7&jobName=Windows

# Unmaintained Qt build scripts

Scripts available for these Qt versions:

* [5.11.2][5112]
* [5.10.0][5100]
* [5.9.1][591]
* [5.7.1][571]
* [4.8.6][486]
* [4.8.5][485]

[5112]: https://github.com/jcfr/qt-easy-build/tree/5.11.2#readme
[5100]: https://github.com/jcfr/qt-easy-build/tree/5.10.0#readme
[591]: https://github.com/jcfr/qt-easy-build/tree/5.9.1#readme
[571]: https://github.com/jcfr/qt-easy-build/tree/5.7.1#readme
[486]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme
[485]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme

# Frequently Asked Questions

**Why does the windows build stop with "The underlying connection was closed: An unexpected error occurred on a receive." ?**

As explained [here](https://github.com/chocolatey/choco/wiki/Installation#installing-with-restricted-tls), this most likely happens because the build script is attempting to download from a server that needs to use TLS 1.1 or TLS 1.2 (has restricted the use of TLS 1.0 and SSL v3).

To address the problem, you should update the version of `.NET` installed and install a newer version of PowerShell:
* https://en.wikipedia.org/wiki/.NET_Framework_version_history#Overview
* https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx

**Why does the linux build stop with `curl: (35) SSL connect error`?**

TLS auto-negotation may fail on older Linux versions. Try adding `--tlsv1.2` to the `curl` invocations in `Build-qt.sh`.

# License

Scripts in this repository are licensed under the Apache 2.0 License. See [LICENSE_Apache_20](LICENSE_Apache_20) file for details.

