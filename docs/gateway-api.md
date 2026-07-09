# Gateway API (HTTPRoute)

Instead of (or in addition to) the traditional `Ingress`, the chart can render a
[Gateway API](https://gateway-api.sigs.k8s.io/) `HTTPRoute` that attaches to a
shared cluster `Gateway`. This is the recommended path when your platform
already provides a centrally managed Gateway (Envoy Gateway, Contour, Istio,
Cilium, NGINX Gateway Fabric, GKE Gateway, …) and you want your GeoNode release
to plug into it rather than run its own ingress.

The Gateway API resources are gated behind `geonode.gatewayApi.enabled` and are
independent from `geonode.ingress.enabled` — you can run either, both, or
neither.

## What gets rendered

When `geonode.gatewayApi.enabled: true` **and** `parentRefs` is non-empty **and**
at least one hostname resolves (see below), the chart renders a single
`HTTPRoute` in the release namespace with these path rules:

| Path prefix | Backend service | Port |
|---|---|---|
| `/geoserver` | `<release>-geoserver` | `geoserver.port` |
| `pycsw.endpoint` (only if `pycsw.enabled: true`) | `<release>-pycsw` | `pycsw.port` |
| `/` (fallback) | `<release>-nginx` | `80` |

Rule order matches the template ([nginx-httproute.yaml](../charts/geonode/templates/nginx/nginx-httproute.yaml));
Gateway API implementations apply the longest-prefix match, so `/geoserver` and
the pycsw endpoint always win over `/`.

If any of the three preconditions is missing (`enabled: false`, empty
`parentRefs`, no hostname), **the HTTPRoute is silently skipped** — helm renders
zero Gateway API objects. This is intentional so a partially-configured chart
never publishes an unreachable route.

## Hostnames

- If `geonode.gatewayApi.hostnames` is a non-empty list, it is used verbatim.
- If it is empty, the chart falls back to `geonode.general.externalDomain` as
  the sole hostname.
- If both are empty, no HTTPRoute is rendered.

You typically leave `hostnames` empty and just set `externalDomain`. Populate
`hostnames` explicitly when a single release needs to answer on multiple
domains (e.g. vanity + tenant hostnames on the same Gateway listener).

## Minimal values

```yaml
geonode:
  general:
    externalDomain: geonode.example.org

  # existing ingress can stay disabled when a Gateway handles ingress
  ingress:
    enabled: False

  gatewayApi:
    enabled: True
    parentRefs:
      - name: my-shared-gateway
        namespace: gateway-system
        sectionName: https
```

The `parentRefs` entry above points at a listener named `https` on a Gateway
called `my-shared-gateway` in namespace `gateway-system`. Structure matches
[Gateway API `ParentReference`](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.ParentReference)
one-to-one; the chart passes the list through untouched.

## Full values reference

| Key | Type | Default | Purpose |
|---|---|---|---|
| `geonode.gatewayApi.enabled` | bool | `False` | Master switch. |
| `geonode.gatewayApi.parentRefs` | list | `[]` | Required. Gateway listener(s) the HTTPRoute attaches to. Empty list ⇒ nothing rendered. |
| `geonode.gatewayApi.hostnames` | list | `[]` | Explicit hostnames. Empty ⇒ falls back to `geonode.general.externalDomain`. |
| `geonode.gatewayApi.labels` | map | `{}` | Labels added to the HTTPRoute (used by some controllers as selectors). |
| `geonode.gatewayApi.annotations` | map | `{}` | Annotations added to the HTTPRoute. |

## Cross-namespace concerns

- The HTTPRoute is created in `.Release.Namespace`, alongside the backend
  services it references. **Backends are always same-namespace** — no
  `ReferenceGrant` is needed on the backend side.
- The Gateway named in `parentRefs` almost always lives in a **different**
  namespace (e.g. `gateway-system`, `envoy-gateway-system`). For the HTTPRoute
  to attach, the Gateway must permit routes from your release namespace via
  its `spec.listeners[].allowedRoutes.namespaces`. Common patterns:

  ```yaml
  # on the Gateway
  listeners:
    - name: https
      # ...
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              gateway-access: "true"
  ```

  Then label your GeoNode namespace: `kubectl label ns <release-ns> gateway-access=true`.

  Or, simpler but broader:

  ```yaml
      allowedRoutes:
        namespaces:
          from: All
  ```

- If your Gateway is happy to accept the HTTPRoute but the route shows
  `status: Accepted=False` with `reason: NotAllowedByListeners`, the Gateway
  side is what needs adjusting, not the chart.

## TLS

TLS is terminated at the Gateway listener, not at the HTTPRoute. Configure the
`certificateRefs` on your Gateway; the HTTPRoute the chart renders is
protocol-agnostic and works behind either an HTTP or HTTPS listener.

The chart's `geonode.acme` / cert-manager `Issuer` block only applies to the
traditional Ingress (`geonode.ingress.enabled: True`) and is bypassed when only
Gateway API is used — issue certificates for your Gateway via whatever your
platform already provides.

## Coexisting with the traditional Ingress

Both stacks can render at the same time. This is useful for gradual migration:

```yaml
geonode:
  ingress:
    enabled: True         # keep the Ingress alive
  gatewayApi:
    enabled: True         # add HTTPRoute on the new Gateway
    parentRefs:
      - name: my-shared-gateway
        namespace: gateway-system
```

Both paths point at the same backend services, so traffic ends up in the same
place. Once your DNS/clients are cut over to the Gateway hostname, flip
`ingress.enabled: False` and remove the Ingress.

## Verifying

```
kubectl -n <release-ns> get httproute
kubectl -n <release-ns> describe httproute <release>-nginx
```

Look for `status.parents[].conditions[]`:

- `Accepted: True, ResolvedRefs: True` → the Gateway attached the route and
  the backend services exist.
- `Accepted: False` → check the Gateway's `allowedRoutes` (see above).
- `ResolvedRefs: False` → a backend service name/port doesn't exist. If you've
  disabled `pycsw` or changed `geoserver.port`, redeploy so the HTTPRoute
  matches.
