module Compo
  module Mixins
    # Helper mixin for objects that can be moved into other objects
    #
    # This mixin defines a method, #move_to, which handles removing a child
    # from its current parent and adding it to a new one.
    #
    # It expects the current parent to be reachable from #parent.
    module Movable
      # Moves this model object to a new parent with a new ID
      #
      # @api  public
      # @example  Moves the object to a new parent.
      #   movable.move_to(parent, :id)
      # @example  Moves the object out of its parent (deleting it, if there are
      #   no other live references).
      #   movable.move_to(nil, nil)
      #
      # @param new_parent [Object] The new parent for this object (can be nil).
      # @param new_id [Object]  The new ID under which the object will exist in
      #   the parent.
      #
      # @return [self]
      def move_to(new_parent, new_id)
        move_from_old_parent
        move_to_new_parent(new_parent, new_id)
        self
      end

      private

      # Performs the move from an old parent, if necessary
      #
      # @api private
      #
      # @return [void]
      def move_from_old_parent
        parent.remove(self)
      end

      # Performs the move to a new parent, if necessary
      #
      # @api private
      #
      # @param new_parent [Composite]  The target parent of the move.
      # @param new_id [Object]  The intended new ID of this child.
      #
      # @return [void]
      def move_to_new_parent(new_parent, new_id)
        new_parent.add(new_id, self) unless new_parent.nil?
      end
    end
  end
end
