module.exports = (grunt)->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json'),
    coffee:
      options:
        sourceMap:true
      compile:
        files: 'dist/ShareCoffee.js' : ['license/*.coffee', 'src/**/*.coffee']
    simplemocha:
      options:
        compilers: 'coffee:coffee-script'
        reporter: 'spec'
      all:
        src: ['test/**/*.coffee']
    uglify:
      options:
        banner: '/* ShareCoffee (c) 2013 Thorsten Hans | dotnet-rocks.com | https://github.com/ThorstenHans/ShareCoffee/ | under MIT License | */'
      dist:
        files:
          'dist/ShareCoffee.min.js': 'dist/ShareCoffee.js'
    clean:
      dist: ['dist/**/*.src.coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.registerTask 'default', ['simplemocha', 'coffee','uglify','clean']
  grunt.registerTask 'test', ['simplemocha']
