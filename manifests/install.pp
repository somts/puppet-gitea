# @summary Manage the installation of Gitea
class gitea::install {
  # This class only makes sense when called from init.pp
  assert_private("Must only be called by ${module_name}/init.pp")

  ## VARIABLES

  # Build the app URL when not provided. Downcase kernel string.
  $package_url = $gitea::package_url ? {
    undef   => join([
        $gitea::package_baseurl,
        '/',
        $gitea::package_version,
        '/gitea-',
        $gitea::package_version,
        '-',
        $gitea::package_kernel.downcase,
        '-',
        $gitea::package_architecture,
    ], ''),
    default => $gitea::package_url,
  }

  # Once we know our URL, use the basename for our archive path
  # Conditionally set several variables based on .xz compression
  # EG https://dl.gitea.io/gitea/1.16.4/gitea-1.16.4-linux-arm64
  $path_exe = "${gitea::path_opt}/bin/${package_url.split('/')[-1]}"

  ## MANAGED RESOURCES

  group { $gitea::group: * => $gitea::defaults_group }

  user { $gitea::user:
    * => $gitea::defaults_user + {
      home    => $gitea::path_home,
      groups  => [$gitea::group],
      require => Group[$gitea::group],
    },
  }

  file {
    "${gitea::path_etc}/app.ini":
      * => $gitea::defaults_file + {
        group   => $gitea::group,
        require => Group[$gitea::group],
      };
    $gitea::path_home:
      * => $gitea::defaults_directory + {
        group   => $gitea::group,
        mode    => '2750',  # sticky bit on
        owner   => $gitea::user,
        require => User[$gitea::user],
      };
  }

  if $gitea::package_name {
    # Install from package manager per
    # https://docs.gitea.io/en-us/install-from-package/

    package { 'gitea':
      * => $gitea::defaults_package + {
        name   => $gitea::package_name,
        before => User[$gitea::user],
      },
    }

  } else {
    # Install from binary download per
    # https://docs.gitea.io/en-us/install-from-binary/

    # Attempt to remove package, avoiding collisions with /usr/local
    package { 'gitea':
      ensure => 'absent',
      before => File[$gitea::path_link],
    }

    file {
      $gitea::path_etc:
        * => $gitea::defaults_directory + {
          group   => $gitea::group,
          require => Group[$gitea::group],
        };
      $gitea::path_opt:
        * => $gitea::defaults_directory + {
          group   => $gitea::group,
          require => Group[$gitea::group],
        };
      "${gitea::path_opt}/bin":
        * => $gitea::defaults_directory + {
          group   => $gitea::group,
          require => Group[$gitea::group],
        };
      $path_exe:
        group   => $gitea::group,
        mode    => '0750',
        source  => $package_url,
        require => File["${gitea::path_opt}/bin"],;
      $gitea::path_link:  # convenience link, EG run `gitea admin`
        ensure  => 'link',
        target  => $path_exe,
        group   => $gitea::group,
        require => Archive['gitea'],;
    }
  }

  if $gitea::packages_ensure != undef {
    ensure_packages($gitea::packages_ensure)
  }
}
