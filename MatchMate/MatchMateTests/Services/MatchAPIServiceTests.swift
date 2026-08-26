//
//  MatchAPIServiceTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import XCTest
@testable import MatchMate

final class MatchAPIServiceTests: XCTestCase {
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.stubError = nil
        session = nil
        super.tearDown()
    }

    func test_fetchProfiles_success() async throws {
        let sampleJSON = """
        {
            "results": [
                {
                    "gender": "male",
                    "name": { "title": "Mr", "first": "John", "last": "Doe" },
                    "location": {
                        "street": { "number": 123, "name": "Main St" },
                        "city": "Sampleville",
                        "state": "CA",
                        "country": "USA",
                        "postcode": 90210,
                        "coordinates": { "latitude": "34.05", "longitude": "-118.25" },
                        "timezone": { "offset": "-08:00", "description": "PST" }
                    },
                    "email": "john.doe@example.com",
                    "login": { "uuid": "test-uuid-123", "username": "johndoe" },
                    "dob": { "date": "1990-05-15T00:00:00.000Z", "age": 34 },
                    "registered": { "date": "2020-01-01T00:00:00.000Z", "age": 4 },
                    "phone": "555-0100",
                    "cell": "555-0199",
                    "picture": {
                        "large": "https://example.com/large.jpg",
                        "medium": "https://example.com/med.jpg",
                        "thumbnail": "https://example.com/thumb.jpg"
                    },
                    "nat": "US"
                }
            ],
            "info": { "seed": "matchmate", "results": 1, "page": 1, "version": "1.4" }
        }
        """.data(using: .utf8)!

        MockURLProtocol.stubResponseData = sampleJSON
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://randomuser.me/api/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let service = RandomUserRemoteDataSource(session: session)
        let profiles = try await service.fetchProfiles(page: 1)

        XCTAssertEqual(profiles.count, 1)
        let profile = profiles[0]
        XCTAssertEqual(profile.id, "test-uuid-123")
        XCTAssertEqual(profile.firstName, "John")
        XCTAssertEqual(profile.lastName, "Doe")
        XCTAssertEqual(profile.age, 34)
        XCTAssertEqual(profile.city, "Sampleville")
        XCTAssertEqual(profile.state, "CA")
        XCTAssertEqual(profile.postcode, "90210")
        XCTAssertEqual(profile.status, .pending)
    }

    func test_fetchProfiles_httpError_throwsInvalidResponse() async {
        MockURLProtocol.stubResponseData = Data()
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://randomuser.me/api/")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let service = RandomUserRemoteDataSource(session: session)
        do {
            _ = try await service.fetchProfiles(page: 1)
            XCTFail("Should have thrown error")
        } catch let error as APIError {
            XCTAssertEqual(error, .invalidResponse(statusCode: 500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_fetchProfiles_corruptedJSON_throwsDecodingError() async {
        MockURLProtocol.stubResponseData = "invalid json data".data(using: .utf8)!
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://randomuser.me/api/")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let service = RandomUserRemoteDataSource(session: session)
        do {
            _ = try await service.fetchProfiles(page: 1)
            XCTFail("Should have thrown decoding error")
        } catch let error as APIError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - MockURLProtocol
final class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponse: HTTPURLResponse?
    static var stubError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = MockURLProtocol.stubResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = MockURLProtocol.stubResponseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
