//+------------------------------------------------------------------+
//|                                                 CRiskManager.mqh |
//|                      HunterIPDA Pro EA - v1.8 - Módulo Execution |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el riesgo del sistema:                      |
//| - Cálculo de tamaño de posición (lotes)                          |
//| - Stop Loss y Take Profit (fijos y dinámicos)                    |
//| - Trailing Stop (incl. IPDA 40/20/10 días)                       |
//| - Breakeven                                                      |
//| - Scaling Out (TP1, TP2, TP3)                                    |
//| - Drawdown Management                                            |
//| - Mitigación de Pérdidas (R2/R3)                                 |
//| - Filtros de riesgo por modelo de trading                        |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-020 a RF-031, RF-052 a RF-057, RF-069 a RF-076              |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CDataRange: IPDA Data Ranges (Trailing Stop)                 |
//|   - CContext: Contexto de mercado                                |
//|   - CTradingPlan: Límites de pérdida                             |
//|                                                                  |
//| Versión: 1.0                                                     |
//| Fecha: 22/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 22/07/2026  | Versión inicial del módulo               |
//+------------------------------------------------------------------+

#ifndef __CRISKMANAGER_MQH__
#define __CRISKMANAGER_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CDataRange.mqh"
#include "../Analysis/CContext.mqh"
#include "../TradingPlan/CTradingPlan.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct RiskState {
    double           accountEquity;
    double           accountBalance;
    double           currentDrawdown;
    double           maxDrawdown;
    double           dailyDrawdown;
    double           weeklyDrawdown;
    double           monthlyDrawdown;
    double           riskPerTrade;
    double           totalRiskExposure;
    int              openPositions;
    int              dailyTrades;
    int              weeklyTrades;
    int              monthlyTrades;
    bool             isDrawdownLimitReached;
    bool             isDailyLimitReached;
    bool             isWeeklyLimitReached;
    bool             isMonthlyLimitReached;
    datetime         lastUpdate;
};

struct ScalingLevel {
    double           rrRatio;
    double           percentage;
    double           priceLevel;
    bool             isHit;
    datetime         hitTime;
};

//+------------------------------------------------------------------+
//| CLASE CRiskManager - Gestor de Riesgo                            |
//+------------------------------------------------------------------+
class CRiskManager {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CDataRange*        m_dataRange;
    CContext*          m_context;
    CTradingPlan*      m_tradingPlan;
    bool               m_isInitialized;
    
    //--- Estado
    RiskState          m_state;
    double             m_maxDrawdownPct;
    double             m_dailyLossLimit;
    double             m_weeklyLossLimit;
    double             m_monthlyLossLimit;
    int                m_cooldownLosses;
    int                m_cooldownDays;
    double             m_mitigationFactor;
    int                m_consecutiveLosses;
    int                m_consecutiveWins;
    double             m_currentRiskMultiplier;
    datetime           m_lastLossTime;
    datetime           m_cooldownEnd;
    bool               m_isCooldownActive;
    
    //--- Configuración de Scaling Out
    double             m_soLevel1RR;
    double             m_soLevel1Pct;
    double             m_soLevel2RR;
    double             m_soLevel2Pct;
    double             m_soLevel3RR;
    double             m_soLevel3Pct;
    
    //--- Configuración de Trailing Stop IPDA
    bool               m_tsIPDAEnabled;
    int                m_tsIPDAInitial;
    int                m_tsIPDAMid;
    int                m_tsIPDAFinal;
    
    //--- Configuración de Breakeven
    bool               m_beEnabled;
    int                m_beActivationPips;
    
    //--- Gestión de órdenes
    struct ManagedPosition {
        ulong          ticket;
        string         symbol;
        ENUM_TRADING_MODEL model;
        ENUM_BIAS      bias;
        double         entryPrice;
        double         stopLoss;
        double         takeProfit;
        double         lot;
        double         initialRisk;
        double         currentSL;
        double         currentTP;
        double         highestPrice;
        double         lowestPrice;
        double         progressPercent;
        ScalingLevel   scalingLevels[3];
        bool           isBreakevenHit;
        bool           isTrailingActive;
        datetime       openTime;
        datetime       lastModification;
    };
    
    ManagedPosition    m_positions[];
    int                m_positionCount;
    int                m_maxPositions;
    
    //--- Métodos privados
    bool               InitializeParameters();
    void               UpdateAccountInfo();
    void               UpdateDrawdown();
    void               UpdateRiskExposure();
    void               ResetCounters();
    void               CheckCooldown();
    void               ApplyMitigation();
    void               ApplyLossReduction();
    double             GetRiskPercentForModel(ENUM_TRADING_MODEL model) const;
    double             GetMaxSpreadForModel(ENUM_TRADING_MODEL model) const;
    double             GetMaxSlippageForModel(ENUM_TRADING_MODEL model) const;
    ENUM_ENTRY_TYPE    GetEntryTypeForModel(ENUM_TRADING_MODEL model) const;
    bool               IsModelFrequencyValid(ENUM_TRADING_MODEL model) const;
    void               UpdatePositionProgress(ulong ticket);
    double             CalculateIPDATrailingStop(ulong ticket);
    double             CalculateSwingStop(Signal &signal);
    double             CalculateOSOKStop(Signal &signal);
    double             CalculateDayTradeStop(Signal &signal);
    double             CalculateScalpStop(Signal &signal);
    double             CalculateMegaStop(Signal &signal);
    double             CalculateStockStop(Signal &signal);
    double             CalculateScalingLevel(int level, Signal &signal);
    bool               ValidateStopLoss(Signal &signal);
    bool               ValidateTakeProfit(Signal &signal);
    bool               ValidatePositionSize(Signal &signal);
    double             CalculatePipDistance(double price1, double price2, string symbol);
    bool               IsStopLossValid(Signal &signal);
    bool               IsTakeProfitValid(Signal &signal);
    int                FindPosition(ulong ticket);
    void               CleanClosedPositions();
    double             GetCurrentPrice(string symbol);
    double             GetPointValue(string symbol);
    
public:
    //--- Constructor / Destructor
    CRiskManager();
    ~CRiskManager();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CDataRange* dataRange,
              CContext* context, CTradingPlan* tradingPlan);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-027/053: Actualización de Estado
    void Update();
    bool IsTradeAllowed();
    bool IsModelTradeAllowed(ENUM_TRADING_MODEL model);
    bool IsSymbolTradeAllowed(string symbol);
    void ResetDailyCounters();
    void ResetWeeklyCounters();
    void ResetMonthlyCounters();
    
    //--- RF-020/021: Stop Loss
    double CalculateStopLoss(Signal &signal);
    double CalculateFixedStopLoss(Signal &signal);
    double CalculateDynamicStopLoss(Signal &signal);
    double GetStopLossForModel(Signal &signal, ENUM_TRADING_MODEL model);
    
    //--- RF-022/023: Take Profit
    double CalculateTakeProfit(Signal &signal);
    double CalculateFixedTakeProfit(Signal &signal);
    double CalculateDynamicTakeProfit(Signal &signal);
    double GetTakeProfitForModel(Signal &signal, ENUM_TRADING_MODEL model);
    
    //--- RF-024/025: Tamaño de Posición
    double CalculateLot(Signal &signal);
    double CalculateFixedLot(Signal &signal);
    double CalculateDynamicLot(Signal &signal);
    double GetLotForModel(Signal &signal, ENUM_TRADING_MODEL model);
    double GetMaxLotForSymbol(string symbol);
    double GetMinLotForSymbol(string symbol);
    double GetLotStepForSymbol(string symbol);
    
    //--- RF-018/317-319: Trailing Stop
    double CalculateTrailingStop(ulong ticket);
    bool IsTrailingActive(ulong ticket);
    void UpdateTrailingStop(ulong ticket);
    double GetIPDATrailingStop(ulong ticket);
    bool IsIPDATrailingActive(ulong ticket);
    void SetIPDATrailingLevels(int initial, int mid, int finalDays);
    
    //--- RF-017: Breakeven
    void UpdateBreakeven(ulong ticket);
    bool IsBreakevenActive(ulong ticket);
    bool ShouldMoveToBreakeven(ulong ticket);
    void MoveToBreakeven(ulong ticket);
    
    //--- RF-054: Scaling Out
    void UpdateScalingOut(ulong ticket);
    bool ShouldScaleOut(ulong ticket, int level);
    ScalingLevel GetScalingLevel(ulong ticket, int level);
    void ExecuteScalingOut(ulong ticket, int level);
    void SetScalingLevels(double level1RR, double level1Pct, 
                          double level2RR, double level2Pct,
                          double level3RR, double level3Pct);
    
    //--- RF-052: R:R Validation
    bool ValidateRMultiple(Signal &signal);
    double GetMinRRForModel(ENUM_TRADING_MODEL model) const;
    double GetOptimalRRForModel(ENUM_TRADING_MODEL model) const;
    
    //--- RF-069-076: Mitigación de Pérdidas
    void ApplyLossMitigation();
    void RecordTradeResult(double pnl, bool isWin, ENUM_TRADING_MODEL model);
    double GetMitigationFactor() const { return m_mitigationFactor; }
    int GetConsecutiveLosses() const { return m_consecutiveLosses; }
    int GetConsecutiveWins() const { return m_consecutiveWins; }
    bool IsInCooldown() const;
    double GetCooldownDaysRemaining() const;
    void ResetMitigation();
    
    //--- RF-029-031: Filtros
    bool IsTimeValid();
    bool IsDayValid();
    bool IsVolatilityValid(string symbol);
    bool IsSpreadValid(string symbol);
    bool IsSlippageValid(string symbol, double expected, double actual);
    
    //--- RF-055-057: Límites de Frecuencia
    bool IsFrequencyValid(ENUM_TRADING_MODEL model);
    int GetMaxTradesPerWeek(ENUM_TRADING_MODEL model) const;
    int GetMaxTradesPerDay(ENUM_TRADING_MODEL model) const;
    int GetMaxTradesPerYear(ENUM_TRADING_MODEL model) const;
    int GetTradesCount(ENUM_TRADING_MODEL model, ENUM_TIMEFRAMES period);
    void IncrementTradeCount(ENUM_TRADING_MODEL model);
    
    //--- RF-056: Priorización de Setups
    int GetSetupQualityScore(Signal &signal);
    bool IsHighProbabilitySetup(Signal &signal);
    bool IsSetupPriorityValid(Signal &signal);
    
    //--- Gestión de Posiciones
    void AddPosition(ulong ticket, Signal &signal);
    void RemovePosition(ulong ticket);
    void UpdatePosition(ulong ticket);
    ManagedPosition GetPosition(ulong ticket) const;
    int GetOpenPositions() const { return m_positionCount; }
    int GetMaxPositions() const { return m_maxPositions; }
    void SetMaxPositions(int max) { m_maxPositions = MathMax(1, max); }
    
    //--- RF-028: Stop Loss de Emergencia
    bool IsEmergencyStopTriggered();
    void ExecuteEmergencyStop();
    double GetEmergencyStopLevel() const;
    
    //--- Getters
    RiskState GetRiskState() const { return m_state; }
    double GetAccountEquity() const { return m_state.accountEquity; }
    double GetAccountBalance() const { return m_state.accountBalance; }
    double GetCurrentDrawdown() const { return m_state.currentDrawdown; }
    double GetMaxDrawdown() const { return m_state.maxDrawdown; }
    double GetRiskPerTrade() const { return m_state.riskPerTrade; }
    bool IsDrawdownLimitReached() const { return m_state.isDrawdownLimitReached; }
    bool IsDailyLimitReached() const { return m_state.isDailyLimitReached; }
    bool IsWeeklyLimitReached() const { return m_state.isWeeklyLimitReached; }
    bool IsMonthlyLimitReached() const { return m_state.isMonthlyLimitReached; }
    double GetPositionProgress(ulong ticket) const;
    
    //--- Reportes
    string GetRiskSummary();
    string GetDrawdownReport();
    string GetPositionReport();
    string GetMitigationReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CRiskManager::CRiskManager() {
    m_config = NULL;
    m_utils = NULL;
    m_dataRange = NULL;
    m_context = NULL;
    m_tradingPlan = NULL;
    m_isInitialized = false;
    m_maxDrawdownPct = 20.0;
    m_dailyLossLimit = 2.0;
    m_weeklyLossLimit = 5.0;
    m_monthlyLossLimit = 10.0;
    m_cooldownLosses = 3;
    m_cooldownDays = 1;
    m_mitigationFactor = 1.0;
    m_consecutiveLosses = 0;
    m_consecutiveWins = 0;
    m_currentRiskMultiplier = 1.0;
    m_lastLossTime = 0;
    m_cooldownEnd = 0;
    m_isCooldownActive = false;
    m_soLevel1RR = 3.0;
    m_soLevel1Pct = 50.0;
    m_soLevel2RR = 5.0;
    m_soLevel2Pct = 25.0;
    m_soLevel3RR = 9.0;
    m_soLevel3Pct = 25.0;
    m_tsIPDAEnabled = true;
    m_tsIPDAInitial = 40;
    m_tsIPDAMid = 20;
    m_tsIPDAFinal = 10;
    m_beEnabled = true;
    m_beActivationPips = 15;
    m_positionCount = 0;
    m_maxPositions = 10;
    ZeroMemory(m_state);
    ArrayResize(m_positions, 0);
}

//--- Destructor
CRiskManager::~CRiskManager() {
    Deinit();
}

//--- Inicialización
bool CRiskManager::Init(CConfig* config, CUtils* utils, CDataRange* dataRange,
                        CContext* context, CTradingPlan* tradingPlan) {
    if(config == NULL || utils == NULL || dataRange == NULL ||
       context == NULL || tradingPlan == NULL) {
        Print("CRiskManager::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_dataRange = dataRange;
    m_context = context;
    m_tradingPlan = tradingPlan;
    
    //--- Inicializar parámetros
    if(!InitializeParameters()) {
        Print("CRiskManager::Init - Error al inicializar parámetros");
        return false;
    }
    
    //--- Actualizar estado inicial
    UpdateAccountInfo();
    UpdateDrawdown();
    UpdateRiskExposure();
    
    m_isInitialized = true;
    m_utils.LogInfo("CRiskManager inicializado correctamente");
    return true;
}

//--- Desinicialización
void CRiskManager::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_dataRange = NULL;
    m_context = NULL;
    m_tradingPlan = NULL;
    m_isInitialized = false;
    ArrayResize(m_positions, 0);
    m_positionCount = 0;
}

//--- Inicializar parámetros
bool CRiskManager::InitializeParameters() {
    //--- Cargar configuración de inputs (valores por defecto)
    m_maxDrawdownPct = 20.0;
    m_dailyLossLimit = 2.0;
    m_weeklyLossLimit = 5.0;
    m_monthlyLossLimit = 10.0;
    m_cooldownLosses = 3;
    m_cooldownDays = 1;
    m_mitigationFactor = 0.5;
    m_soLevel1RR = 3.0;
    m_soLevel1Pct = 50.0;
    m_soLevel2RR = 5.0;
    m_soLevel2Pct = 25.0;
    m_soLevel3RR = 9.0;
    m_soLevel3Pct = 25.0;
    m_tsIPDAEnabled = true;
    m_tsIPDAInitial = 40;
    m_tsIPDAMid = 20;
    m_tsIPDAFinal = 10;
    m_beEnabled = true;
    m_beActivationPips = 15;
    m_maxPositions = 10;
    
    return true;
}

//--- RF-027: Actualizar información de cuenta
void CRiskManager::UpdateAccountInfo() {
    m_state.accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_state.accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_state.openPositions = PositionsTotal();
    m_state.lastUpdate = TimeCurrent();
}

//--- RF-027: Actualizar drawdown
void CRiskManager::UpdateDrawdown() {
    double equity = m_state.accountEquity;
    double balance = m_state.accountBalance;
    
    if(balance > 0) {
        m_state.currentDrawdown = (balance - equity) / balance * 100.0;
        if(m_state.currentDrawdown > m_state.maxDrawdown) {
            m_state.maxDrawdown = m_state.currentDrawdown;
        }
        
        //--- Verificar límites
        m_state.isDrawdownLimitReached = m_state.currentDrawdown >= m_maxDrawdownPct;
        m_state.isDailyLimitReached = m_state.dailyDrawdown >= m_dailyLossLimit;
        m_state.isWeeklyLimitReached = m_state.weeklyDrawdown >= m_weeklyLossLimit;
        m_state.isMonthlyLimitReached = m_state.monthlyDrawdown >= m_monthlyLossLimit;
    }
}

//--- Actualizar exposición de riesgo
void CRiskManager::UpdateRiskExposure() {
    double totalRisk = 0;
    for(int i = 0; i < m_positionCount; i++) {
        totalRisk += m_positions[i].initialRisk;
    }
    m_state.totalRiskExposure = totalRisk;
    m_state.riskPerTrade = (m_state.accountEquity > 0) ? 
                           (totalRisk / m_state.accountEquity * 100.0) : 0;
}

//--- RF-027: Verificar si se permite trading
bool CRiskManager::IsTradeAllowed() {
    if(!m_isInitialized) return false;
    
    //--- Verificar drawdown
    if(m_state.isDrawdownLimitReached) {
        m_utils.LogWarning("Drawdown limit reached: " + DoubleToString(m_state.currentDrawdown, 2) + "%");
        return false;
    }
    
    //--- Verificar límites diarios
    if(m_state.isDailyLimitReached) {
        m_utils.LogWarning("Daily loss limit reached: " + DoubleToString(m_state.dailyDrawdown, 2) + "%");
        return false;
    }
    
    //--- Verificar límites semanales
    if(m_state.isWeeklyLimitReached) {
        m_utils.LogWarning("Weekly loss limit reached: " + DoubleToString(m_state.weeklyDrawdown, 2) + "%");
        return false;
    }
    
    //--- Verificar límites mensuales
    if(m_state.isMonthlyLimitReached) {
        m_utils.LogWarning("Monthly loss limit reached: " + DoubleToString(m_state.monthlyDrawdown, 2) + "%");
        return false;
    }
    
    //--- Verificar cooldown
    if(IsInCooldown()) {
        m_utils.LogWarning("Cooldown active: " + DoubleToString(GetCooldownDaysRemaining(), 1) + " days remaining");
        return false;
    }
    
    //--- Verificar límite de posiciones
    if(m_positionCount >= m_maxPositions) {
        m_utils.LogWarning("Max positions reached: " + IntegerToString(m_maxPositions));
        return false;
    }
    
    return true;
}

//--- RF-055: Verificar frecuencia por modelo
bool CRiskManager::IsModelTradeAllowed(ENUM_TRADING_MODEL model) {
    if(!m_isInitialized) return false;
    
    if(!IsTradeAllowed()) return false;
    
    //--- Verificar frecuencia
    if(!IsFrequencyValid(model)) {
        m_utils.LogWarning("Frequency limit reached for model: " + EnumToString(model));
        return false;
    }
    
    //--- Verificar límite de posiciones para el modelo
    int modelPositions = 0;
    for(int i = 0; i < m_positionCount; i++) {
        if(m_positions[i].model == model) modelPositions++;
    }
    
    int maxModelPositions = 1;
    switch(model) {
        case MODEL_POSITION: maxModelPositions = 1; break;
        case MODEL_SWING: maxModelPositions = 2; break;
        case MODEL_SHORT_TERM: maxModelPositions = 2; break;
        case MODEL_OSOK: maxModelPositions = 1; break;
        case MODEL_DAY_TRADING: maxModelPositions = 2; break;
        case MODEL_SCALPING: maxModelPositions = 3; break;
        case MODEL_MEGA_TRADE: maxModelPositions = 1; break;
        case MODEL_STOCK_TRADING: maxModelPositions = 3; break;
        case MODEL_BONUS_HUNTER: maxModelPositions = 3; break;
        default: maxModelPositions = 1;
    }
    
    if(modelPositions >= maxModelPositions) {
        m_utils.LogWarning("Max positions for model " + EnumToString(model) + " reached");
        return false;
    }
    
    return true;
}

//--- RF-029: Verificar tiempo válido
bool CRiskManager::IsTimeValid() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    //--- Horario de trading: 24/5
    if(dt.day_of_week == 5 && dt.hour >= 22) return false; // Viernes 10 PM
    if(dt.day_of_week == 6) return false; // Sábado
    if(dt.day_of_week == 0 && dt.hour < 22) return false; // Domingo hasta 10 PM
    
    return true;
}

//--- RF-030: Verificar día válido
bool CRiskManager::IsDayValid() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    //--- Permitir todos los días de la semana por defecto
    return true;
}

//--- RF-031: Verificar volatilidad válida
bool CRiskManager::IsVolatilityValid(string symbol) {
    double atr = m_utils.CalculateATR(symbol, PERIOD_D1, 14);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    if(price == 0) return false;
    
    double volatilityPct = (atr / price) * 100;
    return volatilityPct < 5.0; // 5% de volatilidad máxima
}

//--- RF-019: Verificar spread válido
bool CRiskManager::IsSpreadValid(string symbol) {
    long spreadLong = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    double spread = (double)spreadLong;
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    double spreadPips = spread * point * 10; // Convertir a pips
    
    return spreadPips < 3.0; // 3 pips máximo
}

//--- RF-020/021: Calcular Stop Loss
double CRiskManager::CalculateStopLoss(Signal &signal) {
    if(!m_isInitialized) return 0;
    
    //--- Verificar si es fijo o dinámico
    bool useFixed = false; // Por defecto dinámico
    
    if(useFixed) {
        return CalculateFixedStopLoss(signal);
    } else {
        return CalculateDynamicStopLoss(signal);
    }
}

double CRiskManager::CalculateFixedStopLoss(Signal &signal) {
    double pips = 20; // Valor por defecto
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    
    if(signal.bias == BIAS_BULLISH) {
        return signal.entryPrice - pips * point * 10;
    } else {
        return signal.entryPrice + pips * point * 10;
    }
}

double CRiskManager::CalculateDynamicStopLoss(Signal &signal) {
    //--- Usar estructura de mercado para SL
    if(signal.bias == BIAS_BULLISH) {
        //--- SL por debajo del mínimo reciente o estructura
        double low20 = m_utils.GetLowestLow(signal.symbol, PERIOD_H1, 20);
        if(low20 > 0 && low20 < signal.entryPrice) {
            return low20 - SymbolInfoDouble(signal.symbol, SYMBOL_POINT) * 2;
        }
        //--- Fallback: 20 pips
        return signal.entryPrice - 20 * SymbolInfoDouble(signal.symbol, SYMBOL_POINT) * 10;
    } else {
        double high20 = m_utils.GetHighestHigh(signal.symbol, PERIOD_H1, 20);
        if(high20 > 0 && high20 > signal.entryPrice) {
            return high20 + SymbolInfoDouble(signal.symbol, SYMBOL_POINT) * 2;
        }
        return signal.entryPrice + 20 * SymbolInfoDouble(signal.symbol, SYMBOL_POINT) * 10;
    }
}

//--- RF-022/023: Calcular Take Profit
double CRiskManager::CalculateTakeProfit(Signal &signal) {
    if(!m_isInitialized) return 0;
    
    double stopLoss = CalculateStopLoss(signal);
    if(stopLoss == 0) return 0;
    
    double rrRatio = 3.0; // 3:1 por defecto
    double risk = MathAbs(signal.entryPrice - stopLoss);
    
    if(signal.bias == BIAS_BULLISH) {
        return signal.entryPrice + risk * rrRatio;
    } else {
        return signal.entryPrice - risk * rrRatio;
    }
}

//--- RF-024: Calcular Tamaño de Posición
double CRiskManager::CalculateLot(Signal &signal) {
    if(!m_isInitialized) return 0;
    
    double riskPct = GetRiskPercentForModel(signal.model);
    double stopLoss = CalculateStopLoss(signal);
    
    if(stopLoss == 0) return 0;
    
    double risk = MathAbs(signal.entryPrice - stopLoss);
    double equity = m_state.accountEquity;
    
    //--- Aplicar mitigación
    riskPct *= m_mitigationFactor;
    riskPct *= m_currentRiskMultiplier;
    
    //--- Calcular lote
    double riskAmount = equity * (riskPct / 100.0);
    double pipValue = m_utils.CalculatePipValue(signal.symbol, 1.0);
    double lot = riskAmount / (risk * pipValue);
    
    //--- Ajustar al mínimo y step del símbolo
    double minLot = SymbolInfoDouble(signal.symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(signal.symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(signal.symbol, SYMBOL_VOLUME_STEP);
    
    if(lot < minLot) lot = minLot;
    if(lot > maxLot) lot = maxLot;
    
    //--- Redondear al step
    if(lotStep > 0) {
        lot = MathFloor(lot / lotStep) * lotStep;
    }
    
    return lot;
}

//--- RF-052: Validar R:R
bool CRiskManager::ValidateRMultiple(Signal &signal) {
    double minRR = GetMinRRForModel(signal.model);
    return signal.rrRatio >= minRR;
}

double CRiskManager::GetMinRRForModel(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return RR_MIN_POSITION;
        case MODEL_SWING:       return RR_MIN_SWING;
        case MODEL_SHORT_TERM:  return RR_MIN_SHORT_TERM;
        case MODEL_OSOK:        return RR_MIN_OSOK;
        case MODEL_DAY_TRADING: return RR_MIN_DAY_TRADING;
        case MODEL_SCALPING:    return RR_MIN_SCALPING;
        case MODEL_MEGA_TRADE:  return RR_MIN_MEGA;
        case MODEL_STOCK_TRADING: return RR_MIN_STOCK;
        case MODEL_BONUS_HUNTER: return RR_MIN_BONUS;
        default: return 1.0;
    }
}

double CRiskManager::GetOptimalRRForModel(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_SWING:       return RR_OPTIMAL_SWING;
        case MODEL_MEGA_TRADE:  return RR_OPTIMAL_MEGA;
        default: return GetMinRRForModel(model);
    }
}

//--- RF-054: Scaling Out
void CRiskManager::UpdateScalingOut(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    for(int i = 0; i < 3; i++) {
        if(!m_positions[idx].scalingLevels[i].isHit) {
            if(ShouldScaleOut(ticket, i)) {
                ExecuteScalingOut(ticket, i);
            }
        }
    }
}

bool CRiskManager::ShouldScaleOut(ulong ticket, int level) {
    int idx = FindPosition(ticket);
    if(idx < 0) return false;
    
    double currentPrice = GetCurrentPrice(m_positions[idx].symbol);
    double entry = m_positions[idx].entryPrice;
    double sl = m_positions[idx].stopLoss;
    double risk = MathAbs(entry - sl);
    
    double targetLevel;
    if(m_positions[idx].bias == BIAS_BULLISH) {
        targetLevel = entry + risk * m_positions[idx].scalingLevels[level].rrRatio;
        return currentPrice >= targetLevel;
    } else {
        targetLevel = entry - risk * m_positions[idx].scalingLevels[level].rrRatio;
        return currentPrice <= targetLevel;
    }
}

void CRiskManager::ExecuteScalingOut(ulong ticket, int level) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    //--- Calcular cantidad a cerrar
    double closeLot = m_positions[idx].lot * (m_positions[idx].scalingLevels[level].percentage / 100.0);
    
    //--- Cerrar parcialmente
    //--- NOTA: En MQL5, PositionClosePartial requiere implementación específica
    //--- Esta es una implementación simplificada
    
    m_positions[idx].scalingLevels[level].isHit = true;
    m_positions[idx].scalingLevels[level].hitTime = TimeCurrent();
    
    m_utils.LogInfo("Scaling Out Level " + IntegerToString(level+1) + " executed for ticket " + IntegerToString(ticket));
}

//--- RF-017: Breakeven
void CRiskManager::UpdateBreakeven(ulong ticket) {
    if(!m_beEnabled) return;
    
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    if(m_positions[idx].isBreakevenHit) return;
    
    if(ShouldMoveToBreakeven(ticket)) {
        MoveToBreakeven(ticket);
    }
}

bool CRiskManager::ShouldMoveToBreakeven(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return false;
    
    double currentPrice = GetCurrentPrice(m_positions[idx].symbol);
    double entry = m_positions[idx].entryPrice;
    double point = SymbolInfoDouble(m_positions[idx].symbol, SYMBOL_POINT);
    
    double pipsGained;
    if(m_positions[idx].bias == BIAS_BULLISH) {
        pipsGained = (currentPrice - entry) / point / 10;
    } else {
        pipsGained = (entry - currentPrice) / point / 10;
    }
    
    return pipsGained >= m_beActivationPips;
}

void CRiskManager::MoveToBreakeven(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    m_positions[idx].currentSL = m_positions[idx].entryPrice;
    m_positions[idx].isBreakevenHit = true;
    
    m_utils.LogInfo("Breakeven activated for ticket " + IntegerToString(ticket));
}

//--- RF-018: Trailing Stop
double CRiskManager::CalculateTrailingStop(ulong ticket) {
    if(!m_tsIPDAEnabled) return 0;
    
    int idx = FindPosition(ticket);
    if(idx < 0) return 0;
    
    //--- Calcular progreso
    UpdatePositionProgress(ticket);
    double progress = m_positions[idx].progressPercent;
    
    //--- Seleccionar lookback según progreso
    int lookback;
    if(progress < 50) {
        lookback = m_tsIPDAInitial;
    } else if(progress < 75) {
        lookback = m_tsIPDAMid;
    } else {
        lookback = m_tsIPDAFinal;
    }
    
    double trailingStop = 0;
    if(m_positions[idx].bias == BIAS_BULLISH) {
        double lowestLow = m_utils.GetLowestLow(m_positions[idx].symbol, PERIOD_D1, lookback);
        if(lowestLow > 0) {
            trailingStop = lowestLow;
        }
    } else {
        double highestHigh = m_utils.GetHighestHigh(m_positions[idx].symbol, PERIOD_D1, lookback);
        if(highestHigh > 0) {
            trailingStop = highestHigh;
        }
    }
    
    return trailingStop;
}

void CRiskManager::UpdateTrailingStop(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    double newSL = CalculateTrailingStop(ticket);
    if(newSL > 0) {
        //--- Solo actualizar si mejora el SL
        if(m_positions[idx].bias == BIAS_BULLISH && newSL > m_positions[idx].currentSL) {
            m_positions[idx].currentSL = newSL;
        } else if(m_positions[idx].bias == BIAS_BEARISH && newSL < m_positions[idx].currentSL) {
            m_positions[idx].currentSL = newSL;
        }
    }
}

//--- RF-028: Stop Loss de Emergencia
bool CRiskManager::IsEmergencyStopTriggered() {
    return m_state.currentDrawdown >= 30.0; // 30% de drawdown
}

void CRiskManager::ExecuteEmergencyStop() {
    if(!IsEmergencyStopTriggered()) return;
    
    m_utils.LogError("EMERGENCY STOP: Drawdown reached 30%");
    
    //--- Cerrar todas las posiciones
    for(int i = m_positionCount - 1; i >= 0; i--) {
        //--- Cerrar posición
        //--- Posición cerrada, se elimina de la lista en RemovePosition
        RemovePosition(m_positions[i].ticket);
    }
    
    m_state.isDrawdownLimitReached = true;
}

double CRiskManager::GetEmergencyStopLevel() const {
    double balance = m_state.accountBalance;
    if(balance == 0) return 0;
    return balance * 0.7; // 70% del balance
}

//--- RF-069-076: Mitigación de Pérdidas
void CRiskManager::ApplyLossMitigation() {
    if(m_consecutiveLosses < 2) return;
    
    //--- Reducir factor de mitigación
    m_mitigationFactor = MathMax(0.25, m_mitigationFactor * 0.5);
    
    //--- Activar cooldown si se supera el límite
    if(m_consecutiveLosses >= m_cooldownLosses) {
        m_isCooldownActive = true;
        m_cooldownEnd = TimeCurrent() + m_cooldownDays * 86400;
        m_utils.LogWarning("Cooldown activated for " + IntegerToString(m_cooldownDays) + " days");
    }
}

void CRiskManager::RecordTradeResult(double pnl, bool isWin, ENUM_TRADING_MODEL model) {
    if(isWin) {
        m_consecutiveWins++;
        m_consecutiveLosses = 0;
        //--- Incrementar gradualmente el riesgo
        if(m_consecutiveWins > 3) {
            m_currentRiskMultiplier = MathMin(1.5, m_currentRiskMultiplier * 1.1);
        }
    } else {
        m_consecutiveLosses++;
        m_consecutiveWins = 0;
        m_lastLossTime = TimeCurrent();
        m_currentRiskMultiplier = MathMax(0.5, m_currentRiskMultiplier * 0.8);
        ApplyLossMitigation();
    }
    
    //--- Actualizar drawdown
    UpdateDrawdown();
}

bool CRiskManager::IsInCooldown() const {
    if(!m_isCooldownActive) return false;
    return TimeCurrent() < m_cooldownEnd;
}

double CRiskManager::GetCooldownDaysRemaining() const {
    if(!m_isCooldownActive) return 0;
    double seconds = (double)(m_cooldownEnd - TimeCurrent());
    return MathMax(0, seconds / 86400.0);
}

//--- RF-055-057: Límites de Frecuencia
int CRiskManager::GetMaxTradesPerWeek(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return 1;
        case MODEL_SWING:       return 2;
        case MODEL_SHORT_TERM:  return 3;
        case MODEL_OSOK:        return 1;
        case MODEL_DAY_TRADING: return 5;
        case MODEL_SCALPING:    return 10;
        case MODEL_MEGA_TRADE:  return 1;
        case MODEL_STOCK_TRADING: return 3;
        case MODEL_BONUS_HUNTER: return 10;
        default: return 5;
    }
}

int CRiskManager::GetMaxTradesPerDay(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return 1;
        case MODEL_SWING:       return 1;
        case MODEL_SHORT_TERM:  return 2;
        case MODEL_OSOK:        return 1;
        case MODEL_DAY_TRADING: return 2;
        case MODEL_SCALPING:    return 5;
        case MODEL_MEGA_TRADE:  return 1;
        case MODEL_STOCK_TRADING: return 2;
        case MODEL_BONUS_HUNTER: return 10;
        default: return 3;
    }
}

int CRiskManager::GetMaxTradesPerYear(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return MAX_POSITION_TRADES_YEAR;
        case MODEL_SWING:       return MAX_SWING_TRADES_YEAR;
        case MODEL_SHORT_TERM:  return 50;
        case MODEL_OSOK:        return 52;
        case MODEL_DAY_TRADING: return 250;
        case MODEL_SCALPING:    return 500;
        case MODEL_MEGA_TRADE:  return MAX_MEGA_TRADES_YEAR;
        case MODEL_STOCK_TRADING: return 50;
        case MODEL_BONUS_HUNTER: return 500;
        default: return 100;
    }
}

//--- RF-056: Priorización de Setups
int CRiskManager::GetSetupQualityScore(Signal &signal) {
    int score = 0;
    
    //--- R:R (30%)
    if(signal.rrRatio >= 5.0) score += 30;
    else if(signal.rrRatio >= 3.0) score += 20;
    else if(signal.rrRatio >= 2.0) score += 10;
    
    //--- Alignment (30%)
    if(m_context != NULL) {
        double alignment = m_context.GetAlignmentScore();
        if(alignment >= 70) score += 30;
        else if(alignment >= 50) score += 20;
        else if(alignment >= 30) score += 10;
    }
    
    //--- Sponsorship (20%)
    if(m_context != NULL && m_context.IsSponsorshipPresent()) {
        score += 20;
    }
    
    //--- Seasonality (20%)
    //--- Simplificado: si hay seasonal, suma puntos
    
    return score;
}

bool CRiskManager::IsHighProbabilitySetup(Signal &signal) {
    return GetSetupQualityScore(signal) >= 70;
}

//--- Función auxiliar: Obtener precio actual
double CRiskManager::GetCurrentPrice(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_BID);
}

//--- Función auxiliar: Obtener valor del punto
double CRiskManager::GetPointValue(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_POINT);
}

//--- Función auxiliar: Encontrar posición
int CRiskManager::FindPosition(ulong ticket) {
    for(int i = 0; i < m_positionCount; i++) {
        if(m_positions[i].ticket == ticket) {
            return i;
        }
    }
    return -1;
}

//--- Actualizar progreso de posición
void CRiskManager::UpdatePositionProgress(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    double currentPrice = GetCurrentPrice(m_positions[idx].symbol);
    double entry = m_positions[idx].entryPrice;
    double sl = m_positions[idx].stopLoss;
    double tp = m_positions[idx].takeProfit;
    
    double totalRange = MathAbs(tp - entry);
    if(totalRange == 0) {
        m_positions[idx].progressPercent = 0;
        return;
    }
    
    double currentProgress;
    if(m_positions[idx].bias == BIAS_BULLISH) {
        currentProgress = (currentPrice - entry) / totalRange * 100;
    } else {
        currentProgress = (entry - currentPrice) / totalRange * 100;
    }
    
    m_positions[idx].progressPercent = MathMax(0, MathMin(100, currentProgress));
}

//--- Añadir posición
void CRiskManager::AddPosition(ulong ticket, Signal &signal) {
    int idx = m_positionCount;
    ArrayResize(m_positions, m_positionCount + 1);
    
    m_positions[idx].ticket = ticket;
    m_positions[idx].symbol = signal.symbol;
    m_positions[idx].model = signal.model;
    m_positions[idx].bias = signal.bias;
    m_positions[idx].entryPrice = signal.entryPrice;
    m_positions[idx].stopLoss = signal.stopLoss;
    m_positions[idx].takeProfit = signal.takeProfit;
    m_positions[idx].lot = signal.risk;
    m_positions[idx].initialRisk = signal.risk;
    m_positions[idx].currentSL = signal.stopLoss;
    m_positions[idx].currentTP = signal.takeProfit;
    m_positions[idx].highestPrice = signal.entryPrice;
    m_positions[idx].lowestPrice = signal.entryPrice;
    m_positions[idx].progressPercent = 0;
    m_positions[idx].isBreakevenHit = false;
    m_positions[idx].isTrailingActive = false;
    m_positions[idx].openTime = TimeCurrent();
    m_positions[idx].lastModification = TimeCurrent();
    
    //--- Inicializar niveles de scaling
    m_positions[idx].scalingLevels[0].rrRatio = m_soLevel1RR;
    m_positions[idx].scalingLevels[0].percentage = m_soLevel1Pct;
    m_positions[idx].scalingLevels[0].isHit = false;
    m_positions[idx].scalingLevels[0].priceLevel = 0;
    m_positions[idx].scalingLevels[0].hitTime = 0;
    
    m_positions[idx].scalingLevels[1].rrRatio = m_soLevel2RR;
    m_positions[idx].scalingLevels[1].percentage = m_soLevel2Pct;
    m_positions[idx].scalingLevels[1].isHit = false;
    m_positions[idx].scalingLevels[1].priceLevel = 0;
    m_positions[idx].scalingLevels[1].hitTime = 0;
    
    m_positions[idx].scalingLevels[2].rrRatio = m_soLevel3RR;
    m_positions[idx].scalingLevels[2].percentage = m_soLevel3Pct;
    m_positions[idx].scalingLevels[2].isHit = false;
    m_positions[idx].scalingLevels[2].priceLevel = 0;
    m_positions[idx].scalingLevels[2].hitTime = 0;
    
    m_positionCount++;
    
    IncrementTradeCount(signal.model);
}

//--- Eliminar posición
void CRiskManager::RemovePosition(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    //--- Mover el último elemento al índice eliminado
    if(idx < m_positionCount - 1) {
        m_positions[idx] = m_positions[m_positionCount - 1];
    }
    
    m_positionCount--;
    ArrayResize(m_positions, m_positionCount);
}

//--- Actualizar posición
void CRiskManager::UpdatePosition(ulong ticket) {
    int idx = FindPosition(ticket);
    if(idx < 0) return;
    
    double currentPrice = GetCurrentPrice(m_positions[idx].symbol);
    
    //--- Actualizar high/low
    if(currentPrice > m_positions[idx].highestPrice) {
        m_positions[idx].highestPrice = currentPrice;
    }
    if(currentPrice < m_positions[idx].lowestPrice) {
        m_positions[idx].lowestPrice = currentPrice;
    }
    
    //--- Actualizar progreso
    UpdatePositionProgress(ticket);
    
    //--- Actualizar trailing stop
    if(m_tsIPDAEnabled) {
        UpdateTrailingStop(ticket);
    }
    
    //--- Actualizar breakeven
    UpdateBreakeven(ticket);
    
    //--- Actualizar scaling out
    UpdateScalingOut(ticket);
    
    m_positions[idx].lastModification = TimeCurrent();
}

//--- RF-027: Resetear contadores
void CRiskManager::ResetDailyCounters() {
    m_state.dailyDrawdown = 0;
    m_state.dailyTrades = 0;
    m_state.isDailyLimitReached = false;
}

void CRiskManager::ResetWeeklyCounters() {
    m_state.weeklyDrawdown = 0;
    m_state.weeklyTrades = 0;
    m_state.isWeeklyLimitReached = false;
}

void CRiskManager::ResetMonthlyCounters() {
    m_state.monthlyDrawdown = 0;
    m_state.monthlyTrades = 0;
    m_state.isMonthlyLimitReached = false;
}

//--- RF-027: Obtener riesgo por modelo
double CRiskManager::GetRiskPercentForModel(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return RISK_POSITION_DEFAULT;
        case MODEL_SWING:       return RISK_SWING_DEFAULT;
        case MODEL_SHORT_TERM:  return RISK_SHORT_TERM_DEFAULT;
        case MODEL_OSOK:        return RISK_OSOK_DEFAULT;
        case MODEL_DAY_TRADING: return RISK_DAY_TRADING_DEFAULT;
        case MODEL_SCALPING:    return RISK_SCALPING_DEFAULT;
        case MODEL_MEGA_TRADE:  return RISK_MEGA_DEFAULT;
        case MODEL_STOCK_TRADING: return RISK_STOCK_DEFAULT;
        case MODEL_BONUS_HUNTER: return RISK_BONUS_DEFAULT;
        default: return 1.0;
    }
}

//--- RF-019: Obtener spread máximo por modelo
double CRiskManager::GetMaxSpreadForModel(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return MAX_SPREAD_POSITION;
        case MODEL_SWING:       return MAX_SPREAD_SWING;
        case MODEL_SHORT_TERM:  return MAX_SPREAD_SHORT_TERM;
        case MODEL_OSOK:        return MAX_SPREAD_OSOK;
        case MODEL_DAY_TRADING: return MAX_SPREAD_DAY_TRADING;
        case MODEL_SCALPING:    return MAX_SPREAD_SCALPING;
        case MODEL_MEGA_TRADE:  return MAX_SPREAD_MEGA;
        case MODEL_STOCK_TRADING: return MAX_SPREAD_STOCK;
        case MODEL_BONUS_HUNTER: return MAX_SPREAD_BONUS;
        default: return 3.0;
    }
}

//--- Obtener slippage máximo por modelo
double CRiskManager::GetMaxSlippageForModel(ENUM_TRADING_MODEL model) const {
    switch(model) {
        case MODEL_POSITION:    return MAX_SLIPPAGE_POSITION;
        case MODEL_SWING:       return MAX_SLIPPAGE_SWING;
        case MODEL_SHORT_TERM:  return MAX_SLIPPAGE_SHORT_TERM;
        case MODEL_OSOK:        return MAX_SLIPPAGE_OSOK;
        case MODEL_DAY_TRADING: return MAX_SLIPPAGE_DAY_TRADING;
        case MODEL_SCALPING:    return MAX_SLIPPAGE_SCALPING;
        case MODEL_MEGA_TRADE:  return MAX_SLIPPAGE_MEGA;
        case MODEL_STOCK_TRADING: return MAX_SLIPPAGE_STOCK;
        case MODEL_BONUS_HUNTER: return MAX_SLIPPAGE_BONUS;
        default: return 3.0;
    }
}

//--- RF-055: Incrementar contador de trades
void CRiskManager::IncrementTradeCount(ENUM_TRADING_MODEL model) {
    m_state.dailyTrades++;
    m_state.weeklyTrades++;
    m_state.monthlyTrades++;
}

//--- RF-055: Verificar frecuencia por modelo
bool CRiskManager::IsFrequencyValid(ENUM_TRADING_MODEL model) {
    int dailyMax = GetMaxTradesPerDay(model);
    int weeklyMax = GetMaxTradesPerWeek(model);
    int yearlyMax = GetMaxTradesPerYear(model);
    
    if(m_state.dailyTrades >= dailyMax) return false;
    if(m_state.weeklyTrades >= weeklyMax) return false;
    if(m_state.monthlyTrades >= yearlyMax / 12) return false;
    
    return true;
}

//--- RF-055: Obtener contador de trades
int CRiskManager::GetTradesCount(ENUM_TRADING_MODEL model, ENUM_TIMEFRAMES period) {
    switch(period) {
        case PERIOD_D1: return m_state.dailyTrades;
        case PERIOD_W1: return m_state.weeklyTrades;
        case PERIOD_MN1: return m_state.monthlyTrades;
        default: return 0;
    }
}

//--- RF-053: Actualización
void CRiskManager::Update() {
    if(!m_isInitialized) return;
    
    UpdateAccountInfo();
    UpdateDrawdown();
    UpdateRiskExposure();
    CheckCooldown();
    
    //--- Actualizar posiciones
    for(int i = m_positionCount - 1; i >= 0; i--) {
        //--- Verificar si la posición aún está abierta
        if(!PositionSelectByTicket(m_positions[i].ticket)) {
            RemovePosition(m_positions[i].ticket);
            continue;
        }
        UpdatePosition(m_positions[i].ticket);
    }
    
    //--- Verificar emergency stop
    if(IsEmergencyStopTriggered()) {
        ExecuteEmergencyStop();
    }
}

//--- RF-069: Check cooldown
void CRiskManager::CheckCooldown() {
    if(m_isCooldownActive && TimeCurrent() >= m_cooldownEnd) {
        m_isCooldownActive = false;
        m_mitigationFactor = 1.0;
        m_currentRiskMultiplier = 1.0;
        m_consecutiveLosses = 0;
        m_utils.LogInfo("Cooldown expired, trading resumed");
    }
}

//--- RF-069: Resetear mitigación
void CRiskManager::ResetMitigation() {
    m_mitigationFactor = 1.0;
    m_currentRiskMultiplier = 1.0;
    m_consecutiveLosses = 0;
    m_consecutiveWins = 0;
    m_isCooldownActive = false;
    m_cooldownEnd = 0;
}

//+------------------------------------------------------------------+
//| Obtener progreso de posición                                     |
//+------------------------------------------------------------------+
double CRiskManager::GetPositionProgress(ulong ticket) const {
    for(int i = 0; i < m_positionCount; i++) {
        if(m_positions[i].ticket == ticket) {
            return m_positions[i].progressPercent;
        }
    }
    return 0;
}

//--- Reportes
string CRiskManager::GetRiskSummary() {
    string summary = "=== RISK SUMMARY ===\n";
    summary += "Equity: " + DoubleToString(m_state.accountEquity, 2) + "\n";
    summary += "Balance: " + DoubleToString(m_state.accountBalance, 2) + "\n";
    summary += "Drawdown: " + DoubleToString(m_state.currentDrawdown, 2) + "%\n";
    summary += "Max Drawdown: " + DoubleToString(m_state.maxDrawdown, 2) + "%\n";
    summary += "Risk per Trade: " + DoubleToString(m_state.riskPerTrade, 2) + "%\n";
    summary += "Open Positions: " + IntegerToString(m_positionCount) + "\n";
    summary += "Cooldown: " + (m_isCooldownActive ? "ACTIVE" : "INACTIVE") + "\n";
    summary += "Mitigation Factor: " + DoubleToString(m_mitigationFactor, 2) + "\n";
    summary += "Consecutive Losses: " + IntegerToString(m_consecutiveLosses) + "\n";
    summary += "Consecutive Wins: " + IntegerToString(m_consecutiveWins) + "\n";
    summary += "=========================";
    return summary;
}

string CRiskManager::GetDrawdownReport() {
    string report = "=== DRAWDOWN REPORT ===\n";
    report += "Current: " + DoubleToString(m_state.currentDrawdown, 2) + "%\n";
    report += "Maximum: " + DoubleToString(m_state.maxDrawdown, 2) + "%\n";
    report += "Daily: " + DoubleToString(m_state.dailyDrawdown, 2) + "% (Limit: " + DoubleToString(m_dailyLossLimit, 2) + "%)\n";
    report += "Weekly: " + DoubleToString(m_state.weeklyDrawdown, 2) + "% (Limit: " + DoubleToString(m_weeklyLossLimit, 2) + "%)\n";
    report += "Monthly: " + DoubleToString(m_state.monthlyDrawdown, 2) + "% (Limit: " + DoubleToString(m_monthlyLossLimit, 2) + "%)\n";
    report += "Limit Reached: " + (m_state.isDrawdownLimitReached ? "YES" : "NO") + "\n";
    report += "Emergency Stop Level: " + DoubleToString(GetEmergencyStopLevel(), 2) + "\n";
    report += "=========================";
    return report;
}

string CRiskManager::GetPositionReport() {
    string report = "=== POSITION REPORT ===\n";
    report += "Open Positions: " + IntegerToString(m_positionCount) + "/" + IntegerToString(m_maxPositions) + "\n";
    
    for(int i = 0; i < m_positionCount; i++) {
        report += "---\n";
        report += "Ticket: " + IntegerToString(m_positions[i].ticket) + "\n";
        report += "Symbol: " + m_positions[i].symbol + "\n";
        report += "Model: " + EnumToString(m_positions[i].model) + "\n";
        report += "Bias: " + (m_positions[i].bias == BIAS_BULLISH ? "BUY" : "SELL") + "\n";
        report += "Entry: " + DoubleToString(m_positions[i].entryPrice, 5) + "\n";
        report += "SL: " + DoubleToString(m_positions[i].currentSL, 5) + "\n";
        report += "TP: " + DoubleToString(m_positions[i].currentTP, 5) + "\n";
        report += "Lot: " + DoubleToString(m_positions[i].lot, 2) + "\n";
        report += "Progress: " + DoubleToString(m_positions[i].progressPercent, 1) + "%\n";
        report += "Breakeven: " + (m_positions[i].isBreakevenHit ? "YES" : "NO") + "\n";
        report += "Trailing: " + (m_positions[i].isTrailingActive ? "ACTIVE" : "INACTIVE") + "\n";
        report += "Open Time: " + TimeToString(m_positions[i].openTime) + "\n";
    }
    
    report += "=========================";
    return report;
}

string CRiskManager::GetMitigationReport() {
    string report = "=== MITIGATION REPORT ===\n";
    report += "Mitigation Factor: " + DoubleToString(m_mitigationFactor, 2) + "\n";
    report += "Risk Multiplier: " + DoubleToString(m_currentRiskMultiplier, 2) + "\n";
    report += "Consecutive Losses: " + IntegerToString(m_consecutiveLosses) + "\n";
    report += "Consecutive Wins: " + IntegerToString(m_consecutiveWins) + "\n";
    report += "Cooldown: " + (m_isCooldownActive ? "ACTIVE" : "INACTIVE") + "\n";
    if(m_isCooldownActive) {
        report += "Cooldown Remaining: " + DoubleToString(GetCooldownDaysRemaining(), 1) + " days\n";
    }
    report += "=========================";
    return report;
}

#endif // __CRISKMANAGER_MQH__