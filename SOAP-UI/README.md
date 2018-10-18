# Soap UI Dockerizado para servir mockups de proyectos basados en SOAP.

Se parte de la dockerización de docker-hub siguiente:

https://hub.docker.com/r/fbascheper/soapui-mockservice-runner/


### 0. Estructura de carpetas

- custom: modificación de la imagen base dockerizada de soap-ui mockservice runner. Permite inyectar un mock hecho a medida.

- default: imagen default de la dockerización de soap-ui mockservice runner. Usa un mock que viene por defecto en la imagen.

- node: Ejemplo de consumo del sevicio soap usando node y la libreria de npm "soap".

- Postman: colecciones de postman para atacar tanto al servicio que usa la imagen default como la imagen custom.

- soap: Proyecto Soap-UI

### 1. Configuración por defecto a modo de test

Para ejecutar un SOAP-UI con la configuración por defecto, nos vamos a la carpeta default.

La configuración por defecto mínima, usa un proyecto SOAP-UI de xml ya instalado en la imagen por defecto, en el directorio del contenedor:

/home/soapui/soapui-prj/default-soapui-project.xml

Partimos del siguiente docker-compose.yml:

```yml
soap-ui:
  image: fbascheper/soapui-mockservice-runner
  ports:
    - "8080:8080"
  environment:
    - MOCK_SERVICE_NAME=BLZ-SOAP11-MockService
    - MOCK_SERVICE_PATH=/BLZMockService
    - PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml
```

Para levantar el servicio, hacemos:

```shell
$ docker-compose up
```

Para probar el API SOAP, hacemos:

```shell
$ curl http://localhost:8080

<html>
    <body>
        <p>There are currently 1 running SoapUI MockServices</p>
        <ul>
            <li>
                <a href="/BLZMockService?WSDL">BLZ-SOAP11-MockService</a>
            </li>
        </ul>
    </p>
</body>
</html>
```

Esto nos indica que hay un Web Service SOAP escuchando con el nombre BLZMockService.

Lo invocamos, creando en postman una llamada, teniendo en cuenta lo siguiente:

- method: post
- body: raw (text/xml)

```xml
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:blz="http://thomas-bayer.com/blz/">
   <soap:Header/>
   <soap:Body>
      <blz:getBank>
         <blz:blz>60030700</blz:blz>
      </blz:getBank>
   </soap:Body>
</soap:Envelope>
```

Ejecutando la llamada, nos ha de devolver el siguiente resultado:

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
    <soapenv:Body>
        <ns1:getBankResponse xmlns:ns1="http://thomas-bayer.com/blz/">
            <ns1:details>
                <ns1:bezeichnung>AKTIVBANK</ns1:bezeichnung>
                <ns1:bic>AKBADES1XXX</ns1:bic>
                <ns1:ort>Pforzheim</ns1:ort>
                <ns1:plz>75179</ns1:plz>
            </ns1:details>
        </ns1:getBankResponse>
    </soapenv:Body>
</soapenv:Envelope>
```

### 2. Configuración para un proyecto SOAP-UI customizado.

#### 2.1. Creamos una carpeta para el proyecto con la siguiente estructura:

  - WSDL --> carpeta donde dejamos el fichero wsdl y los schemas
  - soap-project --> carpeta donde vamos a dejar el proyecto de Soap-ui una vez creado.
  - Dockerfile --> fichero principal para la creación de la imagen docker

El fichero Dockerfile sería este:

```docker
### Extends image from soapui-mockservice-runner
FROM fbascheper/soapui-mockservice-runner

### File Author / Maintainer
MAINTAINER "Diego Perez dperez@tcpsi.es"

### Open Ports
EXPOSE 8080

### Copy soap xml custom project
ADD soap-project /home/soapui/soapui-prj/
```

#### 2.2. Creamos un proyecto con SOAP-UI vacío

Nos aseguramos de darle un nombre adecuado, por ejemplo: __Cuentas__

#### 2.3. Añadir el fichero WSDL al proyecto

Desde Soap-UI, añadimos el WSDL que tenemos en la carpeta WSDL, marcando la casilla de "Create MockService"

Damos un nombre adecuado (por ejemplo __CuentasMockService__) al mockService cuando nos lo pregunte el wizard.

#### 2.4. Guardar el proyecto SOAP-UI

Guardamos el proyecto Soap-UI en la carpeta soap-project, dando un nombre (por ejemplo: __Cuentas-soapui-project.xml__)

#### 2.5 Creamos un docker-compose para arrancar el servicio

```yml
version: "2.0"

services:

  mockwscuentas:
    build: mockWSCuentas
    image: mockwscuentas
    ports:
     - "0.0.0.0:8105:8080"
    environment:
    - MOCK_SERVICE_NAME=CuentasMockService
    - MOCK_SERVICE_PATH=/mockBAMOBIPGLSoapBindingHTTP
    - PROJECT=/home/soapui/soapui-prj/Cuentas-soapui-project.xml
```

Los valores que tenemos que poner como variables de entorno (environment) son los siguientes:

- MOCK_SERVICE: Nombre del servicio mock que está asociado al proyecto de SOAP-UI. En nuestro caso, era CuentasMockService.
- MOCK_SERVICE_PATH: El path del mockService que hemos creado. Se puede obtener desde Soap-UI consultando el wizard MockService Properties que aparece en la parte inferior de la pantalla.
- PROJECT: Ponemos la ruta donde estamos copiando el proyecto de SOAP-UI y su nombre.

#### 2.6 Arranque el servicio

Basta con ejecutar:

```shell
$ docker-compose up
```
