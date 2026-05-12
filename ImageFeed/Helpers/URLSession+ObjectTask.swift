//
//  URLSession+ObjectTask.swift
//  ImageFeed
//
//  Created by AI on 30.03.2026.
//

import Foundation

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
            // Если пришла ошибка уровня URLSession — сразу пробрасываем
            if let error {
                let networkError = NetworkError.urlRequestError(error)
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
                return
            }

            // Проверяем, что есть HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                let networkError = NetworkError.urlSessionError
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
                return
            }

            // Проверяем, что есть данные
            guard let data else {
                let networkError = NetworkError.urlSessionError
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
                return
            }

            // Проверяем статус-код
            guard (200..<300).contains(httpResponse.statusCode) else {
                let networkError = NetworkError.httpStatusCode(httpResponse.statusCode)
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
                return
            }

            // Успех
            fulfillCompletionOnTheMainThread(.success(data))
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
