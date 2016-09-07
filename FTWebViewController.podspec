Pod::Spec.new do |s|
  s.name         = "FTWebViewController"
  s.version      = "0.0.2"
  s.summary      = "A paginated iOS UIWebView controller with simple interactivity support."
  s.homepage     = "https://github.com/Fingertips/FTWebViewController"
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.authors      = [
      { "Eloy Durán" => "eloy.de.enige@gmail.com" },
      { "Thíjs van der Vossen" => "thijs@fngtps.com" },
      { "Manfred Stienstrá" => "manfred@fngtps.com" }
  ]
  s.source       = { git: "https://github.com/Fingertips/FTWebViewController.git" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Source/*.{h,m}'
end
