import Foundation
import FirebaseAuth

enum FirebaseError: LocalizedError {
    case authError(AuthErrorCode)
    case networkError
    case unknown
    
    init(error: Error) {
        if let authError = error as? AuthErrorCode {
            self = .authError(authError)
        } else if (error as NSError).domain == NSURLErrorDomain {
            self = .networkError
        } else {
            self = .unknown
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .authError(let error):
            switch error.code {
            case .invalidEmail:
                return "Please enter a valid email address"
            case .weakPassword:
                return "Your password must be at least 6 characters long"
            case .emailAlreadyInUse:
                return "An account with this email already exists"
            case .wrongPassword:
                return "Incorrect password"
            case .userNotFound:
                return "No account found with this email"
            case .networkError:
                return "Please check your internet connection"
            default:
                return "An error occurred. Please try again"
            }
        case .networkError:
            return "Please check your internet connection"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
} 