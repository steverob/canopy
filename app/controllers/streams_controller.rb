#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join("lib", "stream", "aspect")
require Rails.root.join("lib", "stream", "multi")
require Rails.root.join("lib", "stream", "comments")
require Rails.root.join("lib", "stream", "likes")
require Rails.root.join("lib", "stream", "mention")
require Rails.root.join("lib", "stream", "followed_tag")
require Rails.root.join("lib", "stream", "activity")


class StreamsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_selected_aspects, :only => :aspects
  before_filter :redirect_unless_admin, :only => :public

  respond_to :html,
             :mobile,
             :json

  def aspects
    aspect_ids = (session[:a_ids] || [])
    @stream = Stream::Aspect.new(current_user, aspect_ids,
                                 :max_time => max_time)
    stream_responder
  end

  def public
    stream_responder(Stream::Public)
  end

  def activity
    stream_responder(Stream::Activity)
  end

  def multi
      stream_responder(Stream::Multi)
  end

  def commented
    stream_responder(Stream::Comments)
  end

  def liked
    stream_responder(Stream::Likes)
  end

  def mentioned
    stream_responder(Stream::Mention)
  end

  def followed_tags
    gon.tagFollowings = tags
    stream_responder(Stream::FollowedTag)
  end

  private

  def stream_responder(stream_klass=nil)
    if stream_klass.present?
      @stream ||= stream_klass.new(current_user, :max_time => max_time)
    end

    respond_with do |format|
      format.html { render 'layouts/main_stream' }
      format.mobile { render 'layouts/main_stream' }
      format.json { render :json => @stream.stream_posts.map {|p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user)) }}
    end
  end

  def save_selected_aspects
    if params[:a_ids].present?
      session[:a_ids] = params[:a_ids]
    end
  end
end
