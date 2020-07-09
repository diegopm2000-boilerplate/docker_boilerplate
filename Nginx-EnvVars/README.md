# Environment variables in Nginx 1.19 or upper

Support for environment variables in Nginx.

Out-of-the-box, nginx doesn't support environment variables inside most configuration blocks. But this image has a function, which will extract environment variables before nginx starts.

Here is an example using docker-compose.yml:

```yaml
web:
  image: nginx
  volumes:
   - ./templates:/etc/nginx/templates
  ports:
   - "8080:80"
  environment:
   - NGINX_HOST=foobar.com
   - NGINX_PORT=80
```

By default, this function reads template files in /etc/nginx/templates/*.template and outputs the result of executing envsubst to /etc/nginx/conf.d.

So if you place templates/default.conf.template file, which contains variable references like this:

listen       ${NGINX_PORT};
outputs to /etc/nginx/conf.d/default.conf like this:

listen       80;