Setup Oracle Database Free Lite
###############################

.. |CI| image:: https://github.com/rob975/setup-oracle-free-lite/actions/workflows/ci.yml/badge.svg
  :target: https://github.com/rob975/setup-oracle-free-lite/actions/workflows/ci.yml
  :alt: CI

.. |Dependabot Updates| image:: https://github.com/rob975/setup-oracle-free-lite/actions/workflows/dependabot/dependabot-updates/badge.svg
  :target: https://github.com/rob975/setup-oracle-free-lite/actions/workflows/dependabot/dependabot-updates
  :alt: Dependabot Updates

.. |Release| image:: https://img.shields.io/github/v/release/rob975/setup-oracle-free-lite
   :alt: Release

|CI| |Dependabot Updates| |Release|

`GitHub Action <https://docs.github.com/actions>`_ to set up an Oracle Database using
`Oracle Database 23ai Free Lite Container images <https://container-registry.oracle.com/ords/ocr/ba/database/free>`_.

.. list-table::

  * - ⚠️
    - Only Linux `runners <https://github.com/actions/runner-images>`_ are supported.

Oracle Database 23ai Free Lite Container image contains a pre-built database,
so the startup time is very fast.

Inputs
******

No input using ``step.with`` keys is required but some are defined to customize
the database.

.. list-table::
  :widths: 15 15 70
  :header-rows: 1

  * - Name
    - Default
    - Description
  * - tag
    - latest-lite
    - Image tag from `Oracle Container Registry <https://container-registry.oracle.com/ords/ocr/ba/database/free>`_.

      Must contain hyphen delimited ``lite`` word.
  * - container-name
    - oracle-db
    - Container name.
  * - oracle-pwd
    - *auto generated*
    - SYS, SYSTEM and PDBADMIN password.
  * - oracle-pdb
    - FREEPDB1
    - Pluggable database name.
  * - port
    - 1521
    - Port for database connections.
  * - startup-scripts
    - *none*
    - Absolute path to startup scripts directory.
  * - readiness-retries
    - 10
    - Readiness check retries before exiting with error.

      Checks are performed every 10 seconds.

Usage
*****

Basic usage
===========

.. code-block:: yaml

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: rob975/setup-oracle-free-lite@v1

Custom password for SYS, SYSTEM and PDBADMIN
============================================

.. code-block:: yaml

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: rob975/setup-oracle-free-lite@v1
          with:
            oracle-pwd: <password>

Start up scripts
================

.. code-block:: yaml

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: rob975/setup-oracle-free-lite@v1
          with:
            startup-scripts: ${{ github.workspace }}/tests/scripts/oracle
