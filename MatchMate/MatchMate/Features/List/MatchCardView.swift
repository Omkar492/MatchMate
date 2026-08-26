import SwiftUI

struct MatchCardView: View {
    let user: MatchUser
    var onAccept: () -> Void = {}
    var onDecline: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            photo
            details
            actions
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var photo: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.tertiarySystemFill))
            .frame(height: 260)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(.tertiary)
            )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(user.name), \(user.age)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                Text("\(user.city), \(user.country)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button(action: onDecline) {
                Label("Decline", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            Button(action: onAccept) {
                Label("Accept", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .controlSize(.large)
    }
}

#Preview {
    MatchCardView(user: MatchUser.sampleData[0])
        .padding()
        .background(Color(.systemGroupedBackground))
}
