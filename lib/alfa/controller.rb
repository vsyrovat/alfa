module Alfa
  class Controller
    def _instance_variables_hash
      Hash[instance_variables.map { |name| [name.to_s[1..-1].to_sym, instance_variable_get(name)] } ]
    end
  end
end
