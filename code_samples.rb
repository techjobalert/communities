# http://net-ssh.github.com/sftp/v2/api/index.html
require 'net/sftp'

Net::SFTP.start('host', 'username', :password => 'password') do |sftp|
  # upload a file or directory to the remote host
  sftp.upload!("/path/to/local", "/path/to/remote")

  # download a file or directory from the remote host
  sftp.download!("/path/to/remote", "/path/to/local")

  # grab data off the remote host directly to a buffer
  data = sftp.download!("/path/to/remote")

  # open and write to a pseudo-IO for a remote file
  sftp.file.open("/path/to/remote", "w") do |f|
    f.puts "Hello, world!\n"
  end

  # open and read from a pseudo-IO for a remote file
  sftp.file.open("/path/to/remote", "r") do |f|
    puts f.gets
  end

  # create a directory
  sftp.mkdir! "/path/to/directory"

  # list the entries in a directory
  sftp.dir.foreach("/path/to/directory") do |entry|
    puts entry.longname
  end
end



sftp.download!("remote", "local") do |event, downloader, *args|
  case event
  when :open then
    # args[0] : file metadata
    puts "starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes}"
  when :get then
    # args[0] : file metadata
    # args[1] : byte offset in remote file
    # args[2] : data that was received
    puts "writing #{args[2].length} bytes to #{args[0].local} starting at #{args[1]}"
  when :close then
    # args[0] : file metadata
    puts "finished with #{args[0].remote}"
  when :mkdir then
    # args[0] : local path name
    puts "creating directory #{args[0]}"
  when :finish then
    puts "all done!"
end
