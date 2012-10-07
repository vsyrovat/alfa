require 'test/unit'
require 'alfa/tfile'



class AlfaTFileTest < Test::Unit::TestCase
  def test_01_set
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
  end

  def test_02_create
    f = Alfa::TFile.new(:absfile => '/some/path/to/file.txt')
    assert_equal('/some/path/to/file.txt', f.absfile)
    assert_equal('file.txt', f.basename)
    assert_equal('.txt', f.extname)
    assert_equal('file', f.filename)
    assert_equal('/some/path/to/', f.dirname)
    assert_equal('/some/path/to/file.txt', f.to_str)
    assert_equal('/some/path/to/file.txt', f.to_s)
  end

  def test_03_class
    Alfa::TFile.project_root = '/projects/project1'
    assert_equal('/projects/project1/', Alfa::TFile.project_root)
    assert_equal('/projects/project1/public/', Alfa::TFile.document_root)
    Alfa::TFile.project_root = '/projects/project1/'
    assert_equal('/projects/project1/', Alfa::TFile.project_root)
    assert_equal('/projects/project1/public/', Alfa::TFile.document_root)
  end

  def test_04_url
    Alfa::TFile.project_root = '/projects/project'
    f = Alfa::TFile.new
    f.absfile = '/projects/project/public/robots.txt'
    assert_equal('/robots.txt', f.url)
    f.absfile = '/projects/project/public/folder/file.jpg'
    assert_equal('/folder/file.jpg', f.url)
    f.absfile = '/projects/project/out_of_public/robots.txt'
    assert_equal(nil, f.url)
  end

  def test_10_class_inheritance
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