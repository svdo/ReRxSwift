//  Copyright © 2017 Stefan van den Oord. All rights reserved.

import ReSwift
import RxSwift
import RxCocoa

public class Connection<State: StateType, Props, Actions>: StoreSubscriber {
    let store: Store<State>
    let mapStateToProps: (State) -> (Props)
    public let props: Variable<Props>
    public let actions: Actions!
    let disposeBag = DisposeBag()

    public init(store: Store<State>,
                mapStateToProps: @escaping (State) -> (Props),
                mapDispatchToActions: (@escaping DispatchFunction) -> (Actions)
        ) {
        self.store = store
        self.mapStateToProps = mapStateToProps
        let initialState = store.state!
        let props = mapStateToProps(initialState)
        self.props = Variable(props)
        self.actions = mapDispatchToActions(store.dispatch)
    }

    public func connect() {
        store.subscribe(self)
    }

    public func disconnect() {
        store.unsubscribe(self)
    }

    public func newState(state: State) {
        props.value = mapStateToProps(state)
    }

    // MARK: - Binding optional observers

    public func bind<T: Equatable, O>(_ keyPath: KeyPath<Props, T>,
                                      to observer: O)
        where O: ObserverType, O.E == T?
    {
        self.bind(keyPath, to: observer, mapping: nil)
    }

    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T>,
                                         to observer: O,
                                         mapping: ((T)->M)? = nil)
        where O: ObserverType, O.E == M?
    {
        let distinctAtKeyPath = self.props
            .asObservable()
            .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
            .map { $0[keyPath: keyPath] }

        let afterMapping: Observable<M>
        if (T.self == M.self) {
            afterMapping = distinctAtKeyPath as! Observable<M>
        } else {
            afterMapping = distinctAtKeyPath.map(mapping!)
        }

        afterMapping
            .bind(to: observer)
            .disposed(by: disposeBag)
    }

    // MARK: - Binding non-optional observers

    public func bind<T: Equatable, O>(_ keyPath: KeyPath<Props, T>,
                                      to observer: O)
        where O: ObserverType, O.E == T
    {
        self.bind(keyPath, to: observer, mapping: nil)
    }

    public func bind<T: Equatable, O, M>(_ keyPath: KeyPath<Props, T>,
                                         to observer: O,
                                         mapping: ((T)->M)? = nil)
        where O: ObserverType, O.E == M
    {
        let distinctAtKeyPath = self.props
            .asObservable()
            .distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
            .map { $0[keyPath: keyPath] }

        let afterMapping: Observable<M>
        if (T.self == M.self) {
            afterMapping = distinctAtKeyPath as! Observable<M>
        } else {
            afterMapping = distinctAtKeyPath.map(mapping!)
        }

        afterMapping
            .bind(to: observer)
            .disposed(by: disposeBag)
    }

    // MARK: - Binding sequences using binder function
    //         (e.g. collectionView.rx.items)
    
    public func bind<S: Sequence>(_ keyPath: KeyPath<Props, S>,
                                  to binder: (Observable<S>) -> Disposable)
        where S.Element: Equatable
    {
        self.props
            .asObservable()
            .distinctUntilChanged { $0[keyPath: keyPath].elementsEqual($1[keyPath: keyPath]) }
            .map { $0[keyPath: keyPath] }
            .bind(to: binder)
            .addDisposableTo(disposeBag)
    }
}

