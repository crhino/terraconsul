### README

To apply:
```
  $ ./scripts/setup.sh
```

To use envoy:
1. Build a docker image from the official Consul Dockerfile, replacing the
   `FROM` directive with `FROM frolvlad/alpine-glibc`. Tag it `glibc-consul`.

   ```
   $ docker build . -t glibc-consul
   ```
2. Run `USE_ENVOY=true ./scripts/setup.sh`
