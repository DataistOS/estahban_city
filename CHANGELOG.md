# Changelog

## 0.3.0 (2026-08-29)
* **Feature Architecture Restructuring**: Migrated project files into a feature-based architecture (`feat_auth`, `feat_posts`, `feat_main`, `feat_about`) to enhance code scalability and maintainability.
* **Authentication & Profile Management**: Introduced complete login and profile pages (`login_page.dart`, `profile_page.dart`) with robust PocketBase session handling and user data rendering.
* **Post System & Performance**: Implemented efficient pagination and infinite scrolling mechanisms within `home_page.dart` and `post_service.dart` to optimize large dataset rendering.
* **Assets & UI Integration**: Added official application assets, including the app logo (`logo.png`), and updated the main navigation routing structure.

## 0.1.0 (2026-07-14)
* Initial release of Estahban City.
* Implemented user authentication with PocketBase.
* Added ad listing and detail view pages.
* Integrated local market features for Estahban citizens.
* Setup Flutter localization for Persian (RTL) support.