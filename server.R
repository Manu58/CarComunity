
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(metricsgraphics)
library(randomForest)
load("cardata.RData")


shinyServer(function(input, output, session) {
#Unit Switchers
        output$mpglabel<-renderText(switch(input$units, 
                                  met="Consumption (km/liter)",
                                  us = "Consumption (miles/gallon)"))
        output$test<-renderText({input$gear})
        output$predict<-renderText({
                convmpg <- switch(input$units, met=0.425099 , us=1)
                cwt<- switch(input$units, met=0.002204622*input$metwt, us=input$uswt)
                cdisp<- switch(input$units, met=61.02398*input$metdisp, us=input$usdisp)
                signif(convmpg*predict(fit,data.frame(cyl=input$cyl,
                                                disp=cdisp, 
                                                wt=cwt, 
                                                am=as.numeric(input$am),
                                                gear=as.numeric(input$gear))),3)
                                               })
        
        output$mjs1 <- renderMetricsgraphics({
                xlabel<-switch(input$units,
                                        met="Kilometer per Liter",
                                        us="Miles per Gallon")
                convmpg <- switch(input$units, met=0.425099 , us=1)
                cwt<- switch(input$units, met=0.002204622*input$metwt, us=input$uswt)
                cdisp<- switch(input$units, met=61.02398*input$metdisp, us=input$usdisp)
                predcar<-as.numeric(convmpg*predict(fit,data.frame(cyl=input$cyl,
                                                      disp=cdisp, 
                                                      wt=cwt, 
                                                      am=as.numeric(input$am),
                                                      gear=as.numeric(input$gear))))                
                dens <- density(mycars$mpg,bw="SJ",kernel=input$smooth,(2^input$points)/2)
                spl <- smooth.spline(dens$x, dens$y, df=input$dof, keep.data=FALSE)
                predmpg <- predict(spl, mycars$mpg)
                x<-switch(input$units,
                  met = predmpg$x/ 2,352393,
                  us =  predmpg$x)
        mpgdens <- data.frame(x,y=predmpg$y,cons=80-x)
                
        mpgdens %>%
                mjs_plot(x=x, y=y, width=500, height=650) %>%
                mjs_point(color_accessor=x, size_accessor=cons) %>%
                mjs_labs(x=xlabel, y="Probability density")%>%
                mjs_add_marker(predcar, "Your car")
        })
        observeEvent(input$add,
                {
                        cmpg <- switch(input$units, met=0.425099*input$mpgin , us=input$mpgin)
                        cwt<- switch(input$units, met=0.002204622*input$metwt, us=input$uswt)
                        cdisp<- switch(input$units, met=61.02398*input$metdisp, us=input$usdisp)
                        nm <- c(rownames(mycars),input$model)
                        mycars<-rbind(mycars, data.frame(mpg=cmpg,
                                                 cyl=input$cyl,
                                                 disp=cdisp, 
                                                 wt=cwt, 
                                                 am=as.numeric(input$am),
                                                 gear=as.numeric(input$gear)))
                        rownames(mycars) <- nm
                        fit=lm(mpg~.,data=mycars)
                        save(mycars,fit,file="cardata.RData")
                }
        )

})
