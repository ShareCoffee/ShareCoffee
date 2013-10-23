module.exports = (grunt)->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json'),
    coffee:
      options:
        sourceMap:true
      compile:
        expand: true
        flatten: true
        cwd: 'src'
        src: '*.coffee'
        dest: 'dist'
        ext: '.js'
    simplemocha:
      options:
        compilers: 'coffee:coffee-script'
        reporter: 'spec'
      all:
        src: ['test/**/*.coffee']
    uglify:
      dist:
        files:
          'dist/ShareCoffee.min.js': 'dist/ShareCoffee.js'


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.registerTask 'default', ['simplemocha', 'coffee','uglify']
  grunt.registerTask 'test', ['simplemocha']
