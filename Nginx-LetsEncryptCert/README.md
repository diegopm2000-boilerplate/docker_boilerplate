# Lets Encrypt Certificate

Extraído de: https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

NOTAS:

- Let's Encrypt no funciona para localhost, en este caso mejor usar como recomiendan en la documentación un certificado autogenerado

- Let's Encrypt usa el protocolo ACME para conectarse con nuestro servidor, realiza una prueba de verificación de dominio (necesita un dominio DNS, no funciona con la IP tal cual) contra nuestro servidor y es capaz de generar y actualizar los certificados.


