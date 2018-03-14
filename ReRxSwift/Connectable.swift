//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

/// Declare your view controller to be suitable for ReRxSwift. This requires your
/// view controller to add a `Connection` property. Please note that you do not need
/// to explicitly specify what the `associatedtype`s are in your case, the compiler
/// will derive this from the parameters to the
/// `Connection(store:mapStateToProps:mapDispatchToProps)` constructor.
///
/// Example:
///
/// ```swift
/// class MyViewController: UIViewController {
///     let connection = Connection(
///         store: store,
///         mapStateToProps: mapStateToProps,
///         mapDispatchToActions: mapDispatchToActions
///     )
///
///     ...
/// ```

public protocol Connectable {
    /// The type of your global ReSwift application state.
    associatedtype AppStateType: StateType

    /// The type of your view controller's `Props` struct.
    associatedtype PropsType

    /// The type of your view controller's `Actions` struct.
    associatedtype ActionsType

    /// Being `Connectable` means that you must have a `connection` instance.
    var connection: Connection<AppStateType, PropsType, ActionsType> { get }
}

public extension Connectable {
    /// This is what your view controller uses to access the state that it wants to
    /// use. The contents of this variable is managed by the `Connection` object:
    /// whenever a new ReSwift state is received by your connection, it uses your
    /// `mapStateToProps` function to convert it your `Props` struct and makes it
    /// available through this variable.
    public var props: PropsType {
        get { return connection.props.value }
        set { connection.props.accept(newValue) }
    }

    /// This is what your view controller uses whenever it wants to trigger an action.
    /// The `Connection` manages this variable: it uses `mapDispatchToActions` to
    /// call your store's dispatch function the right way.
    public var actions: ActionsType {
        get { return connection.actions }
        set { connection.actions = newValue }
    }
}
