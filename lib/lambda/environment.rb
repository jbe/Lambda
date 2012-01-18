
module Lambda
  # En environment of identified lambda terms. Allows multiple
  # environments to share logic within a single lambda "pool".
  class Environment
    def initialize(&blk)
      @names = {} # by term
      @terms = {} # by name
    end

    def name(id, term)
      @names[term] = id
      @terms[id]   = term
    end

    def forget_name(name)
      @names.delete(@terms.delete(name))
    end

    def forget_term(term)
      @terms.delete(@names.delete(term))
    end

    def get_name(name); @names[name]; end
    def get_term(term); @terms[term]; end
  end
end
