#
# Contains various parsers, implemented using either the lambda builder
# or parslet, and possibly some hacks.
#

module Lambda

  # Parse a bitfield (using the lambda builder and a
  # simple state machine)
  #
  def self.parse_bitfield(bits, state=:blank, b=build)
    bits.each do |bit|
      bit = bit == 1
      state = case state
      when :blank
        bit ? 0 : :cmd
      when :cmd
        bit ? b.application : b.abstraction; :blank
      when Fixnum
        if bit
          state + 1
        else
          b.parameter(state); :blank
        end
      end
      return b.result if b.result
    end
  end

  # Takes nested parentheses and returns a tree of arrays
  def self.paren_tree(d)
    result    = []
    ary_stack = [result]

    d.each_char do |c|
      case c
      when '('
        ary = []
        ary_stack.last << ary
        ary_stack << ary
      when ')'
        raise 'too many close parentheses!' if ary_stack.size < 2
        ary_stack.pop
      else
        ary_stack.last << '' unless ary_stack.last.last.is_a?(String)
        ary_stack.last.last << c
      end
    end
    raise 'missing close parenthesis!' if ary_stack.size > 1
    result
  end
  
  # parse a lambda expression in de bruijn notation
  # unfinished.
  #
  def self.parse_de_bruijn(str)
    parse_de_bruijn_tree(paren_tree(str))
  end

  def self.parse_de_bruijn_tree(ary, b=build)
    ary.each do |item|
      case item
      when String
        item.scan(/\\|[\u03BB]{1}|[0-9]+/) do |match|
          case match
          when '\\', "\u03BB" then b.abstraction
          when /[0-9]+/ then b.parameter(Integer(match))
          else raise("uexpected token #{item}")
          end
        end
      when Array
        build.application
        parse_de_bruijn_tree(item, b)
      end
    end
    b
  end

  def self.read(path)
    parse_bitfield(Lambda::BitField.read(path))
  end

  def self.parse_blc(str)
    parse_bitfield(Lambda::BitField.parse(str))
  end

end
