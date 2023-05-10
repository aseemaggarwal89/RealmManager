//
//  AppDatabaseService.swift
//  RealmManager
//
//  Created by Aseem Aggarwal on 10/05/23.
//

import Foundation
import RealmSwift
import Realm
import Combine

protocol DatabaseRepositoryInjection {}
extension DatabaseRepositoryInjection {
    var database: DatabaseProtocol {
        return AppRealmManager.shared
    }
}

protocol DatabaseProtocol {
    func saveData<T: Object>(realmObject: T) -> Future<Bool, Error>
    func saveData<T: Object>(realmObjects: [T]) -> Future<Bool, Error>
    func getData<T: Object>(_ isIncluded: ((Query<T>) -> Query<Bool>)?) -> AnyPublisher<Results<T>, Never>
    func getData<T: Object>() -> AnyPublisher<Results<T>, Never>
    func update<T: Object>(object: T, updateBlock: @escaping (T) -> Void) -> Future<Bool, Error>
    func delete<T: Object>(isIncluded: @escaping ((Query<T>) -> Query<Bool>)) -> Future<Bool, Error>
    func deleteAll<T: Object>(type: T.Type) -> AnyPublisher<Bool, Error>
}

class AppRealmManager: DatabaseProtocol {
    private let database: RealmManager
    static let shared = AppRealmManager()
    private let readQueue: DispatchQueue
    
    init(readQueue: DispatchQueue = DispatchQueue.main,
         writeQueue: DispatchQueue = DispatchQueue(label: "realm write queue")) {
        self.readQueue = readQueue
        self.database = RealmManager(readQueue: readQueue, writeQueue: writeQueue) ?? RealmManager()
    }
    
    func deleteAll<T: Object>(type: T.Type) -> AnyPublisher<Bool, Error> {
        let future = Future<Results<T>, Never> {[weak self] promise in
            self?.database.fetch() { result in
                promise(.success(result))
            }
        }

        return future.map {[unowned self] results -> Future<Bool, Error> in
            return self.delete(results: results)
        }.flatMap { $0.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    func delete<T: Object>(results: Results<T>) -> Future<Bool, Error> {
        let future = Future<Bool, Error> {[weak self] promise in
            self?.database.delete(objects: results) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        
        return future
    }
    
    func delete<T: Object>(isIncluded: @escaping ((Query<T>) -> Query<Bool>)) -> Future<Bool, Error> {
        let future = Future<Bool, Error> {[weak self] promise in
            self?.database.delete(isIncluded) {result in
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        
        return future
    }
    
    func saveData<T: Object>(realmObject: T) -> Future<Bool, Error> {
        let future = Future<Bool, Error> {[weak self] promise in
            self?.database.addOrUpdateWithRealm(object: realmObject) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        
        return future
    }

    func saveData<T: Object>(realmObjects: [T]) -> Future<Bool, Error> {
        let future = Future<Bool, Error> {[weak self] promise in
            self?.database.addOrUpdateWithRealm(objects: realmObjects, update: true) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        
        return future
    }
    

    func getData<T: Object>(_ isIncluded: ((Query<T>) -> Query<Bool>)?) -> AnyPublisher<Results<T>, Never> {
        let future = Future<Results<T>, Never> {[weak self] promise in
            self?.database.fetch(isIncluded) { result in
                promise(.success(result))
            }
        }
        
        return future.subscribe(on: readQueue).receive(on: readQueue).eraseToAnyPublisher()
    }
    
    func getData<T: Object>() -> AnyPublisher<Results<T>, Never> {
        let future = Future<Results<T>, Never> {[weak self] promise in
            self?.database.fetch(nil) { result in
                promise(.success(result))
            }
        }
        
        return future.subscribe(on: readQueue).receive(on: readQueue).eraseToAnyPublisher()
    }
    
    func update<T: Object>(object: T, updateBlock: @escaping (T) -> Void) -> Future<Bool, Error> {
        let future = Future<Bool, Error> {[weak self] promise in
            self?.database.updateWithRealm(object: object, updateBlock: updateBlock) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        
        return future
    }
}
