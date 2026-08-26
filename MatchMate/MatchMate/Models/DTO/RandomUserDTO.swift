//
//  RandomUserDTO.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public struct RandomUserResponseDTO: Decodable, Sendable {
    public let results: [UserDTO]
    public let info: ResponseInfoDTO?

    public init(results: [UserDTO], info: ResponseInfoDTO? = nil) {
        self.results = results
        self.info = info
    }
}

public struct ResponseInfoDTO: Decodable, Sendable {
    public let seed: String?
    public let results: Int?
    public let page: Int?
    public let version: String?
}

public struct UserDTO: Decodable, Sendable {
    public let gender: String?
    public let name: NameDTO?
    public let location: LocationDTO?
    public let email: String?
    public let login: LoginDTO?
    public let dob: DateInfoDTO?
    public let registered: DateInfoDTO?
    public let phone: String?
    public let cell: String?
    public let picture: PictureDTO?
    public let nat: String?

    public init(
        gender: String? = nil,
        name: NameDTO? = nil,
        location: LocationDTO? = nil,
        email: String? = nil,
        login: LoginDTO? = nil,
        dob: DateInfoDTO? = nil,
        registered: DateInfoDTO? = nil,
        phone: String? = nil,
        cell: String? = nil,
        picture: PictureDTO? = nil,
        nat: String? = nil
    ) {
        self.gender = gender
        self.name = name
        self.location = location
        self.email = email
        self.login = login
        self.dob = dob
        self.registered = registered
        self.phone = phone
        self.cell = cell
        self.picture = picture
        self.nat = nat
    }

    public func toDomain(pageIndex: Int) -> MatchProfile {
        let stableId = login?.uuid?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedId = (stableId != nil && !stableId!.isEmpty) ? stableId! : UUID().uuidString

        let streetNum = location?.street?.number?.description ?? ""
        let streetNm = location?.street?.name ?? ""
        let resolvedCity = location?.city ?? ""
        let resolvedState = location?.state ?? ""
        let resolvedCountry = location?.country ?? ""
        let resolvedPostcode = location?.postcode?.description ?? ""
        let resolvedLat = location?.coordinates?.latitude ?? ""
        let resolvedLong = location?.coordinates?.longitude ?? ""

        let largeURL = picture?.large.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: $0) }
        let medURL = picture?.medium.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: $0) }
        let thumbURL = picture?.thumbnail.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: $0) }

        return MatchProfile(
            id: resolvedId,
            title: name?.title ?? "",
            firstName: name?.first ?? "",
            lastName: name?.last ?? "",
            gender: gender ?? "",
            age: dob?.age ?? 0,
            dob: dob?.parsedDate,
            email: email ?? "",
            phone: phone ?? "",
            cell: cell ?? "",
            streetNumber: streetNum,
            streetName: streetNm,
            city: resolvedCity,
            state: resolvedState,
            country: resolvedCountry,
            postcode: resolvedPostcode,
            latitude: resolvedLat,
            longitude: resolvedLong,
            largePhotoURL: largeURL,
            mediumPhotoURL: medURL,
            thumbnailPhotoURL: thumbURL,
            nationality: nat ?? "",
            registeredDate: registered?.parsedDate ?? Date(),
            status: .pending,
            pageIndex: pageIndex
        )
    }
}

public struct NameDTO: Decodable, Sendable {
    public let title: String?
    public let first: String?
    public let last: String?

    public init(title: String? = nil, first: String? = nil, last: String? = nil) {
        self.title = title
        self.first = first
        self.last = last
    }
}

public struct LocationDTO: Decodable, Sendable {
    public let street: StreetDTO?
    public let city: String?
    public let state: String?
    public let country: String?
    public let postcode: FlexibleString?
    public let coordinates: CoordinatesDTO?
    public let timezone: TimezoneDTO?

    public init(
        street: StreetDTO? = nil,
        city: String? = nil,
        state: String? = nil,
        country: String? = nil,
        postcode: FlexibleString? = nil,
        coordinates: CoordinatesDTO? = nil,
        timezone: TimezoneDTO? = nil
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.country = country
        self.postcode = postcode
        self.coordinates = coordinates
        self.timezone = timezone
    }
}

public struct StreetDTO: Decodable, Sendable {
    public let number: FlexibleString?
    public let name: String?

    public init(number: FlexibleString? = nil, name: String? = nil) {
        self.number = number
        self.name = name
    }
}

public struct CoordinatesDTO: Decodable, Sendable {
    public let latitude: String?
    public let longitude: String?

    public init(latitude: String? = nil, longitude: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct TimezoneDTO: Decodable, Sendable {
    public let offset: String?
    public let description: String?

    public init(offset: String? = nil, description: String? = nil) {
        self.offset = offset
        self.description = description
    }
}

public struct LoginDTO: Decodable, Sendable {
    public let uuid: String?
    public let username: String?

    public init(uuid: String? = nil, username: String? = nil) {
        self.uuid = uuid
        self.username = username
    }
}

public struct DateInfoDTO: Decodable, Sendable {
    public let date: String?
    public let age: Int?

    public init(date: String? = nil, age: Int? = nil) {
        self.date = date
        self.age = age
    }

    public var parsedDate: Date? {
        guard let dateString = date else { return nil }
        return ISO8601DateParser.parse(dateString)
    }
}

public struct PictureDTO: Decodable, Sendable {
    public let large: String?
    public let medium: String?
    public let thumbnail: String?

    public init(large: String? = nil, medium: String? = nil, thumbnail: String? = nil) {
        self.large = large
        self.medium = medium
        self.thumbnail = thumbnail
    }
}

/// Flexible wrapper that decodes either an Int, Double, or String safely into a String representation.
public struct FlexibleString: Decodable, Sendable, CustomStringConvertible {
    public let value: String

    public var description: String { value }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            self.value = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = String(doubleValue)
        } else {
            self.value = ""
        }
    }

    public init(_ value: String) {
        self.value = value
    }
}

public enum ISO8601DateParser {
    private static let formatterWithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let standardFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public static func parse(_ string: String) -> Date? {
        if let date = formatterWithFractional.date(from: string) {
            return date
        }
        return standardFormatter.date(from: string)
    }
}
