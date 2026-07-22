//+------------------------------------------------------------------+
//|                                                     CContext.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis de contexto:                    |
//| - Determinación de bias multi-temporal                           |
//| - Sponsorship institucional                                      |
//| - SMT Divergence                                                 |
//| - Alineación de 7 Factores                                       |
//| - Análisis de estructura de mercado                              |
//| - Macro to Micro                                                 |
//| - Trampas del Market Maker                                       |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-058: Determinación de Bias                                  |
//|   RF-059: Transposición de Niveles                               |
//|   RF-060: Refinamiento de Entradas                               |
//|   RF-061: Identificación de Niveles Institucionales              |
//|   RF-063: Verificación de Sponsorship Institucional              |
//|   RF-083: SMT Divergence                                         |
//|   RF-085: Alineación de 7 Factores                               |
//|   RF-086: Pensamiento Procesal                                   |
//|   RF-103-105: Modelos y Setups                                   |
//|   RF-107: Institutional Order Flow                               |
//|   RF-108: Análisis por Cuerpos de Vela                           |
//|   RF-109: Fund Level Liquidity                                   |
//|   RF-110-111: Mitigation y Breakers                              |
//|   RF-113: Priorización de Niveles de Whales                      |
//|   RF-115-117: Liquidity Runs                                     |
//|   RF-118: Time of Day                                            |
//|   RF-121: Power of 3                                             |
//|   RF-122: Opening Price NY                                       |
//|   RF-123-126: Rango Mensual y OHLC                               |
//|   RF-127-133: Estructura de Mercado                              |
//|   RF-134-140: Macro to Micro                                     |
//|   RF-141-144: Trendlines y Phantoms                              |
//|   RF-145-149: Head and Shoulders                                 |
//|   RF-370-371: Intermarket y COT                                  |
//|   RF-472-477: Short-Term y OSOK                                  |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CMacroAnalyzer: Análisis macro                               |
//|   - CSeasonal: Tendencias estacionales                           |
//|   - CDataRange: IPDA Data Ranges                                 |
//|                                                                  |
//| Versión: 1.0                                                     |
//| Fecha: 21/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 21/07/2026  | Versión inicial del módulo               |
//+------------------------------------------------------------------+

#ifndef __CCONTEXT_MQH__
#define __CCONTEXT_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CMacroAnalyzer.mqh"
#include "CSeasonal.mqh"
#include "CDataRange.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct ContextState {
    ENUM_BIAS        monthlyBias;
    ENUM_BIAS        weeklyBias;
    ENUM_BIAS        dailyBias;
    ENUM_BIAS        h4Bias;
    ENUM_BIAS        h1Bias;
    ENUM_BIAS        overallBias;
    bool             isSponsorshipPresent;
    bool             isSMTDivergence;
    bool             isMarketSymmetry;
    bool             isAsymmetrical;
    double           alignmentScore;
    int              alignedFactors;
    datetime         lastUpdate;
};

struct MarketStructure {
    double           monthlyHigh;
    double           monthlyLow;
    double           weeklyHigh;
    double           weeklyLow;
    double           dailyHigh;
    double           dailyLow;
    double           h4High;
    double           h4Low;
    bool             isUptrend;
    bool             isDowntrend;
    bool             isConsolidation;
    ENUM_BIAS        structureBias;
};

//+------------------------------------------------------------------+
//| CLASE CContext - Analizador de Contexto                          |
//+------------------------------------------------------------------+
class CContext {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CMacroAnalyzer*    m_macroAnalyzer;
    CSeasonal*         m_seasonal;
    CDataRange*        m_dataRange;
    bool               m_isInitialized;
    string             m_symbol;
    
    //--- Estado
    ContextState       m_state;
    MarketStructure    m_marketStructure;
    int                m_minAlignedFactors;
    int                m_osokCounter;
    int                m_osokMaxPerWeek;
    datetime           m_osokWeekStart;
    
    //--- Datos internos
    double             m_nyOpeningPrice;
    datetime           m_nyOpeningTime;
    double             m_fundLevelLiquidityHigh;
    double             m_fundLevelLiquidityLow;
    
    //--- Métodos privados
    void               AnalyzeMonthlyBias();
    void               AnalyzeWeeklyBias();
    void               AnalyzeDailyBias();
    void               AnalyzeH4Bias();
    void               AnalyzeH1Bias();
    void               AnalyzeSponsorship();
    void               AnalyzeSMTDivergence();
    void               AnalyzeMarketSymmetry();
    void               AnalyzeAlignment();
    void               DetermineOverallBias();
    void               AnalyzeMarketStructure();
    bool               IsHigherTimeFrameDisplacement();
    bool               IsDynamicResponseInternal(double price);
    bool               IsLethargicResponseInternal(double price);
    bool               IsSellSideLiquidityRunInternal();
    bool               IsBuySideLiquidityRunInternal();
    bool               IsAccumulationInternal();
    bool               IsDistributionInternal();
    bool               IsFailureSwingInternal();
    bool               IsBreakerSwingInternal();
    ENUM_BIAS          GetBiasFromPriceAction(string symbol, ENUM_TIMEFRAMES tf);
    double             GetDisplacementStrength(string symbol, ENUM_TIMEFRAMES tf);
    bool               DetectSMT(string symbol1, string symbol2);
    bool               DetectPhantomTrendline();
    bool               DetectFalseHnS();
    bool               DetectFalseiHnS();
    bool               DetectThirdTouchTrap();
    double             GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int bars);
    double             GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int bars);
    void               UpdateNYOpeningPrice();
    
public:
    //--- Constructor / Destructor
    CContext();
    ~CContext();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CMacroAnalyzer* macroAnalyzer,
              CSeasonal* seasonal, CDataRange* dataRange);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-058: Determinación de Bias
    ENUM_BIAS GetMonthlyBias() const { return m_state.monthlyBias; }
    ENUM_BIAS GetWeeklyBias() const { return m_state.weeklyBias; }
    ENUM_BIAS GetDailyBias() const { return m_state.dailyBias; }
    ENUM_BIAS GetH4Bias() const { return m_state.h4Bias; }
    ENUM_BIAS GetH1Bias() const { return m_state.h1Bias; }
    ENUM_BIAS GetOverallBias() const { return m_state.overallBias; }
    string GetBiasName(ENUM_BIAS bias) const;
    
    //--- RF-059: Transposición de Niveles
    double GetTransposedLevel(ENUM_TIMEFRAMES fromTF, ENUM_TIMEFRAMES toTF, double level);
    double GetMonthlyLevelOnDaily(double level);
    double GetWeeklyLevelOnH4(double level);
    double GetDailyLevelOnH1(double level);
    
    //--- RF-060: Refinamiento de Entradas
    double RefineEntry(double entryLevel, ENUM_TIMEFRAMES entryTF);
    bool IsEntryValid(double price, ENUM_TIMEFRAMES entryTF);
    
    //--- RF-061: Niveles Institucionales
    double GetInstitutionalSupport();
    double GetInstitutionalResistance();
    double GetNearestInstitutionalLevel(double price);
    
    //--- RF-063: Sponsorship Institucional
    bool IsSponsorshipPresent() const { return m_state.isSponsorshipPresent; }
    bool IsDynamicResponse(double price);
    bool IsLethargicResponse(double price);
    double GetSponsorshipStrength();
    
    //--- RF-083: SMT Divergence
    bool IsSMTDivergence() const { return m_state.isSMTDivergence; }
    bool IsSMTDivergenceWith(string symbol1, string symbol2);
    bool IsUSDXSMTDivergence();
    double GetSMTDivergenceScore();
    
    //--- RF-085: Alineación de 7 Factores
    int GetAlignedFactors() const { return m_state.alignedFactors; }
    double GetAlignmentScore() const { return m_state.alignmentScore; }
    bool IsAligned7Factors();
    bool IsMacroAligned();
    bool IsSeasonalAligned();
    bool IsDataRangeAligned();
    
    //--- RF-086: Pensamiento Procesal
    bool ProcessTick();
    bool ValidateStep(string step, bool condition);
    string GetProcessStatus();
    
    //--- RF-103-105: Modelos y Setups
    bool IsModelValid(ENUM_TRADING_MODEL model);
    bool IsBreadAndButterSetup();
    bool IsPullbackSetup();
    bool IsOrderBlockSetup();
    bool IsTurtleSoupSetup();
    string GetBestSetup();
    
    //--- RF-107: Institutional Order Flow
    ENUM_BIAS GetIOF();
    bool IsIOFAligning(ENUM_BIAS bias);
    
    //--- RF-108: Análisis por Cuerpos de Vela
    double GetBodyHigh(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetBodyLow(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double GetBodyRange(string symbol, ENUM_TIMEFRAMES tf, int shift);
    bool IsBullishBody(string symbol, ENUM_TIMEFRAMES tf, int shift);
    bool IsBearishBody(string symbol, ENUM_TIMEFRAMES tf, int shift);
    
    //--- RF-109: Fund Level Liquidity
    double GetFundLevelLiquidity(ENUM_BIAS side);
    bool IsFundLevelLiquidityAbove(double price);
    bool IsFundLevelLiquidityBelow(double price);
    
    //--- RF-110-111: Mitigation y Breakers
    bool IsMitigationBlock(double price);
    bool IsBreakerBlock(double price);
    double GetMitigationLevel();
    double GetBreakerLevel();
    
    //--- RF-113: Priorización de Niveles de Whales
    double GetWhaleLevel();
    bool IsWhaleLevel(double price);
    
    //--- RF-115-117: Liquidity Runs
    bool IsSellSideLiquidityRun();
    bool IsBuySideLiquidityRun();
    bool IsLowResistanceRun();
    bool IsHighResistanceRun();
    
    //--- RF-118: Time of Day
    bool IsOptimalTimeOfDay();
    bool IsAsianSession();
    bool IsLondonSession();
    bool IsNYSession();
    bool IsLondonCloseSession();
    bool IsKillZoneActive(ENUM_KILL_ZONE zone);
    
    //--- RF-121: Power of 3
    bool IsPowerOf3Setup();
    double GetPowerOf3Entry();
    double GetPowerOf3Target();
    
    //--- RF-122: Opening Price NY
    double GetNYOpeningPrice();
    bool IsPriceAboveNYOpen();
    bool IsPriceBelowNYOpen();
    
    //--- RF-123-126: Rango Mensual y OHLC
    double GetMonthlyRange();
    double GetMonthlyHigh();
    double GetMonthlyLow();
    double GetMonthlyOHLC(string field);
    
    //--- RF-127-133: Estructura de Mercado
    bool IsMarketSymmetry() const { return m_state.isMarketSymmetry; }
    bool IsAsymmetrical() const { return m_state.isAsymmetrical; }
    bool IsAccumulation();
    bool IsDistribution();
    bool IsFailureSwing();
    bool IsBreakerSwing();
    bool IsMarketStructureShift();
    ENUM_BIAS GetMarketStructureBias();
    
    //--- RF-134-140: Macro to Micro
    bool IsMacroToMicroAligned();
    string GetMacroToMicroSummary();
    
    //--- RF-141-144: Trendlines y Phantoms
    bool IsPhantomTrendline();
    bool IsThirdTouchTrap();
    bool IsContrarianSetup();
    
    //--- RF-145-149: Head and Shoulders
    bool IsFalseHnS();
    bool IsFalseiHnS();
    bool IsTurtleSoupLong();
    bool IsTurtleSoupShort();
    double GetNecklineLevel();
    
    //--- RF-370-371: Intermarket y COT
    bool IsIntermarketAligned();
    bool IsCOTAligned();
    bool IsCOTHedgingProgramAligned();
    
    //--- RF-472-477: Short-Term y OSOK
    bool IsShortTermValid();
    bool IsOSOKValid();
    bool IsOSOKSeasonalValid();
    bool IsOSOKCOTValid();
    bool IsOSOKKillZoneValid();
    bool IsOSOKFrequencyValid();
    bool IsOSOKQualified();
    void IncrementOSOKCounter();
    int GetOSOKTradesThisWeek() const { return m_osokCounter; }
    void ResetOSOKCounter();
    
    //--- Reportes
    string GetContextSummary();
    string GetBiasReport();
    string GetAlignmentReport();
    string GetMarketStructureReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CContext::CContext() {
    m_config = NULL;
    m_utils = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_minAlignedFactors = 5;
    m_osokCounter = 0;
    m_osokMaxPerWeek = 1;
    m_osokWeekStart = 0;
    m_nyOpeningPrice = 0;
    m_nyOpeningTime = 0;
    m_fundLevelLiquidityHigh = 0;
    m_fundLevelLiquidityLow = 0;
    ZeroMemory(m_state);
    ZeroMemory(m_marketStructure);
}

//--- Destructor
CContext::~CContext() {
    Deinit();
}

//--- Inicialización
bool CContext::Init(CConfig* config, CUtils* utils, CMacroAnalyzer* macroAnalyzer,
                    CSeasonal* seasonal, CDataRange* dataRange) {
    if(config == NULL || utils == NULL || macroAnalyzer == NULL ||
       seasonal == NULL || dataRange == NULL) {
        Print("CContext::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_macroAnalyzer = macroAnalyzer;
    m_seasonal = seasonal;
    m_dataRange = dataRange;
    
    m_symbol = _Symbol;
    m_osokWeekStart = TimeCurrent();
    
    //--- Actualizar análisis
    AnalyzeMarketStructure();
    AnalyzeMonthlyBias();
    AnalyzeWeeklyBias();
    AnalyzeDailyBias();
    AnalyzeH4Bias();
    AnalyzeH1Bias();
    AnalyzeSMTDivergence();
    AnalyzeMarketSymmetry();
    AnalyzeSponsorship();
    AnalyzeAlignment();
    DetermineOverallBias();
    UpdateNYOpeningPrice();
    
    m_isInitialized = true;
    m_utils.LogInfo("CContext inicializado correctamente para " + m_symbol);
    return true;
}

//--- Desinicialización
void CContext::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_macroAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
}

//--- RF-058: Analizar bias mensual
void CContext::AnalyzeMonthlyBias() {
    m_state.monthlyBias = GetBiasFromPriceAction(m_symbol, PERIOD_MN1);
}

//--- RF-058: Analizar bias semanal
void CContext::AnalyzeWeeklyBias() {
    m_state.weeklyBias = GetBiasFromPriceAction(m_symbol, PERIOD_W1);
}

//--- RF-058: Analizar bias diario
void CContext::AnalyzeDailyBias() {
    m_state.dailyBias = GetBiasFromPriceAction(m_symbol, PERIOD_D1);
}

//--- RF-058: Analizar bias H4
void CContext::AnalyzeH4Bias() {
    m_state.h4Bias = GetBiasFromPriceAction(m_symbol, PERIOD_H4);
}

//--- RF-058: Analizar bias H1
void CContext::AnalyzeH1Bias() {
    m_state.h1Bias = GetBiasFromPriceAction(m_symbol, PERIOD_H1);
}

//--- RF-058: Obtener bias de price action
ENUM_BIAS CContext::GetBiasFromPriceAction(string symbol, ENUM_TIMEFRAMES tf) {
    double ema20 = iMA(symbol, tf, 20, 0, MODE_EMA, PRICE_CLOSE);
    double ema50 = iMA(symbol, tf, 50, 0, MODE_EMA, PRICE_CLOSE);
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    
    if(currentPrice > ema20 && ema20 > ema50) return BIAS_BULLISH;
    if(currentPrice < ema20 && ema20 < ema50) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-058: Obtener nombre del bias
string CContext::GetBiasName(ENUM_BIAS bias) const {
    switch(bias) {
        case BIAS_BULLISH: return "BULLISH";
        case BIAS_BEARISH: return "BEARISH";
        case BIAS_NEUTRAL: return "NEUTRAL";
        default: return "UNKNOWN";
    }
}

//--- RF-063: Analizar Sponsorship
void CContext::AnalyzeSponsorship() {
    bool hasDisplacement = IsHigherTimeFrameDisplacement();
    bool hasDynamicResponse = IsDynamicResponseInternal(SymbolInfoDouble(m_symbol, SYMBOL_BID));
    bool hasSellSideRun = IsSellSideLiquidityRunInternal();
    bool hasBuySideRun = IsBuySideLiquidityRunInternal();
    
    m_state.isSponsorshipPresent = (hasDisplacement && (hasDynamicResponse || hasSellSideRun || hasBuySideRun));
}

//--- RF-083: Analizar SMT Divergence
void CContext::AnalyzeSMTDivergence() {
    //--- Comparar DXY con el par actual
    string dxySymbol = "DXY";
    m_state.isSMTDivergence = DetectSMT(dxySymbol, m_symbol);
}

//--- RF-083: Detectar SMT entre dos símbolos
bool CContext::DetectSMT(string symbol1, string symbol2) {
    double close1[], close2[];
    ArraySetAsSeries(close1, true);
    ArraySetAsSeries(close2, true);
    
    if(CopyClose(symbol1, PERIOD_H1, 0, 20, close1) < 20) return false;
    if(CopyClose(symbol2, PERIOD_H1, 0, 20, close2) < 20) return false;
    
    bool symbol1Up = close1[0] > close1[10];
    bool symbol2Up = close2[0] > close2[10];
    
    return symbol1Up != symbol2Up;
}

//--- RF-083: SMT con DXY
bool CContext::IsUSDXSMTDivergence() {
    return DetectSMT("DXY", m_symbol);
}

//--- RF-083: Obtener score de SMT
double CContext::GetSMTDivergenceScore() {
    if(m_state.isSMTDivergence) return 80.0;
    return 20.0;
}

//--- RF-128: Analizar Market Symmetry
void CContext::AnalyzeMarketSymmetry() {
    //--- Comparar DXY y el par
    m_state.isMarketSymmetry = DetectSMT("DXY", m_symbol);
    m_state.isAsymmetrical = !m_state.isMarketSymmetry;
}

//--- RF-085: Analizar Alineación de 7 Factores
void CContext::AnalyzeAlignment() {
    int factors = 0;
    double score = 0.0;
    
    //--- Factor 1: Macro (20%)
    if(m_macroAnalyzer != NULL && m_macroAnalyzer.IsMacroAligned(m_state.overallBias)) {
        factors++;
        score += 20;
    }
    
    //--- Factor 2: Seasonal (15%)
    if(m_seasonal != NULL && m_seasonal.IsContextValid(m_symbol, m_state.overallBias)) {
        factors++;
        score += 15;
    }
    
    //--- Factor 3: Data Range (15%)
    if(m_dataRange != NULL && m_dataRange.IsSetupValid(m_state.overallBias, SymbolInfoDouble(m_symbol, SYMBOL_BID))) {
        factors++;
        score += 15;
    }
    
    //--- Factor 4: Monthly Bias (10%)
    if(m_state.monthlyBias == m_state.overallBias) {
        factors++;
        score += 10;
    }
    
    //--- Factor 5: Weekly Bias (10%)
    if(m_state.weeklyBias == m_state.overallBias) {
        factors++;
        score += 10;
    }
    
    //--- Factor 6: Daily Bias (10%)
    if(m_state.dailyBias == m_state.overallBias) {
        factors++;
        score += 10;
    }
    
    //--- Factor 7: Sponsorship (20%)
    if(m_state.isSponsorshipPresent) {
        factors++;
        score += 20;
    }
    
    m_state.alignedFactors = factors;
    m_state.alignmentScore = score;
}

//--- RF-085: Verificar alineación de 7 factores
bool CContext::IsAligned7Factors() {
    return m_state.alignedFactors >= m_minAlignedFactors;
}

//--- RF-058: Determinar bias general
void CContext::DetermineOverallBias() {
    int bullish = 0, bearish = 0;
    
    if(m_state.monthlyBias == BIAS_BULLISH) bullish++; else if(m_state.monthlyBias == BIAS_BEARISH) bearish++;
    if(m_state.weeklyBias == BIAS_BULLISH) bullish++; else if(m_state.weeklyBias == BIAS_BEARISH) bearish++;
    if(m_state.dailyBias == BIAS_BULLISH) bullish++; else if(m_state.dailyBias == BIAS_BEARISH) bearish++;
    if(m_state.h4Bias == BIAS_BULLISH) bullish++; else if(m_state.h4Bias == BIAS_BEARISH) bearish++;
    if(m_state.h1Bias == BIAS_BULLISH) bullish++; else if(m_state.h1Bias == BIAS_BEARISH) bearish++;
    
    if(bullish > bearish) m_state.overallBias = BIAS_BULLISH;
    else if(bearish > bullish) m_state.overallBias = BIAS_BEARISH;
    else m_state.overallBias = BIAS_NEUTRAL;
}

//--- RF-127: Analizar estructura de mercado
void CContext::AnalyzeMarketStructure() {
    m_marketStructure.monthlyHigh = GetHighestHigh(m_symbol, PERIOD_MN1, 5);
    m_marketStructure.monthlyLow = GetLowestLow(m_symbol, PERIOD_MN1, 5);
    m_marketStructure.weeklyHigh = GetHighestHigh(m_symbol, PERIOD_W1, 5);
    m_marketStructure.weeklyLow = GetLowestLow(m_symbol, PERIOD_W1, 5);
    m_marketStructure.dailyHigh = GetHighestHigh(m_symbol, PERIOD_D1, 5);
    m_marketStructure.dailyLow = GetLowestLow(m_symbol, PERIOD_D1, 5);
    m_marketStructure.h4High = GetHighestHigh(m_symbol, PERIOD_H4, 10);
    m_marketStructure.h4Low = GetLowestLow(m_symbol, PERIOD_H4, 10);
    
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double range = m_marketStructure.weeklyHigh - m_marketStructure.weeklyLow;
    
    if(range > 0) {
        double position = (currentPrice - m_marketStructure.weeklyLow) / range;
        if(position > 0.7) m_marketStructure.isUptrend = true;
        else if(position < 0.3) m_marketStructure.isDowntrend = true;
        else m_marketStructure.isConsolidation = true;
    }
    
    m_marketStructure.structureBias = (m_marketStructure.isUptrend) ? BIAS_BULLISH :
                                       (m_marketStructure.isDowntrend) ? BIAS_BEARISH : BIAS_NEUTRAL;
}

//--- RF-115: Sell Side Liquidity Run
bool CContext::IsSellSideLiquidityRun() {
    return IsSellSideLiquidityRunInternal();
}

bool CContext::IsSellSideLiquidityRunInternal() {
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice < low20;
}

//--- RF-116: Buy Side Liquidity Run
bool CContext::IsBuySideLiquidityRun() {
    return IsBuySideLiquidityRunInternal();
}

bool CContext::IsBuySideLiquidityRunInternal() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice > high20;
}

//--- RF-119: Dynamic Response
bool CContext::IsDynamicResponse(double price) {
    return IsDynamicResponseInternal(price);
}

bool CContext::IsDynamicResponseInternal(double price) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double diff = MathAbs(currentPrice - price);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    return diff / point < 5.0;
}

//--- RF-120: Lethargic Response
bool CContext::IsLethargicResponse(double price) {
    return IsLethargicResponseInternal(price);
}

bool CContext::IsLethargicResponseInternal(double price) {
    return !IsDynamicResponseInternal(price);
}

//--- RF-121: Power of 3
bool CContext::IsPowerOf3Setup() {
    double nyOpen = GetNYOpeningPrice();
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double diff = MathAbs(currentPrice - nyOpen);
    double atr = m_utils.CalculateATR(m_symbol, PERIOD_D1, 14);
    return diff < atr * 0.3;
}

//--- RF-122: NY Opening Price
void CContext::UpdateNYOpeningPrice() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    dt.hour = 8;
    dt.min = 0;
    dt.sec = 0;
    m_nyOpeningTime = StructToTime(dt);
    m_nyOpeningPrice = iOpen(m_symbol, PERIOD_H1, 0);
}

double CContext::GetNYOpeningPrice() {
    if(m_nyOpeningPrice == 0) UpdateNYOpeningPrice();
    return m_nyOpeningPrice;
}

//--- RF-123-126: Rango Mensual
double CContext::GetMonthlyRange() {
    return m_marketStructure.monthlyHigh - m_marketStructure.monthlyLow;
}

double CContext::GetMonthlyHigh() {
    return m_marketStructure.monthlyHigh;
}

double CContext::GetMonthlyLow() {
    return m_marketStructure.monthlyLow;
}

//--- RF-141-143: Phantom Trendline
bool CContext::IsPhantomTrendline() {
    return DetectPhantomTrendline();
}

bool CContext::DetectPhantomTrendline() {
    //--- Placeholder
    return false;
}

//--- RF-142: Third Touch Trap
bool CContext::IsThirdTouchTrap() {
    return DetectThirdTouchTrap();
}

bool CContext::DetectThirdTouchTrap() {
    //--- Placeholder
    return false;
}

//--- RF-145-149: False H&S
bool CContext::IsFalseHnS() {
    return DetectFalseHnS();
}

bool CContext::DetectFalseHnS() {
    //--- Placeholder
    return false;
}

bool CContext::IsFalseiHnS() {
    return DetectFalseiHnS();
}

bool CContext::DetectFalseiHnS() {
    //--- Placeholder
    return false;
}

bool CContext::IsTurtleSoupLong() {
    return IsFalseiHnS();
}

bool CContext::IsTurtleSoupShort() {
    return IsFalseHnS();
}

//--- RF-472-477: OSOK
bool CContext::IsOSOKValid() {
    return IsOSOKSeasonalValid() && IsOSOKCOTValid() &&
           IsOSOKKillZoneValid() && IsOSOKFrequencyValid();
}

bool CContext::IsOSOKSeasonalValid() {
    if(m_seasonal == NULL) return false;
    return m_seasonal.IsSeasonalValid(m_symbol);
}

bool CContext::IsOSOKCOTValid() {
    if(m_macroAnalyzer == NULL) return false;
    return m_macroAnalyzer.IsCOTAligned();
}

bool CContext::IsOSOKKillZoneValid() {
    return IsKillZoneActive(KZ_LONDON) || IsKillZoneActive(KZ_NEW_YORK) ||
           IsKillZoneActive(KZ_ASIAN) || IsKillZoneActive(KZ_LONDON_CLOSE);
}

bool CContext::IsOSOKFrequencyValid() {
    return m_osokCounter < m_osokMaxPerWeek;
}

bool CContext::IsOSOKQualified() {
    return IsOSOKValid() && IsAligned7Factors();
}

void CContext::IncrementOSOKCounter() {
    m_osokCounter++;
}

void CContext::ResetOSOKCounter() {
    m_osokCounter = 0;
}

//--- RF-118: Kill Zones
bool CContext::IsKillZoneActive(ENUM_KILL_ZONE zone) {
    return m_utils.IsKillZoneActive(zone, TimeCurrent());
}

bool CContext::IsAsianSession() {
    return m_utils.IsAsianSession(TimeCurrent());
}

bool CContext::IsLondonSession() {
    return m_utils.IsLondonSession(TimeCurrent());
}

bool CContext::IsNYSession() {
    return m_utils.IsNYSession(TimeCurrent());
}

bool CContext::IsLondonCloseSession() {
    return m_utils.IsLondonCloseSession(TimeCurrent());
}

//--- RF-118: Time of Day
bool CContext::IsOptimalTimeOfDay() {
    return IsLondonSession() || IsNYSession();
}

//--- RF-370-371: Intermarket y COT
bool CContext::IsIntermarketAligned() {
    if(m_macroAnalyzer == NULL) return false;
    return m_macroAnalyzer.GetIntermarketAlignment() > 50;
}

bool CContext::IsCOTAligned() {
    if(m_macroAnalyzer == NULL) return false;
    return m_macroAnalyzer.IsCOTAligned();
}

//--- RF-103: Model Validation
bool CContext::IsModelValid(ENUM_TRADING_MODEL model) {
    if(model == MODEL_OSOK) {
        return IsOSOKQualified();
    }
    return IsAligned7Factors();
}

//--- RF-107: Institutional Order Flow
ENUM_BIAS CContext::GetIOF() {
    if(m_dataRange == NULL) return BIAS_NEUTRAL;
    return m_dataRange.GetIOF();
}

//--- RF-109: Fund Level Liquidity
double CContext::GetFundLevelLiquidity(ENUM_BIAS side) {
    if(side == BIAS_BULLISH) {
        return m_marketStructure.monthlyHigh;
    }
    return m_marketStructure.monthlyLow;
}

//--- RF-110-111: Mitigation y Breakers
bool CContext::IsMitigationBlock(double price) {
    //--- Placeholder
    return false;
}

bool CContext::IsBreakerBlock(double price) {
    //--- Placeholder
    return false;
}

//--- RF-113: Whale Levels
bool CContext::IsWhaleLevel(double price) {
    double whaleLevel = GetWhaleLevel();
    double diff = MathAbs(price - whaleLevel);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    return diff / point < 10.0;
}

double CContext::GetWhaleLevel() {
    return (m_marketStructure.monthlyHigh + m_marketStructure.monthlyLow) / 2.0;
}

//--- RF-059: Transposición de Niveles
double CContext::GetTransposedLevel(ENUM_TIMEFRAMES fromTF, ENUM_TIMEFRAMES toTF, double level) {
    //--- Simplificado
    return level;
}

double CContext::GetMonthlyLevelOnDaily(double level) {
    return level;
}

double CContext::GetWeeklyLevelOnH4(double level) {
    return level;
}

double CContext::GetDailyLevelOnH1(double level) {
    return level;
}

//--- Funciones auxiliares
double CContext::GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int bars) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    if(CopyHigh(symbol, tf, 0, bars, highArray) < bars) return 0;
    double maxHigh = highArray[0];
    for(int i = 1; i < bars; i++) {
        if(highArray[i] > maxHigh) maxHigh = highArray[i];
    }
    return maxHigh;
}

double CContext::GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int bars) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    if(CopyLow(symbol, tf, 0, bars, lowArray) < bars) return 0;
    double minLow = lowArray[0];
    for(int i = 1; i < bars; i++) {
        if(lowArray[i] < minLow) minLow = lowArray[i];
    }
    return minLow;
}

//--- RF-127-133: Estructura de Mercado
bool CContext::IsMarketStructureShift() {
    ENUM_BIAS currentBias = GetMarketStructureBias();
    ENUM_BIAS previousBias = m_state.overallBias;
    return currentBias != previousBias && currentBias != BIAS_NEUTRAL;
}

ENUM_BIAS CContext::GetMarketStructureBias() {
    return m_marketStructure.structureBias;
}

//--- RF-134-140: Macro to Micro
bool CContext::IsMacroToMicroAligned() {
    if(m_macroAnalyzer == NULL) return false;
    ENUM_BIAS macroBias = m_macroAnalyzer.GetIntermarketBias();
    ENUM_BIAS microBias = GetOverallBias();
    return macroBias == microBias || microBias == BIAS_NEUTRAL;
}

string CContext::GetMacroToMicroSummary() {
    string summary = "=== MACRO TO MICRO ===\n";
    summary += "Macro Bias: " + GetBiasName(m_macroAnalyzer.GetIntermarketBias()) + "\n";
    summary += "Micro Bias: " + GetBiasName(GetOverallBias()) + "\n";
    summary += "Aligned: " + (IsMacroToMicroAligned() ? "YES" : "NO") + "\n";
    return summary;
}

//--- Reportes
string CContext::GetContextSummary() {
    string summary = "=== CONTEXT SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Monthly Bias: " + GetBiasName(m_state.monthlyBias) + "\n";
    summary += "Weekly Bias: " + GetBiasName(m_state.weeklyBias) + "\n";
    summary += "Daily Bias: " + GetBiasName(m_state.dailyBias) + "\n";
    summary += "H4 Bias: " + GetBiasName(m_state.h4Bias) + "\n";
    summary += "H1 Bias: " + GetBiasName(m_state.h1Bias) + "\n";
    summary += "Overall Bias: " + GetBiasName(m_state.overallBias) + "\n";
    summary += "Sponsorship: " + (m_state.isSponsorshipPresent ? "YES" : "NO") + "\n";
    summary += "SMT Divergence: " + (m_state.isSMTDivergence ? "YES" : "NO") + "\n";
    summary += "Market Symmetry: " + (m_state.isMarketSymmetry ? "YES" : "NO") + "\n";
    summary += "Alignment Score: " + DoubleToString(m_state.alignmentScore, 1) + "%\n";
    summary += "Aligned Factors: " + IntegerToString(m_state.alignedFactors) + "/7\n";
    summary += "=========================";
    return summary;
}

string CContext::GetBiasReport() {
    string report = "=== BIAS REPORT ===\n";
    report += "Monthly: " + GetBiasName(m_state.monthlyBias) + "\n";
    report += "Weekly: " + GetBiasName(m_state.weeklyBias) + "\n";
    report += "Daily: " + GetBiasName(m_state.dailyBias) + "\n";
    report += "H4: " + GetBiasName(m_state.h4Bias) + "\n";
    report += "H1: " + GetBiasName(m_state.h1Bias) + "\n";
    report += "Overall: " + GetBiasName(m_state.overallBias) + "\n";
    report += "===================";
    return report;
}

string CContext::GetAlignmentReport() {
    string report = "=== ALIGNMENT REPORT ===\n";
    report += "Macro: " + (m_macroAnalyzer != NULL && m_macroAnalyzer.IsMacroAligned(m_state.overallBias) ? "✅" : "❌") + "\n";
    report += "Seasonal: " + (m_seasonal != NULL && m_seasonal.IsContextValid(m_symbol, m_state.overallBias) ? "✅" : "❌") + "\n";
    report += "Data Range: " + (m_dataRange != NULL && m_dataRange.IsSetupValid(m_state.overallBias, SymbolInfoDouble(m_symbol, SYMBOL_BID)) ? "✅" : "❌") + "\n";
    report += "Monthly Bias: " + (m_state.monthlyBias == m_state.overallBias ? "✅" : "❌") + "\n";
    report += "Weekly Bias: " + (m_state.weeklyBias == m_state.overallBias ? "✅" : "❌") + "\n";
    report += "Daily Bias: " + (m_state.dailyBias == m_state.overallBias ? "✅" : "❌") + "\n";
    report += "Sponsorship: " + (m_state.isSponsorshipPresent ? "✅" : "❌") + "\n";
    report += "Score: " + DoubleToString(m_state.alignmentScore, 1) + "%\n";
    report += "Factors: " + IntegerToString(m_state.alignedFactors) + "/7\n";
    report += "=========================";
    return report;
}

string CContext::GetMarketStructureReport() {
    string report = "=== MARKET STRUCTURE ===\n";
    report += "Monthly High: " + DoubleToString(m_marketStructure.monthlyHigh, 5) + "\n";
    report += "Monthly Low: " + DoubleToString(m_marketStructure.monthlyLow, 5) + "\n";
    report += "Weekly High: " + DoubleToString(m_marketStructure.weeklyHigh, 5) + "\n";
    report += "Weekly Low: " + DoubleToString(m_marketStructure.weeklyLow, 5) + "\n";
    report += "Daily High: " + DoubleToString(m_marketStructure.dailyHigh, 5) + "\n";
    report += "Daily Low: " + DoubleToString(m_marketStructure.dailyLow, 5) + "\n";
    report += "Structure Bias: " + GetBiasName(m_marketStructure.structureBias) + "\n";
    report += "Uptrend: " + (m_marketStructure.isUptrend ? "YES" : "NO") + "\n";
    report += "Downtrend: " + (m_marketStructure.isDowntrend ? "YES" : "NO") + "\n";
    report += "Consolidation: " + (m_marketStructure.isConsolidation ? "YES" : "NO") + "\n";
    report += "=========================";
    return report;
}

#endif // __CCONTEXT_MQH__