# absente

Absente is an OCaml that aims to provide an interface on top of Unix bindings.

It is not ready for usage, and really do not even have a fixed API (that explains why this README is so empty), you shouldn't use it.

I'd be glad to welcome any contributions. 

# Building process

You should use dune to build Absente.

This library depends on containers, containers-data, and extunix, and works when built with the latest version of theses library. (3.6, 3.6 and 0.3.2, respectively, at the time where I write this.)
