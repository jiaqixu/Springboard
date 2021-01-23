Statistical Arbitrage on S&P 500 by Natural Language Processing (NLP)
======================================================================

In capstone one, I used daily price of [S&P 500](https://finance.yahoo.com/quote/%5EGSPC/) with machine learning methods to predict one-day movement of stock price. Furthermore, analysts are dedicated to analyzing and attempt to quantify qualitative data from social media (such as twitter), breaking news (from Reuters), or public released files (SEC mandated reporting). 

![Figure 1](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Figure1.png)

One of the famous forms is SEC 8-K files which must be formed within four business days to provide updated to previous Form 10-Q (quarterly reports) and Form 10-K (annual reports). In this capstone, I used SEC-8k files with NLP to analysis the opinion and ideas from many reports to predict the stock’s movement and make a trading decision automatically.

This propose of this capstone is to compare different deep learning models in S&P 500 trading with an extension data (start from year 2005 to the end of year 2019) 
with the following approach:

1. Use MLP, CNN, RNN and CNN-RNN models to train for stocks with most articles by delay effect
2. Trade with momentum methods and see the performance of methods in 1 for different economics situations (e.g. financial crisis in 2008, COVID-19 pandemic in 2020)

Datasets Extract, Transform and Load (ETL)
------------------------------------------
1. Download SP500 list from [Wikipedia](https://en.wikipedia.org/wiki/List_of_S%26P_500_companies) with stock tickers, GICS sector, and CIK.
2. Use Python yahoo finance module [yahoo-finance-1.0.4](https://pypi.org/project/yahoo-finance-pynterface/) to download daily data of 
all components and S&P 500 index from 2005/01/01 to 2020/01/01 (15 years data).
3. From [SEC website](https://www.sec.gov/edgar/searchedgar/companysearch.html) to download 8-K files of stocks from 2.1 with timestamp from 01-01-2005 to 10-31-2020.

Exploration Data Analysis (EDA)
-------------------------------

### Data Split
This part is similar to capstone 1.
1. Set the length of the in-sample formation window to 750 days (approximately three years) and the length of the subsequent
out-of-sample trading window to 250 days (approximately one year).
2. Move the formation-trading set forward by 250 days in a sliding-window approach, resulting in 13 non-overlapping trading batches in following table

![Table 1](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Table1.png)

### Data Cleaning
Data cleaning includes:
1. Text preprocessing - remove extra whitespace, tokenize and remove punctations, stop words and covert all words to lower case.
2. Set the length of text between 99 (0.05 quantile) and 1508 (0.99 quantile).

There are total 100,961 files as our final research target.


### Feature generation 

1. Input: 

- Let <a href="https://www.codecogs.com/eqnedit.php?latex=P^s={{(P}_t^s)}_{t\in&space;T}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?P^s={{(P}_t^s)}_{t\in&space;T}" title="P^s={{(P}_t^s)}_{t\in T}" /></a> denote the price process of stock s or financial indicator, with <a href="https://www.codecogs.com/eqnedit.php?latex=s\in\{1,...,n\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?s\in\{1,...,n\}" title="s\in\{1,...,n\}" /></a>. Define the simple return <a href="https://www.codecogs.com/eqnedit.php?latex=R_{t,m}^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?R_{t,m}^s" title="R_{t,m}^s" /></a> for each stock or indicator over m periods as <a href="https://www.codecogs.com/eqnedit.php?latex=R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" target="_blank"><img src="https://latex.codecogs.com/gif.latex?R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" title="R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1" /></a>, Where <a href="https://www.codecogs.com/eqnedit.php?latex=m\in\{\text{1&space;week,&space;1&space;month,&space;1&space;quarter&space;and&space;1&space;year}\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?m\in\{\text{1&space;week,&space;1&space;month,&space;1&space;quarter&space;and&space;1&space;year}\}" title="m\in\{\text{1 week, 1 month, 1 quarter and 1 year}\}" /></a>. The notation of features is <a href="https://www.codecogs.com/eqnedit.php?latex=f_m" target="_blank"><img src="https://latex.codecogs.com/gif.latex?f_m" title="f_m" /></a>, m is defined as above which represents returns of different lags of periods. 
Where <a href="https://www.codecogs.com/eqnedit.php?latex=m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" title="m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}" /></a>.
The notation of features is <a href="https://www.codecogs.com/eqnedit.php?latex=f_m" target="_blank"><img src="https://latex.codecogs.com/gif.latex?f_m" title="f_m" /></a>, m is defined as above which represents returns of different lags of days.
- VIX (CBOE Volatility Index), choose open price if the file is released before the market open, otherwise choose close price.
- GIS section as categorical data



2. Output: 
Construct a triple response variable <a href="https://www.codecogs.com/eqnedit.php?latex=Y_t^s\in\{0,1,2\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Y_t^s\in\{0,1,2\}" title="Y_t^s\in\{0,1,2\}" /></a> for each stock s. Here index represents S&P 500 index.

- Delay effect of released files
<a href="https://www.codecogs.com/eqnedit.php?latex=s_{price\_change}(t)&space;=&space;\begin{cases}&space;s_{close}(t)-s_{open}(t),&space;\text{if&space;8-K&space;is&space;released&space;before&space;normal&space;trading&space;hours},\\&space;s_{open}(t&plus;1)-s_{close}(t),&space;\text{if&space;8-K&space;is&space;released&space;during&space;normal&space;trading&space;hours},\\&space;s_{close}(t&plus;1)-s_{open}(t&plus;1),&space;\text{if&space;8-K&space;is&space;released&space;after&space;normal&space;trading&space;hours}.&space;\end{cases}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?s_{price\_change}(t)&space;=&space;\begin{cases}&space;s_{close}(t)-s_{open}(t),&space;\text{if&space;8-K&space;is&space;released&space;before&space;normal&space;trading&space;hours},\\&space;s_{open}(t&plus;1)-s_{close}(t),&space;\text{if&space;8-K&space;is&space;released&space;during&space;normal&space;trading&space;hours},\\&space;s_{close}(t&plus;1)-s_{open}(t&plus;1),&space;\text{if&space;8-K&space;is&space;released&space;after&space;normal&space;trading&space;hours}.&space;\end{cases}" title="s_{price\_change}(t) = \begin{cases} s_{close}(t)-s_{open}(t), \text{if 8-K is released before normal trading hours},\\ s_{open}(t+1)-s_{close}(t), \text{if 8-K is released during normal trading hours},\\ s_{close}(t+1)-s_{open}(t+1), \text{if 8-K is released after normal trading hours}. \end{cases}" /></a>


<a href="https://www.codecogs.com/eqnedit.php?latex=Index_{price\_change}(t)&space;=&space;\begin{cases}&space;index_{close}(t)-index_{open}(t-1),&space;\text{if&space;8-K&space;is&space;released&space;before&space;normal&space;trading&space;hours},\\&space;index_{open}(t&plus;1)-index_{close}(t),&space;\text{if&space;8-K&space;is&space;released&space;during&space;normal&space;trading&space;hours},\\&space;index_{close}(t&plus;1)-index_{open}(t&plus;1),&space;\text{if&space;8-K&space;is&space;released&space;after&space;normal&space;trading&space;hours}.\\&space;\end{cases}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Index_{price\_change}(t)&space;=&space;\begin{cases}&space;index_{close}(t)-index_{open}(t-1),&space;\text{if&space;8-K&space;is&space;released&space;before&space;normal&space;trading&space;hours},\\&space;index_{open}(t&plus;1)-index_{close}(t),&space;\text{if&space;8-K&space;is&space;released&space;during&space;normal&space;trading&space;hours},\\&space;index_{close}(t&plus;1)-index_{open}(t&plus;1),&space;\text{if&space;8-K&space;is&space;released&space;after&space;normal&space;trading&space;hours}.\\&space;\end{cases}" title="Index_{price\_change}(t) = \begin{cases} index_{close}(t)-index_{open}(t-1), \text{if 8-K is released before normal trading hours},\\ index_{open}(t+1)-index_{close}(t), \text{if 8-K is released during normal trading hours},\\ index_{close}(t+1)-index_{open}(t+1), \text{if 8-K is released after normal trading hours}.\\ \end{cases}" /></a>

- <a href="https://www.codecogs.com/eqnedit.php?latex=Y_t^s" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Y_t^s" title="Y_t^s" /></a> is defined as follows:
<a href="https://www.codecogs.com/eqnedit.php?latex=spread_{price\_change}(t)&space;=s_{price\_change}(t)-index_{price\_change}(t)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?spread_{price\_change}(t)&space;=s_{price\_change}(t)-index_{price\_change}(t)" title="spread_{price\_change}(t) =s_{price\_change}(t)-index_{price\_change}(t)" /></a>

<a href="https://www.codecogs.com/eqnedit.php?latex=Y_{t}^s&space;=&space;\begin{cases}&space;\text{up(2),&space;if}&space;spread_{price\_change}(t)>0.01,\\&space;\text{stay(1),&space;if}&space;|spread_{price\_change}(t)|\leq&space;0.01,\\&space;\text{down(0),&space;if}&space;spread_{price\_change}(t)<-0.01.\\&space;\end{cases}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Y_{t}^s&space;=&space;\begin{cases}&space;\text{up(2),&space;if}&space;spread_{price\_change}(t)>0.01,\\&space;\text{stay(1),&space;if}&space;|spread_{price\_change}(t)|\leq&space;0.01,\\&space;\text{down(0),&space;if}&space;spread_{price\_change}(t)<-0.01.\\&space;\end{cases}" title="Y_{t}^s = \begin{cases} \text{up(2), if} spread_{price\_change}(t)>0.01,\\ \text{stay(1), if} |spread_{price\_change}(t)|\leq 0.01,\\ \text{down(0), if} spread_{price\_change}(t)<-0.01.\\ \end{cases}" /></a>


Deep Learning models
-----------------------
Deep learning models MLP, CNN, RNN, RNN+CNN are used in this part and the design of the strcture is as follows:

![Figure 2](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Figure2.png)

### Results for Deep Learning 

Train and test results for deep learning are

![Figure 3](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Figure3.png)
![Figure 4](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Figure4.png)

For accuracy in test (trade) datasets, analysis by different years, MLP performs best in year 2008, 2010, 2012, 2013, 2014 and 2016; CNN performs best in year 2011, 2019 ; RNN performs best in year 2015, 2017; CNN-RNN performs best in year 2018, 2020 Oct.

Trading
-------
We use momentum method which was studied by Jegadeesh and Titman (1993), that is long the highest (“expected winner”) maximum number of k probabilities’ stocks (if it exists), short S&P 500 index with “up” signal and short the lowest (“expected loser”) maximum number of k probabilities’ stocks (if it exists), long S&P 500 index with “down” signal to make profits.  

### Trading Results

For K=3, the comparison of cumulated daily trading returns to S&P 500 without tranaction fee for 3 stocks/pair with CNN-RNN method is displayed as

![Figure 5](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone2/Figure/Figure5.png)

The above plot indicates in year 2008, 2009, 2011, 2015, 2018 and 2020 Oct my method outperformed the benchmark of S&P 500 without transaction cost. Beside year 2012, 2013 and 2014, my method achieved positive cumulated daily returns in other 7 years. My result also confirms our hypothesis that “profits are declining in recent years and there is a severe challenge to the semi-strong form of market efficiency.”

Future Work
-----------
There are lots of work can be considered:

(1) Try other models such as BERT, GPT 2 or GPT3.\
(2) Analysis detailly with more criteria such as maximum drawdown and reasons why in the years 2012,2013 and 2014, my method didn’t perform well. \
(3) Consider transaction fee and leverage.
