# == Class: sentry::config
#
# This class is called from sentry for service config.
#
class sentry::config
{
  $password       = $sentry::password
  $secret_key     = $sentry::secret_key
  $email          = $sentry::email
  $url            = $sentry::url
  $url_path       = $sentry::url_path
  $host           = $sentry::host
  $port           = $sentry::port
  $workers        = $sentry::workers
  $database       = $sentry::database
  $beacon_enabled = $sentry::beacon_enabled
  $email_enabled  = $sentry::email_enabled
  $proxy_enabled  = $sentry::proxy_enabled
  $redis_enabled  = $sentry::redis_enabled
  $extra_config   = $sentry::extra_config

  $filestore_location = $sentry::params::filestore_location

  $config = {
    'database' => merge(
      $sentry::params::database_config_default,
      $sentry::database_config
    ),
    'email'    => merge(
      $sentry::params::email_config_default,
      $sentry::email_config
    ),
    'redis'    => merge(
      $sentry::params::redis_config_default,
      $sentry::redis_config
    ),
  }

  file { "${sentry::path}/sentry.conf.py":
    ensure  => present,
    content => template('sentry/sentry.conf.py.erb'),
    owner   => $sentry::owner,
    group   => $sentry::group,
    mode    => '0640',
  } ->

  file { "${sentry::path}/config.yml":
    ensure  => present,
    content => template('sentry/sentry.config.yml.erb'),
    owner   => $sentry::owner,
    group   => $sentry::group,
    mode    => '0640',
  } ->

  file { "${sentry::path}/.initialized":
    ensure  => present,
    content => 'This file tells Puppet to avoid running an upgrade again on config change',
    owner   => $sentry::owner,
    group   => $sentry::group,
  } ~>

  sentry::command { 'postconfig_upgrade':
    command     => 'upgrade --noinput',
    refreshonly => true,
  } ~>

  sentry::command { 'create_superuser':
    command     => join([
      'createuser',
      "--email='${email}'",
      '--superuser',
      "--password='${password}'",
      '--no-input'
    ], ' '),
    refreshonly => true,
  }
}
