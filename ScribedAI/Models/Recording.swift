import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let date: Date
    let url: URL
    let text: String
    let language: String
    let duration: TimeInterval
} 