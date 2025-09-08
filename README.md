
# Qt Easy build

You will find here scripts allowing to very easily build Qt with OpenSSL support on Linux, Windows or macOS

## Maintained Qt build scripts

Scripts available for these Qt versions:

* [5.15.16][51516]
* [5.15.8][5158]

[51516]: https://github.com/commontk/qt-easy-build/tree/5.15.16#readme
[5158]: https://github.com/commontk/qt-easy-build/tree/5.15.8#readme

## Unmaintained Qt build scripts

Scripts available for these Qt versions:

* [5.15.2][5152]
* [5.15.1][5151]
* [5.15.0][5150]
* [5.12.8][5128]
* [5.11.2][5112]
* [5.10.0][5100]
* [5.9.1][591]
* [5.7.1][571]
* [4.8.7][487]
* [4.8.6][486]
* [4.8.5][485]

[5152]: https://github.com/commontk/qt-easy-build/tree/5.15.2#readme
[5151]: https://github.com/commontk/qt-easy-build/tree/5.15.1#readme
[5150]: https://github.com/commontk/qt-easy-build/tree/5.15.0#readme
[5128]: https://github.com/commontk/qt-easy-build/tree/5.12.8#readme
[5112]: https://github.com/commontk/qt-easy-build/tree/5.11.2#readme
[5100]: https://github.com/commontk/qt-easy-build/tree/5.10.0#readme
[591]: https://github.com/commontk/qt-easy-build/tree/5.9.1#readme
[571]: https://github.com/commontk/qt-easy-build/tree/5.7.1#readme
[487]: https://github.com/commontk/qt-easy-build/tree/4.8.7#readme
[486]: https://github.com/commontk/qt-easy-build/tree/4.8.7#readme
[485]: https://github.com/commontk/qt-easy-build/tree/4.8.7#readme

## Frequently Asked Questions

**Why does the windows build stop with "The underlying connection was closed: An unexpected error occurred on a receive." ?**

As explained [here](https://github.com/chocolatey/choco/wiki/Installation#installing-with-restricted-tls), this most likely happens because the build script is attempting to download from a server that needs to use TLS 1.1 or TLS 1.2 (has restricted the use of TLS 1.0 and SSL v3).

To address the problem, you should update the version of `.NET` installed and install a newer version of PowerShell:
* https://en.wikipedia.org/wiki/.NET_Framework_version_history#Overview
* https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx

**Why does the linux build stop with `curl: (35) SSL connect error`?**

TLS auto-negotation may fail on older Linux versions. Try adding `--tlsv1.2` to the `curl` invocations in `Build-qt.sh`.

## History

* **2017** — Repository created by [Jean-Christophe Fillion-Robin](https://github.com/jcfr) with initial focus on building Qt 4.8.x and 5.9.x, including CI integration and clear separation of maintained vs. unmaintained branches.
* **2018** — Expanded to support Qt 5.10.0 and beyond. Documentation improvements (FAQs, TLS support, badges) and community contributions (notably from [Isaiah Norton](https://github.com/ihnorton)) helped stabilize the scripts.
* **2019–2020** — Contributions from [James Butler](https://github.com/jamesobutler) and others updated tested branches for Qt 5.12 and 5.15 series. Repository became a standard tool for reproducible Qt builds in the [3D Slicer](https://www.slicer.org/) ecosystem.
* **2021** — Default branch updated to Qt 5.15.2, with continued focus on long-term supported versions.
* **2024** — Qt 4.8.7 scripts marked as unmaintained, signaling end-of-life for legacy Qt 4 builds.
* **2025** — Repository transferred from `jcfr/qt-easy-build` to the [commontk](https://github.com/commontk) organization (`commontk/qt-easy-build`) to ensure long-term maintenance and broader community stewardship. Work initiated to support Qt 5.15.17 across Linux, macOS, and Windows.

## License

Scripts in this repository are licensed under the Apache 2.0 License. See [LICENSE_Apache_20](LICENSE_Apache_20) file for details.

