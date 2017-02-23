class CustomController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'

  def index
  end
  
  def form

    if current_user.blank?
      # abort("fsfs")
      redirect_to "/"
    else
      @brwrId = Array.new
      @brwrId << "loan_highlight"
      
      @borrowers = Array.new
      @collaterals = Array.new
      @images = Array.new

      @contact_tab = Custom.find_by_form_and_user_id("Contact Information", "#{current_user.id}")
       if @contact_tab.blank?
        @contact_tab = Custom.new
        @contact_tab.form = "Contact Information"
        @contact_tab.user_id = "#{current_user.id}"
        @contact_tab.hide = 0
        @contact_tab.save
      end
      # abort(@contact_tab.custom_fields.inspect)
      @highlight_tab = Custom.find_by_form_and_user_id("Highlights", "#{current_user.id}") 
       if @highlight_tab.blank?
        @highlight_tab = Custom.new
        @highlight_tab.form = "Highlights"
        @highlight_tab.user_id = "#{current_user.id}"
        @highlight_tab.hide = 0
        @highlight_tab.save
      end
      # abort(@highlight_tab.custom_fields.inspect)
      @summary_tab = Custom.find_by_form_and_user_id("Summary", "#{current_user.id}")
      if @summary_tab.blank?
        @summary_tab = Custom.new
        @summary_tab.form = "Summary"
        @summary_tab.user_id = "#{current_user.id}"
        @summary_tab.hide = 0
        @summary_tab.save
      end
      @transaction_information_tab = Custom.find_by_form_and_user_id("Transaction Information", "#{current_user.id}")
      if @transaction_information_tab.blank?
        @transaction_information_tab = Custom.new
        @transaction_information_tab.form = "Transaction Information"
        @transaction_information_tab.user_id = "#{current_user.id}"
        @transaction_information_tab.hide = 0
        @transaction_information_tab.save
      end
      @use_of_funds_tab = Custom.find_by_form_and_user_id("Use Of Funds", "#{current_user.id}")
      if @use_of_funds_tab.blank?
        @use_of_funds_tab = Custom.new
        @use_of_funds_tab.form = "Use Of Funds"
        @use_of_funds_tab.user_id = "#{current_user.id}"
        @use_of_funds_tab.hide = 0
        @use_of_funds_tab.save
      end
      @exit_strategy_tab = Custom.find_by_form_and_user_id("Exit Strategy", "#{current_user.id}")
      if @exit_strategy_tab.blank?
        @exit_strategy_tab = Custom.new
        @exit_strategy_tab.form = "Exit Strategy"
        @exit_strategy_tab.user_id = "#{current_user.id}"
        @exit_strategy_tab.hide = 0
        @exit_strategy_tab.save
      end

      @borrowers_tab = Custom.find_by_form_and_user_id("Borrower", "#{current_user.id}")
      if @borrowers_tab.blank?
        @borrowers_tab = Custom.new
        @borrowers_tab.form = "Borrower"
        @borrowers_tab.user_id = "#{current_user.id}"
        @borrowers_tab.hide = 0
        @borrowers_tab.save
      end

      @collateral_tab = Custom.find_by_form_and_user_id("Collateral", "#{current_user.id}")
      if @collateral_tab.blank?
        @collateral_tab = Custom.new
        @collateral_tab.form = "Collateral"
        @collateral_tab.user_id = "#{current_user.id}"
        @collateral_tab.hide = 0
        @collateral_tab.save
      end

      @picture_tab = Custom.find_by_form_and_user_id("Picture", "#{current_user.id}")
      if @picture_tab.blank?
        @picture_tab = Custom.new
        @picture_tab.form = "Picture"
        @picture_tab.user_id = "#{current_user.id}"
        @picture_tab.hide = 0
        @picture_tab.save
      end

       @document_tab = Custom.find_by_form_and_user_id("Document", "#{current_user.id}")
      if @document_tab.blank?
        @document_tab = Custom.new
        @document_tab.form = "Document"
        @document_tab.user_id = "#{current_user.id}"
        @document_tab.hide = 0
        @document_tab.save
      end

      @new_custom_tab = Custom.find_by_form_and_user_id("Custom Fields", "#{current_user.id}")
      if @new_custom_tab.blank?
        @new_custom_tab = Custom.new
        @new_custom_tab.form = "Custom Fields"
        @new_custom_tab.user_id = "#{current_user.id}"
        @new_custom_tab.hide = 0
        @new_custom_tab.save
      end

      @all_new_fields = NewCustomField.all(:user_id => "#{current_user.id}")
    end
  end

  def edit_custom_tab
    @custom_tab = Custom.find_by_form_and_user_id("Custom Fields", "#{current_user.id}")
    @custom_tab.display_name = "#{params[:tab_name]}"
    @custom_tab.save

    render text: "done"
  end

  def remove_tab
    @custom = Custom.find_by_form_and_user_id("#{params[:tab]}", "#{current_user.id}")
    if @custom.blank?
      @custom = Custom.new
      @custom.form = "#{params[:tab]}"
      @custom.user_id = "#{current_user.id}"
      @custom.hide = 1
    else
      @custom.hide = 1
    end
    @custom.save

    render text: "done"
  end

  def add_tab
    @custom = Custom.find_by_form_and_user_id("#{params[:tab]}", "#{current_user.id}")
    # abort("#{@custom.inspect}")
    unless @custom.blank?
      @custom.hide = 0
      @custom.save
    end

    render text:"done"
  end 

  def remove_field
    if params[:tab] == "contact"
      @form = "Contact Information"
    elsif params[:tab] == "highlights"
      @form = "Highlights"
    elsif params[:tab] == "summary"
      @form = "Summary"
    elsif params[:tab] == "transaction_information"
      @form = "Transaction Information"
    elsif params[:tab] == "use_of_funds"
      @form = "Use Of Funds"
    elsif params[:tab] == "exit_strategy"
      @form = "Exit Strategy"
    elsif params[:tab] == "borrower"
      @form = "Borrower"
    elsif params[:tab] == "collateral"
      @form = "Collateral"
    elsif params[:tab] == "picture"
      @form = "Picture"
    elsif params[:tab] == "document"
      @form = "Document"
    end

    @custom = Custom.find_by_form_and_user_id("#{@form}", "#{current_user.id}")

    if @custom.blank?
      @custom = Custom.new
      @custom.form = "#{@form}"
      @custom.user_id = "#{current_user.id}"
      @custom.hide = 0
      @custom.save

      @custom_field = CustomField.new
      @custom_field.custom_id = @custom.id
      @custom_field.field_name = "#{params[:field]}"
      @custom_field.hide = 1
      @custom_field.save
    else

      @custom_field = CustomField.find_by_custom_id_and_field_name("#{@custom.id}", "#{params[:field]}")
      
      if @custom_field.blank?
        @custom_field = CustomField.new
        @custom_field.custom_id = @custom.id
        @custom_field.field_name = "#{params[:field]}"
      end
      @custom_field.hide = 1
      @custom_field.save
    end

    render text:"done"
        
  end

  def add_field
    if params[:tab] == "contact"
      @form = "Contact Information"
    elsif params[:tab] == "highlights"
      @form = "Highlights"
    elsif params[:tab] == "summary"
      @form = "Summary"
    elsif params[:tab] == "transaction_information"
      @form = "Transaction Information"
    elsif params[:tab] == "use_of_funds"
      @form = "Use Of Funds"
    elsif params[:tab] == "exit_strategy"
      @form = "Exit Strategy"
    elsif params[:tab] == "borrower"
      @form = "Borrower"
    elsif params[:tab] == "collateral"
      @form = "Collateral"
    elsif params[:tab] == "picture"
      @form = "Picture"
    elsif params[:tab] == "document"
      @form = "Document"
    end

    @custom = Custom.find_by_form_and_user_id("#{@form}", "#{current_user.id}")

    unless @custom.blank?
      @custom_field = CustomField.find_by_custom_id_and_field_name("#{@custom.id}", "#{params[:field]}")
      unless @custom_field.blank?
        @custom_field.hide = 0
        @custom_field.save
      end
    end

    render text:"done"

  end

  def required_field
    @custom = Custom.find_by_form_and_user_id("#{params[:tab]}", "#{current_user.id}")

    unless @custom.blank?
      @field_info = CustomField.find_by_custom_id_and_field_name("#{@custom.id}", "#{params[:field]}")
      
      if @field_info.blank?
        @field_info = CustomField.new
        @field_info.custom_id = "#{@custom.id}"
        @field_info.field_name = "#{params[:field]}"
      end
      
      @field_info.required = params[:required].to_i
      @field_info.save
    
    end

    render  text:"done"
  end
  
  def required_tab
    @custom = Custom.find_by_form_and_user_id("#{params[:tab]}", "#{current_user.id}")
    unless @custom.blank?
      @custom.required = "#{params[:required]}"
      @custom.save
    end

    render  text:"done"
  end

  def check_if_exist
    field_name = params[:field_name].gsub(/[^0-9A-Za-z]/, '')
    @if_exist = NewCustomField.find_by_field_name_and_user_id("#{field_name}", "#{current_user.id}")
    if @if_exist.blank?
      rsp="yes"
    else
      rsp="no"
    end

    render text:rsp
  end

  def add_new_field
    @new_field = NewCustomField.new
    @new_field.name = params[:field_name]
    @new_field.user_id = "#{current_user.id}" 
    field_name =  params[:field_name].gsub(/[^0-9A-Za-z]/, '')
    @new_field.field_name = field_name
    @new_field.save

    @all_new_fields = NewCustomField.all(:user_id => "#{current_user.id}")

    render partial:"new_custom_field"

  end

  def right_custom_tab
    @all_new_fields = NewCustomField.all(:user_id => "#{current_user.id}")
    @new_custom_tab = Custom.find_by_form_and_user_id("Custom Fields", "#{current_user.id}")
    render partial:"right_custom_tab"
  end

  def show_custom_field
    @field = NewCustomField.find_by_field_name_and_user_id("#{params[:field]}", "#{current_user.id}")
    @field.hide = 0
    @field.save

    render  text:"done"
  end

  def remove_custom_field
    @field = NewCustomField.find_by_field_name_and_user_id("#{params[:field]}", "#{current_user.id}")
    @field.hide = 1
    @field.save

    render  text:"done"
  end

  def required_custom_field
    @field = NewCustomField.find_by_field_name_and_user_id("#{params[:field]}", "#{current_user.id}")
    @field.required = params[:required].to_i
    @field.save

    render  text:"done"
  end
 
 end