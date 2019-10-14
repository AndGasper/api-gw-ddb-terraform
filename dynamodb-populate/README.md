## Installing go dependencies (since I'm still new to this)
```
go get github.com/aws/aws-sdk-go/aws
```

## Inserting Records
```
go run dynamo-db-load-items.go
```

## Go project structure is supposed to be like:
```
- bin
- pkg
- src
- vendor
```

- [Example Go Project Layout](https://github.com/golang-standards/project-layout)


```
- bin -> binaries
- pkg -> compiled src objects
- src -> source code for project
- vendor -> application dependencies
```