# frozen_string_literal: true

module SolidusReports
  class Configuration < Spree::Preferences::Configuration
    # Solidus 4.0 and later use a different way to define menu items
    if Gem::Version.new(Spree.solidus_version) >= Gem::Version.new("4.2")
      new_item = Spree::BackendConfiguration::MenuItem.new(
        label: "reports",
        icon: "file",
        condition: -> { can?(:admin, :reports) },
        url: :admin_reports_path,
      )
    else
      REPORT_TABS ||= [:reports].freeze

      new_item = Spree::BackendConfiguration::MenuItem.new(
        REPORT_TABS,
        "file",
        condition: -> { can?(:admin, :reports) }
      )
    end

    Spree::Backend::Config.menu_items << new_item
  end
end