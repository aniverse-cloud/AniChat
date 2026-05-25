## 2025-05-24 - Flutter Dependency Versioning
**Learning:** Found that 'isar_generator' and 'hive_generator' have strict 'analyzer' package version requirements that can conflict with 'flutter_test' (which pins 'matcher' and indirectly affects the dependency tree).
**Action:** Use 'hive' without the generator or ensure compatible version ranges when 'flutter_test' is a requirement in a Flutter 3.x environment.

## 2026-05-25 - Glassmorphism Performance Considerations
**Learning:** Using BackdropFilter with excessive sigma values on high-density displays can drop frame rates.
**Action:** Keep blur values moderate (around 10) and ensure glassmorphic elements are not excessively layered to maintain 60/120 FPS.

## 2026-05-25 - Server-side Stream Filtering
**Learning:** Supabase streams without filters fetch the entire table before client-side filtering, leading to O(N) memory and bandwidth growth per user.
**Action:** Always use .eq() or other filters on streams (like conversation_id) to ensure the client only receives relevant data packets.
