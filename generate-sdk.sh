#!/usr/bin/env bash
#
# Regenerate the `platz` package from the backend's OpenAPI schema.
#
# The generated package is gitignored and rebuilt fresh on every release, so
# this script is the single source of truth for how the client is produced —
# run it locally the same way CI does:
#
#     ./generate-sdk.sh path/to/openapi.yaml
#
# Requires `uv` (https://docs.astral.sh/uv/); the generator and its formatter
# (ruff) run in an isolated, version-pinned environment via `uvx`.

set -euo pipefail

OPENAPI_SCHEMA="${1:-openapi.yaml}"
GENERATOR_VERSION="0.28.4"

uvx --with ruff "openapi-python-client@${GENERATOR_VERSION}" generate \
    --path "${OPENAPI_SCHEMA}" \
    --meta none \
    --config openapi-python-client-config.yaml \
    --overwrite

# openapi-python-client does not emit a PEP 561 marker in `--meta none` mode;
# add it so type-checkers consume the SDK's inline type hints.
touch platz/py.typed
