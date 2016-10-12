require 'spec_helper'

describe 'letsencrypt', type: :class do
  let :facts do
    {
      osfamily: 'Debian',
      fqdn: 'spec-test.example.com',
      puppetmaster: 'spec-test.example.com'
    }
  end
  it { should contain_file('/etc/letsencrypt').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/csr').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/private').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/certs').with_ensure('directory') }

end
