import SwiftUI

struct ContentInputView: View {
    @State private var appearDelayPassed = false
    @StateObject private var viewModel = AffirmationViewModel()
    @State private var currentText = ""
    @State private var isAnyInputFocused: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $viewModel.currentPage) {
                    // Transition Before Identity Modeling
                    
                    TransitionPage(text: """
                    🌱 Ready to get real with yourself?

                    This isn’t about fixing anything — it’s about tuning in. What do you really want? What’s been holding you back? And who are you becoming?

                    These questions are here to help you peel back the noise and connect with what actually matters to you.

                    No pressure. No judgment. Just honesty and curiosity.

                    Take a breath — and let’s dive in.
                    """)
                    .multilineTextAlignment(.center)
                    .tag(0)
                    
                    TransitionPage(text: """
                    If nothing was off-limits, what do I truly want my life to look and feel like?
                    
                    (Clarity on desire)
                    """)
                    .multilineTextAlignment(.center)
                    .tag(1)

                    InputPage(
                        title: "If nothing was off-limits, what do I truly want my life to look and feel like? (Clarity on desire)",
                        items: $viewModel.userInputs.idealSelfCharacteristics,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(2)

                    // Transition Before Assumptions
                    TransitionPage(text: "Your beliefs shape your behavior. Identify the assumptions you'd hold if your success was guaranteed.")
                        .tag(3)

                    InputPage(
                        title: "What am I craving emotionally beneath the surface of my goals? (Freedom? Love? Recognition? Peace?)",
                        items: $viewModel.userInputs.threeMonthGoals,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(4)

                    // Transition Before Subconscious Reprogramming
                    TransitionPage(text: "Growth also means shedding what's outdated. Let's define what needs to be left behind.")
                        .tag(5)

                    InputPage(
                        title: "What’s secretly holding me back from believing I can have it? (Limiting beliefs, self-worth issues, fear of change?)",
                        items: $viewModel.userInputs.yearlyGoals,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(6)

                    // Transition Before Assumed Action
                    TransitionPage(text: "Step into the identity now. If your vision was real today, how would you behave?")
                        .tag(7)

                    InputPage(
                        title: "What part of me benefits from staying the same, even if I say I want change? (Uncovering resistance or subconscious comfort zones)",
                        items: $viewModel.userInputs.fiveYearVision,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(8)

                    // Transition Before 5-Year Vision
                    TransitionPage(text: "Zoom out. Consider what a fully aligned, meaningful life looks like in five years — day-to-day, emotionally, and mentally.")
                        .tag(9)

                    InputPage(
                        title: "What version of me already has this life — and how do they think, feel, act? (Identity shift and embodiment)",
                        items: $viewModel.userInputs.fiveYearVision,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(10)
                    
                    TransitionPage(text: "Zoom out. Consider what a fully aligned, meaningful life looks like in five years — day-to-day, emotionally, and mentally.")
                        .tag(11)

                    InputPage(
                        title: "What would I believe about myself if I were already living this life? (Your affirmation blueprint)",
                        items: $viewModel.userInputs.fiveYearVision,
                        isAnyInputFocused: $isAnyInputFocused
                    )
                    .tag(12)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .onChange(of: viewModel.currentPage) { oldValue, newValue in
                    isAnyInputFocused = false
                }

                if viewModel.currentPage < 9 {
    if appearDelayPassed {
        Button("Continue") {
            Task {
                withAnimation(.easeInOut(duration: 0.6)) {
                    viewModel.currentPage += 1
                }
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s pause
            }
        }
        .buttonStyle(.borderedProminent)
        .scaleEffect(appearDelayPassed ? 1.05 : 1.0)
        .animation(appearDelayPassed ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: appearDelayPassed)
        .padding()
    }

        
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
            .onAppear {
                appearDelayPassed = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    appearDelayPassed = true
                }
            }
        }
        .sheet(isPresented: .constant(!viewModel.affirmations.isEmpty)) {
            AffirmationsView(affirmations: viewModel.affirmations)
        }
    }
}

struct TransitionPage: View {
    let text: String
    @State private var appear = false

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .multilineTextAlignment(.center)
                .font(.title3)
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.95)
                .animation(.easeOut(duration: 0.6), value: appear)
                .padding()
            Spacer()
        }
        .padding()
        .onAppear {
            appear = true
        }
    }
}

struct InputPage: View {
    let title: String
    @Binding var items: [String]
    @Binding var isAnyInputFocused: Bool
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
        .onChange(of: isInputFocused) { oldValue, newValue in
            isAnyInputFocused = newValue
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
