FROM nginx:alpine

ADD config/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/log/nginx

CMD ["nginx", "-g", "daemon off;"]