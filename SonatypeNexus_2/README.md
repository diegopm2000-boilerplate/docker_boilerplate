# Sonatype nexus 2 dockerizado

## Instalación previa

Para que funcione correctamente el volumen donde hacemos la persistencia, hay que haberlo creado previamene así:

```shell
$ mkdir -p ./volumes/sonatypenexus/data
$ sudo chown -R 200 ./volumes/sonatypenexus/data
```

## Acceso a la consola web

http://localhost:8081/nexus


- user: admin
- password: admin123

## Subir un artefacto usando la consola web

Cómo subir un artefacto a Sonatype Nexus usando el cliente Web de Sonatype Nexus

Se necesita un usuario logado en el sistema Sonatype Nexus con permisos de administración necesarios para poder subir artefactos.

Paso que hay que seguir

1. Entramos en nuestro repositorio
2. Vamos a la pestaña de Artifact Upload
3. En GAV Definition seleccionamos: From POM
4. Pulsamos el botón de "Select POM to Upload" y navegamos por el explorador de ficheros hasta seleccionar el fichero .pom relacionado con el artefacto a subir.
5. Pulsamos en "Select Artifact(s) to Upload" y navegamos por el explorador de ficheros hasta seleccionar el fichero .jar relacionado con el artefacto a subir.
6. Pulsamos en el botón de "Add Artifacts", tras lo cual se añade el fichero .jar a la lista de Artifacts que se muestra a continuación.
7. Pulsamos en el botón de más abajo de "Upload Artifacts"

NOTA: No se muy bien porqué hay a veces pasa que hay que hacerlo dos veces para que suba el .jar. Si se sube el artefacto y no se refresca bien, volver a repetir los pasos hasta que suba.

## Subir un artefacto usando maven

Previamente, hemos de tener levantado un docker con Sonatype Nexus v2 escuchando en localhost por el puerto 8081.

### Modificaciones en el fichero pom.xml del proyecto

En el fichero pom.xml añadimos lo siguiente:

```code
<distributionManagement>
	   <snapshotRepository>
	      <id>nexus-snapshots</id>
	      <url>http://localhost:8081/nexus/content/repositories/snapshots</url>
	   </snapshotRepository>
</distributionManagement>
```

Añadimos al pom.xml el plugin específico de sonatype nexus, en lugar de usar el plugin por defecto:

__plugin por defecto__

```code
<plugin>
   <artifactId>maven-deploy-plugin</artifactId>
   <version>2.8.1</version>
   <executions>
      <execution>
         <id>default-deploy</id>
         <phase>deploy</phase>
         <goals>
            <goal>deploy</goal>
         </goals>
      </execution>
   </executions>
</plugin>
```

Para ello, deshabilitamos el plugin por defecto y habilitamos el específico

__plugin por defecto que deshabilitamos__

```code
<plugin>
   <groupId>org.apache.maven.plugins</groupId>
   <artifactId>maven-deploy-plugin</artifactId>
   <version>${maven-deploy-plugin.version}</version>
   <configuration>
      <skip>true</skip>
   </configuration>
</plugin>
```

(no hay que poner el que deshabilitamos en el pom.xml)

__plugin específico__

```code
<plugin>
   <groupId>org.sonatype.plugins</groupId>
   <artifactId>nexus-staging-maven-plugin</artifactId>
   <version>1.5.1</version>
   <executions>
      <execution>
         <id>default-deploy</id>
         <phase>deploy</phase>
         <goals>
            <goal>deploy</goal>
         </goals>
      </execution>
   </executions>
   <configuration>
      <serverId>nexus</serverId>
      <nexusUrl>http://localhost:8081/nexus/</nexusUrl>
      <skipStaging>true</skipStaging>
   </configuration>
</plugin>
```

Ahora tenemos que modificar el settings.xml de maven (situado en el directorio .m2 del home/user) para añadir el servidor de sonatype nexus:

```code
<servers>
   <server>
      <id>nexus-snapshots</id>
      <username>deployment</username>
      <password>the_pass_for_the_deployment_user</password>
   </server>
</servers>
```

Finalmente, para subir el artefacto, hacemos:

```shell
$ mvn clean deploy -Dmaven.test.skip=true
```

Evitar los test es normal, ya que el despliegue se considera lo último que se realiza en el pipeline de despliegue del proyecto (por ejemplo dentro de una automatización de Jenkins)

Si queremos que corran los test, pondríamos:

```shell
$ mvn clean deploy -Dmaven.test.skip=true
```

### Cómo subir al repositorio de snapshots o al de releases

Si hemos puesto como versión lo siguiente:

```code
<version>0.0.1-SNAPSHOT</version>
```

Se subirá al repositorio de __snapshots__

Si queremos que se suba al repositorio de __releases__, ponemos:

```code
<version>1.0.0-RELEASE</version>
```

Y además, tenemos que definir en el pom.xml el repositorio de releases:

```code
<repository>
			<id>nexus-releases</id>
			<url>http://localhost:8081/nexus/content/repositories/releases</url>
</repository>
```

Y en el settings.xml de maven configurarlo también:

```code
<server>
   <id>nexus-releases</id>
   <username>admin</username>
   <password>admin123</password>
</server>
```

Y volvemos a ejecutar:

```shell
$ mvn clean deploy -Dmaven.test.skip=true
```

### Error 400: Bad Request en los despliegues

Si ejecutamos por segunda vez el despliegue de la misma versión y falla dando un error 400, puede ser que no hayamos cambiado la versión del artefacto, en cuyo caso, o bien la cambiamos, o bien, habilitamos el redeploy en la configuración de Sonatype Nexus.
