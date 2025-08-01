# frozen_string_literal: true

module SolidusReports
  class Configuration < Spree::Preferences::Configuration
    REPORT_TABS ||= [:reports].freeze

    new_item = Spree::BackendConfiguration::MenuItem.new(
      label: "Reports",
      icon: "file",
      condition: -> { can?(:admin, :reports) },
    )
    Spree::Backend::Config.menu_items << new_item
  end
end
