
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

crt_domains.each do | crt_domain |
    Facter.add("letsencrypt_crt_" + crt_domain) do
        setcode do
            crt = File.read("/opt/letsencrypt/requests/#{crt_domain}/#{crt_domain}.crt")
            if (crt =~ /.*BEGIN CERTIFICATE.*/)
                crt
            else
                nil
            end
        end
    end
end

