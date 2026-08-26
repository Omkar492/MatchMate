//
//  UpdateMatchStatusUseCase.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public protocol UpdateMatchStatusUseCase: Sendable {
    func execute(id: String, status: MatchStatus) async throws -> Profile
}

public struct DefaultUpdateMatchStatusUseCase: UpdateMatchStatusUseCase {
    private let repository: ProfileRepository

    public init(repository: ProfileRepository) {
        self.repository = repository
    }

    public func execute(id: String, status: MatchStatus) async throws -> Profile {
        try await repository.updateStatus(id: id, status: status)
    }
}
