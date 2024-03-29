#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion < ActiveRecord::Base
  include Evergreen::Federated::Base


  belongs_to :person
  after_create :queue_delete_account

  attr_accessible :person

  xml_name :account_deletion
  xml_attr :Evergreen_handle


  def person=(person)
    self[:Evergreen_handle] = person.Evergreen_handle
    self[:person_id] = person.id
  end

  def Evergreen_handle=(Evergreen_handle)
    self[:Evergreen_handle] = Evergreen_handle
    self[:person_id] ||= Person.find_by_Evergreen_handle(Evergreen_handle).id
  end

  def queue_delete_account
    Resque.enqueue(Jobs::DeleteAccount, self.id)
  end

  def perform!
    self.dispatch if person.local?
    AccountDeleter.new(self.Evergreen_handle).perform!
  end

  def subscribers(user)
    person.owner.contact_people.remote | Person.who_have_reshared_a_users_posts(person.owner).remote
  end

  def dispatch
    Postzord::Dispatcher.build(person.owner, self).post
  end

  def public?
    true
  end
end
