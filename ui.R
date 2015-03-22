
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(metricsgraphics)
library(shinydashboard)
library(RColorBrewer)

dashboardPage(
        dashboardHeader(title = "fuel consumption"),
        dashboardSidebar(
                sidebarMenu(
                        menuItem("Main",tabName = "prognosis", icon = icon("automobile")),
                        menuItem("Main",tabName = "prognosis", icon = icon("automobile")),
                        menuItem("Settings",tabName = "set", icon = icon("cog" )),
                        menuItem("Graphics",tabName = "gset", icon = icon("sliders" ))
                ),
                tabItems(
                        tabItem(tabName = "set",
                                h3("Settings"),
                                radioButtons("units", label = h4("Units"), 
                                             choices = list("Metric" = 'met', 
                                                            "US" = 'us')),
                                h3("Add car to model"),
                                conditionalPanel(
                                        condition = "input.units=='met'",
                                        numericInput("mpgin", label = 'Consumption in km per liter', 
                                                     10, min = 4, max = 20, step = 0.01)
                                ),
                                conditionalPanel(
                                        condition = "input.units=='us'",
                                        numericInput("mpgin", label = 'Consumption in miles /gallon', 
                                                     20, min = 10, max = 40, step = 0.01)
                                ),
                                textInput("model","Car model",value="Unknown"),
                                h5("Add car to model and saves new model"),
                                actionButton('add','Add and save',icon = icon('plus-square'))
                                

                        ),
                        tabItem(tabName = "gset",
                                selectInput("smooth", label = h4("Smoothing"),
                                            choices = c("gaussian", "epanechnikov", "rectangular",
                                                        "triangular", "biweight",
                                                        "cosine", "optcosine")),
                                sliderInput("points", label = "nr of pts in powers of 2",
                                             min = 1, max = 9, value = 0),
                                sliderInput("dof", label = "Degrees of freedom",
                                            min = 2, max = 34, value = 30)
                
                        ),
                        tabItem(tabName = "prognosis",
                                conditionalPanel(
                                        condition = "input.units=='met'",
                                        numericInput("metwt", label = 'Weight in kg', 
                                             1460, min = 500, max = 3000, step = 1),
                                        numericInput("metdisp", label = 'Displacement in liters',
                                             3, min = 0.5, max = 8, step = .001)                                ),
                                conditionalPanel(
                                        condition = "input.units=='us'",
                                        numericInput("uswt", label = 'Weight in 1000 lb', 
                                                     3.2, min = 1.1, max = 6.7, step = 0.002),
                                        numericInput("usdisp", label = 'Diplacement in cubic inch',
                                                     184, min = 30, max = 500, step = .05)
                                ),
                                sliderInput("cyl" ,label = "Cylinders",
                                            min = 2, max = 8, value = 4, step =1),
                                radioButtons("gear", label = "Gears",
                                                     choices = list("3" = 3,
                                                                    "4" = 4,
                                                                    "5" = 5),
                                                     selected = 4,inline = TRUE),
                                radioButtons("am", label = "Gear Type",
                                                     choices = list("Automatic" = 0,
                                                                    "Manual" = 1))
                        )
                )
        ),
        dashboardBody(
                fluidPage(
                        metricsgraphicsOutput('mjs1'),
                        box(width=6,h4("Predicted Consumption"), 
                            h4(textOutput('mpglabel')), 
                                h3(textOutput('predict'))
                                ),
                        box(width =6, h5("The panels"),
                            strong("main"),"where you set the properties of your car",br(),
                            strong("settings"),"where you can change units and add a car to the model",br(),
                            strong("graphics"),"where you can set the smoothness of the densityplot"),
                        box(width=12,
                            h5("Instructions"),
                            "- Use the panels to set car properties and the regression model will calculate 
                            the consumption in units of your choice",br(),
                            "- When you add a new car model, a new regression model is calculated based on all models 
                            in the database. Regression model and database are saved on disk")
                )
        )
)
