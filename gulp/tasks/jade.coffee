gulp = require("gulp")
browserSync = require("browser-sync")
handleErrors = require("../util/handleErrors")
jade = require('gulp-jade')
config = require("../config").jade

gulp.task "jade", (->
  gulp.src(config.src).pipe(jade()).on("error", handleErrors)
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload(stream: true))

  gulp.src(config.srcTemplate).pipe(jade()).on("error", handleErrors)
    .pipe(gulp.dest(config.dest + '/templates'))
    .pipe(browserSync.reload(stream: true))
  return)














