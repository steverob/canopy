#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Evergreen::Application.configure do
  config.generators do |g|
    g.integration_tool :rspec
    g.test_framework   :rspec
  end
end
