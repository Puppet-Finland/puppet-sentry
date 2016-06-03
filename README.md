[![Puppet Forge](https://img.shields.io/puppetforge/v/venmo/sentry.svg)](https://forge.puppetlabs.com/venmo/sentry)
[![Build Status](https://travis-ci.org/venmo/puppet-sentry.svg?branch=master)](https://travis-ci.org/venmo/puppet-sentry)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What sentry affects](#what-sentry-affects)
    * [Beginning with sentry](#beginning-with-sentry)
4. [Usage](#usage)
    * [Security](#security)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

The sentry module installs, configures, and manages the
[Sentry](http://sentry.readthedocs.org/) realtime event logging and
aggregation platform. It supports Sentry version >= 8.5.0 on
the following platforms:

* Debian 7 (Wheezy)
* Ubuntu 14.04 (Trusty)

## Module Description

Installation is via PyPI or Git, with support for arbitrary PyPI versions
or Git revisions. Configuration supports optional database integration
with MySQL/Postgres, caching/queueing with Redis, and a reverse SSL proxy,
though these must be deployed separately (for which an
[example profile](https://github.com/venmo/puppet-sentry/blob/master/examples/profile.pp)
is provided). Service management is done with
[Supervisor](http://supervisord.org/).

## Setup

### What sentry affects

* A Python virtualenv is created with Sentry and required dependencies.
* A Sentry configuration is generated based on provided class parameters.
* A SQLite database is created and its contents initialized.
* Supervisor is deployed to manage the Sentry web and worker services.

### Beginning with sentry

A basic deploy listening on `http://localhost:9000` can be done with

    include sentry

An admin user is also created for evaluation purposes with username
`admin@localhost` and password `password`.

To specify a PyPI version instead, run

```puppet
class { 'sentry':
  version => '8.5.0'
}
```

or for a specific Git revision (branch, tag, or commit sha1) on
https://github.com/getsentry/sentry/

```puppet
class { 'sentry':
  source_location => 'git',
  git_revision    => 'master',
}
```

Note that installing from Git will also install git and nodejs packages
required for building from source.

## Usage

To allow for more widespread evaluation (say over a VPN), pass extra parameters
like the following (**IMPORTANT**: don't use these values for `password`
and `secret_key`, see [Security](#security) for how to generate your own)

```puppet
class { 'sentry':
  password   => 'password',
  secret_key => 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g==',
  email      => 'sentry@example.com',
  url        => 'http://sentry.example.lan:9000',  # must not have a trailing slash
  host       => '0.0.0.0',
}
```

For a basic production-ready deploy with support for Postgres, Redis, and a
reverse SSL proxy deployed separately on the same host, pass extra parameters
like the following (**IMPORTANT**: don't use these values for `password`
and `secret_key`, see [Security](#security) for how to generate your own)

```puppet
class { 'sentry':
  password        => 'password',  # this should come from an encrypted source like hiera-eyaml
  secret_key      => 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g==',
  email           => 'sentry@example.com',
  url             => 'https://sentry.example.com',  # must not have a trailing slash
  database        => 'postgres',
  database_config => {
    user     => 'sentry',
    password => 'randompassword',  # this should come from an encrypted source like hiera-eyaml
  },
  proxy_enabled   => true,
  redis_enabled   => true,
}
```

For further instructions on preparing a production-ready deploy, see the
parameter list in [Reference](#reference) and the following Sentry
documentation:

* [Initializing the Configuration](http://sentry.readthedocs.org/en/latest/quickstart/index.html#initializing-the-configuration)
* [Configure Redis](http://sentry.readthedocs.org/en/latest/quickstart/index.html#configure-redis)
* [Setup a Reverse Proxy](http://sentry.readthedocs.org/en/latest/quickstart/index.html#setup-a-reverse-proxy)

### Security

The values for `password` and `secret_key` are the admin user's password
and the django secret key respectively. It's important to use your own
values for these as the defaults are insecure.

* `password` can be randomly generated with a shell command like the following:
  `openssl rand -hex 8`
* `secret_key` can be randomly generated with the following Python command:
  `python -c "import os; from base64 import b64encode; print(b64encode(os.urandom(40)))"`

## Reference

### Classes

#### Class: `sentry`

Install Sentry server. See the documentation at `manifests/init.pp`


### Defines

#### Define: `sentry::command`

Execute a sentry command as documented at
[Command Line Usage](http://sentry.readthedocs.org/en/latest/cli/index.html).

##### `command`

The command to execute including any arguments.

##### `refreshonly`

Whether to execute only when an event is received, defaults to `false`.

#### Define: `sentry::plugin`

Installs a sentry plugin as documented at
[Plugins](http://sentry.readthedocs.org/en/latest/plugins/).

##### `plugin`

The plugin to install, typically begins with `sentry-`.

##### `version`

The plugin version to install, defaults to latest.

## Limitations

* Upgrades are not handled automatically, but must be
  done as documented at
  [Upgrading](https://docs.getsentry.com/on-premise/server/upgrading/).
* Multiple Redis servers are not currently supported.

## Development

Pull requests are highly encouraged, please read the guidelines in
[CONTRIBUTING](https://github.com/venmo/puppet-sentry/blob/master/CONTRIBUTING.md)
before submitting. Tests are run by [Travis CI](https://travis-ci.org/).
