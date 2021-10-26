###########################################
# Stage 1: Kompilacja i budowa kodu agulara
###########################################
# Użycie oficjalnego obrazu
FROM node:latest as build

#Ustawienie proxy dla budowy

RUN npm config set proxy http://proxy:8080
RUN npm config set https-proxy http://proxy:8080

# Ustawienie katalogu
WORKDIR /usr/local/app

# Dodanie kodu źródłowego
COPY ./ /usr/local/app/

# Instalacja zależności
RUN npm install -g npm@8.1.1
RUN npm i -g @angular/cli
RUN ng update
RUN npm update

# Budowa aplikacji
RUN npm run build

######################################
# Stage 2: Aplikacja  nginx server
#####################################

# Użycie oficjalnego obrazu nginx
FROM nginx:latest

# Kopiowanie wybudowanego kodu.
COPY --from=build /usr/local/app/dist/sample-app/ /usr/share/nginx/html/
COPY --from=build /usr/local/app/docker/default.conf /etc/nginx/conf.d/default.conf

RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

# Expose port 80
EXPOSE 80