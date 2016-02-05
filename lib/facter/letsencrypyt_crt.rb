
require 'facter'


crt_domains = Dir['/opt/letsencrypt/requests/*/*.crt'].map{|a| a.gsub(/\.crt$/, '').gsub(/^.*\//, '') }

Facter.add(:letsencrypt_crts) do
    setcode do
        if crt_domains
            crt_domains.join(',')
        else
            nil
        end
    end
end

