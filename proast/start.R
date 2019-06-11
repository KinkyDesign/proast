require(jsonlite)
require(proast61.5)
require(plumber)
pr<- plumber::plumb('/Users/pantelispanka/Jaqpot/proast/proasttest.R')
pr$run(port = 5518)


require(jsonlite)
require(proast61.5)
require(plumber)
pr<- plumber::plumb('/Users/pantelispanka/Jaqpot/proast/proasttest3.R')
pr$run(port = 5518)

require(jsonlite)
require(proast61.5)
require(plumber)
pr<- plumber::plumb('/Users/pantelispanka/Jaqpot/proast/proasttest2.R')
pr$run(port = 5518)

require(jsonlite)
require(proast61.5)
require(plumber)
pr<- plumber::plumb('/Users/pantelispanka/Jaqpot/proast/proast.R')
pr$run(port = 5518)



Warning in if (ans.all$dtype != 6) ans.all$alfa.length <- 0 :
  the condition has length > 1 and only the first element will be used