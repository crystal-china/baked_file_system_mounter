# baked_file_system_mounter

Assemble files and directories into an executable binary using `baked_file_system`
at compile time, then mount them onto a new file system at runtime.

Let us assume there are assets folders like this:


```sh
PROJECT_ROOT/
  src/assets/
  └── materialize
	  ├── css
	  │   └── materialize.min.css
	  └── js
		  └── materialize.min.js
```

What we want is:

1. Assemble assets files in `src/assets` folder into binary when build.
2. Then binary into `/foo` directory on target host, running it will extract assets from binary.

Look like this:

```sh
/foo/
  public/
  └── materialize
	  ├── css
	  │   └── materialize.min.css
	  └── js
		  └── materialize.min.js
3 directories, 2 files
```

With following configuration:

```crystal
require "baked_file_system_mounter"

BakedFileSystemMounter.assemble(
  {
    "src/assets" => "public",
  }
)

{% if flag?(:release) %}
  BakedFileSystemMounter::Storage.mount
{% end %}
```

Then you can use those assets both in development (`src/assets/materialize`) and
production (`public/materialize`), like this:

```erb
<html>
  <head>
    <link rel="stylesheet" href="/materialize/css/materialize.min.css" />
  </head>
  <body>
      <%= yield_content "footer" %>
  </body>
</html>
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     baked_file_system_mounter:
       github: crystal-china/baked_file_system_mounter
   ```

2. Run `shards install`

## Usage

`assemble` accepts either a `Hash` or an `Array`.

Use a `Hash` when you want to map a source path to a different target path.
Source paths may point to either a directory or a single file.
Relative source paths are resolved from the compile-time working directory
(`pwd`).

`assemble` supports string literals and string constants in the mapping.
String interpolation and other macro expressions are not supported.

```crystal
require "baked_file_system_mounter"

BakedFileSystemMounter.assemble(
  {
    "src/assets" => "public",
    "db" => "db",
  }
)

if APP_ENV == "production"
  # Mount files in `src/assets` into `public` and files in `db` into `db`.
  # Target folders will be created if they do not exist.
  BakedFileSystemMounter::Storage.mount
end

```

String constants are also supported:

```crystal
ASSETS_DIR = "src/assets"
PUBLIC_DIR = "public"

BakedFileSystemMounter.assemble(
  {
    ASSETS_DIR => PUBLIC_DIR,
  }
)
```

### Single file

You can also bake a single file to an exact target path:

```crystal
BakedFileSystemMounter.assemble(
  {
    "public/bun-manifest.json" => "public/bun-manifest.json",
  }
)
```

### Directory + file

Directories and files can be mixed in a single `assemble` call:

```crystal
BakedFileSystemMounter.assemble(
  {
    "public/assets" => "public/assets",
    "public/bun-manifest.json" => "public/bun-manifest.json",
    "markdowns" => "markdowns",
  }
)
```

### Array shorthand

You can pass an `Array` as argument too. In this case it uses `PWD` as the
default source and target path for each entry.

```crystal
BakedFileSystemMounter.assemble(["public", "db"])

# It's same as:

# BakedFileSystemMounter.assemble(
#   {
#     "public" => "public",
#     "db" => "db"
#   }
# )

if APP_ENV == "production" 
  BakedFileSystemMounter::Storage.mount
end

```

### Absolute target path

It can be used to mount assets outside the current directory, for example into
`/tmp`:

```crystal
BakedFileSystemMounter.assemble(
  {
    "sounds" => "/tmp/sounds",
  }
)

if APP_ENV == "production" 
  BakedFileSystemMounter::Storage.mount
end
```

### Absolute source directory

The source path can also be an absolute directory path:

```crystal
BakedFileSystemMounter.assemble(
  {
    "/opt/my_app/assets" => "public/assets",
  }
)
```

### Absolute source file

Absolute source paths also work for single files:

```crystal
BakedFileSystemMounter.assemble(
  {
    "/opt/my_app/bun-manifest.json" => "public/bun-manifest.json",
  }
)
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/crystal-china/baked_file_system_mounter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Billy.Zheng](https://github.com/zw963) - creator and maintainer
