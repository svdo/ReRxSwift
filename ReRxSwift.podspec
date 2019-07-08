Pod::Spec.new do |s|
  s.name         = "ReRxSwift"
  s.version      = "2.2.0"
  s.summary      = "RxSwift bindings for ReSwift"
  s.description  = <<-DESC
                   ReRxSwift: RxSwift bindings for ReSwift. Heavily inspired by
                   react-redux, this allows you to 'connect' your controllers and specify
                   props and actions that your controller depends on. The real state
                   and actions are thus decoupled from the controller implementations.
                   DESC

  s.homepage     = "https://github.com/svdo/ReRxSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Stefan van den Oord" => "soord@mac.com" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/svdo/ReRxSwift.git", :tag => "#{s.version}" }
  s.source_files  = "ReRxSwift/*.swift"
  s.requires_arc = true
  s.swift_version = '4.1'

  s.dependency     "ReSwift", "~> 5"
  s.dependency     "RxSwift", "~> 5"
  s.dependency     "RxCocoa", "~> 5"

end
