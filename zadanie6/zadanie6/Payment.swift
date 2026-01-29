import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let cardLast4: String
    let amount: String
    let date: Date
    let transactionID: String

    var maskedCard: String {
        return "**** **** **** \(cardLast4)"
    }

    init(id: UUID = UUID(), fullName: String, cardLast4: String, amount: String, date: Date = Date(), transactionID: String) {
        self.id = id
        self.fullName = fullName
        self.cardLast4 = cardLast4
        self.amount = amount
        self.date = date
        self.transactionID = transactionID
    }
}
