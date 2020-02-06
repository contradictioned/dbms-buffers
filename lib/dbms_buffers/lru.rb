# frozen_string_literal: true

module DbmsBuffers
  LRUBufferEntry = Struct.new(:value, :timestamp)

  # The LRUBuffer applies least recently used as eviction strategy.
  # For this, it saves the time of the last access with each buffered value.
  class LRUBuffer
    attr_reader :size

    def initialize(size)
      @size = size
      @buffer = []
      @time = 0
    end

    def access(value)
      @time += 1
      try_touch(value) || try_insert_new(value) || try_replace(value)
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

    def try_touch(value)
      result = contains? value
      touch(value) if result
      result
    end

    def try_insert_new(value)
      return false if used == @size

      entry = LRUBufferEntry.new(value, @time)
      @buffer << entry

      true
    end

    def try_replace(value)
      entry = oldest_entry
      entry.value = value
      entry.timestamp = @time

      true
    end

    def index(value)
      @buffer.index { |entry| entry.value == value }
    end

    def oldest_entry
      @buffer.min { |entry_a, entry_b| entry_a.timestamp <=> entry_b.timestamp }
    end

    def touch(value)
      @buffer.find { |entry| entry.value == value }.timestamp = @time
    end
  end
end
