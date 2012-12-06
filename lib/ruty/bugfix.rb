module Ruty
  class Parser
    # tokenize the sourcecode and return an array of tokens
    def tokenize
      result = Datastructure::TokenStream.new
      @source.scan(TAG_REGEX).each do |match|
        result << [:text, match[0]] if match[0] and not match[0].empty?
        if data = match[1]
          result << [:block, data.strip]
        elsif data = match[2]
          result << [:var, data.strip]
        elsif data = match[3]
          result << [:comment, data.strip]
        end
      end
      rest = $~ ? @source[$~.end(0)..-1] : @source
      result << [:text, rest] if not rest.empty?
      result.close
    end
  end
end