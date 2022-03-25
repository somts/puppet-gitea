require 'spec_helper'

describe 'gitea::service' do
  let :node do
    'example.com'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} " do
      let :facts do
        os_facts
      end

      context 'with all defaults' do
        it do
          is_expected.to compile.and_raise_error(
            /Must only be called by gitea\/init\.pp/)
        end
      end

    end
  end
end
