import SwiftUI

// MARK: - KwizKid Theme
struct KwizKidTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primaryBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
        static let primaryPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
        static let primaryGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let primaryOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let primaryPink = Color(red: 1.0, green: 0.4, blue: 0.6)
        static let primaryTeal = Color(red: 0.2, green: 0.8, blue: 0.8)
        
        // Secondary Colors
        static let secondaryBlue = Color(red: 0.1, green: 0.4, blue: 0.8)
        static let secondaryPurple = Color(red: 0.4, green: 0.2, blue: 0.7)
        static let secondaryGreen = Color(red: 0.1, green: 0.6, blue: 0.3)
        static let secondaryOrange = Color(red: 0.8, green: 0.4, blue: 0.1)
        static let secondaryPink = Color(red: 0.8, green: 0.2, blue: 0.4)
        static let secondaryTeal = Color(red: 0.1, green: 0.6, blue: 0.6)
        
        // Neutral Colors
        static let background = Color(red: 0.98, green: 0.98, blue: 1.0)
        static let surface = Color.white
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6)
        
        // Status Colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
        static let info = Color(red: 0.2, green: 0.6, blue: 1.0)
        
        // Gradient Colors
        static let primaryGradient = LinearGradient(
            colors: [primaryBlue, primaryPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let successGradient = LinearGradient(
            colors: [success, Color(red: 0.1, green: 0.7, blue: 0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let warningGradient = LinearGradient(
            colors: [warning, Color(red: 0.8, green: 0.4, blue: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let errorGradient = LinearGradient(
            colors: [error, Color(red: 0.8, green: 0.1, blue: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    struct Typography {
        // Headlines
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .bold, design: .rounded)
        
        // Body Text
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Button Text
        static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let buttonMedium = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let round: CGFloat = 28
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 12,
            x: 0,
            y: 6
        )
        
        static let extraLarge = Shadow(
            color: Color.black.opacity(0.25),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animations
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func kwizKidShadow(_ shadow: Shadow = KwizKidTheme.Shadows.medium) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
    
    func kwizKidCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: KwizKidTheme.CornerRadius.lg)
                    .fill(KwizKidTheme.Colors.surface)
            )
            .kwizKidShadow()
    }
    
    func kwizKidButton(style: ButtonStyle = .primary) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.textColor)
            .frame(maxWidth: .infinity)
            .frame(height: style.height)
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .kwizKidShadow(style.shadow)
    }
}

// MARK: - Button Styles
enum ButtonStyle {
    case primary
    case secondary
    case success
    case warning
    case error
    case outline
    
    var font: Font {
        switch self {
        case .primary, .secondary, .success, .warning, .error:
            return KwizKidTheme.Typography.buttonLarge
        case .outline:
            return KwizKidTheme.Typography.buttonMedium
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .success, .warning, .error:
            return .white
        case .secondary:
            return KwizKidTheme.Colors.textPrimary
        case .outline:
            return KwizKidTheme.Colors.primaryBlue
        }
    }
    
    var background: some View {
        switch self {
        case .primary:
            return AnyView(KwizKidTheme.Colors.primaryGradient)
        case .secondary:
            return AnyView(Color(KwizKidTheme.Colors.surface))
        case .success:
            return AnyView(KwizKidTheme.Colors.successGradient)
        case .warning:
            return AnyView(KwizKidTheme.Colors.warningGradient)
        case .error:
            return AnyView(KwizKidTheme.Colors.errorGradient)
        case .outline:
            return AnyView(Color.clear)
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .primary, .secondary, .success, .warning, .error:
            return KwizKidTheme.CornerRadius.round
        case .outline:
            return KwizKidTheme.CornerRadius.lg
        }
    }
    
    var height: CGFloat {
        switch self {
        case .primary, .secondary, .success, .warning, .error:
            return 56
        case .outline:
            return 48
        }
    }
    
    var shadow: Shadow {
        switch self {
        case .primary, .success, .warning, .error:
            return KwizKidTheme.Shadows.medium
        case .secondary:
            return KwizKidTheme.Shadows.small
        case .outline:
            return Shadow(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
}

// MARK: - Category Colors
extension KwizKidTheme {
    static func colorForCategory(_ category: QuizCategory) -> Color {
        switch category.color {
        case "blue":
            return Colors.primaryBlue
        case "green":
            return Colors.primaryGreen
        case "orange":
            return Colors.primaryOrange
        case "purple":
            return Colors.primaryPurple
        case "teal":
            return Colors.primaryTeal
        case "pink":
            return Colors.primaryPink
        default:
            return Colors.primaryBlue
        }
    }
    
    static func gradientForCategory(_ category: QuizCategory) -> LinearGradient {
        let baseColor = colorForCategory(category)
        return LinearGradient(
            colors: [baseColor, baseColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
