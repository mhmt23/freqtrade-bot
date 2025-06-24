# pragma pylint: disable=missing-docstring, invalid-name, pointless-string-statement
# flake8: noqa: F401
# isort: skip_file
# --- Do not remove these imports ---
import numpy as np
import pandas as pd
from pandas import DataFrame
from datetime import datetime
from typing import Optional, Union

from freqtrade.strategy import (BooleanParameter, CategoricalParameter, DecimalParameter,
                                IntParameter, IStrategy, merge_informative_pair)

# Import ft-pandas-ta instead of talib
import freqtrade.vendor.qtpylib.indicators as qtpylib


class UltraAggressiveScalpingStrategy(IStrategy):
    """
    Ultra Aggressive Scalping Strategy - TEST VERSİYONU
    - Maksimum trade yapmak için tasarlandı
    - Her mumda trade yapmaya çalışır
    - %0.1 kar hedefi, stop loss yok
    - Basit moving average cross
    """

    # Strategy interface version
    INTERFACE_VERSION: int = 3

    # Çok düşük kar hedefleri - maksimum trade için
    minimal_roi = {
        "15": 0.001,   # 15 dakika sonra %0.1 kar
        "10": 0.002,   # 10 dakika sonra %0.2 kar  
        "5": 0.003,    # 5 dakika sonra %0.3 kar
        "0": 0.005     # Anında %0.5 kar
    }

    # Stop loss kullanmıyoruz
    stoploss = -0.99  # Effectively no stop

    # Trailing stop kullanmıyoruz
    trailing_stop = False

    # 1 dakika timeframe
    timeframe = '1m'

    # Sadece yeni mumda çalış
    process_only_new_candles = True

    # ROI'ye güven
    use_exit_signal = False
    exit_profit_only = True
    ignore_roi_if_entry_signal = False

    # Minimum startup candle
    startup_candle_count: int = 5

    # Market order kullan (hızlı execution)
    order_types = {
        'entry': 'market',
        'exit': 'market',
        'stoploss': 'market',
        'stoploss_on_exchange': False
    }

    order_time_in_force = {
        'entry': 'GTC',
        'exit': 'GTC'
    }

    def informative_pairs(self):
        return []

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Minimal indikatörler
        """
        # Sadece çok basit MA
        dataframe['sma_3'] = qtpylib.sma(dataframe['close'], 3)
        dataframe['sma_5'] = qtpylib.sma(dataframe['close'], 5)
        
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Ultra agresif giriş - her fırsatta trade
        """
        
        # Çok basit long koşulu
        dataframe.loc[
            (
                # SMA cross up
                (dataframe['sma_3'] > dataframe['sma_5']) &
                # Volume var
                (dataframe['volume'] > 0)
            ),
            ['enter_long', 'enter_tag']
        ] = (1, 'ultra_long')

        # Çok basit short koşulu  
        dataframe.loc[
            (
                # SMA cross down
                (dataframe['sma_3'] < dataframe['sma_5']) &
                # Volume var
                (dataframe['volume'] > 0)
            ),
            ['enter_short', 'enter_tag']
        ] = (1, 'ultra_short')

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Exit sinyalleri - sadece backup
        """
        # Long exit
        dataframe.loc[
            (dataframe['sma_3'] < dataframe['sma_5']),
            ['exit_long', 'exit_tag']
        ] = (1, 'sma_cross_down')

        # Short exit
        dataframe.loc[
            (dataframe['sma_3'] > dataframe['sma_5']),
            ['exit_short', 'exit_tag']
        ] = (1, 'sma_cross_up')

        return dataframe

    def custom_stake_amount(self, pair: str, current_time: datetime, current_rate: float,
                           proposed_stake: float, min_stake: Optional[float], max_stake: float,
                           leverage: float, entry_tag: Optional[str], side: str,
                           **kwargs) -> float:
        """
        Sabit stake amount
        """
        return 20.0
