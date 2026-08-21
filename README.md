# What-the-

Prototype scaffold for TechDeck HQ mobile app (prototype branch)

This repository contains the initial prototype for the TechDeck HQ mobile app: a cross-platform Flutter app (iOS & Android) with an AI assistant UI, a mock feed, daily tips, a safety bunker UX, and an in-app admin ingest page.

This commit is an initial prototype (B). It includes:

- Flutter app scaffold (flutter_app/)
- Firebase Cloud Functions stubs (functions/)
- README with setup and next steps

Next steps (after you add secrets and configure Firebase/OpenAI):

- Add OPENAI_API_KEY to your environment (see .env.example)
- Deploy cloud functions or run locally for development
- Replace mocked auth and data with Firebase Auth and Firestore


## Notes
- This is a prototype. Client-side encryption for the safety bunker and production-grade auth are included in the full scaffold (A) that will follow.
