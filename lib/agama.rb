require 'agama/graph'
require 'agama/traverser'
require 'agama/keyify'
require 'agama/config'
require 'agama/loader'
require 'json'

=begin rdoc
:title: Agama: A Graph Store for Ruby

Storing large graphs on disk is cumbersome process and difficult to manage. Modelling them as tables on a relational database requires a constant schema translation as nodes and edges are not the first class entities. Agama tries to provide a simple and intuitive way to store large graphs onto disks. Agama uses a key-value store like Tokyo Cabinet to serialize graphs internally.

== Installing the Gem
As Agama currently uses Tokyo Cabinet to store the data, make sure http://fallabs.com/tokyocabinet/ and its http://fallabs.com/tokyocabinet/rubypkg/ are installed and are working on the target machine.
Ubuntu users can install Tokyo Cabinet through apt-get.
  $ sudo apt-get install libtokyocabinet8 libtokyocabinet-ruby1.8
Once Tokyo Cabinet is installed, install the gem
  $ gem install agama
Note: Agama is currently tested only on Linux.

=end 