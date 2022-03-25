# Manage the Gitea service
class gitea::service {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}/init.pp")

  service { 'gitea':
    ensure => 'running',
    enable => true,
  }

  case $facts['kernel'] {
    'FreeBSD': {
      #NOOP
      # service file lives at /usr/local/etc/rc.d/gitea
    } 'Linux': {
      systemd::unit_file { 'gitea.service':
        content => epp("${module_name}/gitea.service.epp", {
            app_name       => $gitea::ini['DEFAULT']['app_name'],
            db_manage      => $gitea::database_manage,
            db_type        => $gitea::ini['database']['db_type'],
            etc            => $gitea::path_etc,
            gitea_custom   => $gitea::path_etc,
            gitea_group    => $gitea::group,
            gitea_user     => $gitea::user,
            gitea_work_dir => $gitea::path_home,
            home           => $gitea::path_home,
            pidfile        => $gitea::path_pid,
            procname       => $gitea::install::path_exe,
        }),
        notify  => Service['gitea'],
      }
    } default: {
      fail("${facts['kernel']} is unsupported")
    }
  }
}
