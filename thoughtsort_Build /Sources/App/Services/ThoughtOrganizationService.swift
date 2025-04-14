import Foundation

class ThoughtOrganizationService {
    static let shared = ThoughtOrganizationService()
    private let apiKey = "dummy_key_replace_with_real_claude_api_key"
    private let apiEndpoint = "https://api.anthropic.com/v1/messages"
    
    private init() {}
    
    struct ClaudeResponse: Codable {
        let content: [MessageContent]
        
        struct MessageContent: Codable {
            let text: String
        }
    }
    
    func organizeThoughts(_ input: String) async throws -> [String] {
        let prompt = """
        System: You are an AI assistant specialized in helping users organize their thoughts into actionable tasks. Extract specific, actionable items from the user's input and format them as a list. Focus on clarity, brevity, and actionability. Each task should be concise and begin with a verb when possible. Do not add tasks that aren't implied in the original input. Output should be a JSON array of task strings.
        
        User: \(input)
        """
        
        let body: [String: Any] = [
            "model": "claude-3-sonnet-20240229",
            "max_tokens": 1000,
            "temperature": 0.3,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        guard let url = URL(string: apiEndpoint) else {
            throw ThoughtOrganizationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue("anthropic-version=2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // For testing without actual API call
            #if DEBUG
            return try await mockOrganizeThoughts(input)
            #else
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ThoughtOrganizationError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ThoughtOrganizationError.apiError(statusCode: httpResponse.statusCode)
            }
            
            let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            let tasksString = claudeResponse.content.first?.text ?? "[]"
            
            guard let tasksData = tasksString.data(using: .utf8),
                  let tasks = try? JSONDecoder().decode([String].self, from: tasksData) else {
                throw ThoughtOrganizationError.invalidTaskFormat
            }
            
            return tasks
            #endif
        } catch {
            throw ThoughtOrganizationError.networkError(error)
        }
    }
    
    // Mock function for testing without API key
    private func mockOrganizeThoughts(_ input: String) async throws -> [String] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simple task extraction logic for testing
        let sentences = input.components(separatedBy: [".", "!", "?", "\n"])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return sentences.map { sentence in
            // Add action verb if doesn't start with one
            if sentence.lowercased().range(of: "^(to |)[a-z]+(ed|ing)\\s", options: .regularExpression) == nil {
                return "Complete \(sentence.prefix(1).lowercased() + sentence.dropFirst())"
            }
            return sentence.prefix(1).uppercased() + sentence.dropFirst()
        }
    }
}

enum ThoughtOrganizationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)
    case invalidTaskFormat
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let statusCode):
            return "API error with status code: \(statusCode)"
        case .invalidTaskFormat:
            return "Could not parse tasks from API response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 