module Project
  # Here is hash of groups with list of grants in each.
  # Guest group is required and may be empty, all other groups are optional.
  GROUPS = {
      # Add custom groups here. Example:
      # :some_group => [:send_mails, :create_users, :moderate_forum],
      # Note that :some_group=>[:some_grant] and :other_group=>[:some_grant] points to same :some_grant

      # :admin_index - predefined (system required) grant for browse admin app
      :admin => [:admin_index],

      # Public group is associated with all users include non-logged in.
      # This group is empty by default, but you can put some grants in it.
      # For example :public => [:foo] means that all users respond to .grant?(:foo) as true.
      :public => [],
  }
end