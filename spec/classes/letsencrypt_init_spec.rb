require 'spec_helper'
describe 'letsencrypt' do
    let :facts do
        {
            osfamily: 'Ubuntu',
            fqdn: 'spec-test.example.com',
            puppetmaster: 'spec-test.example.com'
        }
    end
end
