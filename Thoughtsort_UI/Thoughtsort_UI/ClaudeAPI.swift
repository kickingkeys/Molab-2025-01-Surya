import Foundation

struct ClaudeAPI {
    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    enum ClaudeError: Error {
        case invalidAPIKey
        case networkError(Error)
        case apiError(String)
        case parsingError(String)
    }

    static func generateTasks(from userInput: String, completion: @escaping (Result<[String], ClaudeError>) -> Void) {
        // ✅ Get the API key at request time
        guard let apiKey = KeychainManager.getAPIKey(), !apiKey.isEmpty else {
            print("❌ Claude API key is missing or empty.")
            completion(.failure(.invalidAPIKey))
            return
        }

        print("✅ Claude API key loaded: \(apiKey)")

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let promptText = """
        Turn the following into a to-do list. Respond only with a JSON object containing an array of tasks.
        Format: { "tasks": ["Task 1", "Task 2", "Task 3"] }

        \(userInput)
        """

        let body: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 300,
            "temperature": 0.5,
            "system": "You are a helpful assistant that converts messy user thoughts into structured to-do lists. Always return valid JSON.",
            "messages": [
                [
                    "role": "user",
                    "content": promptText
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(.networkError(error)))
            return
        }

        // ✅ Log request headers for debugging
        if let headers = request.allHTTPHeaderFields {
            print("📤 Headers:")
            headers.forEach { print("  \($0.key): \($0.value)") }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.parsingError("No data received.")))
                return
            }

            // 🟡 Print raw Claude response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟡 Claude Raw Response:\n\(jsonString)")
            }

            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let apiError = responseJSON["error"] as? [String: Any],
                       let message = apiError["message"] as? String {
                        completion(.failure(.apiError(message)))
                        return
                    }

                    if let contentArray = responseJSON["content"] as? [[String: Any]],
                       let firstContent = contentArray.first,
                       let text = firstContent["text"] as? String,
                       let jsonData = text.data(using: .utf8),
                       let taskDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: [String]],
                       let tasks = taskDict["tasks"] {
                        completion(.success(tasks))
                        return
                    }
                }

                completion(.failure(.parsingError("Could not extract valid task list from Claude response.")))
            } catch {
                completion(.failure(.parsingError("JSON parsing failed: \(error.localizedDescription)")))
            }
        }.resume()
    }
}
