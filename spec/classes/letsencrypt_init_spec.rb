require 'spec_helper'

describe 'letsencrypt', type: :class do
  let :facts do
    {
      osfamily: 'Debian',
      fqdn: 'spectest',
      puppetmaster: 'spectest',
      letsencrypt_crts: 'spectest',
      letsencrypt_csr_spectest: '-----BEGIN CERTIFICATE REQUEST-----\nMIICpzCCAY8CAQAwYjELMAkGA1UEBhMCQVQxETAPBgNVBAgMCFNhbHpidXJnMREw\nDwYDVQQHDAhTYWx6YnVyZzENMAsGA1UECgwEYnplZDEeMBwGA1UEAwwVc3BlYy10\nZXN0LmV4YW1wbGUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA\nlc3jPhFUfrfPvvQOd7vtl1+eA4ak6MAEqGL0c6xjyIiaHffNMr1ujPhZIyDuX+a/\nvbB4en+FZrq3abSqGEF0+ca/aqluAxR3jQzM231g18UpAppceV/Xz8lOsk4u5vl2\nnBW/44GwpwV+rFTjgsNPZ3dDRWaTcyJ8FFxLstf5AWudecnLYEiWeXIpiCYiUZZH\neoO9SUhs77f2S3lU8sAeUGn8L4Xrx70cyhDym7gh2Vwf0LmvulsNvQQPPPEfh3Mp\nHQvhqPmRYVl/fAszEEhrElgwCT76LPbvJjs/bYdkDUbT1gv1Lv/4h7xbvc7YsIf9\naIGQGU+Tbc4Bpd1uMQjxwwIDAQABoAAwDQYJKoZIhvcNAQELBQADggEBAF8ytNzr\n2HLQaqjPH6ETOi3yiheJe8tNB1bV8YCtffxjPyIkRUONtMTuugD1bWSBz9ZsBIGs\nsTsUH1nBXUneinVjCBDM8pWGyyQJ+Sp9mGzO/ozgl/B3Ty54/J7OfE6kAlGibSoX\nQOmUGLdsRDGgVmismofs2fam4XDjijVxXMgrdzj22KbcuWmdF3W+9Sn8GpEXW4Nh\nT+oIq/TPAl/wym6jo6EeflMlOLo0V4Bb5ylmkPCkLVGwm/ClouxgNSRP/uDDa/kT\nMhRrz3+JfoRSK2PgzT1Ai48eTt98YxsBr261KvovbMbnpqPtCfedta33d7EESg32\nssyZggp6vUJnypw=\n-----END CERTIFICATE REQUEST-----'
    }
  end
  #  it { should contain_file('/etc/letsencrypt').with_ensure('directory') }
  #  it { should contain_file('/etc/letsencrypt/csr').with_ensure('directory') }
  #  it { should contain_file('/etc/letsencrypt/private').with_ensure('directory') }
  #  it { should contain_file('/etc/letsencrypt/certs').with_ensure('directory') }
end
