#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PeopleHelper
  include ERB::Util

  def search_header
    if search_query.blank?
      content_tag(:h2, t('people.index.no_results'))
    else
      content_tag(:h2, :id => 'search_title') do
        t('people.index.results_for').html_safe + ' ' +
        content_tag(:span, search_query, :class => 'term')
      end
    end
  end

  def search_or_index
    if search_query
      I18n.t 'people.helper.results_for',:params => search_query
    else
      I18n.t "people.helper.people_on_pod_are_aware_of"
    end
  end

  def birthday_format(bday)
    if bday.year == 1000
      I18n.l bday, :format => I18n.t('date.formats.birthday')
    else
      I18n.l bday, :format => I18n.t('date.formats.birthday_with_year')
    end
  end

  def person_link(person, opts={})
    opts[:class] ||= ""
    opts[:class] << " self" if defined?(user_signed_in?) && user_signed_in? && current_user.person == person
    remote_or_hovercard_link = Rails.application.routes.url_helpers.person_path(person).html_safe
    "<a data-hovercard='#{remote_or_hovercard_link}' #{person_href(person)} class='#{opts[:class]}' #{ ("target=" + opts[:target]) if opts[:target]}>#{h(person.name)}</a>".html_safe
  end

  def last_visible_post_for(person, current_user=nil)
    unless Post.visible_from_author(person, current_user).empty?
      link_to(t('people.last_post'), last_post_person_path(person.to_param))
    end
  end

  def person_image_tag(person, size = :thumb_small)
    image_tag(person.profile.image_url(size), :alt => person.name, :class => 'avatar', :title => person.name, 'data-person_id' => person.id)
  end

  def person_image_link(person, opts={})
    return "" if person.nil? || person.profile.nil?
    if opts[:to] == :photos
      link_to person_image_tag(person, opts[:size]), person_photos_path(person)
    else
      "<a #{person_href(person)} class='#{opts[:class]}' #{ ("target=" + opts[:target]) if opts[:target]}>
      #{person_image_tag(person, opts[:size])}
      </a>".html_safe
    end
  end

  def person_href(person, opts={})
    "href=\"#{local_or_remote_person_path(person, opts)}\"".html_safe
  end

  # Rails.application.routes.url_helpers is needed since this is indirectly called from a model
  def local_or_remote_person_path(person, opts={})
    opts.merge!(:protocol => AppConfig.pod_uri.scheme, :host => AppConfig.pod_uri.authority)
    absolute = opts.delete(:absolute)

    if person.local?
      username = person.Evergreen_handle.split('@')[0]
      unless username.include?('.')
        opts.merge!(:username => username)
        if absolute
          return Rails.application.routes.url_helpers.user_profile_url(opts)
        else
          return Rails.application.routes.url_helpers.user_profile_path(opts)
        end
      end
    end

    if absolute
      return Rails.application.routes.url_helpers.person_url(person, opts)
    else
      return Rails.application.routes.url_helpers.person_path(person, opts)
    end
  end
end
