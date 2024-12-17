import Foundation
import SwiftData

@Model
class Dashboard {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var trades: [Trade]
    var createdAt: Date
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.trades = []
        self.createdAt = Date()
    }
} 