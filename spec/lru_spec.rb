# frozen_string_literal: true

RSpec.describe DbmsBuffers::LRUBuffer do
  it 'initializes correctly' do
    buffer = DbmsBuffers::LRUBuffer.new(3)
    expect(buffer.size).to be 3
    expect(buffer.used).to be 0
  end

  it 'contains just referenced entry' do
    buffer = DbmsBuffers::LRUBuffer.new(2)
    buffer.access('a')
    expect(buffer.used).to be 1
    expect(buffer.contains?('a')).to be true
  end

  it 'does not contain same entry twice' do
    buffer = DbmsBuffers::LRUBuffer.new(2)
    buffer.access('a')
    buffer.access('a')
    expect(buffer.used).to be 1
    expect(buffer.contains?('a')).to be true
  end

  it 'can hold multiple entries' do
    buffer = DbmsBuffers::LRUBuffer.new(2)
    buffer.access('a')
    buffer.access('b')
    expect(buffer.used).to be 2
    expect(buffer.contains?('a')).to be true
    expect(buffer.contains?('b')).to be true
  end

  it 'removes last used' do
    buffer = DbmsBuffers::LRUBuffer.new(2)
    buffer.access :a
    buffer.access :b
    buffer.access :c

    expect(buffer.contains?(:a)).to be false
    expect(buffer.contains?(:b)).to be true
    expect(buffer.contains?(:c)).to be true
  end

  it 'updates timestamp' do
    buffer = DbmsBuffers::LRUBuffer.new(2)
    buffer.access :a
    buffer.access :b
    buffer.access :a
    buffer.access :c

    expect(buffer.contains?(:a)).to be true
    expect(buffer.contains?(:b)).to be false
    expect(buffer.contains?(:c)).to be true
  end
end
