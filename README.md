# ReRxSwift
![Swift Version 4](https://img.shields.io/badge/Swift-v4-yellow.svg)
[![Build Status](https://travis-ci.org/svdo/ReRxSwift.svg?branch=master)](https://travis-ci.org/svdo/ReRxSwift)
[![API Documentation](https://svdo.github.io/ReRxSwift/badge.svg)](https://svdo.github.io/ReRxSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Version Badge](https://img.shields.io/cocoapods/v/ReRxSwift.svg)](https://cocoapods.org/pods/ReRxSwift)
![Supported Platforms Badge](https://img.shields.io/cocoapods/p/ReRxSwift.svg)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/svdo/ReRxSwift/blob/master/LICENSE)

*[RxSwift][1] bindings for [ReSwift][2]*

## Table of Contents

* [Introduction](#introduction)
* [Installation](#installation)
* [Usage](#usage)
* [API](#api)
  - [Connectable](#connectable)
  - [Connection](#connection)
- [Example App](#example-app)
- [FAQ](#faq)


## Introduction

In case you don't know them yet, these are two awesome frameworks:

- [ReSwift][2] is a small framework that implement the
  [unidirectional data flow architecture][3] in Swift. It is inspired
  by the JavaScript implementation of that architecture: [Redux][4].
- [RxSwift][1] is a Swift implementation of [ReactiveX][5]. Amongst
  other things, it allows you to easily bind properties to user interface
  elements.

Using those two frameworks you can make very nice app architectures.
RxSwift allows you to bind application state to your UI, and ReSwift
emits state updates in response to actions. We take it one step further
though.

Similar to [react-redux][6], ReRxSwift allows you to create view
controllers that have `props` and `actions`. View controllers read all
data they need from their `props` (instead of directly from the state),
and they change data by invoking callbacks defined by `actions` (instead
of directly dispatching ReSwift actions). This has some nice advantages:

- Better separation of concerns. It is easier to understand what your
  view controller does and what data it uses. In other words, it
  facilitates local reasoning.
- Unit-testing. Because of the separation of concerns, you can easily
  unit-test your view controllers, all the way up to the Interface
  Builder connections.
- Better reusability. Reusing your view controllers is as simple as
  specifying different mappings from state to `props` and from ReSwift
  actions to `actions`. (See also section 'Open Issues' below.)
- Rapid prototyping. You can easily use dummy `props` and `actions` so
  that you get a working UI layer prototype. Without writing any of your
  application's business logic, you can implement your presentation
  layer in such a way that it is very simple to replace the dummies
  with real state and actions.


## Installation

The easiest way to use this library is through [Cocoapods][15] or [Carthage][16]. For CocoaPods, add this to your `Podfile`:

```ruby
pod 'ReRxSwift', '~> 1.0'
```

For Carthage, add this to your `Cartfile`:

```
github "svdo/ReRxSwift" ~> 1.0
```

## Usage

This section assumes that there is a global variable `store` that contains
your app's store, and that it's type is `Store<AppState>`. You have a view
controller that manages a text field; the text field displays a value from
your state, and on `editingDidEnd` you trigger an action to store the text
field's content back into your state. To use ReRxSwift for your view
controller `MyViewController`, you use the following steps.

1. Create an extension to your view controller to make it `Connectable`,
   defining the `Props` and `Actions` that your view controller needs:

    ```swift
    extension MyViewController: Connectable {
        struct Props {
            let text: String
        }
        struct Actions {
            let updatedText: (String) -> Void
        }
    }
    ```

2. Define how your state is mapped to the above `Props` type:

    ```swift
    private let mapStateToProps = { (appState: AppState) in
        return MyViewController.Props(
            text: appState.content
        )
    }
    ```

3. Define the actions that are dispatched:

    ```swift
    private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
        return MyViewController.Actions(
            updatedText: { newText in dispatch(SetContent(newContent: newText)) }
        )
    }
    ```

4. Define the connection and hook it up:

    ```swift
    class MyViewController: UIViewController {
        @IBOutlet weak var textField: UITextField!

        let connection = Connection(
            store: store,
            mapStateToProps: mapStateToProps,
            mapDispatchToActions: mapDispatchToActions
        )

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            connection.connect()
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            connection.disconnect()
        }
    }
    ```

5. Bind the text field's text, using a Swift 4 key path to refer to the
   `text` property of `Props`:

    ```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        connection.bind(\Props.text, to: textField.rx.text)
    }
    ```

6. Call the action:

    ```swift
    @IBAction func editingChanged(_ sender: UITextField) {
        actions.updatedText(sender.text ?? "")
    }
    ```

This is pretty much the [`SimpleTextFieldViewController`][10] inside the sample
app. That view controller comes with complete unit tests:
[`SimpleTextFieldViewControllerSpec`][11].


## API

Below is a high-level description of the most important components of the API.
There is also [full API documentation of ReRxSwift][14] available.

### Connectable

This is the protocol that your view controller has to conform to. It requires
you to add a `connection` property. It provides the `props` and `actions` that
you can use in your view controller. Normally, you declare the `connection` as
follows:

```swift
class MyViewController: Connectable {
    let connection = Connection(
        store: store,
        mapStateToProps: mapStateToProps,
        mapDispatchToActions: mapDispatchToActions
    )
}
```

Refer to the `Connection` constructor documentation for more information.

#### props
This contains the `Props` object that you create using `mapStateToProps`. In
other words: it contains all data that your view controller uses, automatically
extracted from your application state. When using the `bind` methods in
`Connection`, you probably don't need to use this `props` property directly.

#### actions
This contains the `Actions` object that you create using `mapDispatchToActions`.
In other words: it specifies which ReSwift action has to be dispatched when
calling the callbacks defined by your `actions`.

### Connection
The `Connection` takes care of the mapping from you application state to your
view controller `props`, and of dispatching the mapped action when calling
functions in your view controller `actions`.

#### Constructor(store, mapStateToProps, mapDispatchToActions)
To create your `Connection` instance, you need to construct it with three
parameters:

- **store**: Your application's ReSwift store.
- **mapStateToProps**: A function that takes values from your application's
  state and puts them in the view controller's `props` object. This decouples
  your application state from the view controller data.
- **mapDispatchToActions**: A function that specifies which actions your view
  controller can call, and for each of those which ReSwift action needs to be
  dispatched.

#### connect()
Calling this method causes the connection to subscribe to the ReSwift store and
receive application state updates. Call this from your view controller's
`viewWillAppear` or `viewDidAppear` method.

#### disconnect()
Calling this method causes the connection to unsubscribe from the ReSwift store.
Call this from your view controller's `viewWillDisappear` or `viewDidDisappear`.

#### subscribe(keyPath, onNext)
Subscribe to an entry in your view controller's `props`, meaning that the given
`onNext` handler will be called whenever that entry changes.

#### bind(keyPath, to, mapping)
This function binds an entry in your view controller's `props` to a
RxSwift-enabled user interface element, so that every time your `props` change,
the user interface element is updated accordingly, automatically.

The function `bind` takes the following parameters:
- **keyPath**: The (Swift 4) key path that points to the element in your `props`
  that you want to bind to the user interface element.
- **to**: The RxSwift reactive property wrapper, e.g. `textField.rx.text` or
  `progressView.rx.progress`.
- **mapping**: _Most of the `bind` variants_ (but not all of them) allow you to
  provide a mapping function. This mapping function is applied to the `props`
  element at the specified `keyPath`. You can use this for example for type
  conversions: your `props` contains a value as a `Float`, but the UI element
  requires it to be a `String`. Specifying the mapping `{ String($0) }` will
  take care of that. [`SteppingUpViewController.swift`][12] contains an example
  of a mapping function that maps a `Float` value to the selected index of
  a segmented control.

Just for your understanding: there are several variants of the `bind` function.
They are all variants of this simplified code:

```swift
self.props
    .asObservable()
    .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    .map { $0[keyPath: keyPath] }
    .bind(to: observer)
    .disposed(by: disposeBag)
```

## Example App
The folder [`Example`][13] contains the following examples:

- **SimpleTextField**: Most basic use case of ReRxSwift, containing a text field that has its value bound, and an action.
- **SteppingUp**: Use case with multiple bound values and actions, also showing how to transform values when binding them.
- **TableAndCollection**: Shows how to use ReRxSwift in combination with RxSwift, RxCocoa and RxDataSources to have very simple table/collection views that automatically animate their updates.


## FAQ

### My `props` are not updated when the application state changes?
This happens when you forget to call `connection.connect()` in you view
controller's `viewWillAppear` or `viewDidAppear` method. While you're at it,
you may want to verify that you also call `connection.disconnect()` in
`viewWillDisappear` or `viewDidDisappear`.

### I get compiler errors when calling `connection.bind()`?
When calling `bind`, you pass a key path to an element in your `props` object.
Because of the way ReRxSwift makes sure to only trigger when this element
actually changed, it compares its value with the previous one. This means
that the elements in your `props` object need to be `Equatable`. Simple types
of course are already `Equatable`, but especially when binding table view
items or collection view items, you need to make sure that the types are
`Equatable`.

Another common source of errors is when the type of the element in your `props`
does not exactly match the expected type by the user interface element. For
example, you bind to a stepper's `stepValue`, which is a `Double`, but your
`props` contains a `Float`. In these cases you can pass a mapping function as
the third parameter to `bind(_:to:mapping:)` to cast the `props` element to
the expected type. See [`SteppingUpViewController.swift`][12] for examples.

### I double-checked everything and I still get errors!
Please open a [new issue][8] on GitHub, as you may have run into a bug. (But please make sure everything inside your `Props` type is `Equatable`!)


[1]: https://github.com/ReactiveX/RxSwift
[2]: https://github.com/ReSwift/ReSwift
[3]: http://redux.js.org/docs/basics/DataFlow.html
[4]: https://github.com/reactjs/redux
[5]: http://reactivex.io
[6]: http://redux.js.org/docs/basics/UsageWithReact.html
[7]: https://github.com/apple/swift-evolution/blob/master/proposals/0161-key-paths.md
[8]: https://github.com/svdo/ReRxSwift/issues
[9]: https://github.com/svdo/ReRxSwift/issues/1
[10]: https://github.com/svdo/ReRxSwift/blob/master/Example/SimpleTextField/SimpleTextFieldViewController.swift
[11]: https://github.com/svdo/ReRxSwift/blob/master/ExampleTests/SimpleTextField/SimpleTextFieldViewControllerSpec.swift
[12]: https://github.com/svdo/ReRxSwift/blob/master/Example/SteppingUp/SteppingUpViewController.swift
[13]: https://github.com/svdo/ReRxSwift/tree/master/Example
[14]: https://svdo.github.io/ReRxSwift
[15]: http://cocoapods.org
[16]: https://github.com/Carthage/Carthage
