require 'spec_helper'
describe 'dockerce' do
  context 'with default values for all parameters' do
    it { should contain_class('dockerce') }
  end
end
