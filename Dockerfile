# Serve a static Flutter Web build with Nginx
FROM nginx:1.27-alpine

# Replace default site config
COPY nginx/conf.d/app.conf /etc/nginx/conf.d/default.conf

# Copy your compiled Flutter assets into Nginx's html dir
# Make sure you've run: flutter build web --release --base-href=/
COPY build/web/ /usr/share/nginx/html/

# (Optional) tiny healthcheck file
RUN echo "ok" > /usr/share/nginx/html/healthz

EXPOSE 80
