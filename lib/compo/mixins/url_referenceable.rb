require 'compo/finders/root'

module Compo
  module Mixins
    # Adds ID-based 'URL's to Compo classes
    #
    # For the purposes of this module, a URL is a string of slash-delimited IDs
    # representing the location of a Composite in the tree structure formed by
    # its ancestors.  Depending on the types of IDs used in the structure, the
    # URLs may not actually be literal Uniform Resource Locators.
    #
    # This module expects its includer to define #parent and #id.  These are
    # defined, for example, by the Compo::ParentTracker mixin.
    module UrlReferenceable
      extend Forwardable

      # Returns the URL of this object
      #
      # The #url of a Composite is defined inductively as '' for composites that
      # have no parent, and the joining of the parent URL and the current ID
      # otherwise.
      #
      # The result of #url can be used to give a URL hierarchy to Composites.
      #
      # @api  public
      # @example  Gets the URL of an object with no parent.
      #   orphan.url
      #   #=> ''
      # @example  Gets the URL of an object with a parent.
      #   leaf.url
      #   #=> 'grandparent_id/parent_id/id'
      #
      # @return [String]  The URL of this object.
      def url
        Compo::Finders::Root.new(self).reverse_each.map do |item|
          item.is_root? ? '' : item.id
        end.join('/')
      end

      # Returns the URL of a child of this object, with the given ID
      #
      # This defaults to joining the ID to this object's URL with a slash.
      #
      # @api  public
      # @example  Gets the URL of the child of an object without a parent.
      #   orphan.child_url(:id)
      #   #=> '/id'
      # @example  Gets the URL of the child of an object with a parent.
      #   leaf.child_url(:id)
      #   #=> 'grandparent_id/parent_id/id'
      #
      # @param child_id [Object]  The ID of the child whose URL is sought.
      #
      # @return [String]  The URL of the child with the given ID.
      def child_url(child_id)
        [url, child_id].join('/')
      end

      # Returns the URL of this object's parent
      #
      # @api  public
      # @example  Gets the parent URL of an object with no parent.
      #   orphan.parent_url
      #   #=> nil
      # @example  Gets the URL of an object with a parent.
      #   leaf.parent_url
      #   #=> 'grandparent_id/parent_id'
      #
      # @return [String]  The URL of this object's parent, or nil if there is no
      #   parent.
      def_delegator :parent, :url, :parent_url
    end
  end
end
