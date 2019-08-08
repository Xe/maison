# Package

version       = "0.1.0"
author        = "Christine Dodrill"
description   = "A dashboard for my home"
license       = "0BSD"
srcDir        = "src"
binDir        = "bin"
bin           = @["maison"]

# Dependencies

requires "nim >= 0.20.2", "jester", "dotenv", "tempdir"

--define: "ssl"

task fullbuild, "runs build steps":
  withDir "frontend":
    exec "browserify ./index.js -p tinyify -o ../public/bundle.js"

  if existsEnv "NIM_RELEASE":
    --define: "release"
    --threads: "on"

  setCommand "build"

task setup, "does basic setup stuffs":
  exec "npm install -g browserify"
  exec "git remote add dokku dokku@minipaas.xeserv.us:maison"

  withDir "frontend":
    exec "npm install"

task deploy, "deploy to minipaas":
  exec "docker build ."
  exec "git push dokku master"

