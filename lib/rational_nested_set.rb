require 'rational_nested_set/rational_nested_set'
require 'active_record'
ActiveRecord::Base.send :extend, CollectiveIdea::Acts::NestedSet

if defined?(ActionView)
  require 'rational_nested_set/helper'
  ActionView::Base.send :include, CollectiveIdea::Acts::NestedSet::Helper
end
