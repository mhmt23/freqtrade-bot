from freqtrade.strategy import IStrategy
from pandas import DataFrame
import talib.abstract as ta
import freqtrade.vendor.qtpylib.indicators as qtpylib
from functools import reduce

class UltraAggressiveScalpingStrategy(IStrategy):
    """
    Ultra Aggressive Scalping Strategy for Freqtrade
    Hızlı al-sat işlemleri için optimize edilmiş
    """
    
    # Strategy interface version
    INTERFACE_VERSION = 3
    
    # Minimal ROI designed for the strategy
    minimal_roi = {
        "60": 0.01,   # 1 dakika sonra %1 kar
        "30": 0.02,   # 30 saniye sonra %2 kar
        "0": 0.03     # Hemen %3 kar
    }
    
    # Optimal stoploss
    stoploss = -0.05  # %5 zarar durumunda çık
    
    # Optimal timeframe for the strategy
    timeframe = '1m'
    
    # Run "populate_indicators" only for new candle
    process_only_new_candles = False
    
    # Number of candles the strategy requires before producing valid signals
    startup_candle_count: int = 30
    
    # Strategy parameters
    buy_rsi_enabled = True
    buy_rsi = 30
    sell_rsi_enabled = True
    sell_rsi = 70
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Adds several different TA indicators to the given DataFrame
        """
        
        # RSI
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        
        # MACD
        macd = ta.MACD(dataframe)
        dataframe['macd'] = macd['macd']
        dataframe['macdsignal'] = macd['macdsignal']
        dataframe['macdhist'] = macd['macdhist']
        
        # Bollinger Bands
        bollinger = qtpylib.bollinger_bands(qtpylib.typical_price(dataframe), window=20, stds=2)
        dataframe['bb_lowerband'] = bollinger['lower']
        dataframe['bb_middleband'] = bollinger['mid']
        dataframe['bb_upperband'] = bollinger['upper']
        dataframe["bb_percent"] = (
            (dataframe["close"] - dataframe["bb_lowerband"]) /
            (dataframe["bb_upperband"] - dataframe["bb_lowerband"])
        )
        dataframe["bb_width"] = (
            (dataframe["bb_upperband"] - dataframe["bb_lowerband"]) / dataframe["bb_middleband"]
        )
        
        # EMA - Exponential Moving Average
        dataframe['ema_fast'] = ta.EMA(dataframe, timeperiod=5)
        dataframe['ema_slow'] = ta.EMA(dataframe, timeperiod=10)
        
        # SMA - Simple Moving Average
        dataframe['sma_fast'] = ta.SMA(dataframe, timeperiod=5)
        dataframe['sma_slow'] = ta.SMA(dataframe, timeperiod=10)
        
        # Volume indicators
        dataframe['volume_mean'] = dataframe['volume'].rolling(20).mean()
        
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Based on TA indicators, populates the entry signal for the given dataframe
        """
        conditions = []
        
        # RSI oversold
        if self.buy_rsi_enabled:
            conditions.append(dataframe['rsi'] < self.buy_rsi)
        
        # Price below lower Bollinger Band
        conditions.append(dataframe['close'] < dataframe['bb_lowerband'])
        
        # MACD bullish
        conditions.append(dataframe['macd'] > dataframe['macdsignal'])
        
        # EMA crossover
        conditions.append(dataframe['ema_fast'] > dataframe['ema_slow'])
        
        # Volume above average
        conditions.append(dataframe['volume'] > dataframe['volume_mean'])
        
        # Combine all conditions
        if conditions:
            dataframe.loc[
                reduce(lambda x, y: x & y, conditions),
                'enter_long'] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Based on TA indicators, populates the exit signal for the given dataframe
        """
        conditions = []
        
        # RSI overbought
        if self.sell_rsi_enabled:
            conditions.append(dataframe['rsi'] > self.sell_rsi)
        
        # Price above upper Bollinger Band
        conditions.append(dataframe['close'] > dataframe['bb_upperband'])
        
        # MACD bearish
        conditions.append(dataframe['macd'] < dataframe['macdsignal'])
        
        # EMA crossover down
        conditions.append(dataframe['ema_fast'] < dataframe['ema_slow'])
        
        # Combine all conditions
        if conditions:
            dataframe.loc[
                reduce(lambda x, y: x & y, conditions),
                'exit_long'] = 1

        return dataframe
