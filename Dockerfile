FROM nginx:alpine

# نصب ابزار envsubst برای جایگزینی متغیرها
RUN apk add --no-cache gettext

# کپی فایل کانفیگ Nginx
COPY nginx.conf /etc/nginx/nginx.conf.template

# اسکریپت ورودی برای جایگزینی متغیرها
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# پورت پیش‌فرض
EXPOSE 8080

# اجرای اسکریپت ورودی
ENTRYPOINT ["/entrypoint.sh"]
