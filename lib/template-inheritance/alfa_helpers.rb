# Monkeypatch functionalfix for gem TemplateInheritance v0.3.1
module TemplateInheritance
  class Template
    attr_writer :resources
    def resources
      @resources ||= {styles: [], scripts:[], added_scripts: []}
    end

    def instantiate_supertemplate
      supertemplate = self.class.new(self.supertemplate, self.scope)
      supertemplate.blocks = self.blocks
      supertemplate.resources = self.resources
      supertemplate
    end
  end

  module TemplateHelpers
    # Global variable, bad code style
    AUX_VARS = {}

    def require_style(src, *modes)
      case src
        when :'960gs', '960gs'
          require_style '/~assets/css/960gs/960.css'
          require_style '/~assets/css/960gs/text.css' if modes.include?(:text)
          require_style '/~assets/css/960gs/reset.css' if modes.include?(:reset)
        when :'960gs24', '960gs24'
          require_style '/~assets/css/960gs/960_24_col.css'
          require_style '/~assets/css/960gs/text.css' if modes.include?(:text)
          require_style '/~assets/css/960gs/reset.css' if modes.include?(:reset)
        else
          self.template.resources[:styles] << src
      end
    end

    def styles
      self.template.resources[:styles].reverse.uniq.map{|s| "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{s}\">\n" }.join('')
    end

    def top_scripts

    end

    def require_script(src, type: 'text/javascript')
      raise ArgumentError, 'src required' if src.nil?
      self.template.resources[:scripts] << src
    end

    def add_script(type: 'text/javascript', &block)
      self.template.resources[:scripts] << self.template.scope.capture(&block)
    end

    def scripts
      self.template.resources[:scripts].reverse.uniq.map{|s| "<script type='text/javascript' src='#{s}'></script>\n" }.join('')
    end

    def href(*o)
      AUX_VARS[:controller].href(*o)
    end

    def a(text, url)
      "<a href='#{url}'>#{text}</a>"
    end

    alias :link_to :a
  end
end
# End of patch