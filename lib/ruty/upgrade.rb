# escape variables by default
# {{ variable }} transforms to {{ variable|escape }}
# {{ variable|raw }} transforms to {{ variable }}
module Ruty
  class ParserController

    # parse everything until the block returns true
    def parse_until &block
      result = Datastructure::NodeStream.new(self)
      while not @tokenstream.eos?
        token, value = @tokenstream.next

        # text tokens are returned just if the arn't empty
        if token == :text
          @first = false if @first and not value.strip.empty?
          result << Datastructure::TextNode.new(value) \
                    if not value.empty?

          # variables leave the parser just if they have just
          # one name and some optional filters on it.
        elsif token == :var
          @first = false
          names = []
          filters = []
          Parser::parse_arguments(value).each do |arg|
            if arg.is_a?(Array)
              filters << arg
            else
              names << arg
            end
          end

          filters << [:escape] if (filters & [[:raw], [:escape]]).empty?
          filters -= [[:raw]]

          fail('Invalid syntax for variable node') if names.size != 1
          result << Datastructure::VariableNode.new(names[0], filters)

          # blocks are a bit more complicated. first they can act as
          # needle tokens for other blocks, on the other hand blocks
          # can have their own subprogram
        elsif token == :block
          p = value.split(/\s+/, 2)
          name = p[0].to_sym
          args = p[1] || ''
          if block.call(name, args)
            @first = false
            return result.to_nodelist
          end

          tag = Tags[name]
          fail("Unknown tag #{name.inspect}") if tag.nil?
          result << tag.new(self, args)
          @first = false
        end
      end
      result.to_nodelist
      end

  end
end