# Nix Parser
[![Build Status](https://travis-ci.org/pallavagarwal07/NixParser.svg?branch=master)](https://travis-ci.org/pallavagarwal07/NixParser)

This is a parser for nix expression language written in Go.
This uses golang type aliases hence it is supported on go 1.9+. This may change in future.

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
