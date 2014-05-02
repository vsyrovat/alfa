module Tilt
  class Template
    # This patch allows to use of @keys as well as keys
    # Example:
    #   template.render({:@name => 'Piter'})
    def local_extraction(local_keys)
      local_keys.map do |k|
        if k.to_s =~ /\A@?[a-z_][a-zA-Z_0-9]*\z/ # this line patched
          "#{k} = locals[#{k.inspect}]"
        else
          raise "invalid locals key: #{k.inspect} (keys must be variable names)"
        end
      end.join("\n")
    end
  end
end

module TemplateInheritance
  class Template
    def template(options = {})
      options = {:escape_html => true, :raw_interpolated_tags => [:a, :link_to, :a_post, :img]}.merge(options)
      @template ||= Tilt.new(self.fullpath, nil, options)
    end
  end
end