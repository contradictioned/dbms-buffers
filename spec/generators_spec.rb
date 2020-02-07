# frozen_string_literal: true

RSpec.describe DbmsBuffers::SimpleGenerator do
  it 'returns something' do
    generator = DbmsBuffers::SimpleGenerator.new
    generator.range(['A'])

    20.times do
      expect(generator.get).to be 'A'
    end
  end

  it 'repeats' do
    generator = DbmsBuffers::SimpleGenerator.new
    generator.range(['A', 'B'])

    result = generator.repeat 5
    expect(result.size).to be 5
  end
end
