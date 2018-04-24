
# Qt Easy build

You will find here scripts allowing to very easily build Qt with OpenSSL support on Linux, Windows or macOS

# Maintained Qt build scripts

Scripts available for these Qt versions:

* [5.10.0][5100]
* [4.8.7][487]

[5100]: https://github.com/jcfr/qt-easy-build/tree/5.10.0#readme
[487]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme

| Qt Version   | Linux CI                        | macOS CI                        | Windows CI |
|--------------|---------------------------------|---------------------------------|------------|
| 5.10.0       | [![][5100_linux_i]][5100_linux] | [![][5100_macos_i]][5100_macos] | NA         |
| 4.8.7        | [![][487_linux_i]][487_linux]   | [![][487_macos_i]][487_macos]   | NA         |


[5100_linux]: https://circleci.com/gh/jcfr/qt-easy-build/tree/5.10.0
[5100_linux_i]: https://circleci.com/gh/jcfr/qt-easy-build/tree/5.10.0.svg?style=svg

[487_linux]: https://circleci.com/gh/jcfr/qt-easy-build/tree/4.8.7
[487_linux_i]: https://circleci.com/gh/jcfr/qt-easy-build/tree/4.8.7.svg?style=svg

[5100_macos]: https://travis-ci.org/jcfr/qt-easy-build
[5100_macos_i]: https://travis-ci.org/jcfr/qt-easy-build.svg?branch=5.10.0

[487_macos]: https://travis-ci.org/jcfr/qt-easy-build
[487_macos_i]: https://travis-ci.org/jcfr/qt-easy-build.svg?branch=4.8.7


# Unmaintained Qt build scripts

Scripts available for these Qt versions:

* [5.9.1][591]
* [5.7.1][571]
* [4.8.6][486]
* [4.8.5][485]

[591]: https://github.com/jcfr/qt-easy-build/tree/5.9.1#readme
[571]: https://github.com/jcfr/qt-easy-build/tree/5.7.1#readme
[486]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme
[485]: https://github.com/jcfr/qt-easy-build/tree/4.8.7#readme

# Frequently Asked Questions

**Why windows build stop with "The underlying connection was closed: An unexpected error occurred on a receive." ?**

As explained [here](https://github.com/chocolatey/choco/wiki/Installation#installing-with-restricted-tls), this most likely happens because the build script is attempting to download from a server that needs to use TLS 1.1 or TLS 1.2 (has restricted the use of TLS 1.0 and SSL v3).

To address the problem, you should update the version of `.NET` installed and install a newer version of PowerShell:
* https://en.wikipedia.org/wiki/.NET_Framework_version_history#Overview
* https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx

** Why does linux build stop with `curl: (35) SSL connect error`?**

TLS auto-negotation may fail on older Linux versions. Try adding `--tlsv1.2` to the `curl` invocations in `Build-qt.sh`.

# License

Scripts in this repository are licensed under the Apache 2.0 License. See [LICENSE_Apache_20](LICENSE_Apache_20) file for details.

