FROM gp3t1/alpine:0.3

LABEL maintainer="Jeremy PETIT <jeremy.petit@gmail.com>" \
			description="alpine-based isso image - commenting server"

## ISSO BUILD SETTINGS
ARG VERSION="0.10.5"
# ARG MISAKA_VERSION="1.0.2"

## VOLUMES
VOLUME ["/etc/isso","/data/isso"]

## PORTS
EXPOSE 80

## CUSTOM ISSO UID/GID
ENV APP_USER="isso" 			APP_UID=500
ENV APP_GROUP="$APP_USER"	APP_GUID=501

## ISSO CONFIGURATION
ENV DB_NAME="comments.db" \
		NAME="ISSO" \
		WEBSITE="https://my-domain/" \
		LISTEN="http://localhost:8100" \
		RELOAD="off" \
		PROFILE_ENABLE="off" \
		HASH_SALT=""
ENV	NOTIFY="stdout" \
		LOG_NAME=""
ENV	MOD_ENABLE="false" \
		MOD_PURGE="30d"
ENV	SMTP_USER="" \
		SMTP_PASSWORD="" \
		SMTP_HOST="" \
		SMTP_PORT="" \
		SMTP_SECURITY="" \
		SMTP_TO="" \
		SMTP_FROM="" \
		SMTP_TIMEOUT=""
ENV	GUARD_ENABLE="true" \
		MAX_AGE="15m" \
		RATE_LIMIT="3" \
		DIRECT_REPLY="3" \
		REPLY_SELF="false" \
		REQUIRE_AUTHOR="false" \
		REQUIRE_EMAIL="false"
ENV	MARKUP_OPTIONS="TABLES, FENCED_CODE, AUTOLINK, STRIKETHROUGH, NO_INTRA_EMPHASIS" \
		MARKUP_ALLOW_ELTS="img" \
		MARKUP_ALLOW_ATTRS="src"		

## INSTALLATION
RUN  setAppUser \
	&& apk --no-cache add -t build-dependencies \
			python-dev \
			libffi-dev \
			py2-pip \
			build-base \
	&& apk --no-cache add \
			python \
			py-setuptools \
			sqlite \
			# libressl \
			# ca-certificates \
	&& pip install --no-cache cffi \
	&& pip install --no-cache misaka \
	&& pip install --no-cache "isso==${VERSION}" \
	&& pip install --no-cache j2cli[yaml] \
	&& apk del build-dependencies \
	&& rm -rf /tmp/*

COPY templates/* /templates/
COPY bin/* /usr/bin/
RUN  chmod 755 /usr/bin/entrypoint

# CMD ["/usr/local/bin/umurmurd","-d","-c","/etc/umurmur/umurmurd.conf"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
CMD ["isso", "-c", "/etc/isso/isso.conf", "run"]
