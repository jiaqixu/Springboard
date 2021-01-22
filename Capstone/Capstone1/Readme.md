Statistical Arbitrage on S&P 500 Components by Machine Learning Models
======================================================================

[S&P 500](https://finance.yahoo.com/quote/%5EGSPC/) is one of the most followed equity indices which measures the stock performance of largest 500 companies listed on stock exchanges in US. 
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

Data Split
----------
1. Set the length of the in-sample formation window to 750 days (approximately three years) and the length of the subsequent
out-of-sample trading window to 250 days (approximately one year).
2. Move the formation-trading set forward by 250 days in a sliding-window approach, resulting in 12 non-overlapping trading batches in following table

.. figure:: ![Table 1](https://github.com/jiaqixu/Springboard/blob/master/Capstone/Capstone1/Figure/Table1.png)

Feature generation 
------------------
1. Input: 
Let $P^s={{(P}_t^s)}_{t\in T}$ denote the price process of stock s or financial indicator, with $s\in{1,...,n}$. Define the simple return $R_{t,m}^s$ for each stock or indicator over m periods as 
$R_{t,m}^s=\frac{P_t^s}{P_{t-m}^s}-1$

Where $m\in\{{1,\ldots,20}\cup{40,60,\ldots,240}\}$
The notation of features is $f_m$, m is defined as above which represents returns of different lags of days.

2. Output: 
Construct a binary response variable $Y_{t+j,j}^s\in{0,1}$ for each stock s. The response $Y_{t+j,j}^s$ equals to one (class 1), if the j-period return $R_{t+j,j}^s$ of stock s is larger than the corresponding cross-sectional median return computed over all stocks and zero otherwise (class 0). Here we can try different $j(s)$. For example, if $j=1$ it means one-period return prediction. We try to forecast probability $\mathcal{P}_{t+j}^s$ for each stock s to outperform the cross-sectional median in period t+j. Please note the binary response also can be extended to multinomial response in the future work.
