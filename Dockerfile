FROM nginx:stable-alpine

ENV TZ=America/Sao_Paulo

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apk del tzdata

RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx

EXPOSE 8080

RUN rm /etc/nginx/conf.d/default.conf && rm /etc/nginx/nginx.conf

COPY default.conf /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

RUN export APP_NAME=$(ls /dist | head -n 1) && \
    echo "Application name: $APP_NAME" && \
    mv /dist/$APP_NAME /dist/app

COPY /dist/app /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
