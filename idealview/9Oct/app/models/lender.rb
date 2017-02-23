class Lender
  include MongoMapper::Document
  include ActionView::Helpers

  many :loans

  key :infusion_id, Integer
  key :firstName, String
  key :lastName, String
  key :name, String
  key :company, String
  key :jobTitle, String
  key :streetAddress1, String
  key :streetAddress2, String
  key :city, String
  key :state, String
  key :postalCode, String
  key :country, String
  key :phone1, String
  key :phone2, String
  key :fax1, String
  key :email, String
  key :website, String
  key :address2Street1, String
  key :address2Street2, String
  key :city2, String
  key :state2, String
  key :postalCode2, String
  key :country2, String
  key :address3Street1, String
  key :address3Street2, String
  key :city3, String
  key :state3 , String
  key :postalCode3, String  
  key :country3, String  
  key :numberOfClosedDeals, String
  key :fDRanking, String
  key :loanMinDropDown, Integer
  key :loanMaxDropDown, String
  key :pointsMin, Integer
  key :pointsMax, Integer
  key :interestRateMin, Integer
  key :interestRateMax, Integer
  key :termLengthMin, Integer
  key :termLengthMax, Integer
  key :termLengthType, String
  key :capitalizationStructure0, String
  key :timeInBusiness, Integer
  key :lendingStates0, String
  key :otherLendingPreferences, String
  key :loanToValueMin, String
  key :loanToValueMax, String
  key :lendingCountries, String
  key :lendingCategory, String
  key :lendingTypes, String
  key :businessFinancingTypes, String
  key :equityandCrowdFunding, String
  key :mortageTypes, String
  key :broker, Integer
  key :password, String
  key :delete, Integer

  

  def self.highlight_fields
   temp = [
       :Id,
       :FirstName,
       :LastName, 
       :Company, 
       :JobTitle,
       :StreetAddress1, 
       :StreetAddress2, 
       :City, 
       :State, 
       :PostalCode, 
       :Country, 
       :Phone1, 
       :Phone2, 
       :Fax1, 
       :Email, 
       :Website, 
       :Address2Street1, 
       :Address2Street2, 
       :City2, 
       :State2, 
       :PostalCode2, 
       :Country2, 
       :Address3Street1, 
       :Address3Street2, 
       :City3, 
       :State3 , 
       :PostalCode3,   
       :Country3, 
       :_NumberOfClosedDeals, 
       :_FDRanking, 
       :_LoanMinDropDown, 
       :_LoanMaxDropDown, 
       :_PointsMin, 
       :_PointsMax, 
       :_InterestRateMin, 
       :_InterestRateMax, 
       :_TermLengthMin, 
       :_TermLengthMax, 
       :_TermLengthType,
       :_CapitalizationStructure0, 
       :_TimeInBusiness, 
       :_LendingStates0, 
       :_OtherLendingPreferences, 
       :_LoanToValueMin, 
       :_LoanToValueMax, 
       :_LendingCountries,
       :_LendingCategory,
       :_LendingTypes,
       :_BusinessFinancingTypes,
       :_EquityandCrowdFunding,
       :_MortageTypes
    ]
  end

end
