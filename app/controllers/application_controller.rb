class ApplicationController < ActionController::Base
    include UserAuth
    include SubscriberStatus
end
