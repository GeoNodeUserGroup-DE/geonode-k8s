# Enabling `OAUTH2_API_KEY` on an existing installation

GeoNode's legacy `/api/roles`, `/api/adminRole` and `/api/users` endpoints are reachable
**anonymously** while `OAUTH2_API_KEY` is empty — they expose usernames, group names and
which accounts are superusers. Setting the key closes them.

But GeoServer's `geonode REST role service` calls those same three endpoints, so it needs
the key too. If only GeoNode has it, GeoServer gets `401` and every user authenticating
through the `geonode-oauth2` filter resolves **no roles**.

> ⚠️ **That failure is silent.** `GeoServerRestRoleService` catches the `401` at
> `Level.FINEST` with a null message and returns an empty role set, and
> `PRODUCTION_LOGGING` logs `org.geoserver` at `warn`. Nothing appears in
> `geoserver.log`.

> Conventions used below — substitute your own values:
> - `<release>` — your Helm release name (e.g. `geonode`)
> - `<ns>` — its namespace (e.g. `geonode`)

---

## How this normally works

The `geonode/geoserver` image runs `set_geoserver_auth.sh` from its entrypoint on **every
container start**, copying `OAUTH2_API_KEY` out of the environment and into

```
/geoserver_data/data/security/role/geonode REST role service/config.xml
```

(the same script also fills in `baseUrl`, and the client credentials and URIs in the
`geonode-oauth2` filter config). It leaves a `config.xml.orig` beside each file it touches,
which is how you can tell it has run.

So on a **new** installation you only set the key in your values file and the image does the
rest.

**The catch for existing installations:** that script works by `grep`-then-`sed`, so it only
replaces tags that already exist. A GeoServer data directory created before `<authApiKey>`
was added to the `geonode/geoserver_data` image never receives the element, and the key is
therefore never applied — silently.

---

## Step 1 — Check whether you are affected

```bash
kubectl -n <ns> exec <release>-geoserver-0 -c geoserver -- \
  grep -c authApiKey "/geoserver_data/data/security/role/geonode REST role service/config.xml"
```

- `1` — the element is present, the entrypoint will fill it. Continue at Step 3.
- `0` — the element is missing. Do Step 2.

## Step 2 — Add the empty element

```bash
kubectl -n <ns> exec <release>-geoserver-0 -c geoserver -- \
  sed -i 's|</authKeyRESTRoleService>|  <authApiKey></authApiKey>\n</authKeyRESTRoleService>|' \
  "/geoserver_data/data/security/role/geonode REST role service/config.xml"
```

Leave it **empty** — the entrypoint fills it on the next start, so the secret never has to be
written into the file by hand.

> :bulb: **Note:**
>
> This edits a file on the PVC, so it does not survive re-initialising that volume. Once your
> data directory comes from an image that already ships the element, the step is no longer
> needed.

## Step 3 — Set the key

Set `geonode.secret.oauth2.apiKey` in your values file, or supply `OAUTH2_API_KEY` through
`geonode.secret.existingSecretName` / `geoserver.secret.existingSecretName`.

```yaml
geonode:
  secret:
    oauth2:
      apiKey: "<generated value>"
```

Generate it with `openssl rand -hex 32`. Avoid:

- **whitespace** — GeoNode splits the `Authorization` header and requires exactly two fields
- **`<`, `>`, `&`** — the value is written into XML
- **`${`** — GeoServer would read it as an environment placeholder

> ⚠️ Requires chart **2.0.1 or newer**. Releases up to and including `2.0.0` hardcode
> `OAUTH2_API_KEY: ""` in both the GeoNode and GeoServer Secrets and ignore the value
> ([#343](https://github.com/GeoNodeUserGroup-DE/geonode-k8s/pull/343)).

Confirm it reached **both** pods:

```bash
for p in <release>-geonode-0 <release>-geoserver-0; do
  kubectl -n <ns> exec $p -- sh -c 'test -n "$OAUTH2_API_KEY" && echo "$(hostname): set" || echo "$(hostname): EMPTY"'
done
```

## Step 4 — Restart GeoServer

```bash
kubectl -n <ns> rollout restart statefulset/<release>-geoserver
```

## Step 5 — Verify

From inside the GeoServer pod, against the in-cluster nginx Service:

```bash
kubectl -n <ns> exec <release>-geoserver-0 -c geoserver -- \
  curl -s -o /dev/null -w '%{http_code}\n' http://<release>-nginx/api/roles
```

- `200` — both sides agree. Done.
- `401` — the keys differ, or GeoServer's `authApiKey` is still empty.
- `000` — wrong Service name or port.

Then sign in to GeoServer *through GeoNode* as a superuser and confirm you get the admin UI.

From outside, the endpoints should no longer be readable:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://<your-host>/api/roles
```

`401` is expected. `200` means the key is not in effect.

---

## Two things to avoid

**Do not generate the key per pod.** Something like

```python
OAUTH2_API_KEY = OAUTH2_API_KEY or secrets.token_urlsafe(48)
```

in appended settings produces a different value in every process and on every restart, so it
can never be shared with GeoServer. Role resolution then breaks permanently, and silently.

**Do not block these paths at the chart's nginx.** GeoServer reaches them through that
Service, so blocking there breaks role resolution just as a mismatched key does. Block at the
ingress instead:

```yaml
geonode:
  ingress:
    annotations:
      nginx.ingress.kubernetes.io/server-snippet: |
        location ~ ^/api/(roles|adminRole|users)/?$ { return 404; }
```

> :bulb: **Note:**
>
> With split-horizon DNS the same hostname may be served by more than one ingress. Apply the
> rule to each one that is reachable, not only the public one.

---

## Related

The chart also ships GeoNode's published sample `clientId` and `clientSecret` for the
GeoServer OAuth2 client (from `geonode/base/fixtures/default_oauth_apps.json`). Rotating
those needs the values **and** the `oauth2_provider.application` row, which `tasks.py`
rebuilds from `OAUTH2_CLIENT_ID` / `OAUTH2_CLIENT_SECRET` — GeoServer's own side is handled
by the same entrypoint script. See
[#344](https://github.com/GeoNodeUserGroup-DE/geonode-k8s/issues/344).
