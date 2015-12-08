class SavingsController < ApplicationController
  def index
    @members = [
                  { id:"04d0d4b2-ac25-11e1-96a5-9787dec335c2", name:"Group 1", description:"Description of Patent Group 1"},
                  { id:"9d4f6e5c-dd73-11e1-bed3-fbfe082dc‌​761", name:"Group 3", description:"Description of Patent Group 3"},
                  { id:"06d0d4b2-ac25-11e1-96a5-9787dec33‌​5c2", name:"Group 2", description:"Description of Patent Group 2"}
               ]
    if current_user.profile && current_user.bank_account
      if current_user.group
        @members = current_user.group.members.select(:id, :email) if current_user.group
      end
      @joined_groups = current_user.joined_groups
    else
      @error_message = "Please complete the profile"
    end
  end
end
