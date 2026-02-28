# Carousel List Demo

## 1. Project Overview

**Carousel List Demo** is an iOS app that displays a paginated image carousel with a searchable list of items. The project is organized by branches: **main** (overview only), **UIKit** (VIP architecture), and **SwiftUI** (MVVM). Each UI branch shares the same services, models, and business logic within its own subtree.

**What it solves:**
- Combines a horizontally swipeable image carousel with a vertically scrollable list
- The entire content scrolls; the search bar stays pinned (sticky) to the top of the view
- Shows how to handle large image sets with pagination and caching
- Reuses networking, data mapping, and statistics logic across UI implementations

**Key features:**
- Image carousel with page indicators (up to 10 photographers)
- Searchable list synced with carousel data
- Statistics bottom sheet (items per page, character frequency)
- Localization support (`Localizable.strings`)
- Memory image caching
- Error handling with retry

**Branch structure:**
- **main** — this README only; landing page for the repository
- **UIKit** — full app with VIP (View-Interactor-Presenter) architecture
- **SwiftUI** — full app with MVVM architecture; shared entry point via `@main` App

---

## 2. Architecture

### 2.1 Shared Layer (within each branch)

The shared layer contains all business logic, services, and models. It has no UI framework dependencies except where necessary (e.g. `UIImage` for image caching in UIKit).

| Layer | Contents |
|-------|----------|
| **Models** | `ImageItem`, `ListItem`, `CarouselPage`, `Statistics` (`AppStatistics`, `PageStatistics`, `CharacterOccurrence`), `UnsplashPhoto` (DTO) |
| **Services** | `NetworkService`, `ImageCacheService`, `ImageLoader`, `RemoteDataProvider`, `CharacterCounter`, `APIEndpoints` (see Services/Network/, Data/, Image/, Statistics/ subdirectories) |
| **Protocols** | `NetworkServiceProtocol` (async Swift Concurrency), `DataProviderProtocol` (async `fetchImages`) |
| **Resources** | `AppStrings`, `AppIcons`, `APIKeys`, `Localizable.strings`, `Info.plist` |
| **Extensions** | `String+Localization`, `UIColor+Hex` / `Color+Hex`, `UIFont+App` / `Font` (framework-specific) |

### 2.2 UIKit Branch — VIP (View-Interactor-Presenter)

**Style:** VIP (View-Interactor-Presenter)

**Layers:**
- **View** (`MainViewController`) — UI only, displays view models, delegates user actions to Interactor via `MainInteractorProtocol`
- **Interactor** (`MainInteractor`) — business logic, fetches data via `DataProviderProtocol`, sends results to Presenter
- **Presenter** (`MainPresenter`) — transforms raw data into view models, calls View via `MainDisplayLogic`
- **Services** — networking, image cache, image loading (injectable)
- **Models** — shared `ImageItem`, `ListItem` + VIP-specific `MainViewModel`, `StatisticsViewModel`
- **Protocols** — `DataProviderProtocol`, `MainInteractorProtocol`, `MainPresenterProtocol`, `MainDisplayLogic`

**Flow:**
```
View → Interactor → Presenter → View
```

**Dependency management:**
- Constructor injection for all dependencies
- Composition root in `SceneDelegate`: creates `NetworkService`, `ImageCacheService`, `ImageLoader`, `RemoteDataProvider`, `MainPresenter`, `MainInteractor`, `MainViewController`
- View receives Interactor and ImageLoader via init; Presenter holds weak reference to View (`MainDisplayLogic`)

### 2.3 SwiftUI Branch — MVVM

**Style:** MVVM with `@Observable` and `@MainActor`

**Layers:**
- **Views** — `AppView`, `CarouselView`, `StatisticsSheet` and reusable components (`AsyncImageView`, `SearchBar`, `ListItemRow`, etc.)
- **ViewModels** — `MainViewModel`, `StatisticsViewModel` (business logic, state, async data loading)
- **Services** — shared `RemoteDataProvider`, `NetworkService`, `ImageCacheService`; SwiftUI-specific `ObservableImageLoader` (async, `@Observable`)
- **Models** — shared `ImageItem`, `ListItem`, `CarouselPage`, `AppStatistics`
- **Environment** — `ImageServicesEnvironment` (network + cache for image loading)

**Flow:**
```
View → ViewModel → DataProvider / ImageLoader → View
```

**Entry point:** `@main` App with SwiftUI `WindowGroup` (no SceneDelegate).

**Note on Coordinator:** The SwiftUI branch does not use the Coordinator pattern — with the current number of views (AppView, CarouselView, StatisticsSheet, etc.), it is not necessary. Navigation is simple enough without it.

**SwiftUI-specific optimizations:**
- **Batch loading** — fetches all initial pages before updating UI (avoids progressive re-renders)
- **Prefetch** — first carousel image is prefetched during data load for faster display
- **ScrollView + `.paging`** — full-page snap (no half-scroll states)
- **ObservableImageLoader** — loader created in init for earlier load start; `ImageServicesEnvironment` for DI

---

## 3. Protocols

Protocols define contracts between layers and enable dependency inversion.

**Current protocols:**
- `DataProviderProtocol` — abstraction for fetching image list (`RemoteDataProvider` conforms); async `fetchImages(page:limit:)` (Swift Concurrency)
- `NetworkServiceProtocol` — abstraction for network layer (async, accessKey passed to `fetchUnsplashPhotos`); enables mocking in unit tests
- `MainInteractorProtocol` — interface for View → Interactor (UIKit)
- `MainPresenterProtocol` — interface for Interactor → Presenter (UIKit)
- `MainDisplayLogic` — interface for Presenter → View (UIKit)

**Why protocols:**
- Decouple layers: View does not depend on concrete Interactor, Interactor does not depend on concrete Presenter
- Testability: unit tests inject mock implementations (e.g. `MockNetworkService`, `MockURLProtocol`) without touching production code
- Clear boundaries: each protocol describes exactly what a layer needs from another

---

## 4. Design Patterns & Language Features

**Design patterns:**
- VIP (View-Interactor-Presenter) for UIKit
- MVVM with `@Observable` for SwiftUI
- Dependency Injection (constructor injection)
- Protocol-Oriented Programming (`DataProviderProtocol`, `NetworkServiceProtocol`, `Main*Protocol`)
- Observer-like (closures: onRetry, onTap, onTextChange for FAB/search/carousel)

**Swift language features:**
- `async`/`await` (Swift Concurrency) for data loading in both UIKit and SwiftUI
- `[weak self]` in closures to avoid retain cycles
- Generic `fetch<T: Decodable>` for type-safe API calls
- Extensions (`String+Localization`, `UIColor+Hex` / `Color+Hex`, `UIFont+App` / `Font`)
- Protocol conformance (Decodable, LocalizedError)

---

## 5. API

**Base URL:** `https://api.unsplash.com`

**Integration:**
- Unsplash API provides a paginated list of photos (id, author, dimensions, URLs, description, alt_description)
- Register at [unsplash.com/oauth/applications](https://unsplash.com/oauth/applications) to get an access key
- Add `UNSPLASH_ACCESS_KEY` to Info.plist with your key (replace `YOUR_UNSPLASH_ACCESS_KEY`)
- Endpoints in `APIEndpoints`; networking in `NetworkService`; data fetching in `RemoteDataProvider`

**Networking:**
- Native `URLSession` with custom configuration
- `URLCache` for HTTP response caching (20 MB memory, 100 MB disk)
- Generic `fetch<T: Decodable>(_ type:from:)` for JSON
- Dedicated `loadImage(from:)` for image binary data

**Image caching:**  
In-memory (`NSCache`) for fast access while browsing.

**Documentation:** [Unsplash API](https://unsplash.com/documentation)

---

## 6. Project Structure

Each branch contains its own full implementation. Branches differ mainly in the View layer; shared logic (models, services, protocols) is duplicated per branch for isolation.

### UIKit branch

```
CarouselList/
├── Models/
├── Services/
│   ├── Network/
│   ├── Data/
│   └── Image/
├── Extensions/
├── Resources/
├── UIKit/
│   ├── Core/
│   │   └── AppDelegate.swift
│   ├── Extensions/
│   ├── Main/
│   │   ├── MainViewController.swift
│   │   ├── MainInteractor.swift
│   │   ├── MainPresenter.swift
│   │   └── Protocols/
│   └── Components/
└── CarouselListTests/      # Unit + UI tests
└── CarouselListUITests/    # UI tests only (UIKit)
```

### SwiftUI branch

```
CarouselList/
├── Models/
├── Services/
│   ├── Network/
│   ├── Data/
│   └── Image/
├── Extensions/
├── Resources/
├── SwiftUI/
│   ├── CarouselList_App.swift
│   ├── AppView.swift
│   ├── ViewModels/
│   ├── Components/
│   └── Extensions/
└── CarouselListTests/      # Unit tests only (business logic)
```

---

## 7. Versioning

| Version | Contents |
|---------|----------|
| **1.x** | Shared layer, VIP (UIKit), carousel + searchable list, statistics sheet, memory image cache, localization, Unsplash API |
| **2.x** | SwiftUI branch, MVVM, batch loading, prefetch |
| **3.x** | CI/CD, modularization, offline persistence |

---

## 8. Technologies Used

| Branch | Minimum iOS | Rationale |
|--------|-------------|-----------|
| **UIKit** | iOS 16.0 | VIP architecture uses standard UIKit; iOS 16+ covers ~95%+ of active devices, supports Swift Concurrency, modern URLSession |
| **SwiftUI** | iOS 17.0 | Requires `@Observable` (Observation framework), `scrollTargetBehavior(.paging)`, and improved SwiftUI APIs |

Swift 6, Xcode 16. Native frameworks: Foundation, UIKit, SwiftUI, Observation. No external libraries.

---

## 9. Testing

**Business logic tests** — present in both branches. Cover: `APIEndpoints`, `CharacterCounter`, `NetworkService`, `RemoteDataProvider`, `ImageCacheService`, models (`ImageItem`, `ListItem`, `CarouselPage`, `Statistics`, `UnsplashPhoto`).

**UI tests** — only in the **UIKit** branch. Cover: app launch, search bar visibility, FAB visibility, launch screenshot.

**Mocking:**
- `NetworkServiceProtocol` — `MockNetworkService` for protocol injection
- `MockURLProtocol` — URLSession mocking for network tests

**Planned:**
- MainInteractor / MainPresenter unit tests (UIKit)
- Broader UI test coverage for carousel, search, statistics sheet (UIKit)

---

## 10. Code Style

- Architecture-first: VIP for UIKit, MVVM for SwiftUI; thin View, logic in Interactor/ViewModel
- Protocol-oriented: protocols for layers, Decodable for models
- SOLID: single responsibility, dependency injection
- Clear separation: shared / UIKit or SwiftUI
- Reusable components: `EmptyStateView`, `ErrorView`, `SearchBarView`, etc.
- Naming: `camelCase` for variables, `PascalCase` for types, `AppStrings.X.y` for localization keys
- Constants defined locally in files where used; strings in `AppStrings`, icons in `AppIcons`

---

## 11. Setup

1. Clone the repository.
2. Check out the desired branch:
   - `git checkout UIKit` — for UIKit implementation
   - `git checkout SwiftUI` — for SwiftUI implementation
3. Open the project in Xcode.
4. Set `UNSPLASH_ACCESS_KEY` in Info.plist to your [Unsplash API](https://unsplash.com/developers) access key.
5. Build and run (⌘R).

---

## 12. Possible Future Improvements

- Broader unit and UI test coverage
- CI/CD (Xcode Cloud, GitHub Actions)
- Modularization (e.g. CarouselModule, ListModule)
- SwiftData or Core Data for offline persistence
- Additional localizations
- **Coordinator pattern (SwiftUI)** — consider introducing a Coordinator for navigation flow if the app grows and the number of screens increases significantly
