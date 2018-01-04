# Nix Parser

This is a parser for nix expression language written in Go.

To Install Dependencies:

```
go get -u golang.org/x/tools/cmd/goyacc
go get -u golang.org/x/tools/cmd/goimports
```

To Build:

```
git clone git@github.com:pallavagarwal07/NixParser
cd NixParser
mkdir build
go generate
```

To run:

```
cd build
go run *.go filename.nix
```

For example, filename.nix may contain:

```
{
    a = 5;
    b = "hello";
}
```
