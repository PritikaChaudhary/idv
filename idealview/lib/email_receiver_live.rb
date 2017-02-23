require 'rubygems'
require 'resque'
require 'redis'
require 'mail'
# require 'FileUtils'

class EmailReceive
  @queue = :incoming_email_queue


  def initialize(content)
    mail    = Mail.read_from_string(content)
    body    = mail.body.decoded
    from    = mail.from.first
    to      = mail.to.first
    subject = mail.subject

    # log = Logger.new "/home/rails/idealview/log/resque.log"
    # iFile = File.read("#{mail.attachments.first}")

   if mail.attachments
      attachFiles = Array.new
       mail.attachments.each do |attach|
          attachment = attach
       
          file = StringIO.new(attachment.decoded)
          file.class.class_eval { attr_accessor :original_filename, :content_type }
          file.original_filename = attachment.filename
          file.content_type = attachment.mime_type
          #File.open("/tmp/file.png", "w")do |f|
          extension = File.extname(file.original_filename)
          base=File.basename(file.original_filename, extension)

          new_file = base+"_"+Time.now.strftime("%m%d%y%H%M%S")+extension
          #save_path = Rails.root.join('filecontent',new_file)
         
         #  File.open("save_path", "w")do |f|
          # File.open("/home/rails/idealview/filecontent/#{new_file}", File::RDWR|File::CREAT, 0644)do |f|
          # newfile = File.open("/home/rails/idealview/filecontent/#{new_file}", 'w+',0664)
          # abort("#{newfile}")
          # FileUtils.chmod 0644,newfile
          File.open("/home/rails/idealview/public/temp/#{new_file}", 'w+',0664) do |f|
              f.write(attachment.decoded)

              # abourtf.umask(2)
          end 
          File.chmod(0644,"/home/rails/idealview/public/temp/#{new_file}")

          attachFiles << new_file
      end
      attachFile = attachFiles.join(",")
      if mail.text_part.body
         message = mail.text_part.body.decoded
      end
     else
      if mail.text_part.body
          message = mail.text_part.body.decoded
      end
     end
    
    

    # abort("starting Mail log --->>> mail.multipart #{mail.text_part.body.decoded}")
    
    # if mail.multipart?
    #   part = mail.parts.select { |p| p.content_type =~ /text\/plain/ }.first rescue nil
    #   unless part.nil?
    #     message = part.body.decoded
    #   end
    # else
    #   message = mail.decoded
    # end
    
    unless message.nil?
      # abort("#{message}")
      # log = Logger.new 'log/resque.log'
    # log.debug "foo bar"
      Resque.enqueue(EmailReceive, from, to, subject, message,attachFile)
    #abort("#{check.inspect}")
    end
  end
end

EmailReceive.new($stdin.read)
