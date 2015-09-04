require 'rational_nested_set/columns'
require 'rational_nested_set/model'

module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:

      # This acts provides Rational Nested Set functionality. Nested Set is a smart way to implement
      # an _ordered_ tree, with the added feature that you can select the children and all of their
      # descendants with a single query. Furthermore, the use of rational numbers to mark tree nodes means
      # that insertion or moving of nodes doesn't require an update of the entire tree.
      #
      # This implementation utilizes rational numbers to mark tree nodes. This improves the efficiency
      # of insertions and moves. For these operations it does not need to update the entire tree-set
      # but only the descendants of the concerned tree node, if any. The drawback is that it is no longer
      # simple to recognize leaf nodes, to test if a node is a leaf a query against the whole tree-set is
      # necessary. This module overcomes this by using an extra column to mark nodes that are leaves, and
      # adds an extra step during insertion and deletion to ensure the nodes are updated accordingly.
      # It is also necessary to add another sorting column as the total order is established from values
      # from 2 columns.
      #
      # Nested sets are appropriate each time you want either an ordered tree (menus,
      # commercial categories) or an efficient way of querying big trees (threaded posts).
      #
      # == API
      #
      # Methods names are aligned with acts_as_tree as much as possible to make replacement from one
      # by another easier.
      #
      #   item.children.create(:name => "child1")
      #

      # Configuration options are:
      #
      # * +:parent_column+ - specifies the column name to use as the inverse of the parent column (default: parent_id)
      # * +:primary_column+ - specifies the column name to use for keeping the position integer (default: id)
      # * +:numv_column+ - column name for numerator data, default "numv"
      # * +:denv_column+ - column name for denominator data, default "denv"
      # * +:snumv_column+ - column name for sibling numerator data, default "snumv"
      # * +:sdenv_column+ - column name for sibling denominator data, default "sdenv"
      # * +:depth_column+ - column name for the depth data, default "depth"
      # * +:total_order_column+ - column name for the ordering data (numv/denv), default "total_order"
      # * +:is_leaf_column+ - column name for leaf indication data, default "is_leaf"
      # * +:scope+ - restricts what is to be considered a list. Given a symbol, it'll attach "_id"
      #   (if it hasn't been already) and use that as the foreign key restriction. You
      #   can also pass an array to scope by multiple attributes.
      #   Example: <tt>acts_as_nested_set :scope => [:notable_id, :notable_type]</tt>
      # * +:dependent+ - behavior for cascading destroy. If set to :destroy, all the
      #   child objects are destroyed alongside this object by calling their destroy
      #   method. If set to :delete_all (default), all the child objects are deleted
      #   without calling their destroy method.
      # * +:counter_cache+ adds a counter cache for the number of children.
      #   defaults to false.
      #   Example: <tt>acts_as_nested_set :counter_cache => :children_count</tt>
      # * +:order_column+ on which column to do sorting, by default it is the total_order_column_name
      #   Example: <tt>acts_as_nested_set :order_column => :position</tt>
      #
      # See CollectiveIdea::Acts::NestedSet::Model::ClassMethods for a list of class methods and
      # CollectiveIdea::Acts::NestedSet::Model for a list of instance methods added
      # to acts_as_nested_set models
      def acts_as_nested_set(options = {})
        acts_as_nested_set_parse_options! options

        include Model
        include Columns
        extend Columns

        acts_as_nested_set_relate_parent!
        acts_as_nested_set_relate_children!

        attr_accessor :skip_before_destroy

        acts_as_nested_set_prevent_assignment_to_reserved_columns!
        acts_as_nested_set_define_callbacks!
      end

      private
      def acts_as_nested_set_define_callbacks!
        # on creation, set automatically numv, denv, snumv and sdenv to the end of the tree
        before_create  :set_default_numv_and_denv
        before_save    :store_new_parent
        after_save     :move_to_new_parent, :set_depth!
        before_destroy :destroy_descendants

        define_model_callbacks :move
      end

      def acts_as_nested_set_relate_children!
        has_many_children_options = {
          :class_name => self.base_class.to_s,
          :foreign_key => parent_column_name,
          :primary_key => primary_column_name,
          :inverse_of => (:parent unless acts_as_nested_set_options[:polymorphic]),
        }

        # Add callbacks, if they were supplied.. otherwise, we don't want them.
        [:before_add, :after_add, :before_remove, :after_remove].each do |ar_callback|
          has_many_children_options.update(
            ar_callback => acts_as_nested_set_options[ar_callback]
          ) if acts_as_nested_set_options[ar_callback]
        end

        has_many :children, -> { order(quoted_order_column_name) },
                 has_many_children_options
      end

      def acts_as_nested_set_relate_parent!
        belongs_to :parent, :class_name => self.base_class.to_s,
                            :foreign_key => parent_column_name,
                            :primary_key => primary_column_name,
                            :counter_cache => acts_as_nested_set_options[:counter_cache],
                            :inverse_of => (:children unless acts_as_nested_set_options[:polymorphic]),
                            :polymorphic => acts_as_nested_set_options[:polymorphic],
                            :touch => acts_as_nested_set_options[:touch]
      end

      def acts_as_nested_set_default_options
        {
          :parent_column => 'parent_id',
          :primary_column => 'id',
          :numv_column => 'numv',
          :denv_column => 'denv',
          :snumv_column => 'snumv',
          :sdenv_column => 'sdenv',
          :depth_column => 'depth',
          :total_order_column => 'total_order',
          :is_leaf_column => 'is_leaf',
          :dependent => :delete_all, # or :destroy
          :polymorphic => false,
          :counter_cache => false,
          :touch => false
        }.freeze
      end

      def acts_as_nested_set_parse_options!(options)
        options = acts_as_nested_set_default_options.merge(options)

        if options[:scope].is_a?(Symbol) && options[:scope].to_s !~ /_id$/
          options[:scope] = "#{options[:scope]}_id".intern
        end

        class_attribute :acts_as_nested_set_options
        self.acts_as_nested_set_options = options
      end

      def acts_as_nested_set_prevent_assignment_to_reserved_columns!
        # no assignment to structure fields
        [numv_column_name, denv_column_name, snumv_column_name, sdenv_column_name, depth_column_name, total_order_column_name, is_leaf_column_name].each do |column|
          module_eval <<-"end_eval", __FILE__, __LINE__
            def #{column}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{column}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
          end_eval
        end
      end
    end
  end
end
