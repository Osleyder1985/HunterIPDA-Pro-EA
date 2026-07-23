//+------------------------------------------------------------------+
//|                                                       CUtils.mqh |
//|                           HunterIPDA Pro EA - v1.8 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo proporciona funciones auxiliares para todo el EA:    |
//| - Cálculos matemáticos (lotes, pips, Fibonacci, ADR, ATR)        |
//| - Validaciones de mercado (spread, slippage, sesiones)           |
//| - Gestión de tiempo (sesiones, semanas, meses)                   |
//| - Formateo de datos (tiempo, precio, pips, moneda)               |
//| - Logging centralizado                                           |
//| - Funciones de precio (GetHighestHigh, GetLowestLow, etc.)       |
//|                                                                  |
//| RFs asociados:                                                   |
//|   - Funciones auxiliares para todos los RFs que lo requieran     |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|                                                                  |
//| Versión: 1.5                                                     |
//| Fecha: 22/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 21/07/2026  | Versión inicial del módulo               |
//| 1.1     | 21/07/2026  | Eliminada dependencia de CConstants como |
//|         |             | clase, simplificada inicialización       |
//| 1.2     | 21/07/2026  | Corregida declaración de CalculateATR    |
//| 1.3     | 21/07/2026  | Corregido CalculateCBDR                  |
//| 1.4     | 21/07/2026  | Conversión explícita en IsSpreadValid()  |
//| 1.5     | 22/07/2026  | Añadidas funciones: GetHighestHigh,      |
//|         |             | GetLowestLow, GetClosePrice,             |
//|         |             | GetOpenPrice, GetHighPrice, GetLowPrice, |
//|         |             | GetAccountEquity, GetAccountBalance,     |
//|         |             | GetAccountFreeMargin, GetAccountLeverage,|
//|         |             | GetAccountCurrency, GetPoint, GetDigits, |
//|         |             | GetTickSize, GetTickValue                |
//+------------------------------------------------------------------+

#ifndef __CUTILS_MQH__
#define __CUTILS_MQH__

#include "CConstants.mqh"

//+------------------------------------------------------------------+
//| CLASE CUtils - Utilidades y Funciones Auxiliares                 |
//+------------------------------------------------------------------+
class CUtils {
private:
    //--- Miembros privados
    bool               m_isInitialized;
    
    //--- Métodos privados
    bool               ValidateDouble(double value, double min, double max);
    bool               ValidateInt(int value, int min, int max);
    double             NormalizePrice(double price, int digits);
    double             NormalizeLot(double lot, double step);
    void               LogMessage(string message, ENUM_LOG_LEVEL level);
    
public:
    //--- Constructor / Destructor
    CUtils();
    ~CUtils();
    
    //--- Inicialización
    bool Init();
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Validación de parámetros
    bool ValidateConfig();
    
    //--- Cálculos matemáticos
    double CalculateLotSize(double riskPercent, double stopDistance, double accountEquity, 
                            string symbol, double tickValue);
    double CalculateStopDistance(double entryPrice, double stopPrice, string symbol);
    double CalculatePipValue(string symbol, double lotSize);
    double CalculatePipsBetween(double price1, double price2, string symbol);
    double CalculateFibonacciRetracement(double high, double low, double level);
    double CalculateFibonacciExtension(double high, double low, double level);
    double CalculateEquilibrium(double high, double low);
    double CalculateOTE(double high, double low);
    double CalculateADR(string symbol, int periods = 5);
    double CalculateATR(string symbol, ENUM_TIMEFRAMES tf, int periods = 14);
    double CalculateCBDR(string symbol, datetime startTime, datetime endTime);
    double CalculateStandardDeviation(double &prices[], int count);
    double CalculateRSI(string symbol, ENUM_TIMEFRAMES tf, int periods);
    double CalculateWilliamsR(string symbol, ENUM_TIMEFRAMES tf, int periods);
    
    //--- Funciones de precio (NUEVAS)
    double GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int bars);
    double GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int bars);
    double GetClosePrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetOpenPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetHighPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetLowPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetMedianPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetTypicalPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetWeightedPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);

    //--- Funciones de cuenta (NUEVAS)
    double GetAccountEquity();
    double GetAccountBalance();
    double GetAccountFreeMargin();
    double GetAccountLeverage();
    string GetAccountCurrency();
    double GetAccountProfit();

    //--- Constantes de símbolo (NUEVAS)
    int GetDigits(string symbol);
    double GetPoint(string symbol);
    double GetTickSize(string symbol);
    double GetTickValue(string symbol);
    double GetSpread(string symbol);
    double GetSpreadPips(string symbol);
    double GetMinLot(string symbol);
    double GetMaxLot(string symbol);
    double GetLotStep(string symbol);

    //--- Conversiones
    double PipsToPrice(double pips, string symbol);
    double PriceToPips(double priceDiff, string symbol);
    double ConvertToCurrency(double pnl, string symbol);
    double ConvertLotToUnits(double lot, string symbol);
    
    //--- Validaciones de mercado
    bool IsMarketOpen(string symbol);
    bool IsTradingAllowed(string symbol);
    bool IsSpreadValid(string symbol, double maxSpread);
    bool IsSlippageValid(double expectedPrice, double actualPrice, double maxSlippage, string symbol);
    bool IsNewsEventActive(string newsSymbols);
    bool IsKillZoneActive(ENUM_KILL_ZONE zone, datetime time);
    bool IsAsianSession(datetime time);
    bool IsLondonSession(datetime time);
    bool IsNYSession(datetime time);
    bool IsLondonCloseSession(datetime time);
    bool IsWeekend(datetime time);
    bool IsHoliday(datetime time);
    bool IsVolumeValid(string symbol, double volume);
    bool IsStopLevelValid(string symbol, double price, double stopLevel, ENUM_BIAS bias);
    bool IsTakeProfitValid(string symbol, double price, double takeProfit, ENUM_BIAS bias);
    
    //--- Gestión de tiempo
    datetime GetWeekStart(datetime time);
    datetime GetWeekEnd(datetime time);
    datetime GetMonthStart(datetime time);
    datetime GetMonthEnd(datetime time);
    datetime GetQuarterStart(datetime time);
    datetime GetQuarterEnd(datetime time);
    int GetWeekNumber(datetime time);
    int GetDayOfWeek(datetime time);
    int GetHourOfDay(datetime time);
    datetime GetNewYorkTime(datetime time);
    datetime GetGMTTime(datetime time);
    bool IsNewDay(datetime time);
    bool IsNewWeek(datetime time);
    bool IsNewMonth(datetime time);
    bool IsNewYear(datetime time);
    
    //--- Formateo
    string FormatTime(datetime time);
    string FormatDate(datetime time);
    string FormatPrice(double price, int digits);
    string FormatPips(double pips);
    string FormatCurrency(double value);
    string FormatPercentage(double value);
    string GetBiasName(ENUM_BIAS bias);
    string GetModelName(ENUM_TRADING_MODEL model);
    string GetStateName(ENUM_EA_STATE state);
    string GetZoneName(ENUM_MARKET_ZONE zone);
    string GetMarketStateName(ENUM_MARKET_STATE state);
    string GetReversalTypeName(ENUM_REVERSAL_TYPE type);
    string GetPriceEngineModelName(ENUM_PRICE_ENGINE_MODEL model);
    string GetPatternName(ENUM_INDEX_PATTERN pattern);
    
    //--- Logging
    void Log(string message, ENUM_LOG_LEVEL level = LOG_INFO);
    void LogError(string message, int errorCode = 0);
    void LogWarning(string message);
    void LogInfo(string message);
    void LogDebug(string message);
    void LogTrace(string message);

    //--- Manejo de errores
    string GetLastErrorDescription();
    int GetLastError();
    void ClearLastError();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CUtils::CUtils() {
    m_isInitialized = false;
}

//--- Destructor
CUtils::~CUtils() {
    Deinit();
}

//--- Inicialización
bool CUtils::Init() {
    m_isInitialized = true;
    
    LogInfo("CUtils inicializado correctamente");
    return true;
}

//--- Desinicialización
void CUtils::Deinit() {
    m_isInitialized = false;
}

//--- Validación de configuración
bool CUtils::ValidateConfig() {
    if(!m_isInitialized) {
        LogError("CUtils no está inicializado");
        return false;
    }
    return true;
}

//--- Normalización de precio
double CUtils::NormalizePrice(double price, int digits) {
    if(digits <= 0) digits = 5;
    double multiplier = MathPow(10, digits);
    return MathRound(price * multiplier) / multiplier;
}

//--- Normalización de lote
double CUtils::NormalizeLot(double lot, double step) {
    if(step <= 0) step = 0.01;
    return MathRound(lot / step) * step;
}

//--- Validación de double
bool CUtils::ValidateDouble(double value, double min, double max) {
    if(value < min || value > max) {
        LogWarning("Valor " + DoubleToString(value) + " fuera de rango [" + DoubleToString(min) + ", " + DoubleToString(max) + "]");
        return false;
    }
    return true;
}

//--- Validación de int
bool CUtils::ValidateInt(int value, int min, int max) {
    if(value < min || value > max) {
        LogWarning("Valor " + IntegerToString(value) + " fuera de rango [" + IntegerToString(min) + ", " + IntegerToString(max) + "]");
        return false;
    }
    return true;
}

//--- Logging privado
void CUtils::LogMessage(string message, ENUM_LOG_LEVEL level) {
    string levelStr = "INFO";
    switch(level) {
        case LOG_ERROR:   levelStr = "ERROR"; break;
        case LOG_WARNING: levelStr = "WARNING"; break;
        case LOG_INFO:    levelStr = "INFO"; break;
        case LOG_DEBUG:   levelStr = "DEBUG"; break;
        case LOG_TRACE:   levelStr = "TRACE"; break;
    }
    Print("[" + levelStr + "] " + message);
}

//--- Cálculo de tamaño de lote
double CUtils::CalculateLotSize(double riskPercent, double stopDistance, double accountEquity, 
                                string symbol, double tickValue) {
    if(riskPercent <= 0 || stopDistance <= 0 || accountEquity <= 0) {
        LogError("Parámetros inválidos para CalculateLotSize");
        return 0.0;
    }
    
    double riskAmount = accountEquity * (riskPercent / 100.0);
    double lot = riskAmount / (stopDistance * tickValue);
    
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    if(lot < minLot) lot = minLot;
    if(lot > maxLot) lot = maxLot;
    lot = NormalizeLot(lot, stepLot);
    
    return lot;
}

//--- Cálculo de distancia al stop
double CUtils::CalculateStopDistance(double entryPrice, double stopPrice, string symbol) {
    if(entryPrice <= 0 || stopPrice <= 0) return 0.0;
    double diff = MathAbs(entryPrice - stopPrice);
    return PriceToPips(diff, symbol);
}

//--- Cálculo de valor de pip
double CUtils::CalculatePipValue(string symbol, double lotSize) {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE) * lotSize;
}

//--- Cálculo de pips entre dos precios
double CUtils::CalculatePipsBetween(double price1, double price2, string symbol) {
    double diff = MathAbs(price1 - price2);
    return PriceToPips(diff, symbol);
}

//--- Cálculo de retroceso Fibonacci
double CUtils::CalculateFibonacciRetracement(double high, double low, double level) {
    if(high <= low || level < 0.0 || level > 1.0) return 0.0;
    return high - (high - low) * level;
}

//--- Cálculo de extensión Fibonacci
double CUtils::CalculateFibonacciExtension(double high, double low, double level) {
    if(high <= low || level < 0.0) return 0.0;
    return high + (high - low) * (level - 1.0);
}

//--- Cálculo de Equilibrium (50%)
double CUtils::CalculateEquilibrium(double high, double low) {
    if(high <= low) return 0.0;
    return (high + low) / 2.0;
}

//--- Cálculo de OTE (62%-79%)
double CUtils::CalculateOTE(double high, double low) {
    if(high <= low) return 0.0;
    return CalculateFibonacciRetracement(high, low, 0.705);
}

//--- Cálculo de ADR (Average Daily Range)
double CUtils::CalculateADR(string symbol, int periods) {
    if(periods <= 0) periods = 5;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    int copied = CopyRates(symbol, PERIOD_D1, 1, periods + 1, rates);
    if(copied < periods + 1) {
        LogError("No hay suficientes datos para ADR en " + symbol);
        return 0.0;
    }
    
    double totalRange = 0.0;
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0.0;

    for(int i = 0; i < periods; i++) {
        double range = (rates[i].high - rates[i].low) / point;
        totalRange += range;
    }
    
    return totalRange / periods;
}

//--- Cálculo de ATR
double CUtils::CalculateATR(string symbol, ENUM_TIMEFRAMES tf, int periods) {
    if(periods <= 0) periods = 14;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    int copied = CopyRates(symbol, tf, 1, periods + 1, rates);
    if(copied < periods + 1) {
        LogError("No hay suficientes datos para ATR en " + symbol);
        return 0.0;
    }
    
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0.0;

    double totalATR = 0.0;
    for(int i = 0; i < periods; i++) {
        double tr = MathMax(rates[i].high - rates[i].low,
                   MathMax(MathAbs(rates[i].high - rates[i+1].close),
                          MathAbs(rates[i].low - rates[i+1].close)));
        totalATR += tr / point;
    }
    
    return totalATR / periods;
}

//--- Cálculo de CBDR (Central Bank Dealers Range)
double CUtils::CalculateCBDR(string symbol, datetime startTime, datetime endTime) {
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    int bars = Bars(symbol, PERIOD_M15, startTime, endTime);
    if(bars < 2) {
        LogError("No hay suficientes datos para CBDR en " + symbol);
        return 0.0;
    }
    
    int copied = CopyRates(symbol, PERIOD_M15, 0, bars, rates);
    if(copied < 2) return 0.0;
    
    double high = rates[0].high;
    double low = rates[0].low;
    
    for(int i = 1; i < copied; i++) {
        if(rates[i].high > high) high = rates[i].high;
        if(rates[i].low < low) low = rates[i].low;
    }
    
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0.0;

    return (high - low) / point;
}

//--- Cálculo de desviación estándar
double CUtils::CalculateStandardDeviation(double &prices[], int count) {
    if(count <= 1) return 0.0;
    
    double sum = 0.0;
    for(int i = 0; i < count; i++) sum += prices[i];
    double mean = sum / count;
    
    double variance = 0.0;
    for(int i = 0; i < count; i++) variance += MathPow(prices[i] - mean, 2);
    variance /= count;
    
    return MathSqrt(variance);
}

//--- Cálculo de RSI
double CUtils::CalculateRSI(string symbol, ENUM_TIMEFRAMES tf, int periods) {
    double rsi[];
    ArraySetAsSeries(rsi, true);
    
    int handle = iRSI(symbol, tf, periods, PRICE_CLOSE);
    if(handle == INVALID_HANDLE) {
        LogError("No se pudo crear handle de RSI para " + symbol);
        return 50.0;
    }
    
    if(CopyBuffer(handle, 0, 0, 1, rsi) < 1) {
        IndicatorRelease(handle);
        return 50.0;
    }
    
    IndicatorRelease(handle);
    return rsi[0];
}

//--- Cálculo de Williams %R
double CUtils::CalculateWilliamsR(string symbol, ENUM_TIMEFRAMES tf, int periods) {
    double wr[];
    ArraySetAsSeries(wr, true);
    
    int handle = iWPR(symbol, tf, periods);
    if(handle == INVALID_HANDLE) {
        LogError("No se pudo crear handle de Williams %R para " + symbol);
        return -50.0;
    }
    
    if(CopyBuffer(handle, 0, 0, 1, wr) < 1) {
        IndicatorRelease(handle);
        return -50.0;
    }
    
    IndicatorRelease(handle);
    return wr[0];
}

//+------------------------------------------------------------------+
//| FUNCIONES DE PRECIO (NUEVAS)                                     |
//+------------------------------------------------------------------+

//--- Obtener el máximo más alto en un número de barras
double CUtils::GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int bars) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    if(CopyHigh(symbol, tf, 0, bars, highArray) < bars) return 0;

    double maxHigh = highArray[0];
    for(int i = 1; i < bars; i++) {
        if(highArray[i] > maxHigh) maxHigh = highArray[i];
    }
    return maxHigh;
}

//--- Obtener el mínimo más bajo en un número de barras
double CUtils::GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int bars) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    if(CopyLow(symbol, tf, 0, bars, lowArray) < bars) return 0;

    double minLow = lowArray[0];
    for(int i = 1; i < bars; i++) {
        if(lowArray[i] < minLow) minLow = lowArray[i];
    }
    return minLow;
}

//--- Obtener precio de cierre
double CUtils::GetClosePrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    if(CopyClose(symbol, tf, shift, 1, closeArray) < 1) return 0;
    return closeArray[0];
}

//--- Obtener precio de apertura
double CUtils::GetOpenPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double openArray[];
    ArraySetAsSeries(openArray, true);
    if(CopyOpen(symbol, tf, shift, 1, openArray) < 1) return 0;
    return openArray[0];
}

//--- Obtener precio máximo
double CUtils::GetHighPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    if(CopyHigh(symbol, tf, shift, 1, highArray) < 1) return 0;
    return highArray[0];
}

//--- Obtener precio mínimo
double CUtils::GetLowPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    if(CopyLow(symbol, tf, shift, 1, lowArray) < 1) return 0;
    return lowArray[0];
}

//--- Obtener precio mediano (H+L)/2
double CUtils::GetMedianPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double high = GetHighPrice(symbol, tf, shift);
    double low = GetLowPrice(symbol, tf, shift);
    if(high <= 0 || low <= 0) return 0;
    return (high + low) / 2.0;
}

//--- Obtener precio típico (H+L+C)/3
double CUtils::GetTypicalPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double high = GetHighPrice(symbol, tf, shift);
    double low = GetLowPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    if(high <= 0 || low <= 0 || close <= 0) return 0;
    return (high + low + close) / 3.0;
}

//--- Obtener precio ponderado (H+L+2*C)/4
double CUtils::GetWeightedPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double high = GetHighPrice(symbol, tf, shift);
    double low = GetLowPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    if(high <= 0 || low <= 0 || close <= 0) return 0;
    return (high + low + 2 * close) / 4.0;
}

//+------------------------------------------------------------------+
//| FUNCIONES DE CUENTA (NUEVAS)                                     |
//+------------------------------------------------------------------+

//--- Obtener equity de la cuenta
double CUtils::GetAccountEquity() {
    return AccountInfoDouble(ACCOUNT_EQUITY);
}

//--- Obtener balance de la cuenta
double CUtils::GetAccountBalance() {
    return AccountInfoDouble(ACCOUNT_BALANCE);
}

//--- Obtener margen libre
double CUtils::GetAccountFreeMargin() {
    return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

//--- Obtener apalancamiento
double CUtils::GetAccountLeverage() {
    return (double)AccountInfoInteger(ACCOUNT_LEVERAGE);
}

//--- Obtener moneda de la cuenta
string CUtils::GetAccountCurrency() {
    return AccountInfoString(ACCOUNT_CURRENCY);
}

//--- Obtener profit de la cuenta
double CUtils::GetAccountProfit() {
    return AccountInfoDouble(ACCOUNT_PROFIT);
}

//+------------------------------------------------------------------+
//| CONSTANTES DE SÍMBOLO (NUEVAS)                                   |
//+------------------------------------------------------------------+

//--- Obtener dígitos del símbolo
int CUtils::GetDigits(string symbol) {
    return (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
}

//--- Obtener punto del símbolo
double CUtils::GetPoint(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_POINT);
}

//--- Obtener tick size del símbolo
double CUtils::GetTickSize(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
}

//--- Obtener tick value del símbolo
double CUtils::GetTickValue(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
}

//--- Obtener spread del símbolo
double CUtils::GetSpread(string symbol) {
    return (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
}

//--- Obtener spread en pips
double CUtils::GetSpreadPips(string symbol) {
    double spread = GetSpread(symbol);
    double point = GetPoint(symbol);
    if(point <= 0) return 0;
    return spread * point * 10;
}

//--- Obtener lote mínimo
double CUtils::GetMinLot(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
}

//--- Obtener lote máximo
double CUtils::GetMaxLot(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
}

//--- Obtener step de lote
double CUtils::GetLotStep(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
}

//+------------------------------------------------------------------+
//| CONVERSIONES                                                     |
//+------------------------------------------------------------------+

//--- Conversión de pips a precio
double CUtils::PipsToPrice(double pips, string symbol) {
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    return pips * point * 10;
}

//--- Conversión de precio a pips
double CUtils::PriceToPips(double priceDiff, string symbol) {
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0.0;
    return priceDiff / (point * 10);
}

//--- Conversión a moneda de cuenta
double CUtils::ConvertToCurrency(double pnl, string symbol) {
    return pnl;
}

//--- Conversión de lotes a unidades
double CUtils::ConvertLotToUnits(double lot, string symbol) {
    return lot * 100000;
}

//+------------------------------------------------------------------+
//| VALIDACIONES DE MERCADO                                          |
//+------------------------------------------------------------------+

//--- Verificar si el mercado está abierto
bool CUtils::IsMarketOpen(string symbol) {
    return true;
}

//--- Verificar si el trading está permitido
bool CUtils::IsTradingAllowed(string symbol) {
    return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) > 0;
}

//--- Verificar si el spread es válido
bool CUtils::IsSpreadValid(string symbol, double maxSpread) {
    double spread = (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    return spread <= maxSpread;
}

//--- Verificar slippage
bool CUtils::IsSlippageValid(double expectedPrice, double actualPrice, double maxSlippage, string symbol) {
    double diff = MathAbs(expectedPrice - actualPrice);
    double slippagePips = PriceToPips(diff, symbol);
    return slippagePips <= maxSlippage;
}

//--- Verificar si hay evento de noticias activo
bool CUtils::IsNewsEventActive(string newsSymbols) {
    return false;
}

//--- Verificar si una Kill Zone está activa
bool CUtils::IsKillZoneActive(ENUM_KILL_ZONE zone, datetime time) {
    int hour = GetHourOfDay(time);
    
    switch(zone) {
        case KZ_LONDON:
            return (hour >= KZ_LONDON_START && hour < KZ_LONDON_END);
        case KZ_NEW_YORK:
            return (hour >= KZ_NY_START && hour < KZ_NY_END);
        case KZ_LONDON_CLOSE:
            return (hour >= KZ_LC_START && hour < KZ_LC_END);
        case KZ_ASIAN:
            return (hour >= KZ_ASIAN_START || hour < KZ_ASIAN_END);
        default:
            return false;
    }
}

//--- Verificar sesión Asiática
bool CUtils::IsAsianSession(datetime time) {
    int hour = GetHourOfDay(time);
    return (hour >= ASIAN_SESSION_START || hour < ASIAN_SESSION_END);
}

//--- Verificar sesión London
bool CUtils::IsLondonSession(datetime time) {
    int hour = GetHourOfDay(time);
    return (hour >= KZ_LONDON_START && hour < KZ_LONDON_END);
}

//--- Verificar sesión NY
bool CUtils::IsNYSession(datetime time) {
    int hour = GetHourOfDay(time);
    return (hour >= NY_SESSION_START && hour < NY_SESSION_END);
}

//--- Verificar sesión London Close
bool CUtils::IsLondonCloseSession(datetime time) {
    int hour = GetHourOfDay(time);
    return (hour >= KZ_LC_START && hour < KZ_LC_END);
}

//--- Verificar fin de semana
bool CUtils::IsWeekend(datetime time) {
    int day = GetDayOfWeek(time);
    return (day == 6 || day == 0);
}

//--- Verificar día festivo
bool CUtils::IsHoliday(datetime time) {
    return false;
}

//--- Verificar si el volumen es válido
bool CUtils::IsVolumeValid(string symbol, double volume) {
    double minLot = GetMinLot(symbol);
    double maxLot = GetMaxLot(symbol);
    double lotStep = GetLotStep(symbol);

    if(volume < minLot) return false;
    if(volume > maxLot) return false;
    if(lotStep > 0) {
        double remainder = fmod(volume, lotStep);
        if(remainder > 0.000001) return false;
    }
    return true;
}

//--- Verificar si el stop loss es válido
bool CUtils::IsStopLevelValid(string symbol, double price, double stopLevel, ENUM_BIAS bias) {
    double point = GetPoint(symbol);
    double stopLevelMin = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;

    double distance = MathAbs(price - stopLevel);
    if(distance < stopLevelMin) return false;

    if(bias == BIAS_BULLISH && stopLevel >= price) return false;
    if(bias == BIAS_BEARISH && stopLevel <= price) return false;

    return true;
}

//--- Verificar si el take profit es válido
bool CUtils::IsTakeProfitValid(string symbol, double price, double takeProfit, ENUM_BIAS bias) {
    double point = GetPoint(symbol);
    double stopLevelMin = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;

    double distance = MathAbs(price - takeProfit);
    if(distance < stopLevelMin) return false;

    if(bias == BIAS_BULLISH && takeProfit <= price) return false;
    if(bias == BIAS_BEARISH && takeProfit >= price) return false;

    return true;
}

//+------------------------------------------------------------------+
//| GESTIÓN DE TIEMPO                                                |
//+------------------------------------------------------------------+

//--- Obtener inicio de semana
datetime CUtils::GetWeekStart(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    dt.day_of_week = 0;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    return StructToTime(dt);
}

//--- Obtener fin de semana
datetime CUtils::GetWeekEnd(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    dt.day_of_week = 6;
    dt.hour = 23;
    dt.min = 59;
    dt.sec = 59;
    return StructToTime(dt);
}

//--- Obtener inicio de mes
datetime CUtils::GetMonthStart(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    dt.day = 1;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    return StructToTime(dt);
}

//--- Obtener fin de mes
datetime CUtils::GetMonthEnd(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    dt.day = 1;
    dt.mon++;
    if(dt.mon > 12) { dt.mon = 1; dt.year++; }
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    return StructToTime(dt) - 1;
}

//--- Obtener inicio de trimestre
datetime CUtils::GetQuarterStart(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    int quarter = (dt.mon - 1) / 3;
    dt.mon = quarter * 3 + 1;
    dt.day = 1;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    return StructToTime(dt);
}

//--- Obtener fin de trimestre
datetime CUtils::GetQuarterEnd(datetime time) {
    datetime start = GetQuarterStart(time);
    MqlDateTime dt;
    TimeToStruct(start, dt);
    dt.mon += 3;
    if(dt.mon > 12) { dt.mon = 1; dt.year++; }
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    return StructToTime(dt) - 1;
}

//--- Obtener número de semana
int CUtils::GetWeekNumber(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.day_of_year / 7 + 1;
}

//--- Obtener día de la semana (0=Lunes, 6=Domingo)
int CUtils::GetDayOfWeek(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.day_of_week;
}

//--- Obtener hora del día (0-23)
int CUtils::GetHourOfDay(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.hour;
}

//--- Convertir a hora NY
datetime CUtils::GetNewYorkTime(datetime time) {
    return time + 4 * 3600;
}

//--- Convertir a hora GMT
datetime CUtils::GetGMTTime(datetime time) {
    return time - 4 * 3600;
}

//--- Verificar si es nuevo día
bool CUtils::IsNewDay(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.hour == 0 && dt.min == 0 && dt.sec == 0;
}

//--- Verificar si es nueva semana
bool CUtils::IsNewWeek(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.day_of_week == 0 && dt.hour == 0 && dt.min == 0 && dt.sec == 0;
}

//--- Verificar si es nuevo mes
bool CUtils::IsNewMonth(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.day == 1 && dt.hour == 0 && dt.min == 0 && dt.sec == 0;
}

//--- Verificar si es nuevo año
bool CUtils::IsNewYear(datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    return dt.mon == 1 && dt.day == 1 && dt.hour == 0 && dt.min == 0 && dt.sec == 0;
}

//+------------------------------------------------------------------+
//| FORMATEO                                                         |
//+------------------------------------------------------------------+

//--- Formatear tiempo
string CUtils::FormatTime(datetime time) {
    return TimeToString(time, TIME_DATE | TIME_MINUTES);
}

//--- Formatear fecha
string CUtils::FormatDate(datetime time) {
    return TimeToString(time, TIME_DATE);
}

//--- Formatear precio
string CUtils::FormatPrice(double price, int digits) {
    if(digits <= 0) digits = 5;
    return DoubleToString(price, digits);
}

//--- Formatear pips
string CUtils::FormatPips(double pips) {
    return DoubleToString(pips, 1);
}

//--- Formatear moneda
string CUtils::FormatCurrency(double value) {
    return DoubleToString(value, 2);
}

//--- Formatear porcentaje
string CUtils::FormatPercentage(double value) {
    return DoubleToString(value, 2) + "%";
}

//--- Obtener nombre del bias
string CUtils::GetBiasName(ENUM_BIAS bias) {
    switch(bias) {
        case BIAS_BULLISH: return "BULLISH";
        case BIAS_BEARISH: return "BEARISH";
        case BIAS_NEUTRAL: return "NEUTRAL";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del modelo
string CUtils::GetModelName(ENUM_TRADING_MODEL model) {
    switch(model) {
        case MODEL_POSITION:      return MODEL_NAME_POSITION;
        case MODEL_SWING:         return MODEL_NAME_SWING;
        case MODEL_SHORT_TERM:    return MODEL_NAME_SHORT_TERM;
        case MODEL_OSOK:          return MODEL_NAME_OSOK;
        case MODEL_DAY_TRADING:   return MODEL_NAME_DAY_TRADING;
        case MODEL_SCALPING:      return MODEL_NAME_SCALPING;
        case MODEL_MEGA_TRADE:    return MODEL_NAME_MEGA_TRADE;
        case MODEL_STOCK_TRADING: return MODEL_NAME_STOCK_TRADING;
        case MODEL_BONUS_HUNTER:  return MODEL_NAME_BONUS_HUNTER;
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del estado
string CUtils::GetStateName(ENUM_EA_STATE state) {
    switch(state) {
        case STATE_INIT:                   return "INIT";
        case STATE_IDLE:                   return "IDLE";
        case STATE_MACRO_ANALYSIS:         return "MACRO_ANALYSIS";
        case STATE_MULTI_ASSET_ANALYSIS:   return "MULTI_ASSET_ANALYSIS";
        case STATE_STOCK_TRADING_ANALYSIS: return "STOCK_TRADING_ANALYSIS";
        case STATE_MEGA_TRADE_ANALYSIS:    return "MEGA_TRADE_ANALYSIS";
        case STATE_TRADING_PLAN_ANALYSIS:  return "TRADING_PLAN_ANALYSIS";
        case STATE_BONUS_HUNTER_ANALYSIS:  return "BONUS_HUNTER_ANALYSIS";
        case STATE_SWING_FILTER_ANALYSIS:  return "SWING_FILTER_ANALYSIS";
        case STATE_SHORT_TERM_ANALYSIS:    return "SHORT_TERM_ANALYSIS";
        case STATE_OSOK_ANALYSIS:          return "OSOK_ANALYSIS";
        case STATE_DAY_TRADING_ANALYSIS:   return "DAY_TRADING_ANALYSIS";
        case STATE_SCALPING_ANALYSIS:      return "SCALPING_ANALYSIS";
        case STATE_DATA_RANGE_ANALYSIS:    return "DATA_RANGE_ANALYSIS";
        case STATE_SEASONAL_ANALYSIS:      return "SEASONAL_ANALYSIS";
        case STATE_MODEL_SELECTION:        return "MODEL_SELECTION";
        case STATE_ANALYZING:              return "ANALYZING";
        case STATE_SIGNAL:                 return "SIGNAL";
        case STATE_EXECUTING:              return "EXECUTING";
        case STATE_IN_TRADE:               return "IN_TRADE";
        case STATE_CLOSING:                return "CLOSING";
        case STATE_LOGGING:                return "LOGGING";
        case STATE_PAUSED:                 return "PAUSED";
        case STATE_SHUTDOWN:               return "SHUTDOWN";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre de la zona
string CUtils::GetZoneName(ENUM_MARKET_ZONE zone) {
    switch(zone) {
        case ZONE_PREMIUM:     return "PREMIUM";
        case ZONE_DISCOUNT:    return "DISCOUNT";
        case ZONE_EQUILIBRIUM: return "EQUILIBRIUM";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del estado del mercado
string CUtils::GetMarketStateName(ENUM_MARKET_STATE state) {
    switch(state) {
        case STATE_EXPANSION:     return "EXPANSION";
        case STATE_RETRACEMENT:   return "RETRACEMENT";
        case STATE_REVERSAL:      return "REVERSAL";
        case STATE_CONSOLIDATION: return "CONSOLIDATION";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del tipo de reversión
string CUtils::GetReversalTypeName(ENUM_REVERSAL_TYPE type) {
    switch(type) {
        case REVERSAL_PREV_DAY_HIGH:      return "PREV_DAY_HIGH";
        case REVERSAL_PREV_DAY_LOW:       return "PREV_DAY_LOW";
        case REVERSAL_INTRA_WEEK_HIGH:    return "INTRA_WEEK_HIGH";
        case REVERSAL_INTRA_WEEK_LOW:     return "INTRA_WEEK_LOW";
        case REVERSAL_INTERMEDIATE_HIGH:  return "INTERMEDIATE_HIGH";
        case REVERSAL_INTERMEDIATE_LOW:   return "INTERMEDIATE_LOW";
        case REVERSAL_NY_SESSION:         return "NY_SESSION";
        case REVERSAL_LONDON_CLOSE:       return "LONDON_CLOSE";
        case REVERSAL_CME_OPEN:           return "CME_OPEN";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del modelo de Price Engine
string CUtils::GetPriceEngineModelName(ENUM_PRICE_ENGINE_MODEL model) {
    switch(model) {
        case MODEL_OFFSET_ACCUMULATION: return "OFFSET_ACCUMULATION";
        case MODEL_RE_ACCUMULATION:     return "RE_ACCUMULATION";
        case MODEL_OFFSET_DISTRIBUTION: return "OFFSET_DISTRIBUTION";
        case MODEL_REDISTRIBUTION:      return "REDISTRIBUTION";
        default: return "UNKNOWN";
    }
}

//--- Obtener nombre del patrón de índices
string CUtils::GetPatternName(ENUM_INDEX_PATTERN pattern) {
    switch(pattern) {
        case PATTERN_NORMAL_AM_TREND_PM_CONT: return "NORMAL_AM_TREND_PM_CONT";
        case PATTERN_NORMAL_AM_TREND_PM_REV:  return "NORMAL_AM_TREND_PM_REV";
        case PATTERN_OR_BREAKOUT_AM_TREND:    return "OR_BREAKOUT_AM_TREND";
        case PATTERN_OR_BREAKOUT_AM_REV:      return "OR_BREAKOUT_AM_REV";
        case PATTERN_AM_CONSOL_PM_BREAKOUT:   return "AM_CONSOL_PM_BREAKOUT";
        case PATTERN_AM_CONSOL_PM_REV:        return "AM_CONSOL_PM_REV";
        case PATTERN_OR_RANGE_BOUND:          return "OR_RANGE_BOUND";
        case PATTERN_OR_EXTENDED:             return "OR_EXTENDED";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| LOGGING                                                          |
//+------------------------------------------------------------------+

//--- Logging público
void CUtils::Log(string message, ENUM_LOG_LEVEL level) {
    if(!m_isInitialized) {
        Print("[CUtils] " + message);
        return;
    }
    LogMessage(message, level);
}

//--- Log de error
void CUtils::LogError(string message, int errorCode) {
    string errorMsg = message;
    if(errorCode > 0) {
        errorMsg += " (código: " + IntegerToString(errorCode) + ")";
    }
    LogMessage("[ERROR] " + errorMsg, LOG_ERROR);
}

//--- Log de advertencia
void CUtils::LogWarning(string message) {
    LogMessage("[WARNING] " + message, LOG_WARNING);
}

//--- Log de información
void CUtils::LogInfo(string message) {
    LogMessage("[INFO] " + message, LOG_INFO);
}

//--- Log de depuración
void CUtils::LogDebug(string message) {
    LogMessage("[DEBUG] " + message, LOG_DEBUG);
}

//--- Log de traza
void CUtils::LogTrace(string message) {
    LogMessage("[TRACE] " + message, LOG_TRACE);
}

//+------------------------------------------------------------------+
//| MANEJO DE ERRORES                                                |
//+------------------------------------------------------------------+

//--- Obtener descripción del último error
string CUtils::GetLastErrorDescription() {
    int error = GetLastError();
    if(error == 0) return "No error";
    return GetErrorDescription(error);
}

//+------------------------------------------------------------------+
//| Funciones auxiliares de error                                    |
//+------------------------------------------------------------------+
string GetErrorDescription(int error) {
    switch(error) {
        case 0:   return "No error";
        case 1:   return "No error (ERR_NO_ERROR)";
        case 2:   return "No result (ERR_NO_RESULT)";
        case 3:   return "Common error (ERR_COMMON_ERROR)";
        case 4:   return "Invalid trade parameters (ERR_INVALID_TRADE_PARAMETERS)";
        case 5:   return "Server busy (ERR_SERVER_BUSY)";
        case 6:   return "Old version (ERR_OLD_VERSION)";
        case 7:   return "No connection (ERR_NO_CONNECTION)";
        case 8:   return "Not enough rights (ERR_NOT_ENOUGH_RIGHTS)";
        case 9:   return "Too frequent requests (ERR_TOO_FREQUENT_REQUESTS)";
        case 10:  return "Malfunctional trade (ERR_MALFUNCTIONAL_TRADE)";
        case 11:  return "Account disabled (ERR_ACCOUNT_DISABLED)";
        case 12:  return "Invalid account (ERR_INVALID_ACCOUNT)";
        case 13:  return "Trade timeout (ERR_TRADE_TIMEOUT)";
        case 14:  return "Invalid price (ERR_INVALID_PRICE)";
        case 15:  return "Invalid stops (ERR_INVALID_STOPS)";
        case 16:  return "Invalid trade volume (ERR_INVALID_TRADE_VOLUME)";
        case 17:  return "Market closed (ERR_MARKET_CLOSED)";
        case 18:  return "Trade disabled (ERR_TRADE_DISABLED)";
        case 19:  return "Not enough money (ERR_NOT_ENOUGH_MONEY)";
        case 20:  return "Price changed (ERR_PRICE_CHANGED)";
        case 21:  return "Off quotes (ERR_OFF_QUOTES)";
        case 22:  return "Broker busy (ERR_BROKER_BUSY)";
        case 23:  return "Requote (ERR_REQUOTE)";
        case 24:  return "Order locked (ERR_ORDER_LOCKED)";
        case 25:  return "Long positions only allowed (ERR_LONG_POSITIONS_ONLY_ALLOWED)";
        case 26:  return "Short positions only allowed (ERR_SHORT_POSITIONS_ONLY_ALLOWED)";
        case 27:  return "Trade expiration denied (ERR_TRADE_EXPIRATION_DENIED)";
        case 28:  return "Trade too many orders (ERR_TRADE_TOO_MANY_ORDERS)";
        case 29:  return "Trade hedge prohibited (ERR_TRADE_HEDGE_PROHIBITED)";
        case 30:  return "Trade prohibited by FIFO (ERR_TRADE_PROHIBITED_BY_FIFO)";
        case 100: return "Invalid function parameter (ERR_INVALID_FUNCTION_PARAM)";
        case 101: return "Invalid parameter (ERR_INVALID_PARAMETER)";
        case 102: return "Invalid buffer (ERR_INVALID_BUFFER)";
        case 103: return "Invalid array (ERR_INVALID_ARRAY)";
        case 104: return "Invalid array range (ERR_INVALID_ARRAY_RANGE)";
        case 105: return "Invalid date (ERR_INVALID_DATE)";
        case 106: return "Invalid datetime (ERR_INVALID_DATETIME)";
        case 107: return "Invalid indicator (ERR_INVALID_INDICATOR)";
        case 108: return "Invalid timeframe (ERR_INVALID_TIMEFRAME)";
        case 109: return "Invalid string (ERR_INVALID_STRING)";
        case 110: return "Invalid symbol (ERR_INVALID_SYMBOL)";
        case 111: return "Invalid ticket (ERR_INVALID_TICKET)";
        case 112: return "Invalid function (ERR_INVALID_FUNCTION)";
        case 113: return "Invalid result (ERR_INVALID_RESULT)";
        case 114: return "Array error (ERR_ARRAY_ERROR)";
        case 115: return "Object error (ERR_OBJECT_ERROR)";
        case 116: return "String to double error (ERR_STR_TO_DOUBLE_ERROR)";
        case 117: return "Math error (ERR_MATH_ERROR)";
        case 118: return "No memory (ERR_NO_MEMORY)";
        case 119: return "No string memory (ERR_NO_STRING_MEMORY)";
        case 120: return "String overflow (ERR_STRING_OVERFLOW)";
        case 121: return "Double array overflow (ERR_DOUBLE_ARRAY_OVERFLOW)";
        case 122: return "Float array overflow (ERR_FLOAT_ARRAY_OVERFLOW)";
        case 123: return "Map error (ERR_MAP_ERROR)";
        case 124: return "Queue error (ERR_QUEUE_ERROR)";
        case 125: return "Load image error (ERR_LOAD_IMAGE_ERROR)";
        case 126: return "Unknown object type (ERR_UNKNOWN_OBJECT_TYPE)";
        case 127: return "Property not found (ERR_PROPERTY_NOT_FOUND)";
        case 128: return "Index not found (ERR_INDEX_NOT_FOUND)";
        case 129: return "Object already exists (ERR_OBJECT_ALREADY_EXISTS)";
        case 130: return "Object access error (ERR_OBJECT_ACCESS_ERROR)";
        case 131: return "Object index error (ERR_OBJECT_INDEX_ERROR)";
        case 132: return "Object delete error (ERR_OBJECT_DELETE_ERROR)";
        default: return "Unknown error: " + IntegerToString(error);
    }
}

//--- Obtener código del último error
int CUtils::GetLastError() {
    return GetLastError();
}

//--- Limpiar último error
void CUtils::ClearLastError() {
    ResetLastError();
}

#endif // __CUTILS_MQH__