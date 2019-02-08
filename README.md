# Stream Searcher

## Summary
This application opens up 10 worker threads to search a stream for the string 'Lpfn'. To execute, first run ``bundle install`` in the root directory, then run ```ruby -Ilib exe/run```. The run time will default to 60 (seconds), but you may specify a different time by adding option flags:
 ```-t <seconds>``` or ```--time <seconds>```. You may display a list of option flags by using ```-h``` or ```--help```