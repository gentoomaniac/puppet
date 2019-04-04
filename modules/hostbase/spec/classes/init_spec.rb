require 'spec_helper'
describe 'hostbase' do
  context 'with default values for all parameters' do
    it { should contain_class('hostbase') }
  end
end
