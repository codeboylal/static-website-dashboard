# FROM nginx

# WORKDIR /app/website-file/

# RUN rm -rf /usr/share/nginx/html/*

# COPY . /usr/share/nginx/html/

# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]

FROM nginx

WORKDIR /app/website-file/

RUN rm -rf /usr/share/nginx/html/*

COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]