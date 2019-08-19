Pod::Spec.new do |s|

  s.name         = "ScrollingDateAndTimePicker"
  s.version      = "0.1.0"
  s.summary      = "Infinite scrolling date and time picker for iOS"
  s.homepage     = "https://github.com/dougzilla/ScrollingDateAndTimePicker"
  s.screenshots  = "https://github.com/dougzilla/ScrollingDateAndTimePicker/blob/master/Screenshots/screen.png?raw=true"
  s.license      = "MIT"
  s.author       = { "Doug Stein" => "dougstein@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/dougzilla/ScrollingDateAndTimePicker.git", :tag => "#{s.version}" }
  s.source_files = "Sources"
  s.resource_bundles = { "ScrollingDateAndTimePicker" => ["Sources/*.xib"] }
  s.requires_arc = true

end
