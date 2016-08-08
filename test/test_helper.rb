# frozen_string_literal: true

require 'coveralls'

Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'timed'

require 'minitest/autorun'

module TestHelper
  module_function

  def range begin_range, end_range
    begin_at = Random.rand begin_range
    end_at = Random.rand end_range
    begin_at..end_at
  end

  def item begin_range, end_range
    ::Timed::Item.new range(begin_range, end_range)
  end
end
