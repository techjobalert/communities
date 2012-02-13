class DocumentToPdf
  @queue = :document_to_prf

  def self.perform(document_path, save_to)
  	document_path = '../../document'
  	pdf_save_to ||= document_path+'/pdf'
  	command = %x[libreoffice --headless -convert-to pdf #{document_path} -outdir #{pdf_save_to}]
  end
end