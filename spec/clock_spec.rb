# frozen_string_literal: true

RSpec.describe DbmsBuffers::ClockBuffer do
  it 'initializes correctly' do
    buffer = DbmsBuffers::ClockBuffer.new(3)
    expect(buffer.size).to be 3
    expect(buffer.used).to be 0
  end

  it 'contains just referenced entry' do
    buffer = DbmsBuffers::ClockBuffer.new(2)
    buffer.access('a')
    expect(buffer.used).to be 1
    expect(buffer.contains?('a')).to be true
    expect(buffer.clock_value_of('a')).to be 1
  end

  it 'does not contain same entry twice' do
    buffer = DbmsBuffers::ClockBuffer.new(2)
    buffer.access('a')
    buffer.access('a')
    expect(buffer.used).to be 1
    expect(buffer.contains?('a')).to be true
    expect(buffer.clock_value_of('a')).to be 1
  end

  it 'can hold multiple entries' do
    buffer = DbmsBuffers::ClockBuffer.new(2)
    buffer.access('a')
    buffer.access('b')
    expect(buffer.used).to be 2
    expect(buffer.contains?('a')).to be true
    expect(buffer.clock_value_of('a')).to be 1
    expect(buffer.contains?('b')).to be true
    expect(buffer.clock_value_of('b')).to be 1
  end

  it 'gives second chance' do
    buffer = DbmsBuffers::ClockBuffer.new(2)
    buffer.access :a
    buffer.access :b
    buffer.access :c

    expect(buffer.contains?(:a) ^ buffer.contains?(:b)).to be true

    [:a, :b].each do |left_key|
      next unless buffer.contains? left_key

      expect(buffer.clock_value_of(left_key)).to be 0
      buffer.access left_key
      expect(buffer.clock_value_of(left_key)).to be 1
    end
  end
end
