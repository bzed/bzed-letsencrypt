
require 'facter'

begin
  basedir = File.read("/etc/letsencrypt.basedir").chomp
rescue
  basedir = "/etc/letsencrypt"
end
csr_domains = Dir["#{basedir}/csr/*.csr"].map { |a| a.gsub(%r{\.csr$}, '').gsub(%r{^.*/}, '') }

Facter.add(:letsencrypt_basedir) do
  setcode do
      basedir
  end
end
  
Facter.add(:letsencrypt_csrs) do
  setcode do
    csr_domains.join(',') if csr_domains
  end
end

csr_domains.each do |csr_domain|
  Facter.add('letsencrypt_csr_' + csr_domain) do
    setcode do
      csr = File.read("#{basedir}/csr/#{csr_domain}.csr")
      csr
    end
  end
end
