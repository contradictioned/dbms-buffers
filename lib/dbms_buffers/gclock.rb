# frozen_string_literal: true

module DbmsBuffers
  GClockBufferEntry = Struct.new(:value, :clock_value)

  # The generalized clock buffer arranges entries in a logical clock and a single hand.
  # When the buffer is full and a not-yet-inserted entry needs space,
  # the hand goes clockwise until it finds an entry with clock_value = 0.
  # The found entry is evicted, removed from the buffer, and the new values
  # is inserted with clock_value 1.
  # All entries the hand passes where clock_value = 1, this value is decremented,
  # but they are not replaced yet (they have a second chance).
  # When an element is accessed, its value is incremented by 1.
  class GClockBuffer
    attr_reader :pointer, :size

    def initialize(size)
      @size = size
      @buffer = []
      @pointer = 0
    end

    def access(value)
      try_touch(value) || try_insert_new(value) || try_replace(value)
    end

    def clock_value_of(value)
      @buffer[index(value)].clock_value
    end

    def entries
      @buffer.clone
    end

    def contains?(value)
      @buffer.any? { |entry| value == entry.value }
    end

    def used
      @buffer.size
    end

    private

    # If value is contained in the buffer, it's value is set to 1
    # and true is returned, otherwise false
    def try_touch(value)
      result = contains? value
      touch(value) if result
      result
    end

    # If buffer slots are free, inserts value and returns true.
    def try_insert_new(value)
      return false if used == @size

      entry = GClockBufferEntry.new(value, 1)
      @buffer[@pointer] = entry
      advance_pointer

      true
    end

    def try_replace(value)
      entry = @buffer[@pointer]
      if entry.clock_value.zero?
        entry.value = value
        entry.clock_value = 1
        return true
      end

      entry.clock_value -= 1
      advance_pointer
      try_replace value
    end

    def advance_pointer
      @pointer = (@pointer + 1) % @size
    end

    def index(value)
      @buffer.index { |entry| entry.value == value }
    end

    def touch(value)
      @buffer.find { |entry| entry.value == value }.clock_value += 1
    end
  end
end
