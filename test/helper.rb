unless defined? Chronic
  $:.unshift File.expand_path('../../lib', __FILE__)
  require 'chronic'
end

require 'active_support/testing/time_helpers'
require 'active_support/values/time_zone'
require 'active_support/core_ext/time'
require 'minitest/autorun'

class TestCase < MiniTest::Test
  include ActiveSupport::Testing::TimeHelpers

  def self.test(name, &block)
    define_method("test_#{name.gsub(/\W/, '_')}", &block) if block
  end
end
