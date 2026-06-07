require "./spec_helper"

private SPEC_ROOT = "/tmp/baked_file_system_mounter_spec"

{% system("rm -rf /tmp/baked_file_system_mounter_absolute_source_assets") %}
{% system("mkdir -p /tmp/baked_file_system_mounter_absolute_source_assets") %}
{% system("cp spec/fixtures/external_assets/info.txt /tmp/baked_file_system_mounter_absolute_source_assets/info.txt") %}
{% system("cp spec/fixtures/external_config.json /tmp/baked_file_system_mounter_absolute_config.json") %}

BakedFileSystemMounter.assemble(
  {
    "spec/fixtures/assets"   => "/tmp/baked_file_system_mounter_spec/public/assets",
    "spec/fixtures/config.json" => "/tmp/baked_file_system_mounter_spec/public/config.json",
    "spec/fixtures/bun-manifest.json" => "/tmp/baked_file_system_mounter_spec/public/bun-manifest.json",
    "/tmp/baked_file_system_mounter_absolute_source_assets" => "/tmp/baked_file_system_mounter_spec/external/assets",
    "/tmp/baked_file_system_mounter_absolute_config.json" => "/tmp/baked_file_system_mounter_spec/external/config.json",
  }
)

describe BakedFileSystemMounter do
  before_each do
    FileUtils.rm_rf(SPEC_ROOT)
  end

  after_each do
    FileUtils.rm_rf(SPEC_ROOT)
  end

  it "mounts a baked directory" do
    BakedFileSystemMounter::Storage.mount

    File.read("#{SPEC_ROOT}/public/assets/hello.txt").should eq("Hello from a baked directory.\n")
  end

  it "mounts a baked file" do
    BakedFileSystemMounter::Storage.mount

    File.read("#{SPEC_ROOT}/public/config.json").should eq(%({"feature":"single-file"}) + '\n')
  end

  it "mounts a mix of directories and files" do
    BakedFileSystemMounter::Storage.mount

    File.read("#{SPEC_ROOT}/public/assets/hello.txt").should eq("Hello from a baked directory.\n")
    File.read("#{SPEC_ROOT}/public/config.json").should eq(%({"feature":"single-file"}) + '\n')
    File.read("#{SPEC_ROOT}/public/bun-manifest.json").should eq(%({"css/app.css":"css/app-123.css"}) + '\n')
  end

  it "mounts a directory from an absolute source path" do
    BakedFileSystemMounter::Storage.mount

    File.read("#{SPEC_ROOT}/external/assets/info.txt").should eq("Hello from an absolute source directory.\n")
  end

  it "mounts a file from an absolute source path" do
    BakedFileSystemMounter::Storage.mount

    File.read("#{SPEC_ROOT}/external/config.json").should eq(%({"feature":"absolute-single-file"}) + '\n')
  end
end
