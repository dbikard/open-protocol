# OpenProtocol
## AWS needed

In order to operate or stage OpenProtocol, you need to be registered for RDS, EC2, and SES.

Specifically for SES, you must verify the email address from which your application will be sending email. See [this document](http://docs.amazonwebservices.com/ses/latest/DeveloperGuide/index.html?InitialSetup.EmailVerification.html) for how to verify an email, and then fill in that email in `config/initializers/email.rb`. See below for more details.

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
* Run, `bundle exec rake secret` and then paste that value into the empty string in `config/initializers/secret_token.rb` that follows `SECRET_TOKEN = `
* Fill in the `FROM_EMAIL_ADDRESS` variable with the email address you verified with SES.
* `bundle exec rake db:create`
* `bundle exec rake db:migrate`

* `bundle exec rails server`
* Visit [http://localhost:3000/]() and you're set!

##  Creating a staging environment on AWS

_(We assume that you have already set up an AWS account and have set up the dev environment as laid out above)_

**NOTE: All of this must be done on us-east**

* Log onto the AWS management console.
* Select the EC2 tab. Select the `Key Pairs` subsection.
* Click `Create Key Pair` and name it `gsg-keypair`. It will download as `gsg-keypair.pem`.
* Set up the keys:

        mkdir ~/.ec2
        cd ~/.ec2
        mv ~/Downloads/gsg-keypair.pem gsg-keypair
        ssh-keygen -y -f gsg-keypair > gsg-keypair.pub


**MARKER1**

* Now select the `Security Groups` section. Create a new group, call it `open_protocol_staging_app`, and the description `Rubber automatic security group for role: app`. Leave the rest default and create it.
* Select the RDS tab. Start an instance (db.m1.small should suffice). 5GB of storage should suffice. Call it `staging`. Choose some username and password that you remember. On the next screen, name the database `open_protocol`. The rest of the page is fine as a default. On the next page, leave all the backup settings as the default, and then finally launch the instance. Wait for it to boot. Note the `Endpoint` field in the bottom pane.
* Go to the `DB Security Groups` section. Select the `default` security group. In the bottom pane, under the `Description` header, you should see an `Add` button. Select `EC2 Security Group` from the selector and then paste `open_protocol_staging_app` into the `Security Group` field and your AWS Account ID in to the appropriate field. Click `Add`.

The above only needs doing once, the first time you create a staging environment. Now, we modify our local files for staging deployment.

**NOTE: You should NOT push these changes to Github, or else you will be PUBLICIZING YOUR PRIVATE EC2 CREDENTIALS! Try using a local branch to store this information, which you can rebase on `master`.**

* In `config/database.yml`, edit the `staging` entry to look something like:

        staging:
          adapter: mysql2
          database: open_protocol
          host: master.blah-blah-blah.us-east-1.rds.amazonaws.com
          username: dbusername
          password: dbpassword
          port: 3306

  Where `host` is the `Endpoint` and `username` and `password` are what were specified when creating the RDS instance.

* In `config/ses.yml`, edit the `staging` entry with your SES credentials. (Just your regular AWS creds.)
* In `config/rubber/rubber.yml`, fill out the `admin_email` entry with an email address where system notifications should go. Under `cloud_providers`, `aws`, fill out the `access_key`, `secret_access_key`, and `account` fields with the appropriate values from your AWS account.
* In `config/s3.yml`, fill out the `staging` entry. For `bucket`, call it `openprotocols-images-staging` or something to that effect if that is taken.
* Assuming you have signed up for recaptcha, enter your credentials into `config/initializers/recaptcha.rb`.
* Run, `bundle exec rake secret` and then paste that value into the empty string in `config/initializers/secret_token.rb` that follows `SECRET_TOKEN = `
* Now simply run `RUBBER_ENV=staging bundle exec cap rubber:create_staging` and just accept the defaults all the way through. It will prompt you for the local machine's sudo password in order to modify `/etc/hosts` with the `staging.openprotocols.net` alias.

This process should create the application server instance, configure it, and deploy code to it over the course of about 20 minutes.

Any subsequent code deploys to the same, existing staging environment can be done with `RUBBER_ENV=staging bundle exec cap deploy`. This will deploy the exact code you have locally to the server.

**NOTE: the staging environment creation will add an entry to your `/etc/hosts` file that will alias `staging.openprotocols.net` to the staging env.**

To destroy the staging environment, `RUBBER_ENV=staging bundle exec cap rubber:destroy_staging`. This will destroy the application server instance, but you have to manually shut down the RDS instance in the AWS console.

## Creating a production environment on AWS

Until there's a need to create a larger production environment, we will use the `bundle exec cap rubber:create_staging` shortcut to launch production. To do this we need to do the following:

* Go to the RDS tab and create a new `DB Security Group` called `production`.
* Then, follow the steps for setting up staging, above, except for creating a new keypair. (That is, from **MARKER1** downward.)
* When creating the RDS instance for production, choose `production` as the DB security group, on the second screen. This is so that the staging and development environments cannot speak to the production DB, just in case of terrible things happening.
* For safety, set a secure username and password for the web tools in `config/rubber/rubber.yml`:

        web_tools_user: admin
        web_tools_password: sekret

* When modifying the config files, use `production` instead of `staging`. For instance, the RDS instance name should be `production` instead of `staging` and the security group name `open_protocol_production_app` instead of `open_protocol_staging_app`.
* When filling out `database.yml` and `s3.yml` be sure to fill out the `production` sections. Remember that you must choose a different bucket name for production.
* When creating the production database, you might want to provision a bit more space, say 10-20GB, given how cheap storage is.
* Be sure to select a new `SECRET_TOKEN` for production.

Finally, `RUBBER_ENV=production bundle exec cap rubber:create_staging`. Leave the default alias of production. Do NOT have it remove the staging security groups if you have your staging environment up in parallel.

## Production notes:

Web tools (HAProxy monitoring, Monit) can be found at https://ENVNAME.openprotocols.net:8443

The credential is the one set in `config/rubber/rubber.yml` under `web_tools_user` and `web_tools_password`.

If production starts to get slow because of load, and it's not the DB (which you'll be able to see easily if you go to the AWS console under RDS, select the instance, and view the graphs in the bottom pane), you can upgrade the instance size to a `c1.medium` for the application server. Do this by modifying this entry `image_type` in `config/rubber/rubber.yml` to `c1.medium`:
        cloud_providers:
          aws:
          ...
            image_type: m1.small

If Sphinx starts to hit it's memory usage limits (which you can see in Monit) for indexing, you can up this by changing the entry in `config/rubber/common/sphinx.yml` from `256M` to any memory string that a Sphinx config can understand.

A clever way of managing all this configuration would be to create a git branch called `staging` and another called `production`. Check in the appropriate config changes to these branches only, and do NOT push them to GitHub. When new changes are added to master and you want to deploy them to staging or production, simply checkout the appropriate branch, rebase master, and then deploy. Though remember that you will have to be very specific about what you push to GitHub in order not to expose your AWS account.