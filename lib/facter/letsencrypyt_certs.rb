
require 'facter'

crt_domains = Dir['/etc/letsencrypt/certs/*.crt'].map { |a| a.gsub(%r{\.crt$}, '').gsub(%r{^.*/}, '') }

Facter.add(:letsencrypt_certs) do
  setcode do
    crt_domains
  end
end
