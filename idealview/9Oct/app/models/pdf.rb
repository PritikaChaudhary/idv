class Pdf
  include MongoMapper::Document
  many :loan_pdfs

  key :name, String
  key :date_created, String
  key :emails, String
  key :file_name, String
  key :content, String
  key :status, Integer

  def pdf_by_loan
    LoanPdf.find_all_by_pdf_id(self._id, :order => "sort_id ASC")
  end

end