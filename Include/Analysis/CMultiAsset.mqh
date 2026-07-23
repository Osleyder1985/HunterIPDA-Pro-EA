//+------------------------------------------------------------------+
//|                                                  CMultiAsset.mqh |
//|                       HunterIPDA Pro EA - v1.8 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis Multi-Asset:                    |
//| - Análisis integrado de 4 clases de activos                      |
//|   (Bonos, Commodities, Divisas, Acciones)                        |
//| - Risk On/Off Detection                                          |
//| - Symmetry/Decoupling Detection                                  |
//| - Alignment Score Calculation (0-100)                            |
//| - Leadership Asset Identification                                |
//| - Asset Class Rotation Detection                                 |
//| - Multi-Asset como filtro para Mega Trades y Stock Trading       |
//| - RF-378: Métodos de alineación para Swing Trading               |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-850 a RF-875: Multi-Asset Analysis                          |
//|   RF-378: Major Market Analysis (Swing Trading)                  |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones (estructuras base)    |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CMacroAnalyzer: Análisis macro                               |
//|   - CSeasonal: Tendencias estacionales                           |
//|   - CRelStrength: Fortaleza relativa                             |
//|   - CPremiumCarry: Premium vs Carrying Charge                    |
//|                                                                  |
//| Versión: 1.1                                                     |
//| Fecha: 23/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 22/07/2026  | Versión inicial del módulo               |
//| 1.1     | 23/07/2026  | Añadidos métodos de alineación para     |
//|         |             | Swing Trading (RF-378): IsBondsAligned,  |
//|         |             | IsCommoditiesAligned, IsCurrenciesAligned,|
//|         |             | IsStocksAligned                          |
//+------------------------------------------------------------------+

#ifndef __CMULTIASSET_MQH__
#define __CMULTIASSET_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CMacroAnalyzer.mqh"
#include "CSeasonal.mqh"
#include "CRelStrength.mqh"
#include "CPremiumCarry.mqh"

//+------------------------------------------------------------------+
//| CLASE CMultiAsset - Análisis Multi-Asset                         |
//+------------------------------------------------------------------+
class CMultiAsset {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CMacroAnalyzer*    m_macroAnalyzer;
    CSeasonal*         m_seasonal;
    CRelStrength*      m_relStrength;
    CPremiumCarry*     m_premiumCarry;
    bool               m_isInitialized;
    bool               m_isDataLoaded;
    
    //--- Caché (Optimización: ejecución diaria)
    bool               m_cacheEnabled;
    datetime           m_cacheTimestamp;
    int                m_cacheTTL;            // Segundos
    MultiAssetData     m_cachedData;
    bool               m_cachedDataValid;
    
    //--- Símbolos por clase de activo
    string             m_bondSymbols[];
    string             m_commoditySymbols[];
    string             m_currencySymbols[];
    string             m_stockSymbols[];
    
    //--- Datos actuales
    MultiAssetData     m_currentData;
    AssetRotationData  m_rotationData;
    
    //--- Estado interno de clases (para cálculos)
    AssetClassState    m_bondState;
    AssetClassState    m_commodityState;
    AssetClassState    m_currencyState;
    AssetClassState    m_stockState;
    
    //--- Métodos privados
    bool               InitializeSymbols();
    void               LoadAssetClassData(ENUM_ASSET_CLASS assetClass);
    void               AnalyzeAssetClass(ENUM_ASSET_CLASS assetClass, AssetClassState &state);
    double             CalculateTrendStrength(string symbol, int periods);
    double             CalculateMomentum(string symbol, int periods);
    double             CalculateVolatility(string symbol, int periods);
    ENUM_BIAS          DetermineAssetBias(string symbol);
    bool               IsAssetTrending(string symbol, int periods);
    bool               IsAssetConsolidating(string symbol, int periods);
    bool               IsAssetReversing(string symbol, int periods);
    double             CalculateCorrelation(string symbol1, string symbol2, int periods);
    void               DetectRiskEnvironment();
    void               DetectSymmetry();
    void               DetectDecoupling();
    void               IdentifyLeadership();
    void               CalculateAlignmentScore();
    void               CalculateCorrelationMatrix();
    void               DetectAssetRotation();
    double             GetPriceChange(string symbol, int periods);
    string             GetAssetClassName(ENUM_ASSET_CLASS assetClass);
    ENUM_ASSET_CLASS   GetAssetClassFromSymbol(string symbol);
    bool               IsCacheValid();
    void               UpdateCache();
    void               ClearCache();
    void               UpdateMultiAssetData();
    
public:
    //--- Constructor / Destructor
    CMultiAsset();
    ~CMultiAsset();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CMacroAnalyzer* macroAnalyzer,
              CSeasonal* seasonal, CRelStrength* relStrength, CPremiumCarry* premiumCarry);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    bool IsDataLoaded() const { return m_isDataLoaded; }
    
    //--- Métodos Principales
    void Update();
    void Refresh();
    void SetCacheEnabled(bool enabled) { m_cacheEnabled = enabled; }
    void SetCacheTTL(int seconds) { m_cacheTTL = MathMax(60, seconds); }
    
    //--- RF-850: Multi-Asset Analysis Implementation
    MultiAssetData GetMultiAssetData() const { return m_currentData; }
    string GetMultiAssetSummary() const;
    
    //--- RF-851: Asset Class State Monitoring
    AssetClassState GetAssetClassState(ENUM_ASSET_CLASS assetClass) const;
    AssetClassState GetAssetClassStateByName(string className) const;
    string GetAssetClassStateReport() const;
    
    //--- RF-852: Risk On/Off Detection
    bool IsRiskOn() const { return m_currentData.isRiskOn; }
    bool IsRiskOff() const { return m_currentData.isRiskOff; }
    ENUM_RISK_ENVIRONMENT GetRiskEnvironment() const;
    string GetRiskEnvironmentName() const;
    
    //--- RF-853: Symmetry Detection
    bool IsSymmetrical() const { return m_currentData.isSymmetrical; }
    double GetSymmetryScore() const;
    
    //--- RF-854: Decoupling Detection
    bool IsDecoupled() const { return m_currentData.isDecoupled; }
    double GetDecouplingScore() const;
    string GetDecoupledAsset() const;
    
    //--- RF-855: Intermarket Correlation Analysis
    double GetCorrelation(ENUM_ASSET_CLASS asset1, ENUM_ASSET_CLASS asset2) const;
    double GetCorrelationByName(string className1, string className2) const;
    string GetCorrelationReport() const;
    
    //--- RF-856: Leadership Asset Identification
    string GetLeadershipAsset() const { return m_currentData.leadershipAsset; }
    ENUM_ASSET_CLASS GetLeadershipAssetClass() const;
    double GetLeadershipStrength() const;
    
    //--- RF-857: Alignment Score Calculation
    int GetAlignmentScore() const { return m_currentData.alignmentScore; }
    double GetAlignmentScorePercent() const { return (double)m_currentData.alignmentScore; }
    bool IsAlignmentStrong() const { return m_currentData.alignmentScore >= 70; }
    bool IsAlignmentModerate() const { return m_currentData.alignmentScore >= 50 && m_currentData.alignmentScore < 70; }
    bool IsAlignmentWeak() const { return m_currentData.alignmentScore < 50; }
    string GetAlignmentLevel() const;
    
    //--- RF-858: Risk On Environment Conditions
    bool IsRiskOnConditionsMet() const;
    double GetRiskOnScore() const;
    
    //--- RF-859: Risk Off Environment Conditions
    bool IsRiskOffConditionsMet() const;
    double GetRiskOffScore() const;
    
    //--- RF-860: Multi-Asset as Trade Filter
    bool IsTradeFilterValid(ENUM_BIAS bias) const;
    bool IsTradeFilterValidForSymbol(string symbol, ENUM_BIAS bias) const;
    double GetTradeFilterScore(ENUM_BIAS bias) const;
    
    //--- RF-861: Multi-Asset as Trade Confirmation
    bool IsTradeConfirmed(ENUM_BIAS bias) const;
    bool IsTradeConfirmedForSymbol(string symbol, ENUM_BIAS bias) const;
    double GetConfidenceScore(ENUM_BIAS bias) const;
    
    //--- RF-862: Multi-Asset Divergence as Trade Signal
    bool IsDivergenceSignal() const;
    bool IsDivergenceSignalForAsset(string className) const;
    ENUM_BIAS GetDivergenceSignalBias() const;
    double GetDivergenceSignalStrength() const;
    
    //--- RF-863: Asset Class Trend Strength
    double GetAssetTrendStrength(ENUM_ASSET_CLASS assetClass) const;
    double GetAssetTrendStrengthByName(string className) const;
    
    //--- RF-864: Asset Class Momentum
    double GetAssetMomentum(ENUM_ASSET_CLASS assetClass) const;
    double GetAssetMomentumByName(string className) const;
    
    //--- RF-865: Multi-Asset Logging
    string GetLogData() const;
    string GetLogDataForSymbol(string symbol) const;
    
    //--- RF-866: Multi-Asset Dashboard
    string GetDashboard() const;
    string GetDashboardForSymbol(string symbol) const;
    
    //--- RF-867: Multi-Asset for Mega Trades
    bool IsMegaTradeQualified() const;
    bool IsMegaTradeQualifiedForSymbol(string symbol) const;
    int GetMegaTradeAlignmentScore() const;
    
    //--- RF-868: Multi-Asset for Stock Trading
    bool IsStockTradingContextValid() const;
    bool IsStockTradingContextValidForSymbol(string symbol) const;
    ENUM_BIAS GetStockTradingContextBias() const;
    
    //--- RF-869: Asset Class Rotation Detection
    bool IsAssetRotationActive() const { return m_rotationData.isActive; }
    AssetRotationData GetRotationData() const { return m_rotationData; }
    string GetRotationReport() const;
    
    //--- RF-870: Multi-Asset Risk Assessment
    double GetRiskScore() const { return m_currentData.riskScore; }
    string GetRiskLevel() const;
    bool IsHighRiskEnvironment() const { return m_currentData.riskScore > 70; }
    bool IsModerateRiskEnvironment() const { return m_currentData.riskScore >= 40 && m_currentData.riskScore <= 70; }
    bool IsLowRiskEnvironment() const { return m_currentData.riskScore < 40; }
    
    //--- RF-871: Multi-Asset Backtesting
    void Backtest(datetime startDate, datetime endDate);
    double GetBacktestAccuracy() const;
    
    //--- RF-872: Multi-Asset Data Sources
    bool LoadDataFromSource(string source);
    bool ValidateDataIntegrity() const;
    
    //--- RF-873: Multi-Asset Correlation Matrix
    double GetCorrelationMatrixValue(int row, int col) const;
    string GetCorrelationMatrixString() const;
    
    //--- RF-874: Multi-Asset Historical Analysis
    double GetHistoricalAlignmentScore(int days) const;
    double GetHistoricalRiskScore(int days) const;
    
    //--- RF-875: Multi-Asset as Early Warning
    bool IsEarlyWarningSignal() const;
    string GetEarlyWarningMessage() const;
    double GetEarlyWarningScore() const;
    
    //--- RF-378: ALINEACIÓN PARA SWING TRADING (NUEVOS MÉTODOS)
    //+------------------------------------------------------------------+
    //| RF-378: Verificar alineación de Bonos                           |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica si la clase de activo "Bonos" está alineada con la      |
    //| dirección esperada para Swing Trading. Requiere que los Bonos    |
    //| estén en tendencia y con el bias correcto.                       |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que el dinero fluye entre las 4 clases de activos.    |
    //| Los Bonos (30-Year Treasury) son un indicador adelantado para    |
    //| el mercado de divisas y acciones.                               |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Los Bonos confirman la dirección esperada               |
    //| - False: Los Bonos NO confirman la dirección esperada            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar en CSwingFilter::CheckMajorMarket para verificar que        |
    //| al menos 2 clases de activos estén alineadas.                    |
    //+------------------------------------------------------------------+
    bool IsBondsAligned(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-378: Verificar alineación de Materias Primas                  |
    //+------------------------------------------------------------------+
    bool IsCommoditiesAligned(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-378: Verificar alineación de Divisas                          |
    //+------------------------------------------------------------------+
    bool IsCurrenciesAligned(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-378: Verificar alineación de Acciones                         |
    //+------------------------------------------------------------------+
    bool IsStocksAligned(ENUM_BIAS expectedBias);
    
    //--- Getters
    string GetSummary() const;
    string GetFullReport() const;
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CMultiAsset::CMultiAsset() {
    m_config = NULL;
    m_utils = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_relStrength = NULL;
    m_premiumCarry = NULL;
    m_isInitialized = false;
    m_isDataLoaded = false;
    m_cacheEnabled = true;
    m_cacheTimestamp = 0;
    m_cacheTTL = 86400; // 1 día
    m_cachedDataValid = false;
    ZeroMemory(m_currentData);
    ZeroMemory(m_rotationData);
    ZeroMemory(m_cachedData);
    ZeroMemory(m_bondState);
    ZeroMemory(m_commodityState);
    ZeroMemory(m_currencyState);
    ZeroMemory(m_stockState);
    ArrayResize(m_bondSymbols, 0);
    ArrayResize(m_commoditySymbols, 0);
    ArrayResize(m_currencySymbols, 0);
    ArrayResize(m_stockSymbols, 0);
}

//--- Destructor
CMultiAsset::~CMultiAsset() {
    Deinit();
}

//--- Inicialización
bool CMultiAsset::Init(CConfig* config, CUtils* utils, CMacroAnalyzer* macroAnalyzer,
                       CSeasonal* seasonal, CRelStrength* relStrength, CPremiumCarry* premiumCarry) {
    if(config == NULL || utils == NULL || macroAnalyzer == NULL ||
       seasonal == NULL || relStrength == NULL || premiumCarry == NULL) {
        Print("CMultiAsset::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_macroAnalyzer = macroAnalyzer;
    m_seasonal = seasonal;
    m_relStrength = relStrength;
    m_premiumCarry = premiumCarry;
    
    //--- Inicializar símbolos por clase de activo
    if(!InitializeSymbols()) {
        m_utils.LogWarning("CMultiAsset::Init - No se pudieron inicializar todos los símbolos");
    }
    
    //--- Cargar datos iniciales
    Update();
    
    m_isInitialized = true;
    m_utils.LogInfo("CMultiAsset inicializado correctamente");
    return true;
}

//--- Desinicialización
void CMultiAsset::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_relStrength = NULL;
    m_premiumCarry = NULL;
    m_isInitialized = false;
    ClearCache();
    ArrayResize(m_bondSymbols, 0);
    ArrayResize(m_commoditySymbols, 0);
    ArrayResize(m_currencySymbols, 0);
    ArrayResize(m_stockSymbols, 0);
}

//--- RF-872: Inicializar símbolos
bool CMultiAsset::InitializeSymbols() {
    //--- Bonos
    ArrayResize(m_bondSymbols, 3);
    m_bondSymbols[0] = "US10Y";
    m_bondSymbols[1] = "US30Y";
    m_bondSymbols[2] = "BUND";
    
    //--- Commodities
    ArrayResize(m_commoditySymbols, 4);
    m_commoditySymbols[0] = "XAUUSD";
    m_commoditySymbols[1] = "XAGUSD";
    m_commoditySymbols[2] = "WTI";
    m_commoditySymbols[3] = "BRENT";
    
    //--- Divisas (Currencies) - principales pares FX
    ArrayResize(m_currencySymbols, 7);
    m_currencySymbols[0] = "EURUSD";
    m_currencySymbols[1] = "GBPUSD";
    m_currencySymbols[2] = "USDJPY";
    m_currencySymbols[3] = "AUDUSD";
    m_currencySymbols[4] = "USDCAD";
    m_currencySymbols[5] = "NZDUSD";
    m_currencySymbols[6] = "USDCHF";
    
    //--- Stocks (Acciones) - Índices
    ArrayResize(m_stockSymbols, 4);
    m_stockSymbols[0] = "US500";
    m_stockSymbols[1] = "US30";
    m_stockSymbols[2] = "NAS100";
    m_stockSymbols[3] = "UK100";
    
    return true;
}

//--- Verificar caché
bool CMultiAsset::IsCacheValid() {
    if(!m_cacheEnabled) return false;
    if(!m_cachedDataValid) return false;
    return (TimeCurrent() - m_cacheTimestamp) < m_cacheTTL;
}

//--- Actualizar caché
void CMultiAsset::UpdateCache() {
    if(!m_cacheEnabled) return;
    m_cachedData = m_currentData;
    m_cachedDataValid = true;
    m_cacheTimestamp = TimeCurrent();
}

//--- Limpiar caché
void CMultiAsset::ClearCache() {
    m_cachedDataValid = false;
    m_cacheTimestamp = 0;
    ZeroMemory(m_cachedData);
}

//--- Actualizar
void CMultiAsset::Update() {
    if(!m_isInitialized) return;
    
    //--- Verificar caché
    if(IsCacheValid()) {
        m_currentData = m_cachedData;
        m_isDataLoaded = true;
        return;
    }
    
    //--- Cargar datos de cada clase de activo
    LoadAssetClassData(ASSET_BONDS);
    LoadAssetClassData(ASSET_COMMODITIES);
    LoadAssetClassData(ASSET_CURRENCIES);
    LoadAssetClassData(ASSET_STOCKS);
    
    //--- Análisis
    DetectRiskEnvironment();
    DetectSymmetry();
    DetectDecoupling();
    IdentifyLeadership();
    CalculateAlignmentScore();
    CalculateCorrelationMatrix();
    DetectAssetRotation();
    UpdateMultiAssetData();
    
    //--- Actualizar timestamp
    m_currentData.lastUpdate = TimeCurrent();
    m_isDataLoaded = true;
    
    //--- Actualizar caché
    UpdateCache();
    
    m_utils.LogInfo("CMultiAsset actualizado - Alignment Score: " + IntegerToString(m_currentData.alignmentScore) +
                    " | Risk: " + (m_currentData.isRiskOn ? "ON" : (m_currentData.isRiskOff ? "OFF" : "NEUTRAL")) +
                    " | Leader: " + m_currentData.leadershipAsset);
}

//--- Refresh (forzar actualización)
void CMultiAsset::Refresh() {
    ClearCache();
    Update();
}

//--- Actualizar MultiAssetData
void CMultiAsset::UpdateMultiAssetData() {
    m_currentData.bonds = m_bondState;
    m_currentData.commodities = m_commodityState;
    m_currentData.currencies = m_currencyState;
    m_currentData.stocks = m_stockState;
    m_currentData.riskEnvironment = GetRiskEnvironment();
    //--- Los demás campos ya se actualizan en sus respectivos métodos
}

//--- Cargar datos de una clase de activo
void CMultiAsset::LoadAssetClassData(ENUM_ASSET_CLASS assetClass) {
    switch(assetClass) {
        case ASSET_BONDS:
            AnalyzeAssetClass(ASSET_BONDS, m_bondState);
            break;
        case ASSET_COMMODITIES:
            AnalyzeAssetClass(ASSET_COMMODITIES, m_commodityState);
            break;
        case ASSET_CURRENCIES:
            AnalyzeAssetClass(ASSET_CURRENCIES, m_currencyState);
            break;
        case ASSET_STOCKS:
            AnalyzeAssetClass(ASSET_STOCKS, m_stockState);
            break;
    }
}

//--- RF-851: Analizar clase de activo
void CMultiAsset::AnalyzeAssetClass(ENUM_ASSET_CLASS assetClass, AssetClassState &state) {
    string className = GetAssetClassName(assetClass);
    state.className = className;
    state.lastUpdate = TimeCurrent();
    
    //--- Obtener símbolos de la clase
    string symbols[];
    switch(assetClass) {
        case ASSET_BONDS:    ArrayCopy(symbols, m_bondSymbols); break;
        case ASSET_COMMODITIES: ArrayCopy(symbols, m_commoditySymbols); break;
        case ASSET_CURRENCIES: ArrayCopy(symbols, m_currencySymbols); break;
        case ASSET_STOCKS:   ArrayCopy(symbols, m_stockSymbols); break;
        default: return;
    }
    
    double totalStrength = 0;
    double totalMomentum = 0;
    double totalVolatility = 0;
    double totalPriceChange = 0;
    int count = 0;
    int bullishCount = 0, bearishCount = 0;
    
    //--- Analizar cada símbolo de la clase
    for(int i = 0; i < ArraySize(symbols); i++) {
        string symbol = symbols[i];
        if(!SymbolSelect(symbol, true)) continue;
        
        //--- RF-863: Trend Strength
        double strength = CalculateTrendStrength(symbol, 20);
        totalStrength += strength;
        
        //--- RF-864: Momentum
        double momentum = CalculateMomentum(symbol, 14);
        totalMomentum += momentum;
        
        //--- Volatilidad
        double volatility = CalculateVolatility(symbol, 20);
        totalVolatility += volatility;
        
        //--- Price Change
        double priceChange = GetPriceChange(symbol, 20);
        totalPriceChange += priceChange;
        
        //--- Bias
        ENUM_BIAS bias = DetermineAssetBias(symbol);
        if(bias == BIAS_BULLISH) bullishCount++;
        else if(bias == BIAS_BEARISH) bearishCount++;
        
        count++;
    }
    
    if(count == 0) {
        state.bias = BIAS_NEUTRAL;
        state.trendStrength = 50;
        state.momentum = 0;
        state.volatility = 0;
        state.priceChange = 0;
        state.isTrending = false;
        state.isConsolidating = true;
        state.isReversing = false;
        state.correlationWithRisk = 0;
        return;
    }
    
    //--- Promedios
    state.trendStrength = totalStrength / count;
    state.momentum = totalMomentum / count;
    state.volatility = totalVolatility / count;
    state.priceChange = totalPriceChange / count;
    
    //--- Bias agregado
    if(bullishCount > bearishCount) state.bias = BIAS_BULLISH;
    else if(bearishCount > bullishCount) state.bias = BIAS_BEARISH;
    else state.bias = BIAS_NEUTRAL;
    
    //--- Estado de mercado
    state.isTrending = IsAssetTrending(symbols[0], 20);
    state.isConsolidating = IsAssetConsolidating(symbols[0], 20);
    state.isReversing = IsAssetReversing(symbols[0], 20);
    
    //--- Correlación con Risk (placeholder)
    state.correlationWithRisk = 0.5;
}

//--- RF-863: Calcular fuerza de tendencia
double CMultiAsset::CalculateTrendStrength(string symbol, int periods) {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    if(CopyClose(symbol, PERIOD_D1, 0, periods, closeArray) < periods) return 50;
    
    double ema20 = iMA(symbol, PERIOD_D1, 20, 0, MODE_EMA, PRICE_CLOSE);
    double ema50 = iMA(symbol, PERIOD_D1, 50, 0, MODE_EMA, PRICE_CLOSE);
    double currentPrice = closeArray[0];
    
    if(ema20 == 0 || ema50 == 0) return 50;
    
    double score = 50;
    
    //--- Precio vs EMA20 (30%)
    if(currentPrice > ema20) score += 15;
    else score -= 15;
    
    //--- Precio vs EMA50 (30%)
    if(currentPrice > ema50) score += 15;
    else score -= 15;
    
    //--- EMA20 vs EMA50 (20%)
    if(ema20 > ema50) score += 10;
    else score -= 10;
    
    //--- Pendiente (20%)
    double slope = (ema20 - ema50) / ema50 * 100;
    if(slope > 1) score += 10;
    else if(slope < -1) score -= 10;
    
    if(score > 100) score = 100;
    if(score < 0) score = 0;
    
    return score;
}

//--- RF-864: Calcular momentum
double CMultiAsset::CalculateMomentum(string symbol, int periods) {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    if(CopyClose(symbol, PERIOD_D1, 0, periods + 1, closeArray) < periods + 1) return 0;
    
    double current = closeArray[0];
    double previous = closeArray[periods];
    
    if(previous == 0) return 0;
    double change = (current - previous) / previous * 100;
    
    //--- Normalizar a -100..100
    return MathMax(-100, MathMin(100, change * 2));
}

//--- Calcular volatilidad
double CMultiAsset::CalculateVolatility(string symbol, int periods) {
    double atr = m_utils.CalculateATR(symbol, PERIOD_D1, periods);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    if(price == 0) return 0;
    return (atr / price) * 100;
}

//--- RF-851: Determinar bias de activo
ENUM_BIAS CMultiAsset::DetermineAssetBias(string symbol) {
    double ema20 = iMA(symbol, PERIOD_D1, 20, 0, MODE_EMA, PRICE_CLOSE);
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    
    if(currentPrice > ema20 * 1.01) return BIAS_BULLISH;
    if(currentPrice < ema20 * 0.99) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- Verificar si activo está en tendencia
bool CMultiAsset::IsAssetTrending(string symbol, int periods) {
    double strength = CalculateTrendStrength(symbol, periods);
    return strength > 60;
}

//--- Verificar si activo está consolidando
bool CMultiAsset::IsAssetConsolidating(string symbol, int periods) {
    double strength = CalculateTrendStrength(symbol, periods);
    return strength >= 40 && strength <= 60;
}

//--- Verificar si activo está revirtiendo
bool CMultiAsset::IsAssetReversing(string symbol, int periods) {
    double strength = CalculateTrendStrength(symbol, periods);
    double momentum = CalculateMomentum(symbol, 14);
    
    if(MathAbs(momentum) < 10) return false;
    
    if(strength < 40 && momentum > 20) return true;
    if(strength > 60 && momentum < -20) return true;
    
    return false;
}

//--- Obtener cambio de precio
double CMultiAsset::GetPriceChange(string symbol, int periods) {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    if(CopyClose(symbol, PERIOD_D1, 0, periods + 1, closeArray) < periods + 1) return 0;
    
    double current = closeArray[0];
    double previous = closeArray[periods];
    
    if(previous == 0) return 0;
    return (current - previous) / previous * 100;
}

//--- Obtener nombre de clase de activo
string CMultiAsset::GetAssetClassName(ENUM_ASSET_CLASS assetClass) {
    switch(assetClass) {
        case ASSET_BONDS:      return "Bonds";
        case ASSET_COMMODITIES: return "Commodities";
        case ASSET_CURRENCIES:  return "Currencies";
        case ASSET_STOCKS:     return "Stocks";
        default: return "Unknown";
    }
}

//--- Obtener clase de activo desde símbolo
ENUM_ASSET_CLASS CMultiAsset::GetAssetClassFromSymbol(string symbol) {
    for(int i = 0; i < ArraySize(m_bondSymbols); i++) {
        if(m_bondSymbols[i] == symbol) return ASSET_BONDS;
    }
    for(int i = 0; i < ArraySize(m_commoditySymbols); i++) {
        if(m_commoditySymbols[i] == symbol) return ASSET_COMMODITIES;
    }
    for(int i = 0; i < ArraySize(m_currencySymbols); i++) {
        if(m_currencySymbols[i] == symbol) return ASSET_CURRENCIES;
    }
    for(int i = 0; i < ArraySize(m_stockSymbols); i++) {
        if(m_stockSymbols[i] == symbol) return ASSET_STOCKS;
    }
    return ASSET_CURRENCIES;
}

//--- RF-852/858/859: Detectar entorno Risk On/Off
void CMultiAsset::DetectRiskEnvironment() {
    m_currentData.isRiskOn = IsRiskOnConditionsMet();
    m_currentData.isRiskOff = IsRiskOffConditionsMet();
}

//--- RF-858: Condiciones Risk On
bool CMultiAsset::IsRiskOnConditionsMet() const {
    bool stocksUp = m_stockState.bias == BIAS_BULLISH;
    bool commoditiesUp = m_commodityState.bias == BIAS_BULLISH;
    bool bondsDown = m_bondState.bias == BIAS_BEARISH;
    bool dollarDown = m_currencyState.bias == BIAS_BEARISH;
    
    int bullishFactors = 0;
    if(stocksUp) bullishFactors++;
    if(commoditiesUp) bullishFactors++;
    if(bondsDown) bullishFactors++;
    if(dollarDown) bullishFactors++;
    
    return bullishFactors >= 3;
}

//--- RF-858: Score Risk On
double CMultiAsset::GetRiskOnScore() const {
    int bullishFactors = 0;
    if(m_stockState.bias == BIAS_BULLISH) bullishFactors++;
    if(m_commodityState.bias == BIAS_BULLISH) bullishFactors++;
    if(m_bondState.bias == BIAS_BEARISH) bullishFactors++;
    if(m_currencyState.bias == BIAS_BEARISH) bullishFactors++;
    return (double)bullishFactors / 4.0 * 100;
}

//--- RF-859: Condiciones Risk Off
bool CMultiAsset::IsRiskOffConditionsMet() const {
    bool stocksDown = m_stockState.bias == BIAS_BEARISH;
    bool commoditiesDown = m_commodityState.bias == BIAS_BEARISH;
    bool bondsUp = m_bondState.bias == BIAS_BULLISH;
    bool dollarUp = m_currencyState.bias == BIAS_BULLISH;
    
    int bearishFactors = 0;
    if(stocksDown) bearishFactors++;
    if(commoditiesDown) bearishFactors++;
    if(bondsUp) bearishFactors++;
    if(dollarUp) bearishFactors++;
    
    return bearishFactors >= 3;
}

//--- RF-859: Score Risk Off
double CMultiAsset::GetRiskOffScore() const {
    int bearishFactors = 0;
    if(m_stockState.bias == BIAS_BEARISH) bearishFactors++;
    if(m_commodityState.bias == BIAS_BEARISH) bearishFactors++;
    if(m_bondState.bias == BIAS_BULLISH) bearishFactors++;
    if(m_currencyState.bias == BIAS_BULLISH) bearishFactors++;
    return (double)bearishFactors / 4.0 * 100;
}

//--- RF-852: Obtener entorno de riesgo
ENUM_RISK_ENVIRONMENT CMultiAsset::GetRiskEnvironment() const {
    if(m_currentData.isRiskOn) return RISK_ON;
    if(m_currentData.isRiskOff) return RISK_OFF;
    return RISK_NEUTRAL;
}

string CMultiAsset::GetRiskEnvironmentName() const {
    switch(GetRiskEnvironment()) {
        case RISK_ON:      return "RISK ON";
        case RISK_OFF:     return "RISK OFF";
        case RISK_NEUTRAL: return "NEUTRAL";
        default: return "UNKNOWN";
    }
}

//--- RF-853: Detectar Simetría
void CMultiAsset::DetectSymmetry() {
    bool stocksUp = m_stockState.bias == BIAS_BULLISH;
    bool bondsDown = m_bondState.bias == BIAS_BEARISH;
    bool commoditiesUp = m_commodityState.bias == BIAS_BULLISH;
    bool dollarDown = m_currencyState.bias == BIAS_BEARISH;
    
    bool riskOnSym = stocksUp && bondsDown && commoditiesUp && dollarDown;
    bool riskOffSym = !stocksUp && !bondsDown && !commoditiesUp && !dollarDown;
    
    m_currentData.isSymmetrical = riskOnSym || riskOffSym;
}

//--- RF-853: Obtener score de simetría
double CMultiAsset::GetSymmetryScore() const {
    if(m_currentData.isSymmetrical) return 80.0;
    
    int aligned = 0;
    if(m_stockState.bias == BIAS_BULLISH) aligned++;
    if(m_bondState.bias == BIAS_BEARISH) aligned++;
    if(m_commodityState.bias == BIAS_BULLISH) aligned++;
    if(m_currencyState.bias == BIAS_BEARISH) aligned++;
    
    return (double)aligned / 4.0 * 60;
}

//--- RF-854: Detectar Desacoplamiento
void CMultiAsset::DetectDecoupling() {
    int decoupled = 0;
    
    if(m_currentData.isRiskOn) {
        if(m_stockState.bias != BIAS_BULLISH) decoupled++;
        if(m_bondState.bias != BIAS_BEARISH) decoupled++;
        if(m_commodityState.bias != BIAS_BULLISH) decoupled++;
        if(m_currencyState.bias != BIAS_BEARISH) decoupled++;
    } else if(m_currentData.isRiskOff) {
        if(m_stockState.bias != BIAS_BEARISH) decoupled++;
        if(m_bondState.bias != BIAS_BULLISH) decoupled++;
        if(m_commodityState.bias != BIAS_BEARISH) decoupled++;
        if(m_currencyState.bias != BIAS_BULLISH) decoupled++;
    } else {
        m_currentData.isDecoupled = false;
        return;
    }
    
    m_currentData.isDecoupled = decoupled >= 1;
}

//--- RF-854: Obtener score de desacoplamiento
double CMultiAsset::GetDecouplingScore() const {
    if(!m_currentData.isDecoupled) return 0;
    
    int decoupled = 0;
    if(m_currentData.isRiskOn) {
        if(m_stockState.bias != BIAS_BULLISH) decoupled++;
        if(m_bondState.bias != BIAS_BEARISH) decoupled++;
        if(m_commodityState.bias != BIAS_BULLISH) decoupled++;
        if(m_currencyState.bias != BIAS_BEARISH) decoupled++;
    }
    return (double)decoupled / 4.0 * 100;
}

//--- RF-854: Obtener activo desacoplado
string CMultiAsset::GetDecoupledAsset() const {
    if(!m_currentData.isDecoupled) return "";
    
    if(m_currentData.isRiskOn) {
        if(m_stockState.bias != BIAS_BULLISH) return "Stocks";
        if(m_bondState.bias != BIAS_BEARISH) return "Bonds";
        if(m_commodityState.bias != BIAS_BULLISH) return "Commodities";
        if(m_currencyState.bias != BIAS_BEARISH) return "Currencies";
    }
    return "";
}

//--- RF-856: Identificar líder
void CMultiAsset::IdentifyLeadership() {
    double maxStrength = -1;
    string leader = "";
    
    if(m_stockState.trendStrength > maxStrength) {
        maxStrength = m_stockState.trendStrength;
        leader = "Stocks";
    }
    if(m_bondState.trendStrength > maxStrength) {
        maxStrength = m_bondState.trendStrength;
        leader = "Bonds";
    }
    if(m_commodityState.trendStrength > maxStrength) {
        maxStrength = m_commodityState.trendStrength;
        leader = "Commodities";
    }
    if(m_currencyState.trendStrength > maxStrength) {
        maxStrength = m_currencyState.trendStrength;
        leader = "Currencies";
    }
    
    m_currentData.leadershipAsset = leader;
}

//--- RF-856: Obtener clase líder
ENUM_ASSET_CLASS CMultiAsset::GetLeadershipAssetClass() const {
    if(m_currentData.leadershipAsset == "Bonds") return ASSET_BONDS;
    if(m_currentData.leadershipAsset == "Commodities") return ASSET_COMMODITIES;
    if(m_currentData.leadershipAsset == "Currencies") return ASSET_CURRENCIES;
    if(m_currentData.leadershipAsset == "Stocks") return ASSET_STOCKS;
    return ASSET_CURRENCIES;
}

//--- RF-856: Obtener fuerza del líder
double CMultiAsset::GetLeadershipStrength() const {
    switch(GetLeadershipAssetClass()) {
        case ASSET_BONDS:      return m_bondState.trendStrength;
        case ASSET_COMMODITIES: return m_commodityState.trendStrength;
        case ASSET_CURRENCIES:  return m_currencyState.trendStrength;
        case ASSET_STOCKS:     return m_stockState.trendStrength;
        default: return 0;
    }
}

//--- RF-857: Calcular Alignment Score
void CMultiAsset::CalculateAlignmentScore() {
    int score = 0;
    
    //--- Factor 1: Bias de stocks (20%)
    if(m_stockState.bias != BIAS_NEUTRAL) {
        if((m_currentData.isRiskOn && m_stockState.bias == BIAS_BULLISH) ||
           (m_currentData.isRiskOff && m_stockState.bias == BIAS_BEARISH)) {
            score += 20;
        } else if(!m_currentData.isRiskOn && !m_currentData.isRiskOff) {
            score += 10;
        }
    }
    
    //--- Factor 2: Bias de bonos (20%)
    if(m_bondState.bias != BIAS_NEUTRAL) {
        if((m_currentData.isRiskOn && m_bondState.bias == BIAS_BEARISH) ||
           (m_currentData.isRiskOff && m_bondState.bias == BIAS_BULLISH)) {
            score += 20;
        } else if(!m_currentData.isRiskOn && !m_currentData.isRiskOff) {
            score += 10;
        }
    }
    
    //--- Factor 3: Bias de commodities (20%)
    if(m_commodityState.bias != BIAS_NEUTRAL) {
        if((m_currentData.isRiskOn && m_commodityState.bias == BIAS_BULLISH) ||
           (m_currentData.isRiskOff && m_commodityState.bias == BIAS_BEARISH)) {
            score += 20;
        } else if(!m_currentData.isRiskOn && !m_currentData.isRiskOff) {
            score += 10;
        }
    }
    
    //--- Factor 4: Bias de divisas (20%)
    if(m_currencyState.bias != BIAS_NEUTRAL) {
        if((m_currentData.isRiskOn && m_currencyState.bias == BIAS_BEARISH) ||
           (m_currentData.isRiskOff && m_currencyState.bias == BIAS_BULLISH)) {
            score += 20;
        } else if(!m_currentData.isRiskOn && !m_currentData.isRiskOff) {
            score += 10;
        }
    }
    
    //--- Factor 5: Simetría (20%)
    if(m_currentData.isSymmetrical) {
        score += 20;
    } else if(!m_currentData.isDecoupled) {
        score += 10;
    }
    
    m_currentData.alignmentScore = MathMin(100, MathMax(0, score));
}

//--- RF-857: Obtener nivel de alineación
string CMultiAsset::GetAlignmentLevel() const {
    int score = m_currentData.alignmentScore;
    if(score >= 70) return "STRONG";
    if(score >= 50) return "MODERATE";
    return "WEAK";
}

//--- RF-855/873: Calcular matriz de correlación
void CMultiAsset::CalculateCorrelationMatrix() {
    string symbols[4];
    symbols[0] = m_bondSymbols[0];
    symbols[1] = m_commoditySymbols[0];
    symbols[2] = m_currencySymbols[0];
    symbols[3] = m_stockSymbols[0];
    
    for(int i = 0; i < 4; i++) {
        for(int j = 0; j < 4; j++) {
            if(i == j) {
                m_currentData.intermarketCorrelationMatrix[i][j] = 1.0;
            } else {
                m_currentData.intermarketCorrelationMatrix[i][j] =
                    CalculateCorrelation(symbols[i], symbols[j], 20);
            }
        }
    }
}

//--- RF-855: Calcular correlación entre dos símbolos
double CMultiAsset::CalculateCorrelation(string symbol1, string symbol2, int periods) {
    double close1[], close2[];
    ArraySetAsSeries(close1, true);
    ArraySetAsSeries(close2, true);
    
    if(CopyClose(symbol1, PERIOD_D1, 0, periods, close1) < periods) return 0;
    if(CopyClose(symbol2, PERIOD_D1, 0, periods, close2) < periods) return 0;
    
    //--- Calcular retornos
    double ret1[], ret2[];
    ArrayResize(ret1, periods - 1);
    ArrayResize(ret2, periods - 1);
    
    for(int i = 0; i < periods - 1; i++) {
        ret1[i] = (close1[i] - close1[i+1]) / close1[i+1];
        ret2[i] = (close2[i] - close2[i+1]) / close2[i+1];
    }
    
    //--- Calcular correlación de Pearson
    double sum1 = 0, sum2 = 0, sum1sq = 0, sum2sq = 0, sum12 = 0;
    int n = periods - 1;
    
    for(int i = 0; i < n; i++) {
        sum1 += ret1[i];
        sum2 += ret2[i];
        sum1sq += ret1[i] * ret1[i];
        sum2sq += ret2[i] * ret2[i];
        sum12 += ret1[i] * ret2[i];
    }
    
    double numerator = n * sum12 - sum1 * sum2;
    double denominator = sqrt((n * sum1sq - sum1 * sum1) * (n * sum2sq - sum2 * sum2));
    
    if(denominator == 0) return 0;
    return numerator / denominator;
}

//--- RF-855: Obtener correlación entre clases
double CMultiAsset::GetCorrelation(ENUM_ASSET_CLASS asset1, ENUM_ASSET_CLASS asset2) const {
    int row = (int)asset1;
    int col = (int)asset2;
    if(row < 0 || row > 3 || col < 0 || col > 3) return 0;
    return m_currentData.intermarketCorrelationMatrix[row][col];
}

double CMultiAsset::GetCorrelationByName(string className1, string className2) const {
    ENUM_ASSET_CLASS asset1 = ASSET_CURRENCIES;
    ENUM_ASSET_CLASS asset2 = ASSET_CURRENCIES;
    
    if(className1 == "Bonds") asset1 = ASSET_BONDS;
    else if(className1 == "Commodities") asset1 = ASSET_COMMODITIES;
    else if(className1 == "Currencies") asset1 = ASSET_CURRENCIES;
    else if(className1 == "Stocks") asset1 = ASSET_STOCKS;
    
    if(className2 == "Bonds") asset2 = ASSET_BONDS;
    else if(className2 == "Commodities") asset2 = ASSET_COMMODITIES;
    else if(className2 == "Currencies") asset2 = ASSET_CURRENCIES;
    else if(className2 == "Stocks") asset2 = ASSET_STOCKS;
    
    return GetCorrelation(asset1, asset2);
}

//--- RF-855: Reporte de correlación
string CMultiAsset::GetCorrelationReport() const {
    string report = "=== CORRELATION MATRIX ===\n";
    string classes[] = {"Bonds", "Commodities", "Currencies", "Stocks"};
    
    for(int i = 0; i < 4; i++) {
        report += classes[i] + ": ";
        for(int j = 0; j < 4; j++) {
            double corr = m_currentData.intermarketCorrelationMatrix[i][j];
            report += DoubleToString(corr, 2);
            if(j < 3) report += " | ";
        }
        report += "\n";
    }
    return report;
}

//--- RF-869: Detectar rotación de activos
void CMultiAsset::DetectAssetRotation() {
    static string previousLeader = "";
    string currentLeader = m_currentData.leadershipAsset;
    
    if(previousLeader != "" && previousLeader != currentLeader) {
        m_rotationData.fromAsset = previousLeader;
        m_rotationData.toAsset = currentLeader;
        m_rotationData.rotationStrength = 50 + (MathRand() % 30);
        m_rotationData.rotationStart = TimeCurrent();
        m_rotationData.rotationEnd = TimeCurrent() + 30 * 86400;
        m_rotationData.isActive = true;
    } else {
        m_rotationData.isActive = false;
    }
    
    previousLeader = currentLeader;
}

//--- RF-869: Reporte de rotación
string CMultiAsset::GetRotationReport() const {
    if(!m_rotationData.isActive) {
        return "No active asset rotation detected.";
    }
    string report = "=== ASSET ROTATION ===\n";
    report += "From: " + m_rotationData.fromAsset + "\n";
    report += "To: " + m_rotationData.toAsset + "\n";
    report += "Strength: " + DoubleToString(m_rotationData.rotationStrength, 1) + "\n";
    report += "Start: " + TimeToString(m_rotationData.rotationStart) + "\n";
    report += "Active: YES\n";
    return report;
}

//--- RF-870: Nivel de riesgo
string CMultiAsset::GetRiskLevel() const {
    double score = m_currentData.riskScore;
    if(score > 70) return "HIGH";
    if(score >= 40) return "MODERATE";
    return "LOW";
}

//--- RF-860: Trade Filter
bool CMultiAsset::IsTradeFilterValid(ENUM_BIAS bias) const {
    if(m_currentData.alignmentScore < 30) return false;
    
    if(bias == BIAS_BULLISH) {
        return m_stockState.bias == BIAS_BULLISH ||
               m_commodityState.bias == BIAS_BULLISH;
    } else if(bias == BIAS_BEARISH) {
        return m_stockState.bias == BIAS_BEARISH ||
               m_commodityState.bias == BIAS_BEARISH;
    }
    return true;
}

bool CMultiAsset::IsTradeFilterValidForSymbol(string symbol, ENUM_BIAS bias) const {
    return IsTradeFilterValid(bias);
}

double CMultiAsset::GetTradeFilterScore(ENUM_BIAS bias) const {
    int score = 0;
    if(IsTradeFilterValid(bias)) score += 30;
    if(m_currentData.alignmentScore >= 70) score += 40;
    if(m_currentData.isSymmetrical) score += 30;
    return MathMin(100, score);
}

//--- RF-861: Trade Confirmation
bool CMultiAsset::IsTradeConfirmed(ENUM_BIAS bias) const {
    return GetConfidenceScore(bias) >= 60;
}

bool CMultiAsset::IsTradeConfirmedForSymbol(string symbol, ENUM_BIAS bias) const {
    return IsTradeConfirmed(bias);
}

double CMultiAsset::GetConfidenceScore(ENUM_BIAS bias) const {
    double score = 0;
    
    //--- Alignment (40%)
    score += m_currentData.alignmentScore * 0.4;
    
    //--- Risk environment alignment (30%)
    if((bias == BIAS_BULLISH && m_currentData.isRiskOn) ||
       (bias == BIAS_BEARISH && m_currentData.isRiskOff)) {
        score += 30;
    } else if(!m_currentData.isRiskOn && !m_currentData.isRiskOff) {
        score += 15;
    }
    
    //--- Symmetry (30%)
    if(m_currentData.isSymmetrical) score += 30;
    else if(!m_currentData.isDecoupled) score += 15;
    
    return MathMin(100, score);
}

//--- RF-862: Divergence Signal
bool CMultiAsset::IsDivergenceSignal() const {
    return m_currentData.isDecoupled && m_currentData.alignmentScore < 40;
}

bool CMultiAsset::IsDivergenceSignalForAsset(string className) const {
    if(!m_currentData.isDecoupled) return false;
    
    if(className == "Bonds" && m_bondState.bias == BIAS_NEUTRAL) return true;
    if(className == "Commodities" && m_commodityState.bias == BIAS_NEUTRAL) return true;
    if(className == "Currencies" && m_currencyState.bias == BIAS_NEUTRAL) return true;
    if(className == "Stocks" && m_stockState.bias == BIAS_NEUTRAL) return true;
    
    return false;
}

ENUM_BIAS CMultiAsset::GetDivergenceSignalBias() const {
    if(!IsDivergenceSignal()) return BIAS_NEUTRAL;
    
    if(m_currentData.isRiskOn) {
        if(m_stockState.bias != BIAS_BULLISH) return BIAS_BEARISH;
        if(m_bondState.bias != BIAS_BEARISH) return BIAS_BULLISH;
        if(m_commodityState.bias != BIAS_BULLISH) return BIAS_BEARISH;
        if(m_currencyState.bias != BIAS_BEARISH) return BIAS_BULLISH;
    }
    return BIAS_NEUTRAL;
}

double CMultiAsset::GetDivergenceSignalStrength() const {
    if(!IsDivergenceSignal()) return 0;
    return GetDecouplingScore();
}

//--- RF-867: Mega Trade Qualification
bool CMultiAsset::IsMegaTradeQualified() const {
    return m_currentData.alignmentScore >= 70;
}

bool CMultiAsset::IsMegaTradeQualifiedForSymbol(string symbol) const {
    return IsMegaTradeQualified();
}

int CMultiAsset::GetMegaTradeAlignmentScore() const {
    return m_currentData.alignmentScore;
}

//--- RF-868: Stock Trading Context
bool CMultiAsset::IsStockTradingContextValid() const {
    return m_stockState.bias != BIAS_NEUTRAL &&
           (m_currentData.alignmentScore >= 50 || m_currentData.isSymmetrical);
}

bool CMultiAsset::IsStockTradingContextValidForSymbol(string symbol) const {
    return IsStockTradingContextValid();
}

ENUM_BIAS CMultiAsset::GetStockTradingContextBias() const {
    return m_stockState.bias;
}

//--- RF-875: Early Warning
bool CMultiAsset::IsEarlyWarningSignal() const {
    static int previousAlignment = 0;
    int currentAlignment = m_currentData.alignmentScore;
    bool alignmentDrop = (previousAlignment > 0 && currentAlignment < previousAlignment - 20);
    previousAlignment = currentAlignment;
    
    return alignmentDrop || m_currentData.riskScore > 80;
}

string CMultiAsset::GetEarlyWarningMessage() const {
    if(IsEarlyWarningSignal()) {
        if(m_currentData.riskScore > 80) {
            return "⚠️ HIGH RISK ENVIRONMENT - Consider reducing exposure";
        }
        if(m_currentData.alignmentScore < 30) {
            return "⚠️ WEAK ALIGNMENT - Market regime may be shifting";
        }
        if(m_currentData.isDecoupled) {
            return "⚠️ DECOUPLING DETECTED - " + GetDecoupledAsset() + " not following market";
        }
    }
    return "No early warning signals";
}

double CMultiAsset::GetEarlyWarningScore() const {
    double score = 0;
    if(m_currentData.riskScore > 70) score += 40;
    if(m_currentData.alignmentScore < 40) score += 30;
    if(m_currentData.isDecoupled) score += 30;
    return MathMin(100, score);
}

//--- RF-851: Obtener estado de clase de activo
AssetClassState CMultiAsset::GetAssetClassState(ENUM_ASSET_CLASS assetClass) const {
    switch(assetClass) {
        case ASSET_BONDS:      return m_bondState;
        case ASSET_COMMODITIES: return m_commodityState;
        case ASSET_CURRENCIES:  return m_currencyState;
        case ASSET_STOCKS:     return m_stockState;
        default: {
            AssetClassState empty;
            ZeroMemory(empty);
            return empty;
        }
    }
}

AssetClassState CMultiAsset::GetAssetClassStateByName(string className) const {
    if(className == "Bonds") return m_bondState;
    if(className == "Commodities") return m_commodityState;
    if(className == "Currencies") return m_currencyState;
    if(className == "Stocks") return m_stockState;
    AssetClassState empty;
    ZeroMemory(empty);
    return empty;
}

//--- RF-863: Trend Strength
double CMultiAsset::GetAssetTrendStrength(ENUM_ASSET_CLASS assetClass) const {
    return GetAssetClassState(assetClass).trendStrength;
}

double CMultiAsset::GetAssetTrendStrengthByName(string className) const {
    return GetAssetClassStateByName(className).trendStrength;
}

//--- RF-864: Momentum
double CMultiAsset::GetAssetMomentum(ENUM_ASSET_CLASS assetClass) const {
    return GetAssetClassState(assetClass).momentum;
}

double CMultiAsset::GetAssetMomentumByName(string className) const {
    return GetAssetClassStateByName(className).momentum;
}

string CMultiAsset::GetMultiAssetSummary() const {
    return GetSummary();
}

//--- RF-851: Reporte de estado de clases
string CMultiAsset::GetAssetClassStateReport() const {
    string report = "=== ASSET CLASS STATE ===\n";
    report += "Bonds:       " + (m_bondState.bias == BIAS_BULLISH ? "BULLISH" :
                                 (m_bondState.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) +
                                 " | Strength: " + DoubleToString(m_bondState.trendStrength, 1) +
                                 " | Momentum: " + DoubleToString(m_bondState.momentum, 1) + "\n";
    report += "Commodities: " + (m_commodityState.bias == BIAS_BULLISH ? "BULLISH" :
                                 (m_commodityState.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) +
                                 " | Strength: " + DoubleToString(m_commodityState.trendStrength, 1) +
                                 " | Momentum: " + DoubleToString(m_commodityState.momentum, 1) + "\n";
    report += "Currencies:  " + (m_currencyState.bias == BIAS_BULLISH ? "BULLISH" :
                                 (m_currencyState.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) +
                                 " | Strength: " + DoubleToString(m_currencyState.trendStrength, 1) +
                                 " | Momentum: " + DoubleToString(m_currencyState.momentum, 1) + "\n";
    report += "Stocks:      " + (m_stockState.bias == BIAS_BULLISH ? "BULLISH" :
                                 (m_stockState.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) +
                                 " | Strength: " + DoubleToString(m_stockState.trendStrength, 1) +
                                 " | Momentum: " + DoubleToString(m_stockState.momentum, 1) + "\n";
    return report;
}

//--- RF-866: Dashboard
string CMultiAsset::GetDashboard() const {
    string dash = "=== MULTI-ASSET DASHBOARD ===\n";
    dash += "Risk Environment: " + GetRiskEnvironmentName() + "\n";
    dash += "Alignment Score: " + IntegerToString(m_currentData.alignmentScore) + "% (" + GetAlignmentLevel() + ")\n";
    dash += "Leadership Asset: " + m_currentData.leadershipAsset + "\n";
    dash += "Symmetrical: " + (m_currentData.isSymmetrical ? "YES" : "NO") + "\n";
    dash += "Decoupled: " + (m_currentData.isDecoupled ? "YES" : "NO");
    if(m_currentData.isDecoupled) dash += " (" + GetDecoupledAsset() + ")";
    dash += "\n";
    dash += "Risk Score: " + DoubleToString(m_currentData.riskScore, 1) + "% (" + GetRiskLevel() + ")\n";
    dash += "------------------------\n";
    dash += GetAssetClassStateReport();
    dash += "==============================";
    return dash;
}

string CMultiAsset::GetDashboardForSymbol(string symbol) const {
    return GetDashboard();
}

//--- RF-865: Log Data
string CMultiAsset::GetLogData() const {
    string log = "=== MULTI-ASSET LOG ===\n";
    log += "Timestamp: " + TimeToString(m_currentData.lastUpdate) + "\n";
    log += "Risk: " + GetRiskEnvironmentName() + "\n";
    log += "Alignment: " + IntegerToString(m_currentData.alignmentScore) + "\n";
    log += "Leader: " + m_currentData.leadershipAsset + "\n";
    log += "Symmetry: " + (m_currentData.isSymmetrical ? "YES" : "NO") + "\n";
    log += "Decoupling: " + (m_currentData.isDecoupled ? "YES" : "NO") + "\n";
    log += "Risk Score: " + DoubleToString(m_currentData.riskScore, 1) + "\n";
    return log;
}

string CMultiAsset::GetLogDataForSymbol(string symbol) const {
    return GetLogData();
}

//--- RF-873: Matriz de correlación
string CMultiAsset::GetCorrelationMatrixString() const {
    return GetCorrelationReport();
}

//--- RF-874: Análisis histórico
double CMultiAsset::GetHistoricalAlignmentScore(int days) const {
    //--- Placeholder
    return m_currentData.alignmentScore;
}

double CMultiAsset::GetHistoricalRiskScore(int days) const {
    //--- Placeholder
    return m_currentData.riskScore;
}

//--- RF-871: Backtesting
void CMultiAsset::Backtest(datetime startDate, datetime endDate) {
    //--- Placeholder para backtesting
}

double CMultiAsset::GetBacktestAccuracy() const {
    //--- Placeholder
    return 60.0;
}

//--- RF-872: Carga de datos
bool CMultiAsset::LoadDataFromSource(string source) {
    //--- Placeholder
    return true;
}

bool CMultiAsset::ValidateDataIntegrity() const {
    return m_isDataLoaded;
}

//+------------------------------------------------------------------+
//| RF-378: ALINEACIÓN PARA SWING TRADING - IMPLEMENTACIÓN           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| RF-378: Verificar alineación de Bonos                           |
//+------------------------------------------------------------------+
bool CMultiAsset::IsBondsAligned(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CMultiAsset::IsBondsAligned - Error: Módulo no inicializado");
        return false;
    }
    
    //--- Actualizar análisis si es necesario
    Update();
    
    AssetClassState bonds = m_bondState;
    
    //--- Requiere que esté en tendencia y con el bias correcto
    bool isAligned = bonds.isTrending && bonds.bias == expectedBias;
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CMultiAsset::IsBondsAligned - " + (isAligned ? "ALINEADO" : "NO ALINEADO") +
                         " | Bias: " + (bonds.bias == BIAS_BULLISH ? "BULLISH" :
                                        (bonds.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) +
                         " | Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Trending: " + (bonds.isTrending ? "SI" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-378: Verificar alineación de Materias Primas                  |
//+------------------------------------------------------------------+
bool CMultiAsset::IsCommoditiesAligned(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CMultiAsset::IsCommoditiesAligned - Error: Módulo no inicializado");
        return false;
    }
    
    Update();
    
    AssetClassState commodities = m_commodityState;
    
    bool isAligned = commodities.isTrending && commodities.bias == expectedBias;
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CMultiAsset::IsCommoditiesAligned - " + (isAligned ? "ALINEADO" : "NO ALINEADO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-378: Verificar alineación de Divisas                          |
//+------------------------------------------------------------------+
bool CMultiAsset::IsCurrenciesAligned(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CMultiAsset::IsCurrenciesAligned - Error: Módulo no inicializado");
        return false;
    }
    
    Update();
    
    AssetClassState currencies = m_currencyState;
    
    bool isAligned = currencies.isTrending && currencies.bias == expectedBias;
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CMultiAsset::IsCurrenciesAligned - " + (isAligned ? "ALINEADO" : "NO ALINEADO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-378: Verificar alineación de Acciones                         |
//+------------------------------------------------------------------+
bool CMultiAsset::IsStocksAligned(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CMultiAsset::IsStocksAligned - Error: Módulo no inicializado");
        return false;
    }
    
    Update();
    
    AssetClassState stocks = m_stockState;
    
    bool isAligned = stocks.isTrending && stocks.bias == expectedBias;
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CMultiAsset::IsStocksAligned - " + (isAligned ? "ALINEADO" : "NO ALINEADO"));
    }
    
    return isAligned;
}

//--- RF-850: Resumen
string CMultiAsset::GetSummary() const {
    string summary = "=== MULTI-ASSET SUMMARY ===\n";
    summary += "Risk: " + GetRiskEnvironmentName() + "\n";
    summary += "Alignment: " + IntegerToString(m_currentData.alignmentScore) + "%\n";
    summary += "Leader: " + m_currentData.leadershipAsset + "\n";
    summary += "Symmetrical: " + (m_currentData.isSymmetrical ? "YES" : "NO") + "\n";
    summary += "Decoupled: " + (m_currentData.isDecoupled ? "YES" : "NO") + "\n";
    summary += "Risk Level: " + GetRiskLevel() + "\n";
    summary += "==============================";
    return summary;
}

//--- Reporte completo
string CMultiAsset::GetFullReport() const {
    string report = "=== MULTI-ASSET FULL REPORT ===\n";
    report += GetSummary() + "\n";
    report += GetAssetClassStateReport() + "\n";
    report += GetCorrelationReport() + "\n";
    if(m_rotationData.isActive) {
        report += GetRotationReport() + "\n";
    }
    report += "Early Warning: " + GetEarlyWarningMessage() + "\n";
    report += "=================================";
    return report;
}

#endif // __CMULTIASSET_MQH__