
require 'facter'

csr_domains = Dir['/etc/letsencrypt/csr/*.csr'].map { |a| a.gsub(/\.csr$/, '').gsub(%r{^.*/, ''}) }

Facter.add(:letsencrypt_csrs) do
  setcode do
    csr_domains.join(',') if csr_domains
  end
end

csr_domains.each do |csr_domain|
  Facter.add('letsencrypt_csr_' + csr_domain) do
    setcode do
      csr = File.read("/etc/letsencrypt/csr/#{csr_domain}.csr")
      csr
    end
  end
end
