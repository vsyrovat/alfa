# HREF

class Ruty::Tags::Href < Ruty::Tag
  def initialize(parser, argstring)
    @argstring = argstring
  end
  def render_node(context, stream)
    stream << Ruty::AUX_VARS[:controller].href(@argstring)
  end
  Ruty::Tags.register(self, :href)
  Ruty::Tags.register(self, :href_to)
end