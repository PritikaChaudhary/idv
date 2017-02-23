class LoanPolicy < ApplicationPolicy
  
  def index
    user && user.role?(:Admin) || false
  end
  
  def edit_field?
    user && user.role?(:Admin)  || false
  end
 
 def update?
    user && user.role?(:Admin)  || false
  end

  def show?
     true
  end
  
  def edit_field?
    user && user.role?(:Admin)  || false
  end
  
  def edit_category?
    user && user.role?(:Admin)  || false
  end
  
  def upload_doc?
    user && user.role?(:Admin)  || false
  end

  def upload_main_image?
    user && user.role?(:Admin)  || false
  end

  def upload_image?
    user && user.role?(:Admin)  || false
  end

  def delete_image?
    user && user.role?(:Admin)  || false
  end

  
end

