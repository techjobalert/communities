class DocumentToPdf
  @queue = :document_to_prf

  def self.perform(document_path, save_to)
  	video_path = '../../document'
  	save_to ||= video_path+'/pdf'
  	command = "libreoffice --headless -convert-to pdf fileToConvert.docx -outdir output/path/for/pdf"
  	output = %x[cd #{upload_dir} && #{command}]
  end
end