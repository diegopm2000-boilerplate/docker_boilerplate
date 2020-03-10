# Golang Compiler

Para compilar la aplicación de go situada en el directorio actual escribimos:

```shell
$ docker run --rm -v "$PWD":/usr/src/myapp -w /usr/src/myapp golang:1.6 go build -v
```

Nos compilará la aplicación y creará el fichero myapp ejecutable para nuestro entorno.
