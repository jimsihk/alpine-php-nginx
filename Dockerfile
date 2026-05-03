FROM webdevops/php-nginx:8.4-alpine@sha256:a829a1110690b12dfa4d73ad23e35af52f18135a1c3d5292c5bf063c0e729818

LABEL org.opencontainers.image.title="alpine-php-nginx" \
      org.opencontainers.image.description="Lightweight container with NGINX & PHP-FPM based on Alpine Linux." \
      org.opencontainers.image.url="https://github.com/jimsihk/alpine-php-nginx" \
      org.opencontainers.image.source="https://github.com/jimsihk/alpine-php-nginx" \
      org.opencontainers.image.documentation="https://github.com/jimsihk/alpine-php-nginx"

RUN mkdir -p \
        /docker-entrypoint-init.d \
        /etc/nginx/conf.d/default/server \
        /var/www/html \
    && rm -f \
        /etc/nginx/conf.d/10-docker.conf \
        /etc/nginx/http.d/default.conf \
        /usr/local/etc/php-fpm.d/application.conf

COPY --chown=nobody rootfs/bin/docker-entrypoint.sh /bin/docker-entrypoint.sh
COPY --chown=nobody rootfs/docker-entrypoint-init.d/ /docker-entrypoint-init.d/
COPY --chown=nobody rootfs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nobody rootfs/etc/nginx/conf.d/security.conf /etc/nginx/conf.d/security.conf
COPY --chown=nobody rootfs/etc/php/conf.d/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY --chown=nobody rootfs/etc/php/conf.d/custom-opcache-jit.ini /usr/local/etc/php/conf.d/custom-opcache-jit.ini
COPY --chown=nobody rootfs/etc/php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chown=nobody rootfs/var/www/html/ /var/www/html/

RUN chmod +x /bin/docker-entrypoint.sh /docker-entrypoint-init.d/* \
    && chown -R nobody:nobody \
        /docker-entrypoint-init.d \
        /etc/nginx \
        /run \
        /usr/local/etc/php \
        /usr/local/etc/php-fpm.d \
        /var/lib/nginx \
        /var/log/nginx \
        /var/www/html

USER nobody

WORKDIR /var/www/html

ENV nginx_root_directory=/var/www/html \
    client_max_body_size=2M \
    clear_env=no \
    allow_url_fopen=On \
    allow_url_include=Off \
    display_errors=Off \
    file_uploads=On \
    max_execution_time=0 \
    max_input_time=-1 \
    max_input_vars=1000 \
    memory_limit=128M \
    post_max_size=8M \
    upload_max_filesize=2M \
    zlib_output_compression=On \
    date_timezone=UTC \
    opcache_jit_buffer_size=0 \
    opcache_jit=1235 \
    opcache_memory_consumption=128 \
    opcache_interned_strings_buffer=16 \
    opcache_max_accelerated_files=15000 \
    custom_router=''

ENV envsubst_config_list="/etc/nginx/nginx.conf \
                          /usr/local/etc/php/conf.d/custom.ini \
                          /usr/local/etc/php/conf.d/custom-opcache-jit.ini \
                          /usr/local/etc/php-fpm.d/www.conf"

EXPOSE 8080

ENTRYPOINT [ "/bin/docker-entrypoint.sh" ]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping || exit 1
