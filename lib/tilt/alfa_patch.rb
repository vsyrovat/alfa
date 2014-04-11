module Tilt
  class Template
    def local_extraction(local_keys)
      local_keys.map do |k|
        if k.to_s =~ /\A@?[a-z_][a-zA-Z_0-9]*\z/
          "#{k} = locals[#{k.inspect}]"
        else
          raise "invalid locals key: #{k.inspect} (keys must be variable names)"
        end
      end.join("\n")
    end
  end
end