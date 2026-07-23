//+------------------------------------------------------------------+
//|                                                 CMultiSymbol.mqh |
//|                      HunterIPDA Pro EA - v1.8 - Módulo Execution |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis y ejecución multi-símbolo:      |
//| - Lista de símbolos a operar                                     |
//| - Análisis independiente por símbolo                             |
//| - Selección de mejores símbolos por modelo                       |
//| - Ejecución por símbolo con gestión de riesgo independiente      |
//| - Sincronización horaria y configuración por símbolo             |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-032 a RF-035                                                |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CDetector: Detección de setups                               |
//|   - CExecutor: Ejecución de órdenes                              |
//|   - CMacroAnalyzer: Análisis macro                               |
//|   - CSeasonal: Tendencias estacionales                           |
//|   - CDataRange: IPDA Data Ranges                                 |
//|   - CMultiAsset: Análisis multi-asset                            |
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

#ifndef __CMULTISYMBOL_MQH__
#define __CMULTISYMBOL_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CDetector.mqh"
#include "../Analysis/CMacroAnalyzer.mqh"
#include "../Analysis/CSeasonal.mqh"
#include "../Analysis/CDataRange.mqh"
#include "../Analysis/CMultiAsset.mqh"
#include "CExecutor.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct SymbolData {
    string           symbol;
    ENUM_TIMEFRAMES  mainTF;
    ENUM_TIMEFRAMES  contextTF;
    ENUM_TRADING_MODEL activeModel;
    ENUM_BIAS        currentBias;
    bool             isActive;
    bool             isTradingAllowed;
    double           spread;
    double           atr;
    int              orderCount;
    double           pnl;
    double           winRate;
    double           totalTrades;
    int              consecutiveLosses;
    int              consecutiveWins;
    double           strengthScore;
    double           momentumScore;
    ENUM_RISK_ENVIRONMENT riskEnv;
    datetime         lastUpdate;
    datetime         lastTrade;
    double           dailyPnl;
    double           weeklyPnl;
    double           monthlyPnl;
    int              dailyTrades;
    int              weeklyTrades;
    int              monthlyTrades;
    bool             isInWatchlist;
    double           priorityScore;
    double           seasonalScore;
    double           macroScore;
    double           technicalScore;
};

struct SymbolRanking {
    string           symbol;
    double           score;
    ENUM_TRADING_MODEL model;
    ENUM_BIAS        bias;
    double           entryPrice;
    double           stopLoss;
    double           takeProfit;
    double           rrRatio;
    int              qualityScore;
    bool             isValid;
};

//+------------------------------------------------------------------+
//| CLASE CMultiSymbol - Gestor Multi-Símbolo                        |
//+------------------------------------------------------------------+
class CMultiSymbol {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CDetector*         m_detector;
    CExecutor*         m_executor;
    CMacroAnalyzer*    m_macroAnalyzer;
    CSeasonal*         m_seasonal;
    CDataRange*        m_dataRange;
    CMultiAsset*       m_multiAsset;
    bool               m_isInitialized;
    
    //--- Listas de símbolos
    string             m_fxSymbols[];
    string             m_indexSymbols[];
    string             m_commoditySymbols[];
    string             m_cryptoSymbols[];
    string             m_stockSymbols[];
    string             m_macroSymbols[];
    string             m_futuresSymbols[];
    int                m_fxCount;
    int                m_indexCount;
    int                m_commodityCount;
    int                m_cryptoCount;
    int                m_stockCount;
    int                m_macroCount;
    int                m_futuresCount;
    
    //--- Datos de símbolos activos
    SymbolData         m_symbolData[];
    int                m_symbolCount;
    int                m_maxSymbols;
    string             m_activeSymbols[];
    int                m_activeCount;
    
    //--- Ranking por modelo
    SymbolRanking      m_ranking[];
    int                m_rankingCount;
    
    //--- Configuración
    bool               m_autoSelectSymbols;
    bool               m_useSpreadFilter;
    bool               m_useATRFilter;
    double             m_maxSpreadPips;
    double             m_minATR;
    int                m_maxConcurrentTrades;
    int                m_maxTradesPerSymbol;
    int                m_updateInterval;
    datetime           m_lastUpdate;
    
    //--- RF-035: Sincronización horaria
    bool               m_syncTimeEnabled;
    int                m_tradingStartHour;
    int                m_tradingEndHour;
    bool               m_allowFridayTrading;
    bool               m_allowMondayTrading;
    
    //--- Métodos privados
    bool               InitializeSymbols();
    bool               LoadSymbolList();
    bool               ValidateSymbol(string symbol);
    bool               IsSymbolAvailable(string symbol) const;
    bool               IsSymbolTradingAllowed(string symbol);
    double             GetSymbolSpread(string symbol);
    double             GetSymbolATR(string symbol);
    ENUM_BIAS          GetSymbolBias(string symbol);
    int                GetSymbolOrderCount(string symbol);
    double             GetSymbolPnL(string symbol);
    double             GetSymbolWinRate(string symbol);
    double             GetSymbolStrength(string symbol);
    double             GetSymbolMomentum(string symbol);
    ENUM_RISK_ENVIRONMENT GetSymbolRiskEnv(string symbol) const;
    void               UpdateSymbolData(string symbol);
    void               SelectBestSymbols();
    string             SelectBestSymbolForModel(ENUM_TRADING_MODEL model);
    string             SelectBestSwingSymbol();
    string             SelectBestOSOKSymbol();
    string             SelectBestDayTradeSymbol();
    string             SelectBestScalpSymbol();
    string             SelectBestMegaTradeSymbol();
    string             SelectBestStockSymbol();
    string             SelectBestBonusHunterSymbol();
    double             CalculateSymbolScore(string symbol, ENUM_TRADING_MODEL model);
    double             CalculateTechnicalScore(string symbol);
    double             CalculateMacroScore(string symbol);
    double             CalculateSeasonalScore(string symbol);
    double             CalculatePriorityScore(string symbol, ENUM_TRADING_MODEL model);
    bool               IsSymbolQualified(string symbol, ENUM_TRADING_MODEL model);
    void               UpdateRanking();
    void               CleanSymbolData();
    void               ResetSymbolStats(string symbol);
    bool               IsTimeValidForSymbol(string symbol) const;
    bool               IsTradingDayValidForSymbol(string symbol);
    bool               IsSymbolInWatchlist(string symbol) const;
    bool               IsSymbolInList(string symbol, const string &list[]) const;
    int                FindSymbolIndex(string symbol) const;
    void               AddSymbolToList(string symbol);
    void               RemoveSymbolFromList(string symbol);
    void               AddSymbolToData(string symbol);
    void               RemoveSymbolFromData(string symbol);
    
public:
    //--- Constructor / Destructor
    CMultiSymbol();
    ~CMultiSymbol();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CDetector* detector,
              CExecutor* executor, CMacroAnalyzer* macroAnalyzer,
              CSeasonal* seasonal, CDataRange* dataRange,
              CMultiAsset* multiAsset);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-032: Lista de Símbolos
    bool SetSymbols(string symbols);
    bool AddSymbol(string symbol);
    bool RemoveSymbol(string symbol);
    bool ClearSymbols();
    string GetSymbols() const;
    int GetSymbolCount() const { return m_symbolCount; }
    string GetSymbol(int index) const;
    string GetActiveSymbol(int index) const;
    int GetActiveSymbolCount() const { return m_activeCount; }
    
    //--- RF-033: Análisis por Símbolo
    void Update();
    void UpdateSymbol(string symbol);
    void UpdateAllSymbols();
    SymbolData GetSymbolData(string symbol) const;
    SymbolData GetSymbolData(int index) const;
    bool IsSymbolActive(string symbol) const;
    bool IsSymbolTradingAllowed(string symbol) const;
    ENUM_BIAS GetSymbolBias(string symbol) const;
    double GetSymbolSpread(string symbol) const;
    double GetSymbolATR(string symbol) const;
    int GetSymbolOrderCount(string symbol) const;
    double GetSymbolPnL(string symbol) const;
    
    //--- RF-034: Ejecución por Símbolo
    bool ExecuteOnSymbol(string symbol, Signal &signal);
    bool ExecuteOnBestSymbol(ENUM_TRADING_MODEL model);
    bool CanTradeSymbol(string symbol, ENUM_TRADING_MODEL model);
    int GetOpenPositionsForSymbol(string symbol) const;
    int GetMaxPositionsForSymbol(string symbol) const;
    double GetRiskForSymbol(string symbol) const;
    bool CloseAllPositionsForSymbol(string symbol);
    
    //--- Selección de mejores símbolos
    string GetBestSymbol(ENUM_TRADING_MODEL model);
    string GetBestSwingSymbol();
    string GetBestOSOKSymbol();
    string GetBestDayTradeSymbol();
    string GetBestScalpSymbol();
    string GetBestMegaTradeSymbol();
    string GetBestStockSymbol();
    string GetBestBonusHunterSymbol();
    SymbolRanking GetBestRanking(ENUM_TRADING_MODEL model);
    SymbolRanking GetRanking(int index) const;
    int GetRankingCount() const { return m_rankingCount; }
    
    //--- RF-035: Sincronización Horaria
    void SetTimeSync(bool enabled);
    bool IsTimeSyncEnabled() const { return m_syncTimeEnabled; }
    void SetTradingHours(int startHour, int endHour);
    int GetTradingStartHour() const { return m_tradingStartHour; }
    int GetTradingEndHour() const { return m_tradingEndHour; }
    void SetFridayTrading(bool allowed) { m_allowFridayTrading = allowed; }
    void SetMondayTrading(bool allowed) { m_allowMondayTrading = allowed; }
    bool IsFridayTradingAllowed() const { return m_allowFridayTrading; }
    bool IsMondayTradingAllowed() const { return m_allowMondayTrading; }
    bool IsTradingHourValid(string symbol) const;
    bool IsTradingDayValid(string symbol) const;
    bool IsTradingTimeValid(string symbol) const;
    
    //--- Configuración
    void SetAutoSelectSymbols(bool enabled) { m_autoSelectSymbols = enabled; }
    bool IsAutoSelectSymbols() const { return m_autoSelectSymbols; }
    void SetSpreadFilter(bool enabled) { m_useSpreadFilter = enabled; }
    void SetATRFilter(bool enabled) { m_useATRFilter = enabled; }
    void SetMaxSpread(double pips) { m_maxSpreadPips = MathMax(0.1, pips); }
    void SetMinATR(double atr) { m_minATR = MathMax(0.01, atr); }
    void SetMaxConcurrentTrades(int max) { m_maxConcurrentTrades = MathMax(1, max); }
    void SetMaxTradesPerSymbol(int max) { m_maxTradesPerSymbol = MathMax(0, max); }
    void SetUpdateInterval(int seconds) { m_updateInterval = MathMax(10, seconds); }
    
    //--- Getters de configuración
    bool IsSpreadFilterEnabled() const { return m_useSpreadFilter; }
    bool IsATRFilterEnabled() const { return m_useATRFilter; }
    double GetMaxSpread() const { return m_maxSpreadPips; }
    double GetMinATR() const { return m_minATR; }
    int GetMaxConcurrentTrades() const { return m_maxConcurrentTrades; }
    int GetMaxTradesPerSymbol() const { return m_maxTradesPerSymbol; }
    int GetUpdateInterval() const { return m_updateInterval; }
    
    //--- Watchlist
    bool AddToWatchlist(string symbol);
    bool RemoveFromWatchlist(string symbol);
    bool IsInWatchlist(string symbol) const;
    int GetWatchlistCount() const;
    string GetWatchlistSymbol(int index) const;
    void ClearWatchlist();
    
    //--- Reportes
    string GetSummary();
    string GetSymbolReport(string symbol);
    string GetAllSymbolsReport();
    string GetRankingReport(ENUM_TRADING_MODEL model);
    string GetWatchlistReport();
    string GetStatusReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CMultiSymbol::CMultiSymbol() {
    m_config = NULL;
    m_utils = NULL;
    m_detector = NULL;
    m_executor = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_multiAsset = NULL;
    m_isInitialized = false;
    m_fxCount = 0;
    m_indexCount = 0;
    m_commodityCount = 0;
    m_cryptoCount = 0;
    m_stockCount = 0;
    m_macroCount = 0;
    m_futuresCount = 0;
    m_symbolCount = 0;
    m_maxSymbols = 50;
    m_activeCount = 0;
    m_rankingCount = 0;
    m_autoSelectSymbols = true;
    m_useSpreadFilter = true;
    m_useATRFilter = true;
    m_maxSpreadPips = 3.0;
    m_minATR = 0.001;
    m_maxConcurrentTrades = 5;
    m_maxTradesPerSymbol = 2;
    m_updateInterval = 60;
    m_lastUpdate = 0;
    m_syncTimeEnabled = true;
    m_tradingStartHour = 0;
    m_tradingEndHour = 23;
    m_allowFridayTrading = true;
    m_allowMondayTrading = true;
    ArrayResize(m_fxSymbols, 0);
    ArrayResize(m_indexSymbols, 0);
    ArrayResize(m_commoditySymbols, 0);
    ArrayResize(m_cryptoSymbols, 0);
    ArrayResize(m_stockSymbols, 0);
    ArrayResize(m_macroSymbols, 0);
    ArrayResize(m_futuresSymbols, 0);
    ArrayResize(m_symbolData, 0);
    ArrayResize(m_activeSymbols, 0);
    ArrayResize(m_ranking, 0);
}

//--- Destructor
CMultiSymbol::~CMultiSymbol() {
    Deinit();
}

//--- Inicialización
bool CMultiSymbol::Init(CConfig* config, CUtils* utils, CDetector* detector,
                        CExecutor* executor, CMacroAnalyzer* macroAnalyzer,
                        CSeasonal* seasonal, CDataRange* dataRange,
                        CMultiAsset* multiAsset) {
    if(config == NULL || utils == NULL || detector == NULL ||
       executor == NULL || macroAnalyzer == NULL || seasonal == NULL ||
       dataRange == NULL || multiAsset == NULL) {
        Print("CMultiSymbol::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_detector = detector;
    m_executor = executor;
    m_macroAnalyzer = macroAnalyzer;
    m_seasonal = seasonal;
    m_dataRange = dataRange;
    m_multiAsset = multiAsset;
    
    //--- Inicializar listas de símbolos
    if(!InitializeSymbols()) {
        m_utils.LogWarning("CMultiSymbol::Init - No se pudieron inicializar los símbolos");
    }
    
    //--- Cargar lista de símbolos
    if(!LoadSymbolList()) {
        m_utils.LogWarning("CMultiSymbol::Init - No se pudo cargar la lista de símbolos");
    }
    
    //--- Actualizar datos iniciales
    UpdateAllSymbols();
    
    m_isInitialized = true;
    m_utils.LogInfo("CMultiSymbol inicializado correctamente");
    return true;
}

//--- Desinicialización
void CMultiSymbol::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_detector = NULL;
    m_executor = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_multiAsset = NULL;
    m_isInitialized = false;
    ArrayResize(m_fxSymbols, 0);
    ArrayResize(m_indexSymbols, 0);
    ArrayResize(m_commoditySymbols, 0);
    ArrayResize(m_cryptoSymbols, 0);
    ArrayResize(m_stockSymbols, 0);
    ArrayResize(m_macroSymbols, 0);
    ArrayResize(m_futuresSymbols, 0);
    ArrayResize(m_symbolData, 0);
    ArrayResize(m_activeSymbols, 0);
    ArrayResize(m_ranking, 0);
}

//--- RF-032: Inicializar símbolos
bool CMultiSymbol::InitializeSymbols() {
    //--- Símbolos FX
    ArrayResize(m_fxSymbols, 7);
    m_fxSymbols[0] = "EURUSD";
    m_fxSymbols[1] = "GBPUSD";
    m_fxSymbols[2] = "USDJPY";
    m_fxSymbols[3] = "AUDUSD";
    m_fxSymbols[4] = "USDCAD";
    m_fxSymbols[5] = "NZDUSD";
    m_fxSymbols[6] = "USDCHF";
    m_fxCount = 7;
    
    //--- Símbolos de Índices
    ArrayResize(m_indexSymbols, 4);
    m_indexSymbols[0] = "US500";
    m_indexSymbols[1] = "US30";
    m_indexSymbols[2] = "NAS100";
    m_indexSymbols[3] = "UK100";
    m_indexCount = 4;
    
    //--- Símbolos de Commodities
    ArrayResize(m_commoditySymbols, 4);
    m_commoditySymbols[0] = "XAUUSD";
    m_commoditySymbols[1] = "XAGUSD";
    m_commoditySymbols[2] = "WTI";
    m_commoditySymbols[3] = "BRENT";
    m_commodityCount = 4;
    
    //--- Símbolos de Criptomonedas
    ArrayResize(m_cryptoSymbols, 3);
    m_cryptoSymbols[0] = "BTCUSD";
    m_cryptoSymbols[1] = "ETHUSD";
    m_cryptoSymbols[2] = "LTCUSD";
    m_cryptoCount = 3;
    
    //--- Símbolos de Stocks
    ArrayResize(m_stockSymbols, 0);
    m_stockCount = 0;
    
    //--- Símbolos Macro
    ArrayResize(m_macroSymbols, 3);
    m_macroSymbols[0] = "DXY";
    m_macroSymbols[1] = "US10Y";
    m_macroSymbols[2] = "US30Y";
    m_macroCount = 3;
    
    //--- Símbolos de Futuros
    ArrayResize(m_futuresSymbols, 0);
    m_futuresCount = 0;
    
    return true;
}

//--- RF-032: Cargar lista de símbolos
bool CMultiSymbol::LoadSymbolList() {
    //--- Combinar todos los símbolos en una lista
    string allSymbols[];
    int totalCount = m_fxCount + m_indexCount + m_commodityCount + 
                     m_cryptoCount + m_stockCount + m_macroCount + m_futuresCount;
    
    ArrayResize(allSymbols, totalCount);
    int idx = 0;
    
    for(int i = 0; i < m_fxCount; i++) {
        allSymbols[idx++] = m_fxSymbols[i];
    }
    for(int i = 0; i < m_indexCount; i++) {
        allSymbols[idx++] = m_indexSymbols[i];
    }
    for(int i = 0; i < m_commodityCount; i++) {
        allSymbols[idx++] = m_commoditySymbols[i];
    }
    for(int i = 0; i < m_cryptoCount; i++) {
        allSymbols[idx++] = m_cryptoSymbols[i];
    }
    for(int i = 0; i < m_stockCount; i++) {
        allSymbols[idx++] = m_stockSymbols[i];
    }
    for(int i = 0; i < m_macroCount; i++) {
        allSymbols[idx++] = m_macroSymbols[i];
    }
    for(int i = 0; i < m_futuresCount; i++) {
        allSymbols[idx++] = m_futuresSymbols[i];
    }
    
    //--- Añadir a datos
    for(int i = 0; i < ArraySize(allSymbols); i++) {
        if(ValidateSymbol(allSymbols[i])) {
            AddSymbolToList(allSymbols[i]);
        }
    }
    
    return true;
}

//--- RF-032: Añadir símbolo a la lista
bool CMultiSymbol::AddSymbol(string symbol) {
    if(!m_isInitialized) return false;
    if(!ValidateSymbol(symbol)) return false;
    if(IsSymbolInList(symbol, m_fxSymbols) || 
       IsSymbolInList(symbol, m_indexSymbols) ||
       IsSymbolInList(symbol, m_commoditySymbols) ||
       IsSymbolInList(symbol, m_cryptoSymbols) ||
       IsSymbolInList(symbol, m_stockSymbols) ||
       IsSymbolInList(symbol, m_macroSymbols) ||
       IsSymbolInList(symbol, m_futuresSymbols)) {
        return false;
    }
    
    //--- Añadir a la lista apropiada
    //--- Por defecto, añadir a FX
    ArrayResize(m_fxSymbols, m_fxCount + 1);
    m_fxSymbols[m_fxCount] = symbol;
    m_fxCount++;
    
    AddSymbolToList(symbol);
    return true;
}

//--- RF-032: Eliminar símbolo de la lista
bool CMultiSymbol::RemoveSymbol(string symbol) {
    if(!m_isInitialized) return false;
    
    //--- Buscar en listas y eliminar
    if(IsSymbolInList(symbol, m_fxSymbols)) {
        for(int i = 0; i < m_fxCount; i++) {
            if(m_fxSymbols[i] == symbol) {
                if(i < m_fxCount - 1) {
                    m_fxSymbols[i] = m_fxSymbols[m_fxCount - 1];
                }
                m_fxCount--;
                ArrayResize(m_fxSymbols, m_fxCount);
                RemoveSymbolFromList(symbol);
                return true;
            }
        }
    }
    //--- Similar para otras listas...
    
    return false;
}

//--- RF-032: Limpiar símbolos
bool CMultiSymbol::ClearSymbols() {
    if(!m_isInitialized) return false;
    
    ArrayResize(m_symbolData, 0);
    m_symbolCount = 0;
    ArrayResize(m_activeSymbols, 0);
    m_activeCount = 0;
    
    return true;
}

//--- RF-032: Obtener lista de símbolos
string CMultiSymbol::GetSymbols() const {
    string result = "";
    for(int i = 0; i < m_symbolCount; i++) {
        result += m_symbolData[i].symbol;
        if(i < m_symbolCount - 1) result += ",";
    }
    return result;
}

//--- RF-032: Obtener símbolo por índice
string CMultiSymbol::GetSymbol(int index) const {
    if(index < 0 || index >= m_symbolCount) return "";
    return m_symbolData[index].symbol;
}

//--- RF-032: Obtener símbolo activo por índice
string CMultiSymbol::GetActiveSymbol(int index) const {
    if(index < 0 || index >= m_activeCount) return "";
    return m_activeSymbols[index];
}

//--- RF-033: Actualizar todos los símbolos
void CMultiSymbol::UpdateAllSymbols() {
    if(!m_isInitialized) return;
    
    for(int i = 0; i < m_symbolCount; i++) {
        UpdateSymbol(m_symbolData[i].symbol);
    }
    
    //--- Seleccionar mejores símbolos
    SelectBestSymbols();
    UpdateRanking();
    
    m_lastUpdate = TimeCurrent();
}

//--- RF-033: Actualizar símbolo
void CMultiSymbol::UpdateSymbol(string symbol) {
    if(!m_isInitialized) return;
    if(!ValidateSymbol(symbol)) return;
    
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) {
        AddSymbolToList(symbol);
        idx = FindSymbolIndex(symbol);
        if(idx == -1) return;
    }
    
    //--- Actualizar datos del símbolo
    m_symbolData[idx].symbol = symbol;
    m_symbolData[idx].mainTF = PERIOD_H1;
    m_symbolData[idx].contextTF = PERIOD_D1;
    m_symbolData[idx].spread = GetSymbolSpread(symbol);
    m_symbolData[idx].atr = GetSymbolATR(symbol);
    m_symbolData[idx].currentBias = GetSymbolBias(symbol);
    m_symbolData[idx].orderCount = GetSymbolOrderCount(symbol);
    m_symbolData[idx].pnl = GetSymbolPnL(symbol);
    m_symbolData[idx].winRate = GetSymbolWinRate(symbol);
    m_symbolData[idx].strengthScore = GetSymbolStrength(symbol);
    m_symbolData[idx].momentumScore = GetSymbolMomentum(symbol);
    m_symbolData[idx].riskEnv = GetSymbolRiskEnv(symbol);
    m_symbolData[idx].lastUpdate = TimeCurrent();
    m_symbolData[idx].isActive = IsSymbolTradingAllowed(symbol);
    m_symbolData[idx].isTradingAllowed = IsSymbolTradingAllowed(symbol) && 
                                         IsTimeValidForSymbol(symbol);
    m_symbolData[idx].seasonalScore = CalculateSeasonalScore(symbol);
    m_symbolData[idx].macroScore = CalculateMacroScore(symbol);
    m_symbolData[idx].technicalScore = CalculateTechnicalScore(symbol);
    m_symbolData[idx].priorityScore = CalculatePriorityScore(symbol, MODEL_POSITION);
    
    //--- Determinar modelo activo
    if(m_symbolData[idx].isTradingAllowed) {
        //--- Seleccionar modelo basado en las características del símbolo
        if(m_symbolData[idx].strengthScore > 70 && m_symbolData[idx].seasonalScore > 60) {
            m_symbolData[idx].activeModel = MODEL_SWING;
        } else if(m_symbolData[idx].momentumScore > 60) {
            m_symbolData[idx].activeModel = MODEL_SHORT_TERM;
        } else if(m_symbolData[idx].spread < 0.5) {
            m_symbolData[idx].activeModel = MODEL_SCALPING;
        } else {
            m_symbolData[idx].activeModel = MODEL_DAY_TRADING;
        }
    }
}

//--- RF-033: Obtener datos de símbolo
SymbolData CMultiSymbol::GetSymbolData(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) {
        SymbolData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_symbolData[idx];
}

SymbolData CMultiSymbol::GetSymbolData(int index) const {
    if(index < 0 || index >= m_symbolCount) {
        SymbolData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_symbolData[index];
}

//--- RF-033: Verificar si símbolo está activo
bool CMultiSymbol::IsSymbolActive(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_symbolData[idx].isActive;
}

//--- RF-033: Verificar si símbolo permite trading
bool CMultiSymbol::IsSymbolTradingAllowed(string symbol) const {
    if(!IsSymbolAvailable(symbol)) return false;
    if(!IsTimeValidForSymbol(symbol)) return false;
    
    double spread = GetSymbolSpread(symbol);
    if(m_useSpreadFilter && spread > m_maxSpreadPips) return false;
    
    double atr = GetSymbolATR(symbol);
    if(m_useATRFilter && atr < m_minATR) return false;
    
    return true;
}

//--- RF-033: Obtener bias del símbolo
ENUM_BIAS CMultiSymbol::GetSymbolBias(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return BIAS_NEUTRAL;
    return m_symbolData[idx].currentBias;
}

//--- RF-033: Obtener spread del símbolo
double CMultiSymbol::GetSymbolSpread(string symbol) const {
    if(!IsSymbolAvailable(symbol)) return 999;
    double spread = (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    return spread * point * 10;
}

//--- RF-033: Obtener ATR del símbolo
double CMultiSymbol::GetSymbolATR(string symbol) const {
    if(!IsSymbolAvailable(symbol)) return 0;
    return m_utils.CalculateATR(symbol, PERIOD_D1, 14);
}

//--- RF-033: Obtener número de órdenes del símbolo
int CMultiSymbol::GetSymbolOrderCount(string symbol) const {
    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == symbol) {
            count++;
        }
    }
    return count;
}

//--- RF-033: Obtener PnL del símbolo
double CMultiSymbol::GetSymbolPnL(string symbol) const {
    double total = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == symbol) {
            total += PositionGetDouble(POSITION_PROFIT);
        }
    }
    return total;
}

//--- RF-033: Obtener entorno de riesgo del símbolo
ENUM_RISK_ENVIRONMENT CMultiSymbol::GetSymbolRiskEnv(string symbol) const {
    if(m_multiAsset != NULL) {
        return m_multiAsset.GetRiskEnvironment();
    }
    return RISK_NEUTRAL;
}

//--- RF-034: Ejecutar en símbolo
bool CMultiSymbol::ExecuteOnSymbol(string symbol, Signal &signal) {
    if(!m_isInitialized) return false;
    if(!CanTradeSymbol(symbol, signal.model)) return false;
    
    //--- Verificar límite de trades concurrentes
    if(m_symbolData[FindSymbolIndex(symbol)].orderCount >= m_maxTradesPerSymbol) {
        return false;
    }
    
    return m_executor.ExecuteSignal(signal);
}

//--- RF-034: Ejecutar en mejor símbolo
bool CMultiSymbol::ExecuteOnBestSymbol(ENUM_TRADING_MODEL model) {
    if(!m_isInitialized) return false;
    
    string symbol = GetBestSymbol(model);
    if(symbol == "") return false;
    
    //--- Obtener señal del detector
    Signal signal;
    //--- Placeholder: obtener señal real del detector
    
    return ExecuteOnSymbol(symbol, signal);
}

//--- RF-034: Verificar si se puede operar símbolo
bool CMultiSymbol::CanTradeSymbol(string symbol, ENUM_TRADING_MODEL model) {
    if(!IsSymbolTradingAllowed(symbol)) return false;
    if(GetOpenPositionsForSymbol(symbol) >= m_maxTradesPerSymbol) return false;
    
    int totalOpen = 0;
    for(int i = 0; i < m_symbolCount; i++) {
        totalOpen += m_symbolData[i].orderCount;
    }
    if(totalOpen >= m_maxConcurrentTrades) return false;
    
    return true;
}

//--- RF-034: Obtener posiciones abiertas por símbolo
int CMultiSymbol::GetOpenPositionsForSymbol(string symbol) const {
    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == symbol) {
            count++;
        }
    }
    return count;
}

//--- RF-034: Obtener máximas posiciones por símbolo
int CMultiSymbol::GetMaxPositionsForSymbol(string symbol) const {
    return m_maxTradesPerSymbol;
}

//--- RF-034: Obtener riesgo por símbolo
double CMultiSymbol::GetRiskForSymbol(string symbol) const {
    //--- Placeholder: retornar riesgo configurado
    return 1.0;
}

//--- RF-034: Cerrar todas las posiciones de un símbolo
bool CMultiSymbol::CloseAllPositionsForSymbol(string symbol) {
    bool result = true;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == symbol) {
            if(!m_executor.ClosePosition(ticket)) {
                result = false;
            }
        }
    }
    return result;
}

//--- RF-032: Seleccionar mejores símbolos
void CMultiSymbol::SelectBestSymbols() {
    //--- Limpiar activos
    ArrayResize(m_activeSymbols, 0);
    m_activeCount = 0;
    
    //--- Calcular scores para cada símbolo y seleccionar los mejores
    for(int i = 0; i < m_symbolCount; i++) {
        if(m_symbolData[i].isTradingAllowed) {
            m_symbolData[i].priorityScore = CalculatePriorityScore(
                m_symbolData[i].symbol, 
                m_symbolData[i].activeModel
            );
            
            //--- Añadir a activos si tiene buena puntuación
            if(m_symbolData[i].priorityScore > 50) {
                AddSymbolToList(m_symbolData[i].symbol);
            }
        }
    }
}

//--- RF-032: Seleccionar mejor símbolo por modelo
string CMultiSymbol::GetBestSymbol(ENUM_TRADING_MODEL model) {
    return SelectBestSymbolForModel(model);
}

string CMultiSymbol::SelectBestSymbolForModel(ENUM_TRADING_MODEL model) {
    string bestSymbol = "";
    double bestScore = -1;
    
    for(int i = 0; i < m_symbolCount; i++) {
        if(!m_symbolData[i].isTradingAllowed) continue;
        
        double score = CalculatePriorityScore(m_symbolData[i].symbol, model);
        if(score > bestScore) {
            bestScore = score;
            bestSymbol = m_symbolData[i].symbol;
        }
    }
    
    return bestSymbol;
}

//--- RF-032: Seleccionar mejor símbolo para Swing
string CMultiSymbol::GetBestSwingSymbol() {
    return SelectBestSymbolForModel(MODEL_SWING);
}

//--- RF-032: Seleccionar mejor símbolo para OSOK
string CMultiSymbol::GetBestOSOKSymbol() {
    return SelectBestSymbolForModel(MODEL_OSOK);
}

//--- RF-032: Seleccionar mejor símbolo para Day Trading
string CMultiSymbol::GetBestDayTradeSymbol() {
    return SelectBestSymbolForModel(MODEL_DAY_TRADING);
}

//--- RF-032: Seleccionar mejor símbolo para Scalping
string CMultiSymbol::GetBestScalpSymbol() {
    return SelectBestSymbolForModel(MODEL_SCALPING);
}

//--- RF-032: Seleccionar mejor símbolo para Mega Trades
string CMultiSymbol::GetBestMegaTradeSymbol() {
    return SelectBestSymbolForModel(MODEL_MEGA_TRADE);
}

//--- RF-032: Seleccionar mejor símbolo para Stock Trading
string CMultiSymbol::GetBestStockSymbol() {
    return SelectBestSymbolForModel(MODEL_STOCK_TRADING);
}

//--- RF-032: Seleccionar mejor símbolo para Bonus Hunter
string CMultiSymbol::GetBestBonusHunterSymbol() {
    return SelectBestSymbolForModel(MODEL_BONUS_HUNTER);
}

//--- Calcular score de prioridad
double CMultiSymbol::CalculatePriorityScore(string symbol, ENUM_TRADING_MODEL model) {
    double score = 0;
    
    //--- Factor 1: Score técnico (30%)
    double techScore = CalculateTechnicalScore(symbol);
    score += techScore * 0.30;
    
    //--- Factor 2: Score macro (30%)
    double macroScore = CalculateMacroScore(symbol);
    score += macroScore * 0.30;
    
    //--- Factor 3: Score estacional (20%)
    double seasonalScore = CalculateSeasonalScore(symbol);
    score += seasonalScore * 0.20;
    
    //--- Factor 4: Score de mercado (20%)
    if(m_multiAsset != NULL) {
        double alignment = m_multiAsset.GetAlignmentScore();
        score += alignment * 0.20;
    }
    
    //--- Ajustes por modelo
    switch(model) {
        case MODEL_SCALPING:
            //--- Spread bajo es importante para scalping
            if(GetSymbolSpread(symbol) < 0.5) score += 20;
            break;
        case MODEL_SWING:
            //--- Fuerza de tendencia importante para swing
            score += m_symbolData[FindSymbolIndex(symbol)].strengthScore * 0.15;
            break;
        case MODEL_OSOK:
            //--- Seasonal y COT importantes para OSOK
            if(seasonalScore > 60) score += 20;
            break;
        default:
            break;
    }
    
    return MathMin(100, MathMax(0, score));
}

//--- Calcular score técnico
double CMultiSymbol::CalculateTechnicalScore(string symbol) {
    double score = 50;
    
    //--- ATR (volatilidad)
    double atr = GetSymbolATR(symbol);
    if(atr > 0.001) score += 10;
    if(atr > 0.002) score += 10;
    
    //--- Spread
    double spread = GetSymbolSpread(symbol);
    if(spread < 1.0) score += 10;
    if(spread < 0.5) score += 10;
    
    //--- Tendencia
    ENUM_BIAS bias = GetSymbolBias(symbol);
    if(bias != BIAS_NEUTRAL) score += 10;
    
    return MathMin(100, score);
}

//--- Calcular score macro
double CMultiSymbol::CalculateMacroScore(string symbol) {
    if(m_macroAnalyzer == NULL) return 50;
    
    double score = 50;
    
    //--- Verificar alineación macro
    ENUM_BIAS macroBias = m_macroAnalyzer.GetIntermarketBias();
    ENUM_BIAS symbolBias = GetSymbolBias(symbol);
    
    if(macroBias == symbolBias) score += 30;
    else if(macroBias != BIAS_NEUTRAL && symbolBias != BIAS_NEUTRAL) score -= 20;
    
    return MathMin(100, MathMax(0, score));
}

//--- Calcular score estacional
double CMultiSymbol::CalculateSeasonalScore(string symbol) {
    if(m_seasonal == NULL) return 50;
    
    double score = 50;
    
    //--- Verificar seasonal
    if(m_seasonal.IsSeasonalValid(symbol)) {
        score += 20;
        if(m_seasonal.IsIdealSeasonal(symbol)) {
            score += 20;
        }
    }
    
    return MathMin(100, MathMax(0, score));
}

//--- RF-035: Configurar sincronización horaria
void CMultiSymbol::SetTimeSync(bool enabled) {
    m_syncTimeEnabled = enabled;
}

void CMultiSymbol::SetTradingHours(int startHour, int endHour) {
    m_tradingStartHour = MathMax(0, MathMin(23, startHour));
    m_tradingEndHour = MathMax(0, MathMin(23, endHour));
    if(m_tradingStartHour > m_tradingEndHour) {
        int temp = m_tradingStartHour;
        m_tradingStartHour = m_tradingEndHour;
        m_tradingEndHour = temp;
    }
}

//--- RF-035: Verificar hora válida para símbolo
bool CMultiSymbol::IsTradingHourValid(string symbol) const {
    if(!m_syncTimeEnabled) return true;
    
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    int hour = dt.hour;
    
    if(m_tradingStartHour <= m_tradingEndHour) {
        return hour >= m_tradingStartHour && hour <= m_tradingEndHour;
    } else {
        return hour >= m_tradingStartHour || hour <= m_tradingEndHour;
    }
}

//--- RF-035: Verificar día válido para símbolo
bool CMultiSymbol::IsTradingDayValid(string symbol) const {
    if(!m_syncTimeEnabled) return true;
    
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    int dayOfWeek = dt.day_of_week;
    
    if(dayOfWeek == 5 && !m_allowFridayTrading) return false;
    if(dayOfWeek == 1 && !m_allowMondayTrading) return false;
    if(dayOfWeek == 6) return false; // Sábado
    if(dayOfWeek == 0) return false; // Domingo
    
    return true;
}

//--- RF-035: Verificar tiempo válido para símbolo
bool CMultiSymbol::IsTradingTimeValid(string symbol) const {
    return IsTradingHourValid(symbol) && IsTradingDayValid(symbol);
}

bool CMultiSymbol::IsTimeValidForSymbol(string symbol) const {
    return IsTradingTimeValid(symbol);
}

//--- Funciones auxiliares
bool CMultiSymbol::ValidateSymbol(string symbol) {
    if(symbol == "") return false;
    return SymbolSelect(symbol, true);
}

bool CMultiSymbol::IsSymbolAvailable(string symbol) const {
    return SymbolSelect(symbol, true);
}

bool CMultiSymbol::IsSymbolInWatchlist(string symbol) const {
    return IsSymbolInList(symbol, m_activeSymbols);
}

bool CMultiSymbol::IsSymbolInList(string symbol, const string &list[]) const {
    for(int i = 0; i < ArraySize(list); i++) {
        if(list[i] == symbol) return true;
    }
    return false;
}

int CMultiSymbol::FindSymbolIndex(string symbol) const  {
    for(int i = 0; i < m_symbolCount; i++) {
        if(m_symbolData[i].symbol == symbol) return i;
    }
    return -1;
}

void CMultiSymbol::AddSymbolToList(string symbol) {
    //--- Verificar si ya existe
    if(FindSymbolIndex(symbol) != -1) return;
    
    int idx = m_symbolCount;
    ArrayResize(m_symbolData, m_symbolCount + 1);
    ZeroMemory(m_symbolData[idx]);
    m_symbolData[idx].symbol = symbol;
    m_symbolData[idx].isActive = true;
    m_symbolData[idx].isTradingAllowed = true;
    m_symbolData[idx].lastUpdate = TimeCurrent();
    m_symbolCount++;
}

void CMultiSymbol::RemoveSymbolFromList(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return;
    
    if(idx < m_symbolCount - 1) {
        m_symbolData[idx] = m_symbolData[m_symbolCount - 1];
    }
    m_symbolCount--;
    ArrayResize(m_symbolData, m_symbolCount);
}

void CMultiSymbol::AddSymbolToData(string symbol) {
    AddSymbolToList(symbol);
}

void CMultiSymbol::RemoveSymbolFromData(string symbol) {
    RemoveSymbolFromList(symbol);
}

//--- Watchlist
bool CMultiSymbol::AddToWatchlist(string symbol) {
    if(!ValidateSymbol(symbol)) return false;
    if(IsSymbolInWatchlist(symbol)) return true;
    
    ArrayResize(m_activeSymbols, m_activeCount + 1);
    m_activeSymbols[m_activeCount] = symbol;
    m_activeCount++;
    
    //--- Marcar como en watchlist
    int idx = FindSymbolIndex(symbol);
    if(idx != -1) {
        m_symbolData[idx].isInWatchlist = true;
    }
    
    return true;
}

bool CMultiSymbol::RemoveFromWatchlist(string symbol) {
    for(int i = 0; i < m_activeCount; i++) {
        if(m_activeSymbols[i] == symbol) {
            if(i < m_activeCount - 1) {
                m_activeSymbols[i] = m_activeSymbols[m_activeCount - 1];
            }
            m_activeCount--;
            ArrayResize(m_activeSymbols, m_activeCount);
            
            //--- Desmarcar watchlist
            int idx = FindSymbolIndex(symbol);
            if(idx != -1) {
                m_symbolData[idx].isInWatchlist = false;
            }
            return true;
        }
    }
    return false;
}

bool CMultiSymbol::IsInWatchlist(string symbol) const {
    return IsSymbolInWatchlist(symbol);
}

int CMultiSymbol::GetWatchlistCount() const {
    return m_activeCount;
}

string CMultiSymbol::GetWatchlistSymbol(int index) const {
    if(index < 0 || index >= m_activeCount) return "";
    return m_activeSymbols[index];
}

void CMultiSymbol::ClearWatchlist() {
    ArrayResize(m_activeSymbols, 0);
    m_activeCount = 0;
}

//--- RF-033: Actualizar
void CMultiSymbol::Update() {
    if(!m_isInitialized) return;
    
    //--- Verificar si es necesario actualizar
    if(TimeCurrent() - m_lastUpdate < m_updateInterval) return;
    
    UpdateAllSymbols();
}

//--- RF-034: Obtener mejor ranking
SymbolRanking CMultiSymbol::GetBestRanking(ENUM_TRADING_MODEL model) {
    SymbolRanking best;
    ZeroMemory(best);
    double bestScore = -1;
    
    for(int i = 0; i < m_rankingCount; i++) {
        if(m_ranking[i].model == model && m_ranking[i].score > bestScore) {
            bestScore = m_ranking[i].score;
            best = m_ranking[i];
        }
    }
    
    return best;
}

SymbolRanking CMultiSymbol::GetRanking(int index) const {
    if(index < 0 || index >= m_rankingCount) {
        SymbolRanking empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_ranking[index];
}

//--- Actualizar ranking
void CMultiSymbol::UpdateRanking() {
    ArrayResize(m_ranking, 0);
    m_rankingCount = 0;
    
    for(int i = 0; i < m_symbolCount; i++) {
        if(!m_symbolData[i].isTradingAllowed) continue;
        
        //--- Calcular ranking para cada modelo
        ENUM_TRADING_MODEL models[] = {
            MODEL_POSITION, MODEL_SWING, MODEL_SHORT_TERM, MODEL_OSOK,
            MODEL_DAY_TRADING, MODEL_SCALPING, MODEL_MEGA_TRADE,
            MODEL_STOCK_TRADING, MODEL_BONUS_HUNTER
        };
        
        for(int m = 0; m < ArraySize(models); m++) {
            double score = CalculatePriorityScore(m_symbolData[i].symbol, models[m]);
            if(score > 50) {
                int idx = m_rankingCount;
                ArrayResize(m_ranking, m_rankingCount + 1);
                m_ranking[idx].symbol = m_symbolData[i].symbol;
                m_ranking[idx].score = score;
                m_ranking[idx].model = models[m];
                m_ranking[idx].bias = m_symbolData[i].currentBias;
                m_ranking[idx].entryPrice = 0;
                m_ranking[idx].stopLoss = 0;
                m_ranking[idx].takeProfit = 0;
                m_ranking[idx].rrRatio = 0;
                m_ranking[idx].qualityScore = (int)score;
                m_ranking[idx].isValid = true;
                m_rankingCount++;
            }
        }
    }
}

//--- Reportes
string CMultiSymbol::GetSummary() {
    string summary = "=== MULTI-SYMBOL SUMMARY ===\n";
    summary += "Total Symbols: " + IntegerToString(m_symbolCount) + "\n";
    summary += "Active Symbols: " + IntegerToString(m_activeCount) + "\n";
    summary += "Max Concurrent Trades: " + IntegerToString(m_maxConcurrentTrades) + "\n";
    summary += "Max Trades Per Symbol: " + IntegerToString(m_maxTradesPerSymbol) + "\n";
    summary += "Auto Select: " + (m_autoSelectSymbols ? "ENABLED" : "DISABLED") + "\n";
    summary += "Spread Filter: " + (m_useSpreadFilter ? "ENABLED" : "DISABLED") + "\n";
    summary += "ATR Filter: " + (m_useATRFilter ? "ENABLED" : "DISABLED") + "\n";
    summary += "Time Sync: " + (m_syncTimeEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Last Update: " + TimeToString(m_lastUpdate) + "\n";
    summary += "==============================";
    return summary;
}

string CMultiSymbol::GetSymbolReport(string symbol) {
    SymbolData data = GetSymbolData(symbol);
    if(data.symbol == "") return "Symbol not found: " + symbol;
    
    string report = "=== SYMBOL REPORT - " + symbol + " ===\n";
    report += "Active: " + (data.isActive ? "YES" : "NO") + "\n";
    report += "Trading Allowed: " + (data.isTradingAllowed ? "YES" : "NO") + "\n";
    report += "Spread: " + DoubleToString(data.spread, 2) + " pips\n";
    report += "ATR: " + DoubleToString(data.atr, 5) + "\n";
    report += "Bias: " + (data.currentBias == BIAS_BULLISH ? "BULLISH" : 
                          (data.currentBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Active Model: " + EnumToString(data.activeModel) + "\n";
    report += "Order Count: " + IntegerToString(data.orderCount) + "\n";
    report += "PnL: " + DoubleToString(data.pnl, 2) + "\n";
    report += "Win Rate: " + DoubleToString(data.winRate, 1) + "%\n";
    report += "Strength Score: " + DoubleToString(data.strengthScore, 1) + "\n";
    report += "Momentum Score: " + DoubleToString(data.momentumScore, 1) + "\n";
    report += "Seasonal Score: " + DoubleToString(data.seasonalScore, 1) + "\n";
    report += "Macro Score: " + DoubleToString(data.macroScore, 1) + "\n";
    report += "Technical Score: " + DoubleToString(data.technicalScore, 1) + "\n";
    report += "Priority Score: " + DoubleToString(data.priorityScore, 1) + "\n";
    report += "In Watchlist: " + (data.isInWatchlist ? "YES" : "NO") + "\n";
    report += "Last Update: " + TimeToString(data.lastUpdate) + "\n";
    report += "=============================";
    return report;
}

string CMultiSymbol::GetAllSymbolsReport() {
    string report = "=== ALL SYMBOLS REPORT ===\n";
    report += "Total: " + IntegerToString(m_symbolCount) + "\n\n";
    
    for(int i = 0; i < m_symbolCount; i++) {
        report += m_symbolData[i].symbol + " | ";
        report += "Bias: " + (m_symbolData[i].currentBias == BIAS_BULLISH ? "BULL" : 
                              (m_symbolData[i].currentBias == BIAS_BEARISH ? "BEAR" : "NEUT")) + " | ";
        report += "Score: " + DoubleToString(m_symbolData[i].priorityScore, 1) + " | ";
        report += "Active: " + (m_symbolData[i].isActive ? "YES" : "NO") + "\n";
    }
    
    report += "=============================";
    return report;
}

string CMultiSymbol::GetRankingReport(ENUM_TRADING_MODEL model) {
    string report = "=== RANKING REPORT - " + EnumToString(model) + " ===\n";
    
    //--- Recopilar rankings para el modelo
    SymbolRanking temp[];
    int count = 0;
    
    for(int i = 0; i < m_rankingCount; i++) {
        if(m_ranking[i].model == model) {
            ArrayResize(temp, count + 1);
            temp[count] = m_ranking[i];
            count++;
        }
    }
    
    //--- Ordenar por score descendente
    for(int i = 0; i < count - 1; i++) {
        for(int j = i + 1; j < count; j++) {
            if(temp[i].score < temp[j].score) {
                SymbolRanking swap = temp[i];
                temp[i] = temp[j];
                temp[j] = swap;
            }
        }
    }
    
    for(int i = 0; i < MathMin(count, 10); i++) {
        report += IntegerToString(i + 1) + ". " + temp[i].symbol + " | ";
        report += "Score: " + DoubleToString(temp[i].score, 1) + " | ";
        report += "Bias: " + (temp[i].bias == BIAS_BULLISH ? "BULL" : 
                              (temp[i].bias == BIAS_BEARISH ? "BEAR" : "NEUT")) + "\n";
    }
    
    if(count == 0) {
        report += "No symbols ranked for this model\n";
    }
    
    report += "=============================";
    return report;
}

string CMultiSymbol::GetWatchlistReport() {
    string report = "=== WATCHLIST REPORT ===\n";
    report += "Total: " + IntegerToString(m_activeCount) + "\n\n";
    
    for(int i = 0; i < m_activeCount; i++) {
        string symbol = m_activeSymbols[i];
        report += IntegerToString(i + 1) + ". " + symbol;
        
        int idx = FindSymbolIndex(symbol);
        if(idx != -1) {
            report += " | Bias: " + (m_symbolData[idx].currentBias == BIAS_BULLISH ? "BULL" : 
                                     (m_symbolData[idx].currentBias == BIAS_BEARISH ? "BEAR" : "NEUT"));
            report += " | Trades: " + IntegerToString(m_symbolData[idx].orderCount);
        }
        report += "\n";
    }
    
    report += "=============================";
    return report;
}

string CMultiSymbol::GetStatusReport() {
    string report = "=== STATUS REPORT ===\n";
    report += "Initialized: " + (m_isInitialized ? "YES" : "NO") + "\n";
    report += "Symbols Loaded: " + IntegerToString(m_symbolCount) + "\n";
    report += "Active Symbols: " + IntegerToString(m_activeCount) + "\n";
    report += "Rankings: " + IntegerToString(m_rankingCount) + "\n";
    report += "Last Update: " + (m_lastUpdate > 0 ? TimeToString(m_lastUpdate) : "NEVER") + "\n";
    report += "=========================";
    return report;
}

#endif // __CMULTISYMBOL_MQH__