module Haml
  class Options
    @defaults = @defaults.merge({:raw_interpolated_tags => []})
    attr_accessor :raw_interpolated_tags
  end

  module Util
    def unescape_interpolation(str, escape_html = nil)
      res = ''
      rest = Haml::Util.handle_interpolation str.dump do |scan|
        escapes = (scan[2].size - 1) / 2
        res << scan.matched[0...-3 - escapes]
        if escapes % 2 == 1
          res << '#{'
        else
          content = eval('"' + balance(scan, ?{, ?}, 1)[0][0...-1] + '"')
          tag = content[/(\S+\s?){1}/].strip.to_sym
          content = "Haml::Helpers.html_escape((#{content}))" if escape_html && !@options[:raw_interpolated_tags].include?(tag)
          res << '#{' + content + "}"# Use eval to get rid of string escapes
        end
      end
      res + rest
    end
  end
end