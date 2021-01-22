Statistical Arbitrage on S&P 500 Components by Machine Learning Models
======================================================================

[S&P 500](https://finance.yahoo.com/quote/%5EGSPC/) is one of the most followed equity indices which measures the stock performance of largest 500 companies listed on stock exchanges in US. 

![Figure3](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Figure3.png)

The average annual total return of the index, including dividends, since inception in 1926 has been 9.8% ([Wikipedia](https://en.wikipedia.org/wiki/S%26P_500)). 
From Berkshire Hathaway’s annual meeting 2020, one of the most famous investors Warren Buffet indicated “In my view, for most people,
the best thing is to do is owning the S&P 500 index fund”. Besides directly investing on S&P 500 index, statistical arbitrage trading 
on composites of S&P 500 index is also a hot topic.

This propose of this capstone is to compare different machine learning methods in S&P 500 trading with an extension data (start from year 2005 to the end of year 2019) 
with the following approach:

1. Use grid-search to tune the parameters in machine learning methods
2. Trade with momentum methods and challenge "semi-strong form of market efficiency"

Datasets Extract, Transform and Load (ETL)
------------------------------------------
1. Download from Wharton Research Data Services ([WRDS]( https://wrds-www.wharton.upenn.edu/) and [Wikipedia](https://en.wikipedia.org/wiki/List_of_S%26P_500_companies)), 
clean them and get a mapping table indicates which stock will be included in S&P 500 at the end of the specific time.
2. Use Python yahoo finance module [yahoo-finance-1.0.4](https://pypi.org/project/yahoo-finance-pynterface/) to download daily data of 
all components and S&P 500 index from 2005/01/01 to 2020/01/01 (15 years data).

Exploration Data Analysis (EDA)
-------------------------------

### Data Split

1. Set the length of the in-sample formation window to 750 days (approximately three years) and the length of the subsequent
out-of-sample trading window to 250 days (approximately one year).
2. Move the formation-trading set forward by 250 days in a sliding-window approach, resulting in 12 non-overlapping trading batches in following table

![Table 1](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Table1.png)

### Feature generation 

1. Input: 
Let <a href="https://www.codecogs.com/eqnedit.php?latex=P^s={{(P}_t^s)}_{t\in&space;T}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?P^s={{(P}_t^s)}_{t\in&space;T}" title="P^s={{(P}_t^s)}_{t\in T}" /></a> denote the price process of stock s or financial indicator, with <a href="https://www.codecogs.com/eqnedit.php?latex=s\in\{1,...,n\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?s\in\{1,...,n\}" title="s\in\{1,...,n\}" /></a>. Define the simple return <a href="https://www.codecogs.com/eqnedit.php?latex=R_{t,m}^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?R_{t,m}^s" title="R_{t,m}^s" /></a> for each stock or indicator over m periods as 
<a href="https://www.codecogs.com/eqnedit.php?latex=R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" target="_blank"><img src="https://latex.codecogs.com/gif.latex?R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" title="R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" /></a>

Where <a href="https://www.codecogs.com/eqnedit.php?latex=m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" title="m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" /></a>
The notation of features is <a href="https://www.codecogs.com/eqnedit.php?latex=f_m" target="_blank"><img src="https://latex.codecogs.com/gif.latex?f_m" title="f_m" /></a>, m is defined as above which represents returns of different lags of days.

2. Output: 
Construct a binary response variable <a href="https://www.codecogs.com/eqnedit.php?latex=Y_{t&plus;j,j}^s\in{0,1}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Y_{t&plus;j,j}^s\in{0,1}" title="Y_{t+j,j}^s\in{0,1}" /></a> for each stock s. The response <a href="https://www.codecogs.com/eqnedit.php?latex=Y_{t&plus;j,j}^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Y_{t&plus;j,j}^s" title="Y_{t+j,j}^s" /></a> equals to one (class 1), if the j-period return <a href="https://www.codecogs.com/eqnedit.php?latex=R_{t&plus;j,j}^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?R_{t&plus;j,j}^s" title="R_{t+j,j}^s" /></a> of stock s is larger than the corresponding cross-sectional median return computed over all stocks and zero otherwise (class 0). Here we can try different <a href="https://www.codecogs.com/eqnedit.php?latex=j(s)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?j(s)" title="j(s)" /></a>. For example, if <a href="https://www.codecogs.com/eqnedit.php?latex=j=1" target="_blank"><img src="https://latex.codecogs.com/gif.latex?j=1" title="j=1" /></a> it means one-period return prediction. We try to forecast probability <a href="https://www.codecogs.com/eqnedit.php?latex=\mathcal{P}_{t&plus;j}^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\mathcal{P}_{t&plus;j}^s" title="\mathcal{P}_{t+j}^s" /></a> for each stock s to outperform the cross-sectional median in period t+j. Please note the binary response also can be extended to multinomial response in the future work.


Machine Learning models
-----------------------
Models as k-nearest neighbor (KNN), random forest (RAF), logistic regression (LG), XGBoost, ensemble (average) of KNN, RAF, LG and XGBoost with their tuned parameters are in following table

![Table 2](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Table2.png)

### Results for Machine Learning

Train and test result for machine learning models is

![Figure 1](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Figure1.png)

Stacking ensemble performs best in both train and test subsets. Overall, range of best testing accuracy is from 52.14% to 54.55% which is obviously higher than 50%, we can conclude that machine learning methods give us some effective prediction for one day stock’s movement. 

Trading
-------
We use momentum method which was studied by Jegadeesh and Titman (1993), that is long the highest (“expected winner”) k probabilities and short the lowest (“expected loser”) k probabilities to make profits. 

### Trading Results

For K=3, 5, 10, 15, 20, the following figure shows the result of different cases

![Figure 2](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Figure2.png)

Without consider transaction fee, in years 2008, 2009 and 2011, most of my method with different stocks in each pair performed better than S&P 500. In years 2013, 2014, 2016, 2017 and 2019, even the best performance of my method got less return than S&P 500. Comparing to Krauss et al. (2017), although they got 0.25% daily return, most of their returns are realized before year 2008 (especially from year 1993 to 2000). My result also confirms our hypothesis that “profits are declining in recent years and there is a severe challenge to the semi-strong form of market efficiency.”

Future Work
-----------
There are lots of work can be considered:

(1) For prediction stock’s movement, not only count if outperforms median or not, try multi-classification.\
(2) Analysis detailly with more criteria such as maximum drawdown and reasons why in the years 2013, 2014, 2016, 2017 and 2019, my method didn’t perform well.\
(3) Continue to tune and find the “optimal” parameters and do the momentum trading again.
