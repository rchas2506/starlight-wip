# Stage 1: Build the application
FROM node:lts AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Configure Apache for HTTPS with Cloudflare certificates
FROM httpd:2.4 AS runtime

# Enable SSL and rewrite modules in Apache
RUN apt-get update && apt-get install -y \
    openssl && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i '/LoadModule ssl_module/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    sed -i '/LoadModule rewrite_module/s/^#//g' /usr/local/apache2/conf/httpd.conf

# Create directories for the website and SSL certificates
RUN mkdir -p /usr/local/apache2/conf/ssl && \
    mkdir -p /usr/local/apache2/htdocs/handyguides

# Copy SSL certificates
COPY astro.crt /usr/local/apache2/conf/ssl/astro.crt
COPY astro.pem /usr/local/apache2/conf/ssl/astro.pem

# Copy the build output to the "handyguides" directory
COPY --from=build /app/dist /usr/local/apache2/htdocs/handyguides/

# Add HTTPS and redirection configuration
RUN echo "\
<VirtualHost *:80>\n\
    ServerName handyguides\n\
    Redirect permanent / https://handyguides/\n\
</VirtualHost>\n\
\n\
<VirtualHost *:443>\n\
    ServerName handyguides\n\
    DocumentRoot \"/usr/local/apache2/htdocs/handyguides\"\n\
    SSLEngine on\n\
    SSLCertificateFile /usr/local/apache2/conf/ssl/astro.crt\n\
    SSLCertificateKeyFile /usr/local/apache2/conf/ssl/astro.pem\n\
    <Directory \"/usr/local/apache2/htdocs/handyguides\">\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>" \
> /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    echo "Include /usr/local/apache2/conf/extra/httpd-ssl.conf" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80 443
