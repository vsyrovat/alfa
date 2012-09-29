# STYLES

class Ruty::Tags::RequireStyle < Ruty::Tag
  @@styles = []
  def initialize parser, argstring
    @@styles << argstring unless @@styles.include? argstring
  end
  def self.clean_cache
    @@styles = []
  end
  Ruty::Tags.register(self, :require_style)
end


class Ruty::Tags::Styles < Ruty::Tag
  def initialize parser, argstring
  end
  def render_node context, stream
    Ruty::Tags::RequireStyle.class_variable_get(:@@styles).each do |file|
      stream << "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{file}\"/>\n"
    end
  end
  Ruty::Tags.register(self, :styles)
end

# SCRIPTS

# Require external script that must be included at bottom of page.
class Ruty::Tags::RequireScript < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :require_script)
end

# Inline script placed at bottom after required scripts.
class Ruty::Tags::Script < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :script)
end

# Consolidation of required and inline scripts, puts at bottom of page before </body> tag.
class Ruty::Tags::Scripts < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :scripts)
end

# Inline script placed at top of page.
class Ruty::Tags::TopScript < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :top_script)
end

# Consolidation of inline top scripts, puts at top of page before </head> tag
class Ruty::Tags::TopScripts < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :top_scripts)
end

# Shortcut for jquery (required bottom)
class Ruty::Tags::RequireJquery < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :require_jquery)
end

# Shortcut for jquery plugin (required bottom)
class Ruty::Tags::RequireJqueryPlugin < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :require_jquery_plugin)
end