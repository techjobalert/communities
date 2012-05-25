class CreatePreview
  @queue = :store_asset

  def self.perform(item_id, to)
    #from 0 to #(seconds or pages)
    item = Item.find item_id
    attachment = item.attachments.last
    dest = nil

    case attachment.attachment_type
    when "pdf"
      # pdftk A=one.pdf B=two.pdf cat A1-7 B1-5 A8 output combined.pdf
      dest = File.join(File.dirname(attachment.file.path), "splited.pdf")
      system("pdftk A=#{attachment.file.path} cat A1-#{to} output #{dest}")
    when "presenter_merged_video", "presentation_video", "video"
      dest = File.join(File.dirname(attachment.file.path), "splited.#{File.extname(attachment.file.path)}")
      system("ffmpeg -i #{attachment.file.path} -ss 0 -t #{to} #{dest}")
    end

    if dest
      new_attachment = Attachment.create!({
                :file => File.open(dest),
                :user => item.user,
                :item_id => item.id,
                :attachment_type => "preview"})
      #remove source file
      FileUtils.remove_file(dest, :verbose => true)
    end

  end
end
