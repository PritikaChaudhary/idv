class UserPolicy < ApplicationPolicy
  def new_user?
    user && user.role?(:Admin)  || false
  end
  
  def edit_user?
    user && user.role?(:Admin) || false
  end

  def update_user?
    user && user.role?(:Admin) || false
  end

  def create_user?
    user && user.role?(:Admin) || false
  end

  def destroy_user?
    user && user.role?(:Admin) || false
  end
  
end

