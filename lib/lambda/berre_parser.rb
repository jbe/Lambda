
module Lambda
  class BerreParser < Parslet::Parser
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:lparen) { str('(') >> space? }
    rule(:rparen) { str(')') >> space? }
    rule(:pipe)   { str('|') >> space? }
    rule(:lamb)   { str('&') }
    rule(:eof)    { any.absnt? }

    rule(:expression)   { abstraction | application | parameter | name }

    rule(:parameter)    { match('[0-9]').repeat(1).as(:parameter) >> space? }
    rule(:abstraction)  { lamb >> expression.as(:abstraction) }
    rule(:application)  { lparen >> expression.as(:app_l) >>
      pipe >> expression.as(:app_r) >> rparen }
    rule(:name) { match('[A-Za-z_]').repeat(1).as(:name) }

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
    rule(:name => simple(:x)) do
      Lambda::STDENV.get_term(x.to_s) ||
        raise('Unknown variable: ' + x.to_s)
    end
  end

  PARSER      = BerreParser.new
  TRANSFORMER = BerreTransformer.new

  def self.parse(str)
    TRANSFORMER.apply(PARSER.parse(str))
  end

end

