# Manage local Gitea database, as supported/needed
class gitea::config::database {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}/init.pp")

  case $gitea::ini['database']['db_type'] {
    'postgres': {
      include 'postgresql'
      postgresql::server::db { $gitea::database_name:
        user     => $gitea::database_user,
        owner    => $gitea::database_user,
        password => postgresql_password($gitea::database_user,
        $gitea::database_password),
        require  => Class['postgresql::server'],
      }
    } default: {
      fail("Database type '${gitea::ini[database][db_type]}' unsupported.")
    }
  }
}
