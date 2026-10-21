# Applies manual App Store signing to the game's own app target only.
#
# Passing PROVISIONING_PROFILE_SPECIFIER on the xcodebuild command line makes
# it apply to every target, including the Google Mobile Ads / UMP Swift
# package targets, which reject provisioning profiles and fail the archive.
#
# Usage: ruby scripts/set_ios_signing.rb <xcodeproj> <team id> <profile name> <bundle id>
require 'xcodeproj'

project_path, team_id, profile_name, bundle_id = ARGV
abort 'usage: set_ios_signing.rb <xcodeproj> <team> <profile> <bundle id>' if [project_path, team_id, profile_name, bundle_id].any? { |v| v.nil? || v.empty? }

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.product_type == 'com.apple.product-type.application' } || project.targets.first
abort 'No app target found.' if target.nil?

target.build_configurations.each do |config|
  settings = config.build_settings
  settings['CODE_SIGN_STYLE'] = 'Manual'
  settings['DEVELOPMENT_TEAM'] = team_id
  settings['PROVISIONING_PROFILE_SPECIFIER'] = profile_name
  settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
  settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'Apple Distribution'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
end

project.save
puts "Manual signing applied to target #{target.name} (#{target.build_configurations.map(&:name).join(', ')})."
