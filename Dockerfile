FROM xena/nim:0.20.2 AS build
RUN apk --no-cache add npm
WORKDIR /maison
COPY . .
RUN nimble setup
RUN nimble update && NIM_RELEASE=1 nimble fullbuild

FROM xena/alpine
WORKDIR /maison
ENV PORT 5000
RUN apk --no-cache add openssl ||:
COPY --from=build /maison/bin/maison /usr/local/bin/maison
COPY --from=build /maison/public ./public
CMD maison
