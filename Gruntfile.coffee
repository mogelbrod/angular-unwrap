module.exports = (grunt) ->
  # grunt-* dependencies
  grunt.loadNpmTasks "grunt-#{dep}" for dep in [
    "newer"
    "contrib-coffee"
    "contrib-jade"
    "contrib-watch"
    "contrib-connect"
  ]

  grunt.initConfig
    pkg: grunt.file.readJSON './package.json'

    jade:
      views:
        expand: true
        cwd: 'src'
        src: '**/*.jade'
        dest: 'build'
        ext: '.htm'

    coffee:
      options:
        bare: true
        # join: true
      scripts:
        expand: true
        cwd: 'src'
        src: '**/*.coffee'
        dest: 'build'
        ext: '.js'

    connect:
      server:
        options:
          base: 'build'
          port: 3001
          livereload: 35731

    watch:
      options:
        livereload: 35731
      jade:
        files: ['src/**/*.jade']
        tasks: 'newer:jade'
      coffee:
        files: ['src/**/*.coffee']
        tasks: 'newer:coffee'

  grunt.registerTask 'build', [
    'jade'
    'coffee'
  ]

  grunt.registerTask 'server', [
    'build'
    'connect'
    'watch'
  ]
  grunt.registerTask 'default', 'server'

