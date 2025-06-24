from freqtrade.strategy import IStrategy
from pandas import DataFrame
import pandas_ta as ta

class SimpleScalpingStrategy(IStrategy):
    """
    Basit Scalping Strategy - Test için
    """
    
    INTERFACE_VERSION = 3
    
    # Minimal ROI
    minimal_roi = {
        "60": 0.01,   # 1 dakika sonra %1
        "30": 0.02,   # 30 saniye sonra %2
        "0": 0.03     # Hemen %3
    }
    
    # Stoploss
    stoploss = -0.05  # %5 zarar
    
    # Timeframe
    timeframe = '1m'
    
    # Candle sayısı
    startup_candle_count: int = 30
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # RSI
        dataframe['rsi'] = ta.rsi(dataframe['close'], length=14)
        
        # Moving averages
        dataframe['ema_fast'] = ta.ema(dataframe['close'], length=9)
        dataframe['ema_slow'] = ta.ema(dataframe['close'], length=21)
        
        return dataframe
    
    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # Oversold
                (dataframe['ema_fast'] > dataframe['ema_slow']) &  # Uptrend
                (dataframe['volume'] > 0)
            ),
            'enter_long'] = 1
        
        return dataframe
    
    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # Overbought
                (dataframe['ema_fast'] < dataframe['ema_slow'])  # Downtrend
            ),
            'exit_long'] = 1
        
        return dataframe
