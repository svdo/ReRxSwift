platform :ios, '9.0'

abstract_target 'ReRx' do
  use_frameworks!

  pod 'ReSwift'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'

  target 'ReRxSwift'

  target 'ReRxSwiftTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.1', :inhibit_warnings => true
    pod 'Nimble', '~> 7.0'
    pod 'RxDataSources', '~> 4.0'
  end

  target 'Example' do
    pod 'RxDataSources', '~> 4.0'

    target 'ExampleTests' do
        pod 'Quick', '~> 1.1', :inhibit_warnings => true
        pod 'Nimble', '~> 7.0'
    end
  end
end

