var gulp = require('gulp');

var coffee = require('gulp-coffee');
var plumber = require('gulp-plumber');
var concat = require('gulp-concat');
var jade = require('gulp-jade');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var declare = require('gulp-declare');
var minifyCss = require('gulp-clean-css');

var sass = require('gulp-sass');
var postcss = require('gulp-postcss');
var autoprefixer = require('autoprefixer');

var beep = require('beepbeep');
var _ = require('lodash');

function errorHandler(err) {
    beep(2);
    console.error(err.toString());
}

function relativePaths(parentPath, paths) {
    return _.map(paths, function (p) {
        return parentPath + p
    });
}

gulp.task("html", function () {
    gulp.src('src/html/**.jade')
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(jade({client: false}))
        .pipe(gulp.dest('dist'));
});

gulp.task("template", function () {
    gulp.src('src/template/**.jade')
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(jade({client: true}))
        .pipe(declare({namespace: 'WT', noRedeclare: true}))
        .pipe(concat('template.js'))
        .pipe(gulp.dest('dist'));
});

gulp.task("script", function () {
    var srcPaths = relativePaths("src/script/",
        ["api.coffee", "router.coffee", "common.coffee", "apk.coffee", "module/**/**.coffee", "main.coffee"]);
    gulp.src(srcPaths)
        .pipe(plumber({errorHandler: errorHandler}))
        //.pipe(sourcemaps.init())
        .pipe(coffee())
        .pipe(concat('app.js'))
        .pipe(uglify())
        //.pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('dist'));

    gulp.src('src/script/setup.coffee')
        .pipe(plumber({errorHandler: errorHandler}))
        //.pipe(sourcemaps.init())
        .pipe(coffee())
        .pipe(uglify())
        //.pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('dist'));

    gulp.src('src/script/jj.coffee')
        .pipe(plumber({errorHandler: errorHandler}))
        //.pipe(sourcemaps.init())
        .pipe(coffee())
        .pipe(uglify())
        //.pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('dist'));
});

gulp.task('style', [], function () {
    var srcPaths = relativePaths("src/style/", ["**.scss"]);
    gulp.src(srcPaths)
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(sass())
        .pipe(concat('app.css'))
        .pipe(minifyCss({compatibility: 'ie8'}))
        .pipe(postcss([autoprefixer({browsers: ['last 2 versions']})]))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('dist'));
});

gulp.task('image', [], function () {
    gulp.src('src/img/**')
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(gulp.dest('dist/img'));
});

gulp.task('lib', [], function () {
    gulp.src('src/lib/**')
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(gulp.dest('dist/lib'));
});

gulp.task('electron', [], function () {
    gulp.src('src/electron/**')
        .pipe(plumber({errorHandler: errorHandler}))
        .pipe(gulp.dest('dist'));
});

gulp.task('watch', ['default'], function () {
    gulp.watch('src/html/**', ['html']);
    gulp.watch('src/template/**', ['template']);
    gulp.watch('src/script/**', ['script']);
    gulp.watch('src/style/**', ['style']);
    gulp.watch('src/img/**', ['image']);
    gulp.watch('src/lib/**', ['lib']);
    gulp.watch('src/electron/**', ['electron']);
});

gulp.task('default', ["html", 'template', 'script', 'style', 'image', 'lib', 'electron']);