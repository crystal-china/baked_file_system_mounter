# Breaking changes

`BakedFileSystemStorage.mount` rename to `BakedFileSystemMounter::Storage.mount` since 0.6.0!

# baked_file_system_mounter

assemble files inside current directories into executable binary use `backed_file_system` at compile time, then mount it on new file system at runtime. 

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

With following configuration.

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

Then, use can use those assets both in development(src/assets/materialize) and production(public/materialize), like this:

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

You can passing a `Hash` as argument for mapping.

```crystal
require "baked_file_system_mounter"

#
# we assemble all files in `src/assets`,`db` into executable binary when we build,
BakedFileSystemMounter.assemble(
  {
    "src/assets" => "public",
    "db" => "db"
  }
)

if APP_ENV == "production"
  # we assemble the db into db folder too
  # Then mount files in `src/assets` into `public` and files in `db` into `db`.
  # folder will be created it if not exists.
  BakedFileSystemMounter::Storage.mount
end

```

You can pass a Array as argument too, in this case, it use `PWD` as default folder.

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

It can be used to mount assets outside current directory, e.g. /tmp

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
