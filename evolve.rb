
$LOAD_PATH.unshift('./lib')
require 'lambda'
require 'set'

PRIMORDIAL_SOUP = Set.new
['TRUE', 'FALSE', 'AND', 'OR', 'NOT', 'I', 'K'].each do |word|
  terms << Lambda(word)
end

class Array
  def random
    self[(rand*size).floor]
  end
end

def random_term
  Lambda::Expression::TERMS.values.random
end

class World < Hash # conditions
  def atoms
  end
end

class Individual < Hash # term mappings

  def initialize(world, genes)
    @world = world
  end
  
end


BOOL = World.new(
  'and(true)(true)'   => 'true',
  'and(true)(false)'  => 'false',
  'and(false)(true)'  => 'false',
  'and(false)(false)' => 'false',

  'or(true)(true)'    => 'true',
  'or(true)(false)'   => 'true',
  'or(false)(true)'   => 'true',
  'or(false)(false)'  => 'false',

  'not(true)'         => 'false',
  'not(false)'        => 'true'
)


