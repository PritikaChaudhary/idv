class CouponsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'


  def index
    # Coupon.delete_all
    @total = Coupon.count
    @coupons = Coupon.paginate(:order => :id.desc, :per_page => 10, :total_entries => @total)
    @page = 1
  end 

  def add
    # abort("#{current_user.inspect}")
  end

  def create
    # abort("#{params.inspect}")
    Time.now.strftime("%m-%d-%y_%H-%M-%S")

    if params[:redeem_by_date].blank?
      redeem_date = ""
    else
      # abort(params[:redeem_by_date])
      redeem =  DateTime.parse("#{params[:redeem_by_date]}")
      redeem_date = redeem.strftime("%Y-%m-%d")
      # abort("#{redeem_date}")
    end
    if params[:dollar].blank?
      dcent = ""
    else
      dcent = params[:dollar].to_f * 100
      dcent =  dcent.to_i
    end
    coupon = Recurly::Coupon.new(
      :coupon_code    => "#{params[:coupon_code]}",
      :redeem_by_date => redeem_date,
      :duration     => "#{params[:duration]}",
      :name => "#{params[:name]}",
      :coupon_type => "single_code",
      :discount_type => "#{params[:discount_type]}",
      :discount_percent => "#{params[:percentage]}",
      :discount_in_cents => dcent,
      :duration => "#{params[:duration]}",
      :temporal_amount => "#{params[:temporal_amount]}",
      :temporal_unit => params[:temporal_unit],
      :max_redemptions => params[:max_redemptions],
      :applies_to_all_plans => true,
      :redemption_resource => "account"

    )
    coupon.save
    
    # abort("#{current_user.id}")

    couponInfo = Coupon.new
    couponInfo.user_id = "#{params[:user_id]}"
    couponInfo.coupon_code = "#{params[:coupon_code]}"
    couponInfo.redeem_by_date = "#{params[:redeem_by_date]}"
    couponInfo.duration = "#{params[:duration]}"
    couponInfo.name = "#{params[:name]}"
    couponInfo.coupon_type = "single_code"
    couponInfo.discount_type = "#{params[:discount_type]}"
    couponInfo.discount_percent = "#{params[:percentage]}"
    couponInfo.discount_in_cents = dcent
    couponInfo.duration = "#{params[:duration]}"
    couponInfo.temporal_amount = "#{params[:temporal_amount]}"
    couponInfo.max_redemptions = params[:max_redemptions]
    couponInfo.applies_to_all_plans = true
    couponInfo.redemption_resource = "account"
    couponInfo.created_date = Time.now.strftime("%d %h, %Y")
    couponInfo.save

    redirect_to controller: 'coupons'
  end

  def paging

    ################## Delete Coupons #######################
    if defined? params[:delete]
      ids=params[:moredata].split(",")
      ids.each do |number|
        cInfo = Coupon.find_by_id("#{number}")
        # abort("#{cInfo.inspect}")
        Coupon.delete_all(:id => number)
        coupon = Recurly::Coupon.find("#{cInfo.coupon_code}")
        coupon.destroy
      end 
    end
    ################## Delete Coupons #######################

    @total = Coupon.count
    @coupons = Coupon.paginate(:order => :id.desc, :per_page => 10, :page => params[:page], :total_entries => @total)
    unless params[:records].blank?
      @partition = @total/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total
        @partitions = @partition + 1
      end
      unless params[:records].blank?
        @records = params[:records]
      else
        @records = 10
      end
      @page = params[:page]
    else
      @partition = @total/10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end
    render partial: 'all_coupons'
  end
  
  def check
    @exist = Coupon.find_by_coupon_code("#{params[:coupon_code]}")
     if @exist.blank?
      render plain: 'true'
    else
      render plain: 'false'
    end
  end
end
