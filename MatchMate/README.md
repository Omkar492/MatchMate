# MatchMate — iOS Matrimonial Matchmaking Application

MatchMate is a modern, offline-first iOS matchmaking application built using **SwiftUI**, **MVVM + Repository architecture**, and **SwiftData** for local persistence. It fetches match profiles with pagination from the Random User API, caches them locally, enables seamless Accept/Decline actions both online and offline, and guarantees real-time status synchronization between the card feed and the full profile detail screen.

---

## 🏛️ Architecture Overview

The app follows the **MVVM + Repository** pattern strictly adhering to Clean Architecture principles, ensuring separation of concerns, testability, and deterministic data flow.

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│  ┌───────────────────────┐   ┌──────────────────────┐  │
│  │     MatchListView     │   │   MatchDetailView    │  │
│  └───────────▲───────────┘   └──────────▲───────────┘  │
│              │                          │              │
│  ┌───────────▼───────────┐   ┌──────────▼───────────┐  │
│  │   MatchListViewModel  │   │ MatchDetailViewModel │  │
│  └───────────▲───────────┘   └──────────▲───────────┘  │
└──────────────┼──────────────────────────┼──────────────┘
               │                          │
┌──────────────┴──────────────────────────┴──────────────┐
│                    Repository Layer                    │
│           ┌────────────────────────────────┐           │
│           │    MatchRepositoryProtocol     │           │
│           │        (MatchRepository)       │           │
│           └───────▲────────────────▲───────┘           │
└───────────────────┼────────────────┼───────────────────┘
                    │                │
┌───────────────────┴──────┐  ┌──────┴───────────────────┐
│       Remote Data        │  │       Local Storage      │
│  ┌────────────────────┐  │  │  ┌────────────────────┐  │
│  │  MatchAPIService   │  │  │  │SwiftDataStorage    │  │
│  │(URLSession + async)│  │  │  │  (ProfileEntity)   │  │
│  └────────────────────┘  │  │  └────────────────────┘  │
└──────────────────────────┘  └──────────────────────────┘
```

### Layer Responsibilities
- **Domain Layer (`Models/Domain`)**: Contains pure Swift domain types (`MatchProfile`, `MatchStatus`) completely decoupled from UI, network libraries, or persistence frameworks.
- **DTO Layer (`Models/DTO`)**: Decodable data transfer objects with resilient decoding (e.g. `FlexibleString` for postcodes/street numbers that can return as `Int` or `String`, ISO8601 parser supporting fractional seconds).
- **Persistence Layer (`Models/Persistence` & `Services/Storage`)**: SwiftData `@Model final class ProfileEntity` mapping to/from domain models. `SwiftDataProfileStorage` handles upserting, fetching, status updates, and deduplication.
- **Network Layer (`Services/Network`)**: `MatchAPIService` executing `URLSession` `async/await` requests against `https://randomuser.me/api/?page={page}&results=10&seed=matchmate`.
- **Repository Layer (`Repositories`)**: `MatchRepository` serves as the single source of truth for the presentation layer. It coordinates API fetching, local database caching, decision preservation, offline fallbacks, and real-time status updates via `AsyncStream`.
- **Presentation Layer (`Features/List`, `Features/Detail`, `Features/Shared`)**: Thin SwiftUI views observing `@Observable` ViewModels (`MatchListViewModel`, `MatchDetailViewModel`). ViewModels perform optimistic UI updates and handle rollback on failures.

---

## 💾 Local Database Choice: SwiftData

We chose **SwiftData** (introduced in iOS 17) over Core Data for several reasons:

1. **Native Swift Concurrency & Observation**: SwiftData pairs natively with the Swift 5.9+ `@Observable` macro and `async/await`, eliminating Core Data boilerplate like `NSManagedObjectContext` perform-blocks and manual notification merges.
2. **Compile-time Type Safety**: `@Model` macros provide declarative, strongly-typed property models without requiring external `.xcdatamodeld` mapping files.
3. **Seamless In-Memory Testing**: `SwiftDataProfileStorage.createInMemory()` enables fast, isolated unit tests using an in-memory SQLite schema without touching disk.
4. **Resilient Initialization**: `AppComposition` handles store setup and automatic fallback recovery in development if schema migrations occur.

---

## 🔄 Pagination & Status Synchronization

### 1. API Pagination (Infinite Scroll)
- Pagination starts at `page = 1` with `seed = matchmate` and `results = 10` per batch.
- As the user scrolls near the bottom of the list (detected via `.task` on the last items in `LazyVStack`), `MatchListViewModel.loadNextPageIfNeeded(currentProfile:)` fetches the next page index.
- New profiles are appended to the local SwiftData storage and the UI seamlessly.
- Pull-to-refresh (`.refreshable`) triggers a reload starting at page 1.

### 2. Immediate Two-Way Status Synchronization
- **Single Source of Truth**: Each profile is uniquely identified by `login.uuid` (`@Attribute(.unique)`).
- **Optimistic UI Updates**: Tapping Accept or Decline on either the Match Card or the Detail Screen immediately updates the local state for zero-latency user feedback.
- **Decision Preservation on API Refetches**: When the app refreshes or fetches subsequent pages, incoming API items are upserted into SwiftData while strictly preserving any existing user decisions (`.accepted` or `.declined`).
- **Real-Time Reactive Stream**: `MatchRepository` publishes updates through `AsyncStream<MatchProfile>`. Both `MatchListViewModel` and `MatchDetailViewModel` subscribe to this stream:
  - If a user changes status on the Detail Screen and navigates back, the list card is already updated immediately without manual refresh.
  - If a user modifies status on the card feed, detail views for that profile reflect the change instantly.
- **App Relaunch**: All decisions survive app termination and device restarts because they are persisted in SwiftData.

---

## 📴 Offline Mode & Error Handling

- **Offline Cache Display**: When network connectivity is absent or the API request fails, `MatchRepository` falls back to querying the cached `ProfileEntity` records in SwiftData and displays them.
- **Offline Actions**: Users can continue to Accept or Decline profiles while offline; decisions are committed directly to SwiftData.
- **Image Caching**: Images are cached to disk via Kingfisher (`.cacheOriginalImage()`), enabling full profile visuals even in Airplane Mode.
- **User Feedback**: Non-intrusive `ErrorBannerView` alerts the user when running offline or encountering transient network issues, while `OfflineEmptyStateView` with a retry action appears if no cached matches exist.

---

## 🧪 Unit Testing

The test suite covers ViewModels, Repository, API Service, DTO mapping, and SwiftData storage using clean mocks and test doubles:

- `MatchListViewModelTests`: Initial loading, infinite scroll pagination threshold, optimistic accept/decline updates, rollback on failure, offline empty state, and repository stream synchronization.
- `MatchDetailViewModelTests`: Profile loading, accept/decline actions, persistence, failure rollback, and external update synchronization.
- `MatchRepositoryTests`: Remote fetching & caching, decision preservation across API re-fetches, offline fallback, and async stream emission.
- `MatchAPIServiceTests`: Endpoint URL construction with seed/page/results, status code validation, JSON decoding, and error mapping via `MockURLProtocol`.
- `SwiftDataProfileStorageTests`: In-memory container CRUD, decision preservation on upsert, status updates, and clearing records.
- `RandomUserDTOTests`: Flexible postcode decoding (`Int` & `String`), flexible street numbers, and fractional ISO8601 date parsing.

### Running Tests
In Xcode:
1. Open `MatchMate.xcodeproj`.
2. Select the `MatchMate` scheme and an iOS 17+ Simulator (e.g., iPhone 15/16/17).
3. Press `Cmd + U` or run `Product > Test`.

Or via command line:
```bash
xcodebuild test -scheme MatchMate -destination "generic/platform=iOS Simulator" -only-testing:MatchMateTests
```

---

## 🛠️ How to Run the App

1. Open `MatchMate.xcodeproj` in Xcode 16+ (or 15+).
2. Select any iOS 17.0+ Simulator target.
3. Press `Cmd + R` to build and run the application.

---

## 💡 Known Gaps & Future Enhancements
- **Bi-directional Filter / Sort**: Filter profiles by Accepted, Declined, or Pending in a segmented control.
- **Undo Decision**: Add a toast notification with an "Undo" action after accepting or declining a match.
- **Swipe Gestures**: Add swipe-left to decline and swipe-right to accept card gestures.

---

## ⏱️ Rough Hours Spent
- **Architecture & Domain Design**: ~1.5 hours
- **SwiftData Storage & API Layer**: ~2 hours
- **UI Design (Cards, Details, Animations)**: ~2.5 hours
- **Status Sync & Offline Logic**: ~1.5 hours
- **Unit Test Suite & Verification**: ~1.5 hours
- **Total**: ~9 hours
