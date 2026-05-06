//
//  URLSession+ObjectTask.swift
//  ImageFeed
//
//  Created by AI on 30.03.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .httpStatusCode(code):
            return "NetworkError - код ошибки \(code)"
        case let .urlRequestError(error):
            return "NetworkError - urlRequestError: \(error.localizedDescription)"
        case .urlSessionError:
            return "NetworkError - urlSessionError"
        }
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let networkError = NetworkError.httpStatusCode(statusCode)
                    print("[data(for:)]: \(networkError)")
                    fulfillCompletionOnTheMainThread(.failure(networkError))
                }
            } else if let error {
                let networkError = NetworkError.urlRequestError(error)
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            } else {
                let networkError = NetworkError.urlSessionError
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            }
        }

        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case let .success(data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print(
                        "Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")"
                    )
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }

        return task
    }
}

