library(rsconnect)


rsconnect::setAccountInfo(name='ds5110',
			  token='39F3BA8750A0FC6A059F27AB00D77438',
			  secret=Sys.getenv("RSHINY_CERT"))

rsconnect::deployApp('ds5110')
