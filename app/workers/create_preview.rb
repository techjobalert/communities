class CreatePreview
  @queue = :create_preview

  def self.perform(item_id, to)
    #from 0 to #(seconds or pages)
    item = Item.find item_id
    unless item.attachments.where(:attachment_type => "#{item.attachment_type}_preview").last
      attachment = item.common_video
      source = nil
      dest = nil
      hex = SecureRandom.hex

      case item.attachment_type
      # when "pdf"
      #   # pdftk A=one.pdf B=two.pdf cat A1-7 B1-5 A8 output combined.pdf
      #   dest = File.join(File.dirname(attachment.file.path), "#{hex}-splited.pdf")
      #   system("pdftk A=#{attachment.file.path} cat A1-#{to} output #{dest}")
      when "presenter_merged_video", "presentation_video", "video"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        Rails.logger.info "----------------------------------------------------------"
        attachment.file.cache_stored_file! if !attachment.file.cached?
        source = attachment.file.path
        dest = File.join(File.dirname(source), "#{hex}-splited#{File.extname(source)}")
        system("ffmpeg -y -i #{source} -ss 0 -t #{to} #{dest}")
      end

      if dest
        new_attachment = Attachment.create!({
                  :file => File.open(dest),
                  :user => item.user,
                  :item_id => item.id,
                  :attachment_type => "#{item.attachment_type}_preview"})
        #remove source and dest file
        #FileUtils.remove_file(dest, :verbose => true)
        FileUtils.rm_rf(File.dirname(source))
      end
    end
  end
end
