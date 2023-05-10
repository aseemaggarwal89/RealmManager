//
//  MessageUseCase.swift
//  RealmManager
//
//  Created by Aseem Aggarwal on 10/05/23.
//

import Foundation
import RealmSwift
import Combine

protocol ChatMessageUseCaseInjection {}
extension ChatMessageUseCaseInjection {
    var chatMessageDatabase: ChatMessageUseCaseProtocol {
        return ChatMessageUseCase()
    }
}

protocol ChatMessageUseCaseProtocol {
    func updateChatMessageFilePath(clientUUID: String, isAttachmentFileExist: Bool) -> AnyPublisher<Bool, Error>
    func updateChatMessageUploadResponse(clientUUID: String, attachmentId: Int, attachmentURL: String) -> AnyPublisher<String?, Error>
    func getChatMessages(chatGroupId: String) -> AnyPublisher<Results<ChatMessageRealmDTO>, Never>
    func deleteMessage(id: String) -> AnyPublisher<Bool, Error>
    func deleteAllChats() -> AnyPublisher<Bool, Error>
}

struct ChatMessageUseCase: ChatMessageUseCaseProtocol, DatabaseRepositoryInjection {
    func getUnsendMessages(chatGroupId: String) -> AnyPublisher<[ChatMessageRealmDTO], Never> {
        let future: AnyPublisher<Results<ChatMessageRealmDTO>, Never>  = database.getData {
            ($0.sentAt == nil) && ($0.chatGroupId == chatGroupId)
        }
        return future.map({ Array($0) }).eraseToAnyPublisher()
    }
    
    func getChatMessages(chatGroupId: String) -> AnyPublisher<Results<ChatMessageRealmDTO>, Never> {
        let future: AnyPublisher<Results<ChatMessageRealmDTO>, Never>  = database.getData()
        return future.map {
            $0.sorted(byKeyPath: "clientTimestamp", ascending: false).where {
                $0.chatGroupId == chatGroupId
            }
        }.eraseToAnyPublisher()
    }
    
    func getChatMessages(chatGroupId: String) -> AnyPublisher<[ChatMessageRealmDTO], Never> {
        let publisher: AnyPublisher<Results<ChatMessageRealmDTO>, Never> = getChatMessages(chatGroupId: chatGroupId)
        
        return publisher.map { results -> [ChatMessageRealmDTO] in
            let message: [ChatMessageRealmDTO] = Array(results)
            return message
        }.eraseToAnyPublisher()
    }
        
    private func getUnsendTextMessages() -> AnyPublisher<[ChatMessageRealmDTO], Never> {
        let future: AnyPublisher<Results<ChatMessageRealmDTO>, Never>  = database.getData {
            ($0.sentAt == nil && $0.type == TypeEnum.text)
        }
        
        return future.eraseToAnyPublisher().map({ Array($0) }).eraseToAnyPublisher()
    }

    private func getUploadedAttachmentMessages() -> AnyPublisher<[ChatMessageRealmDTO], Never> {
        let future: AnyPublisher<Results<ChatMessageRealmDTO>, Never>  = database.getData {
            ($0.sentAt == nil && $0.type != TypeEnum.text && $0.attachmentId != nil && $0.attachmentURL != nil)
        }

        return future.map({ Array($0) }).eraseToAnyPublisher()
    }
    
    func updateChatMessageFilePath(clientUUID: String, isAttachmentFileExist: Bool) -> AnyPublisher<Bool, Error> {
        return getChatMessages(clientUUID: clientUUID)
            .flatMap { message -> AnyPublisher<ChatMessageRealmDTO, Never> in
            guard let message = message else {
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            return Just(message).eraseToAnyPublisher()
        }.flatMap { result -> Future<Bool, Error> in
            return database.update(object: result) { message in
                message.isAttachmentFileExist = isAttachmentFileExist
            }
        }.eraseToAnyPublisher()
    }
    
    func updateChatMessageUploadResponse(clientUUID: String, attachmentId: Int, attachmentURL: String) -> AnyPublisher<String?, Error> {
        return getChatMessages(clientUUID: clientUUID)
            .flatMap { message -> AnyPublisher<ChatMessageRealmDTO, Never> in
            guard let message = message else {
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            return Just(message).eraseToAnyPublisher()
        }.flatMap { result -> Future<Bool, Error> in
            return database.update(object: result) { message in
                message.attachmentId = attachmentId
                message.attachmentURL = attachmentURL
            }
        }.flatMap({ isUpdated in
            return Just(clientUUID)
        })
        .eraseToAnyPublisher()
    }
    
    func getChatMessages(clientUUID: String) -> AnyPublisher<ChatMessageRealmDTO?, Never> {
        return database.getData().map {
            $0.sorted(byKeyPath: "clientTimestamp", ascending: false).where {
                $0.clientUUID == clientUUID
            }
        }.map({
            $0.first
        }).eraseToAnyPublisher()
    }
    
    func deleteMessage(id: String) -> AnyPublisher<Bool, Error> {
        let future = database.delete { (query: Query<ChatMessageRealmDTO>) in
            query.clientUUID == id
        }
        return future.eraseToAnyPublisher()
    }
    
    
    func deleteAllChats() -> AnyPublisher<Bool, Error> {
        return database.deleteAll(type: ChatMessageRealmDTO.self)
    }
}

enum DataBaseChanges {
    case initial
    case update(deletions: [Int], insertions: [Int], modifications: [Int])
    case error(Error)
}

class ChatMessageChangesListener: ChatMessageUseCaseInjection {
    private var results: Results<ChatMessageRealmDTO>? {
        didSet {
            self.notificationToken = results?.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.dataBaseChanges.send(.initial)
                case .update(_, let deletions, let insertions, let modifications):
                    self.dataBaseChanges.send(.update(deletions: deletions, insertions: insertions, modifications: modifications))
                case .error(let err):
                    self.dataBaseChanges.send(.error(err))
                }
            }
        }
    }
    private var notificationToken: NotificationToken?
    private let chatGroupId: String
    private let dataBaseChanges: PassthroughSubject<DataBaseChanges, Never> = PassthroughSubject()
    private var disposeBag = DisposeBag()

    var items: [ChatMessageDTO] {
        guard let results = results else {
            return []
        }
        
        let data = Array(results).compactMap({ ChatMessageDTO(chatReamDTO: $0) })
        return data
    }
    
    init(chatGroupId: String) {
        self.chatGroupId = chatGroupId
        listenDatabaseChanges()
    }
    
    var observeDataBaseChanges: AnyPublisher<DataBaseChanges, Never> {
        return dataBaseChanges.eraseToAnyPublisher()
    }
    
    func listenDatabaseChanges() {
        disposeBag.dispose()
        chatMessageDatabase.getChatMessages(chatGroupId: chatGroupId).sink { [weak self] messageResult in
            self?.results = messageResult
        }.store(in:&disposeBag.disposables)
    }
    
    deinit {
        notificationToken = nil
        disposeBag.dispose()
    }
}

class DisposeBag {
    var disposables = Set<AnyCancellable>()
    
    func dispose() {
        disposables.forEach { $0.cancel() }
    }
    
    deinit {
        dispose()
    }
}

struct ChatMessageDTO {
    init?(chatReamDTO: ChatMessageRealmDTO) {    
    }
}
