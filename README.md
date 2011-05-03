# OpenProtocol
##  Setting up a development environment on OS X

_(We assume here that you have a github account and commit access to the repo)_

* Get [homebrew](http://mxcl.github.com/homebrew/).
* Get [rvm](https://rvm.beginrescueend.com/).
* `rvm install ree`
* `rvm --default ree`
* `brew install mysql`
    * follow the bootstrap and autoload instructions provided
* `brew install sphinx`
    * follow the autoload instructions provided
* `gem install bundler`
* `brew install git`
* `cd /your/work/area`
* `git clone git@github.com:ericmeltzer/open-protocol.git`
* `cd open-protocol`
* `bundle install --path vendor/app_gems`
* `bundle exec rake db:create`
* `bundle exec rake db:migrate`
* `bundle exec rails server`
* Visit [http://localhost:3000/]() and you're set!