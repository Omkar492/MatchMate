//
//  MatchProfile.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public typealias Profile = MatchProfile

public struct MatchProfile: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let firstName: String
    public let lastName: String
    public let gender: String
    public let age: Int
    public let dob: Date?
    public let email: String
    public let phone: String
    public let cell: String
    public let streetNumber: String
    public let streetName: String
    public let city: String
    public let state: String
    public let country: String
    public let postcode: String
    public let latitude: String
    public let longitude: String
    public let largePhotoURL: URL?
    public let mediumPhotoURL: URL?
    public let thumbnailPhotoURL: URL?
    public let nationality: String
    public let registeredDate: Date
    public var status: MatchStatus
    public var pageIndex: Int

    public var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Unknown" : name
    }

    public var fullAddress: String {
        var parts: [String] = []
        let street = "\(streetNumber) \(streetName)".trimmingCharacters(in: .whitespacesAndNewlines)
        if !street.isEmpty { parts.append(street) }
        if !city.isEmpty { parts.append(city) }
        if !state.isEmpty { parts.append(state) }
        if !country.isEmpty { parts.append(country) }
        return parts.joined(separator: ", ")
    }

    public var locationShort: String {
        var parts: [String] = []
        if !city.isEmpty { parts.append(city) }
        if !state.isEmpty { parts.append(state) }
        if parts.isEmpty && !country.isEmpty { parts.append(country) }
        return parts.joined(separator: ", ")
    }

    public init(
        id: String,
        title: String = "",
        firstName: String,
        lastName: String,
        gender: String = "",
        age: Int,
        dob: Date? = nil,
        email: String = "",
        phone: String = "",
        cell: String = "",
        streetNumber: String = "",
        streetName: String = "",
        city: String = "",
        state: String = "",
        country: String = "",
        postcode: String = "",
        latitude: String = "",
        longitude: String = "",
        largePhotoURL: URL? = nil,
        mediumPhotoURL: URL? = nil,
        thumbnailPhotoURL: URL? = nil,
        nationality: String = "",
        registeredDate: Date = Date(),
        status: MatchStatus = .pending,
        pageIndex: Int = 1
    ) {
        self.id = id
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.age = age
        self.dob = dob
        self.email = email
        self.phone = phone
        self.cell = cell
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.city = city
        self.state = state
        self.country = country
        self.postcode = postcode
        self.latitude = latitude
        self.longitude = longitude
        self.largePhotoURL = largePhotoURL
        self.mediumPhotoURL = mediumPhotoURL
        self.thumbnailPhotoURL = thumbnailPhotoURL
        self.nationality = nationality
        self.registeredDate = registeredDate
        self.status = status
        self.pageIndex = pageIndex
    }
}

// Sample mock data for Previews and Testing
extension MatchProfile {
    public static let mock1 = MatchProfile(
        id: "mock-1",
        title: "Miss",
        firstName: "Nalan",
        lastName: "Akgül",
        gender: "female",
        age: 33,
        dob: Date(timeIntervalSince1970: 721847928),
        email: "nalan.akgul@example.com",
        phone: "(590)-971-8437",
        cell: "(121)-414-5321",
        streetNumber: "380",
        streetName: "Anafartalar Cd",
        city: "Van",
        state: "Hakkâri",
        country: "Turkey",
        postcode: "40291",
        latitude: "71.7403",
        longitude: "160.6450",
        largePhotoURL: URL(string: "https://randomuser.me/api/portraits/women/21.jpg"),
        mediumPhotoURL: URL(string: "https://randomuser.me/api/portraits/med/women/21.jpg"),
        thumbnailPhotoURL: URL(string: "https://randomuser.me/api/portraits/thumb/women/21.jpg"),
        nationality: "TR",
        registeredDate: Date(timeIntervalSince1970: 1421657176),
        status: .pending,
        pageIndex: 1
    )

    public static let mock2 = MatchProfile(
        id: "mock-2",
        title: "Ms",
        firstName: "Magarete",
        lastName: "Hohmann",
        gender: "female",
        age: 57,
        dob: Date(timeIntervalSince1970: -23709540),
        email: "magarete.hohmann@example.com",
        phone: "0687-0898116",
        cell: "0178-8085814",
        streetNumber: "1144",
        streetName: "Fasanenweg",
        city: "Waldbröl",
        state: "Sachsen",
        country: "Germany",
        postcode: "17578",
        latitude: "-4.7265",
        longitude: "-46.1069",
        largePhotoURL: URL(string: "https://randomuser.me/api/portraits/women/83.jpg"),
        mediumPhotoURL: URL(string: "https://randomuser.me/api/portraits/med/women/83.jpg"),
        thumbnailPhotoURL: URL(string: "https://randomuser.me/api/portraits/thumb/women/83.jpg"),
        nationality: "DE",
        registeredDate: Date(timeIntervalSince1970: 1032089089),
        status: .accepted,
        pageIndex: 1
    )

    public static let mockList: [MatchProfile] = [mock1, mock2]
}
