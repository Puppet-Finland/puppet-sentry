# == Class: sentry::service
#
# This class is meant to be called from sentry.
# It ensures the service is running.
#
class sentry::service
{
  $command = join([
    "${sentry::path}/virtualenv/bin/sentry",
    "--config=${sentry::path}"
  ], ' ')

  Supervisor::Process {
    ensure => present,
    cwd    => $sentry::path,
    user   => $sentry::owner,
  }

  anchor { 'sentry::service::begin': } ->

  supervisor::process {
    'sentry-http':
      command => "${command} start http",
    ;
    'sentry-worker':
      command => "${command} run worker -l WARNING",
    ;
    'sentry-cron':
      command => "${command} run cron -l WARNING",
    ;
  } ->

  anchor { 'sentry::service::end': }
}
