# encoding: UTF-8


module Lambda

  # Constructs lambda expressions from a series of events
  # (method calls) corresponding to a deBruijin-like tape.
  class Builder

    def initialize
      @builder = Fiber.new do |root|
        @result = parse(root)
      end
    end

    attr_reader :result

    def symbol(s)
      raise 'symbol overflow' if result
      @builder.resume(s)
      result ? result : self
    end
    alias :parameter :symbol
    def abstraction; symbol(:abstraction); end
    def application; symbol(:application); end

  private

    def parse(symbol)
      case symbol
      when Fixnum
        Lambda::Parameter.new(symbol)
      when :abstraction
        Lambda::Abstraction.new(parse(Fiber.yield))
      when :application then 
        Lambda::Application.new(
          parse(Fiber.yield), parse(Fiber.yield))
      else raise('invalid symbol: ' + symbol)
      end
    end
  end

  def self.build; Builder.new; end


end
