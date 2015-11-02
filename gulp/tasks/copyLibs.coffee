gulp = require("gulp")
config = require("../config").copyLibs

gulp.task "copyLibs", [], ->
  #gulp.src("#{config.libs}/normalize/**").pipe(gulp.dest(config.dest + '/lib'))
  #gulp.src("#{config.libs}/angular-ui/**").pipe(gulp.dest(config.dest + '/lib'))
  #gulp.src("#{config.libs}/angular-sanitize/**").pipe(gulp.dest(config.dest + '/lib'))
  gulp.src("#{config.libs}/lodash-2.4.1/**").pipe(gulp.dest(config.dest + '/lib/lodash'))
  gulp.src("#{config.libs}/momentjs/**").pipe(gulp.dest(config.dest + '/lib/momentjs'))
  #gulp.src("#{config.libs}/iscroll/**").pipe(gulp.dest(config.dest + '/lib/iscroll'))
  gulp.src("#{config.libs}/classie/**").pipe(gulp.dest(config.dest + '/lib/classie'))
  gulp.src("#{config.libs}/modernizr/**").pipe(gulp.dest(config.dest + '/lib/modernizr'))
  gulp.src("#{config.libs}/bxslider/**").pipe(gulp.dest(config.dest + '/lib/bxslider'))
  gulp.src("#{config.libs}/grid-gallery/**").pipe(gulp.dest(config.dest + '/lib/grid-gallery'))
  gulp.src("#{config.libs}/jquery-rss/**").pipe(gulp.dest(config.dest + '/lib/jquery-rss'))
  return