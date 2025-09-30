# Credential Scanner

[![Project Graduated](https://docs.outscale.com/fr/userguide/_images/Project-Graduated-green.svg)](https://docs.outscale.com/en/userguide/Open-Source-Projects.html) [![](https://dcbadge.limes.pink/api/server/HUVtY5gT6s?style=flat&theme=default-inverted)](https://discord.gg/HUVtY5gT6s)

<p align="center">
  <img alt="Key Icon" src="https://img.icons8.com/ios-filled/100/key-security.png" width="80px">
  <br/>
  <strong>Detect leaked Access Keys and Secret Keys in your codebase.</strong>
</p>

---

## 🌐 Links

* 🔑 About Access Keys: [Outscale Access Keys](https://docs.outscale.com/en/userguide/About-Access-Keys.html)
* ⚙️ GitHub Action: [action.yml](./action.yml)
* 🧪 Test Script: [tests/tests.sh](./tests/tests.sh)
* 🤝 Contribution Guide: [CONTRIBUTING.md](./CONTRIBUTING.md)
* 💬 Join us on [Discord](https://discord.gg/YOUR_INVITE_CODE)

---

## 📄 Table of Contents

* [Overview](#-overview)
* [Features](#-features)
* [Requirements](#-requirements)
* [Usage](#-usage)
* [GitHub Actions Integration](#-github-actions-integration)
* [Contributing](#-contributing)
* [License](#-license)

---

## 🧭 Overview

**Credential Scanner** is a lightweight Bash script that recursively scans a directory for leaked [Outscale Access Keys and Secret Keys](https://docs.outscale.com/en/userguide/About-Access-Keys.html).

It skips binary files and uses strict patterns to avoid false positives and catch high-confidence secrets.

---

## ✨ Features

* Recursive scanning of directories
* Skips binary files
* Detects:

  * Access Keys (20-character uppercase alphanumeric)
  * Secret Keys (40-character uppercase alphanumeric)
* Ignores known test keys:

  * `ABCDEFGHIJ0123456789`
  * `0123456789ABCDEFGHIJ`
* Ignores weak matches:

  * Access Keys with <3 digits or <3 uppercase letters
  * Secret Keys with <5 digits or <5 uppercase letters

---

## ✅ Requirements

* Bash shell (Linux/macOS/WSL)
* `grep`, `find`, and standard POSIX utilities

---

## 🚀 Usage

```bash
./scan.sh /path/to/your/codebase
```

Example:

```bash
./scan.sh ./src/
```

---

## 🧪 GitHub Actions Integration

You can integrate this scanner directly into your GitHub workflows to detect secrets on pull requests.

### 📥 Inputs

| Input       | Description  | Required | Default |
| ----------- | ------------ | -------- | ------- |
| `scan_path` | Path to scan | ✅ Yes    | `"./"`  |

### 📤 Outputs

None

### 🧾 Example Workflow

Create a file at `.github/workflows/cred-scan.yml`:

```yaml
name: Credential Scanner

on:
  pull_request:
    branches: [ main ]

permissions:
  contents: read

jobs:
  cred-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Scan credentials
        uses: outscale/cred-scan@main
        with:
          scan_path: "./"
```

---

## 🤝 Contributing

We welcome contributions and discussions!

* Run tests with:

  ```bash
  ./tests/tests.sh
  ```

Please read our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) before submitting a pull request.

---

## 📜 License

**Credential Scanner** is licensed under the BSD 3-Clause License.
© Outscale SAS

This project follows the [REUSE Specification](https://reuse.software/).
