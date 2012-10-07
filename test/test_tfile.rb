require 'test/unit'
require 'alfa/tfile'

class AlfaTFileTest < Test::Unit::TestCase
  # errors if set projfile and pubfile before set project_root, document_root
  def test_00
    f = Alfa::TFile.new
    assert_raise RuntimeError do
      f.projfile = 'config/config.rb'
    end
    assert_raise RuntimeError do
      f.url = '/folder/170.html'
    end
  end

  def test_01 # set properties after create
    f = Alfa::TFile.new
    #absfile
    f.absfile = '/some/path/to/file.txt'
    assert_equal('/some/path/to/file.txt', f.absfile)
    assert_equal('file.txt', f.basename)
    assert_equal('.txt', f.extname)
    assert_equal('file', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/file.txt', f.to_str)
    assert_equal('/some/path/to/file.txt', f.to_s)

    # basename
    f.basename = 'blabla.foo'
    assert_equal('/some/path/to/blabla.foo', f.absfile)
    assert_equal('blabla.foo', f.basename)
    assert_equal('.foo', f.extname)
    assert_equal('blabla', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/blabla.foo', f.to_str)
    assert_equal('/some/path/to/blabla.foo', f.to_s)

    # extname with lead dot
    f.extname = '.bar'
    assert_equal('/some/path/to/blabla.bar', f.absfile)
    assert_equal('blabla.bar', f.basename)
    assert_equal('.bar', f.extname)
    assert_equal('blabla', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/blabla.bar', f.to_str)
    assert_equal('/some/path/to/blabla.bar', f.to_s)

    # extname without lead dot
    f.extname = 'bar'
    assert_equal('/some/path/to/blabla.bar', f.absfile)
    assert_equal('blabla.bar', f.basename)
    assert_equal('.bar', f.extname)
    assert_equal('blabla', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/blabla.bar', f.to_str)
    assert_equal('/some/path/to/blabla.bar', f.to_s)

    # filename
    f.filename = 'otherbla'
    assert_equal('/some/path/to/otherbla.bar', f.absfile)
    assert_equal('otherbla.bar', f.basename)
    assert_equal('.bar', f.extname)
    assert_equal('otherbla', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/otherbla.bar', f.to_str)
    assert_equal('/some/path/to/otherbla.bar', f.to_s)

    # dirname with trail slash
    f.dirname = '/other/path/'
    assert_equal('/other/path/otherbla.bar', f.absfile)
    assert_equal('otherbla.bar', f.basename)
    assert_equal('.bar', f.extname)
    assert_equal('otherbla', f.filename)
    assert_equal('/other/path/', f.dirname)
    assert_equal('/other/path/otherbla.bar', f.to_str)
    assert_equal('/other/path/otherbla.bar', f.to_s)

    # dirname without trail slash
    f.dirname = '/other/path'
    assert_equal('/other/path/otherbla.bar', f.absfile)
    assert_equal('otherbla.bar', f.basename)
    assert_equal('.bar', f.extname)
    assert_equal('otherbla', f.filename)
    assert_equal('/other/path/', f.dirname)
    assert_equal('/other/path/otherbla.bar', f.to_str)
    assert_equal('/other/path/otherbla.bar', f.to_s)

    # projfile
    Alfa::TFile.project_root = '/projects/project1'
    f.projfile = 'config/passwords/db.yml'
    assert_equal('/projects/project1/config/passwords/db.yml', f.absfile)
    assert_equal('db.yml', f.basename)
    assert_equal('.yml', f.extname)
    assert_equal('db', f.filename)
    assert_equal('/projects/project1/config/passwords/', f.dirname)
    assert_equal('/projects/project1/config/passwords/db.yml', f.to_str)
    assert_equal('/projects/project1/config/passwords/db.yml', f.to_s)
    f.projfile = '/config/passwords/db.yml'
    assert_equal('/projects/project1/config/passwords/db.yml', f.absfile)

    # url
    Alfa::TFile.document_root = '/projects/project1/public'
    f.url = 'folder/document1.doc'
    assert_equal('/projects/project1/public/folder/document1.doc', f.absfile)
    assert_equal('document1.doc', f.basename)
    assert_equal('.doc', f.extname)
    assert_equal('document1', f.filename)
    assert_equal('/projects/project1/public/folder/', f.dirname)
    assert_equal('/projects/project1/public/folder/document1.doc', f.to_str)
    assert_equal('/projects/project1/public/folder/document1.doc', f.to_s)
    f.url = '/folder/document1.doc'
    assert_equal('/projects/project1/public/folder/document1.doc', f.absfile)
  end

  def test_02 # set properties on create
    f = Alfa::TFile.new(:absfile => '/some/path/to/file.txt')
    assert_equal('/some/path/to/file.txt', f.absfile)
    assert_equal('file.txt', f.basename)
    assert_equal('.txt', f.extname)
    assert_equal('file', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/file.txt', f.to_str)
    assert_equal('/some/path/to/file.txt', f.to_s)

    Alfa::TFile.project_root = '/projects/project1'
    f = Alfa::TFile.new(:projfile => 'config/config.rb')
    assert_equal('/projects/project1/config/config.rb', f.absfile)
    assert_equal('config.rb', f.basename)
    assert_equal('.rb', f.extname)
    assert_equal('config', f.filename)
    assert_equal('/projects/project1/config/', f.dirname)
    assert_equal('/projects/project1/config/config.rb', f.to_str)
    assert_equal('/projects/project1/config/config.rb', f.to_s)
  end

  # class_variables
  def test_03
    Alfa::TFile.project_root = '/projects/project1'
    assert_equal('/projects/project1/', Alfa::TFile.project_root)
    assert_equal('/projects/project1/public/', Alfa::TFile.document_root)
    Alfa::TFile.project_root = '/projects/project1/'
    assert_equal('/projects/project1/', Alfa::TFile.project_root)
    assert_equal('/projects/project1/public/', Alfa::TFile.document_root)
  end

  # url
  def test_04
    Alfa::TFile.project_root = '/projects/project'
    f = Alfa::TFile.new
    f.absfile = '/projects/project/public/robots.txt'
    assert_equal('/robots.txt', f.url)
    f.absfile = '/projects/project/public/folder/file.jpg'
    assert_equal('/folder/file.jpg', f.url)
    f.absfile = '/projects/project/out_of_public/robots.txt'
    assert_equal(nil, f.url)
  end

  # class inheritance
  def test_10
    Alfa::TFile.project_root = '/projects/project0/'
    eval <<EOL
    class MyTFile1 < Alfa::TFile; end
    class MyTFile2 < Alfa::TFile; end
EOL
    assert_equal('/projects/project0/', MyTFile1.project_root)
    assert_equal('/projects/project0/', MyTFile2.project_root)
    MyTFile1.project_root = '/projects/project1/'
    assert_equal('/projects/project1/', MyTFile1.project_root)
    MyTFile2.project_root = '/projects/project2/'
    assert_equal('/projects/project2/', MyTFile2.project_root)
    eval <<EOL
    class MyTFile11 < MyTFile1; end
    class MyTFile22 < MyTFile2; end
EOL
    assert_equal('/projects/project1/', MyTFile11.project_root)
    assert_equal('/projects/project2/', MyTFile22.project_root)
    MyTFile11.project_root = '/projects/project11/'
    MyTFile22.project_root = '/projects/project22/'
    assert_equal('/projects/project0/', Alfa::TFile.project_root)
    assert_equal('/projects/project1/', MyTFile1.project_root)
    assert_equal('/projects/project2/', MyTFile2.project_root)
    assert_equal('/projects/project11/', MyTFile11.project_root)
    assert_equal('/projects/project22/', MyTFile22.project_root)
  end

end