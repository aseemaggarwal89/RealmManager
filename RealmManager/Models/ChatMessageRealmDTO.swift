//
//  ChatMessageRealmDTO.swift
//  RealmManager
//
//  Created by Aseem Aggarwal on 10/05/23.
//

import Foundation
import RealmSwift

class ChatMessageRealmDTO: Object {
    @Persisted(primaryKey: true) var clientUUID: String?
    @Persisted var chatGroupId: String = ""
    @Persisted var id: String?
    @Persisted var messageText: String = ""
    @Persisted var clientTimestamp: String?
    @Persisted var type: TypeEnum?
    @Persisted var sendById: Int?
    @Persisted var sendByName: String?
    @Persisted var data: String?
    @Persisted var attachmentId: Int?
    @Persisted var attachmentName: String?
    @Persisted var attachmentURL: String?
    @Persisted var sentAt: String?
    @Persisted var readAt: String?
    @Persisted var readByAll: Bool = false
    @Persisted var sentToAll: Bool = false
    @Persisted var isSecret: Bool = false
    @Persisted var archivedAt: String?
    @Persisted var remainingSeconds: Double?
    @Persisted var validForSeconds: Double?
    @Persisted var isAttachmentFileExist: Bool = false
    @Persisted var uploadAttachmentFileExist: String?

    override init() {
        super.init()
    }
}


enum TypeEnum: String, Codable, PersistableEnum {
    case audio = "audio"
    case audioCall = "audio_call"
    case document = "document"
    case image = "image"
    case text = "text"
    case video = "video"
    case videoCall = "video_call"
    case vanish = "vanishing"
    
    func fileExtentions() -> String {
        switch self {
        case .image:
            return ".jpeg"
        case .video, .videoCall:
            return ".mp4"
        case .document:
            return ".pdf"
        case .text:
            return ".txt"
        case .audioCall:
            return ".m4a"
        case .audio:
            return ".wav"
        case .vanish:
            return ""
        }
    }
}



