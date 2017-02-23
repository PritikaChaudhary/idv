class Collateral
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :address, String
  key :city, String
  key :state, String
  key :postalcode, String
  key :estimated_value, String
  key :amount_owed, String
  key :mortgage_status, String
  key :gross_monthly_income, String
  key :purchase_price, String
  key :original_purchase_price, String
  key :source_of_value, String
  key :date_last_valuation, String
  key :date_last_bpo, String
  key :property_generate_income, String
  key :noi_ytd, String
  key :noi_last_year, String
  key :noi_two_years_ago, String
  key :noi_this_year, String
  key :noi_next_year, String
  key :noi_two_years_from_now, String
  key :transaction_type, String
  key :signed_contract, String
  key :contract_closing_date, String
  key :rehab_amount, String
  key :purchase_cash_contribute, String
  key :pay_off_amount, String
  key :pay_off_recipient, String
  key :maturity_date, String
  key :refinance_cash_contribute, String
  key :vested_by, String
  key :original_purchase_date, String
  key :cash_contributed, String
  key :asset_type, String
  key :collateral_value, String
  key :related_payoffs, String
  key :related_funds, String
  key :hide, Integer
  key :size, String
  key :sq_footage, String
  key :acres, String
  key :structural_size, String
  key :structural_sq_footage, String
  key :units, String
  key :sf_per_unit, String
  key :hide_fields, String

  def pay_offs
    PayOffAmount.all(:collateral_id => self.id.to_s)
  end
end