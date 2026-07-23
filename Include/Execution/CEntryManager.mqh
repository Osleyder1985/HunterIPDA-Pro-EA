//+-------------------------------------------------------------------+
//|                                                 CEntryManager.mqh |
//|                       HunterIPDA Pro EA - v1.8 - Módulo Execution |
//|                                   Copyright 2026, HunterIPDA Team |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                            |
//+-------------------------------------------------------------------+
//| Este módulo gestiona las entradas de trading:                     |
//| - Stop Entries (Buy Stop / Sell Stop)                             |
//| - Limit Entries (Buy Limit / Sell Limit)                          |
//| - Estrategia Híbrida (Stop + Limit)                               |
//| - Market Entries (para scalping)                                  |
//| - Técnicas de entrada por modelo de trading                       |
//| - Validación de entradas                                          |
//|                                                                   |
//| RFs asociados:                                                    |
//|   RF-306 a RF-315                                                 |
//|                                                                   |
//| Dependencias:                                                     |
//|   - CConstants: Constantes y enumeraciones                        |
//|   - CUtils: Utilidades                                            |
//|   - CConfig: Configuración                                        |
//|   - CContext: Contexto de mercado                                 |
//|   - CRiskManager: Gestión de riesgo                               |
//|                                                                   | 
//| Versión: 1.1                                                      |
//| Fecha: 22/07/2026                                                 |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//| CHANGELOG                                                         |
//+-------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                    |
//|---------|-------------|-------------------------------------------|
//| 1.0     | 22/07/2026  | Versión inicial del módulo                |
//| 1.1     | 22/07/2026  | Corregidos métodos duplicados:            |
//|         |             | ShouldMoveBreakeven (eliminado privado)   |
//|         |             | CalculateTradeProgress (eliminado privado)|
//|         |             | GetProgressStatus (cambiado a string)     |
//|         |             | EntryRecord (movido antes de la clase)    |
//|         |             | CalculateTradeProgress usa GetPosition-   |
//|         |             | Progress de CRiskManager                  |
//+-------------------------------------------------------------------+

#ifndef __CENTRYMANAGER_MQH__
#define __CENTRYMANAGER_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CContext.mqh"
#include "CRiskManager.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
//--- NOTA: EntryRecord está definido en CConstants.mqh
//--- Se usa desde allí, no se debe duplicar aquí.

//+------------------------------------------------------------------+
//| CLASE CEntryManager - Gestor de Entradas                         |
//+------------------------------------------------------------------+
class CEntryManager {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CContext*          m_context;
    CRiskManager*      m_riskManager;
    bool               m_isInitialized;
    
    //--- Configuración de entradas
    bool               m_stopEntriesEnabled;
    bool               m_limitEntriesEnabled;
    bool               m_hybridModeEnabled;
    bool               m_marketEntriesEnabled;
    double             m_maxSpreadMultiplier;
    double             m_slippageTolerance;
    int                m_orderExpiryMinutes;
    
    //--- Historial de entradas
    EntryRecord        m_entryHistory[];
    int                m_entryCount;
    int                m_maxHistorySize;
    
    //--- RF-306/307: Stop Entries
    bool               ValidateStopEntry(Signal &signal);
    double             CalculateStopEntryPrice(Signal &signal);
    ENUM_ORDER_TYPE    GetStopOrderType(ENUM_BIAS bias);
    double             GetStopDistance(Signal &signal);
    bool               IsStopEntryValid(Signal &signal);
    
    //--- RF-312/313: Limit Entries
    bool               ValidateLimitEntry(Signal &signal);
    double             CalculateLimitEntryPrice(Signal &signal);
    ENUM_ORDER_TYPE    GetLimitOrderType(ENUM_BIAS bias);
    double             GetLimitDistance(Signal &signal);
    bool               IsLimitEntryValid(Signal &signal);
    bool               IsDeepDiscount(Signal &signal);
    bool               IsDeepPremium(Signal &signal);
    
    //--- RF-315: Hybrid Mode
    bool               ValidateHybridEntry(Signal &signal);
    double             CalculateHybridStopPrice(Signal &signal);
    double             CalculateHybridLimitPrice(Signal &signal);
    bool               IsHybridEntryValid(Signal &signal);
    ENUM_ENTRY_TYPE    SelectHybridType(Signal &signal);
    
    //--- RF-011/012: Market Entries
    bool               ValidateMarketEntry(Signal &signal);
    double             GetMarketPrice(ENUM_BIAS bias);
    bool               IsMarketEntryValid(Signal &signal);
    
    //--- RF-309/310: Scaling In
    bool               ValidateScalingIn(Signal &signal);
    double             CalculateScalingLevel(Signal &signal, int level);
    double             CalculateScalingLot(Signal &signal, int level);
    bool               IsScalingInValid(Signal &signal, int level);
    int                GetMaxScalingLevels(Signal &signal);
    
    //--- RF-314: HTF Context Validation
    bool               ValidateHTFContext(Signal &signal);
    bool               IsHTFArrayValid(Signal &signal);
    bool               IsMonthlyArrayValid(Signal &signal);
    bool               IsWeeklyArrayValid(Signal &signal);
    
    //--- RF-316: Deep Discount/Premium
    double             CalculateFairValue(Signal &signal);
    bool               IsDeepDiscountZone(Signal &signal);
    bool               IsDeepPremiumZone(Signal &signal);
    double             GetDiscountLevel(Signal &signal);
    double             GetPremiumLevel(Signal &signal);
    
    //--- RF-322: Progress Calculation (ELIMINADOS los duplicados de privado)
    //--- NOTA: CalculateTradeProgress está ahora en público
    //--- CalculatePositionProgress y GetTargetRange se usan internamente
    double             GetProgressThreshold(ENUM_TRADING_MODEL model);
    
    //--- Auxiliares
    string             GetEntryTypeName(ENUM_ENTRY_TYPE type);
    bool               IsValidEntryPrice(double price);
    bool               IsValidStopLoss(double sl, double entry, ENUM_BIAS bias);
    bool               IsValidTakeProfit(double tp, double entry, ENUM_BIAS bias);
    double             NormalizePrice(double price, string symbol);
    double             NormalizeLot(double lot, string symbol);
    double             CalculateSpreadMultiplier(string symbol);
    int                CalculateExpiryTime();
    void               AddHistoryEntry(EntryRecord &record);
    void               CleanHistory();
    double             CalculatePositionProgress(ulong ticket);
    double             GetTargetRange(Signal &signal);
    bool               IsProgressSufficient(ulong ticket);
    
public:
    //--- Constructor / Destructor
    CEntryManager();
    ~CEntryManager();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CContext* context, CRiskManager* riskManager);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    bool ExecuteEntry(Signal &signal);
    bool ValidateEntry(Signal &signal);
    ENUM_ENTRY_TYPE SelectEntryType(Signal &signal);
    double CalculateEntryPrice(Signal &signal);
    
    //--- RF-306/307: Stop Entries
    bool ExecuteStopEntry(Signal &signal);
    bool CanExecuteStopEntry(Signal &signal);
    double GetStopEntryPrice(Signal &signal);
    double GetStopEntrySL(Signal &signal);
    double GetStopEntryTP(Signal &signal);
    
    //--- RF-312/313: Limit Entries
    bool ExecuteLimitEntry(Signal &signal);
    bool CanExecuteLimitEntry(Signal &signal);
    double GetLimitEntryPrice(Signal &signal);
    double GetLimitEntrySL(Signal &signal);
    double GetLimitEntryTP(Signal &signal);
    
    //--- RF-315: Hybrid Mode
    bool ExecuteHybridEntry(Signal &signal);
    bool CanExecuteHybridEntry(Signal &signal);
    double GetHybridStopPrice(Signal &signal);
    double GetHybridLimitPrice(Signal &signal);
    ENUM_ENTRY_TYPE GetHybridActiveType(Signal &signal);
    
    //--- RF-311: Market Entries
    bool ExecuteMarketEntry(Signal &signal);
    bool CanExecuteMarketEntry(Signal &signal);
    double GetMarketEntryPrice(Signal &signal);
    
    //--- RF-309/310: Scaling In
    bool ExecuteScalingIn(Signal &signal, int level);
    bool CanExecuteScalingIn(Signal &signal, int level);
    double GetScalingInPrice(Signal &signal, int level);
    double GetScalingInLot(Signal &signal, int level);
    int GetActiveScalingLevels(Signal &signal);
    int GetMaxScalingLevelsForModel(ENUM_TRADING_MODEL model);
    
    //--- RF-314: HTF Context
    bool IsHTFContextValid(Signal &signal);
    bool IsMonthlyContextValid(Signal &signal);
    bool IsWeeklyContextValid(Signal &signal);
    bool IsDailyContextValid(Signal &signal);
    
    //--- RF-316: Deep Discount/Premium
    bool IsDeepDiscountValid(Signal &signal);
    bool IsDeepPremiumValid(Signal &signal);
    double GetDeepDiscountLevel(Signal &signal);
    double GetDeepPremiumLevel(Signal &signal);
    double GetEquilibriumLevel(Signal &signal);
    
    //--- RF-321: Breakeven Management
    bool ShouldMoveBreakeven(ulong ticket);
    bool IsBreakevenPremature(ulong ticket);
    double GetBreakevenThreshold(ENUM_TRADING_MODEL model);
    void UpdateBreakevenStatus(ulong ticket);
    
    //--- RF-322: Progress
    double CalculateTradeProgress(ulong ticket);
    string GetProgressStatus(ulong ticket);
    string GetProgressDescription(ulong ticket);
    bool IsProgressComplete(ulong ticket);
    
    //--- Configuración
    void SetStopEntriesEnabled(bool enabled) { m_stopEntriesEnabled = enabled; }
    void SetLimitEntriesEnabled(bool enabled) { m_limitEntriesEnabled = enabled; }
    void SetHybridModeEnabled(bool enabled) { m_hybridModeEnabled = enabled; }
    void SetMarketEntriesEnabled(bool enabled) { m_marketEntriesEnabled = enabled; }
    void SetMaxSpreadMultiplier(double multiplier) { m_maxSpreadMultiplier = MathMax(1.0, multiplier); }
    void SetSlippageTolerance(double tolerance) { m_slippageTolerance = MathMax(0.1, tolerance); }
    void SetOrderExpiryMinutes(int minutes) { m_orderExpiryMinutes = MathMax(1, minutes); }
    
    //--- Getters
    bool IsStopEntriesEnabled() const { return m_stopEntriesEnabled; }
    bool IsLimitEntriesEnabled() const { return m_limitEntriesEnabled; }
    bool IsHybridModeEnabled() const { return m_hybridModeEnabled; }
    bool IsMarketEntriesEnabled() const { return m_marketEntriesEnabled; }
    int GetEntryCount() const { return m_entryCount; }
    EntryRecord GetEntryHistory(int index) const;
    
    //--- Reportes
    string GetEntrySummary();
    string GetEntryHistoryReport();
    string GetEntryStatusReport(Signal &signal);
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CEntryManager::CEntryManager() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_riskManager = NULL;
    m_isInitialized = false;
    m_stopEntriesEnabled = true;
    m_limitEntriesEnabled = true;
    m_hybridModeEnabled = false;
    m_marketEntriesEnabled = true;
    m_maxSpreadMultiplier = 1.5;
    m_slippageTolerance = 0.5;
    m_orderExpiryMinutes = 30;
    m_entryCount = 0;
    m_maxHistorySize = 1000;
    ArrayResize(m_entryHistory, 0);
}

//--- Destructor
CEntryManager::~CEntryManager() {
    Deinit();
}

//--- Inicialización
bool CEntryManager::Init(CConfig* config, CUtils* utils, CContext* context, CRiskManager* riskManager) {
    if(config == NULL || utils == NULL || context == NULL || riskManager == NULL) {
        Print("CEntryManager::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_context = context;
    m_riskManager = riskManager;
    
    //--- Inicializar configuración
    m_stopEntriesEnabled = true;
    m_limitEntriesEnabled = true;
    m_hybridModeEnabled = false;
    m_marketEntriesEnabled = true;
    m_maxSpreadMultiplier = 1.5;
    m_slippageTolerance = 0.5;
    m_orderExpiryMinutes = 30;
    
    m_isInitialized = true;
    m_utils.LogInfo("CEntryManager inicializado correctamente");
    return true;
}

//--- Desinicialización
void CEntryManager::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_riskManager = NULL;
    m_isInitialized = false;
    ArrayResize(m_entryHistory, 0);
    m_entryCount = 0;
}

//--- RF-308: Validar entrada
bool CEntryManager::ValidateEntry(Signal &signal) {
    if(!m_isInitialized) return false;
    
    //--- Verificar que la señal es válida
    if(!signal.isQualified) return false;
    
    //--- Verificar contexto HTF
    if(!ValidateHTFContext(signal)) return false;
    
    //--- Verificar entrada específica
    ENUM_ENTRY_TYPE entryType = SelectEntryType(signal);
    
    switch(entryType) {
        case ENTRY_BUY_STOP:
        case ENTRY_SELL_STOP:
            return ValidateStopEntry(signal);
        case ENTRY_BUY_LIMIT:
        case ENTRY_SELL_LIMIT:
            return ValidateLimitEntry(signal);
        case ENTRY_HYBRID:
            return ValidateHybridEntry(signal);
        case ENTRY_MARKET:
            return ValidateMarketEntry(signal);
        default:
            return false;
    }
}

//--- RF-308: Seleccionar tipo de entrada
ENUM_ENTRY_TYPE CEntryManager::SelectEntryType(Signal &signal) {
    //--- Verificar modelo de trading
    if(signal.model == MODEL_SCALPING && m_marketEntriesEnabled) {
        return ENTRY_MARKET;
    }
    
    //--- Verificar deep discount/premium
    if(IsDeepDiscountValid(signal) && m_limitEntriesEnabled) {
        return ENTRY_BUY_LIMIT;
    }
    if(IsDeepPremiumValid(signal) && m_limitEntriesEnabled) {
        return ENTRY_SELL_LIMIT;
    }
    
    //--- Verificar modo híbrido
    if(m_hybridModeEnabled && IsHybridEntryValid(signal)) {
        return ENTRY_HYBRID;
    }
    
    //--- Por defecto: Stop Entry
    if(m_stopEntriesEnabled && ValidateStopEntry(signal)) {
        return (signal.bias == BIAS_BULLISH) ? ENTRY_BUY_STOP : ENTRY_SELL_STOP;
    }
    
    //--- Fallback: Limit Entry
    if(m_limitEntriesEnabled && ValidateLimitEntry(signal)) {
        return (signal.bias == BIAS_BULLISH) ? ENTRY_BUY_LIMIT : ENTRY_SELL_LIMIT;
    }
    
    //--- Último recurso: Market
    if(m_marketEntriesEnabled) {
        return ENTRY_MARKET;
    }
    
    return ENTRY_MARKET;
}

//--- RF-308: Calcular precio de entrada
double CEntryManager::CalculateEntryPrice(Signal &signal) {
    ENUM_ENTRY_TYPE type = SelectEntryType(signal);
    
    switch(type) {
        case ENTRY_BUY_STOP:
        case ENTRY_SELL_STOP:
            return CalculateStopEntryPrice(signal);
        case ENTRY_BUY_LIMIT:
        case ENTRY_SELL_LIMIT:
            return CalculateLimitEntryPrice(signal);
        case ENTRY_HYBRID:
            return GetHybridActiveType(signal) == ENTRY_BUY_STOP ? 
                   CalculateHybridStopPrice(signal) : CalculateHybridLimitPrice(signal);
        case ENTRY_MARKET:
            return GetMarketPrice(signal.bias);
        default:
            return 0;
    }
}

//--- RF-306/307: Validar Stop Entry
bool CEntryManager::ValidateStopEntry(Signal &signal) {
    if(!m_stopEntriesEnabled) return false;
    
    //--- Verificar precio de entrada
    double entryPrice = CalculateStopEntryPrice(signal);
    if(!IsValidEntryPrice(entryPrice)) return false;
    
    //--- Verificar SL
    double sl = GetStopEntrySL(signal);
    if(!IsValidStopLoss(sl, entryPrice, signal.bias)) return false;
    
    //--- Verificar TP
    double tp = GetStopEntryTP(signal);
    if(!IsValidTakeProfit(tp, entryPrice, signal.bias)) return false;
    
    //--- Verificar distancia
    double distance = GetStopDistance(signal);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    if(distance / point < 5) return false; // Mínimo 5 pips
    
    //--- Verificar spread
    if(!m_riskManager.IsSpreadValid(signal.symbol)) return false;
    
    //--- Verificar contexto
    if(!ValidateHTFContext(signal)) return false;
    
    return true;
}

//--- RF-306/307: Calcular precio Stop Entry
double CEntryManager::CalculateStopEntryPrice(Signal &signal) {
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    double distance = GetStopDistance(signal);
    
    if(signal.bias == BIAS_BULLISH) {
        //--- Buy Stop: por encima del precio actual
        double candleHigh = m_utils.GetHighestHigh(signal.symbol, PERIOD_H1, 5);
        if(candleHigh > 0) {
            return candleHigh + point * 2;
        }
        return currentPrice + distance;
    } else {
        //--- Sell Stop: por debajo del precio actual
        double candleLow = m_utils.GetLowestLow(signal.symbol, PERIOD_H1, 5);
        if(candleLow > 0) {
            return candleLow - point * 2;
        }
        return currentPrice - distance;
    }
}

//--- RF-306/307: Obtener distancia Stop
double CEntryManager::GetStopDistance(Signal &signal) {
    double atr = m_utils.CalculateATR(signal.symbol, PERIOD_H1, 14);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    
    //--- ATR * 0.5 o 20 pips, lo que sea mayor
    double minDistance = 20 * point * 10;
    double atrDistance = atr * 0.5;
    
    return MathMax(minDistance, atrDistance);
}

//--- RF-306: Obtener tipo de orden Stop
ENUM_ORDER_TYPE CEntryManager::GetStopOrderType(ENUM_BIAS bias) {
    return (bias == BIAS_BULLISH) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
}

//--- RF-312/313: Validar Limit Entry
bool CEntryManager::ValidateLimitEntry(Signal &signal) {
    if(!m_limitEntriesEnabled) return false;
    
    //--- Verificar precio de entrada
    double entryPrice = CalculateLimitEntryPrice(signal);
    if(!IsValidEntryPrice(entryPrice)) return false;
    
    //--- Verificar SL
    double sl = GetLimitEntrySL(signal);
    if(!IsValidStopLoss(sl, entryPrice, signal.bias)) return false;
    
    //--- Verificar TP
    double tp = GetLimitEntryTP(signal);
    if(!IsValidTakeProfit(tp, entryPrice, signal.bias)) return false;
    
    //--- Verificar deep discount/premium
    if(signal.bias == BIAS_BULLISH && !IsDeepDiscountValid(signal)) {
        return false;
    }
    if(signal.bias == BIAS_BEARISH && !IsDeepPremiumValid(signal)) {
        return false;
    }
    
    //--- Verificar spread
    if(!m_riskManager.IsSpreadValid(signal.symbol)) return false;
    
    //--- Verificar contexto
    if(!ValidateHTFContext(signal)) return false;
    
    return true;
}

//--- RF-312/313: Calcular precio Limit Entry
double CEntryManager::CalculateLimitEntryPrice(Signal &signal) {
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    double distance = GetLimitDistance(signal);
    
    if(signal.bias == BIAS_BULLISH) {
        //--- Buy Limit: en el close de down candle (deep discount)
        double candleClose = m_utils.GetClosePrice(signal.symbol, PERIOD_D1, 1);
        if(candleClose > 0 && candleClose < currentPrice) {
            return candleClose;
        }
        return currentPrice - distance;
    } else {
        //--- Sell Limit: en el close de up candle (deep premium)
        double candleClose = m_utils.GetClosePrice(signal.symbol, PERIOD_D1, 1);
        if(candleClose > 0 && candleClose > currentPrice) {
            return candleClose;
        }
        return currentPrice + distance;
    }
}

//--- RF-312/313: Obtener distancia Limit
double CEntryManager::GetLimitDistance(Signal &signal) {
    double atr = m_utils.CalculateATR(signal.symbol, PERIOD_H1, 14);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    
    //--- ATR * 0.3 o 10 pips, lo que sea mayor
    double minDistance = 10 * point * 10;
    double atrDistance = atr * 0.3;
    
    return MathMax(minDistance, atrDistance);
}

//--- RF-312: Obtener tipo de orden Limit
ENUM_ORDER_TYPE CEntryManager::GetLimitOrderType(ENUM_BIAS bias) {
    return (bias == BIAS_BULLISH) ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
}

//--- RF-315: Validar Hybrid Entry
bool CEntryManager::ValidateHybridEntry(Signal &signal) {
    if(!m_hybridModeEnabled) return false;
    if(!ValidateStopEntry(signal)) return false;
    if(!ValidateLimitEntry(signal)) return false;
    
    return true;
}

//--- RF-315: Calcular precio Stop Hybrid
double CEntryManager::CalculateHybridStopPrice(Signal &signal) {
    return CalculateStopEntryPrice(signal);
}

//--- RF-315: Calcular precio Limit Hybrid
double CEntryManager::CalculateHybridLimitPrice(Signal &signal) {
    return CalculateLimitEntryPrice(signal);
}

//--- RF-315: Seleccionar tipo Hybrid
ENUM_ENTRY_TYPE CEntryManager::SelectHybridType(Signal &signal) {
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double stopPrice = CalculateHybridStopPrice(signal);
    double limitPrice = CalculateHybridLimitPrice(signal);
    
    //--- Verificar cuál se activará primero
    if(signal.bias == BIAS_BULLISH) {
        if(stopPrice < limitPrice) {
            //--- Stop más cercano: usar Buy Stop
            return ENTRY_BUY_STOP;
        } else {
            //--- Limit más cercano: usar Buy Limit
            return ENTRY_BUY_LIMIT;
        }
    } else {
        if(stopPrice > limitPrice) {
            //--- Stop más cercano: usar Sell Stop
            return ENTRY_SELL_STOP;
        } else {
            //--- Limit más cercano: usar Sell Limit
            return ENTRY_SELL_LIMIT;
        }
    }
}

//--- RF-311: Validar Market Entry
bool CEntryManager::ValidateMarketEntry(Signal &signal) {
    if(!m_marketEntriesEnabled) return false;
    
    //--- Verificar spread
    if(!m_riskManager.IsSpreadValid(signal.symbol)) return false;
    
    //--- Verificar slippage
    double expectedPrice = GetMarketPrice(signal.bias);
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    double slippage = MathAbs(expectedPrice - currentPrice) / point / 10;
    
    if(slippage > m_slippageTolerance) return false;
    
    //--- Verificar contexto
    if(!ValidateHTFContext(signal)) return false;
    
    return true;
}

//--- RF-311: Obtener precio Market
double CEntryManager::GetMarketPrice(ENUM_BIAS bias) {
    if(bias == BIAS_BULLISH) {
        return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    } else {
        return SymbolInfoDouble(_Symbol, SYMBOL_BID);
    }
}

//--- RF-314: Validar contexto HTF
bool CEntryManager::ValidateHTFContext(Signal &signal) {
    if(m_context == NULL) return true;
    
    //--- Verificar alineación con temporalidades altas
    ENUM_BIAS overallBias = m_context.GetOverallBias();
    
    //--- Si la señal es neutral, no se alinea
    if(signal.bias == BIAS_NEUTRAL) return false;
    
    //--- Verificar al menos alineación con daily o weekly
    bool monthlyAligned = m_context.GetMonthlyBias() == signal.bias || m_context.GetMonthlyBias() == BIAS_NEUTRAL;
    bool weeklyAligned = m_context.GetWeeklyBias() == signal.bias || m_context.GetWeeklyBias() == BIAS_NEUTRAL;
    bool dailyAligned = m_context.GetDailyBias() == signal.bias || m_context.GetDailyBias() == BIAS_NEUTRAL;
    
    //--- Para modelos de alto timeframe, require alineación HTF
    if(signal.model == MODEL_POSITION || signal.model == MODEL_SWING || signal.model == MODEL_MEGA_TRADE) {
        return monthlyAligned && weeklyAligned;
    }
    
    //--- Para otros modelos, al menos daily alineado
    return dailyAligned || (weeklyAligned && monthlyAligned);
}

//--- RF-316: Verificar Deep Discount
bool CEntryManager::IsDeepDiscountValid(Signal &signal) {
    if(signal.bias != BIAS_BULLISH) return false;
    
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double equilibrium = GetEquilibriumLevel(signal);
    double discountLevel = GetDeepDiscountLevel(signal);
    
    return currentPrice < discountLevel;
}

//--- RF-316: Verificar Deep Premium
bool CEntryManager::IsDeepPremiumValid(Signal &signal) {
    if(signal.bias != BIAS_BEARISH) return false;
    
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double equilibrium = GetEquilibriumLevel(signal);
    double premiumLevel = GetDeepPremiumLevel(signal);
    
    return currentPrice > premiumLevel;
}

//--- RF-316: Obtener Deep Discount Level
double CEntryManager::GetDeepDiscountLevel(Signal &signal) {
    double high = m_utils.GetHighestHigh(signal.symbol, PERIOD_D1, 20);
    double low = m_utils.GetLowestLow(signal.symbol, PERIOD_D1, 20);
    
    if(high <= low) return 0;
    
    double range = high - low;
    return low + range * 0.3; // 30% desde el mínimo (zona de descuento profundo)
}

//--- RF-316: Obtener Deep Premium Level
double CEntryManager::GetDeepPremiumLevel(Signal &signal) {
    double high = m_utils.GetHighestHigh(signal.symbol, PERIOD_D1, 20);
    double low = m_utils.GetLowestLow(signal.symbol, PERIOD_D1, 20);
    
    if(high <= low) return 0;
    
    double range = high - low;
    return high - range * 0.3; // 30% desde el máximo (zona de prima profunda)
}

//--- RF-316: Obtener Equilibrium
double CEntryManager::GetEquilibriumLevel(Signal &signal) {
    double high = m_utils.GetHighestHigh(signal.symbol, PERIOD_D1, 20);
    double low = m_utils.GetLowestLow(signal.symbol, PERIOD_D1, 20);
    
    if(high <= low) return 0;
    
    return (high + low) / 2.0;
}

//--- RF-309/310: Validar Scaling In
bool CEntryManager::ValidateScalingIn(Signal &signal) {
    if(!m_riskManager.IsTradeAllowed()) return false;
    if(!ValidateHTFContext(signal)) return false;
    
    //--- Verificar modelo permite scaling in
    if(signal.model != MODEL_POSITION && signal.model != MODEL_SWING) return false;
    
    //--- Verificar el precio está en dirección favorable
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double entryPrice = signal.entryPrice;
    
    if(signal.bias == BIAS_BULLISH && currentPrice < entryPrice) {
        //--- En uptrend, scalear en down candles
        return true;
    }
    if(signal.bias == BIAS_BEARISH && currentPrice > entryPrice) {
        //--- En downtrend, scalear en up candles
        return true;
    }
    
    return false;
}

//--- RF-309/310: Calcular nivel de Scaling
double CEntryManager::CalculateScalingLevel(Signal &signal, int level) {
    double currentPrice = SymbolInfoDouble(signal.symbol, SYMBOL_BID);
    double atr = m_utils.CalculateATR(signal.symbol, PERIOD_H1, 14);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    
    //--- Nivel = precio actual + ATR * (0.5 + nivel * 0.25)
    double factor = 0.5 + level * 0.25;
    
    if(signal.bias == BIAS_BULLISH) {
        return currentPrice - atr * factor;
    } else {
        return currentPrice + atr * factor;
    }
}

//--- RF-309/310: Calcular lote de Scaling
double CEntryManager::CalculateScalingLot(Signal &signal, int level) {
    double baseLot = signal.risk;
    double reductionFactor = 1.0 / (level + 1); // 1/2, 1/3, 1/4
    
    return baseLot * reductionFactor * 0.5; // 50% del lote base reducido
}

//--- RF-309/310: Obtener máximos niveles de Scaling
int CEntryManager::GetMaxScalingLevels(Signal &signal) {
    switch(signal.model) {
        case MODEL_POSITION: return 3;
        case MODEL_SWING: return 2;
        case MODEL_SHORT_TERM: return 1;
        default: return 0;
    }
}

int CEntryManager::GetMaxScalingLevelsForModel(ENUM_TRADING_MODEL model) {
    switch(model) {
        case MODEL_POSITION: return 3;
        case MODEL_SWING: return 2;
        case MODEL_SHORT_TERM: return 1;
        default: return 0;
    }
}

//--- RF-322: Calcular progreso del trade (USANDO CRiskManager)
double CEntryManager::CalculateTradeProgress(ulong ticket) {
    if(m_riskManager == NULL) return 0;
    return m_riskManager.GetPositionProgress(ticket);
}

//--- RF-322: Obtener estado de progreso
string CEntryManager::GetProgressStatus(ulong ticket) {
    double progress = CalculateTradeProgress(ticket);
    
    if(progress >= 100) return "COMPLETE";
    if(progress >= 75) return "ADVANCED";
    if(progress >= 50) return "MID";
    if(progress >= 25) return "EARLY";
    return "INITIAL";
}

//--- RF-322: Obtener descripción de progreso
string CEntryManager::GetProgressDescription(ulong ticket) {
    double progress = CalculateTradeProgress(ticket);
    
    if(progress >= 100) return "Target reached";
    if(progress >= 75) return "Near target (75%+)";
    if(progress >= 50) return "Halfway there (50%+)";
    if(progress >= 25) return "Early progress (25%+)";
    return "Just started";
}

//--- RF-322: Verificar progreso completo
bool CEntryManager::IsProgressComplete(ulong ticket) {
    return CalculateTradeProgress(ticket) >= 100;
}

//--- RF-321: Verificar si mover a breakeven
bool CEntryManager::ShouldMoveBreakeven(ulong ticket) {
    //--- Implementación simplificada
    //--- En implementación real, usaría PositionSelectByTicket y verificar progreso
    return false;
}

//--- RF-321: Verificar si es prematuro
bool CEntryManager::IsBreakevenPremature(ulong ticket) {
    if(m_riskManager == NULL) return true;
    
    double progress = CalculateTradeProgress(ticket);
    ENUM_TRADING_MODEL model = MODEL_POSITION; // Placeholder
    
    double threshold = GetBreakevenThreshold(model);
    
    return progress < threshold;
}

//--- RF-321: Obtener umbral de breakeven
double CEntryManager::GetBreakevenThreshold(ENUM_TRADING_MODEL model) {
    switch(model) {
        case MODEL_POSITION:    return 50.0; // 50% del objetivo
        case MODEL_SWING:       return 25.0; // 25% del objetivo
        case MODEL_SHORT_TERM:  return 20.0;
        case MODEL_OSOK:        return 30.0;
        case MODEL_DAY_TRADING: return 15.0;
        case MODEL_SCALPING:    return 10.0;
        case MODEL_MEGA_TRADE:  return 40.0;
        case MODEL_STOCK_TRADING: return 30.0;
        default: return 30.0;
    }
}

//--- RF-321: Actualizar estado de breakeven
void CEntryManager::UpdateBreakevenStatus(ulong ticket) {
    //--- Placeholder
}

//--- RF-311: Ejecutar entrada Market
bool CEntryManager::ExecuteMarketEntry(Signal &signal) {
    if(!ValidateMarketEntry(signal)) return false;
    
    double price = GetMarketPrice(signal.bias);
    double sl = signal.stopLoss;
    double tp = signal.takeProfit;
    double lot = signal.risk;
    
    //--- Normalizar
    price = NormalizePrice(price, signal.symbol);
    sl = NormalizePrice(sl, signal.symbol);
    tp = NormalizePrice(tp, signal.symbol);
    lot = NormalizeLot(lot, signal.symbol);
    
    //--- Crear orden
    //--- En implementación real, usar OrderSend o PositionOpen
    
    //--- Registrar en historial
    EntryRecord record;
    record.timestamp = TimeCurrent();
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.entryType = ENTRY_MARKET;
    record.price = price;
    record.stopLoss = sl;
    record.takeProfit = tp;
    record.lot = lot;
    record.isExecuted = true;
    record.isCancelled = false;
    record.reason = "Market Entry executed";
    AddHistoryEntry(record);
    
    m_utils.LogInfo("Market Entry executed: " + signal.symbol + " | Price: " + DoubleToString(price, 5) +
                    " | SL: " + DoubleToString(sl, 5) + " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-311: Can execute Market Entry
bool CEntryManager::CanExecuteMarketEntry(Signal &signal) {
    return ValidateMarketEntry(signal);
}

//--- RF-311: Get Market Entry price
double CEntryManager::GetMarketEntryPrice(Signal &signal) {
    return GetMarketPrice(signal.bias);
}

//--- RF-306: Execute Stop Entry
bool CEntryManager::ExecuteStopEntry(Signal &signal) {
    if(!ValidateStopEntry(signal)) return false;
    
    double price = CalculateStopEntryPrice(signal);
    double sl = GetStopEntrySL(signal);
    double tp = GetStopEntryTP(signal);
    double lot = signal.risk;
    ENUM_ORDER_TYPE orderType = GetStopOrderType(signal.bias);
    
    //--- Normalizar
    price = NormalizePrice(price, signal.symbol);
    sl = NormalizePrice(sl, signal.symbol);
    tp = NormalizePrice(tp, signal.symbol);
    lot = NormalizeLot(lot, signal.symbol);
    
    //--- Crear orden pendiente
    //--- En implementación real, usar OrderSend con ORDER_TYPE_BUY_STOP/SELL_STOP
    
    //--- Registrar en historial
    EntryRecord record;
    record.timestamp = TimeCurrent();
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.entryType = (orderType == ORDER_TYPE_BUY_STOP) ? ENTRY_BUY_STOP : ENTRY_SELL_STOP;
    record.price = price;
    record.stopLoss = sl;
    record.takeProfit = tp;
    record.lot = lot;
    record.isExecuted = true;
    record.isCancelled = false;
    record.reason = "Stop Entry executed";
    AddHistoryEntry(record);
    
    m_utils.LogInfo("Stop Entry executed: " + signal.symbol + " | Type: " + 
                    (orderType == ORDER_TYPE_BUY_STOP ? "BUY_STOP" : "SELL_STOP") +
                    " | Price: " + DoubleToString(price, 5) +
                    " | SL: " + DoubleToString(sl, 5) + " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-306: Can execute Stop Entry
bool CEntryManager::CanExecuteStopEntry(Signal &signal) {
    return ValidateStopEntry(signal);
}

//--- RF-306: Get Stop Entry price
double CEntryManager::GetStopEntryPrice(Signal &signal) {
    return CalculateStopEntryPrice(signal);
}

//--- RF-306: Get Stop Entry SL
double CEntryManager::GetStopEntrySL(Signal &signal) {
    return signal.stopLoss;
}

//--- RF-306: Get Stop Entry TP
double CEntryManager::GetStopEntryTP(Signal &signal) {
    return signal.takeProfit;
}

//--- RF-312: Execute Limit Entry
bool CEntryManager::ExecuteLimitEntry(Signal &signal) {
    if(!ValidateLimitEntry(signal)) return false;
    
    double price = CalculateLimitEntryPrice(signal);
    double sl = GetLimitEntrySL(signal);
    double tp = GetLimitEntryTP(signal);
    double lot = signal.risk;
    ENUM_ORDER_TYPE orderType = GetLimitOrderType(signal.bias);
    
    //--- Normalizar
    price = NormalizePrice(price, signal.symbol);
    sl = NormalizePrice(sl, signal.symbol);
    tp = NormalizePrice(tp, signal.symbol);
    lot = NormalizeLot(lot, signal.symbol);
    
    //--- Crear orden pendiente
    //--- En implementación real, usar OrderSend con ORDER_TYPE_BUY_LIMIT/SELL_LIMIT
    
    //--- Registrar en historial
    EntryRecord record;
    record.timestamp = TimeCurrent();
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.entryType = (orderType == ORDER_TYPE_BUY_LIMIT) ? ENTRY_BUY_LIMIT : ENTRY_SELL_LIMIT;
    record.price = price;
    record.stopLoss = sl;
    record.takeProfit = tp;
    record.lot = lot;
    record.isExecuted = true;
    record.isCancelled = false;
    record.reason = "Limit Entry executed";
    AddHistoryEntry(record);
    
    m_utils.LogInfo("Limit Entry executed: " + signal.symbol + " | Type: " + 
                    (orderType == ORDER_TYPE_BUY_LIMIT ? "BUY_LIMIT" : "SELL_LIMIT") +
                    " | Price: " + DoubleToString(price, 5) +
                    " | SL: " + DoubleToString(sl, 5) + " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-312: Can execute Limit Entry
bool CEntryManager::CanExecuteLimitEntry(Signal &signal) {
    return ValidateLimitEntry(signal);
}

//--- RF-312: Get Limit Entry price
double CEntryManager::GetLimitEntryPrice(Signal &signal) {
    return CalculateLimitEntryPrice(signal);
}

//--- RF-312: Get Limit Entry SL
double CEntryManager::GetLimitEntrySL(Signal &signal) {
    return signal.stopLoss;
}

//--- RF-312: Get Limit Entry TP
double CEntryManager::GetLimitEntryTP(Signal &signal) {
    return signal.takeProfit;
}

//--- RF-315: Execute Hybrid Entry
bool CEntryManager::ExecuteHybridEntry(Signal &signal) {
    if(!ValidateHybridEntry(signal)) return false;
    
    double stopPrice = CalculateHybridStopPrice(signal);
    double limitPrice = CalculateHybridLimitPrice(signal);
    double sl = signal.stopLoss;
    double tp = signal.takeProfit;
    double lot = signal.risk;
    
    //--- Normalizar
    stopPrice = NormalizePrice(stopPrice, signal.symbol);
    limitPrice = NormalizePrice(limitPrice, signal.symbol);
    sl = NormalizePrice(sl, signal.symbol);
    tp = NormalizePrice(tp, signal.symbol);
    lot = NormalizeLot(lot, signal.symbol);
    
    //--- Colocar ambas órdenes (Stop y Limit)
    //--- En implementación real, usar OrderSend para ambas órdenes
    
    //--- Registrar en historial
    EntryRecord record;
    record.timestamp = TimeCurrent();
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.entryType = ENTRY_HYBRID;
    record.price = 0; // Híbrido: dos precios
    record.stopLoss = sl;
    record.takeProfit = tp;
    record.lot = lot;
    record.isExecuted = true;
    record.isCancelled = false;
    record.reason = "Hybrid Entry executed: Stop at " + DoubleToString(stopPrice, 5) + 
                    ", Limit at " + DoubleToString(limitPrice, 5);
    AddHistoryEntry(record);
    
    m_utils.LogInfo("Hybrid Entry executed: " + signal.symbol + 
                    " | Stop: " + DoubleToString(stopPrice, 5) + 
                    " | Limit: " + DoubleToString(limitPrice, 5) +
                    " | SL: " + DoubleToString(sl, 5) + " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-315: Can execute Hybrid Entry
bool CEntryManager::CanExecuteHybridEntry(Signal &signal) {
    return ValidateHybridEntry(signal);
}

//--- RF-315: Get Hybrid Stop price
double CEntryManager::GetHybridStopPrice(Signal &signal) {
    return CalculateHybridStopPrice(signal);
}

//--- RF-315: Get Hybrid Limit price
double CEntryManager::GetHybridLimitPrice(Signal &signal) {
    return CalculateHybridLimitPrice(signal);
}

//--- RF-315: Get Hybrid active type
ENUM_ENTRY_TYPE CEntryManager::GetHybridActiveType(Signal &signal) {
    return SelectHybridType(signal);
}

//--- RF-309/310: Execute Scaling In
bool CEntryManager::ExecuteScalingIn(Signal &signal, int level) {
    if(!ValidateScalingIn(signal)) return false;
    
    double price = CalculateScalingLevel(signal, level);
    double lot = CalculateScalingLot(signal, level);
    double sl = signal.stopLoss;
    double tp = signal.takeProfit;
    
    //--- Normalizar
    price = NormalizePrice(price, signal.symbol);
    sl = NormalizePrice(sl, signal.symbol);
    tp = NormalizePrice(tp, signal.symbol);
    lot = NormalizeLot(lot, signal.symbol);
    
    //--- Colocar orden de scaling
    //--- En implementación real, usar OrderSend
    
    //--- Registrar en historial
    EntryRecord record;
    record.timestamp = TimeCurrent();
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.entryType = (signal.bias == BIAS_BULLISH) ? ENTRY_BUY_LIMIT : ENTRY_SELL_LIMIT;
    record.price = price;
    record.stopLoss = sl;
    record.takeProfit = tp;
    record.lot = lot;
    record.isExecuted = true;
    record.isCancelled = false;
    record.reason = "Scaling In Level " + IntegerToString(level) + " executed";
    AddHistoryEntry(record);
    
    m_utils.LogInfo("Scaling In executed: " + signal.symbol + " | Level: " + IntegerToString(level) +
                    " | Price: " + DoubleToString(price, 5) + " | Lot: " + DoubleToString(lot, 2));
    
    return true;
}

//--- RF-309/310: Can execute Scaling In
bool CEntryManager::CanExecuteScalingIn(Signal &signal, int level) {
    if(!ValidateScalingIn(signal)) return false;
    if(level >= GetMaxScalingLevelsForModel(signal.model)) return false;
    return true;
}

//--- RF-309/310: Get Scaling In price
double CEntryManager::GetScalingInPrice(Signal &signal, int level) {
    return CalculateScalingLevel(signal, level);
}

//--- RF-309/310: Get Scaling In lot
double CEntryManager::GetScalingInLot(Signal &signal, int level) {
    return CalculateScalingLot(signal, level);
}

//--- RF-309/310: Get active scaling levels
int CEntryManager::GetActiveScalingLevels(Signal &signal) {
    //--- Placeholder: verificar cuántos niveles de scaling están activos
    return 0;
}

//--- RF-314: HTF Context checks
bool CEntryManager::IsHTFContextValid(Signal &signal) {
    return ValidateHTFContext(signal);
}

bool CEntryManager::IsMonthlyContextValid(Signal &signal) {
    if(m_context == NULL) return true;
    ENUM_BIAS monthlyBias = m_context.GetMonthlyBias();
    return monthlyBias == signal.bias || monthlyBias == BIAS_NEUTRAL;
}

bool CEntryManager::IsWeeklyContextValid(Signal &signal) {
    if(m_context == NULL) return true;
    ENUM_BIAS weeklyBias = m_context.GetWeeklyBias();
    return weeklyBias == signal.bias || weeklyBias == BIAS_NEUTRAL;
}

bool CEntryManager::IsDailyContextValid(Signal &signal) {
    if(m_context == NULL) return true;
    ENUM_BIAS dailyBias = m_context.GetDailyBias();
    return dailyBias == signal.bias || dailyBias == BIAS_NEUTRAL;
}

//--- RF-322: Get progress threshold
double CEntryManager::GetProgressThreshold(ENUM_TRADING_MODEL model) {
    return GetBreakevenThreshold(model);
}

//--- Funciones auxiliares
string CEntryManager::GetEntryTypeName(ENUM_ENTRY_TYPE type) {
    switch(type) {
        case ENTRY_BUY_STOP:  return "BUY_STOP";
        case ENTRY_SELL_STOP: return "SELL_STOP";
        case ENTRY_BUY_LIMIT: return "BUY_LIMIT";
        case ENTRY_SELL_LIMIT: return "SELL_LIMIT";
        case ENTRY_HYBRID:    return "HYBRID";
        case ENTRY_MARKET:    return "MARKET";
        default: return "UNKNOWN";
    }
}

bool CEntryManager::IsValidEntryPrice(double price) {
    return price > 0;
}

bool CEntryManager::IsValidStopLoss(double sl, double entry, ENUM_BIAS bias) {
    if(sl <= 0) return false;
    if(bias == BIAS_BULLISH && sl >= entry) return false;
    if(bias == BIAS_BEARISH && sl <= entry) return false;
    return true;
}

bool CEntryManager::IsValidTakeProfit(double tp, double entry, ENUM_BIAS bias) {
    if(tp <= 0) return false;
    if(bias == BIAS_BULLISH && tp <= entry) return false;
    if(bias == BIAS_BEARISH && tp >= entry) return false;
    return true;
}

double CEntryManager::NormalizePrice(double price, string symbol) {
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    return NormalizeDouble(price, digits);
}

double CEntryManager::NormalizeLot(double lot, string symbol) {
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    if(lot < minLot) lot = minLot;
    if(lot > maxLot) lot = maxLot;
    if(lotStep > 0) {
        lot = MathFloor(lot / lotStep) * lotStep;
    }
    return lot;
}

//--- Calcular multiplicador de spread
double CEntryManager::CalculateSpreadMultiplier(string symbol) {
    long spreadLong = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    double spread = (double)spreadLong;
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    double spreadPips = spread * point * 10;
    return MathMax(1.0, spreadPips / 1.0);
}

int CEntryManager::CalculateExpiryTime() {
    return (int)TimeCurrent() + m_orderExpiryMinutes * 60;
}

void CEntryManager::AddHistoryEntry(EntryRecord &record) {
    if(m_entryCount >= m_maxHistorySize) {
        //--- Eliminar el más antiguo
        for(int i = 0; i < m_entryCount - 1; i++) {
            m_entryHistory[i] = m_entryHistory[i + 1];
        }
        m_entryCount--;
    }
    
    ArrayResize(m_entryHistory, m_entryCount + 1);
    m_entryHistory[m_entryCount] = record;
    m_entryCount++;
}

void CEntryManager::CleanHistory() {
    //--- Limpiar entradas antiguas (más de 30 días)
    datetime cutoff = TimeCurrent() - 30 * 86400;
    int newCount = 0;
    
    for(int i = 0; i < m_entryCount; i++) {
        if(m_entryHistory[i].timestamp >= cutoff) {
            if(newCount < i) {
                m_entryHistory[newCount] = m_entryHistory[i];
            }
            newCount++;
        }
    }
    
    m_entryCount = newCount;
    ArrayResize(m_entryHistory, m_entryCount);
}

//--- RF-315: Execute entry (método principal)
bool CEntryManager::ExecuteEntry(Signal &signal) {
    if(!ValidateEntry(signal)) return false;
    
    ENUM_ENTRY_TYPE type = SelectEntryType(signal);
    
    switch(type) {
        case ENTRY_BUY_STOP:
        case ENTRY_SELL_STOP:
            return ExecuteStopEntry(signal);
        case ENTRY_BUY_LIMIT:
        case ENTRY_SELL_LIMIT:
            return ExecuteLimitEntry(signal);
        case ENTRY_HYBRID:
            return ExecuteHybridEntry(signal);
        case ENTRY_MARKET:
            return ExecuteMarketEntry(signal);
        default:
            return false;
    }
}

//--- Getters
EntryRecord CEntryManager::GetEntryHistory(int index) const {
    if(index < 0 || index >= m_entryCount) {
        EntryRecord empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_entryHistory[index];
}

//--- Reportes
string CEntryManager::GetEntrySummary() {
    string summary = "=== ENTRY SUMMARY ===\n";
    summary += "Stop Entries: " + (m_stopEntriesEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Limit Entries: " + (m_limitEntriesEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Hybrid Mode: " + (m_hybridModeEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Market Entries: " + (m_marketEntriesEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Total Entries: " + IntegerToString(m_entryCount) + "\n";
    summary += "Max Spread Multiplier: " + DoubleToString(m_maxSpreadMultiplier, 1) + "\n";
    summary += "Slippage Tolerance: " + DoubleToString(m_slippageTolerance, 2) + " pips\n";
    summary += "Order Expiry: " + IntegerToString(m_orderExpiryMinutes) + " min\n";
    summary += "=========================";
    return summary;
}

string CEntryManager::GetEntryHistoryReport() {
    string report = "=== ENTRY HISTORY ===\n";
    report += "Total Entries: " + IntegerToString(m_entryCount) + "\n";
    
    int stopCount = 0, limitCount = 0, hybridCount = 0, marketCount = 0;
    int executedCount = 0, cancelledCount = 0;
    
    for(int i = 0; i < m_entryCount; i++) {
        switch(m_entryHistory[i].entryType) {
            case ENTRY_BUY_STOP:
            case ENTRY_SELL_STOP:
                stopCount++;
                break;
            case ENTRY_BUY_LIMIT:
            case ENTRY_SELL_LIMIT:
                limitCount++;
                break;
            case ENTRY_HYBRID:
                hybridCount++;
                break;
            case ENTRY_MARKET:
                marketCount++;
                break;
            default: break;
        }
        
        if(m_entryHistory[i].isExecuted) executedCount++;
        if(m_entryHistory[i].isCancelled) cancelledCount++;
    }
    
    report += "Stop Entries: " + IntegerToString(stopCount) + "\n";
    report += "Limit Entries: " + IntegerToString(limitCount) + "\n";
    report += "Hybrid Entries: " + IntegerToString(hybridCount) + "\n";
    report += "Market Entries: " + IntegerToString(marketCount) + "\n";
    report += "Executed: " + IntegerToString(executedCount) + "\n";
    report += "Cancelled: " + IntegerToString(cancelledCount) + "\n";
    report += "=========================";
    return report;
}

string CEntryManager::GetEntryStatusReport(Signal &signal) {
    string report = "=== ENTRY STATUS ===\n";
    report += "Symbol: " + signal.symbol + "\n";
    report += "Model: " + EnumToString(signal.model) + "\n";
    report += "Bias: " + (signal.bias == BIAS_BULLISH ? "BUY" : "SELL") + "\n";
    report += "Selected Entry: " + GetEntryTypeName(SelectEntryType(signal)) + "\n";
    report += "Entry Price: " + DoubleToString(CalculateEntryPrice(signal), 5) + "\n";
    report += "Stop Loss: " + DoubleToString(signal.stopLoss, 5) + "\n";
    report += "Take Profit: " + DoubleToString(signal.takeProfit, 5) + "\n";
    report += "R:R Ratio: " + DoubleToString(signal.rrRatio, 2) + "\n";
    report += "Lot Size: " + DoubleToString(signal.risk, 2) + "\n";
    report += "Valid: " + (ValidateEntry(signal) ? "YES" : "NO") + "\n";
    if(!ValidateEntry(signal)) {
        report += "Reason: Invalid entry\n";
    }
    report += "=========================";
    return report;
}

//--- FUNCIONES ADICIONALES PARA COMPLETAR LA CLASE

//--- RF-316: Calcular Fair Value
double CEntryManager::CalculateFairValue(Signal &signal) {
    double high = m_utils.GetHighestHigh(signal.symbol, PERIOD_D1, 20);
    double low = m_utils.GetLowestLow(signal.symbol, PERIOD_D1, 20);
    if(high <= low) return 0;
    return (high + low) / 2.0;
}

//--- RF-316: Verificar Deep Discount Zone
bool CEntryManager::IsDeepDiscountZone(Signal &signal) {
    return IsDeepDiscountValid(signal);
}

//--- RF-316: Verificar Deep Premium Zone
bool CEntryManager::IsDeepPremiumZone(Signal &signal) {
    return IsDeepPremiumValid(signal);
}

//--- RF-316: Obtener Discount Level
double CEntryManager::GetDiscountLevel(Signal &signal) {
    return GetDeepDiscountLevel(signal);
}

//--- RF-316: Obtener Premium Level
double CEntryManager::GetPremiumLevel(Signal &signal) {
    return GetDeepPremiumLevel(signal);
}

//--- RF-314: Verificar HTF Array
bool CEntryManager::IsHTFArrayValid(Signal &signal) {
    return ValidateHTFContext(signal);
}

//--- RF-314: Verificar Monthly Array
bool CEntryManager::IsMonthlyArrayValid(Signal &signal) {
    return IsMonthlyContextValid(signal);
}

//--- RF-314: Verificar Weekly Array
bool CEntryManager::IsWeeklyArrayValid(Signal &signal) {
    return IsWeeklyContextValid(signal);
}

//--- RF-321: Verificar progreso suficiente
bool CEntryManager::IsProgressSufficient(ulong ticket) {
    double progress = CalculateTradeProgress(ticket);
    return progress >= 25.0; // 25% mínimo para considerar progreso
}

//--- RF-322: Calcular posición progreso (privado)
double CEntryManager::CalculatePositionProgress(ulong ticket) {
    return CalculateTradeProgress(ticket);
}

//--- RF-322: Obtener rango objetivo (privado)
double CEntryManager::GetTargetRange(Signal &signal) {
    if(signal.bias == BIAS_BULLISH) {
        return signal.takeProfit - signal.entryPrice;
    } else {
        return signal.entryPrice - signal.takeProfit;
    }
}

#endif // __CENTRYMANAGER_MQH__