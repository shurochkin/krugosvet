dest = "./build"
src = "./src"
libs = "./static/libs"

module.exports =

  copyLibs:
    dest: dest
    libs: libs

  browserSync:
    server:

    # We're serving the src folder as well
    # for sass sourcemap linking
      baseDir: [dest, src]

    files: [
        "#{dest}/**"
      # Exclude Map files
        "!#{dest}/**.map"
    ]

  jade:
    src: "#{src}/jade/*.jade"
    srcTemplate: "#{src}/jade/templates/**/*.jade"
    srcWatch: "#{src}/jade/**/*.jade"
    dest: dest

  sass:
    src: "#{src}/sass/**/*.{sass,scss}"
    dest: dest + "/css"
    settings:
    # Required if you want to use SASS syntax
    # See https://github.com/dlmanning/gulp-sass/issues/81
      sass: './src/sass'
      css: './build/css'
      sourceComments: "map"
      imagePath: "/img" # Used by the image-url helper
      require: ['susy', 'breakpoint', 'modular-scale']

  images:
    src: "#{src}/img/**"
    dest: "#{dest}/img"

  markup:
    src: "#{src}/htdocs/**"
    dest: dest

  browserify:

  # Enable source maps
    debug: false

  # Additional file extentions to make optional
    extensions: [".coffee", ".hbs"]

  # A separate bundle will be generated for each
  # bundle config in the list below
    bundleConfigs: [
      {
        entries: src + "/script/app.coffee"
        dest: dest + "/js/"
        outputName: "app.js"
      }
#      {
#        entries: src + "/javascript/util.coffee"
#        dest: dest
#        outputName: "test.js"
#      }
    ]