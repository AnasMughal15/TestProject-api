
# module ControllerMacros
#   def login_admin
#     before(each) do
#       @request.env ["devise.mapping"] = Devise.mappings[:admin]
#       sign in FactoryBot.create(:admin) # Using factory bot as an example
#     end
#   end
#   def login_user
#     before(:each) do
#       @request.env ["devise.mapping"] = Devise.mappings[:user]
#       user = FactoryBot.create(:user)
#       sign_in user
#     end
#   end
# end
