[![Code Climate](https://codeclimate.com/github/nmeylan/RORganize-Plugin-Agile-Board/badges/gpa.svg)](https://codeclimate.com/github/nmeylan/RORganize-Plugin-Agile-Board)
# AgileBoard
An agile board plugin for RORganize app.
This agile board allow projects' members to write user stories, define sprint, link user stories with issues, group stories into epics...

# Install

From RORganize root dir :

    cd vendor/engines
    git clone https://github.com/nmeylan/RORganize-Plugin-Agile-Board.git agile_board

Add to RORganize app Gemfile :
    
    gem 'agile_board', path: 'vendor/engines/agile_board'
    
Then run db migration :

    rake db:migrate RAILS_ENV="production"
    
It's all the folks.
