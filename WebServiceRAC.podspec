#
#  Be sure to run `pod spec lint WebServiceRAC.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
Pod::Spec.new do |s|

  s.name         = "WebServiceRAC"
  s.version      = "0.1.0"
  s.summary      = "WebService wrapper with local cache for the Reactive world of Cocoa"
  s.description  = <<-DESC
                   WebService wrapper using JSON format with a Reactive implementation,
                   using a local cache mechanism.
                   Originally intended to be an easy to use solution with a Ruby on Rails back-end.
                   DESC
  s.homepage     = "https://github.com/BPerlakiH/WebServiceRAC"
  s.license = "MIT"
  s.author = "BPH"
  s.platform = :ios, "7.0"
  s.source       = { :git => "https://github.com/BPerlakiH/WebServiceRAC.git", :tag => "0.1.0" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.frameworks = "Foundation"

  s.requires_arc = true
  s.dependency "ReactiveCocoa", "~> 2.3"
end
