require 'rational_nested_set/model/prunable'
require 'rational_nested_set/model/movable'
require 'rational_nested_set/model/transactable'
require 'rational_nested_set/model/relatable'
require 'rational_nested_set/model/rebuildable'
require 'rational_nested_set/model/validatable'
require 'rational_nested_set/iterator'

module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      module Model
        extend ActiveSupport::Concern

        included do
          delegate :quoted_table_name, :arel_table, :to => self
          extend Validatable
          extend Rebuildable
          include Movable
          include Prunable
          include Relatable
          include Transactable
        end

        module ClassMethods
          def associate_parents(objects)
            return objects unless objects.all? {|o| o.respond_to?(:association)}

            id_indexed = objects.index_by(&primary_column_name.to_sym)
            objects.each do |object|
              association = object.association(:parent)
              parent = id_indexed[object.parent_id]

              if !association.loaded? && parent
                association.target = parent
                add_to_inverse_association(association, parent)
              end
            end
          end

          def add_to_inverse_association(association, record)
            inverse_reflection = association.send(:inverse_reflection_for, record)
            inverse = record.association(inverse_reflection.name)
            inverse.target << association.owner
            inverse.loaded!
          end

          def children_of(parent_id)
            where arel_table[parent_column_name].eq(parent_id)
          end

          # Iterates over tree elements and determines the current level in the tree.
          # Only accepts default ordering, ordering by an other column than lft
          # does not work. This method is much more efficient than calling level
          # because it doesn't require any additional database queries.
          #
          # Example:
          #    Category.each_with_level(Category.root.self_and_descendants) do |o, level|
          #
          def each_with_level(objects, &block)
            Iterator.new(objects).each_with_level(&block)
          end

          def leaves
            nested_set_scope.where(arel_table[is_leaf_column_name].eq(true))
          end

          def left_of(node)
            where(arel_table[numv_column_name]/arel_table[denv_column_name]).
            lt(node)
          end

          def right_of(node)
            where(arel_table[numv_column_name]/arel_table[denv_column_name]).
            gt(node)
          end

          def nested_set_scope(options = {})
            options = {:order => quoted_order_column_full_name}.merge(options)

            where(options[:conditions]).order(options.delete(:order))
          end

          def primary_key_scope(id)
            where arel_table[primary_column_name].eq(id)
          end

          def root
            roots.first
          end

          def roots
            where arel_table[denv_column_name].eq(1)
          end
        end # end class methods

        # Any instance method that returns a collection makes use of Rails 2.1's named_scope (which is bundled for Rails 2.0), so it can be treated as a finder.
        #
        #   category.self_and_descendants.count
        #   category.ancestors.find(:all, :conditions => "name like '%foo%'")
        # Value of the parent column
        def parent_id(target = self)
          target[parent_column_name]
        end

        def primary_id(target = self)
          target[primary_column_name]
        end

        # Value of the numv column
        def numv(target = self)
          target[numv_column_name]
        end

        # Value of the denv column
        def denv(target = self)
          target[denv_column_name]
        end

        # Value of the snumv column
        def snumv(target = self)
          target[snumv_column_name]
        end

        # Value of the sdenv column
        def sdenv(target = self)
          target[sdenv_column_name]
        end

        # returns the total_order column
        def total_order(target = self)
          target[total_order_column_name]
        end

        # Returns true if this is a root node.
        def root?
          denv == 1
        end

        # Returns true is this is a child node
        def child?
          !root?
        end

        # Returns true if this is the end of a branch.
        def leaf?
          persisted? && is_leaf
        end

        # All nested set queries should use this nested_set_scope, which
        # performs finds on the base ActiveRecord class, using the :scope
        # declared in the acts_as_nested_set declaration.
        def nested_set_scope(options = {})
          if (scopes = Array(acts_as_nested_set_options[:scope])).any?
            options[:conditions] = scopes.inject({}) do |conditions,attr|
              conditions.merge attr => self[attr]
            end
          end

          self.class.base_class.unscoped.nested_set_scope options
        end

        # Separate an other `nested_set_scope` for unscoped model
        # because normal query still need activerecord `default_scope`
        # Only activerecord callbacks need unscoped model to handle the nested set records
        # And class level `nested_set_scope` seems just for query `root` `child` .. etc
        # I think we don't have to provide unscoped `nested_set_scope` in class level.
        def nested_set_scope_without_default_scope(*args)
          self.class.unscoped do
            nested_set_scope(*args)
          end
        end

        def to_text
          self_and_descendants.map do |node|
            "#{'*'*(node.level+1)} #{node.primary_id} #{node.to_s} (#{node.parent_id}, #{node.numv}, #{node.denv})"
          end.join("\n")
        end

        protected

        def without_self(scope)
          return scope if new_record?
          scope.where(["#{self.class.quoted_table_name}.#{self.class.quoted_primary_column_name} != ?", self.primary_id])
        end

        def store_new_parent
          @move_to_new_parent_id = send("#{parent_column_name}_changed?") ? parent_id : false
          true # force callback to return true
        end

        def has_depth_column?
          nested_set_scope.column_names.map(&:to_s).include?(depth_column_name.to_s)
        end

        def evaluate_num_den(list)
          def add_and_reciprocate(num, den, arg)
            num = num + (arg * den)
            [den, num]
          end
          num = 1
          den = 1
          list.reverse.each_with_index do |arg, index|
            arg = Integer(arg)
            if index == 0
              num = 1
              den = arg
              unless index == list.length - 1
                values = add_and_reciprocate(num, den, 1)
                num = values[0]
                den = values[1]
              end
              next
            end
            values = add_and_reciprocate(num, den, arg)
            values = add_and_reciprocate(values[0], values[1], 1) unless index == list.length - 1
            num = values[0]
            den = values[1]
          end
          tmp = num
          num = den
          den = tmp
          [num, den]
        end

        def right_most_node
          @right_most_node ||= nested_set_scope(:order => "#{quoted_total_order_column_full_name} desc").
          where("#{quoted_denv_column_full_name} = ?", 1.0).
          limit(1).
          first
        end

        def set_depth!
          return unless has_depth_column?

          in_tenacious_transaction do
            reload
            update_depth(level)
          end
        end

        def set_depth_for_self_and_descendants!
          return unless has_depth_column?

          in_tenacious_transaction do
            reload
            self_and_descendants.select(primary_column_name).lock(true)
            old_depth = self[depth_column_name] || 0
            new_depth = level
            update_depth(new_depth)
            change_descendants_depth!(new_depth - old_depth)
            new_depth
          end
        end

        def update_depth(depth)
          nested_set_scope.primary_key_scope(primary_id).
          update_all(["#{quoted_depth_column_name} = ?", depth])
          self[depth_column_name] = depth
        end

        def change_descendants_depth!(diff)
          if !leaf? && diff != 0
            sign = "++-"[diff <=> 0]
            descendants.update_all("#{quoted_depth_column_name} = #{quoted_depth_column_name} #{sign} #{diff.abs}")
          end
        end

        def num_and_den_of_nth_child(node, n)
          [
            node[num_column_name] + (n * node[snum_column_name]),
            node[den_column_name] + (n * node[sden_column_name])
          ]
        end

        def snum_and_sden_of_nth_child(node, n)
          [
            node[num_column_name] + ((n + 1) * node[num_column_name]),
            node[sden_column_name] + ((n + 1) * node[sden_column_name]),
          ]
        end

        def set_default_numv_and_denv
          rmn = right_most_node
          if (rmn.nil?)
            self[numv_column_name] = 1 if self[numv_column_name].nil?
            self[denv_column_name] = 1 if self[denv_column_name].nil?
            self[snumv_column_name] = 2 if self[snumv_column_name].nil?
            self[sdenv_column_name] = 1
            self[depth_column_name] = 0 unless depth_column_name.nil?
            self[total_order_column_name] = 1
          else
            self[numv_column_name] = rmn.snumv
            self[denv_column_name] = 1
            self[snumv_column_name] = rmn.snumv + 1
            self[sdenv_column_name] = 1
            self[depth_column_name] = 0 unless depth_column_name.nil?
            self[total_order_column_name] = rmn.snumv
          end
        end

        # reload left, right, and parent
        def reload_nested_set
          reload(
          :select => "#{quoted_numv_column_full_name}, #{quoted_denv_column_full_name}, #{quoted_snumv_column_full_name}, #{quoted_sdenv_column_full_name}, #{quoted_parent_column_full_name}",
          :lock => true
          )
        end

        def reload_target(target, position)
          if target.is_a? self.class.base_class
            target.reload
          elsif position != :root
            nested_set_scope.where(primary_column_name => target).first!
          end
        end
      end
    end
  end
end
