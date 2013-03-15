#   Copyright (c) 2010-2012, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class FetchPublicPosts < Base
    @queue = :http_service

    def self.perform(Evergreen_id)
      require Rails.root.join('lib','Evergreen','fetcher','public')

      PublicFetcher.new.fetch!(Evergreen_id)
    end
  end
end
