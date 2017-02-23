class Loan
  include MongoMapper::Document
  include ActionView::Helpers

  many :images
  many :documents
  many :ndas
  many :loan_urls

  key :name, String
  key :info, Object
  key :published, Boolean
  key :allowed_emails, String
  key :url, String
  key :doc_url, String
  key :url_time, Date
  key :nda_signed, Boolean
  key :archived, Boolean
  key :delete, Integer
  key :sort_id, Integer
  key :email, String
  key :created_date, String
  key :completed, Integer
  key :incomplete, Integer
  key :added_by, String
  key :stepping, Integer
  key :created_at, Time
  key :updated_at, Time
  key :complete_email, Integer
  key :fd_id, Integer
  
  def pay_offs
    PayOffAmount.all(:loan_id => self.id)
  end


  def address
    if !self.info['Address3Street1'].blank? && defined? self.info['City3'] && defined? self.info['State3'] && defined? self.info['PostalCode3']
      self.info['Address3Street1'].to_s+','+self.info['City3'].to_s+','+self.info['State3'].to_s+','+self.info['PostalCode3'].to_s
    else
     return 'None'
    end
  end

  def new_db id
    abort("#{@user_config}")
       file_path = "#{Rails.root}/config/settings/#{current_user.id}.yml"
        #abort("#{file_path}")
        @user_config =  YAML.load_file("#{file_path}")
      
  abort("#{@user_config}")
  connection(Mongo::Connection.new('localhost', 27017))
  set_database_name "#{@user_config['settings']['db']}"


  end
  #def category
   #temp =  Infusionsoft.data_load('Contact', self._id, [:_LendingCategory])
   #abort("#{temp.inspect}")
   #return temp['_LendingCategory']
  #end

  #def loan_type
   # case self.category
   # when 'Private Real Estate Loan'
    #  temp = Infusionsoft.data_load('Contact', self._id, [:_LendingTypes])
     # return temp['_LendingTypes']
    #when 'Business Financing'
     # temp = Infusionsoft.data_load('Contact', self._id, [:_BusinessFinancingTypes])
     # return temp['_BusinessFinancingTypes']
    #when 'Equity and Crowdfunding'
     # temp = Infusionsoft.data_load('Contact', self._id, [:_EquityandCrowdFunding])
      #return temp['_EquityandCrowdFunding']
    #when 'Residential or Commercial Mortgage'
     # temp = Infusionsoft.data_load('Contact', self._id, [:_MortageTypes])
      #return temp['_MortageTypes']
    #end
  #end  
  
  #grab the featured image to display on the overview page
  def featured_image
    self.images.each do |img|
      if img.featured == true
        return img
      end
    end
    return 
  end



  def get_s3_images
    resp = S3.list_objects(
      bucket: S3_BUCKET_NAME,
      encoding_type: "url",
      max_keys: 100,
      prefix: self.id.to_s
    )
    output = Array.new
      resp.each do |page|
        page.each do |item|
          item.contents.each do |image|
            output<<image.key
          end
        end
      end
    output 

  end



  def use_of_fund
    UseOfFund.all(:loan_id => self.id)
  end

  def borrower
    Borrower.all(:loan_id => self.id, :order => :id.desc)
  end

  def collateral
    Collateral.all(:loan_id => self.id, :order => :id.desc)
  end
  
  def get_images
    fields = ['ContactId', 'Extension','FileName','Id','Public']
   # files = Infusionsoft.data_find_by_field('FileBox',1000,0,'ContactId', self._id, fields)
    return self.images
  end
  
  
  
  
  
  
  
  def find_image(name)
     self.images.each do |x|
        if x.name ==name
          return x
       end 
     end
    
  end
  

  def get_docs
    fields = ['ContactId', 'Extension','FileName','Id','Public']
    #files = Infusionsoft.data_find_by_field('FileBox',1000,0,'ContactId', self._id, fields)

      
    #abort("#{files.inspect}")
    #remove docs from the database that have been removed from IS
    docs = self.documents

    docs.each_with_index do |doc, index|
      is_doc = false
      if defined? files.blank?
         files.each do |file|
          if doc.file_id == file['Id'].to_i
            is_doc = true
          end
        end   
      end
     
      if !is_doc
         doc.delete
         #docs.delete_at(docs.index(index))
      end
    end
    return docs
  end 
  



  
  def docs_by_category category
    Document.find_all_by_loan_id_and_category(self._id.to_i, category)
  end
  
  
  
  def self.file_categories
    [
      'Borrower Info & Corporate Docs',
      'Environmental',
      'Property Inspections',
      'Project',
      'Title,Taxes & Insurance',
      'Valuation',
      'Other'
    ]
  end
  
  def self.category_options
    ['Private Real Estate Loan', 'Business Financing', 'Equity and Crowdfunding', 'Residential or Commercial Mortgage']
  end

  def self.category_type_fields
    {'Private Real Estate Loan'=>'_LendingTypes', 
      'Business Financing'=>'_BusinessFinancingTypes',
       'Equity and Crowdfunding'=>'_EquityandCrowdFunding',
        'Residential or Commercial Mortgage'=>'_MortageTypes'}
  end


  def self.paid_options
    {
      'Paid In Full'=>'1',
      'Has Mortgage'=>'0'
    }
  end


  def self.time_options
    {
      '1 Year'=>'1',
      '2 Years'=>'2',
      '3 Years'=>'3',
      '4 Years'=>'4',
      '5 Years'=>'5',
      '6 Years'=>'6',
      '7 Years'=>'7',
      '8 Years'=>'8',
      '9 Years'=>'9',
      '10+ Years'=>'10',

   }
  end

  def self.month_options
    {
      '1 Month'=>'1',
      '2 Months'=>'2',
      '3 Months'=>'3',
      '4 Months'=>'4',
      '5 Months'=>'5',
      '6 Months'=>'6',
      '7 Months'=>'7',
      '8 Months'=>'8',
      '9 Months'=>'9',
      '10 Months'=>'10',
      '11 Months'=>'11',
      '12 Months'=>'12',
   }
  end

  def self.asset_types 
  {

      'Single Family Residence' => 'Single Family Residence',
      'Multifamily'=>'Multifamily',
      'Condo'=>'Condo',
      'Hospitality'=>'Hospitality',
      'Commercial'=>'Commercial',
      'Short Term Real Estate Loan'=>'Short Term Real Estate Loan',
      'Development'=>'Development',
      'Mixed Use'=>'Mixed Use',
      'Retail'=>'Retail',
      'Health Care'=>'Health Care',
      'Industrial'=>'Industrial',
      'Other'=>'Other'
    
  }
  end
     

  def self.loan_type_options 
   
    {
      'Private Real Estate Loan'=>[
          'Single Family Residence',
          'Multifamily',
          'Condo',
          'Hospitality',
          'Commercial',
          'Short Term Real Estate Loan',
          'Development',
          'Mixed Use',
          'Retail',
          'Health Care',
          'Industrial',
          'Other'
          ],
    
      'Business Financing' => [
          'Equipment/Inventory',
          'Working Capital',
          'Factoring',
          'Cash Advances',
          'Accounts Receivable Financing',
          'Supply Chain Financing',
          'Expansion Capital',
          'Equity',
          'SBA Financing'
        ],
    
      'Equity and Crowdfunding' => [
          'Project Financing',
          'Acquisition and Development',
          'Start Up',
          'Business Partnership'
        ],
  
      'Residential or Commercial Mortgage' => [
          'Owner Occupied',
          'Second Home',
          'Investment Property',
          'FHA',
          'VA',
          'Reverse Mortgage',
          'Sub Prime',
          'HUD Financing',
          'Multifamily',
          'Hospitality',
          'Land Development',
          'Mixed Use',
          'Retail',
          'Industrial',
          'Healthcare',
          'Other',
      ],
      'Mortgage' => [
            'Owner Occupied',
            'Second Home',
            'Investment Property',
            'FHA',
            'VA',
            'Reverse Mortgage',
            'Sub Prime',
            'HUD Financing',
            'Multifamily',
            'Hospitality',
            'Land Development',
            'Mixed Use',
            'Retail',
            'Industrial',
            'Healthcare',
            'Other',
      ],
    }
  end
  


  def self.person_fields
    [
    :Id,
    :FirstName,
    :LastName,
    :Email,
    :_LenderEmail,
    :_BrokerEmail
    ]
    
  end
  

  def self.lender_fields
    [
    :id,
    :FirstName,
    :LastName,
    :Email,
    :Company,
    :Groups,
    :_LendingCategory,
    :_LendingTypes,
    :_BusinessFinancingTypes,
    :_EquityandCrowdFunding,
    :_MortageTypes,
    :_BrokerRepresentingLender,
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
    :_NumberOfClosedDeals,
    ]
  end
  
  
  def self.regular_fields
      [
      :AccountId,
      :Address1Type,
      :Address2Street1,
      :Address2Street2,
      :Address2Type,
      :Address3Street1,
      :Address3Street2,
      :Address3Type,
      :Anniversary,
      :AssistantName,
      :AssistantPhone,
      :BillingInformation,
      :Birthday,
      :City,
      :City2,
      :City3,
      :Company,
      :CompanyID,
      :ContactNotes,
      :ContactType,
      :Country,
      :Country2,
      :Country3,
      :CreatedBy,
      :DateCreated,
      :Email,
      :EmailAddress2,
      :EmailAddress3,
      :Fax1,
      :Fax1Type,
      :Fax2,
      :Fax2Type,
      :FirstName,
      :Groups,
      :Id,
      :JobTitle,
      :LastName,
      :LastUpdated,
      :LastUpdatedBy,
      :LeadSourceId,
      :Leadsource,
      :MiddleName,
      :Nickname,
      :OwnerID,
      :Password,
      :Phone1,
      :Phone1Ext,
      :Phone1Type,
      :Phone2,
      :Phone2Ext,
      :Phone2Type,
      :Phone3,
      :Phone3Ext,
      :Phone3Type,
      :Phone4,
      :Phone4Ext,
      :Phone4Type,
      :Phone5,
      :Phone5Ext,
      :Phone5Type,
      :PostalCode,
      :PostalCode2,
      :PostalCode3,
      :ReferralCode,
      :SpouseName,
      :State,
      :State2,
      :State3,
      :StreetAddress1,
      :StreetAddress2,
      :Suffix,
      :Title,
      :Username,
      :Validated,
      :Website,
      :ZipFour1,
      :ZipFour2,
      :ZipFour3, 
      ] 
  end
  
  def self.custom_fields
    [
    :_LoanName,
    :_SocialSecurityNumber,
    :_EIN,
    :_GrossMonthlyIncome,
    :_PrimaryIncomeSource,
    :_CorporateBorrowerName,
    :_WorkingWithBroker,
    :_BrokerName,
    :_BrokerEmail,
    :_SourceURL,
    :_UserIP,
    :_LenderEmail,
    :_NetLoanAmountRequested0,
    :_TransactionType0,
    :_ExpectedCloseDate,
    :_CashContribution,
    :_PurchasePrice,
    :_AdditionalCollateral,
    :_OriginalPurchasePriceifitsarefinance,
    :_OriginalPurchaseDateifitsarefinance,
    :_LoanSummaryWhatareyoulookingfor,
    :_AdditionalCollateralWhatelsecanyouofferassecurity0,
    :_UseofFundsWhatdoyouneedthecapitalfor,
    :_ExitStrategyHowwillyoupaytheloanoff,
    :_DesiredTermLength,
    :_AppraisalDate,
    :_LendingCategory,
    :_LendingTypes,
    :_BusinessFinancingTypes,
    :_EquityandCrowdFunding,
    :_MortageTypes,
    :_NoAppraisalavailable,
    :_FreeandClear0,
    :_CollateralStreetAddress,
    :_CollateralCity,
    :_CollateralState,
    :_ColateralPostalCode,
    :_CollateralCountry,
    :_EstimatedMarketValue,
    :_SourceofValuatoin,
    :_DateofValuation,
    :_Doesthepropertycurrentlygenerateincome,
    :_HowmuchGrossMonthlyIncome,
    :_Mostrecentappraisedvalue,
    :_BusinessName,
    :_BusinessEIN,
    :_BorrowerTimeInBusiness,
    :_BorrowerBio,
    :_BusinessType,
    :_CashOnHand,
    :_AvailableCredit,
    :_AnnualNOI,
    :_MonthlyNOI,
    :_RevenueTimePeriod,
    :_FinancialsTimePeriod,
    :_YearofTaxes,
    :_EstFICO,
    :_AccountsReceivable,
    :_AccountsPayable,
    :_Equipment,
    :_CompanyDebt,
    :_BrokerRepresentingLender,
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
    :_NumberOfLendersShopped,
    :_AmountOwed,
    ]
  end
  
  def self.action_fields
      [
      :Accepted,
      :ActionDate,
      :ActionDescription,
      :ActionType,
      :CompletionDate,
      :ContactId,
      :CreatedBy,
      :CreationDate,
      :CreationNotes,
      :EndDate,
      :Id,
      :IsAppointment,
      :LastUpdated,
      :LastUpdatedBy,
      :ObjectType,
      :OpportunityId,
      :PopupDate,
      :Priority,
      :UserID,
      ]
  end


  def self.highlight_fields
   temp = [
      :_LoanName,
      :_NetLoanAmountRequested0,
      :_TransactionType0,
      :_CashContribution,
      :_DesiredTermLength,
      #:_ExpectedCloseDate,
      :_EstimatedMarketValue,
      :_LendingCategory
    ]
    self.person_fields | temp
  end

  def self.all_fields
    @temp = self.person_fields |self.lender_fields
    @temp = @temp | self.regular_fields
    @temp = @temp | self.custom_fields
    #@temp = @temp | self.action_fields
    return @temp
  end
  


  
  def self.states
    {
      "Alabama" => "Alabama",
      "Alaska" => "Alaska",
      "Arizona" => "Arizona",
      "Arkansas" => "Arkansas",
      "California" => "California",
      "Colorado" => "Colorado",
      "Connecticut" => "Connecticut",
      "Delaware" => "Delaware",
      "District of Columbia" => "District of Columbia",
      "Florida" => "Florida",
      "Georgia" => "Georgia",
      "Hawaii" => "Hawaii",
      "Idaho" => "Idaho",
      "Illinois" => "Illinois",
      "Indiana" => "Indiana",
      "Iowa" => "Iowa",
      "Kansas" => "Kansas",
      "Kentucky" => "Kentucky",
      "Louisiana" => "Louisiana",
      "Maine" => "Maine",
      "Maryland" => "Maryland",
      "Massachusetts" => "Massachusetts",
      "Michigan" => "Michigan",
      "Minnesota" => "Minnesota",
      "Mississippi" => "Mississippi",
      "Missouri" => "Missouri",
      "Montana" => "Montana",
      "Nebraska" => "Nebraska",
      "Nevada" => "Nevada",
      "New Hampshire" => "New Hampshire",
      "New Jersey" => "New Jersey",
      "New Mexico" => "New Mexico",
      "New York" => "New York",
      "North Carolina" => "North Carolina",
      "North Dakota" => "North Dakota",
      "Ohio" => "Ohio",
      "Oklahoma" => "Oklahoma",
      "Oregon" => "Oregon",
      "Pennsylvania" => "Pennsylvania",
      "Rhode Island" => "Rhode Island",
      "South Carolina" => "South Carolina",
      "South Dakota" => "South Dakota",
      "Tennessee" => "Tennessee",
      "Texas" => "Texas",
      "Utah" => "Utah",
      "Vermont" => "Vermont",
      "Virginia" => "Virginia",
      "Washington" => "Washington",
      "West Virginia" => "West Virginia",
      "Wisconsin" => "Wisconsin",
      "Wyoming" => "Wyoming",
    }
    
  
  end
  
  def self.transaction_types
    ["Purchase", "Refinance", "Both"]
  end

  def self.term_lengths
    {"Less Than 3 Months"=>'3', 
      '3 to 6 Months'=>'6',
      '6 to 12 Months'=>'12',
      '12 to 24 Months'=>'24',
      'More than 24 Months'=>'25'      
      }
    
  end

  def self.source_of_values
    { 
      "Appraisal"=>'Appraisal', 
      'BPO/CMA'=>'BPO/CMA',
      'Market Research'=>'Market Research',
    }
    
  end

  def self.sizes
    { 
      "Sq Footage"=>'Sq Footage', 
      'Acres'=>'Acres',
      'Units'=>'Units',
    }
  end

  def self.transaction_types
    { 
      "Purchase"=>'Purchase', 
      'Refinance'=>'Refinance'
    }
  end

  def self.borrower_types
    { 
      "Individual"=>'Individual', 
      'Company or Trust'=>'Company or Trust',
    }
  end

  def self.is_guarantor
    { 
      "Yes"=>'Yes', 
      'No'=>'No',
    }
  end




 
end
