require 'delegate'

# Nil operations
# Nil mean "unknown" or "no data set", so operations with nil return nil too
class NilKnown < SimpleDelegator
  attr_accessor :known
  alias :value :__getobj__

  def initialize(obj, k = nil)
    raise ::ArgumentError, 'obj and k should not be nil simultaneously' if !obj.nil? && !k.nil?
    super(obj)
    @known = obj ? obj : k
  end

  def nil?
    @delegate_sd_obj.nil?
  end

  alias :implicit? :nil?

  def explicit?
    !implicit?
  end

  def is?
    !(@delegate_sd_obj.nil? || @delegate_sd_obj === false)
  end

  def +(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
        if known.nil? && arg_known.nil?
          nil
        elsif known.nil?
          arg_known
        elsif arg_known.nil?
          known
        else
          known + arg_known
        end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj + arg)
    end
  end

  def -(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
        if known.nil? && arg_known.nil?
          nil
        elsif known.nil?
          -arg_known
        elsif arg_known.nil?
          known
        else
          known - arg_known
        end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj - arg)
    end
  end

  def *(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
        if known.nil? || arg_known.nil?
          0
        else
          known * arg_known
        end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj * arg)
    end
  end

  def fdiv(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
        if arg_known.nil?
          Float::INFINITY
        elsif known.nil?
          0
        end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj.fdiv(arg))
    end
  end

  def /(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
      if arg_known.nil?
        if @delegate_sd_obj.is_a?(Float) || @delegate_sd_obj.is_a?(NilClass)
          Float::INFINITY
        else
          raise ZeroDivisionError
        end
      elsif known.nil?
        0
      end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj / arg)
    end
  end

  def div(arg)
    if nil? || arg.nil?
      arg_known = arg.respond_to?(:known) ? arg.known : nil
      k = (
      if arg_known.nil?
        raise ZeroDivisionError
      elsif known.nil?
        0
      end
      )
      k.nil? ? nil : NilKnown.new(nil, k)
    else
      NilKnown.new(@delegate_sd_obj.div(arg))
    end
  end

  def to_a
    [value, known]
  end

  def to_h
    {value: value, known: known}
  end

  def to_nkn
    self
  end

  def hround(digits)
    self.nil? ? '' : @delegate_sd_obj.hround(digits)
  end

  def mround(zeroes = false)
    self.nil? ? '' : @delegate_sd_obj.mround(zeroes)
  end
end


module Alfa
  module NilOperations
    def known
      self
    end

    def value
      self
    end

    def to_nkn
      NilKnown.new(self)
    end

    def is?
      self
    end
  end
end


class NilClass
  include Alfa::NilOperations
end


class Float
  include Alfa::NilOperations
end


class Fixnum
  include Alfa::NilOperations
end


class BigDecimal
  include Alfa::NilOperations
end

class Array
  def to_nkn
    NilKnown.new(self[0], self[1])
  end
end