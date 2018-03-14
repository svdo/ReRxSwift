//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift
import RxSwift
import RxCocoa

/// A ReRxSwift Connection that manages the mapping between ReSwift application state
/// and ReSwift actions on the one hand, and view controller props and actions on the
/// other hand.
///
/// In order to use this, you have to make your view controller conform to
/// `Connectable` and add a `Connection` instance. In your view controller
/// you need to call `connect()` and `disconnect()` at the right time.
///
/// Examples
/// ========
/// The folder [`Example`](https://github.com/svdo/ReRxSwift/tree/master/Example)
/// contains example of how to use this.
///
/// Usage
/// =====
/// 1. Create an extension to your view controller to make it `Connectable`,
/// defining the `Props` and `Actions` that your view controller needs:
///
///     ```swift
///     extension MyViewController: Connectable {
///         struct Props {
///             let text: String
///         }
///         struct Actions {
///             let updatedText: (String) -> Void
///         }
///     }
///     ```
///
/// 2. Define how your state is mapped to the above `Props` type:
///
///     ```swift
///     private let mapStateToProps = { (appState: AppState) in
///         return MyViewController.Props(
///             text: appState.content
///         )
///     }
///     ```
///
/// 3. Define the actions that are dispatched:
///
///     ```swift
///     private let mapDispatchToActions = { (dispatch: @escaping DispatchFunction) in
///         return MyViewController.Actions(
///             updatedText: { newText in dispatch(SetContent(newContent: newText)) }
///         )
///     }
///     ```
///
/// 4. Define the connection and hook it up:
///
///     ```swift
///     class MyViewController: UIViewController {
///         @IBOutlet weak var textField: UITextField!
///
///         let connection = Connection(
///             store: store,
///             mapStateToProps: mapStateToProps,
///             mapDispatchToActions: mapDispatchToActions
///         )
///
///         override func viewWillAppear(_ animated: Bool) {
///             super.viewWillAppear(animated)
///             connection.connect()
///         }
///
///         override func viewDidDisappear(_ animated: Bool) {
///             super.viewDidDisappear(animated)
///             connection.disconnect()
///         }
///     }
///     ```
///
/// 5. Bind the text field's text, using a Swift 4 key path to refer to the
/// `text` property of `Props`:
///
///     ```swift
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         connection.bind(\Props.text, to: textField.rx.text)
///     }
///     ```
///
/// 6. Call the action:
///
///     ```swift
///     @IBAction func editingChanged(_ sender: UITextField) {
///         actions.updatedText(sender.text ?? "")
///     }
///     ```

public class Connection<State: StateType, Props, Actions>: StoreSubscriber {
    /// The RxSwift `BehaviorRelay` that holds your view controller props.
    /// Normally you don't use this this directly, you use it through `Connectable.props`
    /// instead. This variable is public so that you can use it for unit testing.
    /// In cases where you don't want to use the `bind(_:to:)` methods in this class and want
    /// to create your own RxSwift observing code, you do need to use this variable
    /// directly.
    public let props: BehaviorRelay<Props>

    /// This holds you view controller's actions. Don't use this directly, use
    /// `Connectable.actions` instead. This variable is public so that you can use it
    /// for unit testing.
    public var actions: Actions!

    /// The ReSwift store used by this connection object. Normally you pass
    /// your global app store as a parameter to the constructor. This variable
    /// is public so that you can inject a different store during unit testing.
    /// It is not intended to be used directly from production code.
    public var store: Store<State> {
        didSet {
            self.actions = self.mapDispatchToActions(store.dispatch)
        }
    }

    /// This is the mapping function that takes your global ReSwift state, and maps
    /// it into your view controller's `Connectable.props`.
    let mapStateToProps: (State) -> (Props)

    /// This is the mapping function that maps actions in your view controller
    /// to ReSwift actions.
    let mapDispatchToActions: (@escaping DispatchFunction) -> (Actions)

    /// RxSwift memory management.
    let disposeBag = DisposeBag()

    /// Constructs a new `Connection` object. For examples see the class documentation
    /// above, or the code examples in
    /// [`SimpleTextFieldViewController`](https://github.com/svdo/ReRxSwift/blob/master/Example/SimpleTextField/SimpleTextFieldViewController.swift) and
    /// [`SteppingUpViewController`](https://github.com/svdo/ReRxSwift/blob/master/Example/SteppingUp/SteppingUpViewController.swift).
    ///
    /// - Parameters:
    ///   - store: Your application's global store.
    ///   - mapStateToProps: A mapping function that takes the global application state,
    ///     and maps it into a view controller specific structure `Connectable.props`.
    ///     Whenever a new state comes in from your ReSwift store, the connection calls
    ///     this function to map it to the `Connectable.props` needed by your view
    ///     controller.
    ///   - mapDispatchToActions: A mapping function that specifies which ReSwift action
    ///     needs to be dispatched when your view controller calls its
    ///     `Connectable.actions`.
    public init(store: Store<State>,
                mapStateToProps: @escaping (State) -> (Props),
                mapDispatchToActions: @escaping (@escaping DispatchFunction) -> (Actions)
        ) {
        self.store = store
        self.mapStateToProps = mapStateToProps
        self.mapDispatchToActions = mapDispatchToActions
        let initialState = store.state!
        let props = mapStateToProps(initialState)
        self.props = BehaviorRelay(value: props)
        self.actions = mapDispatchToActions(store.dispatch)
    }
    
    deinit {
        disconnect()
    }

    /// "Activates" the connection in the sense that it subscribes to the store so that
    /// store updates are received and can be processed. Failing to call this method
    /// will mean that your view controller does not get new `Connectable.props` when
    /// the global state changes. Call this method from your view controller's
    /// `viewWillAppear()` or `viewDidAppear()`.
    public func connect() {
        store.subscribe(self)
    }

    /// "Deactivates" the connection: unsubscribes from the store so that state updates
    /// are no longer processed for your view controller. Call this method from your view
    /// controller's `viewWillDisappear()` or `viewDidDisappear()`.
    public func disconnect() {
        store.unsubscribe(self)
    }

    /// ReSwift's callback method. Don't call this yourself.
    public func newState(state: State) {
        props.accept(mapStateToProps(state))
    }

    // MARK: - Helper functions

    private func propsEntry<T>(at keyPath: KeyPath<Props, T>,
                               isEqual: @escaping (T,T) -> Bool)
        -> Observable<T> {
        return self.props
            .asObservable()
            .distinctUntilChanged { isEqual($0[keyPath: keyPath], $1[keyPath: keyPath]) }
            .map { $0[keyPath: keyPath] }
    }

    // MARK: - Binding Observers of Optionals

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    /// Convenience method for `bind(keyPath, to: observer, mapping: nil)`.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    public func bind<T: Equatable, O>(_ keyPath: KeyPath<Props, T>,
                                      to observer: O)
        where O: ObserverType, O.E == T?
    {
        self.bind(keyPath, to: observer, mapping: nil)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    ///
    /// All `bind()` functions are variants of the following basic implementation:
    ///
    /// ```swift
    ///     self.props
    ///         .asObservable()
    ///         .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    ///         .map { $0[keyPath: keyPath] }
    ///         .map(mapping)                                            // if not nil
    ///         .bind(to: binder)
    ///         .disposed(by: disposeBag)
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    ///   - mapping: An optional function that takes the entry in your
    ///     `Connectable.props` and converts it to the thing needed by the
    ///     observable. This is useful if your `Connectable.props` entry is a different
    ///     type that needs to be converted before it can be put into the observer, for
    ///     example converting a `Float` into a `String` so that it can be put in a
    ///     text field's `text`.
    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T>,
                                         to observer: O,
                                         mapping: ((T)->M)? = nil)
        where O: ObserverType, O.E == M?
    {
        let distinctAtKeyPath = self.propsEntry(at: keyPath) { $0 == $1}

        let afterMapping: Observable<M>
        if let mapping = mapping {
            afterMapping = distinctAtKeyPath.map(mapping)
        } else {
            afterMapping = distinctAtKeyPath as! Observable<M>
        }

        afterMapping
            .bind(to: observer)
            .disposed(by: disposeBag)
    }

    // MARK: - Subscribing and Binding to Optional Prop

    /// Subscribe to one of your `Connectable.props` entries, having a closure
    /// called whenever it changes. Variant for optional entries.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to subscribe to.
    ///   - onNext: The closure that is called whenever the entry at the given
    ///     key path changes. The new value is passed into the closure as a parameter.
    public func subscribe<T: Equatable>(_ keyPath: KeyPath<Props, T?>,
                                        onNext: @escaping (T?)->())
    {
        self.propsEntry(at: keyPath) { $0 == $1}
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    /// Convenience method for `bind(keyPath, to: observer, mapping: nil)`.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T?>,
                                         to observer: O)
        where O: ObserverType, O.E == M
    {
        self.bind(keyPath, to: observer, mapping: nil)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    ///
    /// All `bind()` functions are variants of the following basic implementation:
    ///
    /// ```swift
    ///     self.props
    ///         .asObservable()
    ///         .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    ///         .map { $0[keyPath: keyPath] }
    ///         .map(mapping)                                            // if not nil
    ///         .bind(to: binder)
    ///         .disposed(by: disposeBag)
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    ///   - mapping: An optional function that takes the entry in your
    ///     `Connectable.props` and converts it to the thing needed by the
    ///     observable. This is useful if your `Connectable.props` entry is a different
    ///     type that needs to be converted before it can be put into the observer, for
    ///     example converting a `Float` into a `String` so that it can be put in a
    ///     text field's `text`.
    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T?>,
                                         to observer: O,
                                         mapping: ((T?)->M)? = nil)
        where O: ObserverType, O.E == M
    {
        let distinctAtKeyPath = self.propsEntry(at: keyPath) { $0 == $1}

        let afterMapping: Observable<M>
        if let mapping = mapping {
            afterMapping = distinctAtKeyPath.map(mapping)
        } else {
            afterMapping = distinctAtKeyPath as! Observable<M>
        }

        afterMapping
            .bind(to: observer)
            .disposed(by: disposeBag)
    }

    // MARK: - Subscribing and Binding Observers of Non-Optionals to Non-Optional Prop

    /// Subscribe to one of your `Connectable.props` entries, having a closure
    /// called whenever it changes. Variant for non-optional entries.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to subscribe to.
    ///   - onNext: The closure that is called whenever the entry at the given
    ///     key path changes. The new value is passed into the closure as a parameter.
    public func subscribe<T: Equatable>(_ keyPath: KeyPath<Props, T>,
                                        onNext: @escaping (T)->())
    {
        self.propsEntry(at: keyPath) { $0 == $1}
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    /// Convenience method for `bind(keyPath, to: observer, mapping: nil)`.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    public func bind<T: Equatable, O>(_ keyPath: KeyPath<Props, T>,
                                      to observer: O)
        where O: ObserverType, O.E == T
    {
        self.bind(keyPath, to: observer, mapping: nil)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    ///
    /// All `bind()` functions are variants of the following basic implementation:
    ///
    /// ```swift
    ///     self.props
    ///         .asObservable()
    ///         .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    ///         .map { $0[keyPath: keyPath] }
    ///         .map(mapping)                                            // if not nil
    ///         .bind(to: binder)
    ///         .disposed(by: disposeBag)
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - observer: The RxSwift observer that you want to bind to.
    ///   - mapping: An optional function that takes the entry in your
    ///     `Connectable.props` and converts it to the thing needed by the
    ///     observable. This is useful if your `Connectable.props` entry is a different
    ///     type that needs to be converted before it can be put into the observer, for
    ///     example converting a `Float` into a `String` so that it can be put in a
    ///     text field's `text`.
    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T>,
                                         to observer: O,
                                         mapping: ((T)->M)? = nil)
        where O: ObserverType, O.E == M
    {
        let distinctAtKeyPath = self.propsEntry(at: keyPath) { $0 == $1}

        let afterMapping: Observable<M>
        if let mapping = mapping {
            afterMapping = distinctAtKeyPath.map(mapping)
        } else {
            afterMapping = distinctAtKeyPath as! Observable<M>
        }

        afterMapping
            .bind(to: observer)
            .disposed(by: disposeBag)
    }

    // MARK: - Subscribing and binding sequences using binder function
    //         (e.g. collectionView.rx.items)

    /// Subscribe to one of your `Connectable.props` entries, having a closure
    /// called whenever it changes. Variant for non-optional entries.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to subscribe to.
    ///   - onNext: The closure that is called whenever the entry at the given
    ///     key path changes. The new value is passed into the closure as a parameter.
    public func subscribe<T: Equatable>(_ keyPath: KeyPath<Props, [T]>,
                                        onNext: @escaping ([T])->())
    {
        self.propsEntry(at: keyPath) { $0.elementsEqual($1) }
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }

    /// Bind a RxSwift observer to one of your `Connectable.props` entries.
    ///
    /// - Parameters:
    ///   - keyPath: Swift 4 `KeyPath` that points to the entry in your view
    ///     controllers `Connectable.props` that you want to bind.
    ///   - binder: The RxSwift binder function such as used by `UICollectionView.rx.items`
    ///     and `UITableView.rx.items`.
    public func bind<S: Sequence,M>(_ keyPath: KeyPath<Props, S>,
                                    to binder: (Observable<M>) -> Disposable,
                                    mapping: ((S)->M)? = nil)
        where S.Element: Equatable
    {
        let distinctAtKeyPath = self.propsEntry(at: keyPath) { $0.elementsEqual($1) }

        let afterMapping: Observable<M>
        if let mapping = mapping {
            afterMapping = distinctAtKeyPath.map(mapping)
        } else {
            afterMapping = distinctAtKeyPath as! Observable<M>
        }

        afterMapping
            .bind(to: binder)
            .disposed(by: disposeBag)
    }
}

