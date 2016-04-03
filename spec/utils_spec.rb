require 'spec_helper'
require_relative '../lib/utils'

describe Utils do
  context 'date conversion' do
    it { expect(Utils.convert_date('10/20/2015')).to eql('20/10/2015') }
  end
end
