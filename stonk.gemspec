# frozen_string_literal: true

require_relative "lib/stonk/version"

Gem::Specification.new do |spec|
  spec.name = "stonk"
  spec.version = Stonk::VERSION
  spec.authors = ["Nick Jones"]
  spec.homepage = "https://github.com/punkstar/stonk.rb"
  spec.email = ["nick@nickjones.tech"]

  spec.summary = "A Ruby gem that fetches real-time stock prices from multiple sources."
  # spec.homepage = "https://github.com/punkstar/stonk.rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.cert_chain = ["etc/punkstar.pem"]
  spec.signing_key = if $PROGRAM_NAME =~ /gem\z/
    %x(op read "op://Private/RubyGem Signing Key/private key" --out-file ~/.ssh/rubygems-punkstar-private.pem --force)

    File.expand_path("~/.ssh/rubygems-punkstar-private.pem")
  end

  spec.metadata["source_code_uri"] = "https://github.com/punkstar/stonk.rb"
  spec.metadata["changelog_uri"] = "https://github.com/punkstar/stonk.rb/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end

  spec.bindir = "bin"
  spec.executables = ["stonk"]
  spec.require_paths = ["lib"]

  spec.add_dependency("logger", "~> 1.7")
end
