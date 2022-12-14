//
//  Persistence.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import Foundation
import CloudKit
import Combine

let myContainer = CKContainer(identifier: "your.container.identifier")

protocol CloudKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
}


class CloudKitUtility {
    
    enum CloudKitError : String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
    
}

// MARK: USER FUNCTIONS

extension CloudKitUtility {
    
    static private func getiCloudStatus(completion: @escaping (Result<Bool,Error>)->()){
        myContainer.accountStatus { returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    completion(.success(true))
                case .noAccount:
                    completion(.failure(CloudKitError.iCloudAccountNotFound))
                case .couldNotDetermine:
                    completion(.failure(CloudKitError.iCloudAccountNotDetermined))
                case .restricted:
                    completion(.failure(CloudKitError.iCloudAccountRestricted))
                default:
                    completion(.failure(CloudKitError.iCloudAccountUnknown))
                }
            }
        }
    }
    
    static func getiCloudStatus()-> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static private func requestApplicationPermission(completion: @escaping (Result<Bool,Error>)->()){
        myContainer.requestApplicationPermission([.userDiscoverability]) { returnedStatus, returnedError in
            if returnedStatus == .granted{
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func requestApplicationPermission()-> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static private func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID,Error>)->()){
        myContainer.fetchUserRecordID { returnedID, returnedError in
            if let id = returnedID {
                completion(.success(id))
            }else{
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func discoverUserIdentity(id : CKRecord.ID, completion: @escaping (Result<String,Error>)->()){
        myContainer.discoverUserIdentity(withUserRecordID: id) { returnedIdentity, returnedError in
            if let name = returnedIdentity?.nameComponents?.givenName {
                completion(.success(name))
            }
            else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static private func discoverUserIdentity(completion: @escaping (Result<String,Error>)->()){
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion{
            case .success(let RecordID):
                CloudKitUtility.discoverUserIdentity(id: RecordID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func discoverUserIdentity()-> Future<String, Error> {
        Future { promise in
            CloudKitUtility.discoverUserIdentity { result in
                promise(result)
            }
        }
    }
}

// MARK: CRUD FUNCTIONS

extension CloudKitUtility {
    
    static func fetch<T:CloudKitableProtocol>(predicate : NSPredicate, recordType : CKRecord.RecordType, sortDescriptors : [NSSortDescriptor]? = nil, resultsLimit : Int? = nil) -> Future<[T], Error> {
        Future{ promise in
            CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (items:[T]) in
                promise(.success(items))
            }
        }
    }
    
    static private func fetch<T:CloudKitableProtocol>(predicate : NSPredicate, recordType : CKRecord.RecordType, sortDescriptors : [NSSortDescriptor]? = nil, resultsLimit : Int? = nil, completion: @escaping (_ items: [T]) -> ()){
        
        // Create Operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)
        
        // Get Items in query
        var returnedItems:  [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            returnedItems.append(item)
        }
        
        //Query Completion
        addQueryResultBlock(operation: operation) { finished in
            completion(returnedItems)
        }
        
        // Execute Operation
        add(operation: operation)
    }
    
    static private func createOperation(predicate : NSPredicate, recordType : CKRecord.RecordType, sortDescriptors : [NSSortDescriptor]? = nil, resultsLimit : Int? = nil) -> CKQueryOperation{
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let queryOperation = CKQueryOperation(query: query)
        if let limit = resultsLimit {
            queryOperation.resultsLimit = limit
        }
        return queryOperation
    }
    
    static private func addRecordMatchedBlock<T:CloudKitableProtocol>(operation : CKQueryOperation, completion: @escaping (_ item: T) -> ()){
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
                switch returnedResult {
                case .success(let record):
                    guard let item = T(record: record) else {return}
                    completion(item)
                case .failure:
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = {(returnedRecord) in
                guard let item = T(record: returnedRecord) else {return}
                completion(item)

            }
        }
    }
    
    static private func addQueryResultBlock(operation : CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()){
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = {returnedResult in
                completion(true)
            }
        } else {
            operation.queryCompletionBlock = {(returnedCursor, returnedError) in
                completion(true)
            }
        }
    }
    
    static private func add(operation: CKDatabaseOperation){
        myContainer.publicCloudDatabase.add(operation)
    }
    
    static func add<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>)->()) {
        
        //Get Record
        let record = item.record
        //Save to cloudkit
        save(record: record, completion: completion)
    }
    
    static func update<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>)->()) {
        add(item: item, completion: completion)
    }
    
    static func save(record: CKRecord, completion: @escaping (Result<Bool, Error>)->()) {
        myContainer.publicCloudDatabase.save(record) { returnedRecord, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func delete<T:CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T:CloudKitableProtocol>(item: T, completion: @escaping (Result<Bool, Error>)->()){
        CloudKitUtility.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>)->()){
        myContainer.publicCloudDatabase.delete(withRecordID: record.recordID) { returnedRecordID, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
}
