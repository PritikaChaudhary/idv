class LoanUrl
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :email, :required=>true
  key :name, :required=>true 
  key :dateCreated  #added on init
  key :url #added on init
  key :visits
  key :emailed
  key :status
  belongs_to :loan


  #before_save :init_url

 
 def get_url
    host = "http://dash.idealview.us"
    return host+'/loans/'+self.url
 end
 

 def init_url
    if self.url.blank?
      self.url =  Digest::MD5.hexdigest('funding'+self.loan._id.to_s+Time.now.getutc.to_s)
      self.dateCreated = Time.now.getutc
      self.visits = Array.new
      self.emailed = false
    end
  end


end