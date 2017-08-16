platform :ios, '9.0'

target 'ReRxSwift' do
  use_frameworks!

  pod 'ReSwift', :git => 'https://github.com/ReSwift/ReSwift', :branch => 'mjarvis/swift-4'
  pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift', :branch => 'swift4.0'
  pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift', :branch => 'swift4.0'

  target 'ReRxSwiftTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.1'
    pod 'Nimble', '~> 7.0'
  end

end
