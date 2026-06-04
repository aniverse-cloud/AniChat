## 2025-05-15 - [Chat Retrieval O(N) -> O(1)]
**Learning:** The initial implementation scanned the entire Hive box (O(N)) for every message list update. In a chat app, this scales poorly as history grows.
**Action:** Use an in-memory `Map<String, List<Message>>` cache keyed by `conversationId`. This makes retrieval O(1) and UI updates extremely snappy, only requiring an O(K log K) sort of the conversation history (where K << N).

## 2025-05-15 - [Local-First UX with Remote Discovery]
**Learning:** Switching to local-first data for `ChatsScreen` (via Hive `watch()`) provides instant loads, but breaks if a message is received from a user NOT in the local contacts box.
**Action:** Implemented automatic profile discovery in `ChatService`. When a message arrives from an unknown UID, the service fetches the profile from Supabase and populates the local `contacts` box, ensuring the conversation appears correctly in the UI.
