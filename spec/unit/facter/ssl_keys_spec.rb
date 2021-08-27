# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/ssl_keys'

describe :ssl_keys, type: :fact do
  subject(:fact) { Facter.fact(:ssl_keys) }

  before :each do
    # perform any action that should be run before every test
    Facter.clear
  end

  it 'returns a value' do
    expect(fact.value).to eq('hello facter')
  end
end
