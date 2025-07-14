# Breaking Changes

As of version 0.6.0, the method `BakedFileSystemStorage.mount` has been renamed
to `BakedFileSystemMounter::Storage.mount`.


# baked_file_system_mounter

The baked_file_system_mounter allows you to assemble files in the a directory 
(current working directory by default) into binary executable at compile time 
(using baked_file_system) and mount the files back into a new file system at runtime.

## Overview

Imagine you have an assets folder structured like this:


```sh
PROJECT_ROOT/
  src/assets/
  └── materialize
	  ├── css
	  │   └── materialize.min.css
	  └── js
		  └── materialize.min.js
```

If you want to:

1. Compile the files in the `src/assets` folder into a binary during the build process.
2. At runtime, extract the assets from the binary and make them available in the 
   directory `/foo` on the target host.

After running, your directory structure will look like this:

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

This can be achieved with the following configuration:

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

Now you can access the assets in both development (src/assets/materialize) 
and production (public/materialize), like this:

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

### You can pass a Hash as an argument to define folder mappings

```crystal
require "baked_file_system_mounter"

#
# Assemble files from `src/assets` and `db` into the executable binary during build
BakedFileSystemMounter.assemble(
  {
    "src/assets" => "public",
    "db" => "db"
  }
)

if APP_ENV == "production"
  # Mount the contents during runtime
  # Files from `src/assets` will appear in `public`
  # Files from `db` will appear in `db`
  BakedFileSystemMounter::Storage.mount
end

```

### Using an Array for default mapping

You can also pass an Array as an argument for default mappings. In this case, 
the current working directory (PWD) is used as the base directory.

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
### Mounting files outside current directory

You can even mount assets outside the current working directory. 

For example,  /tmp:


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
