//
//  RandomUserDTO.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation

public struct RandomUserResponseDTO: Decodable, Sendable {
    public let results: [UserDTO]
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
}

public struct LocationDTO: Decodable, Sendable {
    public let street: StreetDTO?
    public let city: String?
    public let state: String?
    public let country: String?
    public let postcode: FlexibleString?
    public let coordinates: CoordinatesDTO?
}

public struct StreetDTO: Decodable, Sendable {
    public let number: FlexibleString?
    public let name: String?
}

public struct CoordinatesDTO: Decodable, Sendable {
    public let latitude: String?
    public let longitude: String?
}

public struct LoginDTO: Decodable, Sendable {
    public let uuid: String?
}

public struct DateInfoDTO: Decodable, Sendable {
    public let date: String?
    public let age: Int?

    public var parsedDate: Date? {
        guard let date else { return nil }
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatterWithFractional.date(from: date) {
            return d
        }
        return ISO8601DateFormatter().date(from: date)
    }
}

public struct PictureDTO: Decodable, Sendable {
    public let large: String?
    public let medium: String?
    public let thumbnail: String?
}

/// Flexible wrapper that decodes an Int, Double, or String safely into a String representation.
public struct FlexibleString: Decodable, Sendable, CustomStringConvertible {
    public let value: String

    public var description: String { value }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self.value = str
        } else if let num = try? container.decode(Int.self) {
            self.value = String(num)
        } else if let double = try? container.decode(Double.self) {
            self.value = String(double)
        } else {
            self.value = ""
        }
    }
}
