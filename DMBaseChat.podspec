Pod::Spec.new do |s|

  s.name         = "DMBaseChat"
  s.version      = "0.1.4"
  s.summary      = "Some categories for iOS developers"
  s.homepage     = "https://github.com/DimaAvvakumov/DMBaseChat.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Dmitry Avvakumov" => "avvakumov@it-baker.ru" }
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/DimaAvvakumov/DMBaseChat.git" }
  s.source_files = "DMBaseChat/**/*.{h,m}"
  s.public_header_files = "DMBaseChat/**/*.{h}"
  s.framework    = "UIKit"
  s.requires_arc = true

  s.dependency 'DMCategories'
  s.dependency 'StandardPaths'
  s.dependency 'DMCategories'

end
