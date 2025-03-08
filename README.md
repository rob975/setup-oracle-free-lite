
# Setup Oracle Database Free Lite

[![Code](https://img.shields.io/badge/Code-Setup_Oracle_Free_Lite-blue?logo=github&logoColor=rgb(149%2C157%2C165)&labelColor=rgb(53%2C60%2C67))](https://github.com/rob975/setup-oracle-free-lite)
[![Release](https://img.shields.io/github/v/release/rob975/setup-oracle-free-lite?logo=github&logoColor=rgb(149%2C157%2C165)&label=Release&labelColor=rgb(53%2C60%2C67))](https://github.com/rob975/setup-oracle-free-lite/releases)
[![CI](https://github.com/rob975/setup-oracle-free-lite/actions/workflows/ci.yml/badge.svg)](https://github.com/rob975/setup-oracle-free-lite/actions/workflows/ci.yml)
[![Dependabot Updates](https://github.com/rob975/setup-oracle-free-lite/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/rob975/setup-oracle-free-lite/actions/workflows/dependabot/dependabot-updates)

> [!IMPORTANT]
> Only Linux [runners](https://github.com/actions/runner-images) are supported.

[GitHub Action](https://docs.github.com/actions) to set up an Oracle Database using
[Oracle Database 23ai Free Lite Container](https://container-registry.oracle.com/ords/ocr/ba/database/free) images.

Oracle Database 23ai Free Lite Container image contains a pre-built database, so
the startup time is very fast.

## Key Features

- Pulling container images is way faster
- Lite container images are suitable for CI scenarios
- Action returns only after startup scripts are executed

> [!IMPORTANT]
> Image tags are deliberately limited to those containing `lite` word.
>
> For a more comprehensive solution see
> [Setup Oracle Database](https://github.com/marketplace/actions/setup-oracle-db-free).

## Inputs

No input using `step.with` keys is required but some are defined to customize
the database.

| Name              | Default          | Description |
|-------------------|------------------|-------------|
| tag               | latest-lite      | Image tag from [Oracle Container Registry](https://container-registry.oracle.com/ords/ocr/ba/database/free>). Must contain `lite` word. |
| container-name    | oracle-db        | Container name. |
| oracle-pwd        | *auto generated* | SYS, SYSTEM and PDBADMIN password. |
| oracle-pdb        | FREEPDB1         | Pluggable database name. |
| port              | 1521             | Port for database connections. |
| startup-scripts   | *none*           | Absolute path to startup scripts directory. |
| readiness-retries | 10               | Readiness check retries before exiting with error. Checks are performed every 10 seconds. |

## Usage


### Basic usage

```yaml
jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: rob975/setup-oracle-free-lite@v1
```

### Custom password for SYS, SYSTEM and PDBADMIN

```yaml
jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: rob975/setup-oracle-free-lite@v1
        with:
          oracle-pwd: <password>
```

### Startup scripts

```yaml
jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rob975/setup-oracle-free-lite@v1
        with:
          startup-scripts: ${{ github.workspace }}/tests/scripts
```
