# baked_file_system_mounter

assemble files in assets folder into executable binary use `backed_file_system` at compile time, then mount it to new file system folder at runtime. 

Let us assume save our assets file here before compile.


```sh
src/assets/
└── materialize
    ├── css
    │   └── materialize.min.css
    └── js
        └── materialize.min.js
```

What we want is assemble those assets file into binary when build.

Then, when copy binary to target host, and running it, will extract assets from binary into `/public` folder like this:

```sh
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
```


It will load stylesheet correctly when you write ECR template like this when in development/deployment environment.


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

In this example, we mount two folder, one for assets, one for migration.

```crystal
# src/config/baked_file_system_mounter.cr

require "baked_file_system_mounter"

#
# so, we assemble all files in `src/assets`,`db` into executable binary when we build,
BakedFileSystemMounter.assemble(
  {
    "src/assets" => "public",
    "db" => "db"
  }
)

# we assemble the db into db folder too
# Then mount those files in `src/assets` into `public` folder(will create it if not exists)
# will serve by kemal when server is start.
# mount `db` into `db` folder too for run migrate when server is starting on production..

if APP_ENV == "production"
  STDERR.puts "Mounting from baked file system ..."
  BakedFileSystemStorage.mount
end

```

You can pass a Array as argument too.

```crystal
# It same as this follwing code

# BakedFileSystemMounter.assemble(
#   {
#     "public" => "public",
#     "db" => "db"
#   }
# )

BakedFileSystemMounter.assemble(["public", "db"])

if APP_ENV == "production"
  STDERR.puts "Mounting from baked file system ..."
  BakedFileSystemStorage.mount
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
