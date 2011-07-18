
module Lambda

  CHARS = ('a'..'z').to_a

  def self.var_name(num)
    r = ''
    num.to_s(26).each_codepoint do |c|
      r << case c
        when (97..122) then c + 10
        when (48..57)  then c + 49
        else raise "unexpected #{c.chr}"
      end
    end
    r
  end

  class Node
    def blc
      b = Lambda::BitField.new(blc_size)
      bitfield_write(b, 0)
      b
    end

    def write(*args)
      blc.write(*args)
    end

    def normal_form?; !reducible?; end
  end

  class Abstraction < Node

    def initialize(definition)
      @definition = definition
    end

    attr_reader :definition

    def abstraction_height
      @definition.abstraction_height + 1
    end

    def blc_size
      2 + @definition.blc_size
    end

    def bitfield_write(b, offset)
      b.parse('00', offset)
      @definition.bitfield_write(b, offset + 2)
    end

    def berre
      "&#{@definition.berre}"
    end

    def church(depth=0)
      name = Lambda.var_name(depth)
      "\\#{name}.#{@definition.church(depth+1)}"
    end

    def reducible?
      @definition.reducible?
    end
  end

  class Application < Node
    def initialize(operator, operand)
      @operator = operator
      @operand = operand
    end

    attr_reader :operator, :operand

    def abstraction_height
      [@operator.abstraction_height,
        @operand.abstraction_height].max
    end

    def blc_size
      @blcs ||= 2 + @operator.blc_size + @operand.blc_size
    end

    def bitfield_write(b, offset)
      b.parse('01', offset)
      @operator.bitfield_write(b, offset + 2)
      @operand.bitfield_write(b, offset + 2 + @operator.blc_size)
    end

    def berre
      "(#{@operator.berre}|#{@operand.berre})"
    end

    def church(depth=0)
      "(#{@operator.church(depth)}(#{@operand.church(depth)}))"
    end

    def reducible?
      @redcbl ||= @operator.is_a?(Abstraction) ||
        @operator.reducible? || @operand.reducible?
    end
  end

  class Parameter < Node
    def initialize(position)
      @position = position
    end

    attr_reader :position

    def abstraction_height
      0
    end

    def blc_size
      @position + 2
    end

    def bitfield_write(b, offset)
      offset.upto(offset + @position) do |pos|
        b[pos] = 1
      end
      b[offset + @position + 1] = 0
    end

    def berre
      @position.to_s
    end

    def church(depth=0)
      Lambda.var_name((depth-1) - @position)
    end

    def reducible?
      false
    end


  end
end




