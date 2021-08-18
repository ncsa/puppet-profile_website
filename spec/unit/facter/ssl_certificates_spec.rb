# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/ssl_certificates'

describe :ssl_certificates, type: :fact do
  subject(:fact) { Facter.fact(:ssl_certificates) }

  before :each do
    # perform any action that should be run before every test
    Facter.clear
  end

  it 'returns a value' do
    expect(fact.value).to eq('hello facter')
  end
end
