module CollectiveIdea
  module Acts
    module NestedSet
      module Model
        module Relatable
          # Returns an collection of all parents
          def ancestors
            without_self self_and_ancestors
          end

          # Returns the collection of all parents and self
          def self_and_ancestors
            nested_set_scope.
            where(
            "(#{self.class.quoted_table_name}.#{self.class.quoted_total_order_column_name} < ?
                and ? < (#{self.class.quoted_table_name}.#{self.class.quoted_snumv_column_name}/#{self.class.quoted_table_name}.#{self.class.quoted_sdenv_column_name})) or
                #{self.class.quoted_table_name}.#{self.class.quoted_primary_column_name} = ?", self.total_order, self.total_order, self.primary_id
            )
          end

          # Returns the collection of all children of the parent, except self
          def siblings
            without_self self_and_siblings
          end

          # Returns the collection of all children of the parent, including self
          def self_and_siblings
            nested_set_scope.children_of parent_id
          end

          # Returns a set of all of its nested children which do not have children
          def leaves
            descendants.where(arel_table[is_leaf_column_name].eq(true))
          end

          # Returns the level of this object in the tree
          # root level is 0
          def level
            parent_id.nil? ? 0 : compute_level
          end

          # Returns a collection including all of its children and nested children
          def descendants
            without_self self_and_descendants
          end

          # Returns a collection including itself and all of its nested children
          def self_and_descendants
            # using _left_ for both sides here lets us benefit from an index on that column if one exists
            nested_set_scope.where(
            arel_table[primary_column_name].eq(self.primary_id).or(arel_table[total_order_column_name].gteq(total_order)).
            and(arel_table[total_order_column_name].lt(snumv/denv)))
          end

          def is_descendant_of?(other)
            (other.total_order < total_order && (other.snumv/Float(other.sdenv)) > total_order) && same_scope?(other)
          end

          def is_or_is_descendant_of?(other)
            (other == self || is_descendant_of?(other))
          end

          def is_ancestor_of?(other)
            (total_order < other.total_order && other.total_order < (snumv / Float(sdenv))) && same_scope?(other)
          end

          def is_or_is_ancestor_of?(other)
            (self == other || is_ancestor_of?(other))
          end

          # Check if other model is in the same scope
          def same_scope?(other)
            Array(acts_as_nested_set_options[:scope]).all? do |attr|
              self.send(attr) == other.send(attr)
            end
          end

          # Find the first sibling to the left
          def left_sibling
            siblings.where(arel_table[snumv_column_name].eq(numv)).
            where(arel_table[sdenv_column_name].eq(denv)).first
          end

          # Find the first sibling to the right
          def right_sibling
            siblings.where(arel_table[numv_column_name].eq(snumv)).
            where(arel_table[denv_column_name].eq(sdenv)).first
          end

          def root
            return self_and_ancestors.children_of(nil).first if persisted?

            if parent_id && current_parent = nested_set_scope.where(primary_column_name => parent_id).first!
              current_parent.root
            else
              self
            end
          end

          protected

          def compute_level
            node, nesting = determine_depth
            node == self ? ancestors.count : node.level + nesting
          end

          def determine_depth(node = self, nesting = 0)
            while (association = node.association(:parent)).loaded? && association.target
              nesting += 1
              node = node.parent
            end if node.respond_to?(:association)

            [node, nesting]
          end

        end
      end
    end
  end
end
