# Jenkins Dockerizado

Dockerización del software de ALM Jenkins. Tiene docker instalado dentro de la imagen para poder correr docker in docker.
Esto facilita mucho poder trabajar con imágenes docker dentro del jenkins sin necesidad de tener que recurrir a una instalación
externa de docker.

### Persistencia

Para persistir los datos, es necesario exponer a volumen el siguiente directorio:

```shell
/var/jenkins_home
```
