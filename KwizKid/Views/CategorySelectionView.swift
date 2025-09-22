import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedCategory: QuizCategory?
    
    private let categories = [
        QuizCategory(
            id: "math",
            name: "Math Magic",
            description: "Numbers, shapes, and calculations",
            icon: "plus.circle.fill",
            color: "blue",
            difficulty: .easy,
            ageRange: AgeRange(min: 5, max: 12)
        ),
        QuizCategory(
            id: "science",
            name: "Science Fun",
            description: "Discover the wonders of science",
            icon: "atom",
            color: "green",
            difficulty: .easy,
            ageRange: AgeRange(min: 6, max: 12)
        ),
        QuizCategory(
            id: "reading",
            name: "Reading Adventure",
            description: "Words, stories, and language",
            icon: "book.fill",
            color: "orange",
            difficulty: .easy,
            ageRange: AgeRange(min: 4, max: 10)
        ),
        QuizCategory(
            id: "history",
            name: "Time Travel",
            description: "Explore the past and present",
            icon: "clock.fill",
            color: "purple",
            difficulty: .medium,
            ageRange: AgeRange(min: 8, max: 14)
        ),
        QuizCategory(
            id: "geography",
            name: "World Explorer",
            description: "Countries, capitals, and cultures",
            icon: "globe",
            color: "teal",
            difficulty: .medium,
            ageRange: AgeRange(min: 7, max: 12)
        ),
        QuizCategory(
            id: "art",
            name: "Creative Corner",
            description: "Colors, artists, and creativity",
            icon: "paintbrush.fill",
            color: "pink",
            difficulty: .easy,
            ageRange: AgeRange(min: 5, max: 12)
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Choose Your Adventure!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Pick a subject you'd like to learn about")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    
                    // Categories Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(categories) { category in
                            CategoryCard(
                                category: category,
                                isSelected: selectedCategory?.id == category.id
                            ) {
                                selectedCategory = category
                                store.dispatch(.selectCategory(category))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Start Quiz Button
                    if let selectedCategory = selectedCategory {
                        Button(action: {
                            store.dispatch(.startQuiz(selectedCategory))
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start \(selectedCategory.name) Quiz")
                            }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.dispatch(.loadCategories)
        }
    }
}

struct CategoryCard: View {
    let category: QuizCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    private var categoryColor: Color {
        switch category.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "teal": return .teal
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(categoryColor)
                }
                
                // Content
                VStack(spacing: 8) {
                    Text(category.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(category.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Age Range
                    Text("Ages \(category.ageRange.min)-\(category.ageRange.max)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200) // Flexible width, fixed height
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? categoryColor.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? categoryColor : Color.clear,
                        lineWidth: isSelected ? 3 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CategorySelectionView()
        .environmentObject(AppStore())
}
