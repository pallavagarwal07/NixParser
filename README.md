# Nix Parser

This is a parser for nix expression language written in Go.

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
