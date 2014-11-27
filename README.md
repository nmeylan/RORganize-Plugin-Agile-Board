[![Code Climate](https://codeclimate.com/github/nmeylan/RORganize-Plugin-Agile-Board/badges/gpa.svg)](https://codeclimate.com/github/nmeylan/RORganize-Plugin-Agile-Board)

#Screenshot 
![Plan tab](https://cloud.githubusercontent.com/assets/1909074/5199894/b268b500-7560-11e4-9e99-a397fa58a4b7.png)

---

![Work tab](https://cloud.githubusercontent.com/assets/1909074/5199897/b5c476b2-7560-11e4-857e-af39c7ca1a41.png)

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
