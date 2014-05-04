module Sequel
  class Dataset
    def self.with_pks(keys)
      where(primary_key => keys)
    end
  end

  Dataset.register_extension :with_pks

  class Model
    def self.with_pks(keys)
      where(primary_key => keys)
    end
  end
end