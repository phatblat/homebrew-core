class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      :tag      => "1.7.1",
      :revision => "6bf45a0cfedc24d474391e2702ba24b5c4e8dc17"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    cellar :any
    sha256 "b985d100947063ee94961f7f1290f232786634b869d20d56bd553197cf91188b" => :catalina
    sha256 "c7005c34a3cf38d23f98e9cc238a0deae61f50ea5dfbcf51a34cc689a9db315e" => :mojave
  end

  depends_on "carthage" => :build
  depends_on :xcode => ["10.2", :build]

  def install
    # Working around build issues in dependencies
    # - Prevent warnings from causing build failures
    # - Prevent linker errors by telling all lib builds to use max size install names
    xcconfig = buildpath/"Overrides.xcconfig"
    xcconfig.write <<~EOS
      GCC_TREAT_WARNINGS_AS_ERRORS = NO
      OTHER_LDFLAGS = -headerpad_max_install_names
    EOS
    ENV["XCODE_XCCONFIG_FILE"] = xcconfig

    # Only build necessary dependencies
    system "carthage", "bootstrap", "--platform", "macOS", "Commandant"
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_include shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
