class CreatePreview
  @queue = :store_asset

  def self.perform(item_id, to, source_attachment=nil)
    #from 0 to #(seconds or pages)
    item = Item.find item_id

    unless item.attachments.where(:attachment_type => "#{item.attachment_type}_preview").last
      if source_attachment
        attachment = Attachment.find(source_attachment)
      else
        attachment = item.common_video
      end
      source = nil
      dest = nil
      hex = SecureRandom.hex

      Rails.logger.debug "------------#{attachment.file}--------------"
      case item.attachment_type
      # when "pdf"
      #   # pdftk A=one.pdf B=two.pdf cat A1-7 B1-5 A8 output combined.pdf
      #   dest = File.join(File.dirname(attachment.file.path), "#{hex}-splited.pdf")
      #   system("pdftk A=#{attachment.file.path} cat A1-#{to} output #{dest}")
      when "presenter_merged_video", "presentation_video", "video"
        attachment.file.cache_stored_file! if !attachment.file.cached?
        source = attachment.file.path
        dest = File.join(File.dirname(source), "#{hex}-splited#{File.extname(source)}")
        Rails.logger.debug "________source___#{source}___________dest____#{dest}_______"
        msg = system("ffmpeg -y -i #{source} -ss 0 -t #{to} #{dest}")
        Rails.logger.debug "________msg___#{msg}________"
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
