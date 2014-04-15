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


  class RenderScope
    attr_reader :controller

    def initialize(controller = nil)
      @controller = controller
    end
  end


  module TemplateHelpers
    def require_style(src, *modes)
      case src
        when :'960gs', '960gs'
          require_style '/~assets/css/960gs/reset.css' if modes.include?(:reset)
          require_style '/~assets/css/960gs/text.css' if modes.include?(:text)
          require_style '/~assets/css/960gs/960.css'
        when :'960gs24', '960gs24'
          require_style '/~assets/css/960gs/reset.css' if modes.include?(:reset)
          require_style '/~assets/css/960gs/text.css' if modes.include?(:text)
          require_style '/~assets/css/960gs/960_24_col.css'
        when :alfa_classic, 'alfa_classic'

        else
          self.template.resources[:styles] << src
      end
    end

    def styles
      self.template.resources[:styles].uniq.map{|s|
        if s.match(/^\/~assets\/(.*)/)
          f = File.join(File.expand_path('../../../assets/', __FILE__), $1)
        else
          f = File.join(Alfa::WebApplication.config[:document_root], s)
        end
        mtime = File.exist?(f) ? File.mtime(f).to_i : nil
        "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{s}?#{mtime}\">\n"
      }.join('')
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
      @controller.href(*o)
    end

    def a(text, url)
      "<a href='#{url}'>#{Haml::Helpers.html_escape(text)}</a>"
    end

    alias :link_to :a

    def controller
      @controller
    end
  end
end
# End of patch