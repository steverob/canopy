#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  describe '#index' do
    before do
      sign_in :user, bob
    end

    it "generates a jasmine fixture with no query", :fixture => true do
      get :index
      save_fixture(html_for("body"), "empty_people_search")
    end

    it "generates a jasmine fixture trying an external search", :fixture => true do
      get :index, :q => "sample@diaspor.us"
      save_fixture(html_for("body"), "pending_external_people_search")
    end
  end
end
