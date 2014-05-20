require 'json'

class User < Sequel::Model(DB::Main[:users])
  prepend Alfa::UserModule
  plugin :serialization, :json, :groups

  def before_save
    self.groups ||= []
    super
  end
end
