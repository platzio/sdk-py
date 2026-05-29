# AGENTS.md

## Versioning

This SDK is released in lockstep with the Platzio backend and carries the
**same version as the backend release**, pre-release marker included (see
`platzio/dev` AGENTS.md, "Versioning across repos"). So when the backend
releases `0.7.0-beta.3`, this package is `0.7.0-beta.3` too — they are always
cut together.

The version lives in `pyproject.toml` (`[project].version`). Python packaging
normalizes the PEP 440 form, so `0.7.0-beta.3` publishes to PyPI as `0.7.0b3`
(`pip install --pre platz`, or `pip install platz==0.7.0b3`). The release
workflow derives the backend release tag as `v<version>` (`v0.7.0-beta.3`) to
download the matching `openapi.yaml`, so keep the `pyproject.toml` version in
the `X.Y.Z-beta.N` spelling that mirrors the backend tag.

## How it's built

The `platz/` package is **generated** from the backend's OpenAPI schema by
[`openapi-python-client`](https://github.com/openapi-generators/openapi-python-client)
via [`generate-sdk.sh`](generate-sdk.sh), and is **gitignored** — it is
regenerated fresh in CI on every release, never committed. The repo only holds
the packaging config (`pyproject.toml`), the generator config
(`openapi-python-client-config.yaml`), the workflow, and docs.

To regenerate locally against a schema:

```bash
./generate-sdk.sh path/to/openapi.yaml   # writes ./platz/
uv build                                  # produces ./dist/
```

## Publishing

Publishing uses PyPI **trusted publishing** (OIDC) from
[`.github/workflows/release.yaml`](.github/workflows/release.yaml) on push to
`main` — there is no API token. The workflow reads the version from
`pyproject.toml`, downloads the matching `openapi.yaml` from the backend's
GitHub release, regenerates, `uv build`s, and `uv publish`es. `--check-url`
makes a push with an unchanged version a no-op, so only version bumps publish.

## Known generator limitation

The backend schema models a few Rust enums as `oneOf`s whose variants are
**inline** objects (e.g. the `Deployment` arm of `MeResponse`, the
`collection_select` arm of `UiSchemaInputSingleType`). `openapi-python-client`
collides on naming those inline arms and drops them, emitting a warning during
generation. These are narrow union arms, not whole endpoints. The durable fix
is to give those inline objects named `$ref` components in the backend's
`utoipa` annotations; until then the warnings are expected and benign.
