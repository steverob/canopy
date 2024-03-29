#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :except => ['show']

  respond_to :html, :except => [:show]
  respond_to :js, :only => :update

  # this is terrible because we're actually serving up the associated person here;
  # however, this is the effect that we want for now
  def show
    @person = Person.find_by_guid!(params[:id])

    respond_to do |format|
      format.json { render :json => PersonPresenter.new(@person, current_user) }
    end
  end

  def edit
    @person = current_user.person
    @aspect  = :person_edit
    @profile = @person.profile

    @tags = @profile.tags
    @tags_array = []
    @tags.each do |obj| 
      @tags_array << { :name => ("#"+obj.name),
        :value => ("#"+obj.name)}
      end
  end

  def update
    # upload and set new profile photo
    @profile_attrs = params[:profile] || {}
    
    munge_tag_string

    #checkbox tags wtf
    @profile_attrs[:searchable] ||= false
    @profile_attrs[:nsfw] ||= false

    if params[:photo_id]
      @profile_attrs[:photo] = Photo.where(:author_id => current_user.person_id, :id => params[:photo_id]).first
    end

    if current_user.update_profile(@profile_attrs)
      flash[:notice] = I18n.t 'profiles.update.updated'
    else
      flash[:error] = I18n.t 'profiles.update.failed'
    end

    respond_to do |format|
      format.js { render :nothing => true, :status => 200 }
      format.any {
        flash[:notice] = I18n.t 'profiles.update.updated'
        if current_user.getting_started?
          redirect_to getting_started_path
        else
          redirect_to edit_profile_path
        end
      }
    end
  end

  private

  def munge_tag_string
    unless @profile_attrs[:tag_string].nil? || @profile_attrs[:tag_string] == I18n.t('profiles.edit.your_tags_placeholder')
      @profile_attrs[:tag_string].split( " " ).each do |extra_tag|
        extra_tag.strip!
        unless extra_tag == ""
          extra_tag = "##{extra_tag}" unless extra_tag.start_with?( "#" )
          params[:tags] += " #{extra_tag}"
        end
      end
    end
    @profile_attrs[:tag_string] = (params[:tags]) ? params[:tags].gsub(',',' ') : ""
  end
end
