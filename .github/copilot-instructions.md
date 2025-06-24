<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Freqtrade Trading Bot Development Instructions

## Overview
This is a Freqtrade trading bot workspace. Freqtrade is a Python-based cryptocurrency trading bot that supports multiple exchanges and provides backtesting, strategy optimization, and automated trading capabilities.

## Key Components
- **Freqtrade Core**: Main trading engine located in the `freqtrade/` directory
- **User Data**: Configuration and strategy files in `user_data/` directory
- **Strategies**: Trading strategies in `user_data/strategies/`
- **Configuration**: Bot settings in `user_data/config.json`

## Development Guidelines

### Strategy Development
- Create new strategies by extending the `IStrategy` class
- Place custom strategies in `user_data/strategies/`
- Use technical indicators from `ft-pandas-ta` library (TA-Lib not available due to compilation issues)
- Implement `populate_indicators()`, `populate_entry_trend()`, and `populate_exit_trend()` methods

### Configuration
- Main configuration file: `user_data/config.json`
- Test configurations in dry-run mode before live trading
- Use proper risk management settings (stake amount, max open trades)

### Testing and Backtesting
- Use `freqtrade backtesting` command for strategy testing
- Download historical data with `freqtrade download-data`
- Analyze results with built-in backtesting analysis tools

### Dependencies
- Note: TA-Lib is not available due to compilation issues on Windows
- Use `ft-pandas-ta` for technical analysis indicators instead
- All other major dependencies are installed and working

### Safety Reminders
- Always test strategies in dry-run mode first
- Never risk money you cannot afford to lose
- Understand the strategy logic before deployment
- Monitor bot performance regularly

### Common Commands
- Start trading: `freqtrade trade`
- Run backtesting: `freqtrade backtesting --strategy StrategyName`
- Download data: `freqtrade download-data --exchange binance --pairs BTC/USDT ETH/USDT`
- List strategies: `freqtrade list-strategies`
- Start web UI: `freqtrade webserver`

When helping with Freqtrade development, prioritize safety, proper testing, and risk management practices.
