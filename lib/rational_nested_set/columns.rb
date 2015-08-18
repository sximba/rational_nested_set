# Mixed into both classes and instances to provide easy access to the column names
module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      module Columns
        def numv_column_name
          acts_as_nested_set_options[:numv_column]
        end

        def denv_column_name
          acts_as_nested_set_options[:denv_column]
        end

        def snumv_column_name
          acts_as_nested_set_options[:snumv_column]
        end

        def sdenv_column_name
          acts_as_nested_set_options[:sdenv_column]
        end

        def depth_column_name
          acts_as_nested_set_options[:depth_column]
        end

        def total_order_column_name
          acts_as_nested_set_options[:total_order_column]
        end

        def sibling_order_column_name
          acts_as_nested_set_options[:sibling_order_column]
        end

        def is_leaf_column_name
          acts_as_nested_set_options[:is_leaf_column]
        end

        def parent_column_name
          acts_as_nested_set_options[:parent_column]
        end

        def primary_column_name
          acts_as_nested_set_options[:primary_column]
        end

        def order_column
          acts_as_nested_set_options[:order_column] || total_order_column_name
        end

        def scope_column_names
          Array(acts_as_nested_set_options[:scope])
        end

        def quoted_numv_column_name
          ActiveRecord::Base.connection.quote_column_name(numv_column_name)
        end

        def quoted_denv_column_name
          ActiveRecord::Base.connection.quote_column_name(denv_column_name)
        end

        def quoted_snumv_column_name
          ActiveRecord::Base.connection.quote_column_name(snumv_column_name)
        end

        def quoted_sdenv_column_name
          ActiveRecord::Base.connection.quote_column_name(sdenv_column_name)
        end

        def quoted_depth_column_name
          ActiveRecord::Base.connection.quote_column_name(depth_column_name)
        end

        def quoted_primary_column_name
          ActiveRecord::Base.connection.quote_column_name(primary_column_name)
        end

        def quoted_parent_column_name
          ActiveRecord::Base.connection.quote_column_name(parent_column_name)
        end

        def quoted_total_order_column_name
          ActiveRecord::Base.connection.quote_column_name(total_order_column_name)
        end

        def quoted_sibling_order_column_name
          ActiveRecord::Base.connection.quote_column_name(sibling_order_column_name)
        end

        def quoted_is_leaf_column_name
          ActiveRecord::Base.connection.quote_column_name(is_leaf_column_name)
        end

        def quoted_scope_column_names
          scope_column_names.collect {|column_name| connection.quote_column_name(column_name) }
        end

        def quoted_order_column_name
          ActiveRecord::Base.connection.quote_column_name(order_column)
        end

        def quoted_primary_key_column_full_name
          "#{quoted_table_name}.#{quoted_primary_column_name}"
        end

        def quoted_order_column_full_name
          "#{quoted_table_name}.#{quoted_order_column_name}"
        end

        def quoted_numv_column_full_name
          "#{quoted_table_name}.#{quoted_numv_column_name}"
        end

        def quoted_denv_column_full_name
          "#{quoted_table_name}.#{quoted_denv_column_name}"
        end

        def quoted_snumv_column_full_name
          "#{quoted_table_name}.#{quoted_snumv_column_name}"
        end

        def quoted_sdenv_column_full_name
          "#{quoted_table_name}.#{quoted_sdenv_column_name}"
        end

        def quoated_depth_column_full_name
          "#{quoted_table_name}.#{quoted_depth_column_name}"
        end

        def quoted_parent_column_full_name
          "#{quoted_table_name}.#{quoted_parent_column_name}"
        end

        def quoted_total_order_column_full_name
          "#{quoted_table_name}.#{quoted_total_order_column_name}"
        end

        def quoted_sibling_order_column_full_name
          "#{quoted_table_name}.#{quoted_sibling_order_column_name}"
        end

        def quoted_is_leaf_column_full_name
          "#{quoted_table_name}.#{quoted_is_leaf_column_name}"
        end
      end
    end
  end
end
