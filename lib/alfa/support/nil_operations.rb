# Nil operations
# Nil mean "unknown" or "no data set", so operations with nil return nil too
class NilClass
  def *(arg)
    nil
  end

  def +(arg)
    nil
  end

  def -(arg)
    nil
  end

  def /(arg)
    nil
  end

  def div(arg)
    nil
  end

  def fdiv(arg)
    nil
  end
end


module Alfa
  module NilOperations
    def self.included(base)
      base.send(:alias_method, :_mul, :*)
      base.send(:alias_method, :_sum, :+)
      base.send(:alias_method, :_sub, :-)
      base.send(:alias_method, :_div, :/)
      base.send(:alias_method, :_fdiv, :fdiv)
      base.prepend InstanceMethods
    end

    module InstanceMethods
      def *(arg)
        arg.nil? ? nil : _mul(arg)
      end

      def +(arg)
        arg.nil? ? nil : _sum(arg)
      end

      def -(arg)
        arg.nil? ? nil : _sub(arg)
      end

      def /(arg)
        arg.nil? ? nil : _div(arg)
      end

      def div(arg)
        arg.nil? ? nil : _div(arg)
      end

      def fdiv(arg)
        arg.nil? ? nil : _fdiv(arg)
      end
    end
  end
end


class Float
  include Alfa::NilOperations
end


class Fixnum
  include Alfa::NilOperations
end
