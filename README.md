# Platz.io Python SDK

Typed Python client for the [Platz.io](https://platz.io) API. It is generated
from the backend's OpenAPI schema with
[`openapi-python-client`](https://github.com/openapi-generators/openapi-python-client)
and ships **both synchronous and asynchronous** clients built on
[`httpx`](https://www.python-httpx.org/), with full type hints.

## Installation

```bash
pip install platz
```

Pre-release versions track the Platz backend betas, so install those with
`--pre`:

```bash
pip install --pre platz
```

Requires Python 3.10+.

## Usage

The client is token-authenticated. Create an `AuthenticatedClient`, then call
the operation functions grouped by API collection under `platz.api.*`. Every
operation exposes four entry points: `sync` / `asyncio` (return the parsed
body) and `sync_detailed` / `asyncio_detailed` (return a `Response` with the
status code, headers, and parsed body).

### Synchronous

```python
from platz import AuthenticatedClient
from platz.api.deployments import all_deployments

client = AuthenticatedClient(
    base_url="https://your-platz-instance.example.com",
    token="YOUR_API_TOKEN",
)

# Parsed body:
page = all_deployments.sync(client=client, enabled=True)
for deployment in page.items:
    print(deployment.id, deployment.name)

# Full response (status code, headers, parsed body):
response = all_deployments.sync_detailed(client=client)
print(response.status_code, response.parsed.num_total)
```

### Asynchronous

```python
import asyncio

from platz import AuthenticatedClient
from platz.api.deployments import all_deployments


async def main():
    async with AuthenticatedClient(
        base_url="https://your-platz-instance.example.com",
        token="YOUR_API_TOKEN",
    ) as client:
        page = await all_deployments.asyncio(client=client)
        for deployment in page.items:
            print(deployment.name)


asyncio.run(main())
```

## Layout

- `platz.api.<collection>.<operation>` — request functions, e.g.
  `platz.api.deployments.all_deployments`, `platz.api.secrets.create_secret`.
- `platz.models` — request and response models (attrs classes).
- `platz.AuthenticatedClient` / `platz.Client` — the `httpx`-backed clients
  (usable as sync and async context managers).
- `platz.types.Response` — the wrapper returned by the `*_detailed` functions.

## Development

The `platz/` package is generated from the backend OpenAPI schema and is not
committed. To build locally you need [`uv`](https://docs.astral.sh/uv/):

```bash
# Regenerate from a schema file, then build the distribution:
./generate-sdk.sh path/to/openapi.yaml
uv build
```

See [AGENTS.md](AGENTS.md) for versioning and release details.

## License

Apache-2.0
