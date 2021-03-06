#
# Copyright (C) 2013-2018 University of Amsterdam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

controlCharts <- function(jaspResults, dataset, options){

  # Make the Process ID and clean the dataset
  variables <- unlist(options$variables)
  ID <- options$ProcessID
  makeID <- ID != ""
  numberMissing <- 0
  dataset         <- .readDataSetToEnd(columns.as.numeric = variables)
  dataset.factors <- .readDataSetToEnd(columns = variables)
  dataset <- na.omit(dataset)
  # Cheking for errors in the dataset
  .hasErrors(dataset, type = c('observations', 'infinity', 'missingValues'),
             all.target = options$variables,
             observations.amount = c(' < 2'), exitAnalysisIfErrors = TRUE,
             custom = function() { if (length(options$variables) < 2 && length(options$variables) != 0) return("Please use two measurements or more")})
  
  jaspResults[["intro"]] <- createJaspHtml("Select one of the control charts to from the interface.\n\nX bar chart: \nS chart: \nR chart: \nI-mR chart:", "p")
  jaspResults[["intro"]]$position <- 0
  
  # Return when no variables are present
  if (length(options$variables) == 0)
  	return ()

  #X bar R Chart
  if(options$Xbarchart && is.null(jaspResults[["Xbarchart"]])){

    jaspResults[["XbarPlot"]] <- createJaspPlot(title = "X bar chart", width = 600, height = 300)
    jaspResults[["XbarPlot"]]$dependOn(c("Xbarchart"))
    jaspResults[["XbarPlot"]]$position <- 11
    XbarPlot <- jaspResults[["XbarPlot"]]
    XbarPlot$plotObject <- .XbarchartNoId(dataset = dataset, options = options)
  }
  if(options$Rchart && is.null(jaspResults[["Rchart"]])){
    jaspResults[["RPlot"]] <- createJaspPlot(title = "R chart", width = 600, height = 300)
    jaspResults[["RPlot"]]$dependOn(c("Rchart"))
    jaspResults[["RPlot"]]$position <- 11
    RPlot<- jaspResults[["RPlot"]]
    RPlot$plotObject <- .RchartNoId(dataset = dataset, options = options)
  }

  #X bar S Chart
  if(options$Schart && is.null(jaspResults[["Schart"]])){
    jaspResults[["SPlot"]] <- createJaspPlot(title = "S chart", width = 600, height = 300)
    jaspResults[["SPlot"]]$dependOn(c("Schart"))
    jaspResults[["SPlot"]]$position <- 11
    SPlot<- jaspResults[["SPlot"]]
    SPlot$plotObject <- .SchartNoId(dataset = dataset, options = options)
  }
  #ImR chart
  if(options$ImRchart) {
    if (is.null(jaspResults[["ImRchart"]])){
      jaspResults[["ImRchart"]] <- createJaspContainer(gettext("ImR charts"))
      jaspResults[["ImRchart"]]$dependOn(c("ImRchart"))
      jaspResults[["ImRchart"]]$position <- 11
    }

    ImRplot <- jaspResults[["ImRchart"]]

    for (var in variables){
      ImRplot[[var]] <- .ImRchart(dataset = dataset, options = options, variable = var)
    }
  }
}

#Functions
.SchartNoId <- function(dataset, options) {
  data1 <- dataset[, unlist(lapply(dataset, is.numeric))]
  Stdv <- apply(data1, 1, function(x) sd(x))
  subgroups <- c(1:length(Stdv))
  data_plot <- data.frame(subgroups = subgroups, Stdv = Stdv)
  sixsigma <- qcc::qcc(data1, type ='S', plot=FALSE)
  center <- sixsigma$center
  UCL <- max(sixsigma$limits)
  LCL <- min(sixsigma$limits)
  yBreaks <- jaspGraphs::getPrettyAxisBreaks(c(LCL, data_plot$Stdv, UCL + 1))
  yLimits <- range(yBreaks)
  xBreaks <- jaspGraphs::getPrettyAxisBreaks(c(subgroups))
  xLimits <- range(xBreaks)
  dfLabel <- data.frame(
    x = max(xLimits) + 1,
    y = c(center, UCL, LCL),
    l = c(
      gettextf("SD = %g", round(center, 3)),
      gettextf("UCL = %g",   round(UCL, 3)),
      gettextf("LCL = %g",   round(LCL, 3))
    )
  )
  p <- ggplot2::ggplot(data_plot, ggplot2::aes(x = subgroups, y = Stdv)) +
    jaspGraphs::geom_line() +
    jaspGraphs::geom_point(size = 4, fill = ifelse(data_plot$Stdv > UCL | data_plot$Stdv < LCL, 'red', 'gray')) +
    ggplot2::geom_hline(yintercept =  center, color = 'black') +
    ggplot2::geom_hline(yintercept = c(UCL, LCL), color = "red") +
    ggplot2::geom_label(data = dfLabel, mapping = ggplot2::aes(x = x, y = y, label = l),inherit.aes = FALSE) +
    ggplot2::scale_y_continuous(name = "Subgroup Standard Deviation" ,limits = yLimits, breaks = yBreaks) +
    ggplot2::scale_x_continuous(name = 'Subgroup', breaks = xBreaks, limits = c(min(xLimits), max(xLimits) + 1)) +
    jaspGraphs::geom_rangeframe() +
    jaspGraphs::themeJaspRaw()

  return(p)
}
.ImRchart <- function(dataset, options, variable){
  title <- gettextf("Measurement: %s", variable )
  ppPlot <- createJaspPlot(width = 600, height = 300, title = title)
  ppPlot$dependOn(optionContainsValue = list(variables = variable))

  #data
  data <- data.frame(process = dataset[[.v(variable)]])
  subgroups <- c(1:length(data$process))
  sixsigma <- qcc::qcc(data$process, type ='xbar.one', plot=FALSE)
  center <- sixsigma$center
  UCL <- max(sixsigma$limits)
  LCL <- min(sixsigma$limits)
  yBreaks <- jaspGraphs::getPrettyAxisBreaks(c(LCL - 1, UCL + 1))
  yLimits <- range(yBreaks)
  xBreaks <- jaspGraphs::getPrettyAxisBreaks(c(subgroups))
  xLimits <- range(xBreaks)
  dfLabel <- data.frame(
    x = max(xLimits) + 1,
    y = c(center, UCL, LCL),
    l = c(
      gettextf("Mean = %g", round(center, 3)),
      gettextf("UCL = %g",   round(UCL, 3)),
      gettextf("LCL = %g",   round(LCL, 3))
    )
  )

  #plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = subgroups, y = process)) +
    jaspGraphs::geom_line() +
    jaspGraphs::geom_point(size = 4, fill = ifelse(data$process > UCL | data$process < LCL, 'red', 'gray')) +
    ggplot2::geom_hline(yintercept =  center, color = 'black') +
    ggplot2::geom_hline(yintercept = c(UCL, LCL), color = "red") +
    ggplot2::geom_label(data = dfLabel, mapping = ggplot2::aes(x = x, y = y, label = l),inherit.aes = FALSE) +
    ggplot2::scale_y_continuous(name = "Value" ,limits = yLimits, breaks = yBreaks) +
    ggplot2::scale_x_continuous(name = 'Observations', breaks = xBreaks, limits = c(min(xLimits), max(xLimits) + 1)) +
    jaspGraphs::geom_rangeframe() +
    jaspGraphs::themeJaspRaw()

  ppPlot$plotObject <-  p
  return(ppPlot)
}
