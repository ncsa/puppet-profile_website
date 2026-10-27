# frozen_string_literal: true

require 'spec_helper'

describe 'profile_website::php' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with handler => fpm' do
        let(:params) { { enable: true, handler: 'fpm' } }

        it { is_expected.to contain_class('apache::mod::dir') }
        it { is_expected.to contain_class('apache::mod::proxy_fcgi') }
        it { is_expected.not_to contain_class('apache::mod::php') }
        it { is_expected.to contain_apache__custom_config('php-fpm').with_content(%r{SetHandler "proxy:fcgi://127.0.0.1:9000"}) }
      end
    end
  end
end
