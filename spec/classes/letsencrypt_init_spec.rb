require 'spec_helper'

describe 'letsencrypt', type: :class do
  let :facts do
    {
      osfamily: 'Debian',
      fqdn: 'spec-test.example.com',
      puppetmaster: 'spec-test.example.com',
      letsencrypt_crts: 'spec-test.example.com',
      letsencrypt_csr_spec-test.example.com: '-----BEGIN CERTIFICATE REQUEST-----
MIICpzCCAY8CAQAwYjELMAkGA1UEBhMCQVQxETAPBgNVBAgMCFNhbHpidXJnMREw
DwYDVQQHDAhTYWx6YnVyZzENMAsGA1UECgwEYnplZDEeMBwGA1UEAwwVc3BlYy10
ZXN0LmV4YW1wbGUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
lc3jPhFUfrfPvvQOd7vtl1+eA4ak6MAEqGL0c6xjyIiaHffNMr1ujPhZIyDuX+a/
vbB4en+FZrq3abSqGEF0+ca/aqluAxR3jQzM231g18UpAppceV/Xz8lOsk4u5vl2
nBW/44GwpwV+rFTjgsNPZ3dDRWaTcyJ8FFxLstf5AWudecnLYEiWeXIpiCYiUZZH
eoO9SUhs77f2S3lU8sAeUGn8L4Xrx70cyhDym7gh2Vwf0LmvulsNvQQPPPEfh3Mp
HQvhqPmRYVl/fAszEEhrElgwCT76LPbvJjs/bYdkDUbT1gv1Lv/4h7xbvc7YsIf9
aIGQGU+Tbc4Bpd1uMQjxwwIDAQABoAAwDQYJKoZIhvcNAQELBQADggEBAF8ytNzr
2HLQaqjPH6ETOi3yiheJe8tNB1bV8YCtffxjPyIkRUONtMTuugD1bWSBz9ZsBIGs
sTsUH1nBXUneinVjCBDM8pWGyyQJ+Sp9mGzO/ozgl/B3Ty54/J7OfE6kAlGibSoX
QOmUGLdsRDGgVmismofs2fam4XDjijVxXMgrdzj22KbcuWmdF3W+9Sn8GpEXW4Nh
T+oIq/TPAl/wym6jo6EeflMlOLo0V4Bb5ylmkPCkLVGwm/ClouxgNSRP/uDDa/kT
MhRrz3+JfoRSK2PgzT1Ai48eTt98YxsBr261KvovbMbnpqPtCfedta33d7EESg32
ssyZggp6vUJnypw=
-----END CERTIFICATE REQUEST-----',
    }
  end
  it { should contain_file('/etc/letsencrypt').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/csr').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/private').with_ensure('directory') }
  it { should contain_file('/etc/letsencrypt/certs').with_ensure('directory') }

end
