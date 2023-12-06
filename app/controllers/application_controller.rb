class ApplicationController < ActionController::Base
    include UserAuth
    include EarlyAccessCheck
end
