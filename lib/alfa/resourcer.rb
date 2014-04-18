module Alfa
  class Resourcer
    def initialize
      @resources = {
        action: {styles: [], scripts:[], added_scripts: []},
        layout: {styles: [], scripts:[], added_scripts: []},
        snippet: {styles: [], scripts:[], added_scripts: []},
      }
    end

    def [](name)
      @resources[@cursor][name]
    end

    # @param l Symbol
    def level=(l)
      raise "level should be on of #{@resources.keys}" unless @resources.keys.include?(l)
      @cursor = l
    end

    def styles
      @resources[:layout][:styles].concat(@resources[:action][:styles]).concat(@resources[:snippet][:styles])
    end

    def scripts
      @resources[:layout][:scripts].concat(@resources[:action][:scripts]).concat(@resources[:snippet][:scripts])
    end
  end
end