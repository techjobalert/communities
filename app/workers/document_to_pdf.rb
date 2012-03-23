require 'mini_magick'

class DocumentToPdf
  @queue = :document_to_prf

  def self.perform(obj)
    file_name = File.basename()
    File.dirname()
  	command = %x[libreoffice --headless -convert-to pdf #{path} -outdir #{path}]

    pdf = MiniMagick::ImageList.new("doc.pdf")
    thumb = pdf.scale(300, 300)
    thumb.write "thumb.png"
  end
end