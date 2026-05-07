import Foundation

public enum Scope: String, Codable, Sendable {
    case project
    case user
    case managed
    case plugin
    case unknown
}
