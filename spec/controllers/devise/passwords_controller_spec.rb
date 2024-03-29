#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Devise::PasswordsController do
  include Devise::TestHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "#create" do
    context "when there is no such user" do
      it "succeeds" do
        post :create, "user" => {"email" => "foo@example.com"}
        response.should be_success
      end
      it "doesn't send email" do
        Resque.should_not_receive(:enqueue)
        post :create, "user" => {"email" => "foo@example.com"}
      end
    end
    context "when there is a user with that email" do
      it "redirects to the login page" do
        post :create, "user" => {"email" => alice.email}
        response.should redirect_to(new_user_session_path)
      end
      it "sends email (enqueued to Resque)" do
        Resque.should_receive(:enqueue).with(Jobs::ResetPassword, alice.id)
        post :create, "user" => {"email" => alice.email}
      end
    end
  end
end