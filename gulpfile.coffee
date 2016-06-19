gulp = require 'gulp'
plumber = require 'gulp-plumber'
gutil = require 'gulp-util'
jade = require 'gulp-jade'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'

jade_path = './public_src/**/*.jade'
sass_path = './public_src/**/*.sass';
coffee_path = ['./public_src/**/*.coffee', './index.coffee']

gulp.task 'jade', ->
	gulp.src jade_path
		.pipe plumber()
		.pipe jade()
		.pipe gulp.dest('public')

gulp.task 'sass', ->
	gulp.src sass_path
		.pipe sass({outputStyle: 'compressed'}).on('error', sass.logError)
		.pipe gulp.dest('public')

gulp.task 'coffee', ->
	gulp.src coffee_path[0]
		.pipe coffee({bare: true}).on('error', gutil.log)
		.pipe uglify()
		.pipe gulp.dest('public')
	gulp.src coffee_path[1]
		.pipe coffee({bare: true}).on('error', gutil.log)
		.pipe gulp.dest('./')

gulp.task 'watch', ->
	gulp.watch jade_path, ['jade']
	gulp.watch sass_path, ['sass']
	gulp.watch coffee_path, ['coffee']
