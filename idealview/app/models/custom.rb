class Custom
  include MongoMapper::Document
  key :user_id, String
  key :form, String
  key :display_name, String
  key :hide_fields, String
  key :hide, Integer
  key :required, Integer


  def custom_fields
  	@fields = CustomField.all(:custom_id => "#{self.id}", :hide => 1)
    # abort("#{@fields.inspect}")
  	@hide_fields = Array.new
  	@fields.each do |field|
  		@hide_fields << field.field_name
  	end
  	return @hide_fields
  end

  def required_fields
    @fields = CustomField.all(:custom_id => "#{self.id}", :required => 1)
    @required_fields = Array.new
    @fields.each do |field|
      @required_fields << field.field_name
    end
    return @required_fields
  end

end