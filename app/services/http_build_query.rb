class HttpBuildQuery
  class << self
    # Build an HTTP URL-encoded string suitable for appending to GET paths.
    # This is intended to have an as-similar-as-possible usage as PHP's.
    def create(object)
      h = hashify(object)
      result = ""
      separator = '&'
      h.keys.sort.each do |key|
        result << (CGI.escape(key) + '=' + CGI.escape(h[key]) + separator)
      end
      result = result.sub(/#{separator}$/, '') # Remove the trailing k-v separator
      return result
    end
    def hashify(object, parent_key = '')
      raise ArgumentError.new('This is made for serializing Hashes and Arrays only') unless (object.is_a?(Hash) or object.is_a?(Array) or parent_key.length > 0)

      result = {}
      case object
      when String, Symbol, Numeric
        result[parent_key] = object.to_s
      when Hash
        # Recursively call hashify, building closure-like state by
        # appending the current location in the tree as new "parent_key"
        # values.
        hashes = object.map do |key, value|
          if parent_key =~ /^[0-9]+/ or parent_key.length == 0
            new_parent_key = key.to_s
          else
            new_parent_key = parent_key + '[' + key.to_s + ']'
          end
          hashify(value, new_parent_key)
        end
        hash = hashes.reduce { |memo, hash| memo.merge hash }
        result.merge! hash
      when Enumerable
        # _Very_ similar to above, but iterating with "each_with_index"
        hashes = {}
        object.each_with_index do |value, index|
          if parent_key.length == 0
            new_parent_key = index.to_s
          else
            new_parent_key = parent_key + '[' + index.to_s + ']'
          end
          hashes.merge! hashify(value, new_parent_key)
        end
        result.merge! hashes
      else
        raise Exception.new("This should only be serializing Strings, Symbols, or Numerics.")
      end

      return result
    end
  end
end