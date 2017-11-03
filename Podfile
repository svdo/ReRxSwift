platform :ios, '9.0'

abstract_target 'ReRx' do
  use_frameworks!

  pod 'ReSwift', '~> 4.0'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'

  target 'ReRxSwift'

  target 'ReRxSwiftTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.1'
    pod 'Nimble', '~> 7.0'
    pod 'RxDataSources', '~> 3.0'
  end

  target 'Example' do
    pod 'RxDataSources', '~> 3.0'

    target 'ExampleTests' do
        pod 'Quick', '~> 1.1'
        pod 'Nimble', '~> 7.0'
    end
  end
end

