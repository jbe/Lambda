
module Lambda
  class BerreParser < Parslet::Parser
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:lparen) { str('(') >> space? }
    rule(:rparen) { str(')') >> space? }
    rule(:pipe)   { str('|') >> space? }
    rule(:lamb)   { str('&') }
    rule(:eof)    { any.absnt? }

    rule(:expression)   { abstraction | application | parameter }

    rule(:parameter)    { match('[0-9]').repeat(1).as(:parameter) >> space? }
    rule(:abstraction)  { lamb >> expression.as(:abstraction) }
    rule(:application)  { lparen >> expression.as(:app_l) >>
      pipe >> expression.as(:app_r) >> rparen }

    root(:expression)
  end

  class BerreTransformer < Parslet::Transform
    rule(:parameter => simple(:x)) { Parameter.new(Integer(x)) }
    rule(:abstraction => simple(:x)) do
      Abstraction.new(x)
    end
    rule(:app_l => simple(:x), :app_r => simple(:y)) do
      Application.new(x, y)
    end
  end

  PARSER      = BerreParser.new
  TRANSFORMER = BerreTransformer.new

  def self.parse(str)
    TRANSFORMER.apply(PARSER.parse(str))
  end

end

