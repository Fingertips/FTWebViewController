Pod::Spec.new do |s|
  s.name         = "FTWebViewController"
  s.version      = "0.0.1"
  s.summary      = "A paginated iOS UIWebView controller with simple interactivity support."
  s.homepage     = "https://github.com/Fingertips/FTWebViewController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Eloy Durán" => "eloy.de.enige@gmail.com" }
  s.source       = { :git => "https://github.com/Fingertips/FTWebViewController.git" }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source_files = 'Source/*.{h,m}'
  s.dependency 'StyledPageControl'
end
