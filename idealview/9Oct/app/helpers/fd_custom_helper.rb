module FdCustomHelper
  def fd_money input
   if !input.blank?
    '$'+number_to_currency(input, separator: ".", delimiter: ",", format: '%n')
   end
  end
  
 def fd_text input
   if !input.blank?
     input.to_s
   end
 end
 
 def fd_number input
   if !input.blank?
    input.to_s.gsub(/[^\d\.]/, '')
   end
 end
 
 def fd_percent input
   if !input.blank?
    self.fd_number input +'%' 
   end  
 end
 
 def fd_date input
   if !input.blank?
      if input[0...3]=='No '
        input
      else
       input.to_date.strftime("%b %d, %Y")
      end 
   else
     input
   end
   
 end
 
 def fd_phone input
   if !input.blank?
     temp = fd_number(input)
     number_to_phone(temp, area_code: true)
   end
 end


 def fd_ssn input
   if !input.blank?
     temp = fd_number(input)
     if temp.length >4
      '*****'+temp[-4,4]
     else
        '***Invalid***'
     end
   else
     'N/A'
   end
   
 end

 def fd_xml_to_date input
    if defined? input.year
       if !input.blank?
          fd_date(input.year.to_s+'-'+input.month.to_s+'-'+input.day.to_s)
        end
    else
     input
    end 
 end
end