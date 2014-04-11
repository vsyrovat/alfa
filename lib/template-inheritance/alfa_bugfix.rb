# Monkeypatch bugfix for gem TemplateInheritance v0.3.1
# Without this patch the line 10 in template-inheritance/exts/tilt.rb
#   klass.send(:remove_method, :initialize_engine)
# raises error during initialization because Tilt 2.0.0 have no method Tilt::HamlTemplate.initialize_engine
# Correct syntax in tilt.rb should be:
#   klass.send(:remove_method, :initialize_engine) if klass.respond_to?(:initialize_engine)
module Tilt
  class HamlTemplate
    unless self.respond_to?(:initialize_engine)
      def initialize_engine
      end
    end
  end
end
# End of patch