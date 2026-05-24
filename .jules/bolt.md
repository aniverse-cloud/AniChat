## 2025-05-24 - Flutter Dependency Versioning
**Learning:** Found that 'isar_generator' and 'hive_generator' have strict 'analyzer' package version requirements that can conflict with 'flutter_test' (which pins 'matcher' and indirectly affects the dependency tree).
**Action:** Use 'hive' without the generator or ensure compatible version ranges when 'flutter_test' is a requirement in a Flutter 3.x environment.
