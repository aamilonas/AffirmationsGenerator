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
                    Button("Next") {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.title2)
                .padding()
            
            TextField("Enter a new item", text: $currentText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onSubmit {
                    if !currentText.isEmpty {
                        items.append(currentText)
                        currentText = ""
                    }
                }
            
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }
            }
        }
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