class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "http://www.freetds.org/files/stable/freetds-1.00.81.tar.bz2"
  mirror "https://fossies.org/linux/privat/freetds-1.00.81.tar.bz2"
  sha256 "76e8d97dfb36924c4e7815470c9de521a86014f842d868f269dfd3054feed543"

  bottle do
    sha256 "30b2e0164384f7fca4dc7b037b99996e5a0beb5e66196c591d5fc88178d90e3c" => :high_sierra
    sha256 "5f6ea18392b4249e5410c72de975630ecd10e7c38c4b03448177c40f02769a38" => :sierra
    sha256 "24ff1a58281e8b2507d54a6a279317898e73cd3490f5d4000d5d79493182816b" => :el_capitan
  end

  head do
    url "https://github.com/FreeTDS/freetds.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  option "with-msdblib", "Enable Microsoft behavior in the DB-Library API where it diverges from Sybase's"
  option "with-sybase-compat", "Enable close compatibility with Sybase's ABI, at the expense of other features"
  option "with-odbc-wide", "Enable odbc wide, prevent unicode - MemoryError's"
  option "with-krb5", "Enable Kerberos support"

  deprecated_option "enable-msdblib" => "with-msdblib"
  deprecated_option "enable-sybase-compat" => "with-sybase-compat"
  deprecated_option "enable-odbc-wide" => "with-odbc-wide"
  deprecated_option "enable-krb" => "with-krb5"

  depends_on "pkg-config" => :build
  depends_on "unixodbc" => :optional
  depends_on "libiodbc" => :optional
  depends_on "openssl" => :recommended

  def install
    if build.with?("unixodbc") && build.with?("libiodbc")
      odie "freetds: --without-libiodbc must be specified when using --with-unixodbc"
    end

    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.3
      --mandir=#{man}
    ]

    if build.with? "openssl"
      args << "--with-openssl=#{Formula["openssl"].opt_prefix}"
    end

    if build.with? "unixodbc"
      args << "--with-unixodbc=#{Formula["unixodbc"].opt_prefix}"
    end

    if build.with? "libiodbc"
      args << "--with-libiodbc=#{Formula["libiodbc"].opt_prefix}"
    end

    # Translate formula's "--with" options to configuration script's "--enable"
    # options
    %w[msdblib sybase-compat odbc-wide krb5].each do |option|
      args << "--enable-#{option}" if build.with? option
    end

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end
