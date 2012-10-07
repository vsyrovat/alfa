# STYLES

class Ruty::Tags::RequireStyle < Ruty::Tag
  @@styles = []
  def initialize parser, argstring
    @@styles << argstring unless @@styles.include? argstring
  end
  def self.add path
    @@styles << path unless @@styles.include? path
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

class Ruty::Tags::Require960gs < Ruty::Tag
  @@styles = []
  def initialize parser, argstring
    Ruty::Tags::RequireStyle.add '/~assets/css/960gs/960.css'
  end
  Ruty::Tags.register(self, :require_960gs)
end

class Ruty::Tags::Require960gs24 < Ruty::Tag
  @@styles = []
  def initialize parser, argstring
    case argstring
      when 'text'
        Ruty::Tags::RequireStyle.add '/~assets/css/960gs/text.css'
      when 'reset'
        Ruty::Tags::RequireStyle.add '/~assets/css/960gs/reset.css'
      when 'full'
        Ruty::Tags::RequireStyle.add '/~assets/css/960gs/reset.css'
        Ruty::Tags::RequireStyle.add '/~assets/css/960gs/text.css'
      else
    end
    Ruty::Tags::RequireStyle.add '/~assets/css/960gs/960_24_col.css'
  end
  Ruty::Tags.register(self, :require_960gs24)
end


# SCRIPTS

# Require external script that must be included at bottom of page.
class Ruty::Tags::RequireScript < Ruty::Tag
  @@scripts = []
  def initialize parser, argstring
    Ruty::Tags::RequireScript.add argstring
  end
  def self.add path
    @@scripts << path unless @@scripts.include? path
  end
  def self.clean_cache
    @@scripts = []
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
  def render_node context, stream
    Ruty::Tags::RequireScript.class_variable_get(:@@scripts).each do |file|
      stream << "<script src=\"#{file}\"></script>\n"
    end
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
    Ruty::Tags::RequireScript.add '/~assets/js/jquery/jquery-latest.js'
  end
  Ruty::Tags.register(self, :require_jquery)
end

# Shortcut for jquery plugin (required bottom)
class Ruty::Tags::RequireJqueryPlugin < Ruty::Tag
  def initialize parser, argstring
  end
  Ruty::Tags.register(self, :require_jquery_plugin)
end