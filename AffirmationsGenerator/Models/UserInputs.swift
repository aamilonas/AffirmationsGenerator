import Foundation

struct UserInputs: Codable {
    var idealSelfCharacteristics: [String]
    var threeMonthGoals: [String]
    var yearlyGoals: [String]
    var fiveYearVision: [String]
    
    init() {
        self.idealSelfCharacteristics = []
        self.threeMonthGoals = []
        self.yearlyGoals = []
        self.fiveYearVision = []
    }
} 