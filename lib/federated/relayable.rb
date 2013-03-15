module Federated
  class Relayable < ActiveRecord::Base
    self.abstract_class = true

    #crazy ordering issues - DEATH TO ROXML
    include Evergreen::Federated::Base
    include Evergreen::Guid

    #seriously, don't try to move this shit around until you have killed ROXML
    xml_attr :target_type
    include Evergreen::Relayable

    xml_attr :Evergreen_handle

    belongs_to :target, :polymorphic => true
    belongs_to :author, :class_name => 'Person'
    #end crazy ordering issues

    validates_uniqueness_of :target_id, :scope => [:target_type, :author_id]
    validates :parent, :presence => true #should be in relayable (pending on fixing Message)

    def Evergreen_handle
      self.author.Evergreen_handle
    end

    def Evergreen_handle=(nh)
      self.author = Webfinger.new(nh).fetch
    end

    def parent_class
      self.target_type.constantize
    end

    def parent
      self.target
    end

    def parent= parent
      self.target = parent
    end
  end
end