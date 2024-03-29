#* @post /proast
#* @json

function(dataset,predictionFeature,parameters){
    #dataset:= list of 2 objects - 
    #datasetURI:= character sring, code name of dataset
    #dataEntry:= data.frame with 2 columns, 
    #1st:name of compound,2nd:data.frame with values (colnames are feature names)
    #predictionFeature:= character string specifying which is the prediction feature in dataEntry, 
    #parameters:= list with parameter values-- here awaits a list with four elemnts: 
    #nTrials (a numeric value indicating number of trials suggested, if 0 then an estimated number is suggested),
    #criterion (a character value to indicate which optimal deisgn to apply. Possible values are  'D', 'A', 'I'. Default is 'D'),
    #form (a string indicating the formula of the deisgn- 'linear','quad','cubic','cubicS')),
    #r2.threshold (numeric value indicating the r2 threshold value. If the data supplied provides r2 value greater 
    #than the threshold value, a stop message is returned.).
    dat<- dataset$dataEntry$values#dataset$dataEntry[,3]# data table
    dim.dat<- dim(dat)
    
    dat1.yname<- predictionFeature# dat1$predictionFeature #string to indicate dependent variable
    
    ind.dat<- colnames(dat)
    #sel.dat<- seq(2,2*dim.dat[2],by=2)
    #dat.names<- unlist(strsplit(dataset$features[order(dataset$features[,2]),3],"\""))[sel.dat]
    dat.names<- dataset$features[order(dataset$features[,2]),3]
    colnames(dat)<- dat.names
    
    depend.indx<- which(colnames(dat) %in% dat1.yname)
    dat1.xname<- parameters$indiVariable# name
    indi.indx<- which(colnames(dat) %in% dat1.xname) 
    
    #load('.trial1.RData')# includes ans.all
    #load('.changeV.rda')# inlcudes changeV data.frame with names of the variables in ans.all that need to change
    #load(changeV)
    #load(ans.all)
    #data(sysdata, envir=environment())
    changeV<- read.table('change_variables.txt',col.names='change_variables',colClasses='character')
    load('trial1.RData')
    
    ans.all.new<- if(is.null(parameters$ans.all)==FALSE){ans.all}else{parameters$ans.all}
      
      names.ans.all<- names(ans.all)
      pos.ans.all<- which(names(ans.all) %in% changeV[,1])
      
      ans.all.new[[pos.ans.all[1]]]<- indi.indx #xans index
      names(ans.all.new[[pos.ans.all[1]]])<- dat1.xname #xans name
      ans.all.new[[pos.ans.all[2]]]<- depend.indx #yans index
      names(ans.all.new[[pos.ans.all[2]]])<- dat1.yname #yans name
      ans.all.new[[pos.ans.all[3]]]<- getwd() #working dir
      ans.all.new[[pos.ans.all[4]]]<-  dataset$'_id' #data.name
      ans.all.new[[pos.ans.all[5]]]<- dat #odt - dataset
      ans.all.new[[pos.ans.all[6]]]<- ncol(dat) #number of columns (i.e. variables) in data set
      ans.all.new[[pos.ans.all[7]]]<- colnames(dat) #varnames
      ans.all.new[[pos.ans.all[8]]]<- dat1.xname #x name
      ans.all.new[[pos.ans.all[9]]]<- dat1.yname #y name
      
      if(range(dat[,depend.indx])[1]<=0){ans.all.new$auto.detlim<- TRUE}  #ans.all.new$detlim<- 0.001} # to avoid question for detection limit
      
      ans.all.new$cont <- TRUE #; ans.all<- TRUE
      #res0<- f.quick.con(ans.all.new,validate=T)#
      #graphics.off()
      #.ypos <- 95
      devAskNewPage(ask = FALSE)	
      options(device.ask.default = FALSE)
      
      # run proast & save print out in file
      sink("report_from_screen.txt",append=TRUE)
      assign(".ypos", 95, envir = .GlobalEnv)
      
      devAskNewPage(ask = TRUE)
      options(device.ask.default = FALSE)
      print(ans.all.new)
      res1<- proast61.5::f.quick.con(ans.all.new,validate=F)#
      sink()
      #sink.number() 
      # closeAllConnections()
      
      #read print out
      rfs<- readLines("report_from_screen.txt")
      rfs[which(rfs=="")]<- "\n"
      unlink("report_from_screen.txt")
      #sink()   
      #sink.number()
      
      #save, read and resave garphs 
      g.num<- as.numeric(dev.cur()[1])
      c.fig<- as.data.frame(t(character(g.num-1)))
      colnames(c.fig)<- c('FittedValues','NestedHillModels','NestedExponentialModels')#paste('figure',1:(g.num-1),sep='')
      
      w<- 0
      
      for(i in g.num:2){
        w<-w+1 
        if(w>3){break}
        else{ 
          num1<- g.num-i+1
          labeli<- paste('graph',num1,'.png',sep='')
          dev.set(which=i)
          x<- grDevices::recordPlot()
          png(labeli)
          replayPlot(x)
          dev.off()
          png1<- file(labeli,'rb') #open for reading in binary mode
          N<- 1e6
          pngfilecontents <- readBin(png1, what="raw", n=N)
          close(png1)
          #print(c(i))
          c.fig[num1]<- jsonlite::fromJSON(jsonlite::toJSON(pngfilecontents))#base64(pngfilecontents)
          ### NOTE: fromJSON(toJSON( is a round-about since base64 doesn't work with JSON
          ### and to JSON is doing base64 internally
        }
      }
      if(dev.cur()>1){for(j in 1:(dev.cur()-1)){dev.off()}}
      #graphics.off() 
      
      liks.mat<- rbind(res1$logliks,res1$EXP$logliks,res1$HILL$logliks)
      thres.mat<- c(which(liks.mat[,1]=='--'),dim(liks.mat)[1]+1)
      n1.mat<- c('LR',res1$model.sublist)
      n2.mat<- character(dim(liks.mat)[1])
      w<- 2
      while(w<=length(thres.mat)){
        n2.mat[thres.mat[w-1]:(thres.mat[w]-1)]<- rep(n1.mat[w-1],thres.mat[w]-thres.mat[w-1])
        #n2.len<- thres.mat[w]-thres.mat[w-1]
        #n2.mat[thres.mat[w-1]:(thres.mat[w]-1)]<- paste(n2.mat[thres.mat[w-1]:(thres.mat[w]-1)],1:n2.len,sep='')
        w<- w+1
      }
      n3.mat<- paste(n2.mat,liks.mat[,1])
      
      liks.mat.s<- liks.mat
      liks.mat.s1<- as.matrix(liks.mat.s)
      colnames(liks.mat.s1)<- NULL
      x1<- as.list(as.data.frame(t(liks.mat.s1)))
      names(x1)<- n3.mat
      calc5<- list(colNames=colnames(liks.mat.s),values=x1)
      l1<- list(logLik=calc5)
      
      mods.mat<- res1$model.sublist
      len.mat<- length(res1$model.sublist)
      names.res1<- names(res1)
      BMD.All<- matrix(0,len.mat,3)
      rownames(BMD.All)<- mods.mat
      colnames(BMD.All)<- c('BMD','BMDL','BMDU')
      for(i in 1:len.mat){
        BMD.in<- which(names.res1==mods.mat[i])
        BMD.All[i,1:3]<- c(res1[[BMD.in]]$CED,res1[[BMD.in]]$conf.int)
      }
      
      outP<- list(singleCalculations=list(reportFromScreen=jsonlite::unbox(paste(rfs,collapse=' ')),BMD=BMD.All),
                  
                  arrayCalculations=l1,figures=jsonlite::unbox(c.fig))
      #unlink('.trial1.RData')
      grDevices::graphics.off()
      #outPj <- jsonlite::toJSON(outP)
      return(outP)
  }

