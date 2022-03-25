require 'spec_helper'

describe 'gitea' do
  shared_examples 'Supported Platform' do
    it do
      is_expected.to contain_class(
        'gitea::install',
      ).that_comes_before('Class[gitea::config]')
    end
    it do
      is_expected.to contain_class(
        'gitea::config',
      ).that_notifies('Class[gitea::service]')
    end
    it { is_expected.to contain_class('gitea::service') }

    ## Gitea::Install
    it do
      is_expected.to contain_group('git').with(
        ensure: 'present',
      )
    end
    it do
      is_expected.to contain_user('git').with(
        ensure: 'present',
        groups: ['git'],
        managehome: true,
        system: true,
        require: 'Group[git]',
      )
    end

    ## Gitea::Config
    it do
      is_expected.not_to contain_class('gitea::config::database')
    end
    it do
      is_expected.to contain_ini_setting('ini-database-db_type').with(
        ensure: 'present',
        section: 'database',
        setting: 'DB_TYPE',
        value: 'sqlite3',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-database-host').with(
        ensure: 'present',
        section: 'database',
        setting: 'HOST',
        value: '127.0.0.1:3306',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-database-name').with(
        ensure: 'present',
        section: 'database',
        setting: 'NAME',
        value: 'gitea',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-database-user').with(
        ensure: 'present',
        section: 'database',
        setting: 'USER',
        value: 'root',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-default-app_name').with(
        ensure: 'present',
        section: 'DEFAULT',
        setting: 'APP_NAME',
        value: 'Gitea: Git with a cup of tea',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-default-run_mode').with(
        ensure: 'present',
        section: 'DEFAULT',
        setting: 'RUN_MODE',
        value: 'prod',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-default-run_user').with(
        ensure: 'present',
        section: 'DEFAULT',
        setting: 'RUN_USER',
        value: 'git',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-repository-root').with(
        ensure: 'present',
        section: 'repository',
        setting: 'ROOT',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-security-disable_git_hooks').with(
        ensure: 'present',
        section: 'security',
        setting: 'DISABLE_GIT_HOOKS',
        value: true,
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-domain').with(
        ensure: 'present',
        section: 'server',
        setting: 'DOMAIN',
        value: 'localhost',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-http_addr').with(
        ensure: 'present',
        section: 'server',
        setting: 'HTTP_ADDR',
        value: '127.0.0.1',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-http_port').with(
        ensure: 'present',
        section: 'server',
        setting: 'HTTP_PORT',
        value: 3000,
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-lfs_start_server').with(
        ensure: 'present',
        section: 'server',
        setting: 'LFS_START_SERVER',
        value: false,
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-protocol').with(
        ensure: 'present',
        section: 'server',
        setting: 'PROTOCOL',
        value: 'http',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-server-root_url').with(
        ensure: 'present',
        section: 'server',
        setting: 'ROOT_URL',
        value: '%(PROTOCOL)s://%(DOMAIN)s:%(HTTP_PORT)s/',
      )
    end

    ['ini-indexer-issue_indexer_queue_batch_number',
     'ini-indexer-issue_indexer_queue_conn_str',
     'ini-indexer-issue_indexer_queue_dir',
     'ini-indexer-issue_indexer_queue_type',
     'ini-indexer-update_buffer_len',
     'ini-mailer-send_buffer_len',
     'ini-repository-mirror_queue_length',
     'ini-repository-pull_request_queue_length',
     'ini-server-lfs_content_path'].each do |i|
      it do
        is_expected.to contain_ini_setting(i).with_ensure('absent')
      end
    end

    ## Gitea::Service
  end

  shared_examples 'Linux' do
    it do
      is_expected.to contain_user('git').with_home('/var/opt/gitea')
    end
    it do
      is_expected.to contain_file('/opt/gitea/etc').with(
        ensure: 'directory',
        owner: 'root',
        group: 'git',
        mode: '0750',
        require: 'Group[git]',
      )
    end
    it do
      is_expected.to contain_file('/opt/gitea').with(
        ensure: 'directory',
        owner: 'root',
        group: 'git',
        mode: '0750',
        require: 'Group[git]',
      )
    end
    it do
      is_expected.to contain_file('/opt/gitea/bin').with(
        ensure: 'directory',
        owner: 'root',
        group: 'git',
        mode: '0750',
        require: 'Group[git]',
      )
    end
    it do
      is_expected.to contain_file('/opt/gitea/etc/app.ini').with(
        ensure: 'file',
        owner: 'root',
        group: 'git',
        mode: '0640',
      )
    end
    it do
      is_expected.to contain_file('/var/opt/gitea').with(
        ensure: 'directory',
        owner: 'git',
        group: 'git',
        mode: '2750',
        require: 'User[git]',
      )
    end
    it do
      is_expected.to contain_archive('gitea').with(
        path: '/tmp/gitea-1.16.4-linux-amd64.xz',
        cleanup: true,
        creates: '/opt/gitea/bin/gitea-1.16.4-linux-amd64',
        extract: true,
        extract_path: '/opt/gitea/bin',
        group: 'git',
        source: 'https://dl.gitea.io/gitea/1.16.4/gitea-1.16.4-linux-amd64.xz',
        require: 'File[/opt/gitea/bin]',
      )
    end

    ## Gitea::Config
    ['ini-database-db_type', 'ini-database-host', 'ini-database-name',
     'ini-database-path', 'ini-database-ssl_mode', 'ini-database-user',
     'ini-default-app_name', 'ini-default-run_mode', 'ini-default-run_user',
     'ini-lfs-path', 'ini-lfs-storage_type', 'ini-log-enable_ssh_log',
     'ini-log-level', 'ini-log-mode', 'ini-log-root_path', 'ini-log-router',
     'ini-mailer-enabled', 'ini-picture-disable_gravatar',
     'ini-picture-enable_federated_avatar', 'ini-repository-root',
     'ini-security-disable_git_hooks', 'ini-server-disable_ssh',
     'ini-server-domain', 'ini-server-http_addr', 'ini-server-http_port',
     'ini-server-lfs_content_path', 'ini-server-lfs_start_server',
     'ini-server-offline_mode', 'ini-server-protocol',
     'ini-server-root_url', 'ini-server-ssh_domain',
     'ini-server-ssh_port'].each do |i|
      it do
        is_expected.to contain_ini_setting(i).with_path(
          '/opt/gitea/etc/app.ini',
        )
      end
    end
    it do
      is_expected.to contain_ini_setting('ini-repository-root').with(
        value: '/var/opt/gitea/data/gitea-repositories',
      )
    end

    ## Gitea::Install
    it { is_expected.to contain_package('gitea').with_ensure('absent') }

    ## Gitea::Service
    it do
      is_expected.to contain_systemd__unit_file(
        'gitea.service',
      ).with_content(%r{Group=git\n}).with_content(%r{User=git\n})
    end
    it do
      is_expected.to contain_service('gitea').with(
        ensure: 'running',
        enable: true,
      )
    end
  end

  shared_examples 'FreeBSD' do
    # TODO: x86_64 and arm64 architectures

    # Gitea::Install
    it { is_expected.not_to contain_package('xz') }
    it { is_expected.to contain_package('git') }
    it { is_expected.to contain_package('git-lfs') }
    it { is_expected.to contain_package('gitea') }
    it { is_expected.to contain_package('sqlite3') }

    it do
      is_expected.to contain_user('git').with_home('/usr/local/git')
    end
    it do
      is_expected.not_to contain_file('/usr/local/etc/gitea/conf').with(
        ensure: 'directory',
        owner: 'root',
        group: 'git',
        mode: '0750',
        require: 'User[git]',
      )
    end
    it do
      is_expected.not_to contain_file('/usr/local/etc/gitea/conf/app.ini').with(
        ensure: 'file',
        owner: 'root',
        group: 'git',
        mode: '0640',
        require: 'File[/usr/local/etc/gitea/conf]',
      )
    end
    it do
      is_expected.to contain_file('/usr/local/git').with(
        ensure: 'directory',
        owner: 'git',
        group: 'git',
        mode: '2750',
        require: 'User[git]',
      )
    end

    ## Gitea::Config
    ['ini-database-db_type', 'ini-database-host', 'ini-database-name',
     'ini-database-path', 'ini-database-ssl_mode', 'ini-database-user',
     'ini-default-app_name', 'ini-default-run_mode', 'ini-default-run_user',
     'ini-indexer-issue_indexer_path', 'ini-lfs-path', 'ini-lfs-storage_type',
     'ini-log-enable_ssh_log', 'ini-log-level', 'ini-log-mode',
     'ini-log-root_path', 'ini-log-router', 'ini-mailer-enabled',
     'ini-picture-avatar_upload_path', 'ini-picture-disable_gravatar',
     'ini-picture-enable_federated_avatar', 'ini-repository.upload-temp_path',
     'ini-repository-root', 'ini-repository-script_type',
     'ini-security-disable_git_hooks', 'ini-server-disable_ssh',
     'ini-server-domain', 'ini-server-http_addr', 'ini-server-http_port',
     'ini-server-lfs_content_path', 'ini-server-lfs_start_server',
     'ini-server-offline_mode', 'ini-server-app_data_path',
     'ini-server-protocol', 'ini-server-root_url', 'ini-server-ssh_domain',
     'ini-server-ssh_port', 'ini-service-enable_captcha',
     'ini-service-enable_notify_mail', 'ini-service-register_email_confirm',
     'ini-service-require_signin_view', 'ini-session-provider',
     'ini-session-provider_config'].each do |i|
      it do
        is_expected.to contain_ini_setting(i).with_path(
          '/usr/local/etc/gitea/conf/app.ini',
        )
      end
    end
    it do
      is_expected.to contain_ini_setting('ini-database-path').with_value(
        '/var/db/gitea/gitea.db',
      )
    end
    it do
      is_expected.to contain_ini_setting('ini-repository-root').with(
        value: '/var/db/gitea/gitea-repositories',
      )
    end
  end

  shared_examples 'Debian-family' do
    # Gitea::Install
    it { is_expected.to contain_package('sqlite3') }
    it { is_expected.to contain_package('sqlite3-doc') }
    it { is_expected.to contain_package('xz-utils') }
  end

  shared_examples 'RedHat-family' do
    # Gitea::Install
    it { is_expected.to contain_package('sqlite') }
    it { is_expected.to contain_package('xz') }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} " do
      let :facts do
        os_facts
      end

      it { is_expected.to compile.with_all_deps }
      it_behaves_like 'Supported Platform'

      case os_facts[:kernel]
      when 'FreeBSD'
        it_behaves_like 'FreeBSD'
      when 'Linux' then
        it_behaves_like 'Linux'
      end

      case os_facts[:os]['family']
      when 'Debian'
        it_behaves_like 'Debian-family'
      when 'OracleLinux', 'RedHat'
        it_behaves_like 'RedHat-family'
      end

      # Linux OSes that support ARM, but need to download an
      # architecture-specific binary
      case os_facts[:os]['name']
      when 'Debian', 'OracleLinux', 'Ubuntu' then
        # Test various architectures
        ['amd64', 'armv5te', 'armv6h', 'armv7l', 'aarch64'].each do |i|
          context "Explicit #{i} architecture on #{os_facts[:os]['name']}" do
            let :facts do
              os_facts.merge({ architecture: i })
            end

            a = case i
                when 'aarch64' then 'arm64'
                when %r{^armv5} then 'arm-5'
                when %r{^armv[6-7]} then 'arm-6'
                else i
                end

            it do
              is_expected.to contain_archive('gitea').with(
                path: "/tmp/gitea-1.16.4-linux-#{a}.xz",
                creates: "/opt/gitea/bin/gitea-1.16.4-linux-#{a}",
                source: "https://dl.gitea.io/gitea/1.16.4/gitea-1.16.4-linux-#{a}.xz",
              )
            end
          end
        end
      end
    end
  end
end
