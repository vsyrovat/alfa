# Monkeypatch functionalfix for gem TemplateInheritance v0.3.1
module TemplateInheritance
  # class Template
  #   attr_writer :resources
  #   def resources
  #
  #   end
  #
  #   def instantiate_supertemplate
  #     supertemplate = self.class.new(self.supertemplate, self.scope)
  #     supertemplate.blocks = self.blocks
  #     supertemplate.resources = self.resources
  #     supertemplate
  #   end
  # end


  class RenderScope
    attr_reader :controller, :wrapper

    def initialize(controller = nil, wrapper = nil, resourcer = nil)
      @controller = controller
      @wrapper = wrapper
      @resourcer = resourcer
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
          @resourcer[:styles] << src
      end
    end

    def styles
      @resourcer.styles.uniq.map{|s|
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
      @resourcer[:scripts] << {src: src, type: type}
    end

    def add_script(type: 'text/javascript', &block)
      @resourcer[:scripts] << {code: self.template.scope.capture(&block), type: type}
    end

    def scripts
      @resourcer.scripts.uniq.map{|s|
        if (s[:src])
          if s.match(/^\/~assets\/(.*)/)
            f = File.join(File.expand_path('../../../assets/', __FILE__), $1)
          else
            f = File.join(Alfa::WebApplication.config[:document_root], s)
          end
          mtime = File.exist?(f) ? File.mtime(f).to_i : nil
          "<script type='#{s[:type]}' src='#{s[:src]}?#{mtime}'></script>\n"
        else
          "<script type='#{s[:type]}'>\n#{s[:code].rstrip}\n</script>\n"
        end
      }.join('')
    end

    def href(*o)
      @wrapper.href(*o)
    end

    def a(text, url)
      "<a href='#{url}'>#{Haml::Helpers.html_escape(text)}</a>"
    end

    alias :link_to :a

    def application
      @wrapper.application
    end

    def controller
      @controller
    end

    def user
      @wrapper.user
    end

    def snippet(name)
      @wrapper.application.snippet(name, @wrapper)
    end
  end
end
# End of patch