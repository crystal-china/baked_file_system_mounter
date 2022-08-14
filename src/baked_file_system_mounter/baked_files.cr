p Dir.glob("#{ARGV[0]}/**/*").select {|file| File.file? file }
