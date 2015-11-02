gulp = require("gulp")
browserSync = require("browser-sync")
compass = require("gulp-compass")
sourcemaps = require("gulp-sourcemaps")
handleErrors = require("../util/handleErrors")
config = require("../config").sass
autoprefixer = require("gulp-autoprefixer")
minifyCSS = require("gulp-minify-css")

gulp.task "sass", ["images"], (->
  return gulp.src(config.src)
    .pipe(sourcemaps.init())
    .pipe(compass(config.settings))
    .on("error", handleErrors)
    .pipe(sourcemaps.write())
    .pipe(autoprefixer(browsers: ["last 2 version"]))
    .pipe do minifyCSS
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload(stream: true)))
