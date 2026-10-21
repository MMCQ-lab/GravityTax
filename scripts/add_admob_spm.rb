# Adds the Google Mobile Ads Swift package to the exported Xcode project.
#
# The AdMob plugin normally does this in its post-export hook, but Godot
# 4.7.2 does not run that hook for "export project only" iOS exports (what CI
# uses), so the package was missing and the build failed. This is the
# plugin's own logic, plus linking the product in the Frameworks phase.
#
# Usage: ruby scripts/add_admob_spm.rb build/ios/JellySwing.xcodeproj
require 'xcodeproj'

project_path = ARGV[0]
url = 'https://github.com/googleads/swift-package-manager-google-mobile-ads.git'
version = '12.14.0'  # keep in sync with SPM_DEPENDENCIES in addons/AdmobPlugin/AdmobPlugin.gd
product_name = 'GoogleMobileAds'

abort "Xcode project not found at #{project_path}" unless File.exist?(project_path)

project = Xcodeproj::Project.open(project_path)
target = project.targets.first
abort 'No targets found in the Xcode project.' if target.nil?

if target.package_product_dependencies.any? { |dep| dep.product_name == product_name }
  puts "#{product_name} already present."
  exit 0
end

pkg = project.root_object.package_references.find { |p| p.repositoryURL == url }
unless pkg
  pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
  pkg.repositoryURL = url
  pkg.requirement = { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => version }
  project.root_object.package_references << pkg
end

ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
ref.product_name = product_name
ref.package = pkg
target.package_product_dependencies << ref

# Link the package product so the AdmobPlugin static library resolves.
build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.product_ref = ref
target.frameworks_build_phase.files << build_file

project.save
puts "Added #{product_name} (#{url} @ #{version}) to #{File.basename(project_path)} target #{target.name}."
