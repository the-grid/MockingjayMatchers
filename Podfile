# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

def testing_pods
  pod 'Quick'
  pod 'Nimble'
end

def default_pods
  pod 'Mockingjay',   :git => 'https://github.com/kylef/Mockingjay.git',        :branch => 'master'
  pod 'URITemplate',  :git => 'https://github.com/kylef/URITemplate.swift.git', :branch => 'master'
end

target 'MockingjayMatchers-iOS' do
  use_frameworks!

  default_pods

  target 'MockingjayMatchersTests-iOS' do
    inherit! :search_paths
    testing_pods
  end

end

target 'MockingjayMatchers-Mac' do
  use_frameworks!

  default_pods

  target 'MockingjayMatchersTests-Mac' do
    inherit! :search_paths
    testing_pods
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
