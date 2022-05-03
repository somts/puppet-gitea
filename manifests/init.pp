#
# @summary manage Gitea installation
#
# @param ini Hash of INI values for app.ini
# @param ini_absent Hash of INI values to remove from app.ini
# @param database_manage Boolean to determine if we want to manage a local db
# @param defaults_directory Hash of defaults for directorie(s) managed by this module
# @param defaults_file Hash of defaults for file(s) managed by this module
# @param defaults_group Hash of defaults for group(s) managed by this module
# @param defaults_package Hash of defaults for package(s) managed by this module
# @param defaults_user Hash of defaults for user(s) managed by this module
# @param user gitea user
# @param group gitea user group
# @param path_etc /etc-based path of Gitea
# @param path_home $HOME of the gitea user
# @param path_link path to symlink Gitea binary to EG /usr/local/bin/gitea
# @param path_opt /opt-based path of Gitea
# @param path_piddir directory for pidfile EG /var/run/gitea
# @param path_pid where to write pidfile EG /var/run/gitea/gitea.pid
# @param path_tmp /tmp path for archive download(s)
# @param package_architecture architecture to use for auto_URL EG amd64
# @param package_baseurl Beginning segment of download auto-URL
# @param package_kernel kernel to use for auto-URL EG Linux
# @param package_name package when using package manager. Overrides auto-URL
# @param package_url explicit URL for download. Overrides auto-URL
# @param package_version Gitea Version to install for auto-URL
# @param packages_ensure Extra packages to install EG sqlite3
#
# TODO: uninstall logic via 'ensure => Enum['present', 'absent']
#
# @author SOMTS https://somts.ucsd.edu/
#
class gitea (
  Hash[String[1],Hash[String,Variant[Boolean, Integer, String, Undef]]] $ini,
  Hash[String[1],Array[String[1]]] $ini_absent,
  Boolean $database_manage,
  Hash[String[1],Variant[Boolean, Integer, String, Undef]] $defaults_directory,
  Hash[String[1],Variant[Boolean, Integer, String, Undef]] $defaults_file,
  Hash[String[1],Variant[Boolean, Integer, String, Undef]] $defaults_group,
  Hash[String[1],Variant[Boolean, Integer, String, Undef]] $defaults_package,
  Hash[String[1],Variant[Boolean, Integer, String, Undef]] $defaults_user,
  String[1] $user,
  String[1] $group,
  Stdlib::Absolutepath $path_etc,
  Stdlib::Absolutepath $path_home,
  Stdlib::Absolutepath $path_link,
  Stdlib::Absolutepath $path_opt,
  Stdlib::Absolutepath $path_piddir,
  Stdlib::Absolutepath $path_pid,
  Stdlib::Absolutepath $path_tmp,
  String[1] $package_architecture,
  Stdlib::HTTPUrl $package_baseurl,
  String[1] $package_kernel,
  Variant[String[1], Undef] $package_name,
  Variant[Stdlib::HTTPUrl, Undef] $package_url,
  String[1] $package_version,
  Variant[String[1], Array[String[1]], Undef] $packages_ensure,
) {
  Class['gitea::install'] -> Class['gitea::config'] ~> Class['gitea::service']

  contain gitea::install
  contain gitea::config
  contain gitea::service
}
