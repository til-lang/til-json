# til-json

## Build

1. `make`

## Usage

```tcl
json.decode '{"alfa": 1}' | as d
json.decode '[1, 2, 3]' | as l

dict (alfa 1) | dict.encode | as object_string
dict.encode (1 2 3) | as list_string
```
