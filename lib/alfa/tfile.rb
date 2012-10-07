require 'alfa/support'

module Alfa
  class TFile

    class << self
      attr_reader :project_root, :document_root
      def project_root=(arg)
        @project_root = File.expand_path(arg) + '/'
        @document_root = @project_root + 'public/'
      end
      def document_root=(arg)
        @document_root = File.expand_path(arg) + '/'
      end
      def allowed_options
        @allowed_options ||= %w(absfile projfile url).map(&:to_sym)
      end
      def inherited(subclass)
        subclass.instance_variable_set(:@project_root, instance_variable_get(:@project_root))
        subclass.instance_variable_set(:@document_root, instance_variable_get(:@document_root))
      end

    end

    attr_reader :absfile, :absdir, :basename, :dirname

    def initialize options={}
      (options.keys - self.class.allowed_options).each do |opt|
        raise "unknown option #{opt}, expected one of: #{self.class.allowed_options.join(', ')}"
      end
      raise "only one of #{self.class.allowed_options.join(', ')} allowed" if options.length > 1
      if options.has_key?(:absfile)
        self.absfile= options[:absfile]
      elsif options.has_key? :projfile
        self.projfile= options[:projfile]
      end
    end

    def absfile= arg
      @absfile = arg
      @basename = File.basename(arg)
      @dirname = File.dirname(arg) + '/'
    end

    def projfile= arg
      raise "Please set up #{self.class}.project_root before call #{__method__}" unless self.class.project_root
      self.absfile= File.join(self.class.project_root, arg)
    end

    def basename= arg
      @basename = arg
      @absfile = File.join(@dirname, @basename)
    end

    def extname
      File.extname(@basename)
    end

    def extname= arg
      arg = '.' + arg unless arg =~ /^\./
      self.basename= self.filename + arg
    end

    def filename
      File.basename(@basename, File.extname(@basename))
    end

    def filename= arg
      self.basename= arg + self.extname
    end

    def dirname= arg
      @dirname = File.expand_path(arg) + '/'
      @absfile = File.join(@dirname, @basename)
    end

    def url
      if self.absfile[0, self.class.document_root.length] == self.class.document_root
        self.absfile[(self.class.document_root.length-1)..-1]
      end
    end

    def url= arg
      raise "Please set up #{self.class}.document_root before call #{__method__}" unless self.class.document_root
      self.absfile= File.join(self.class.document_root, arg)
    end

    def to_str
      self.absfile
    end

    def to_s
      self.to_str
    end

  end
end