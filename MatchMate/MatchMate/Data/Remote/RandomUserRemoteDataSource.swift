//
//  RandomUserRemoteDataSource.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public protocol RandomUserRemoteDataSourceProtocol: Sendable {
    func fetchProfiles(page: Int, resultsPerPage: Int, seed: String) async throws -> [Profile]
}

extension RandomUserRemoteDataSourceProtocol {
    public func fetchProfiles(page: Int) async throws -> [Profile] {
        try await fetchProfiles(page: page, resultsPerPage: 10, seed: "matchmate")
    }
}

public final class RandomUserRemoteDataSource: RandomUserRemoteDataSourceProtocol {
    private let baseURL: String
    private let session: URLSession

    public init(
        baseURL: String = "https://randomuser.me/api/",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchProfiles(
        page: Int,
        resultsPerPage: Int = 10,
        seed: String = "matchmate"
    ) async throws -> [Profile] {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "results", value: String(resultsPerPage)),
            URLQueryItem(name: "seed", value: seed)
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw APIError.networkError(urlError.localizedDescription)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(RandomUserResponseDTO.self, from: data)
            return decodedResponse.results.map { $0.toDomain(pageIndex: page) }
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}
