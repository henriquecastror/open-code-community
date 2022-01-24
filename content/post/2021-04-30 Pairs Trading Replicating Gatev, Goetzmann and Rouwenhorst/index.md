---

title: "Pairs Trading: Replicating Gatev, Goetzmann and Rouwenhorst (2006)"

categories: []

date: '2021-04-30T00:00:00Z'

draft: true

featured: no

gallery_item: null

image:
  caption: 
  focal_point: Top
  preview_only: no

projects: []

subtitle: null

summary: null

tags:
- Pairs Trading
- Financial Econometrics
- Quantitative trading


authors:
- AlexandreRubesam

---
## Introduction

Pairs trading is a type of mean-reversion trading strategy that has been widely used by hedge funds. At its most basic, a pairs trading strategy has two steps. In the first step, the strategy identifies pairs of stocks that historically "move together", according to some criterion. In the second step, a trading rule is used to monitor the behavior of the selected pairs. When a stock in a pair moves away (diverges) from its historical relationship with the other stock, a position is opened, betting that the pair of stocks will go back to its previous pattern. A trade can be closed when the relationship between the two stocks goes back to "normal", or by using other criteria (for example, after a predefined period of time or if a stop loss is triggered). Pairs trading is interesting from both an academic and practical perspectives. If pairs trading is profitable in terms of risk-adjusted returns, it suggests market inefficiency, since the strategy only makes use of historical prices. From a practical perspective, a profitable pairs trading strategy is obviously attractive to investors such as hedge funds, although much more sophisticated types of statistical arbitrage are generally employed in real life.

[Gatev, Goetzmann and Rouwenhorst (2006)](https://academic.oup.com/rfs/article-abstract/19/3/797/1646694?redirectedFrom=fulltext) (GGR) is probably the most influential paper on pairs trading. Using daily data on U.S. stocks from [CRSP](http://www.crsp.org/), GGR tested a simple pairs trading strategy that selects pairs with minimum squared distance in the space of normalized prices (specifics will be discussed below). The spread (difference) between the prices of two stocks in a pair is used to monitor for trading opportunities. A trade is opened when the spread diverges by more than two historical standard deviations, and is closed when the pair converges (i.e. the spread reverts), or at the end of each trading period.

It is well-known that the performance of these simple strategies has declined over time. GGR found robust profits to their pairs trading strategy using a sample from 1962 to 2002. Subsequently, [Do and Faff (2010)](https://www.tandfonline.com/doi/abs/10.2469/faj.v66.n4.1) extended the sample to 2009, showing a significant decline in the profitability of the strategy in the post-2002 period, although it continued to deliver profits, especially during turbulent periods in the market. They also proposed some refinements that appear to improve the strategy.

In this short article, I replicate the original GGR pairs trading strategy, using CRSP data from January 1962 to December 2020. As will be seen, the profitability of this simple pairs trading strategy in the U.S. has essentially disappeared. Before I proceed with looking at the data, I review a few basic concepts related to the implementation of the strategy.

## Formation and Trading Periods

The GGR pairs trading strategy is implemented using a 12-month period to select pairs, and a 6-month trading period, where the 20 pairs (an arbitrary number) with the smallest squared distances are traded. Because of the 6-month trading period, GGR suggest using 6 overlapping portfolios, each starting one month after the other, similarly to the approach use by [Jegadeesh and Titman (1993)](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1540-6261.1993.tb04702.x) for momentum. The return of the pairs trading strategy on each period is the average return from the six pairs portfolios.

## Pair Selection
GGR select pairs with minimum "minimum distance between normalized historical prices". In practice, this entails creating a synthetic time series of prices for each stock, starting at the value of $1, from the time series of total returns, including dividends. In order to be eligible, a stock needs to have valid return data for the entire formation period, to ensure that the stocks used for pairs formation will be reasonably liquid. Once the universe of eligible stocks for a formation period is defined, we calculate the distances between the normalized prices of all possible pairs of stocks, and select the 20 pairs with the minimum distance. This can be computationally intensive: if there are 1,000 eligible stocks, for example, we need to calculate (1,000 x 999)/2 = 499,500 distances.

It should be noted that this minimum distance criterion is not the only way to select pairs. Other typical approaches use cointegration or copulas to define the pairs. See for example [Rad, Low, and Faff, R. (2016).](https://www.tandfonline.com/doi/abs/10.1080/14697688.2016.1164337?journalCode=rquf20)

## Trading
Once the 20 pairs with the minimum distance are selected, their spreads are monitored during the trading period. A trade is opened if the normalized spread during the trading period exceeds two historical standard deviations, as calculated during the formation period. If the spread is positive, the pair is sold (short position on the first "leg" and long position on the second). If the spread is negative, it's the other way around. GGR test two variations of the strategy, one in which trades are opened on the day the divergence occurs, and another in which trades are opened one day after. The idea of the latter is to reduce the effect of bid-ask bounce. A more reasonable approach in my view is to account for bid-ask spread directly.

A pair is closed if the spread converges (i.e. crosses zero), or if the end of the trading period is reached. This is typically not what is done in practice; other criteria such as a maximum number of days or a stop-loss or stop-gain rule are commonly used.

## Calculation of Returns

As mentioned by GGR, calculating the return of a portfolio of pairs is not a straightforward task, as in principle, the portfolio can have a net position of zero. In addition, multiple positions in any given pair can be opened and closed during the trading period, depending on trading opportunities. A simple and sensible way to obtain reasonable estimates for the daily return on a single pair is to assume that a trade is initiated with \$1 long and \$1 short positions on the first day of the trade, and update this amount according to the returns on each leg. That is, the return on a pair on day t is given by

$$
\begin{equation}
x_{pt}=w_{1,t}r_{1}^{L}+w_{2,t}r_{2}^{s}
\end{equation}
$$
where $w_{1,t}$ and $w_{2,t}$ are initially equal to 1, and evolve after that according to the changes in the value of each stock, i.e., $w_{i,t} = w_{i,t-1}(1+r_{i,t-1})$. The returns calculated in this way essentially mimic the evolution of the profit and loss (pnl) of a portfolio with a $1 long and $1 short on each stock. To calculate the returns on a portfolio of pairs, we need some more assumptions about how capital is allocated to open pairs. GGR suggest two alternatives, the committed capital and the fully invested approaches. Both of these are equally-weighted approaches, in the sense that each pair is always allocated the same amount of money. In the committed capital approach, the full capital of the fund is equally allocated among the 20 pairs, regardless of whether a position is open. In the fully invested approach, the fund's capital at each day is equally allocated among the pairs with open trades. It is important to note that these assumptions are not very realistic: they would require frequent (essentially, daily) rebalancing of the pairs trades. A more realistic approach is to simulate a fund with a given starting capital, and open trades on day t using the capital available, keeping the number of shares of the stocks for a pair trade fixed throughout the life of the trade, and accounting for transaction costs in a more direct fashion.

Now that that the strategy is fully explained, let's go to the implementation.

## Data
The data come from CRSP and was obtained from WRDS. I download data for all ordinary U.S. stocks traded in the NYSE, AMEX and NASDAQ (i.e. EXCHCD equal to 1, 2, or 3 and SHRCD equal to 10 or 11). SAS code for this is available upon request. All that is needed to test the strategy are the returns (including dividends), but my database also includes prices and volumes. I include delisting returns following [Johnson and Zhao (2007)](https://journals.sagepub.com/doi/10.1177/0148558X11409152). The data is in a long format, i.e. each row contains information for one stock for one day.

I start by loading some packages that will be useful, particularly the data.table package to load and manipulate the data. The other packages facilitate return calculations.

The full data set starting in 1962 has about 69 million lines and contains 7 variables: PERMNO, DATE, prc, adjprc, RET, VOL, and EXCHCD. The only variables that we actually need are PERMNO, which uniquely identify each share, DATE, RET (total return including dividends), and VOL (volume in number of shares traded).


    
    rm(list = ls())
    library(data.table)
    library(PerformanceAnalytics)
    library(quantmod)
    
    # load the data
    dcrsp <- fread("CRSP_stocks_daily.csv")
    
    # format dates
    dcrsp$DATE <- as.Date(as.character(dcrsp$DATE), format = "%Y%m%d")
    
    # select period starting in 1962
    dcrsp <- dcrsp[dcrsp$DATE >= "1962-01-01",]
    
    # unique dates
    dates <- unique(sort(dcrsp$DATE))
    
    # size of the data set
    dim(dcrsp)
    ## [1] 69931944        7
    # variables
    colnames(dcrsp)

Next, I would like to work with data in matrix format. I create T×N matrices for the returns and volumes, i.e., each row represents one day, and each column, a stock. A ridiculously convenient way to do is is by using the dcast function, which can reshape my long matrix into a wide matrix by putting each PERMNO in a column. After I do this, I then convert the matrices to an xts object, so I can easily work with specific date ranges. I substitute any returns lower than -1 by that value.

    # daily volumes
    vol <- dcast(dcrsp, DATE ~ PERMNO, value.var = "VOL", fill = NA)
    vol <- xts(vol[, 2:ncol(vol)], vol$DATE)
    
    # daily returns
    ret <- dcast(dcrsp, DATE ~ PERMNO, value.var = "RET", fill = NA)
    ret <- xts(ret[, 2:ncol(ret)], ret$DATE)
    ret[ret<-1] <- -1
    
    # total number of days in the sample
    total_days <- length(dates)
     
## Function to Select Pairs
Backtesting a pairs strategy requires repeatedly selecting pairs for each formation period. To make this process more straightforward, I create a function to select the n pairs with the minimum distance, based on a matrix of total returns. The function outputs a list containing the stocks in each leg of each pair (with respect to the column index in the price matrix), the distance, and the standard deviation of the spread. Selecting the n pairs with minimum distance requires calculations of the distances between all possible pairs of stocks. To have a more efficient calculation, I avoid for loops whenever possible. The function below relies on the dist function to calculate all the pairwise distances. Once I have all the distances, I order pairs according to their distances and keep only the top n pairs. For these pairs, I calculate and store the standard deviation of the spread. This function does not need to treat missing values in the returns matrix, as the strategy only selects stocks with complete data over the formation period (i.e. the idea is to screen all the valid stocks first, and provide only the matrix of valid returns to the function).
   
    GetPairsGGR <- function(form_ret, num_pairs){
      
      # form_ret is a matrix of total returns for each stock
      # num_pairs is the number of pairs with minimum distance to keep
      
      # create a matrix of normalized prices in the formation period
      form_ret[1, ] <- 0  
      P <- apply(form_ret, 2, function(x) cumprod(1 + x))
    
      # dimensions of price matrix
      num_stocks <- ncol(P)
      
      # total number of distinct pairs
      total_pairs <- num_stocks*(num_stocks-1)/2
      
       # create an object to store the distances of all pairs
      # columns: leg1, leg2, distance, spread std deviation
      pairs <- matrix(0, nrow = total_pairs, ncol = 4)
      
      
      # create column combination pairs to calculate distances
      col_diffs <- cbind(rep(1:ncol(P), each = ncol(P)), 1:ncol(P))
      
      # keep only "upper diagonal" combinations
      col_diffs <- col_diffs[col_diffs[, 2] > col_diffs[, 1],]
      
      # calculates distances using dist (more efficient)
      pair_dists <- dist(t(P), diag = FALSE, upper = TRUE)
      
      pairs <- cbind(col_diffs, pair_dists)
      colnames(pairs) <- c("Leg1", "Leg2", "Distance")
      pairs <- as.data.frame(pairs)
      
      # if there is ever a pair with zero distance, remove
      pairs <- pairs[pairs[, "Distance"] > 0, ]
      
      # sort by distance in ascending order
      pairs <- pairs[order(pairs$Distance), ]
      
      # keep at most num_pairs with minimum distance
      pairs <- pairs[1:min(nrow(pairs), num_pairs), ]
      
      # for these pairs, add the standard deviation of the spread
      pairs$Spread_sd <- apply(P[, pairs$Leg1] - P[, pairs$Leg2], 2, sd)
    
      return(pairs)
    }
    
##Function to Calculate Returns
The previous function will provide the list of pairs to trade for each trading period, along with the historical standard deviation of their spreads in the formation period. Next, I create a function that calculates returns on a portfolio of pairs, using the committed capital or the fully invested approach. The CalculatePairsReturnsGGR function takes as inputs the returns during the trading period, the list of pairs output by the GetPairsGGR function, the number of standard deviations to open a trade, and a parameter that controls whether the strategy should wait one day before opening a trade.

This function needs to identify whether a stock has valid data during the trading period. To do this, I first find the last non-missing value (missing = NA) for each stock. If one of the stocks in a pair has all returns missing after a certain index, I consider that that stock was delisted, and the trade will be close on the last available date using the delisting return. Any NAs that occur before are treated as a day with no trading, i.e. I set the return to zero. The logic to open and close trades is based on first identifying all the days when a trade may open (absolute value of the spread is higher than d_open=2 standard deviations) and close (spread reverts, i.e. changes sign, or the last day is reached).

The function then calculates the returns and outputs a list containing the pairs, a matrix containing the payoffs (i.e. returns) of each pair for each day, and matrices containing the returns using the two approaches.

    CalculatePairsReturnsGGR <- function(trade_ret, pairs, d_open, wait1d){
    
      # trade_ret : matrix with total returns with divs for trading
      #             period
      # pairs  : data frame with information about pairs
      # d_open : number of standard deviations to open a pair
      # wait1d : boolean, if TRUE, wait one day before opening trade
      
      trade_ret[1, ] <- 0 
      
      # to treat delisting correctly, identify last non NA values
      last_valid_ret <- apply(trade_ret, 2, function(x) max(which(!is.na(x))))
      
      # can safely replace NAs with 0 before this index
      # is there a way to this without a loop?
      for (i in 1:ncol(trade_ret)){
        r <- trade_ret[1:last_valid_ret[i], i]
        r <- nafill(r, type = "const", fill = 0)
        trade_ret[1:last_valid_ret[i], i] <- r
      }
      
      # "normalize" trading period prices to start at 1 
      trade_prc <- apply(trade_ret, 2, function(x) cumprod(1 + x))
    
      # total number of days in trading period
      trading_days <- nrow(trade_prc)
      
      # total number of pairs considered
      num_pairs <- nrow(pairs)
      
      # storage for output
      directions <- matrix(0, nrow = trading_days, ncol = num_pairs)
      payoffs <- matrix(0, nrow = trading_days, ncol = num_pairs)
      
      # loop through pairs and check for trades
      for (i_pair in 1:num_pairs){
        
        # identify pair legs, build price, return and spread vectors
        leg1 <- pairs[i_pair, 1]
        leg2 <- pairs[i_pair, 2]
        p1 <- trade_prc[, leg1]
        p2 <- trade_prc[, leg2]
        r1 <- trade_ret[, leg1]
        r2 <- trade_ret[, leg2]
    
        # check if one of the stocks was ever delisted
        last_day <- max(which( !is.na(p1) & !is.na(p2)))
        
        # after I find the last day, I can replace NAs with 0
        r1[is.na(r1)] <- 0
        r2[is.na(r2)] <- 0
        
        pair_sd <- pairs[i_pair, "Spread_sd"]
        s <- (p1 - p2) / pair_sd
    
        # create the w1 and w2 in GGR's return calculation
        w1 <- double(trading_days)
        w2 <- double(trading_days)
        
        # days when a trade may open: more than d_open historical std deviations
        open_ids <- (abs(s) > d_open) * seq(1, trading_days)
        open_ids <- open_ids[open_ids > 0 ]
        
        # replacing any dates after last date
        open_ids <- open_ids[open_ids <= last_day]
        open_ids <- open_ids[!is.na(open_ids)]
        
        # days when a trade may close: spread reverts or trading period ends
        close_ids <- (diff(sign(s)) != 0) * seq(2, trading_days)
    
        # always close at end of trading period or if delisting occured
        close_ids[trading_days] <- last_day 
        close_ids <- close_ids[close_ids > 0 & !is.na(close_ids)]
        
        # date when first trade opens
        t_open <- open_ids[which(open_ids > 0)][1]
        
        # if there has been a divergence in the trading period
        if (!is.na(t_open)){      
          while ( !is.na(t_open) & (t_open < last_day - wait1d) ){
            
            # check when trade closed
            t_close <- close_ids[close_ids > t_open + wait1d][1]
            
            # store direction of trade over period when trade is open
            directions[(t_open + wait1d + 1): t_close, i_pair] = -sign(s[t_open - wait1d])
            
            # update w1 and w2
            w1[(t_open + wait1d):t_close] <- 
                             c(1, cumprod(1 + r1[(t_open + wait1d) : (t_close - 1)]))
            w2[(t_open + wait1d):t_close] <- 
                            c(1, cumprod(1 + r2[(t_open + wait1d) : (t_close - 1)]))
            
            # update t_open => moves to next trade for this pair
            t_open <- open_ids[open_ids > t_close][1]
          }
        }
        
        # calculate and store the payoffs for this pair
        payoffs[, i_pair] <- directions[, i_pair] * (w1 * r1 - w2 * r2)
      }
      
      # returns for committed capital approach - just the average of payoffs
      returns_cc <- rowMeans(payoffs)
      
      # for fully-invested approach, capital is divided among open pairs
      num_open_pairs <- rowSums(directions != 0 )
      weights_fi <- ifelse(num_open_pairs > 0, 1 / num_open_pairs, 0)
      weights_fi <- matrix(weights_fi, nrow = length(weights_fi), ncol = num_pairs)
      returns_fi <- rowSums(weights_fi * payoffs)
    
      return(list(pairs = pairs, payoffs = payoffs, directions = directions, 
                  returns_cc = returns_cc, returns_fi = returns_fi))
    }
    
## Backtesting the GGR Strategy

Finally, I backtest the strategy. Since the trading period is 6 months, I need to run six overlapping portfolios and store the results. Before going though the main loop that performs that backtests the strategy over the the entire sample, I show below the logic and some details for the first formation and trading periods of the first overlapping portfolio. Since the sample starts in January 1962, this formation period goes from the beginning of January 1962 to the last day of December 1962, whereas the trading period goes from the first available day of January 1963 to the last day of June 1963. Since the data are in xts format, it's straightforward to select these periods.

    num_pairs <- 20
    d_open <- 2
    wait1d <- 1
    
    # formation period total return including dividends
    form_ret <- ret["1962-01-01/1962-12-31"]
    
    # daily volumes for formation period
    form_vol <- vol["1962-01-01/1962-12-31"]
    form_vol[is.na(form_vol)] <- 0
        
    # boolean to identify eligible stocks
    ava_stocks <- (!is.na(colSums(form_ret))) & 
                  (colSums(form_vol == 0) == 0)
    
    
    print(paste("I found", sum(ava_stocks), 
                "eligible stocks", ", that's", 
                sum(ava_stocks)*(sum(ava_stocks)-1)/2, 
                "possible pairs"))
                
    ## [1] "I found 466 eligible stocks , that's 108345 possible pairs"

    # create matrices with formation and trading prices only for selected stocks
    form_ret <- ret["1962-01-01/1962-12-31", ava_stocks]
    trade_ret <- ret["1963-01-01/1963-06-30", ava_stocks]
    
    # select pairs
    (pairs <- GetPairsGGR(coredata(form_ret), num_pairs))
        
    ##        Leg1 Leg2  Distance  Spread_sd
    ## 60851   158  250 0.3348829 0.01769172
    ## 96480   312  382 0.3598401 0.02223411
    ## 17086    39  158 0.3731510 0.02353779
    ## 1758      4  370 0.3860460 0.02429266
    ## 17244    39  316 0.3862779 0.02317696
    ## 21319    49  176 0.3882258 0.02293991
    ## 15921    36  277 0.3901740 0.02441662
    ## 53980   136  386 0.3913694 0.02366125
    ## 43376   106  117 0.3915966 0.02457472
    ## 94529   300  345 0.3929408 0.02454530
    ## 68535   184  277 0.3950272 0.02296652
    ## 89535   272  377 0.4007039 0.02500380
    ## 1688      4  300 0.4035796 0.02532551
    ## 66324   176  350 0.4063590 0.02560297
    ## 5250     12  202 0.4103112 0.02402767
    ## 5144     12   96 0.4129279 0.02606221
    ## 26175    61  106 0.4132153 0.02595843
    ## 73381   202  218 0.4135509 0.02605783
    ## 5219     12  171 0.4139031 0.02612131
    ## 101588  350  379 0.4153154 0.02510931
    
The result above show the chosen pairs for this formation period. We could investigate the normalized prices of the first pair with the commands below. It is clear that these two stocks were moving closely together in the formation period.

    r1 <- form_ret[, pairs$Leg1[1]]
    r2 <- form_ret[, pairs$Leg2[1]]
    r1[1] <- 0
    r2[1] <- 0 
    p1 <- cumprod(1 + r1)
    p2 <- cumprod(1 + r2)
    
    plot(merge(p1,p2), 
         main = "Normalized prices of first pair - formation period",
         legend.loc = "bottomleft")
         
{{< figure src="1.png" width="80%" >}}

If we knew the standard deviation of the spread on this pair at the beginning of the formation period, we could open trades when the spread diverged by more than two standard deviations, shown below as solid lines. In this case, there were only opportunities to sell the pair.

    std_spread <- (p1 - p2)/pairs$Spread_sd[1]
    
    # create xts objects with buys and sell
    buy_pair <- xts(rep(2, length(p1)), index(p1))
    sell_pair <- xts(rep(-2, length(p1)), index(p2))
    plot(merge(std_spread, buy_pair, sell_pair), 
         main = "Standardize spread of first pair",
         legend.loc = "bottomleft")

Obviously, the standard deviation of the spread is not known at the beginning of the formation period, so we estimate it and use it to trade during the trading period. Let's see what this pair's standardized spread looks like during the trading period:

    r1_trade <- trade_ret[, pairs$Leg1[1]]
    r2_trade <- trade_ret[, pairs$Leg2[1]]
    r1_trade[1] <- 0
    r2_trade[1] <- 0 
    p1_trade <- cumprod(1 + r1_trade)
    p2_trade <- cumprod(1 + r2_trade)
    
    par(mfrow = c(2, 1))
    plot(merge(p1_trade,p2_trade), 
         main = "Normalized prices - trading period",
         legend.loc = "bottomleft")
    
    
    std_spread_trade <- (p1_trade - p2_trade)/pairs$Spread_sd[1]
    
    # create xts objects with buys and sell
    buy_pair_trade <- xts(rep(2, length(p1_trade)), index(p1_trade))
    sell_pair_trade <- xts(rep(-2, length(p1_trade)), index(p1_trade))
    
    plot(merge(std_spread_trade, buy_pair_trade, sell_pair_trade), 
         main = "Standardized spread - trading period",
         legend.loc = "bottomleft")
         
{{< figure src="2.png" width="80%" >}}


The example above shows one of the main risks with pairs trading, which is when trades don't converge. Even though the two stocks appeared to have a very close relationship during pair formation, they subsequently showed different behavior during the trading period. We would have opened a long position on the pair at the end of January 1963, and would close it at a loss at the end of the trading period.

Of course, this is not always the case. For the pair shown below, we would have sold the pair at a profit at least twice:

{{< figure src="3.png" width="80%" >}}

Let's calculate the excess returns for the 20 pairs in the first trading period. I apply the CalculatePairsReturnsGGR function with the chosen pairs and plot the cumulative returns for each pair, as well as the portfolio return using the committed capital approach. Even though many pairs lost money, overall the strategy was profitable, earning a little over 3%.

    trades <- CalculatePairsReturnsGGR(trade_ret, pairs, d_open, wait1d)
    
    pairs_returns <- xts(trades$payoffs, index(trade_ret))
    pairs_port_returns <- xts(trades$returns_cc, index(trade_ret))
    par(mfrow = c(2,1))
    plot(cumprod(1 + pairs_returns))
    plot(cumprod(1 + pairs_port_returns))

{{< figure src="4.png" width="80%" >}}

Now that the dynamics of the GGR pairs trading is a bit clearer, let's move on to the backtest of the strategy over the entire period. To make it convenient to identify the formation and trading periods, I create a variable that identifies the sequential number of the month of each day in the sample. The code below sets up the parameters of the strategy, creates objects to store the outputs, and creates an object identifying the month of each day. I start by looking at the strategy that waits one day prior to opening a trade (wait1d = 1).

    ## Main loop to calculate pairs trading returns
    
        n_formation <- 12
        n_trading <- 6
        num_pairs <- 20
        d_open <- 2
        wait1d <- 1
    
    # storage for results
    strat_returns_cc_w1d <- xts(matrix(0, nrow = total_days, ncol = n_trading),
                            order.by = dates)
    strat_returns_fi_w1d <- strat_returns_cc_w1d
    
    num_open_pairs_w1d <- xts(matrix(0, nrow = total_days, ncol = n_trading), 
                              order.by = dates)

    # Create indices of months in sample
    first_day <- c(1, (month(dates[2 : total_days]) != month(dates[1 : (total_days - 1)])))
    month_id <- cumsum(first_day)

Next comes the main loop to calculate the returns on the six overlapping portfolios over the entire sample period. This code hasn't really been optimized, but it's clear that it could easily be parallelized, as each overlapping portfolio is independent. In addition, trades in each trading period are also independent of previous formation and trading periods. In any case, the code doesn't take very long (about 9-10 minutes per portfolio for a 58-year backtest with daily data on an AMD Ryzen 7 3700X, not bad).

    for (i_port in (1 : n_trading)){
    
      start_time <- Sys.time()
      
      print(paste("Running portfolio", i_port, "of", n_trading))
    
      # find index of date when this portfolio can start
      t_i <- which(month_id == i_port + n_formation - 1)
      t_i <- t_i[length(t_i)]
      
      while (t_i < total_days){
        
        # get daily indices for last n_formation months
        form_start <- which(month_id == month_id[t_i] - n_formation + 1)[1]
        form_end <- t_i
        form_ids <- seq(from = form_start, to = form_end)
        form_dates <- dates[form_ids]
        
        # get daily indices for trading period
        trade_start <- form_end + 1
        trade_end <- which(month_id == month_id[trade_start] + n_trading)[1] - 1
        
        if (is.na(trade_end)){
          trade_end <- total_days
        }
        
        trade_ids <- seq(from = trade_start, to = trade_end)
        trade_dates <- dates[trade_ids]
        
        #print(paste("Portfolio", i_port, "of", n_trading))
        #print(paste("Formation:", form_dates[1], "to", form_dates[length(form_dates)]))
        #print(paste("Trading:", trade_dates[1], "to", trade_dates[length(trade_dates)]))
        
        # check available stocks
        
        # select only stocks:
        #  - with returns for entire formation period
        #  - with volumes > 0 for every day of formation period
    
        # formation period total return including dividends
        form_ret <- ret[form_dates]
        
        # daily volumes for formation period
        form_vol <- vol[form_dates]
        form_vol[is.na(form_vol)] <- 0
        
        # boolean to identify eligible stocks
        ava_stocks <- (!is.na(colSums(form_ret))) & 
          (colSums(form_vol == 0) == 0) 
        
      
        # formation and trading returns for selected stocks
        
        form_ret <- ret[form_dates, ava_stocks]
        trade_ret <- ret[trade_dates, ava_stocks]
    
        # select pairs
        pairs <- GetPairsGGR(coredata(form_ret), num_pairs)
        
        # trade pairs
        trades <- CalculatePairsReturnsGGR(trade_ret, pairs, d_open, wait1d)
        
        # check weird numbers
        if (any(trades$returns_cc>1)){
          break
        }
        
        # store results
        strat_returns_cc_w1d[trade_dates, i_port] <- trades$returns_cc
        strat_returns_fi_w1d[trade_dates, i_port] <- trades$returns_fi
        num_open_pairs_w1d[trade_dates, i_port] <- rowSums(trades$directions != 0 )
        
        # move to next period
        t_i <- trade_ids[length(trade_ids)]
      }
      
      end_time <- Sys.time()
      print(paste("Running portfolio", i_port, "took", 
                  (end_time - start_time), "minutes"))
    
    }
    
    ## [1] "Running portfolio 1 of 6"
    ## [1] "Running portfolio 1 took 9.26413729985555 minutes"
    ## [1] "Running portfolio 2 of 6"
    ## [1] "Running portfolio 2 took 9.18954635063807 minutes"
    ## [1] "Running portfolio 3 of 6"
    ## [1] "Running portfolio 3 took 9.19928489923477 minutes"
    ## [1] "Running portfolio 4 of 6"
    ## [1] "Running portfolio 4 took 9.19631685018539 minutes"
    ## [1] "Running portfolio 5 of 6"
    ## [1] "Running portfolio 5 took 9.24656646649043 minutes"
    ## [1] "Running portfolio 6 of 6"
    ## [1] "Running portfolio 6 took 9.29415026505788 minutes"

After the daily excess returns for the overlapping portfolios are calculated, I calculate the returns on the committed capital and fully invested portfolios of pairs, and then compound them to obtain monthly returns for a comparison with GGR. The bar plot below shows the monthly excess returns on the committed capital. Although the overall pattern is very similar to that reported by GGR, the range of returns is a bit different, especially the extreme positive returns they report in the early 1970s.1 My plot, however, is almost identical to the graph reported by [Do and Faff (2010)](https://www.tandfonline.com/doi/abs/10.2469/faj.v66.n4.1). Although the strategy still delivered some decent returns during the Great Financial Crisis (GFC), we can clearly see the degradation in the returns of the GGR strategy after that.

    ret_cc_w1d <- xts(rowMeans(strat_returns_cc_w1d, na.rm = TRUE), index(strat_returns_cc_w1d))
    ret_fi_w1d <- xts(rowMeans(strat_returns_fi_w1d, na.rm = TRUE), index(strat_returns_fi_w1d))
    
    # daily equity curves
    p_cc_w1d <- cumprod(1 + ret_cc_w1d)
    p_fi_w1d <- cumprod(1 + ret_fi_w1d)
    
    # monthly returns
    m_cc_w1d <- monthlyReturn(p_cc_w1d, type = "log")
    m_fi_w1d <- monthlyReturn(p_fi_w1d, type = "log")
    
    # 12-month moving average
    ma_12_cc_w1d <- rollapply(m_cc_w1d, 12, "mean")
    
    # plot monthly excess returns and cumulative returns for commited capital 
    
    bar_rets <- merge(ma_12_cc_w1d, m_cc_w1d)
    colnames(bar_rets) <- c("12-month moving average",
                            "Wait one day, committed capital")
    chart.Bar(bar_rets, 
              col = c("blue", "grey"), 
              lwd = c(2, 1), 
              main = "Monthly Excess Returns, top 20 pairs", 
              legend.loc = "topright")

{{< figure src="6.png" width="80%" >}}


Next, I plot the cumulative returns over the entire sample period. The shapes are very similar to what GGR report, although it should be noted that I plot the log cumulative excess returns, whereas GGR plot cumulative excess returns on a log-scale.2 Again, the degradation in the post-GFC period is very clear, with almost flat returns after 2010.

    monthly_equity_w1d <- merge(cumprod(1+m_cc_w1d), 
                                   cumprod(1+m_fi_w1d))
    colnames(monthly_equity_w1d) <- c("Commited Capital", "Fully Invested")
    
    plot(log(monthly_equity_w1d), 
         main = "Cumulative Return of GGR Pairs Trading Strategy", 
         legend.loc = "topleft")
         
{{< figure src="7.png" width="80%" >}}

Zooming in to the post-GGR period allows us to see the decline in the profitability of the strategy after the 2008 crisis:

{{< figure src="8.png" width="80%" >}}

I repeat these steps without the one-day waiting period (the code is omitted), and then   an object with all the returns. The graph below shows the log of the cumulative returns of all the strategies over the entire sample period.

    pts_returns <- merge(m_cc_w0d, m_fi_w0d, m_cc_w1d, m_fi_w1d)
    colnames(pts_returns) <- c("No waiting, committed capital",
                               "No waiting, fully invested",
                               "Wait one day, committed capital",
                               "Wait one day, fully invested")
    plot(log(cumprod(1+pts_returns)), 
         main = "Cumulative Return of GGR Pairs Trading Strategy", 
         legend.loc = "topleft")
         
{{< figure src="9.png" width="80%" >}}

Now to calculate some performance statistics. I consider three periods: the original GGR sample period (July 1963 to December 2002), the "post-GGR" sample in Do and Faff (2010), (January 2003 to June 2009), and the remaining post-GFC period, from July 2009 to December 2020. I create a function to report a table with some basic statistics for a given period:

    library(moments)
    ## 
    ## Attaching package: 'moments'
    ## The following objects are masked from 'package:PerformanceAnalytics':
    ## 
    ##     kurtosis, skewness
    stats_table <- function(xts, period){
      mean_sample <- sapply(xts[period], mean)
      sd_sample <- sapply(xts[period], sd)
      t_sample <- mean_sample/(sd_sample/sqrt(nrow(xts[period])))
      median_sample <- sapply(xts[period], median)
      min_sample <- sapply(xts[period], min)
      max_sample <- sapply(xts[period], max)
      skew_sample <- sapply(xts[period], skewness)
      kurt_sample <- sapply(xts[period], kurtosis)
      dd <- maxDrawdown(xts[period])
      
      tb <- rbind(mean_sample, sd_sample, t_sample, median_sample,
                  min_sample, max_sample, skew_sample, kurt_sample, dd)
      rownames(tb) <- c("Mean", "Std Deviation", "t-stat", "median",
                        "Mininum", "Maximum", "Skewness", "Kurtosis",
                        "Max Drawdown")
      return(tb)
      }
  
Next, I create tables for the different periods using the kableExtra package:

    library(kableExtra)
    
    sample_1 <- "1963-07/2002-07"
    sample_2 <-"2003-01/2009-06"
    sample_3 <-"2009-07/"
    
    
    
    # get tables for each period
    tb_GGR <- stats_table(pts_returns, sample_1)
    tb_DoFaff <- stats_table(pts_returns, sample_2)
    tb_Post2009 <- stats_table(pts_returns, sample_3)
    
    
    kbl(tb_GGR, caption =  "GGR Period (1963-2002)") %>%
      kable_classic() 


GGR Period (1963-2002)

{{< figure src="10.png" width="80%" >}}

    kbl(tb_DoFaff, caption =  "Do-Faff Period (2003-2009)") %>%
      kable_classic()

Do-Faff Period (2003-2009)
{{< figure src="11.png" width="80%" >}}

    kbl(tb_Post2009, caption =  "Post-GFC Period (2003-2009)") %>%
      kable_classic() 

Post-GFC Period (2003-2009)
{{< figure src="12.png" width="80%" >}}

For the GGR period and when trades are opened on the day of divergence, I obtain average monthly excess returns of 0.94% and 1.84% for the committed capital and fully invested strategies. This compares to 0.81% and 1.44% reported by GGR. When trades are opened one day after divergence, I get average returns of 0.65% and 1.23% for the committed capital and fully invested strategies, compared to 0.52% and 0.90% reported by GGR. Therefore, the numbers are close, but not identical. The other statistics are also similar, but not identical. Since GGR don't explain in much detail some aspects of their calculation of pair excess returns, it's difficult to know the source of the difference.

For the second period (2003-2009), the pairs trading strategy shows a significant reduction in profitability. However, the numbers I obtain are higher than those reported by Do and Faff (2010) for this period. Incidentally, Do and Faff (2010) report nearly identical numbers for the committed capital and fully invested approaches, which seems odd, given that the fully invested strategy should have higher leverage than the committed capital one. In any case, I get average excess returns of 0.67% and 1.38% per month when trades are opened on the day of divergence for the committed capital and fully invested approaches, compared to the 0.33% for both strategies reported by Do and Faff. When trades are opened one day after divergence, the returns decrease to 0.22% and 0.43%. This is particularly odd, as I get very similar results for the other periods reported by Do and Faff.

Finally, for the post-GFC period, returns decrease dramatically, and range between 0.04% and 0.07% per month, depending on the strategy. That is, we can say with some confidence that the simple distance-based pairs trading strategy doesn't work after the GFC. Previous studies show that pairs trading typically works well during periods when markets are more volatile. An interesting question is whether this simple strategy was profitable during the market stress induced by the COVID-19 pandemic. As shown below, this is not the case. If we consider the first three months of 2020 as the more volatilie period during the pandemic, average returns are negative or close to zero. Similar results are obtained if we use the entire year of 2020. Therefore, we can quite confidently conclude that this strategy is no longer profitable in the U.S.

    sample_covid <- "2020-01/2020-03"
    tb_covid <- stats_table(pts_returns, sample_covid)
    
    kbl(tb_covid, caption =  "Covid-19 Market Stress (January to March 2020)") %>%
      kable_classic()
      
Covid-19 Market Stress (January to March 2020)
{{< figure src="13.png" width="80%" >}}

## Concluding Remarks

In this post, I replicate some results from the simple distance-based pairs trading strategy of [Gatev, Goetzmann and Rouwenhorst (2006)](https://academic.oup.com/rfs/article-abstract/19/3/797/1646694?redirectedFrom=fulltext) and [Do and Faff (2010)](https://www.tandfonline.com/doi/abs/10.2469/faj.v66.n4.1), extending the sample to the end of 2020. I show that the profitability of the strategy has decreased to essentially zero after 2009. Therefore, we can safely assume that this simple pairs trading strategy is no longer profitable after this period. I hope this code will be useful to researchers exploring this type of strategy.



