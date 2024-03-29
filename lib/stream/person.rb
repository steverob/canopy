#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Person < Stream::Base

  attr_accessor :person

  def initialize(user, person, opts={})
    self.person = person
    super(user, opts)
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= user.present? ? user.posts_from(@person) : @person.posts.where(:public => true)
  end
end
