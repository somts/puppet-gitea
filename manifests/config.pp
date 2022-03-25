# Configure Gitea
#
# For Gitea .ini settings details, see
# https://docs.gitea.io/en-us/config-cheat-sheet/
#
class gitea::config {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}/init.pp")

  # Remove deprecated/unwanted settings
  $gitea::ini_absent.each |String $section, Array $keys| {
    $keys.each |String $key| {
      ini_setting { "ini-${section.downcase}-${key.downcase}":
        ensure  => 'absent',
        path    => "${gitea::path_etc}/app.ini",
        section => $section,
        setting => $key.upcase,
      }
    }
  }

  # Add enforced settings.  We do this instead of manage the whole
  # app.ini file as Gitea itself tends to edit this file too
  $gitea::ini.each |String $section, Hash $pairs| {
    delete_undef_values($pairs).each |String $key, $val| {

      # Validate $gitea::ini's nested values here, since it is
      # delivered as one big hash. NOTE: we call delete_undef_values()
      # on hash pairs before getting to this scope; a side-effect of
      # that is that we do not need to detect if a value is Undef.
      case $section {
        'DEFAULT': {
          case $key {
            'app_name', 'run_user': {
              assert_type(String, $val)
            } 'run_mode': {
              assert_type(Enum['dev','prod','test'], $val)
            } default: {
              # DEFAULT only has 3 keys
              fail("Key ${key} not supported in ${section}")
            }
          }
        } 'database': {
          case $key {
            'charset': {
              assert_type(Enum['utf8','utf8mb4'], $val)
            } 'db_type': {
              assert_type(Enum['mysql', 'postgres', 'mssql', 'sqlite3'], $val)
            } 'host', 'name', 'passwd': {
              assert_type(String[1], $val)
            } 'path': {
              assert_type(Stdlib::Unixpath, $val)
            } 'ssl_mode': {
              assert_type(Variant[Boolean, Enum['disable', 'skip-verify',
              'prefer', 'require', 'verify-ca', 'verify-full',]], $val)
            } default: {}  #NOOP
          }
        } 'lfs': {
          case $key {
            'path': {
              assert_type(Stdlib::Unixpath, $val)
            } 'storage_type': {
              assert_type(Enum['local','minio'], $val)
            } default: {}  #NOOP
          }
        } 'log': {
          case $key {
            'enable_ssh_log': {
              assert_type(Boolean, $val)
            } 'level': {
              assert_type(Enum['Trace', 'Debug', 'Info', 'Warn',
              'Error', 'Critical', 'Fatal', 'None'], $val)
            } 'mode', 'router': {
              assert_type(String, $val)
            } 'root_path': {
              assert_type(Stdlib::Unixpath, $val)
            } default: {}  #NOOP
          }
        } 'mailer': {
          case $key {
            'enabled': {
              assert_type(Boolean, $val)
            } default: {}  #NOOP
          }
        } 'picture': {
          case $key {
            'disable_gravatar', 'enable_federated_avatar': {
              assert_type(Boolean, $val)
            } default: {}  #NOOP
          }
        } 'repository': {
          case $key {
            'root': {
              assert_type(Stdlib::Unixpath, $val)
            } default: {}  #NOOP
          }
        } 'security': {
          case $key {
            'disable_git_hooks', 'install_lock': {
              assert_type(Boolean, $val)
            } default: {}  #NOOP
          }
        } 'server': {
          case $key {
            'app_data_path': {
              assert_type(Stdlib::Absolutepath, $val)
            } 'disable_ssh': {
              assert_type(Boolean, $val)
            } 'domain': {
              assert_type(Stdlib::Fqdn, $val)
            } 'http_addr': {
              assert_type(Stdlib::IP::Address, $val)
            } 'http_port', 'ssh_port': {
              assert_type(Stdlib::Port, $val)
            } 'http_protocol': {
              assert_type(Enum['http', 'https', 'fcgi', 'http+unix',
              'fcgi+unix', 'unix'], $val)
            } 'lfs_start_server', 'start_ssh_server': {
              assert_type(Boolean, $val)
            } default: {}  #NOOP
          }
        } 'service': {
          case $key {
            'disable_registration': {
              assert_type(Boolean, $val)
            } default: {}  #NOOP
          }
        } default: {
          #NOOP
        }
      }

      # Downcase the Puppet resource name(s), upcase the Gitea
      # app.ini key name(s)
      ini_setting { "ini-${section.downcase}-${key.downcase}":
        ensure  => 'present',
        path    => "${gitea::path_etc}/app.ini",
        section => $section,
        setting => $key.upcase,
        value   => $val,
      }
    }
  }

  # Manage local database when set to do so
  if $gitea::database_manage and 'database' in $gitea::ini and
  $gitea::ini['database']['db_type'] in ['postgres', 'mysql', 'mssql'] {
    contain 'gitea::config::database'
  }
}
