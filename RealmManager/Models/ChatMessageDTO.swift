////
////  ChatMessageDTO.swift
////  RealmManager
////
////  Created by Aseem Aggarwal on 10/05/23.
////
//
//import Foundation
//import RealmSwift
//
//enum MessageType: String, Codable {
//    case chatMessage = "chat_message"
//    case chatRoom = "chat_room"
//    case pingMessage = "ping_message"
//    case manualPingMessage = "manual_ping"
//    case onlineStatus = "online_status"
//    case readReceipt = "read_receipt"
//    case declineCall = "decline_call"
//    case endCall = "end_call"
//    case chatGroupConfig = "chat_group_config"
//    case blockUser = "block_user"
//    case removeUser = "remove_user"
//    case none = ""
//}
//
//struct BaseSocketMessageDTO<T: Codable>: Codable {
//    var type: MessageType?
//    var data: T?
//}
//
//struct BaseChatMessageSocketDTO: Codable {
//    var type: MessageType?
//    var message: ChatMessageDTO?
//
//    init(type: MessageType, message: ChatMessageDTO) {
//        self.type = type
//        self.message = message
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case type
//        case message = "data"
//    }
//}
//
//// Response from RestAPI
//struct ChatMessageResponseDTO: Codable {
//    let messageInfo: [ChatMessageDTO]
//    let totalMessages: Int
//}
//
//struct ChatMessageDTO: ChatMessageInfo {
//    let messageText: String
//    let clientUUID: String
//    let clientTimestamp: String
//    var type: TypeEnum
//    var chatGroupId: String
//    let sendById: Int?
//    let sendByName: String?
//    let data: String?
//    let attachmentURL: String?
//    let sentAt: String?
//    var readAt: String? = nil
//    var readByAll: Bool
//    var sentToAll: Bool
//    var isSecret: Bool?
//    var id: String?
//    var attachmentId: Int?
//    var attachmentName: String?
//    var archivedAt: String?
//    var remainingSeconds: Double?
//    var validForSeconds: Double?
//    var isAttachmentFileExist: Bool?
//    var uploadAttachmentFileExist: String?
//    var isSelected: Bool = false
//
//    enum CodingKeys: String, CodingKey {
//        case messageText
//        case clientUUID, clientTimestamp
//        case type
//        case chatGroupId
//        case sendById
//        case sendByName
//        case data
//        case attachmentURL
//        case sentAt
//        case readByAll
//        case sentToAll
//        case isSecret
//        case id
//        case attachmentId
//        case attachmentName
//        case archivedAt
//        case remainingSeconds
//        case validForSeconds
//    }
//
//    init?(chatReamDTO: ChatMessageRealmDTO) {
//        self.init(messageText: chatReamDTO.messageText, clientUUID: chatReamDTO.clientUUID, clientTimestamp: chatReamDTO.clientTimestamp, type: chatReamDTO.type, chatGroupId: chatReamDTO.chatGroupId, sendById: chatReamDTO.sendById, sendByName: chatReamDTO.sendByName, data: chatReamDTO.data, attachmentURL: chatReamDTO.attachmentURL, sentAt: chatReamDTO.sentAt, readAt: chatReamDTO.readAt, sentToAll: chatReamDTO.sentToAll, readByAll: chatReamDTO.readByAll, isSecret: chatReamDTO.isSecret, id: chatReamDTO.id, attachmentId: chatReamDTO.attachmentId, attachmentName: chatReamDTO.attachmentName, archivedAt: chatReamDTO.archivedAt, remainingSeconds: chatReamDTO.remainingSeconds, validForSeconds: chatReamDTO.validForSeconds, isAttachmentFileExist: chatReamDTO.isAttachmentFileExist, uploadAttachmentFileExist: chatReamDTO.uploadAttachmentFileExist)
//    }
//
//    init?(messageText: String?, clientUUID: String?, clientTimestamp: String?,
//         type: TypeEnum?, chatGroupId: String?,
//         sendById: Int?, sendByName: String?, data: String?,
//         attachmentURL: String?, sentAt: String?, readAt: String?,  sentToAll: Bool,
//         readByAll: Bool ,isSecret: Bool?, id: String?,
//         attachmentId: Int?, attachmentName: String?, archivedAt: String?,
//          remainingSeconds: Double?, validForSeconds: Double?, isAttachmentFileExist: Bool, uploadAttachmentFileExist: String?) {
//        guard let chatGroupId = chatGroupId, let clientUUID = clientUUID, let clientTimestamp = clientTimestamp else {
//            return nil
//        }
//
//        self.messageText = messageText ?? ""
//        self.clientUUID = clientUUID
//        self.clientTimestamp = clientTimestamp
//        self.type = type ?? .text
//        self.chatGroupId = chatGroupId
//
//        self.sendById = sendById
//        self.sendByName = sendByName
//        self.data = data
//
//        self.attachmentURL = attachmentURL
//        self.sentAt = sentAt
//        self.readAt = readAt
//        self.sentToAll = sentToAll
//        self.readByAll = readByAll
//        self.isSecret = isSecret
//        self.id = id
//        self.attachmentId = attachmentId
//        self.attachmentName = attachmentName
//        self.archivedAt = archivedAt
//        self.remainingSeconds = remainingSeconds
//        self.validForSeconds = validForSeconds
//        self.isAttachmentFileExist = isAttachmentFileExist
//        self.uploadAttachmentFileExist = uploadAttachmentFileExist
//    }
//
//    init(messageText: String, chatGroupId: String) {
//        let uuid = UUID().uuidString
//        self.messageText = messageText
//        self.clientUUID = uuid
//        self.clientTimestamp = Date.now.description
//        self.type = TypeEnum.text
//        self.chatGroupId = chatGroupId
//        self.sendById = userInfo.id
//        self.sendByName = userInfo.name
//        self.data = messageText
//
//        self.attachmentURL = nil
//        self.sentAt = nil
//        self.readAt = nil
//        self.sentToAll = false
//        self.readByAll = false
//        self.isSecret = nil
//        self.id = nil
//        self.attachmentId = nil
//        self.attachmentName = nil
//        self.archivedAt = nil
//        self.remainingSeconds = nil
//        self.validForSeconds = nil
//        self.isAttachmentFileExist = false
//    }
//
//    init(messageText: String, chatGroupId: String, validForSeconds: Double) {
//        let uuid = UUID().uuidString
//        self.messageText = messageText
//        self.clientUUID = uuid
//        self.clientTimestamp = Date.now.toString()
//        self.type = TypeEnum.vanish
//        self.chatGroupId = chatGroupId
//        self.sendById = userInfo.id
//        self.sendByName = userInfo.name
//        self.data = messageText
//        self.validForSeconds = validForSeconds
//
//        self.attachmentURL = nil
//        self.sentAt = nil
//        self.readAt = nil
//        self.sentToAll = false
//        self.readByAll = false
//        self.isSecret = nil
//        self.id = nil
//        self.attachmentId = nil
//        self.attachmentName = nil
//        self.archivedAt = nil
//        self.remainingSeconds = nil
//        self.isAttachmentFileExist = false
//    }
//
//    func sendDate() -> Date? {
//        return sentAt?.toDateUTC()
//    }
//
//    func clientTimestampDate() -> Date? {
//        return clientTimestamp.toDate()
//    }
//
//    func sendDateAsString() -> String? {
//        return sendDate()?.toString(formatType: .mmmdyyyy)
//    }
//
//    func sendDateAsCurrentTimeString() -> String? {
//        return sendDate()?.toStringAsCurrentTimeZone(formatType: .hmma)
//    }
//
//    func isMessageSend() -> Bool {
//        return sendDate() == nil ? false : true
//    }
//
//    func isMessageSendByLoginUser() -> Bool {
//        guard let userInfo = AppUserDefaults.userInfo else {
//            return false
//        }
//
//        return sendById == userInfo.userInfo.id
//    }
//
//    func lastMessageInfo() -> LastMessageRealmDTO {
//        return LastMessageRealmDTO.init(lastMessageText: messageText, lastMessageBy: sendByName, lastMessageSentAt: sentAt, lastMessageType: type, lastMessageByUserId: sendById)
//    }
//
//    func isImage() -> Bool {
//        return type == .image
//    }
//
//    func isVideo() -> Bool {
//        return type == .video
//    }
//
//    func canDownloadAttachment() -> Bool {
//        switch type {
//        case .audio, .video, .document, .image:
//            return true
//        default:
//            return false
//        }
//    }
//
//    func attachmentFileExtension() -> String {
//        guard let attachmentURL = self.attachmentURL else {
//            return self.type.fileExtentions()
//        }
//        guard let resourceUrl = URL(string: attachmentURL) else {
//            return self.type.fileExtentions()
//        }
//
//        return resourceUrl.lastPathComponent
//    }
//
//    func attachmentFileName() -> String {
//        return attachmentName ?? "\(clientUUID)\(attachmentFileExtension())"
//    }
//
//    mutating func toggleSelection() {
//        self.isSelected = !self.isSelected
//    }
//}
//
//protocol ChatMessageInfo: MessageInfo {
//    var readByAll: Bool { get }
//    var sentToAll: Bool { get }
//    var isSecret: Bool? { get }
//    var id: String? { get }
//    var attachmentId: Int? { get }
//    var attachmentName: String? { get }
//    var archivedAt: String? { get }
//    var remainingSeconds: Double? { get }
//    var validForSeconds: Double? { get }
//}
//
//
//extension Dictionary {
//    var dictionaryToJsonData: Data? {
//        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
//    }
//
//    func dictionaryToJSONString() -> String? {
//        if let jsonData = dictionaryToJsonData {
//            let jsonString = String(data: jsonData, encoding: .utf8)
//            return jsonString
//        }
//
//        return nil
//    }
//}
//
//
//struct ChatMessageSocketResponseDTO: Codable {
//    var type: MessageType?
//    var message: MessageInfoResponseDTO?
//
//    enum CodingKeys: String, CodingKey {
//        case type
//        case message = "data"
//    }
//
//}
//
//// MARK: - Secret Chat Request Classes
//struct SecretChatRequestDTO: Codable {
//    let validityForSeconds: Int
//    let chatGroupId: String
//}
//
//struct SecretChatResponseDTO: Codable {
//    let type: String
//    let data: SecretChatDTO?
//
//    enum CodingKeys: String, CodingKey {
//        case type
//        case data
//    }
//}
//
//struct SecretChatDTO: Codable {
//    let validityForSeconds: Int
//    let chatGroupId: String
//
//    enum CodingKeys: String, CodingKey {
//        case validityForSeconds
//        case chatGroupId
//    }
//}
//
//// MARK: - Calls Request Classes
//struct CallRequestDTO: Codable {
//    let userIds: [Int]
//    let clientUUID: String
//    let clientTimestamp: String
//    let type: TypeEnum
//    var chatGroupId: String
//
//    init(type: TypeEnum, chatGroupId: String, userIds: [Int]) {
//        let uuid = UUID().uuidString
//        self.clientUUID = uuid
//        self.clientTimestamp = Date.now.description
//        self.userIds = userIds
//        self.type = type
//        self.chatGroupId = chatGroupId
//    }
//}
//
//// MARK: - Calls DataClass
//
//struct CallResponseDTO: Codable {
//    var type: MessageType?
//    var data: CallDataModel?
//
//    enum CodingKeys: String, CodingKey {
//        case type
//        case data
//    }
//}
//
//struct CallDataModel: Codable {
//    var chatGroupName: String?
//    var chatGroupType: String?
//    var accessToken: String?
//    var chatGroupId: String?
//    var fromUserName: String?
//    var type: TypeEnum
//    var url: String?
//    var userId: Int
//    var twilioResponse: CallDataResponse?
//
//    enum CodingKeys: String, CodingKey {
//        case chatGroupName = "ChatGroupName"
//        case chatGroupType = "ChatGroupType"
//        case accessToken
//        case chatGroupId
//        case fromUserName
//        case type
//        case url
//        case userId
//        case twilioResponse
//    }
//}
//struct CallDataResponse: Codable {
//    var accountSid: String?
//    var audioOnly: Bool?
//    var dateCreated: String?
//    var dateUpdated: String?
//    var enableTurn: Bool?
//    var links: CallDataLinks?
//    var maxConcurrentPublishedTracks: Int?
//    var maxParticipantDuration: Int?
//    var maxParticipants: Int?
//    var mediaRegion: String?
//    var recordParticipantsOnConnect: Bool?
//    var sid: String?
//    var status: String?
//    var statusCallback: String?
//    var statusCallbackMethod: String?
//    var type: String?
//    var uniqueName: String?
//    var url: String?
//    var videoCodecs: [String]?
//
//    enum CodingKeys: String, CodingKey {
//        case accountSid = "account_sid"
//        case audioOnly = "audio_only"
//        case dateCreated = "date_created"
//        case dateUpdated = "date_updated"
//        case enableTurn = "enable_turn"
//        case links
//        case maxConcurrentPublishedTracks = "max_concurrent_published_tracks"
//        case maxParticipantDuration = "max_participant_duration"
//        case maxParticipants = "max_participants"
//        case mediaRegion = "media_region"
//        case recordParticipantsOnConnect = "record_participants_on_connect"
//        case sid
//        case status
//        case statusCallback = "status_callback"
//        case statusCallbackMethod = "status_callback_method"
//        case type
//        case uniqueName = "unique_name"
//        case url
//        case videoCodecs = "video_codecs"
//    }
//}
//
//struct CallDataLinks: Codable {
//    var participants: String?
//    var recordingRules: String?
//    var recordings: String?
//
//    enum CodingKeys: String, CodingKey {
//        case participants
//        case recordingRules = "recording_rules"
//        case recordings
//    }
//}
//
//enum TypeEnum: String, Codable, PersistableEnum {
//    case audio = "audio"
//    case audioCall = "audio_call"
//    case document = "document"
//    case image = "image"
//    case text = "text"
//    case video = "video"
//    case videoCall = "video_call"
//    case vanish = "vanishing"
//
//    func fileExtentions() -> String {
//        switch self {
//        case .image:
//            return ".jpeg"
//        case .video, .videoCall:
//            return ".mp4"
//        case .document:
//            return ".pdf"
//        case .text:
//            return ".txt"
//        case .audioCall:
//            return ".m4a"
//        case .audio:
//            return ".wav"
//        case .vanish:
//            return ""
//        }
//    }
//}
