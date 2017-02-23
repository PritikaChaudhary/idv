class Coupon
  include MongoMapper::Document
  key :user_id, String
  key :coupon_code, String
  key :name, String
  key :discount_type, String
  key :discount_in_cents, String
  key :discount_percent, String
  key :plan_codes, String
  key :single_use, String
  key :max_redemptions, String
  key :temporal_amount, String
  key :temporal_unit, String
  key :applies_to_non_plan_charges, String
  key :redemption_resource, String
  key :max_redemptions_per_account, String
  key :coupon_type, String
  key :unique_code_template, String
  key :plan_codes, String
  key :applies_to_all_plans, String 
  key :redeem_by_date, String
  key :duration, String
  key :created_date, String
end