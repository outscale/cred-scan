# Credential Scanner

This small bash script will scan for leaked [Access Keys or Secret Keys](https://docs.outscale.com/en/userguide/About-Access-Keys.html) in a folder.

# Usage

Just provide the folder to scan (recursively):
Example
```
./scan.sh FOLDER_PATH
```

# Features

- Skip binary files
- Search for:
  - Access Keys (20 capital alphanumeric random string)
  - Secret Keys (40 capital alphanumeric random string)
- Special Access Keys are ignored:
  - `ABCDEFGHIJ0123456789`
  - `0123456789ABCDEFGHIJ`
- Access Keys withs less than 3 digits or less than 3 capital alphabetic characters are ignored.
- Secret Keys with less than 5 digits or less than 5 capital alphabetic characters are ignored.

# Contributing

Feel free to open an issue for discussion.
`./tests/tests.sh` to run tests.

# Using scanner in Github actions

## Description

This Github action allows you to scan for leaked credentials.
See [action.yml](action.yml)

## Inputs

| Parameter           | Description                                                           | Required | Default   |
| :------------------ | :-------------------------------------------------------------------- | :------- | :-------- |
| `scan_path`         | Folder to scan                                                        | `true`   | `"./"`    |

## Output
N/A

## Example

- Create workflow folder: `mkdir -p .github/workflows`
- Add new workflow `.github/workflows/cred-scan.yml`:

```yaml
name: Credential Scanner

on:
  pull_request:
    branches: [ master ]

jobs:
  cred-scan:
    runs-on: ubuntu-20.04
    steps:
    - uses: actions/checkout@v2
    - name: Scan credentials
      uses: outscale-dev/cred-scan@main
      with:
        scan_path: "./"
```

# License

> Copyright Outscale SAS
>
> BSD-3-Clause

`LICENSE` folder contain raw licenses terms following spdx naming.

You can check which license apply to which copyright owner through `.reuse/dep5` specification.

You can test [reuse](https://reuse.software/.) compliance by running:
```
docker run --rm --volume $(pwd):/data fsfe/reuse:0.11.1 lint
```
