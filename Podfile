platform :ios, '9.0'

abstract_target 'ReRx' do
  use_frameworks!

  pod 'ReSwift', '~> 6'
  pod 'RxSwift', '~> 6'
  pod 'RxCocoa', '~> 6'

  target 'ReRxSwift'

  target 'ReRxSwiftTests' do
    inherit! :search_paths
    pod 'Quick', '~> 3.0',  :inhibit_warnings => true
    pod 'Nimble', '~> 9.0'
    pod 'RxDataSources', '~> 5.0'
  end

  target 'Example' do
    pod 'RxDataSources', '~> 5.0'

    target 'ExampleTests' do
        pod 'Quick', '~> 3.0', :inhibit_warnings => true
        pod 'Nimble', '~> 9.0'
    end
  end
end

