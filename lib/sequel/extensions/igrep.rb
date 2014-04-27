module Sequel
  class Dataset
    QUERY_METHODS << :igrep

    def igrep(columns, patterns, opts=OPTS)
      self.grep(columns, patterns, opts.merge({:case_insensitive=>true}))
    end
  end

  Dataset.register_extension :igrep

  class Model
    DATASET_METHODS << :igrep

    module ClassMethods
      Plugins.def_dataset_methods(self, [:igrep])
    end
  end
end