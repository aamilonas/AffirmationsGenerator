import Foundation
import OpenAIKit

class AffirmationViewModel: ObservableObject {
    @Published var userInputs = UserInputs()
    @Published var currentPage = 0
    @Published var affirmations: [String] = []
    @Published var isLoading = false

    private var openAI: OpenAI?

    init() {
        guard let apiKey = loadAPIKey() else {
            print("❌ API Key not found")
            return
        }

        let config = Configuration(organizationId: "", apiKey: apiKey)
        openAI = OpenAI(config)
    }

    func generateAffirmations() async {
        guard let openAI = openAI else {
            print("OpenAI client not initialized.")
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        let prompt = """
        Based on the following information about the user:

        Ideal Self Characteristics:
        \(userInputs.idealSelfCharacteristics.joined(separator: "\n"))

        3-Month Goals:
        \(userInputs.threeMonthGoals.joined(separator: "\n"))

        Yearly Goals:
        \(userInputs.yearlyGoals.joined(separator: "\n"))

        5-Year Vision:
        \(userInputs.fiveYearVision.joined(separator: "\n"))

        Please generate 10–15 positive, personalized affirmations that will help the user achieve their goals and embody their ideal self. Make the affirmations specific, actionable, and emotionally resonant.
        """

        do {
            let chatParameters = ChatParameters(
                model: .gpt4,
                messages: [
                    ChatMessage(role: .system, content: "You are a helpful assistant."),
                    ChatMessage(role: .user, content: prompt)
                ]
            )

            let result = try await openAI.generateChatCompletion(parameters: chatParameters)

            if let content = result.choices.first?.message?.content {
                let lines = content
                    .components(separatedBy: CharacterSet.newlines)
                    .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.lowercased().contains("affirmation") }

                DispatchQueue.main.async {
                    self.affirmations = lines.map { line in
                        if let range = line.range(of: #"^\d+[\).\s]+"#, options: String.CompareOptions.regularExpression) {
                            return line.replacingCharacters(in: range, with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                        }
                        return line
                    }
                }
            }
        } catch {
            print("❌ Error generating affirmations: \(error)")
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

func loadAPIKey() -> String? {
    guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path),
          let key = dict["OpenAI_API_Key"] as? String else {
        return nil
    }
    return key
}
