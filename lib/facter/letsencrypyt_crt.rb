
require 'facter'

crt_domains = Dir['/opt/letsencrypt/requests/*/*.crt'].map { |a| a.gsub(/\.crt$/, '').gsub(%r{^.*/, ''}) }

Facter.add(:letsencrypt_crts) do
  setcode do
    crt_domains.join(',') if crt_domains
  end
end
