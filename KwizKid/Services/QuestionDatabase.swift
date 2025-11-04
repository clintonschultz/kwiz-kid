import Foundation
import SQLite3

// MARK: - Question Database Models
struct QuestionRecord {
    let id: String
    let category: String
    let difficulty: String
    let ageMin: Int
    let ageMax: Int
    let questionText: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let hasImage: Bool
    let imagePath: String?
    let imagePrompt: String?
    let tags: [String]
    let createdAt: Date
    let isActive: Bool
    let usageCount: Int
}

struct CategoryRecord {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let isActive: Bool
    let createdAt: Date
}

// MARK: - SQLite Database Manager
class QuestionDatabase: ObservableObject {
    static let shared = QuestionDatabase()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    @Published var isConnected = false
    @Published var totalQuestions: Int = 0
    @Published var categories: [CategoryRecord] = []
    
    private init() {
        // Create database in Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.dbPath = documentsPath.appendingPathComponent("KwizKidQuestions.db").path
        
        print("📁 Database path: \(dbPath)")
        initializeDatabase()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Initialization
    private func initializeDatabase() {
        print("🔧 Attempting to open database at: \(dbPath)")
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ Database opened successfully")
            createTables()
            isConnected = true
            updateStatistics()
        } else {
            print("❌ Failed to open database: \(String(cString: sqlite3_errmsg(db)))")
            isConnected = false
        }
    }
    
    private func createTables() {
        // Create questions table
        let createQuestionsTable = """
        CREATE TABLE IF NOT EXISTS questions (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            age_min INTEGER NOT NULL,
            age_max INTEGER NOT NULL,
            question_text TEXT NOT NULL,
            options TEXT NOT NULL, -- JSON array
            correct_answer INTEGER NOT NULL,
            explanation TEXT NOT NULL,
            has_image INTEGER DEFAULT 0,
            image_path TEXT,
            image_prompt TEXT,
            tags TEXT, -- JSON array
            created_at TEXT NOT NULL,
            is_active INTEGER DEFAULT 1,
            usage_count INTEGER DEFAULT 0
        );
        """
        
        // Create categories table
        let createCategoriesTable = """
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            icon_name TEXT NOT NULL,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL
        );
        """
        
        executeSQL(createQuestionsTable)
        executeSQL(createCategoriesTable)
        
        // Insert default categories if they don't exist
        insertDefaultCategories()
        
        // Update statistics
        updateStatistics()
    }
    
    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ SQL executed successfully")
            } else {
                print("❌ SQL execution failed: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("❌ SQL preparation failed: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Default Data
    private func insertDefaultCategories() {
        let defaultCategories = [
            ("math", "Mathematics", "Numbers, equations, and problem solving", "number.circle.fill"),
            ("science", "Science", "Nature, experiments, and discoveries", "atom"),
            ("reading", "Reading", "Language, stories, and comprehension", "book.fill"),
            ("history", "History", "Past events and historical figures", "clock.fill"),
            ("geography", "Geography", "Countries, capitals, and world knowledge", "globe"),
            ("art", "Art", "Creativity, colors, and artistic expression", "paintbrush.fill")
        ]
        
        for (id, name, description, iconName) in defaultCategories {
            let insertSQL = """
            INSERT OR IGNORE INTO categories (id, name, description, icon_name, created_at)
            VALUES ('\(id)', '\(name)', '\(description)', '\(iconName)', '\(ISO8601DateFormatter().string(from: Date()))');
            """
            executeSQL(insertSQL)
        }
    }
    
    // MARK: - Question Operations
    func fetchQuestions(category: String? = nil, difficulty: Difficulty? = nil, ageRange: AgeRange? = nil, hasImage: Bool? = nil, limit: Int = 50) -> [QuestionRecord] {
        print("🔍 fetchQuestions called with:")
        print("  - Category: \(category ?? "nil")")
        print("  - Difficulty: \(difficulty?.rawValue ?? "nil")")
        print("  - Age Range: \(ageRange != nil ? "\(ageRange!.min)-\(ageRange!.max)" : "nil")")
        print("  - Has Image: \(hasImage?.description ?? "nil")")
        print("  - Limit: \(limit)")
        
        guard isConnected else {
            print("❌ Database not connected")
            return []
        }
        
        // First, let's check if there are ANY questions in the database
        let countSQL = "SELECT COUNT(*) FROM questions"
        var countStatement: OpaquePointer?
        var totalCount = 0
        
        if sqlite3_prepare_v2(db, countSQL, -1, &countStatement, nil) == SQLITE_OK {
            if sqlite3_step(countStatement) == SQLITE_ROW {
                totalCount = Int(sqlite3_column_int(countStatement, 0))
            }
        }
        sqlite3_finalize(countStatement)
        
        print("🔍 Total questions in database: \(totalCount)")
        
        if totalCount == 0 {
            print("⚠️ No questions in database at all!")
            return []
        }
        
        // Check how many are active
        let activeCountSQL = "SELECT COUNT(*) FROM questions WHERE is_active = 1"
        var activeCountStatement: OpaquePointer?
        var activeCount = 0
        
        if sqlite3_prepare_v2(db, activeCountSQL, -1, &activeCountStatement, nil) == SQLITE_OK {
            if sqlite3_step(activeCountStatement) == SQLITE_ROW {
                activeCount = Int(sqlite3_column_int(activeCountStatement, 0))
            }
        }
        sqlite3_finalize(activeCountStatement)
        
        print("🔍 Active questions in database: \(activeCount)")
        
        if activeCount == 0 {
            print("⚠️ All questions are inactive! Checking first few questions...")
            let checkSQL = "SELECT id, is_active, question_text FROM questions LIMIT 5"
            var checkStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, checkSQL, -1, &checkStatement, nil) == SQLITE_OK {
                while sqlite3_step(checkStatement) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text(checkStatement, 0))
                    let isActive = sqlite3_column_int(checkStatement, 1)
                    let questionText = String(cString: sqlite3_column_text(checkStatement, 2))
                    print("  - ID: \(id), Active: \(isActive), Text: \(questionText)")
                }
            }
            sqlite3_finalize(checkStatement)
        }
        
        var sql = "SELECT * FROM questions WHERE is_active = 1"
        var parameters: [String] = []
        
        if let category = category {
            sql += " AND category = ?"
            parameters.append(category)
        }
        
        if let difficulty = difficulty {
            sql += " AND difficulty = ?"
            parameters.append(difficulty.rawValue)
        }
        
        if let ageRange = ageRange {
            sql += " AND age_min <= ? AND age_max >= ?"
            parameters.append(String(ageRange.max))
            parameters.append(String(ageRange.min))
        }
        
        if let hasImage = hasImage {
            sql += " AND has_image = ?"
            parameters.append(hasImage ? "1" : "0")
        }
        
        sql += " ORDER BY RANDOM() LIMIT ?"
        parameters.append(String(limit))
        
        print("🔍 Database Query: \(sql)")
        print("🔍 Parameters: \(parameters)")
        
        let results = executeQuery(sql, parameters: parameters)
        print("🔍 Query returned \(results.count) questions")
        
        return results
    }
    
    func insertQuestion(_ question: QuestionRecord) {
        print("💾 Attempting to insert question with ID: \(question.id)")
        
        let optionsJSON = try! JSONSerialization.data(withJSONObject: question.options)
        let optionsString = String(data: optionsJSON, encoding: .utf8)!
        
        let tagsJSON = try! JSONSerialization.data(withJSONObject: question.tags)
        let tagsString = String(data: tagsJSON, encoding: .utf8)!
        
        let dateFormatter = ISO8601DateFormatter()
        let createdAtString = dateFormatter.string(from: question.createdAt)
        
        let sql = """
        INSERT INTO questions (
            id, category, difficulty, age_min, age_max, question_text, options,
            correct_answer, explanation, has_image, image_path, image_prompt,
            tags, created_at, is_active, usage_count
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, question.id, -1, nil)
            sqlite3_bind_text(statement, 2, question.category, -1, nil)
            sqlite3_bind_text(statement, 3, question.difficulty, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(question.ageMin))
            sqlite3_bind_int(statement, 5, Int32(question.ageMax))
            sqlite3_bind_text(statement, 6, question.questionText, -1, nil)
            sqlite3_bind_text(statement, 7, optionsString, -1, nil)
            sqlite3_bind_int(statement, 8, Int32(question.correctAnswer))
            sqlite3_bind_text(statement, 9, question.explanation, -1, nil)
            sqlite3_bind_int(statement, 10, question.hasImage ? 1 : 0)
            sqlite3_bind_text(statement, 11, question.imagePath, -1, nil)
            sqlite3_bind_text(statement, 12, question.imagePrompt, -1, nil)
            sqlite3_bind_text(statement, 13, tagsString, -1, nil)
            sqlite3_bind_text(statement, 14, createdAtString, -1, nil)
            sqlite3_bind_int(statement, 15, question.isActive ? 1 : 0)
            sqlite3_bind_int(statement, 16, Int32(question.usageCount))
            
            let result = sqlite3_step(statement)
            if result == SQLITE_DONE {
                print("✅ Question inserted successfully: \(question.questionText)")
            } else {
                print("❌ Failed to insert question: \(String(cString: sqlite3_errmsg(db)))")
                print("❌ SQLite result code: \(result)")
            }
        } else {
            print("❌ Failed to prepare statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
    }
    
    func updateQuestionUsage(questionId: String) {
        let sql = "UPDATE questions SET usage_count = usage_count + 1 WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, questionId, -1, nil)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Category Operations
    func fetchCategories() -> [CategoryRecord] {
        let sql = "SELECT * FROM categories WHERE is_active = 1 ORDER BY name"
        return executeCategoryQuery(sql)
    }
    
    func insertCategory(_ category: CategoryRecord) {
        let dateFormatter = ISO8601DateFormatter()
        let createdAtString = dateFormatter.string(from: category.createdAt)
        
        let sql = """
        INSERT INTO categories (id, name, description, icon_name, is_active, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, category.id, -1, nil)
            sqlite3_bind_text(statement, 2, category.name, -1, nil)
            sqlite3_bind_text(statement, 3, category.description, -1, nil)
            sqlite3_bind_text(statement, 4, category.iconName, -1, nil)
            sqlite3_bind_int(statement, 5, category.isActive ? 1 : 0)
            sqlite3_bind_text(statement, 6, createdAtString, -1, nil)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Statistics
    func updateStatistics() {
        // Update total questions count
        let countSQL = "SELECT COUNT(*) FROM questions WHERE is_active = 1"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, countSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                totalQuestions = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        // Update categories
        categories = fetchCategories()
    }
    
    func getQuestionCount(by category: String? = nil) -> Int {
        var sql = "SELECT COUNT(*) FROM questions WHERE is_active = 1"
        if let category = category {
            sql += " AND category = ?"
        }
        
        var statement: OpaquePointer?
        var count = 0
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if let category = category {
                sqlite3_bind_text(statement, 1, category, -1, nil)
            }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return count
    }
    
    func activateAllQuestions() {
        let updateSQL = "UPDATE questions SET is_active = 1;"
        executeSQL(updateSQL)
        print("✅ All questions activated.")
        updateStatistics()
    }
    
    // MARK: - Helper Methods
    private func executeQuery(_ sql: String, parameters: [String] = []) -> [QuestionRecord] {
        var statement: OpaquePointer?
        var questions: [QuestionRecord] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            // Bind parameters
            for (index, parameter) in parameters.enumerated() {
                sqlite3_bind_text(statement, Int32(index + 1), parameter, -1, nil)
            }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let category = String(cString: sqlite3_column_text(statement, 1))
                let difficulty = String(cString: sqlite3_column_text(statement, 2))
                let ageMin = Int(sqlite3_column_int(statement, 3))
                let ageMax = Int(sqlite3_column_int(statement, 4))
                let questionText = String(cString: sqlite3_column_text(statement, 5))
                let optionsString = String(cString: sqlite3_column_text(statement, 6))
                let correctAnswer = Int(sqlite3_column_int(statement, 7))
                let explanation = String(cString: sqlite3_column_text(statement, 8))
                let hasImage = sqlite3_column_int(statement, 9) == 1
                let imagePath = sqlite3_column_text(statement, 10) != nil ? String(cString: sqlite3_column_text(statement, 10)) : nil
                let imagePrompt = sqlite3_column_text(statement, 11) != nil ? String(cString: sqlite3_column_text(statement, 11)) : nil
                let tagsString = sqlite3_column_text(statement, 12) != nil ? String(cString: sqlite3_column_text(statement, 12)) : "[]"
                let createdAtString = String(cString: sqlite3_column_text(statement, 13))
                let isActive = sqlite3_column_int(statement, 14) == 1
                let usageCount = Int(sqlite3_column_int(statement, 15))
                
                // Parse JSON arrays
                let options = (try? JSONSerialization.jsonObject(with: optionsString.data(using: .utf8)!, options: [])) as? [String] ?? []
                let tags = (try? JSONSerialization.jsonObject(with: tagsString.data(using: .utf8)!, options: [])) as? [String] ?? []
                
                let dateFormatter = ISO8601DateFormatter()
                let createdAt = dateFormatter.date(from: createdAtString) ?? Date()
                
                let question = QuestionRecord(
                    id: id,
                    category: category,
                    difficulty: difficulty,
                    ageMin: ageMin,
                    ageMax: ageMax,
                    questionText: questionText,
                    options: options,
                    correctAnswer: correctAnswer,
                    explanation: explanation,
                    hasImage: hasImage,
                    imagePath: imagePath,
                    imagePrompt: imagePrompt,
                    tags: tags,
                    createdAt: createdAt,
                    isActive: isActive,
                    usageCount: usageCount
                )
                
                questions.append(question)
            }
        }
        sqlite3_finalize(statement)
        return questions
    }
    
    private func executeCategoryQuery(_ sql: String) -> [CategoryRecord] {
        var statement: OpaquePointer?
        var categories: [CategoryRecord] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let description = String(cString: sqlite3_column_text(statement, 2))
                let iconName = String(cString: sqlite3_column_text(statement, 3))
                let isActive = sqlite3_column_int(statement, 4) == 1
                let createdAtString = String(cString: sqlite3_column_text(statement, 5))
                
                let dateFormatter = ISO8601DateFormatter()
                let createdAt = dateFormatter.date(from: createdAtString) ?? Date()
                
                let category = CategoryRecord(
                    id: id,
                    name: name,
                    description: description,
                    iconName: iconName,
                    isActive: isActive,
                    createdAt: createdAt
                )
                
                categories.append(category)
            }
        }
        sqlite3_finalize(statement)
        return categories
    }
    
    private func closeDatabase() {
        if sqlite3_close(db) == SQLITE_OK {
            print("✅ Database closed successfully")
        } else {
            print("❌ Failed to close database")
        }
    }
}
