class FileController < ApplicationController

  def upload
    file = params[:file]
    File.open('vendor/erlyvideo/' + file.original_filename, "wb") do |f|
      f.write(params[:file].read)
    end
    redirect_to "/file/load/#{file.original_filename}"
  end

  def load
    @name = params[:name]
    puts @name, params
  end

  def convert
    Resque.enqueue(VideoConvert, params[:name])
  end

  def merge
    Resque.enqueue(VideoMerge, params[:name], params[:name2])
  end

end
