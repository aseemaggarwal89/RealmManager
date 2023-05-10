//
//  RealmManager.swift
//  RealmManager
//
//  Created by Aseem Aggarwal on 10/05/23.
//

import Foundation
import RealmSwift
import Realm
import Combine

extension Realm {
}

enum RealmResult {
    case success
    case failure(Error)
}

class RealmManager {
    public typealias Completion = ((RealmResult) -> Void)
    private let readQueue: DispatchQueue     //= DispatchQueue.main
    private let writeQueue: DispatchQueue   //= DispatchQueue(label: "realm write queue")
    private var readRealm: Realm!
    private var writeRealm: Realm!
    private var configuration: Realm.Configuration!

    init?(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration,
          readQueue: DispatchQueue = DispatchQueue.main,
          writeQueue: DispatchQueue = DispatchQueue(label: "realm write queue")) {
        self.configuration = configuration
        self.readQueue = readQueue
        self.writeQueue = writeQueue
        do {
            try readQueue.sync {
                self.readRealm = try Realm(configuration: configuration, queue: readQueue)
            }
            try writeQueue.sync {
                self.writeRealm = try Realm(configuration: configuration, queue: writeQueue)
            }
        } catch {
            return nil
        }
    }
    
    init() {
        self.configuration = Realm.Configuration.defaultConfiguration
        self.readQueue = DispatchQueue.main
        self.writeQueue = DispatchQueue(label: "realm write queue")
        self.readRealm = try! Realm(configuration: configuration, queue: readQueue)
        writeQueue.sync {
            self.writeRealm = try! Realm(configuration: configuration, queue: writeQueue)
        }
    }
    
    fileprivate func writeAsync<T: ThreadConfined>(_ passedObject: T, errorHandler: @escaping ((_ error: Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        
        if (passedObject.realm != nil) {
            DispatchQueue.main.async {
                let objectReference = ThreadSafeReference(to: passedObject)
                self.writeQueue.async { [unowned self] in
                    autoreleasepool {
                        do {
                            try self.writeRealm.write {                                // Resolve within the transaction to ensure you get the latest changes from other threads
                                let object = writeRealm.resolve(objectReference)
                                block(writeRealm, object)
                            }
                        } catch {
                            errorHandler(error)
                        }
                    }
                }
            }
        } else {
            self.writeQueue.async { [unowned self] in
                autoreleasepool {
                    do {
                        try self.writeRealm.write {
                            block(writeRealm, passedObject)
                        }
                    } catch {
                        errorHandler(error)
                    }
                }
            }
        }
    }
}

extension RealmManager {
    func addOrUpdateWithRealm<T: Object>(objects: [T],
                                         update: Bool,
                                         completion: @escaping Completion) {
        
        let rlmArray = List<T>()
        rlmArray.append(objectsIn: objects)
        
        writeAsync(rlmArray) { error in
            completion(.failure(error))
        } block: { realm, threadSafeObject in
            guard let threadSafeObject = threadSafeObject else {
                // Already deleted
                return
            }

            realm.add(threadSafeObject,
                      update: update ? .all : .error)
            completion(.success)
        }
    }
    
    func addOrUpdateWithRealm<T: Object>(object: T,
                                         completion: @escaping Completion) {
        writeAsync(object) { error in
            completion(.failure(error))
        } block: { realm, threadSafeObject in
            guard let threadSafeObject = threadSafeObject else {
                // Already deleted
                return
            }

            realm.add(threadSafeObject,
                      update: .all)
            completion(.success)
        }
    }
    
    func updateWithRealm<T: Object>(object: T,
                                    updateBlock: @escaping ((T) -> Void),
                                    completion: @escaping Completion) {
        writeAsync(object) { error in
            completion(.failure(error))
        } block: { realm, threadSafeObject in
            guard let threadSafeObject = threadSafeObject else {
                // Already deleted
                return
            }
            
            updateBlock(threadSafeObject)
            completion(.success)
        }
    }

    func delete<T: Object>(objects: Results<T>,
                           completion: @escaping Completion) {
        writeAsync(objects) { error in
            completion(.failure(error))
        } block: { realm, threadSafeObject in
            guard let threadSafeObject = threadSafeObject else {
                // Already deleted
                return
            }

            realm.delete(threadSafeObject)
            completion(.success)
        }
    }

    func delete<T: Object>(objects: List<T>,
                           condition: String?,
                           completion: @escaping Completion) {
        writeAsync(objects) { error in
            completion(.failure(error))
        } block: { realm, threadSafeObject in
            guard let threadSafeObject = threadSafeObject else {
                // Already deleted
                return
            }

            realm.delete(threadSafeObject)
            completion(.success)
        }
    }
}

extension RealmManager {
    func fetch<T: Object>(condition: String?,
                          completion: @escaping(_ result: Results<T>) -> Void) {
        readQueue.async { [unowned self] in
            
            debugPrint(readRealm.refresh())

            // All object inside the model passed.
            var objects = readRealm.objects(T.self)

            if let cond = condition {
                // filters the result if condition exists
                objects = objects.filter(cond)
            }

            completion(objects)
        }
    }

    func fetch<T: Object>(_ isIncluded: ((Query<T>) -> Query<Bool>)? = nil,
                          completion: @escaping(_ result: Results<T>) -> Void) {
        readQueue.async { [unowned self] in
            debugPrint(readRealm.refresh())
            guard let cond = isIncluded else {
                let objects = readRealm.objects(T.self)
                completion(objects)
                return
            }
            // filters the result if condition exists
            let objects = readRealm.objects(T.self).where(cond)
            completion(objects)
        }
    }
    
    
    func delete<T: Object>(_ isIncluded: ((Query<T>) -> Query<Bool>)?,
                           completion: @escaping Completion) {
        fetch(isIncluded) { [unowned self] fetched in
            writeAsync(fetched) { error in
                completion(.failure(error))
            } block: { realm, threadSafeObject in
                guard let threadSafeObject = threadSafeObject else {
                    // Already deleted
                    completion(.success)
                    return
                }

                realm.delete(threadSafeObject)
                completion(.success)
            }
        }
    }
    
    func delete<T: Object>(object: T?, condition: String?,
                           completion: @escaping Completion) {
        if object == nil {
            fetch(condition: condition) { [unowned self] fetched in
                writeAsync(fetched) { error in
                    completion(.failure(error))
                } block: { realm, threadSafeObject in
                    guard let threadSafeObject = threadSafeObject else {
                        // Already deleted
                        return
                    }

                    realm.delete(threadSafeObject)
                    completion(.success)
                }
            }
        } else {
            if let object = object {
                writeAsync(object) { error in
                    completion(.failure(error))
                } block: { realm, threadSafeObject in
                    guard let threadSafeObject = threadSafeObject else {
                        // Already deleted
                        return
                    }

                    realm.delete(threadSafeObject)
                    completion(.success)
                }
            }
        }
    }

}
