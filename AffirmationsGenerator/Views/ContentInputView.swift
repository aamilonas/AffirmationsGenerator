import SwiftUI

struct ContentInputView: View {
    @StateObject private var viewModel = AffirmationViewModel()
    @State private var currentText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $viewModel.currentPage) {
                    InputPage(
                        title: "List some of the characteristics of your IDEAL self.",
                        items: $viewModel.userInputs.idealSelfCharacteristics
                    )
                    .tag(0)
                    
                    InputPage(
                        title: "What are your goals for the following 3 months?",
                        items: $viewModel.userInputs.threeMonthGoals
                    )
                    .tag(1)
                    
                    InputPage(
                        title: "What are some goals you'd like to accomplish this upcoming year?",
                        items: $viewModel.userInputs.yearlyGoals
                    )
                    .tag(2)
                    
                    InputPage(
                        title: "What does your ideal life look like in 5 years?",
                        items: $viewModel.userInputs.fiveYearVision
                    )
                    .tag(3)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                if viewModel.currentPage < 3 {
                    Button("Continue") {
                        withAnimation {
                            viewModel.currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    Button("Generate Affirmations") {
                        Task {
                            await viewModel.generateAffirmations()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationTitle("Personal Affirmations")
        }
        .sheet(isPresented: .constant(!viewModel.affirmations.isEmpty)) {
            AffirmationsView(affirmations: viewModel.affirmations)
        }
    }
}

struct InputPage: View {
    let title: String
    @Binding var items: [String]
    @State private var currentText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.title2)
                .padding()

            HStack {
                TextField("Enter a new item", text: $currentText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)

                Button(action: {
                    addItem()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .disabled(currentText.isEmpty)
            }
            .padding(.horizontal)

            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isInputFocused = true
            }
        }
    }

    private func addItem() {
        guard !currentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        items.append(currentText)
        currentText = ""
        isInputFocused = true // Keeps focus on text field
    }
}


struct AffirmationsView: View {
    let affirmations: [String]
    
    var body: some View {
        NavigationView {
            List(affirmations, id: \.self) { affirmation in
                Text(affirmation)
                    .padding()
            }
            .navigationTitle("Your Affirmations")
        }
    }
} 
