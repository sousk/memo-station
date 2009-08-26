# $Id$

# インストール関連

require "rake/contrib/sys"

namespace "install" do
  desc "すべてのライブラリのインストール"
  task :all => [:pdf, :graphics] do
  end

  desc "PDFライブラリとRubyバインディングのインストール"
  task :pdf => [:pdflib, "pdf-writer-all"] do
  end

  desc "pdf-writerのインストール(パッチあて)"
  task "pdf-writer-all" => ["pdf-writer", "pdf-writer-ja-patch", :pdftest] do
  end

  desc "Cで書かれたPDFlibのインストール"
  task :pdflib do
    Sys.run "
cd ~/opt
wget http://www.pdflib.com/products/pdflib/download/603src/PDFlib-Lite-6.0.3.tar.gz
tar xzvf PDFlib-Lite-6.0.3.tar.gz
cd ~/opt/PDFlib-Lite-6.0.3
./configure
make
sudo make install
"
  end

  desc "pdflibのRubyバインディング pdf-writer をインストール"
  task "pdf-writer" do
    Sys.run "sudo gem install -y pdf-writer"
  end

  desc "pdf-writerを日本語に対応させる"
  task "pdf-writer-ja-patch" do
    Sys.run "
cd ~/opt
wget http://www2s.biglobe.ne.jp/~Nori/ruby/dist/pdf-writer-1.1.3-ja_font_patch-20060516.tar.gz
tar xzvf pdf-writer-1.1.3-ja_font_patch-20060516.tar.gz
cd /usr/local/lib/ruby/gems/1.8/gems/pdf-writer-1.1.3
sudo patch --batch -p0 < ~/opt/pdf-writer-1.1.3-ja_font_patch-20060516/pdf-writer-1.1.3-ja_font_patch-20060516.diff
"
  end

  desc "PDF関連ライブラリが動作するか簡単にテスト"
  task :pdftest do
    begin
      require 'rubygems'
      require 'pdf/writer'
      pdf = PDF::Writer.new
      pdf.select_font('Ryumin-Light', 'EUC-H')
      puts "OK"
    rescue
      puts $!
      puts "NG"
    end
  end

  desc "グラフィックス関連のインストール"
  task :graphics => [:image_magick, :rmagick]

  desc "ImageMagickのインストール"
  task :image_magick do
    Sys.run "
sudo apt-get install -y libtool
sudo apt-get install -y 'freetype*'

cd ~/opt
wget ftp://ftp.u-aizu.ac.jp/pub/graphics/image/ImageMagick/imagemagick.org/ImageMagick-6.2.8-5.tar.gz
tar xzvf ImageMagick-6.2.8-5.tar.gz
cd ImageMagick-6.2.8
./configure
make
sudo make install
"
  end

  desc "gemで入れるライブラリ"
  task :gem do
    Sys.run "sudo gem install -y rmagick sparklines sparklines_generator"
    Sys.run "sudo gem install -y gruff"
    Sys.run "sudo gem cleanup"
  end
end

