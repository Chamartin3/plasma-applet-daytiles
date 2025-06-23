# vendored daytiles

Pinned copy of the upstream `dist/` build. Do not edit by hand.

To refresh:

```sh
git clone --depth 1 https://github.com/Chamartin3/daytiles /tmp/daytiles
cp /tmp/daytiles/dist/index.js ./index.js
( cd /tmp/daytiles && git rev-parse HEAD ) > REF
```
