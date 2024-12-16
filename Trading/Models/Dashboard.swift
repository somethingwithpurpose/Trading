import Foundation
import SwiftData

@Model
final class Dashboard {
    var name: String
    var isActive: Bool
    var createdAt: Date
    
    init(name: String, isActive: Bool = false) {
        self.name = name
        self.isActive = isActive
        self.createdAt = Date()
    }
} 