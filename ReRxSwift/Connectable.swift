//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift

public protocol Connectable {
    associatedtype AppStateType: StateType
    associatedtype PropsType
    associatedtype ActionsType
    var connection: Connection<AppStateType, PropsType, ActionsType> { get }
}

public extension Connectable {
    public var props: PropsType {
        get { return connection.props.value }
        set { connection.props.value = newValue }
    }
    public var actions: ActionsType {
        get { return connection.actions }
        set { connection.actions = newValue }
    }
}
