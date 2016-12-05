
require 'facter'

begin
  basedir = File.read("/etc/letsencrypt.handler_basedir").chomp
rescue
  basedir = "/opt/letsencrypt"
end
crt_domains = Dir["#{basedir}/requests/*/*.crt"].map { |a| a.gsub(%r{\.crt$}, '').gsub(%r{^.*/}, '') }

Facter.add(:letsencrypt_crts) do
  setcode do
    crt_domains.join(',') if crt_domains
  end
end
