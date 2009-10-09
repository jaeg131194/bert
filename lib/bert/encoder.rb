module BERT
  class Encoder
    # Encode a Ruby object into a BERT.
    #   +ruby+ is the Ruby object
    #
    # Returns a BERT
    def self.encode(ruby)
      complex_ruby = convert(ruby)
      Erlectricity::Encoder.encode(complex_ruby)
    end

    # Convert Ruby types into corresponding Erlectricity representation
    # of BERT complex types.
    #   +item+ is the Ruby object to convert
    #
    # Returns the converted Ruby object
    def self.convert(item)
      case item
        when Hash
          pairs = Erl::List[]
          item.each_pair { |k, v| pairs << [convert(k), convert(v)] }
          [:dict, pairs]
        when Tuple
          item.map { |x| convert(x) }
        when Array
          Erl::List.new(item.map { |x| convert(x) })
        when nil
          [:nil, :nil]
        when TrueClass, FalseClass
          [:bool, item.to_s.to_sym]
        when Time
          [:time, item.to_i, item.usec]
        when Regexp
          options = ''
          options += 'i' if item.options & Regexp::IGNORECASE > 0
          options += 'x' if item.options & Regexp::EXTENDED > 0
          options += 'm' if item.options & Regexp::MULTILINE > 0
          [:regex, item.source, options]
        else
          item
      end
    end
  end
end