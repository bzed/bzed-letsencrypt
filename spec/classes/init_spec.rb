require 'spec_helper'
describe 'letsencrypt' do

  context 'with defaults for all parameters' do
    it { should contain_class('letsencrypt') }
  end
end
