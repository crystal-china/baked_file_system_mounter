require "baked_file_system"
require "./baked_file_system_mounter/version"
require "file_utils"

module BakedFileSystemMounter
  macro assemble(mapping)
    {% unless mapping.is_a? HashLiteral || mapping.is_a? ArrayLiteral %}
      {% raise "assemble only support Array or Hash as the only argument." %}
    {% end %}

    {% new_mapping = {} of String => String %}

    {% if mapping.is_a? ArrayLiteral %}
      {% for value in mapping %}
        {% new_mapping[value] = value %}
      {% end %}
    {% elsif mapping.is_a? HashLiteral %}
      {% for k, v in mapping %}
        {% if v.starts_with?('/') %}
          {% new_mapping[k] = v %}
        {% else %}
          {% new_mapping[k] = "./#{v.id}" %}
        {% end %}
      {% end %}
    {% end %}

    {% root = system("pwd").strip.id %}
    {% i, j = 0, 0 %}

    class BakedFileSystemMounter::Storage
      extend BakedFileSystem
      {% for key, value in new_mapping %}
        {% source_path = key.starts_with?('/') ? key : "#{root}/#{key.id}" %}

        # Directories still use `bake_folder`, while individual files are embedded
        # with `bake_file` so they can be mounted to an exact target path.
        {% if system(%<test -f "#{source_path.id}" && echo file || echo dir>).strip == "file" %}
          bake_file "{{key.id}}", {{ read_file(source_path.id) }}
          @@baked_files_{{i}} = ["{{key.id}}"] of String
        {% else %}
          bake_folder "{{source_path.id}}"
          @@baked_files_{{i}} = {{ run("./baked_file_system_mounter/baked_files", key).strip }} of String
        {% end %}
        {% i += 1 %}
      {% end %}

      def self.mount
        {% for key, value in new_mapping %}
          @@baked_files_{{j}}.each do |filename|
            # 1. 目录模式下 filename 是目录里的文件相对路径
            # 2. key 是被 bake 的根路径
            # 3. Dir.glob("#{dir}/**/*").select { |f| File.file?(f) } 不会把目录本身放进去，只会放文件
            # 4. 所以 filename == key 只有在“key 本身就是文件”时才成立
            target_file_name = if filename == "{{key.id}}"
                                 "{{value.id}}"
                               else
                                 filename.sub("{{key.id}}", "{{value.id}}")
                               end

            FileUtils.mkdir_p File.dirname(target_file_name) unless File.exists?(target_file_name)

            baked_file_name = if filename == "{{key.id}}"
                                "{{key.id}}"
                              else
                                filename.sub("{{key.id}}/", "")
                              end

            File.write(target_file_name, get(baked_file_name).gets_to_end)

            {% j += 1 %}
          end
        {% end %}
      end
    end
  end
end
