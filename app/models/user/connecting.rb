#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module User::Connecting
  # This will create a contact on the side of the sharer and the sharee.
  # @param [Person] person The person to start sharing with.
  # @param [Aspect] aspect The aspect to add them to.
  # @return [Contact] The newly made contact for the passed in person.
  def share_with(person, aspect)
    contact = self.contacts.find_or_initialize_by_person_id(person.id)
    return false unless contact.valid?

    unless contact.receiving?
      contact.dispatch_request
      contact.receiving = true
    end

    contact.aspects << aspect
    contact.save

    if notification = Notification.where(:target_id => person.id).first
      notification.update_attributes(:unread=>false)
    end

    register_share_visibilities(contact)
    contact
  end

  # This puts the last 100 public posts by the passed in contact into the user's stream.
  # @param [Contact] contact
  # @return [void]
  def register_share_visibilities(contact)
    #should have select here, but proven hard to test
    posts = Post.where(:author_id => contact.person_id, :public => true).limit(100)
    p = posts.map do |post|
      ShareVisibility.new(:contact_id => contact.id, :shareable_id => post.id, :shareable_type => 'Post')
    end
    ShareVisibility.import(p) unless posts.empty?
    nil
  end

  def remove_contact(contact, opts={:force => false})
    posts = contact.posts.all

    if !contact.mutual? || opts[:force]
      contact.destroy
    else
      contact.update_attributes(:receiving => false)
    end
  end

  def disconnect(bad_contact, opts={})
    person = bad_contact.person
    Rails.logger.info("event=disconnect user=#{Evergreen_handle} target=#{person.Evergreen_handle}")
    retraction = Retraction.for(self)
    retraction.subscribers = [person]#HAX
    Postzord::Dispatcher.build(self, retraction).post

    AspectMembership.where(:contact_id => bad_contact.id).delete_all
    remove_contact(bad_contact, opts)
  end

  def disconnected_by(person)
    Rails.logger.info("event=disconnected_by user=#{Evergreen_handle} target=#{person.Evergreen_handle}")
    if contact = self.contact_for(person)
      remove_contact(contact)
    end
  end
end
