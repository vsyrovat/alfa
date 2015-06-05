require 'test/unit'
require 'sequel'
require 'json'

class SequelTest < Test::Unit::TestCase
  # before_save/before_create hooks with serialization plugin
  def test_01
    Sequel::Model.db = Sequel.sqlite
    Sequel::Model.db.create_table(:tests) do
      primary_key :id
      varchar     :name
      text        :data
    end
    eval <<EOL
class SequelTest01 < Sequel::Model(:tests)
  plugin :serialization, :json, :data

  def before_save
    self.data ||= [1, 2]
    super
  end
end
EOL
    t = SequelTest01.create(name: 'foo')
    assert_equal({id: 1, name: 'foo', data: '[1,2]'}, t.values)
  end

end