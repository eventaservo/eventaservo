# frozen_string_literal: true

# Counts Bootstrap-specific markup so the migration can ratchet usage down.
module BootstrapUsage
  ROOT = File.expand_path("..", __dir__)
  TARGETS = %w[app/views app/components app/javascript app/helpers].freeze
  PATTERNS = {
    data_attributes: /data-bs-[a-z-]+/,
    component_classes: /\b(?:btn|badge|modal|dropdown|nav-tabs|pagination|alert|card|navbar|collapse|carousel|offcanvas|toast|tooltip|popover|accordion|form-control|form-select|input-group|table|container|row|col-(?:sm|md|lg|xl|xxl)?-?\d+)\b/
  }.freeze

  module_function

  # Counts Bootstrap usage per target directory.
  #
  # @return [Hash{String => Hash{Symbol => Integer}}] counts per directory and pattern
  def counts
    TARGETS.to_h do |dir|
      text = files_in(dir).map { |f| File.read(f) }.join("\n")
      [dir, PATTERNS.transform_values { |pattern| text.scan(pattern).size }]
    end
  end

  # Returns the files under a target directory.
  #
  # @param dir [String] relative directory
  #
  # @return [Array<String>] absolute file paths
  def files_in(dir)
    Dir.glob(File.join(ROOT, dir, "**", "*")).select { |path| File.file?(path) }
  end
end
