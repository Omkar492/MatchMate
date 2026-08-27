//
//  ProfileEntity.swift
//  MatchMate
//
//  Created by Omkar Chougule on 27/08/26.
//

import Foundation
import SwiftData

@Model
public final class ProfileEntity {
    @Attribute(.unique) public var id: String = ""
    public var title: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var gender: String = ""
    public var age: Int = 0
    public var dob: Date? = nil
    public var email: String = ""
    public var phone: String = ""
    public var cell: String = ""
    public var streetNumber: String = ""
    public var streetName: String = ""
    public var city: String = ""
    public var state: String = ""
    public var country: String = ""
    public var postcode: String = ""
    public var latitude: String = ""
    public var longitude: String = ""
    public var largePhotoURLString: String = ""
    public var mediumPhotoURLString: String = ""
    public var thumbnailPhotoURLString: String = ""
    public var nationality: String = ""
    public var registeredDate: Date = Date()
    public var statusRaw: String = MatchStatus.pending.rawValue
    public var pageIndex: Int = 1
    public var orderIndex: Int = 0
    public var cachedAt: Date = Date()
    public var updatedAt: Date = Date()

    public init(from profile: MatchProfile) {
        self.id = profile.id
        self.title = profile.title
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.gender = profile.gender
        self.age = profile.age
        self.dob = profile.dob
        self.email = profile.email
        self.phone = profile.phone
        self.cell = profile.cell
        self.streetNumber = profile.streetNumber
        self.streetName = profile.streetName
        self.city = profile.city
        self.state = profile.state
        self.country = profile.country
        self.postcode = profile.postcode
        self.latitude = profile.latitude
        self.longitude = profile.longitude
        self.largePhotoURLString = profile.largePhotoURL?.absoluteString ?? ""
        self.mediumPhotoURLString = profile.mediumPhotoURL?.absoluteString ?? ""
        self.thumbnailPhotoURLString = profile.thumbnailPhotoURL?.absoluteString ?? ""
        self.nationality = profile.nationality
        self.registeredDate = profile.registeredDate
        self.statusRaw = profile.status.rawValue
        self.pageIndex = profile.pageIndex
        self.orderIndex = 0
        self.cachedAt = Date()
        self.updatedAt = Date()
    }

    public func update(from profile: MatchProfile, preserveDecision: Bool = true) {
        self.title = profile.title
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.gender = profile.gender
        self.age = profile.age
        self.dob = profile.dob
        self.email = profile.email
        self.phone = profile.phone
        self.cell = profile.cell
        self.streetNumber = profile.streetNumber
        self.streetName = profile.streetName
        self.city = profile.city
        self.state = profile.state
        self.country = profile.country
        self.postcode = profile.postcode
        self.latitude = profile.latitude
        self.longitude = profile.longitude
        self.largePhotoURLString = profile.largePhotoURL?.absoluteString ?? ""
        self.mediumPhotoURLString = profile.mediumPhotoURL?.absoluteString ?? ""
        self.thumbnailPhotoURLString = profile.thumbnailPhotoURL?.absoluteString ?? ""
        self.nationality = profile.nationality
        self.registeredDate = profile.registeredDate
        self.pageIndex = profile.pageIndex

        if !preserveDecision || self.statusRaw == MatchStatus.pending.rawValue {
            self.statusRaw = profile.status.rawValue
        }
        self.updatedAt = Date()
    }

    public func toDomain() -> MatchProfile {
        let status = MatchStatus(rawValue: statusRaw) ?? .pending
        return MatchProfile(
            id: id,
            title: title,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            age: age,
            dob: dob,
            email: email,
            phone: phone,
            cell: cell,
            streetNumber: streetNumber,
            streetName: streetName,
            city: city,
            state: state,
            country: country,
            postcode: postcode,
            latitude: latitude,
            longitude: longitude,
            largePhotoURL: largePhotoURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: largePhotoURLString),
            mediumPhotoURL: mediumPhotoURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: mediumPhotoURLString),
            thumbnailPhotoURL: thumbnailPhotoURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: thumbnailPhotoURLString),
            nationality: nationality,
            registeredDate: registeredDate,
            status: status,
            pageIndex: pageIndex
        )
    }
}
