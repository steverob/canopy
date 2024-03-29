#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class DeferredDispatch < Base
    @queue = :dispatch

    def self.perform(user_id, object_class_name, object_id, opts)
      user = User.find(user_id)
      object = object_class_name.constantize.find(object_id)
      opts = HashWithIndifferentAccess.new(opts)
      opts[:services] = user.services.where(:type => opts.delete(:service_types)).all

      if opts[:additional_subscribers].present?
        opts[:additional_subscribers] = Person.where(:id => opts[:additional_subscribers])
      end

      Postzord::Dispatcher.build(user, object, opts).post
    end
  end
end
