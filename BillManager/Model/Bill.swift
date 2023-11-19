// BillManager

import Foundation
import UserNotifications

struct Bill: Codable {
    let id: UUID
    var amount: Double?
    var dueDate: Date?
    var paidDate: Date?
    var payee: String?
    var remindDate: Date?
    
    // Because each bill can have its own reminder, you need to track which notifications have been created and to which bill they belong.
    var notificationID: String?
    
    init(id: UUID = UUID()) {
        self.id = id
    }
}

extension Bill: Hashable {
//    static func ==(_ lhs: Bill, _ rhs: Bill) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
    
    
    
}
