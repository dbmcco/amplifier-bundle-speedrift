---
bundle:
  name: speedrift
  version: 0.3.0
  description: "Amplifier runtime behavior for Workgraph-first Speedrift orchestration (no-beads)."

includes:
  - bundle: git+https://github.com/microsoft/amplifier-foundation@main
  - bundle: git+https://github.com/microsoft/amplifier-bundle-recipes@main
  - bundle: speedrift:behaviors/speedrift

hooks:
  - module: hook-shell
    source: git+https://github.com/microsoft/amplifier-module-hook-shell@main
    config:
      hooks_dirs:
        - .amplifier/hooks
---

# Speedrift Bundle

Amplifier behavior bundle for Speedrift + Workgraph operation.

@speedrift:context/speedrift-protocol.md
@speedrift:context/model-routing.md
