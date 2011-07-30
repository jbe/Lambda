# encoding: UTF-8

require 'set'


module Lambda


  class Expression

    TERM_MAP  = {} # identity map for terms
    CACHE     = {} # reduction cache

    def self.cached_reductions
      CACHE.select do |inp, outp|
        inp != outp
      end.map(&:first)
    end

    def self.new(*params)
      TERM_MAP[params] ||= super(*params)
    end

    def initialize(*children)
      @children = children
    end

    attr_reader :children

    def reduce
      return Lambda::Omega.new if false
      print('.')
      CACHE[self] ||= self.class.new(*children.map(&:reduce))
    end

    def substitute(operand, depth=0)
      self.class.new(*children.map {|c| c.substitute(operand, depth) } )
    end

    def inspect(name=Lambda::FUNCTION_NAMES[self] || berre)
      "#<λ:#{object_id.to_s(16)} #{name}>"
    end

    def normal_form?
      @normal_form ||= (reduce == self)
    end

    def blc
      b = Lambda::BitField.new(blc_size)
      bitfield_write(b, 0)
      b
    end

    def write(*args)
      blc.write(*args)
    end

  private

    def var_name(num)
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
  end


  class Abstraction < Expression

    def definition; children[0]; end

    def abstraction_height
      definition.abstraction_height + 1
    end

    def blc_size
      2 + definition.blc_size
    end

    def bitfield_write(b, offset)
      b.parse('00', offset)
      definition.bitfield_write(b, offset + 2)
    end

    def berre
      "&#{definition.berre}"
    end

    def church(depth=0)
      name = var_name(depth)
      "\\#{name}.#{definition.church(depth+1)}"
    end

    def substitute(operand, depth=0)
      super(operand, depth + 1)
    end

  end

  class Application < Expression

    def operator; children[0]; end
    def operand;  children[1]; end

    def reduce(*args)
      red = super
      if red.operator.is_a?(Lambda::Abstraction) 
        red.operator.definition.
          substitute(red.operand)#.reduce(*args)
      else
        red
      end
    end

    def abstraction_height
      [operator.abstraction_height,
        operand.abstraction_height].max
    end

    def blc_size
      @blcs ||= 2 + operator.blc_size + operand.blc_size
    end

    def bitfield_write(b, offset)
      b.parse('01', offset)
      operator.bitfield_write(b, offset + 2)
      operand.bitfield_write(b, offset + 2 + operator.blc_size)
    end

    def berre
      "(#{operator.berre}|#{operand.berre})"
    end

    def church(depth=0)
      "(#{operator.church(depth)}(#{operand.church(depth)}))"
    end

  end

  class Parameter < Expression

    def initialize(distance)
      @children = []
      @distance = distance
    end

    attr_reader :distance

    def substitute(operand, depth=0)
      distance == depth ? operand : self
    end


    def blc_size
      distance + 2
    end

    def bitfield_write(b, offset)
      offset.upto(offset + distance) do |pos|
        b[pos] = 1
      end
      b[offset + distance + 1] = 0
    end

    def berre
      distance.to_s
    end

    def church(depth=0)
      var_name((depth-1) - distance)
    end

    def abstraction_height; 0; end
    def closed?;      false; end
    def normal_form?; true;  end
    def reduce(*args);self; end

  end

  class Omega < Expression
    def inspect;  super('OMEGA'); end
    def church;   'OMEGA';        end
    def berre;    'OMEGA';        end

    def self.new; @instance ||= super; end
  end

  OMEGA = Omega.new


end




