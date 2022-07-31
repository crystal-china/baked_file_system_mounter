# baked_file_system_mounter

assemble files in assets folder into executable binary use `backed_file_system` at compile time, then mount it to new file system folder at runtime. 

Let us use a [kemal](https://github.com/kemalcr/kemal) as a example.

We save our assets file here


```sh
 ╰─ $ tree src/assets/
src/assets/
└── materialize
    ├── css
    │   └── materialize.min.css
    └── js
        └── materialize.min.js
```

What we want is assemble those assets file into binary when build.

Then, when copy binary to target environment, starting it, will create new folder like this with assets.

```sh
╰─ $ tree public
public/
└── materialize
    ├── css
    │   └── materialize.min.css
    └── js
        └── materialize.min.js
3 directories, 2 files
```

Any files you add to the `public` directory will be served automatically by Kemal by default.

So, it will load stylesheet correctly when you write ECR template like this.


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
       github: zw963/baked_file_system_mounter
   ```

2. Run `shards install`

## Usage

```crystal
# src/config/baked_file_system_mounter.cr

require "baked_file_system_mounter"

# 
# so, we assemble all files in `src/assets` into executable binary when we build.
BakedFileSystemMounter.assemble from: "src/assets", to: "public"

# Then mount those assembled files into `public` folder(will create it if not exists) will serve by kemal.
BakedFileSystemStorage.mount

```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/zw963/baked_file_system_mounter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Billy.Zheng](https://github.com/zw963) - creator and maintainer
