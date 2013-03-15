require 'spec_helper'

describe Pod do
  describe '.find_or_create_by_url' do
    it 'takes a url, and makes one by host' do
      pod = Pod.find_or_create_by_url('https://joinEvergreen.com/maxwell')
      pod.host.should == 'joinEvergreen.com'
    end

    it 'sets ssl boolean(side-effect)' do
      pod = Pod.find_or_create_by_url('https://joinEvergreen.com/maxwell')
      pod.ssl.should be_true
    end
  end
end
