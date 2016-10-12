Pod::Spec.new do |s|
  s.name         = "MockingjayMatchers"
  s.version      = "0.0.1"
  s.summary      = "Mockingjay matchers for APIs at The Grid."
  s.homepage     = "https://github.com/the-grid/MockingjayMatchers"
  s.license     = { :type => "MIT" }
  s.author             = { "Nick Velloff" => "nick.velloff@gmail.com" }
  s.social_media_url   = "https://twitter.com/nickvelloff"
  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/the-grid/MockingjayMatchers.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "MockingjayMatchers/**/*.{h,m,Swift}"
  s.requires_arc = true
  s.dependency "Nimble", "~> 5.0.0"
  s.dependency "Quick", "~> 0.10.0"
  s.dependency "Mockingjay", "~> 1.3.0"
end
