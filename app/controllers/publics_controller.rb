#   Copyright (c) 2010-2011, Evergreen Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join('lib', 'stream', 'public')
class PublicsController < ApplicationController
  require Rails.root.join('lib', 'Evergreen', 'parser')
  require Rails.root.join('lib', 'postzord', 'receiver', 'public')
  require Rails.root.join('lib', 'postzord', 'receiver', 'private')
  include Evergreen::Parser

  skip_before_filter :set_header_data
  skip_before_filter :set_grammatical_gender
  before_filter :check_for_xml, :only => [:receive, :receive_public]
  before_filter :authenticate_user!, :only => [:index]

  respond_to :html
  respond_to :xml, :only => :post

  caches_page :host_meta, :if => Proc.new{ Rails.env == 'production'}

  layout false

  def hcard
    @person = Person.find_by_guid_and_closed_account(params[:guid], false)

    if @person.present? && @person.local?
      render 'publics/hcard'
    else
      render :nothing => true, :status => 404
    end
  end

  def host_meta
    render 'host_meta', :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.local_by_account_identifier(params[:q]) if params[:q]

    if @person.nil? || @person.closed_account?
      render :nothing => true, :status => 404
      return
    end

    FEDERATION_LOGGER.info("webfinger profile request for :#{@person.id}")
    render 'webfinger', :content_type => 'application/xrd+xml'
  end

  def hub
    render :text => params['hub.challenge'], :status => 202, :layout => false
  end

  def receive_public
    FEDERATION_LOGGER.info("recieved a public message")
    Resque.enqueue(Jobs::ReceiveUnencryptedSalmon, CGI::unescape(params[:xml]))
    render :nothing => true, :status => :ok
  end

  def receive
    person = Person.find_by_guid(params[:guid])

    if person.nil? || person.owner_id.nil?
      Rails.logger.error("Received post for nonexistent person #{params[:guid]}")
      render :nothing => true, :status => 404
      return
    end

    @user = person.owner

    FEDERATION_LOGGER.info("recieved a private message for user:#{@user.id}")
    Resque.enqueue(Jobs::ReceiveEncryptedSalmon, @user.id, CGI::unescape(params[:xml]))

    render :nothing => true, :status => 202
  end

  private

  def check_for_xml
    if params[:xml].nil?
      render :nothing => true, :status => 422
      return
    end
  end
end
