class EmailReceive
  @queue = :incoming_email_queue
  def self.perform(from, to, subject, body,attachFile)
    # user = User.find_by_id('55d5a859dba1d62b4f000001')

    # if user.nil?
    #   raise InvalidReplyUser, "User with email = #{from} is not a member of the app."
    # end

    

    log = Logger.new 'log/resque.log'
    log.debug "My message ~~~~~~~~~~~~~~~~~ #{body}"
    params = {
      :body     => body,
      :to       => to,
      :subject  => subject,
      :from     => from,
      :attachFile     => attachFile,
    }

    log.debug "Params ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  #{params}"
     # :user_id => user.id
    # abort("#{params}")
    
    lemail = LoanEmail.new
    lemail.body = body
    lemail.to = to
    lemail.from = from
    lemail.subject = subject
    lemail.file_name = attachFile
    check = lemail.save
    log.debug  "New Email~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  #{params[:attachFile]}"
    log.debug check
    # check = LoanEmail.all
    # abort("#{check.inspect}")
    # unless lemail.save
    #   raise RuntimeError, "Unable to save message. Errors: #{message.errors.inspect}"
    # end
  end
end
