# Code (c) 2007 Peter Cooper
# <http://snippets.dzone.com/posts/show/4234>,
# Changes and additions by Jostein Berre Eliassen
# licensed under the MIT license (see LICENSE)

#
# DESCRIPTION: Basic, pure Ruby bit field. Pretty fast (for what it is) and memory efficient.
#              I've written a pretty intensive test suite for it and it passes great. 
#              Works well for Bloom filters (the reason I wrote it).
#
#              Create a bit field 1000 bits wide
#                bf = BitField.new(1000)
#
#              Setting and reading bits
#                bf[100] = 1
#                bf[100]    .. => 1
#                bf[100] = 0
#
#              More
#                bf.to_s = "10101000101010101"  (example)
#                bf.total_set         .. => 10  (example - 10 bits are set to "1")

module Lambda
  class BitField
    attr_reader :size
    include Enumerable

    class RangeError < StandardError; end
    
    ELEMENT_WIDTH = 32

    #
    def self.read(path)
      File.open(path) do |f|
        bfield = new(File.size(path) * 8)
        File.read(path).unpack('N*').each_with_index do |int, i|
          bfield.field[i] = int
        end
        bfield
      end
    end

    # parse a string like "0110001"
    def self.parse(str)
      new(str.size).parse(str)
    end
    
    def initialize(size)
      @size = size
      @field = Array.new(((size - 1) / ELEMENT_WIDTH) + 1, 0)
    end

    attr_reader :size, :field
    
    # Set a bit (1/0)
    def []=(position, value)
      if value == 1
        @field[position / ELEMENT_WIDTH] |= 1 << (position % ELEMENT_WIDTH)
      elsif (@field[position / ELEMENT_WIDTH]) & (1 << (position % ELEMENT_WIDTH)) != 0
        @field[position / ELEMENT_WIDTH] ^= 1 << (position % ELEMENT_WIDTH)
      end
    end
    
    # Read a bit (1/0)
    def [](position)
      raise(RangeError, 'out of range') if position >= @size
      @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) > 0 ? 1 : 0
    end

    # Set several bits given a string like "0101011"
    def parse(str, offset=0)
      str.chars.each_with_index do |c, i|
        self[i + offset] = Integer(c) if ['0', '1'].include?(c)
      end
      self
    end
    
    # Iterate over each bit
    def each(&block)
      @size.times { |position| yield self[position] }
    end
    
    # Returns the field as a string like "0101010100111100," etc.
    def to_s
      inject("") { |a, b| a + b.to_s }
    end
    
    # Returns the total number of bits that are set
    # (The technique used here is about 6 times faster than using each or inject direct on the bitfield)
    def total_set
      @field.inject(0) { |a, byte| a += byte & 1 and byte >>= 1 until byte == 0; a }
    end

    def pack
      @field.pack('N*')
    end

    # write the bitfield to a file
    def write(path)
      File.open(path, 'w') {|f| f.write(pack) }
    end

  end
end
