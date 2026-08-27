//
//  RandomUserDTOTests.swift
//  MatchMateTests
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import XCTest
@testable import MatchMate

final class RandomUserDTOTests: XCTestCase {
    func test_decoding_flexiblePostcode_intAndString() throws {
        let jsonIntPostcode = """
        { "postcode": 40291 }
        """.data(using: .utf8)!

        let jsonStringPostcode = """
        { "postcode": "AB12 3CD" }
        """.data(using: .utf8)!

        struct TestPostcodeContainer: Decodable {
            let postcode: FlexibleString
        }

        let decodedInt = try JSONDecoder().decode(TestPostcodeContainer.self, from: jsonIntPostcode)
        XCTAssertEqual(decodedInt.postcode.value, "40291")

        let decodedString = try JSONDecoder().decode(TestPostcodeContainer.self, from: jsonStringPostcode)
        XCTAssertEqual(decodedString.postcode.value, "AB12 3CD")
    }

    func test_dateInfoDTO_parsedDate_withAndWithoutFractionalSeconds() {
        let dateWithFractional = DateInfoDTO(date: "1992-11-15T17:18:48.276Z", age: 33)
        XCTAssertNotNil(dateWithFractional.parsedDate)

        let standardDate = DateInfoDTO(date: "2020-01-01T00:00:00Z", age: 26)
        XCTAssertNotNil(standardDate.parsedDate)

        let invalidDate = DateInfoDTO(date: "invalid-date", age: 0)
        XCTAssertNil(invalidDate.parsedDate)
    }

    func test_decoding_userDTO_and_toDomainMapping() throws {
        let jsonString = """
        {
            "gender": "female",
            "name": {
                "title": "Miss",
                "first": "Nalan",
                "last": "Akgül"
            },
            "location": {
                "street": {
                    "number": 380,
                    "name": "Anafartalar Cd"
                },
                "city": "Van",
                "state": "Hakkâri",
                "country": "Turkey",
                "postcode": 40291,
                "coordinates": {
                    "latitude": "71.7403",
                    "longitude": "160.6450"
                }
            },
            "email": "nalan.akgul@example.com",
            "login": {
                "uuid": "b14f01c5-57dc-4023-be26-fbda38e1fc2d"
            },
            "dob": {
                "date": "1992-11-15T17:18:48.276Z",
                "age": 33
            },
            "registered": {
                "date": "2015-01-19T08:46:16.565Z",
                "age": 11
            },
            "phone": "(590)-971-8437",
            "cell": "(121)-414-5321",
            "picture": {
                "large": "https://randomuser.me/api/portraits/women/21.jpg",
                "medium": "https://randomuser.me/api/portraits/med/women/21.jpg",
                "thumbnail": "https://randomuser.me/api/portraits/thumb/women/21.jpg"
            },
            "nat": "TR"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let dto = try JSONDecoder().decode(UserDTO.self, from: jsonData)
        let profile = dto.toDomain(pageIndex: 1)

        XCTAssertEqual(profile.id, "b14f01c5-57dc-4023-be26-fbda38e1fc2d")
        XCTAssertEqual(profile.fullName, "Nalan Akgül")
        XCTAssertEqual(profile.age, 33)
        XCTAssertEqual(profile.gender, "female")
        XCTAssertEqual(profile.city, "Van")
        XCTAssertEqual(profile.state, "Hakkâri")
        XCTAssertEqual(profile.country, "Turkey")
        XCTAssertEqual(profile.email, "nalan.akgul@example.com")
        XCTAssertEqual(profile.phone, "(590)-971-8437")
        XCTAssertEqual(profile.cell, "(121)-414-5321")
        XCTAssertEqual(profile.nationality, "TR")
        XCTAssertEqual(profile.status, MatchStatus.pending)
        XCTAssertEqual(profile.pageIndex, 1)
        XCTAssertEqual(profile.largePhotoURL?.absoluteString, "https://randomuser.me/api/portraits/women/21.jpg")
    }
}
