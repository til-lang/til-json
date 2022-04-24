# til-json

## Build

1. `make`

## Usage

```tcl
> json.decode '{"alfa": 1}'
 dict(alfa=1)
> json.decode '[1, 2, 3]'
 (1 2 3)

> dict (alfa 1) | json.encode
 {"alfa":1}
> json.encode (1 2 3)
 [1,2,3]
```
