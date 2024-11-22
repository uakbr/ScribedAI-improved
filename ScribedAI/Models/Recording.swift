import Foundation

struct Recording: Codable, Identifiable {
    let id: UUID
    let date: Date
    let url: URL
    let text: String
    let language: String
    let duration: TimeInterval
} 