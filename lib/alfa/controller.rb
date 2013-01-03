module Alfa
  class Controller
    def _instance_variables_hash
      Hash[instance_variables.map { |name| [name.to_s[1..-1].to_sym, instance_variable_get(name)] } ]
    end

    def _clear_instance_variables
      instance_variables.each {|name| remove_instance_variable(name)}
    end
  end
end
