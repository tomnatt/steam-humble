# Steam Humble connection

App designed to give a complete list of all games in the Humble Monthly / Choice bundles and their Steam tags. Primary goal is to be able to find games which are co-op.

Written with Ruby 2.5.1 in mind and using Postgres.

To set up and run, clone the code then:

```
bundle install
bundle exec rake db:migrate
bundle exec rails s
```

To run the tests:
```
bundle exec rspec
```
