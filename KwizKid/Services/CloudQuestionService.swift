import Foundation
import Combine

// MARK: - Cloud Question Service
class CloudQuestionService: ObservableObject {
    static let shared = CloudQuestionService()
    
    private let baseURL = "https://your-api-domain.com/api"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected = false
    @Published var lastError: String?
    
    private init() {
        checkConnection()
    }
    
    // MARK: - Connection Management
    func checkConnection() {
        guard let url = URL(string: "\(baseURL)/health") else { return }
        
        session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    self?.isConnected = true
                    self?.lastError = nil
                } else {
                    self?.isConnected = false
                    self?.lastError = error?.localizedDescription ?? "Connection failed"
                }
            }
        }.resume()
    }
    
    // MARK: - Question Fetching
    func fetchQuestions(
        category: String? = nil,
        difficulty: Difficulty? = nil,
        ageRange: AgeRange? = nil,
        includeImages: Bool = false,
        limit: Int = 10
    ) async throws -> [Question] {
        
        var components = URLComponents(string: "\(baseURL)/questions")!
        var queryItems: [URLQueryItem] = []
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if let difficulty = difficulty {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        
        if let ageRange = ageRange {
            queryItems.append(URLQueryItem(name: "ageMin", value: String(ageRange.min)))
            queryItems.append(URLQueryItem(name: "ageMax", value: String(ageRange.max)))
        }
        
        if includeImages {
            queryItems.append(URLQueryItem(name: "includeImages", value: "true"))
        }
        
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw CloudError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CloudError.serverError(httpResponse.statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(CloudAPIResponse<[CloudQuestion]>.self, from: data)
        
        guard apiResponse.success else {
            throw CloudError.apiError(apiResponse.error ?? "Unknown API error")
        }
        
        return apiResponse.data.map { cloudQuestion in
            Question(
                id: cloudQuestion.id,
                text: cloudQuestion.text,
                options: cloudQuestion.options,
                correctAnswer: cloudQuestion.correctAnswer,
                explanation: cloudQuestion.explanation,
                difficulty: Difficulty(rawValue: cloudQuestion.difficulty) ?? .easy
            )
        }
    }
    
    // MARK: - Question Statistics
    func fetchQuestionStats() async throws -> QuestionStats {
        guard let url = URL(string: "\(baseURL)/questions/stats") else {
            throw CloudError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw CloudError.serverError(httpResponse.statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(CloudAPIResponse<QuestionStats>.self, from: data)
        
        guard apiResponse.success else {
            throw CloudError.apiError(apiResponse.error ?? "Unknown API error")
        }
        
        return apiResponse.data
    }
    
    // MARK: - Offline Fallback
    func fetchQuestionsWithFallback(
        category: String? = nil,
        difficulty: Difficulty? = nil,
        ageRange: AgeRange? = nil,
        includeImages: Bool = false,
        limit: Int = 10
    ) async -> [Question] {
        
        do {
            // Try cloud first
            let cloudQuestions = try await fetchQuestions(
                category: category,
                difficulty: difficulty,
                ageRange: ageRange,
                includeImages: includeImages,
                limit: limit
            )
            
            if !cloudQuestions.isEmpty {
                return cloudQuestions
            }
        } catch {
            print("⚠️ Cloud fetch failed: \(error)")
        }
        
        // Fallback to local database
        return await fetchFromLocalDatabase(
            category: category,
            difficulty: difficulty,
            ageRange: ageRange,
            includeImages: includeImages,
            limit: limit
        )
    }
    
    private func fetchFromLocalDatabase(
        category: String? = nil,
        difficulty: Difficulty? = nil,
        ageRange: AgeRange? = nil,
        includeImages: Bool = false,
        limit: Int = 10
    ) async -> [Question] {
        
        // Use existing local database as fallback
        let localQuestions = QuestionDatabase.shared.fetchQuestions(
            category: category,
            difficulty: difficulty,
            ageRange: ageRange,
            hasImage: includeImages ? true : nil,
            limit: limit
        )
        
        return localQuestions.map { record in
            Question(
                id: record.id,
                text: record.questionText,
                options: record.options,
                correctAnswer: record.correctAnswer,
                explanation: record.explanation,
                difficulty: Difficulty(rawValue: record.difficulty) ?? .easy
            )
        }
    }
}

// MARK: - Data Models
struct CloudAPIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let error: String?
    let timestamp: String
}

struct CloudQuestion: Codable {
    let id: String
    let text: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let difficulty: String
    let category: String
    let ageMin: Int
    let ageMax: Int
    let hasImage: Bool
    let imagePath: String?
    let tags: [String]
    let createdAt: String
    let updatedAt: String
}

struct QuestionStats: Codable {
    let total: Int
    let active: Int
    let pendingReview: Int
    let approved: Int
    let byCategory: [String: Int]
    let byDifficulty: [String: Int]
    let byAgeRange: [String: Int]
}

// MARK: - Error Types
enum CloudError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}


