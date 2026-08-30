# Changelog

## [0.6.0] - (2026-08-30)
### Added
- **Search Feature:** Created a dedicated `feat_search` module containing `SearchPage` for filtering posts by title and description.
- **Search History:** Implemented `SearchHistoryService` to automatically record user search queries with the "دیوار استهبان: [query]" format in PocketBase.
- **Navigation:** Added the search tab to the bottom navigation bar (`MainNavigationPage`).

## [0.5.0] (2026-08-30)
### Added
- **Categories Architecture:** Introduced `CategoryModel` and `CategoryService` to manage hierarchical categories (parent-child relationship).
- **Categories Page:** Added a dedicated categories view with tree-like expandable items (`ExpansionTile`) in the main bottom navigation.
- **Category Filtering:** Implemented post filtering by category ID and created `CategoryPostsPage` to display posts belonging to a specific subcategory.
- **Enhanced Post Creation:** Updated `CreatePostPage` and `PostService` to support selecting and saving hierarchical categories for new posts.
### Changed
- **Navigation:** Updated `MainNavigationPage` to include the new categories tab in the bottom navigation bar.
- **Asset Structure:** Reorganized logo asset path structure.

## [0.3.0] (2026-08-29)
* **Feature Architecture Restructuring**: Migrated project files into a feature-based architecture (`feat_auth`, `feat_posts`, `feat_main`, `feat_about`) to enhance code scalability and maintainability.
* **Authentication & Profile Management**: Introduced complete login and profile pages (`login_page.dart`, `profile_page.dart`) with robust PocketBase session handling and user data rendering.
* **Post System & Performance**: Implemented efficient pagination and infinite scrolling mechanisms within `home_page.dart` and `post_service.dart` to optimize large dataset rendering.
* **Assets & UI Integration**: Added official application assets, including the app logo (`logo.png`), and updated the main navigation routing structure.

## [0.1.0] (2026-07-14)
* Initial release of Estahban City.
* Implemented user authentication with PocketBase.
* Added ad listing and detail view pages.
* Integrated local market features for Estahban citizens.
* Setup Flutter localization for Persian (RTL) support.