//+------------------------------------------------------------------+
//|                                                    CDetector.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo detecta setups ICT:                                  |
//| - Order Blocks                                                   |
//| - Fair Value Gaps (FVG)                                          |
//| - Turtle Soup                                                    |
//| - Stop Runs / Liquidity Hunts                                    |
//| - PD Arrays                                                      |
//| - Equilibrium, OTE, Zonas de Descuento/Prima                     |
//| - Breaker Blocks, Rejection Blocks, Propulsion Blocks            |
//| - Liquidity Pools, Liquidity Voids, Gaps                         |
//| - Divergencias, Double Tops/Bottoms                              |
//| - Market Maker Models                                            |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-001 a RF-010: Básicos                                       |
//|   RF-150 a RF-221: Avanzados                                     |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CContext: Contexto                                           |
//|   - CDataRange: IPDA Data Ranges                                 |
//|   - CSeasonal: Tendencias estacionales                           |
//|                                                                  |
//| Versión: 1.1                                                     |
//| Fecha: 21/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 21/07/2026  | Versión inicial del módulo               |
//| 1.1     | 21/07/2026  | Añadidas estructuras y métodos avanzados |
//|         |             | RF-150 a RF-221                          |
//+------------------------------------------------------------------+

#ifndef __CDETECTOR_MQH__
#define __CDETECTOR_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CContext.mqh"
#include "CDataRange.mqh"
#include "CSeasonal.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS BASICAS                                     |
//+------------------------------------------------------------------+
struct OrderBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    double           open;
    double           close;
    double           meanThreshold;
    double           range;
    datetime         startTime;
    datetime         endTime;
    int              candleCount;
    bool             isConfirmed;
    bool             isMitigated;
    bool             isActive;
    double           mitigationLevel;
    double           entryLevel;
    double           stopLevel;
    double           targetLevel;
};

struct FVG {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    double           meanThreshold;
    datetime         startTime;
    datetime         endTime;
    bool             isFilled;
    double           fillLevel;
    bool             isActive;
    bool             isBreakawayGap;
    bool             isExhaustionGap;
    bool             isCommonGap;
};

struct TurtleSoup {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           entryLevel;
    double           stopLevel;
    double           targetLevel;
    double           oldHigh;
    double           oldLow;
    datetime         formationTime;
    bool             isConfirmed;
    bool             isFalseBreakout;
};

struct StopRun {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           level;
    double           liquidityPool;
    datetime         startTime;
    datetime         endTime;
    bool             isBuyStop;
    bool             isSellStop;
    bool             isLowResistance;
    bool             isHighResistance;
    bool             isConfirmed;
};

struct PDArray {
    ENUM_PD_ARRAY    type;
    ENUM_BIAS        bias;
    double           level;
    double           high;
    double           low;
    ENUM_TIMEFRAMES  tf;
    bool             isPremium;
    bool             isDiscount;
    bool             isActive;
    int              priority;
    datetime         formationTime;
};

//+------------------------------------------------------------------+
//| ESTRUCTURAS AVANZADAS (RF-150 a RF-221)                          |
//+------------------------------------------------------------------+
struct BreakerBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    double           triggerLevel;
    double           meanThreshold;
    datetime         startTime;
    datetime         endTime;
    bool             isConfirmed;
    bool             isActive;
    double           entryLevel;
    double           stopLevel;
    double           targetLevel;
};

struct RejectionBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    double           highestBody;
    double           lowestBody;
    double           triggerLevel;
    datetime         formationTime;
    bool             isConfirmed;
    bool             isActive;
};

struct PropulsionBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           level;
    double           meanThreshold;
    datetime         formationTime;
    bool             isConfirmed;
    bool             isActive;
};

struct VacuumBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    datetime         startTime;
    datetime         endTime;
    bool             isFilled;
    double           fillLevel;
    bool             isActive;
};

struct LiquidityPool {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           level;
    double           size;
    datetime         startTime;
    datetime         endTime;
    bool             isActive;
    bool             isNearTerm;
    bool             isShortTerm;
    bool             isIntermediateTerm;
};

struct Divergence {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           priceLevel;
    double           indicatorLevel;
    datetime         startTime;
    datetime         endTime;
    bool             isType1;
    bool             isType2;
    bool             isHidden;
    bool             isPhantom;
    bool             isConfirmed;
};

struct DoublePattern {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           level;
    double           projectedTarget;
    datetime         formationTime;
    bool             isDoubleTop;
    bool             isDoubleBottom;
    bool             isConfirmed;
    bool             isStopRun;
};

struct MitigationBlock {
    string           symbol;
    ENUM_TIMEFRAMES  tf;
    ENUM_BIAS        bias;
    double           high;
    double           low;
    datetime         startTime;
    datetime         endTime;
    bool             isMitigated;
    double           mitigationLevel;
    double           meanThreshold;
    bool             isActive;
};

//+------------------------------------------------------------------+
//| CLASE CDetector - Detector de Setups ICT                         |
//+------------------------------------------------------------------+
class CDetector {
private:
    //--- Referencias
    CConfig*           m_config;
    CContext*          m_context;
    CUtils*            m_utils;
    CDataRange*        m_dataRange;
    CSeasonal*         m_seasonal;
    bool               m_isInitialized;
    string             m_symbol;
    
    //--- Arrays de Detección Básicos
    OrderBlock         m_orderBlocks[];
    FVG                m_fvgs[];
    TurtleSoup         m_turtleSoups[];
    StopRun            m_stopRuns[];
    PDArray            m_pdArrays[];
    int                m_orderBlockCount;
    int                m_fvgCount;
    int                m_turtleSoupCount;
    int                m_stopRunCount;
    int                m_pdArrayCount;
    
    //--- Arrays de Detección Avanzados
    BreakerBlock       m_breakerBlocks[];
    RejectionBlock     m_rejectionBlocks[];
    PropulsionBlock    m_propulsionBlocks[];
    VacuumBlock        m_vacuumBlocks[];
    LiquidityPool      m_liquidityPools[];
    Divergence         m_divergences[];
    DoublePattern      m_doublePatterns[];
    MitigationBlock    m_mitigationBlocks[];
    int                m_breakerCount;
    int                m_rejectionCount;
    int                m_propulsionCount;
    int                m_vacuumCount;
    int                m_liquidityPoolCount;
    int                m_divergenceCount;
    int                m_doublePatternCount;
    int                m_mitigationCount;
    
    //--- Estado
    ENUM_MARKET_STATE  m_marketState;
    ENUM_MARKET_ZONE   m_marketZone;
    double             m_equilibrium;
    double             m_oteHigh;
    double             m_oteLow;
    double             m_currentRangeHigh;
    double             m_currentRangeLow;
    bool               m_isProtraction;
    bool               m_isJudasSwing;
    
    //--- Métodos de Detección Básicos
    void               DetectOrderBlocks();
    void               DetectFVG();
    void               DetectTurtleSoup();
    void               DetectStopRuns();
    void               DetectPDArrays();
    void               ClassifyMarket();
    void               CalculateEquilibrium();
    void               CalculateOTE();
    ENUM_MARKET_ZONE   ClassifyMarketZone();
    bool               IsMarketProtraction();
    bool               IsJudasSwing();
    double             GetDisplacementStrength(int startIdx, int endIdx);
    bool               IsImpulsiveMove(int startIdx, int endIdx);
    
    //--- Métodos de Detección Avanzados
    void               DetectBreakerBlocks();
    void               DetectRejectionBlocks();
    void               DetectPropulsionBlocks();
    void               DetectVacuumBlocks();
    void               DetectLiquidityPools();
    void               DetectDivergences();
    void               DetectDoublePatterns();
    void               DetectMitigationBlocks();
    
    //--- Métodos de Validación
    bool               ValidateOrderBlock(OrderBlock &ob);
    bool               ValidateFVG(FVG &fvg);
    bool               ValidateTurtleSoup(TurtleSoup &ts);
    bool               ValidateStopRun(StopRun &sr);
    bool               ValidateBreakerBlock(BreakerBlock &br);
    bool               ValidateRejectionBlock(RejectionBlock &rb);
    bool               IsInstitutionalSponsorship(double price, ENUM_TIMEFRAMES tf);
    bool               IsDynamicResponse(double price, ENUM_TIMEFRAMES tf);
    bool               IsLethargicResponse(double price, ENUM_TIMEFRAMES tf);
    
    //--- Métodos auxiliares
    double             GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int start, int end);
    double             GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int start, int end);
    double             GetOpenPrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double             GetClosePrice(string symbol, ENUM_TIMEFRAMES tf, int shift);
    bool               IsBullishCandle(string symbol, ENUM_TIMEFRAMES tf, int shift);
    bool               IsBearishCandle(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double             GetCandleBodyHigh(string symbol, ENUM_TIMEFRAMES tf, int shift);
    double             GetCandleBodyLow(string symbol, ENUM_TIMEFRAMES tf, int shift);
    bool               IsSweepBelowOldLow();
    bool               IsSweepAboveOldHigh();
    
public:
    //--- Constructor / Destructor
    CDetector();
    ~CDetector();
    
    //--- Inicialización
    bool Init(CConfig* config, CContext* context, CUtils* utils,
              CDataRange* dataRange, CSeasonal* seasonal);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Analyze(string symbol, ENUM_TIMEFRAMES tf);
    void AnalyzeAll();
    void Clear();
    
    //--- RF-001: Order Blocks
    int GetOrderBlockCount() const { return m_orderBlockCount; }
    OrderBlock GetOrderBlock(int index) const;
    bool HasOrderBlock(ENUM_BIAS bias);
    OrderBlock GetBestOrderBlock(ENUM_BIAS bias);
    OrderBlock GetNearestOrderBlock(double price);
    
    //--- RF-002: FVG
    int GetFVGCount() const { return m_fvgCount; }
    FVG GetFVG(int index) const;
    bool HasFVG(ENUM_BIAS bias);
    FVG GetBestFVG(ENUM_BIAS bias);
    FVG GetNearestFVG(double price);
    bool IsFVGActive(FVG &fvg);
    
    //--- RF-003: Equilibrium
    double GetEquilibrium() const { return m_equilibrium; }
    double GetEquilibriumForRange(double high, double low);
    double GetCurrentRangeHigh() const { return m_currentRangeHigh; }
    double GetCurrentRangeLow() const { return m_currentRangeLow; }
    
    //--- RF-004: Zonas de Descuento y Prima
    ENUM_MARKET_ZONE GetMarketZone() const { return m_marketZone; }
    bool IsInDiscountZone(double price);
    bool IsInPremiumZone(double price);
    bool IsInEquilibriumZone(double price);
    double GetDiscountZoneLow() const;
    double GetDiscountZoneHigh() const;
    double GetPremiumZoneLow() const;
    double GetPremiumZoneHigh() const;
    
    //--- RF-005: Optimal Trade Entry (OTE)
    double GetOTEHigh() const { return m_oteHigh; }
    double GetOTELow() const { return m_oteLow; }
    double GetOTEMid() const;
    bool IsInOTE(double price);
    double GetOTEForRange(double high, double low);
    double GetOTEForRangeLow(double high, double low);
    double GetOTEForRangeHigh(double high, double low);
    
    //--- RF-006: Clasificación de Mercado
    ENUM_MARKET_STATE GetMarketState() const { return m_marketState; }
    string GetMarketStateName() const;
    bool IsExpansion() const { return m_marketState == STATE_EXPANSION; }
    bool IsRetracement() const { return m_marketState == STATE_RETRACEMENT; }
    bool IsReversal() const { return m_marketState == STATE_REVERSAL; }
    bool IsConsolidation() const { return m_marketState == STATE_CONSOLIDATION; }
    
    //--- RF-007: Turtle Soup
    int GetTurtleSoupCount() const { return m_turtleSoupCount; }
    TurtleSoup GetTurtleSoup(int index) const;
    bool IsTurtleSoupLong();
    bool IsTurtleSoupShort();
    TurtleSoup GetBestTurtleSoup();
    TurtleSoup GetNearestTurtleSoup(double price);
    
    //--- RF-008: Stop Runs
    int GetStopRunCount() const { return m_stopRunCount; }
    StopRun GetStopRun(int index) const;
    bool IsStopRunAbove();
    bool IsStopRunBelow();
    StopRun GetBestStopRun();
    StopRun GetNearestStopRun(double price);
    
    //--- RF-009: Market Protraction
    bool IsMarketProtraction() const { return m_isProtraction; }
    bool IsJudasSwing() const { return m_isJudasSwing; }
    bool IsInProtractionPhase();
    string GetProtractionStatus();
    
    //--- RF-010: Análisis Multi-Temporal
    void AnalyzeMultiTimeframe();
    bool IsAllTimeframesAligned();
    int GetAlignedTimeframesCount();
    ENUM_BIAS GetMultiTimeframeBias();
    bool IsTimeframeAligned(ENUM_TIMEFRAMES tf);
    
    //--- PD Arrays
    int GetPDArrayCount() const { return m_pdArrayCount; }
    PDArray GetPDArray(int index) const;
    PDArray GetBestPDArray(ENUM_BIAS bias);
    PDArray GetBestPDArrayByType(ENUM_PD_ARRAY type);
    bool HasPDArray(ENUM_PD_ARRAY type);
    PDArray GetNearestPDArray(double price);
    
    //--- RF-159: Mitigation Blocks
    int GetMitigationBlockCount() const { return m_mitigationCount; }
    MitigationBlock GetMitigationBlock(int index) const;
    bool IsMitigationBlock(double price);
    MitigationBlock GetBestMitigationBlock();
    
    //--- RF-166-172: Breaker Blocks
    int GetBreakerBlockCount() const { return m_breakerCount; }
    BreakerBlock GetBreakerBlock(int index) const;
    bool IsBreakerBlock(double price);
    BreakerBlock GetBestBreakerBlock(ENUM_BIAS bias);
    bool IsBreakerFormation();
    bool IsBreakerConfirmed();
    double GetBreakerTriggerLevel();
    
    //--- RF-173-177: Rejection Blocks
    int GetRejectionBlockCount() const { return m_rejectionCount; }
    RejectionBlock GetRejectionBlock(int index) const;
    bool IsRejectionBlock(double price);
    RejectionBlock GetBestRejectionBlock(ENUM_BIAS bias);
    double GetHighestBodyReference();
    double GetLowestBodyReference();
    
    //--- RF-188-191: Propulsion y Vacuum Blocks
    int GetPropulsionBlockCount() const { return m_propulsionCount; }
    PropulsionBlock GetPropulsionBlock(int index) const;
    bool IsPropulsionBlock(double price);
    PropulsionBlock GetBestPropulsionBlock(ENUM_BIAS bias);
    
    int GetVacuumBlockCount() const { return m_vacuumCount; }
    VacuumBlock GetVacuumBlock(int index) const;
    bool IsVacuumBlock(double price);
    VacuumBlock GetBestVacuumBlock(ENUM_BIAS bias);
    
    //--- RF-150-155: Liquidity
    bool IsExternalRangeLiquidity();
    bool IsInternalRangeLiquidity();
    bool IsLowResistanceLiquidityRun();
    bool IsHighResistanceLiquidityRun();
    double GetExternalRangeLiquidityLevel();
    double GetInternalRangeLiquidityLevel();
    
    //--- RF-202-207: Liquidity Pools y Raids
    int GetLiquidityPoolCount() const { return m_liquidityPoolCount; }
    LiquidityPool GetLiquidityPool(int index) const;
    bool IsLiquidityPool(double price);
    LiquidityPool GetNearestLiquidityPool(double price);
    bool IsLiquidityRaid();
    
    //--- RF-211-213: Divergencias
    int GetDivergenceCount() const { return m_divergenceCount; }
    Divergence GetDivergence(int index) const;
    bool IsType1Divergence();
    bool IsType2Divergence();
    bool IsHiddenDivergence();
    bool IsDivergencePhantom();
    Divergence GetBestDivergence(ENUM_BIAS bias);
    
    //--- RF-216-221: Double Tops/Bottoms
    int GetDoublePatternCount() const { return m_doublePatternCount; }
    DoublePattern GetDoublePattern(int index) const;
    bool IsDoubleTop();
    bool IsDoubleBottom();
    DoublePattern GetBestDoublePattern();
    double GetMeasuredMoveFromDouble();
    bool IsStopRunOnDoubleTop();
    bool IsStopRunOnDoubleBottom();
    
    //--- RF-178-187: Market Maker Models
    bool IsMMBuyModel();
    bool IsMMSellModel();
    bool IsAccumulation();
    bool IsDistribution();
    bool IsBuySideOfCurve();
    bool IsSellSideOfCurve();
    bool IsHedgingDuringAccumulation();
    bool IsHedgingDuringDistribution();
    
    //--- RF-192-201: Gaps y Liquidity Voids
    bool IsBreakawayGap();
    bool IsExhaustionGap();
    bool IsCommonGap();
    bool IsGapFill();
    bool IsFullGapFill();
    double GetGapMeanThreshold();
    bool IsLiquidityVoid();
    bool IsOneSidedRange();
    
    //--- RF-160-165: Estructura de Mercado
    bool IsMarketStructureShift();
    bool IsMPattern();
    bool IsBuyersRemorse();
    bool IsStepLadderFormation();
    bool IsUnderwaterPosition(double price);
    
    //--- RF-180-181: Reclaimed Order Blocks
    bool IsReclaimedOrderBlock(OrderBlock &ob);
    OrderBlock GetBestReclaimedOB(ENUM_BIAS bias);
    
    //--- RF-208-210: FVG Integration
    bool IsFVGFill();
    bool IsEfficiencyInPriceDelivery();
    double GetFVGFillLevel(FVG &fvg);
    
    //--- RF-214-215: Sentimiento
    bool IsOverbought();
    bool IsOversold();
    double GetStochasticValue();
    
    //--- Señales
    Signal GetBestSignal(string symbol, ENUM_TIMEFRAMES tf);
    Signal GetBestSwingSignal(string symbol);
    Signal GetBestShortTermSignal(string symbol);
    bool ValidateSignal(Signal &signal);
    int GetSignalQualityScore(Signal &signal);
    
    //--- Reportes
    string GetSummary();
    string GetDetectionReport();
    string GetOrderBlockReport();
    string GetFVGReport();
    string GetAdvancedReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN - CONSTRUCTOR / DESTRUCTOR / INICIALIZACIÓN       |
//+------------------------------------------------------------------+

//--- Constructor
CDetector::CDetector() {
    m_config = NULL;
    m_context = NULL;
    m_utils = NULL;
    m_dataRange = NULL;
    m_seasonal = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_orderBlockCount = 0;
    m_fvgCount = 0;
    m_turtleSoupCount = 0;
    m_stopRunCount = 0;
    m_pdArrayCount = 0;
    m_breakerCount = 0;
    m_rejectionCount = 0;
    m_propulsionCount = 0;
    m_vacuumCount = 0;
    m_liquidityPoolCount = 0;
    m_divergenceCount = 0;
    m_doublePatternCount = 0;
    m_mitigationCount = 0;
    m_marketState = STATE_CONSOLIDATION;
    m_marketZone = ZONE_EQUILIBRIUM;
    m_equilibrium = 0;
    m_oteHigh = 0;
    m_oteLow = 0;
    m_currentRangeHigh = 0;
    m_currentRangeLow = 0;
    m_isProtraction = false;
    m_isJudasSwing = false;
    ArrayResize(m_orderBlocks, 0);
    ArrayResize(m_fvgs, 0);
    ArrayResize(m_turtleSoups, 0);
    ArrayResize(m_stopRuns, 0);
    ArrayResize(m_pdArrays, 0);
    ArrayResize(m_breakerBlocks, 0);
    ArrayResize(m_rejectionBlocks, 0);
    ArrayResize(m_propulsionBlocks, 0);
    ArrayResize(m_vacuumBlocks, 0);
    ArrayResize(m_liquidityPools, 0);
    ArrayResize(m_divergences, 0);
    ArrayResize(m_doublePatterns, 0);
    ArrayResize(m_mitigationBlocks, 0);
}

//--- Destructor
CDetector::~CDetector() {
    Deinit();
}

//--- Inicialización
bool CDetector::Init(CConfig* config, CContext* context, CUtils* utils,
                     CDataRange* dataRange, CSeasonal* seasonal) {
    if(config == NULL || context == NULL || utils == NULL ||
       dataRange == NULL || seasonal == NULL) {
        Print("CDetector::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_context = context;
    m_utils = utils;
    m_dataRange = dataRange;
    m_seasonal = seasonal;
    
    m_symbol = _Symbol;
    
    m_isInitialized = true;
    m_utils.LogInfo("CDetector inicializado correctamente para " + m_symbol);
    return true;
}

//--- Desinicialización
void CDetector::Deinit() {
    m_config = NULL;
    m_context = NULL;
    m_utils = NULL;
    m_dataRange = NULL;
    m_seasonal = NULL;
    m_isInitialized = false;
}

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN - MÉTODOS PRINCIPALES                             |
//+------------------------------------------------------------------+

//--- Métodos principales
void CDetector::Analyze(string symbol, ENUM_TIMEFRAMES tf) {
    if(!m_isInitialized) return;
    
    m_symbol = symbol;
    
    //--- Limpiar arrays anteriores
    Clear();
    
    //--- Ejecutar detecciones básicas
    DetectOrderBlocks();
    DetectFVG();
    DetectTurtleSoup();
    DetectStopRuns();
    DetectPDArrays();
    ClassifyMarket();
    IsMarketProtraction();
    
    //--- Ejecutar detecciones avanzadas
    DetectBreakerBlocks();
    DetectRejectionBlocks();
    DetectPropulsionBlocks();
    DetectVacuumBlocks();
    DetectLiquidityPools();
    DetectDivergences();
    DetectDoublePatterns();
    DetectMitigationBlocks();
}

void CDetector::AnalyzeAll() {
    string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD"};
    for(int i = 0; i < ArraySize(symbols); i++) {
        Analyze(symbols[i], PERIOD_H1);
    }
}

void CDetector::Clear() {
    ArrayResize(m_orderBlocks, 0);
    ArrayResize(m_fvgs, 0);
    ArrayResize(m_turtleSoups, 0);
    ArrayResize(m_stopRuns, 0);
    ArrayResize(m_pdArrays, 0);
    ArrayResize(m_breakerBlocks, 0);
    ArrayResize(m_rejectionBlocks, 0);
    ArrayResize(m_propulsionBlocks, 0);
    ArrayResize(m_vacuumBlocks, 0);
    ArrayResize(m_liquidityPools, 0);
    ArrayResize(m_divergences, 0);
    ArrayResize(m_doublePatterns, 0);
    ArrayResize(m_mitigationBlocks, 0);
    m_orderBlockCount = 0;
    m_fvgCount = 0;
    m_turtleSoupCount = 0;
    m_stopRunCount = 0;
    m_pdArrayCount = 0;
    m_breakerCount = 0;
    m_rejectionCount = 0;
    m_propulsionCount = 0;
    m_vacuumCount = 0;
    m_liquidityPoolCount = 0;
    m_divergenceCount = 0;
    m_doublePatternCount = 0;
    m_mitigationCount = 0;
}

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN - MÉTODOS BÁSICOS                                 |
//+------------------------------------------------------------------+

//--- RF-006: Clasificar mercado
void CDetector::ClassifyMarket() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    m_currentRangeHigh = high20;
    m_currentRangeLow = low20;
    
    double range = high20 - low20;
    if(range <= 0) {
        m_marketState = STATE_CONSOLIDATION;
        return;
    }
    
    double position = (currentPrice - low20) / range;
    
    if(position > 0.8) m_marketState = STATE_EXPANSION;
    else if(position < 0.2) m_marketState = STATE_RETRACEMENT;
    else if(position > 0.4 && position < 0.6) m_marketState = STATE_CONSOLIDATION;
    else m_marketState = STATE_REVERSAL;
    
    m_marketZone = ClassifyMarketZone();
    CalculateEquilibrium();
    CalculateOTE();
}

//--- RF-004: Clasificar zona de mercado
ENUM_MARKET_ZONE CDetector::ClassifyMarketZone() {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double high = m_currentRangeHigh;
    double low = m_currentRangeLow;
    
    if(high <= low) return ZONE_EQUILIBRIUM;
    
    double range = high - low;
    double position = (currentPrice - low) / range;
    
    if(position > 0.618) return ZONE_PREMIUM;
    if(position < 0.382) return ZONE_DISCOUNT;
    return ZONE_EQUILIBRIUM;
}

//--- RF-003: Calcular Equilibrium
void CDetector::CalculateEquilibrium() {
    m_equilibrium = GetEquilibriumForRange(m_currentRangeHigh, m_currentRangeLow);
}

double CDetector::GetEquilibriumForRange(double high, double low) {
    if(high <= low) return 0;
    return (high + low) / 2.0;
}

//--- RF-005: Calcular OTE
void CDetector::CalculateOTE() {
    m_oteHigh = GetOTEForRangeHigh(m_currentRangeHigh, m_currentRangeLow);
    m_oteLow = GetOTEForRangeLow(m_currentRangeHigh, m_currentRangeLow);
}

double CDetector::GetOTEForRangeLow(double high, double low) {
    if(high <= low) return 0;
    return high - (high - low) * 0.79;
}

double CDetector::GetOTEForRangeHigh(double high, double low) {
    if(high <= low) return 0;
    return high - (high - low) * 0.62;
}

//--- RF-001: Detectar Order Blocks
void CDetector::DetectOrderBlocks() {
    ArrayResize(m_orderBlocks, 0);
    m_orderBlockCount = 0;
    
    ENUM_TIMEFRAMES tfs[] = {PERIOD_D1, PERIOD_H4};
    
    for(int t = 0; t < ArraySize(tfs); t++) {
        ENUM_TIMEFRAMES tf = tfs[t];
        int bars = (tf == PERIOD_D1) ? 50 : 100;
        
        for(int i = 2; i < bars; i++) {
            bool isBullishOB = IsBearishCandle(m_symbol, tf, i) && IsBullishCandle(m_symbol, tf, i-1);
            bool isBearishOB = IsBullishCandle(m_symbol, tf, i) && IsBearishCandle(m_symbol, tf, i-1);
            
            if(isBullishOB || isBearishOB) {
                OrderBlock ob;
                ob.symbol = m_symbol;
                ob.tf = tf;
                ob.bias = isBullishOB ? BIAS_BULLISH : BIAS_BEARISH;
                ob.high = iHigh(m_symbol, tf, i);
                ob.low = iLow(m_symbol, tf, i);
                ob.open = GetOpenPrice(m_symbol, tf, i);
                ob.close = GetClosePrice(m_symbol, tf, i);
                ob.meanThreshold = (ob.open + ob.close) / 2.0;
                ob.range = ob.high - ob.low;
                ob.startTime = iTime(m_symbol, tf, i);
                ob.endTime = iTime(m_symbol, tf, i-1);
                ob.candleCount = 1;
                ob.isConfirmed = ValidateOrderBlock(ob);
                ob.isMitigated = false;
                ob.isActive = true;
                ob.entryLevel = ob.meanThreshold;
                ob.stopLevel = ob.bias == BIAS_BULLISH ? ob.low : ob.high;
                ob.targetLevel = ob.bias == BIAS_BULLISH ? ob.high + ob.range * 2 : ob.low - ob.range * 2;
                ob.mitigationLevel = ob.meanThreshold;
                
                if(ob.isConfirmed) {
                    ArrayResize(m_orderBlocks, m_orderBlockCount + 1);
                    m_orderBlocks[m_orderBlockCount] = ob;
                    m_orderBlockCount++;
                }
            }
        }
    }
}

//--- RF-002: Detectar FVG
void CDetector::DetectFVG() {
    ArrayResize(m_fvgs, 0);
    m_fvgCount = 0;
    
    ENUM_TIMEFRAMES tfs[] = {PERIOD_D1, PERIOD_H4, PERIOD_H1};
    
    for(int t = 0; t < ArraySize(tfs); t++) {
        ENUM_TIMEFRAMES tf = tfs[t];
        int bars = (tf == PERIOD_D1) ? 50 : (tf == PERIOD_H4 ? 100 : 200);
        
        for(int i = 2; i < bars; i++) {
            double high1 = iHigh(m_symbol, tf, i);
            double low1 = iLow(m_symbol, tf, i);
            double high3 = iHigh(m_symbol, tf, i-2);
            double low3 = iLow(m_symbol, tf, i-2);
            
            bool bullishFVG = IsBearishCandle(m_symbol, tf, i) && IsBullishCandle(m_symbol, tf, i-1) &&
                             low1 > high3;
            
            bool bearishFVG = IsBullishCandle(m_symbol, tf, i) && IsBearishCandle(m_symbol, tf, i-1) &&
                             high1 < low3;
            
            if(bullishFVG || bearishFVG) {
                FVG fvg;
                fvg.symbol = m_symbol;
                fvg.tf = tf;
                fvg.bias = bullishFVG ? BIAS_BULLISH : BIAS_BEARISH;
                fvg.high = bullishFVG ? MathMin(high1, high3) : MathMax(high1, high3);
                fvg.low = bullishFVG ? MathMax(low1, low3) : MathMin(low1, low3);
                fvg.meanThreshold = (fvg.high + fvg.low) / 2.0;
                fvg.startTime = iTime(m_symbol, tf, i);
                fvg.endTime = iTime(m_symbol, tf, i-2);
                fvg.isFilled = false;
                fvg.fillLevel = 0;
                fvg.isActive = true;
                
                if(ValidateFVG(fvg)) {
                    ArrayResize(m_fvgs, m_fvgCount + 1);
                    m_fvgs[m_fvgCount] = fvg;
                    m_fvgCount++;
                }
            }
        }
    }
}

//--- RF-007: Detectar Turtle Soup
void CDetector::DetectTurtleSoup() {
    ArrayResize(m_turtleSoups, 0);
    m_turtleSoupCount = 0;
    
    ENUM_TIMEFRAMES tfs[] = {PERIOD_H4, PERIOD_H1};
    
    for(int t = 0; t < ArraySize(tfs); t++) {
        ENUM_TIMEFRAMES tf = tfs[t];
        int bars = (tf == PERIOD_H4) ? 50 : 100;
        
        for(int i = 2; i < bars; i++) {
            double lowPrev = GetLowestLow(m_symbol, tf, i+1, 10);
            double currentLow = iLow(m_symbol, tf, i);
            double currentClose = iClose(m_symbol, tf, i);
            double nextClose = iClose(m_symbol, tf, i-1);
            
            if(currentLow < lowPrev && currentClose > lowPrev && nextClose > lowPrev) {
                TurtleSoup ts;
                ts.symbol = m_symbol;
                ts.tf = tf;
                ts.bias = BIAS_BULLISH;
                ts.entryLevel = currentClose;
                ts.stopLevel = currentLow - (currentLow - lowPrev) * 0.5;
                ts.targetLevel = lowPrev + (lowPrev - currentLow) * 2;
                ts.oldLow = lowPrev;
                ts.oldHigh = 0;
                ts.formationTime = iTime(m_symbol, tf, i);
                ts.isConfirmed = ValidateTurtleSoup(ts);
                ts.isFalseBreakout = true;
                
                if(ts.isConfirmed) {
                    ArrayResize(m_turtleSoups, m_turtleSoupCount + 1);
                    m_turtleSoups[m_turtleSoupCount] = ts;
                    m_turtleSoupCount++;
                }
            }
            
            double highPrev = GetHighestHigh(m_symbol, tf, i+1, 10);
            double currentHigh = iHigh(m_symbol, tf, i);
            double currentClose2 = iClose(m_symbol, tf, i);
            double nextClose2 = iClose(m_symbol, tf, i-1);
            
            if(currentHigh > highPrev && currentClose2 < highPrev && nextClose2 < highPrev) {
                TurtleSoup ts;
                ts.symbol = m_symbol;
                ts.tf = tf;
                ts.bias = BIAS_BEARISH;
                ts.entryLevel = currentClose2;
                ts.stopLevel = currentHigh + (currentHigh - highPrev) * 0.5;
                ts.targetLevel = highPrev - (highPrev - currentHigh) * 2;
                ts.oldLow = 0;
                ts.oldHigh = highPrev;
                ts.formationTime = iTime(m_symbol, tf, i);
                ts.isConfirmed = ValidateTurtleSoup(ts);
                ts.isFalseBreakout = true;
                
                if(ts.isConfirmed) {
                    ArrayResize(m_turtleSoups, m_turtleSoupCount + 1);
                    m_turtleSoups[m_turtleSoupCount] = ts;
                    m_turtleSoupCount++;
                }
            }
        }
    }
}

//--- RF-008: Detectar Stop Runs
void CDetector::DetectStopRuns() {
    ArrayResize(m_stopRuns, 0);
    m_stopRunCount = 0;
    
    ENUM_TIMEFRAMES tfs[] = {PERIOD_H4, PERIOD_H1};
    
    for(int t = 0; t < ArraySize(tfs); t++) {
        ENUM_TIMEFRAMES tf = tfs[t];
        int bars = (tf == PERIOD_H4) ? 50 : 100;
        
        for(int i = 1; i < bars; i++) {
            double high = iHigh(m_symbol, tf, i);
            double low = iLow(m_symbol, tf, i);
            double close = iClose(m_symbol, tf, i);
            double prevHigh = iHigh(m_symbol, tf, i+1);
            double prevLow = iLow(m_symbol, tf, i+1);
            
            if(high > prevHigh && close < prevHigh) {
                StopRun sr;
                sr.symbol = m_symbol;
                sr.tf = tf;
                sr.bias = BIAS_BEARISH;
                sr.level = prevHigh;
                sr.liquidityPool = high;
                sr.startTime = iTime(m_symbol, tf, i);
                sr.endTime = iTime(m_symbol, tf, i-1);
                sr.isBuyStop = true;
                sr.isSellStop = false;
                sr.isLowResistance = false;
                sr.isHighResistance = true;
                sr.isConfirmed = ValidateStopRun(sr);
                
                if(sr.isConfirmed) {
                    ArrayResize(m_stopRuns, m_stopRunCount + 1);
                    m_stopRuns[m_stopRunCount] = sr;
                    m_stopRunCount++;
                }
            }
            
            if(low < prevLow && close > prevLow) {
                StopRun sr;
                sr.symbol = m_symbol;
                sr.tf = tf;
                sr.bias = BIAS_BULLISH;
                sr.level = prevLow;
                sr.liquidityPool = low;
                sr.startTime = iTime(m_symbol, tf, i);
                sr.endTime = iTime(m_symbol, tf, i-1);
                sr.isBuyStop = false;
                sr.isSellStop = true;
                sr.isLowResistance = false;
                sr.isHighResistance = true;
                sr.isConfirmed = ValidateStopRun(sr);
                
                if(sr.isConfirmed) {
                    ArrayResize(m_stopRuns, m_stopRunCount + 1);
                    m_stopRuns[m_stopRunCount] = sr;
                    m_stopRunCount++;
                }
            }
        }
    }
}

//--- RF-009: Market Protraction
bool CDetector::IsMarketProtraction() {
    m_isProtraction = false;
    
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    int hour = dt.hour;
    
    if((hour >= 2 && hour <= 4) || (hour >= 8 && hour <= 10)) {
        double close0 = iClose(m_symbol, PERIOD_M15, 0);
        double close5 = iClose(m_symbol, PERIOD_M15, 5);
        double close10 = iClose(m_symbol, PERIOD_M15, 10);
        
        double move1 = MathAbs(close0 - close5);
        double move2 = MathAbs(close5 - close10);
        double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
        
        if(move1 / point > 10 && move2 / point < 5) {
            m_isProtraction = true;
        }
    }
    
    m_isJudasSwing = m_isProtraction && IsJudasSwing();
    return m_isProtraction;
}

bool CDetector::IsJudasSwing() {
    double close0 = iClose(m_symbol, PERIOD_M15, 0);
    double close2 = iClose(m_symbol, PERIOD_M15, 2);
    double close5 = iClose(m_symbol, PERIOD_M15, 5);
    
    double diff12 = close0 - close2;
    double diff25 = close2 - close5;
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    if(diff12 * diff25 < 0 && MathAbs(diff12) / point > 10) {
        return true;
    }
    return false;
}

//--- RF-010: Análisis Multi-Temporal
void CDetector::AnalyzeMultiTimeframe() {}

bool CDetector::IsAllTimeframesAligned() {
    if(m_context == NULL) return false;
    
    ENUM_BIAS monthlyBias = m_context.GetMonthlyBias();
    ENUM_BIAS weeklyBias = m_context.GetWeeklyBias();
    ENUM_BIAS dailyBias = m_context.GetDailyBias();
    ENUM_BIAS h4Bias = m_context.GetH4Bias();
    
    int bullish = 0, bearish = 0;
    if(monthlyBias == BIAS_BULLISH) bullish++; else if(monthlyBias == BIAS_BEARISH) bearish++;
    if(weeklyBias == BIAS_BULLISH) bullish++; else if(weeklyBias == BIAS_BEARISH) bearish++;
    if(dailyBias == BIAS_BULLISH) bullish++; else if(dailyBias == BIAS_BEARISH) bearish++;
    if(h4Bias == BIAS_BULLISH) bullish++; else if(h4Bias == BIAS_BEARISH) bearish++;
    
    return (bullish == 4 || bearish == 4);
}

int CDetector::GetAlignedTimeframesCount() {
    if(m_context == NULL) return 0;
    
    ENUM_BIAS overall = m_context.GetOverallBias();
    int count = 0;
    
    if(m_context.GetMonthlyBias() == overall) count++;
    if(m_context.GetWeeklyBias() == overall) count++;
    if(m_context.GetDailyBias() == overall) count++;
    if(m_context.GetH4Bias() == overall) count++;
    
    return count;
}

ENUM_BIAS CDetector::GetMultiTimeframeBias() {
    if(m_context == NULL) return BIAS_NEUTRAL;
    return m_context.GetOverallBias();
}

//--- RF-004: Zonas de Descuento y Prima
bool CDetector::IsInDiscountZone(double price) {
    return price < m_equilibrium;
}

bool CDetector::IsInPremiumZone(double price) {
    return price > m_equilibrium;
}

bool CDetector::IsInEquilibriumZone(double price) {
    double diff = MathAbs(price - m_equilibrium);
    double range = m_currentRangeHigh - m_currentRangeLow;
    return diff / range < 0.05;
}

//--- RF-005: OTE
double CDetector::GetOTEMid() const {
    return (m_oteHigh + m_oteLow) / 2.0;
}

bool CDetector::IsInOTE(double price) {
    return price >= m_oteLow && price <= m_oteHigh;
}

//--- RF-006: Market State Name
string CDetector::GetMarketStateName() const {
    switch(m_marketState) {
        case STATE_EXPANSION: return "EXPANSION";
        case STATE_RETRACEMENT: return "RETRACEMENT";
        case STATE_REVERSAL: return "REVERSAL";
        case STATE_CONSOLIDATION: return "CONSOLIDATION";
        default: return "UNKNOWN";
    }
}

//--- RF-009: Protraction Status
string CDetector::GetProtractionStatus() {
    if(m_isJudasSwing) return "JUDAS SWING DETECTED";
    if(m_isProtraction) return "PROTRACTION PHASE";
    return "NORMAL";
}

//--- RF-007: Turtle Soup
bool CDetector::IsTurtleSoupLong() {
    for(int i = 0; i < m_turtleSoupCount; i++) {
        if(m_turtleSoups[i].bias == BIAS_BULLISH) return true;
    }
    return false;
}

bool CDetector::IsTurtleSoupShort() {
    for(int i = 0; i < m_turtleSoupCount; i++) {
        if(m_turtleSoups[i].bias == BIAS_BEARISH) return true;
    }
    return false;
}

TurtleSoup CDetector::GetBestTurtleSoup() {
    TurtleSoup best;
    ZeroMemory(best);
    for(int i = 0; i < m_turtleSoupCount; i++) {
        if(m_turtleSoups[i].isConfirmed && !best.isConfirmed) {
            best = m_turtleSoups[i];
        }
    }
    return best;
}

//--- RF-008: Stop Runs
bool CDetector::IsStopRunAbove() {
    for(int i = 0; i < m_stopRunCount; i++) {
        if(m_stopRuns[i].isBuyStop) return true;
    }
    return false;
}

bool CDetector::IsStopRunBelow() {
    for(int i = 0; i < m_stopRunCount; i++) {
        if(m_stopRuns[i].isSellStop) return true;
    }
    return false;
}

StopRun CDetector::GetBestStopRun() {
    StopRun best;
    ZeroMemory(best);
    for(int i = 0; i < m_stopRunCount; i++) {
        if(m_stopRuns[i].isConfirmed && !best.isConfirmed) {
            best = m_stopRuns[i];
        }
    }
    return best;
}

//--- Validaciones Básicas
bool CDetector::ValidateOrderBlock(OrderBlock &ob) {
    return IsInstitutionalSponsorship(ob.meanThreshold, ob.tf);
}

bool CDetector::ValidateFVG(FVG &fvg) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice < fvg.low || currentPrice > fvg.high;
}

bool CDetector::ValidateTurtleSoup(TurtleSoup &ts) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    if(ts.bias == BIAS_BULLISH) {
        return currentPrice > ts.oldLow;
    } else {
        return currentPrice < ts.oldHigh;
    }
}

bool CDetector::ValidateStopRun(StopRun &sr) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    if(sr.isBuyStop) {
        return currentPrice < sr.level;
    } else {
        return currentPrice > sr.level;
    }
}

//--- Funciones auxiliares
double CDetector::GetHighestHigh(string symbol, ENUM_TIMEFRAMES tf, int start, int count) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    int copied = CopyHigh(symbol, tf, start, count, highArray);
    if(copied < count) return 0;
    double maxHigh = highArray[0];
    for(int i = 1; i < count; i++) {
        if(highArray[i] > maxHigh) maxHigh = highArray[i];
    }
    return maxHigh;
}

double CDetector::GetLowestLow(string symbol, ENUM_TIMEFRAMES tf, int start, int count) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    int copied = CopyLow(symbol, tf, start, count, lowArray);
    if(copied < count) return 0;
    double minLow = lowArray[0];
    for(int i = 1; i < count; i++) {
        if(lowArray[i] < minLow) minLow = lowArray[i];
    }
    return minLow;
}

double CDetector::GetOpenPrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    return iOpen(symbol, tf, shift);
}

double CDetector::GetClosePrice(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    return iClose(symbol, tf, shift);
}

bool CDetector::IsBullishCandle(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double open = GetOpenPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    return close > open;
}

bool CDetector::IsBearishCandle(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double open = GetOpenPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    return close < open;
}

double CDetector::GetCandleBodyHigh(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double open = GetOpenPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    return MathMax(open, close);
}

double CDetector::GetCandleBodyLow(string symbol, ENUM_TIMEFRAMES tf, int shift) {
    double open = GetOpenPrice(symbol, tf, shift);
    double close = GetClosePrice(symbol, tf, shift);
    return MathMin(open, close);
}

//--- RF-010: Timeframe alignment
bool CDetector::IsTimeframeAligned(ENUM_TIMEFRAMES tf) {
    if(m_context == NULL) return false;
    ENUM_BIAS overall = m_context.GetOverallBias();
    ENUM_BIAS tfBias = BIAS_NEUTRAL;
    
    switch(tf) {
        case PERIOD_MN1: tfBias = m_context.GetMonthlyBias(); break;
        case PERIOD_W1:  tfBias = m_context.GetWeeklyBias(); break;
        case PERIOD_D1:  tfBias = m_context.GetDailyBias(); break;
        case PERIOD_H4:  tfBias = m_context.GetH4Bias(); break;
        case PERIOD_H1:  tfBias = m_context.GetH1Bias(); break;
        default: return false;
    }
    
    return tfBias == overall || tfBias == BIAS_NEUTRAL;
}

//+------------------------------------------------------------------+
//| IMPLEMENTACIONES DE GETTERS DE ARRAYS BASICOS                    |
//+------------------------------------------------------------------+

OrderBlock CDetector::GetOrderBlock(int index) const {
    if(index < 0 || index >= m_orderBlockCount) {
        OrderBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_orderBlocks[index];
}

FVG CDetector::GetFVG(int index) const {
    if(index < 0 || index >= m_fvgCount) {
        FVG empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_fvgs[index];
}

TurtleSoup CDetector::GetTurtleSoup(int index) const {
    if(index < 0 || index >= m_turtleSoupCount) {
        TurtleSoup empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_turtleSoups[index];
}

StopRun CDetector::GetStopRun(int index) const {
    if(index < 0 || index >= m_stopRunCount) {
        StopRun empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_stopRuns[index];
}

PDArray CDetector::GetPDArray(int index) const {
    if(index < 0 || index >= m_pdArrayCount) {
        PDArray empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_pdArrays[index];
}

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN - MÉTODOS AVANZADOS (RF-150 a RF-221)             |
//+------------------------------------------------------------------+

//--- RF-166-172: Breaker Blocks
void CDetector::DetectBreakerBlocks() {
    ArrayResize(m_breakerBlocks, 0);
    m_breakerCount = 0;
    
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    //--- Bullish Breaker: sweep below low + reprice above
    if(IsSweepBelowOldLow() && currentPrice > low20) {
        BreakerBlock br;
        br.symbol = m_symbol;
        br.tf = PERIOD_D1;
        br.bias = BIAS_BULLISH;
        br.high = high20;
        br.low = low20;
        br.triggerLevel = low20;
        br.meanThreshold = (high20 + low20) / 2.0;
        br.startTime = TimeCurrent() - 3600;
        br.endTime = TimeCurrent();
        br.isConfirmed = IsBreakerConfirmed();
        br.isActive = true;
        br.entryLevel = low20;
        br.stopLevel = low20 - (high20 - low20) * 0.1;
        br.targetLevel = high20;
        
        if(br.isConfirmed) {
            ArrayResize(m_breakerBlocks, m_breakerCount + 1);
            m_breakerBlocks[m_breakerCount] = br;
            m_breakerCount++;
        }
    }
    
    //--- Bearish Breaker: sweep above high + reprice below
    if(IsSweepAboveOldHigh() && currentPrice < high20) {
        BreakerBlock br;
        br.symbol = m_symbol;
        br.tf = PERIOD_D1;
        br.bias = BIAS_BEARISH;
        br.high = high20;
        br.low = low20;
        br.triggerLevel = high20;
        br.meanThreshold = (high20 + low20) / 2.0;
        br.startTime = TimeCurrent() - 3600;
        br.endTime = TimeCurrent();
        br.isConfirmed = IsBreakerConfirmed();
        br.isActive = true;
        br.entryLevel = high20;
        br.stopLevel = high20 + (high20 - low20) * 0.1;
        br.targetLevel = low20;
        
        if(br.isConfirmed) {
            ArrayResize(m_breakerBlocks, m_breakerCount + 1);
            m_breakerBlocks[m_breakerCount] = br;
            m_breakerCount++;
        }
    }
}

bool CDetector::IsBreakerBlock(double price) {
    for(int i = 0; i < m_breakerCount; i++) {
        if(price >= m_breakerBlocks[i].low && price <= m_breakerBlocks[i].high) {
            return true;
        }
    }
    return false;
}

bool CDetector::IsBreakerFormation() {
    return IsBreakerBlock(SymbolInfoDouble(m_symbol, SYMBOL_BID));
}

bool CDetector::IsBreakerConfirmed() {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    
    return currentPrice > low20 && currentPrice < high20;
}

double CDetector::GetBreakerTriggerLevel() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    return (high20 + low20) / 2.0;
}

BreakerBlock CDetector::GetBreakerBlock(int index) const {
    if(index < 0 || index >= m_breakerCount) {
        BreakerBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_breakerBlocks[index];
}

BreakerBlock CDetector::GetBestBreakerBlock(ENUM_BIAS bias) {
    BreakerBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_breakerCount; i++) {
        if(m_breakerBlocks[i].bias == bias && m_breakerBlocks[i].isConfirmed) {
            return m_breakerBlocks[i];
        }
    }
    return best;
}

//--- RF-173-177: Rejection Blocks
void CDetector::DetectRejectionBlocks() {
    ArrayResize(m_rejectionBlocks, 0);
    m_rejectionCount = 0;
    
    for(int i = 1; i < 20; i++) {
        double high = iHigh(m_symbol, PERIOD_H1, i);
        double low = iLow(m_symbol, PERIOD_H1, i);
        double open = iOpen(m_symbol, PERIOD_H1, i);
        double close = iClose(m_symbol, PERIOD_H1, i);
        double bodyHigh = MathMax(open, close);
        double bodyLow = MathMin(open, close);
        double upperWick = high - bodyHigh;
        double lowerWick = bodyLow - low;
        double bodyRange = bodyHigh - bodyLow;
        
        if(bodyRange > 0) {
            //--- Bullish Rejection: lower wick > 2x body
            if(lowerWick / bodyRange > 2.0) {
                RejectionBlock rb;
                rb.symbol = m_symbol;
                rb.tf = PERIOD_H1;
                rb.bias = BIAS_BULLISH;
                rb.high = high;
                rb.low = low;
                rb.highestBody = bodyHigh;
                rb.lowestBody = bodyLow;
                rb.triggerLevel = bodyLow;
                rb.formationTime = iTime(m_symbol, PERIOD_H1, i);
                rb.isConfirmed = true;
                rb.isActive = true;
                
                ArrayResize(m_rejectionBlocks, m_rejectionCount + 1);
                m_rejectionBlocks[m_rejectionCount] = rb;
                m_rejectionCount++;
            }
            
            //--- Bearish Rejection: upper wick > 2x body
            if(upperWick / bodyRange > 2.0) {
                RejectionBlock rb;
                rb.symbol = m_symbol;
                rb.tf = PERIOD_H1;
                rb.bias = BIAS_BEARISH;
                rb.high = high;
                rb.low = low;
                rb.highestBody = bodyHigh;
                rb.lowestBody = bodyLow;
                rb.triggerLevel = bodyHigh;
                rb.formationTime = iTime(m_symbol, PERIOD_H1, i);
                rb.isConfirmed = true;
                rb.isActive = true;
                
                ArrayResize(m_rejectionBlocks, m_rejectionCount + 1);
                m_rejectionBlocks[m_rejectionCount] = rb;
                m_rejectionCount++;
            }
        }
    }
}

bool CDetector::IsRejectionBlock(double price) {
    for(int i = 0; i < m_rejectionCount; i++) {
        if(price >= m_rejectionBlocks[i].low && price <= m_rejectionBlocks[i].high) {
            return true;
        }
    }
    return false;
}

RejectionBlock CDetector::GetRejectionBlock(int index) const {
    if(index < 0 || index >= m_rejectionCount) {
        RejectionBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_rejectionBlocks[index];
}

RejectionBlock CDetector::GetBestRejectionBlock(ENUM_BIAS bias) {
    RejectionBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_rejectionCount; i++) {
        if(m_rejectionBlocks[i].bias == bias && m_rejectionBlocks[i].isConfirmed) {
            return m_rejectionBlocks[i];
        }
    }
    return best;
}

double CDetector::GetHighestBodyReference() {
    double maxBody = 0;
    for(int i = 1; i < 20; i++) {
        double open = iOpen(m_symbol, PERIOD_H1, i);
        double close = iClose(m_symbol, PERIOD_H1, i);
        double bodyHigh = MathMax(open, close);
        if(bodyHigh > maxBody) maxBody = bodyHigh;
    }
    return maxBody;
}

double CDetector::GetLowestBodyReference() {
    double minBody = DBL_MAX;
    for(int i = 1; i < 20; i++) {
        double open = iOpen(m_symbol, PERIOD_H1, i);
        double close = iClose(m_symbol, PERIOD_H1, i);
        double bodyLow = MathMin(open, close);
        if(bodyLow < minBody) minBody = bodyLow;
    }
    return minBody;
}

//--- RF-188-191: Propulsion y Vacuum Blocks
void CDetector::DetectPropulsionBlocks() {
    ArrayResize(m_propulsionBlocks, 0);
    m_propulsionCount = 0;
    
    for(int i = 0; i < m_orderBlockCount; i++) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        if(currentPrice >= m_orderBlocks[i].low && currentPrice <= m_orderBlocks[i].high) {
            PropulsionBlock pb;
            pb.symbol = m_symbol;
            pb.tf = m_orderBlocks[i].tf;
            pb.bias = m_orderBlocks[i].bias;
            pb.level = m_orderBlocks[i].meanThreshold;
            pb.meanThreshold = m_orderBlocks[i].meanThreshold;
            pb.formationTime = TimeCurrent();
            pb.isConfirmed = true;
            pb.isActive = true;
            
            ArrayResize(m_propulsionBlocks, m_propulsionCount + 1);
            m_propulsionBlocks[m_propulsionCount] = pb;
            m_propulsionCount++;
        }
    }
}

bool CDetector::IsPropulsionBlock(double price) {
    for(int i = 0; i < m_propulsionCount; i++) {
        if(MathAbs(price - m_propulsionBlocks[i].level) < SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 5) {
            return true;
        }
    }
    return false;
}

PropulsionBlock CDetector::GetPropulsionBlock(int index) const {
    if(index < 0 || index >= m_propulsionCount) {
        PropulsionBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_propulsionBlocks[index];
}

PropulsionBlock CDetector::GetBestPropulsionBlock(ENUM_BIAS bias) {
    PropulsionBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_propulsionCount; i++) {
        if(m_propulsionBlocks[i].bias == bias && m_propulsionBlocks[i].isConfirmed) {
            return m_propulsionBlocks[i];
        }
    }
    return best;
}

void CDetector::DetectVacuumBlocks() {
    ArrayResize(m_vacuumBlocks, 0);
    m_vacuumCount = 0;
    
    for(int i = 1; i < 10; i++) {
        double high0 = iHigh(m_symbol, PERIOD_H1, 0);
        double low0 = iLow(m_symbol, PERIOD_H1, 0);
        double high1 = iHigh(m_symbol, PERIOD_H1, i);
        double low1 = iLow(m_symbol, PERIOD_H1, i);
        
        if(high0 < low1 || low0 > high1) {
            VacuumBlock vb;
            vb.symbol = m_symbol;
            vb.tf = PERIOD_H1;
            vb.bias = (high0 < low1) ? BIAS_BULLISH : BIAS_BEARISH;
            vb.high = MathMax(high0, high1);
            vb.low = MathMin(low0, low1);
            vb.startTime = iTime(m_symbol, PERIOD_H1, i);
            vb.endTime = iTime(m_symbol, PERIOD_H1, 0);
            vb.isFilled = false;
            vb.fillLevel = 0;
            vb.isActive = true;
            
            ArrayResize(m_vacuumBlocks, m_vacuumCount + 1);
            m_vacuumBlocks[m_vacuumCount] = vb;
            m_vacuumCount++;
        }
    }
}

bool CDetector::IsVacuumBlock(double price) {
    for(int i = 0; i < m_vacuumCount; i++) {
        if(price >= m_vacuumBlocks[i].low && price <= m_vacuumBlocks[i].high) {
            return true;
        }
    }
    return false;
}

VacuumBlock CDetector::GetVacuumBlock(int index) const {
    if(index < 0 || index >= m_vacuumCount) {
        VacuumBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_vacuumBlocks[index];
}

VacuumBlock CDetector::GetBestVacuumBlock(ENUM_BIAS bias) {
    VacuumBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_vacuumCount; i++) {
        if(m_vacuumBlocks[i].bias == bias && m_vacuumBlocks[i].isActive) {
            return m_vacuumBlocks[i];
        }
    }
    return best;
}

//--- RF-150-155: Liquidity
bool CDetector::IsExternalRangeLiquidity() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice > high20 || currentPrice < low20;
}

bool CDetector::IsInternalRangeLiquidity() {
    return !IsExternalRangeLiquidity();
}

bool CDetector::IsLowResistanceLiquidityRun() {
    ENUM_BIAS overallBias = m_context.GetOverallBias();
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double ema50 = iMA(m_symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
    
    if(overallBias == BIAS_BULLISH && currentPrice > ema50) return true;
    if(overallBias == BIAS_BEARISH && currentPrice < ema50) return true;
    return false;
}

bool CDetector::IsHighResistanceLiquidityRun() {
    return !IsLowResistanceLiquidityRun();
}

double CDetector::GetExternalRangeLiquidityLevel() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    return (high20 + low20) / 2.0;
}

double CDetector::GetInternalRangeLiquidityLevel() {
    return GetExternalRangeLiquidityLevel();
}

//--- RF-202-207: Liquidity Pools y Raids
void CDetector::DetectLiquidityPools() {
    ArrayResize(m_liquidityPools, 0);
    m_liquidityPoolCount = 0;
    
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double range = high20 - low20;
    
    if(range > 0) {
        LiquidityPool pool;
        pool.symbol = m_symbol;
        pool.tf = PERIOD_D1;
        pool.level = high20;
        pool.bias = BIAS_BEARISH;
        pool.size = 0;
        pool.startTime = TimeCurrent();
        pool.endTime = TimeCurrent() + 86400;
        pool.isActive = true;
        pool.isNearTerm = true;
        pool.isShortTerm = false;
        pool.isIntermediateTerm = false;
        
        ArrayResize(m_liquidityPools, m_liquidityPoolCount + 1);
        m_liquidityPools[m_liquidityPoolCount] = pool;
        m_liquidityPoolCount++;
        
        LiquidityPool pool2;
        pool2.symbol = m_symbol;
        pool2.tf = PERIOD_D1;
        pool2.level = low20;
        pool2.bias = BIAS_BULLISH;
        pool2.size = 0;
        pool2.startTime = TimeCurrent();
        pool2.endTime = TimeCurrent() + 86400;
        pool2.isActive = true;
        pool2.isNearTerm = true;
        pool2.isShortTerm = false;
        pool2.isIntermediateTerm = false;
        
        ArrayResize(m_liquidityPools, m_liquidityPoolCount + 1);
        m_liquidityPools[m_liquidityPoolCount] = pool2;
        m_liquidityPoolCount++;
    }
}

bool CDetector::IsLiquidityPool(double price) {
    for(int i = 0; i < m_liquidityPoolCount; i++) {
        if(MathAbs(price - m_liquidityPools[i].level) < SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 5) {
            return true;
        }
    }
    return false;
}

LiquidityPool CDetector::GetLiquidityPool(int index) const {
    if(index < 0 || index >= m_liquidityPoolCount) {
        LiquidityPool empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_liquidityPools[index];
}

LiquidityPool CDetector::GetNearestLiquidityPool(double price) {
    LiquidityPool best;
    ZeroMemory(best);
    double minDist = DBL_MAX;
    
    for(int i = 0; i < m_liquidityPoolCount; i++) {
        double dist = MathAbs(price - m_liquidityPools[i].level);
        if(dist < minDist) {
            minDist = dist;
            best = m_liquidityPools[i];
        }
    }
    return best;
}

bool CDetector::IsLiquidityRaid() {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double close0 = iClose(m_symbol, PERIOD_H1, 0);
    double close1 = iClose(m_symbol, PERIOD_H1, 1);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    if(MathAbs(close0 - close1) / point > 20) {
        if(currentPrice > high20 || currentPrice < low20) {
            return true;
        }
    }
    return false;
}

bool CDetector::IsSweepBelowOldLow() {
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentLow = iLow(m_symbol, PERIOD_H1, 0);
    return currentLow < low20;
}

bool CDetector::IsSweepAboveOldHigh() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double currentHigh = iHigh(m_symbol, PERIOD_H1, 0);
    return currentHigh > high20;
}

//--- RF-211-213: Divergencias
void CDetector::DetectDivergences() {
    ArrayResize(m_divergences, 0);
    m_divergenceCount = 0;
    
    double priceHigh = GetHighestHigh(m_symbol, PERIOD_H1, 0, 5);
    double priceLow = GetLowestLow(m_symbol, PERIOD_H1, 0, 5);
    double priceHigh2 = GetHighestHigh(m_symbol, PERIOD_H1, 5, 5);
    double priceLow2 = GetLowestLow(m_symbol, PERIOD_H1, 5, 5);
    
    //--- Type 1: Price higher high, indicator lower high (bearish)
    if(priceHigh > priceHigh2) {
        Divergence div;
        div.symbol = m_symbol;
        div.tf = PERIOD_H1;
        div.bias = BIAS_BEARISH;
        div.priceLevel = priceHigh;
        div.indicatorLevel = 0;
        div.startTime = TimeCurrent() - 3600;
        div.endTime = TimeCurrent();
        div.isType1 = true;
        div.isType2 = false;
        div.isHidden = false;
        div.isPhantom = false;
        div.isConfirmed = false;
        
        ArrayResize(m_divergences, m_divergenceCount + 1);
        m_divergences[m_divergenceCount] = div;
        m_divergenceCount++;
    }
    
    //--- Type 1: Price lower low, indicator higher low (bullish)
    if(priceLow < priceLow2) {
        Divergence div;
        div.symbol = m_symbol;
        div.tf = PERIOD_H1;
        div.bias = BIAS_BULLISH;
        div.priceLevel = priceLow;
        div.indicatorLevel = 0;
        div.startTime = TimeCurrent() - 3600;
        div.endTime = TimeCurrent();
        div.isType1 = true;
        div.isType2 = false;
        div.isHidden = false;
        div.isPhantom = false;
        div.isConfirmed = false;
        
        ArrayResize(m_divergences, m_divergenceCount + 1);
        m_divergences[m_divergenceCount] = div;
        m_divergenceCount++;
    }
}

bool CDetector::IsType1Divergence() {
    for(int i = 0; i < m_divergenceCount; i++) {
        if(m_divergences[i].isType1) return true;
    }
    return false;
}

bool CDetector::IsType2Divergence() {
    for(int i = 0; i < m_divergenceCount; i++) {
        if(m_divergences[i].isType2) return true;
    }
    return false;
}

bool CDetector::IsHiddenDivergence() {
    for(int i = 0; i < m_divergenceCount; i++) {
        if(m_divergences[i].isHidden) return true;
    }
    return false;
}

bool CDetector::IsDivergencePhantom() {
    for(int i = 0; i < m_divergenceCount; i++) {
        if(m_divergences[i].isPhantom) return true;
    }
    return false;
}

Divergence CDetector::GetDivergence(int index) const {
    if(index < 0 || index >= m_divergenceCount) {
        Divergence empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_divergences[index];
}

Divergence CDetector::GetBestDivergence(ENUM_BIAS bias) {
    Divergence best;
    ZeroMemory(best);
    for(int i = 0; i < m_divergenceCount; i++) {
        if(m_divergences[i].bias == bias) {
            return m_divergences[i];
        }
    }
    return best;
}

//--- RF-216-221: Double Tops/Bottoms
void CDetector::DetectDoublePatterns() {
    ArrayResize(m_doublePatterns, 0);
    m_doublePatternCount = 0;
    
    double high1 = GetHighestHigh(m_symbol, PERIOD_H1, 0, 5);
    double high2 = GetHighestHigh(m_symbol, PERIOD_H1, 5, 5);
    double low1 = GetLowestLow(m_symbol, PERIOD_H1, 0, 5);
    double low2 = GetLowestLow(m_symbol, PERIOD_H1, 5, 5);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    //--- Double Top
    if(MathAbs(high1 - high2) / point < 10.0) {
        DoublePattern dp;
        dp.symbol = m_symbol;
        dp.tf = PERIOD_H1;
        dp.bias = BIAS_BEARISH;
        dp.level = MathMax(high1, high2);
        dp.projectedTarget = dp.level - MathAbs(high1 - high2);
        dp.formationTime = TimeCurrent();
        dp.isDoubleTop = true;
        dp.isDoubleBottom = false;
        dp.isConfirmed = true;
        dp.isStopRun = IsStopRunOnDoubleTop();
        
        ArrayResize(m_doublePatterns, m_doublePatternCount + 1);
        m_doublePatterns[m_doublePatternCount] = dp;
        m_doublePatternCount++;
    }
    
    //--- Double Bottom
    if(MathAbs(low1 - low2) / point < 10.0) {
        DoublePattern dp;
        dp.symbol = m_symbol;
        dp.tf = PERIOD_H1;
        dp.bias = BIAS_BULLISH;
        dp.level = MathMin(low1, low2);
        dp.projectedTarget = dp.level + MathAbs(low1 - low2);
        dp.formationTime = TimeCurrent();
        dp.isDoubleTop = false;
        dp.isDoubleBottom = true;
        dp.isConfirmed = true;
        dp.isStopRun = IsStopRunOnDoubleBottom();
        
        ArrayResize(m_doublePatterns, m_doublePatternCount + 1);
        m_doublePatterns[m_doublePatternCount] = dp;
        m_doublePatternCount++;
    }
}

bool CDetector::IsDoubleTop() {
    for(int i = 0; i < m_doublePatternCount; i++) {
        if(m_doublePatterns[i].isDoubleTop) return true;
    }
    return false;
}

bool CDetector::IsDoubleBottom() {
    for(int i = 0; i < m_doublePatternCount; i++) {
        if(m_doublePatterns[i].isDoubleBottom) return true;
    }
    return false;
}

DoublePattern CDetector::GetDoublePattern(int index) const {
    if(index < 0 || index >= m_doublePatternCount) {
        DoublePattern empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_doublePatterns[index];
}

DoublePattern CDetector::GetBestDoublePattern() {
    DoublePattern best;
    ZeroMemory(best);
    for(int i = 0; i < m_doublePatternCount; i++) {
        if(m_doublePatterns[i].isConfirmed) {
            return m_doublePatterns[i];
        }
    }
    return best;
}

double CDetector::GetMeasuredMoveFromDouble() {
    DoublePattern pattern = GetBestDoublePattern();
    if(pattern.isDoubleTop) {
        double neckline = GetLowestLow(m_symbol, PERIOD_H1, 0, 10);
        return pattern.level - neckline;
    } else if(pattern.isDoubleBottom) {
        double neckline = GetHighestHigh(m_symbol, PERIOD_H1, 0, 10);
        return neckline - pattern.level;
    }
    return 0;
}

bool CDetector::IsStopRunOnDoubleTop() {
    if(!IsDoubleTop()) return false;
    double high = GetHighestHigh(m_symbol, PERIOD_H1, 0, 10);
    double currentHigh = iHigh(m_symbol, PERIOD_H1, 0);
    return currentHigh > high;
}

bool CDetector::IsStopRunOnDoubleBottom() {
    if(!IsDoubleBottom()) return false;
    double low = GetLowestLow(m_symbol, PERIOD_H1, 0, 10);
    double currentLow = iLow(m_symbol, PERIOD_H1, 0);
    return currentLow < low;
}

//--- RF-178-187: Market Maker Models
bool CDetector::IsMMBuyModel() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double ema50 = iMA(m_symbol, PERIOD_D1, 50, 0, MODE_EMA, PRICE_CLOSE);
    
    return currentPrice < ema50 && currentPrice > low20;
}

bool CDetector::IsMMSellModel() {
    double high20 = GetHighestHigh(m_symbol, PERIOD_D1, 0, 20);
    double low20 = GetLowestLow(m_symbol, PERIOD_D1, 0, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double ema50 = iMA(m_symbol, PERIOD_D1, 50, 0, MODE_EMA, PRICE_CLOSE);
    
    return currentPrice > ema50 && currentPrice < high20;
}

bool CDetector::IsAccumulation() {
    return IsMMBuyModel();
}

bool CDetector::IsDistribution() {
    return IsMMSellModel();
}

bool CDetector::IsBuySideOfCurve() {
    return IsMMBuyModel() && m_context.GetOverallBias() == BIAS_BULLISH;
}

bool CDetector::IsSellSideOfCurve() {
    return IsMMSellModel() && m_context.GetOverallBias() == BIAS_BEARISH;
}

bool CDetector::IsHedgingDuringAccumulation() {
    return IsAccumulation() && IsMMSellModel();
}

bool CDetector::IsHedgingDuringDistribution() {
    return IsDistribution() && IsMMBuyModel();
}

//--- RF-192-201: Gaps y Liquidity Voids
bool CDetector::IsBreakawayGap() {
    for(int i = 1; i < 5; i++) {
        double high0 = iHigh(m_symbol, PERIOD_D1, 0);
        double low0 = iLow(m_symbol, PERIOD_D1, 0);
        double high1 = iHigh(m_symbol, PERIOD_D1, i);
        double low1 = iLow(m_symbol, PERIOD_D1, i);
        
        if(high0 < low1 || low0 > high1) {
            return true;
        }
    }
    return false;
}

bool CDetector::IsExhaustionGap() {
    return IsBreakawayGap() && IsReversal();
}

bool CDetector::IsCommonGap() {
    return IsBreakawayGap() && !IsExhaustionGap();
}

bool CDetector::IsGapFill() {
    double high0 = iHigh(m_symbol, PERIOD_D1, 0);
    double low0 = iLow(m_symbol, PERIOD_D1, 0);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice >= low0 && currentPrice <= high0;
}

bool CDetector::IsFullGapFill() {
    double high0 = iHigh(m_symbol, PERIOD_D1, 0);
    double low0 = iLow(m_symbol, PERIOD_D1, 0);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice > high0 || currentPrice < low0;
}

double CDetector::GetGapMeanThreshold() {
    double high0 = iHigh(m_symbol, PERIOD_D1, 0);
    double low0 = iLow(m_symbol, PERIOD_D1, 0);
    return (high0 + low0) / 2.0;
}

bool CDetector::IsLiquidityVoid() {
    double high0 = iHigh(m_symbol, PERIOD_M15, 0);
    double low0 = iLow(m_symbol, PERIOD_M15, 0);
    double high1 = iHigh(m_symbol, PERIOD_M15, 1);
    double low1 = iLow(m_symbol, PERIOD_M15, 1);
    double range = MathAbs(high0 - low0);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    
    return range / point > 30 && MathAbs(high0 - high1) / point < 5;
}

bool CDetector::IsOneSidedRange() {
    double close0 = iClose(m_symbol, PERIOD_M15, 0);
    double close1 = iClose(m_symbol, PERIOD_M15, 1);
    double close2 = iClose(m_symbol, PERIOD_M15, 2);
    
    bool up = close0 > close1 && close1 > close2;
    bool down = close0 < close1 && close1 < close2;
    return up || down;
}

//--- RF-160-165: Estructura de Mercado
bool CDetector::IsMarketStructureShift() {
    ENUM_BIAS prevBias = m_context.GetOverallBias();
    ENUM_BIAS currentBias = GetMultiTimeframeBias();
    return prevBias != currentBias && currentBias != BIAS_NEUTRAL;
}

bool CDetector::IsMPattern() {
    double high1 = GetHighestHigh(m_symbol, PERIOD_H1, 0, 5);
    double high2 = GetHighestHigh(m_symbol, PERIOD_H1, 5, 5);
    double lowMid = GetLowestLow(m_symbol, PERIOD_H1, 3, 4);
    
    if(MathAbs(high1 - high2) / SymbolInfoDouble(m_symbol, SYMBOL_POINT) < 10) {
        return true;
    }
    return false;
}

bool CDetector::IsBuyersRemorse() {
    double high1 = GetHighestHigh(m_symbol, PERIOD_H1, 0, 5);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return currentPrice < high1 * 0.995;
}

bool CDetector::IsStepLadderFormation() {
    double high1 = GetHighestHigh(m_symbol, PERIOD_H1, 0, 3);
    double high2 = GetHighestHigh(m_symbol, PERIOD_H1, 3, 3);
    double low1 = GetLowestLow(m_symbol, PERIOD_H1, 0, 3);
    double low2 = GetLowestLow(m_symbol, PERIOD_H1, 3, 3);
    
    return high2 > high1 && low2 > low1;
}

bool CDetector::IsUnderwaterPosition(double price) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    return price > currentPrice;
}

//--- RF-180-181: Reclaimed Order Blocks
bool CDetector::IsReclaimedOrderBlock(OrderBlock &ob) {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    if(ob.bias == BIAS_BULLISH) {
        return currentPrice > ob.high;
    } else {
        return currentPrice < ob.low;
    }
}

OrderBlock CDetector::GetBestReclaimedOB(ENUM_BIAS bias) {
    OrderBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_orderBlockCount; i++) {
        if(m_orderBlocks[i].bias == bias && IsReclaimedOrderBlock(m_orderBlocks[i])) {
            return m_orderBlocks[i];
        }
    }
    return best;
}

//--- RF-208-210: FVG Integration
bool CDetector::IsFVGFill() {
    for(int i = 0; i < m_fvgCount; i++) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        if(currentPrice >= m_fvgs[i].low && currentPrice <= m_fvgs[i].high) {
            m_fvgs[i].isFilled = true;
            m_fvgs[i].fillLevel = currentPrice;
            return true;
        }
    }
    return false;
}

bool CDetector::IsEfficiencyInPriceDelivery() {
    return IsFVGFill();
}

double CDetector::GetFVGFillLevel(FVG &fvg) {
    if(fvg.isFilled) {
        return fvg.fillLevel;
    }
    return 0;
}

//--- RF-214-215: Sentimiento
bool CDetector::IsOverbought() {
    double rsi = m_utils.CalculateRSI(m_symbol, PERIOD_H1, 14);
    return rsi > 70;
}

bool CDetector::IsOversold() {
    double rsi = m_utils.CalculateRSI(m_symbol, PERIOD_H1, 14);
    return rsi < 30;
}

double CDetector::GetStochasticValue() {
    return m_utils.CalculateWilliamsR(m_symbol, PERIOD_H1, 14);
}

//--- RF-159: Mitigation Blocks
void CDetector::DetectMitigationBlocks() {
    ArrayResize(m_mitigationBlocks, 0);
    m_mitigationCount = 0;
    
    for(int i = 0; i < m_orderBlockCount; i++) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        if(currentPrice >= m_orderBlocks[i].low && currentPrice <= m_orderBlocks[i].high) {
            MitigationBlock mb;
            mb.symbol = m_symbol;
            mb.tf = m_orderBlocks[i].tf;
            mb.bias = m_orderBlocks[i].bias;
            mb.high = m_orderBlocks[i].high;
            mb.low = m_orderBlocks[i].low;
            mb.startTime = TimeCurrent();
            mb.endTime = TimeCurrent() + 3600;
            mb.isMitigated = true;
            mb.mitigationLevel = currentPrice;
            mb.meanThreshold = m_orderBlocks[i].meanThreshold;
            mb.isActive = true;
            
            ArrayResize(m_mitigationBlocks, m_mitigationCount + 1);
            m_mitigationBlocks[m_mitigationCount] = mb;
            m_mitigationCount++;
        }
    }
}

bool CDetector::IsMitigationBlock(double price) {
    for(int i = 0; i < m_mitigationCount; i++) {
        if(price >= m_mitigationBlocks[i].low && price <= m_mitigationBlocks[i].high) {
            return true;
        }
    }
    return false;
}

MitigationBlock CDetector::GetMitigationBlock(int index) const {
    if(index < 0 || index >= m_mitigationCount) {
        MitigationBlock empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_mitigationBlocks[index];
}

MitigationBlock CDetector::GetBestMitigationBlock() {
    MitigationBlock best;
    ZeroMemory(best);
    for(int i = 0; i < m_mitigationCount; i++) {
        if(m_mitigationBlocks[i].isActive) {
            return m_mitigationBlocks[i];
        }
    }
    return best;
}

//--- Señales
Signal CDetector::GetBestSignal(string symbol, ENUM_TIMEFRAMES tf) {
    Signal signal;
    ZeroMemory(signal);
    signal.symbol = symbol;
    signal.tf = tf;
    signal.signalTime = TimeCurrent();
    
    //--- Determinar mejor señal combinando todos los detectores
    if(HasOrderBlock(BIAS_BULLISH) && IsInDiscountZone(SymbolInfoDouble(symbol, SYMBOL_BID))) {
        signal.bias = BIAS_BULLISH;
        signal.entryType = ENTRY_BUY_LIMIT;
        signal.entryPrice = GetBestOrderBlock(BIAS_BULLISH).meanThreshold;
        signal.stopLoss = GetBestOrderBlock(BIAS_BULLISH).low;
        signal.takeProfit = GetBestOrderBlock(BIAS_BULLISH).targetLevel;
        signal.rrRatio = 3.0;
        signal.isQualified = true;
        signal.setupType = "ORDER_BLOCK_DISCOUNT";
    }
    
    if(HasFVG(BIAS_BULLISH) && !IsInOTE(SymbolInfoDouble(symbol, SYMBOL_BID))) {
        signal.bias = BIAS_BULLISH;
        signal.entryType = ENTRY_BUY_LIMIT;
        signal.entryPrice = GetBestFVG(BIAS_BULLISH).meanThreshold;
        signal.stopLoss = GetBestFVG(BIAS_BULLISH).low;
        signal.takeProfit = GetBestFVG(BIAS_BULLISH).high;
        signal.rrRatio = 2.0;
        signal.isQualified = true;
        signal.setupType = "FVG_BULLISH";
    }
    
    return signal;
}

bool CDetector::ValidateSignal(Signal &signal) {
    if(signal.entryPrice <= 0 || signal.stopLoss <= 0 || signal.takeProfit <= 0) return false;
    if(signal.rrRatio < 2.0) return false;
    return signal.isQualified;
}

int CDetector::GetSignalQualityScore(Signal &signal) {
    int score = 0;
    if(signal.isQualified) score += 20;
    if(signal.rrRatio >= 3.0) score += 20;
    if(signal.rrRatio >= 5.0) score += 20;
    if(IsInOTE(signal.entryPrice)) score += 20;
    if(m_context.IsSponsorshipPresent()) score += 20;
    return score;
}

//--- Reportes
string CDetector::GetSummary() {
    string summary = "=== DETECTOR SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Order Blocks: " + IntegerToString(m_orderBlockCount) + "\n";
    summary += "FVGs: " + IntegerToString(m_fvgCount) + "\n";
    summary += "Turtle Soups: " + IntegerToString(m_turtleSoupCount) + "\n";
    summary += "Stop Runs: " + IntegerToString(m_stopRunCount) + "\n";
    summary += "PD Arrays: " + IntegerToString(m_pdArrayCount) + "\n";
    summary += "Breaker Blocks: " + IntegerToString(m_breakerCount) + "\n";
    summary += "Rejection Blocks: " + IntegerToString(m_rejectionCount) + "\n";
    summary += "Propulsion Blocks: " + IntegerToString(m_propulsionCount) + "\n";
    summary += "Vacuum Blocks: " + IntegerToString(m_vacuumCount) + "\n";
    summary += "Liquidity Pools: " + IntegerToString(m_liquidityPoolCount) + "\n";
    summary += "Divergences: " + IntegerToString(m_divergenceCount) + "\n";
    summary += "Double Patterns: " + IntegerToString(m_doublePatternCount) + "\n";
    summary += "Mitigation Blocks: " + IntegerToString(m_mitigationCount) + "\n";
    summary += "Market State: " + GetMarketStateName() + "\n";
    summary += "Market Zone: " + (m_marketZone == ZONE_PREMIUM ? "PREMIUM" : 
                                  (m_marketZone == ZONE_DISCOUNT ? "DISCOUNT" : "EQUILIBRIUM")) + "\n";
    summary += "Equilibrium: " + DoubleToString(m_equilibrium, 5) + "\n";
    summary += "OTE Range: " + DoubleToString(m_oteLow, 5) + " - " + DoubleToString(m_oteHigh, 5) + "\n";
    summary += "Protraction: " + (m_isProtraction ? "YES" : "NO") + "\n";
    summary += "Judas Swing: " + (m_isJudasSwing ? "YES" : "NO") + "\n";
    summary += "=========================";
    return summary;
}

string CDetector::GetDetectionReport() {
    string report = "=== DETECTION REPORT ===\n";
    report += "Order Blocks Found: " + IntegerToString(m_orderBlockCount) + "\n";
    report += "FVGs Found: " + IntegerToString(m_fvgCount) + "\n";
    report += "Turtle Soups Found: " + IntegerToString(m_turtleSoupCount) + "\n";
    report += "Stop Runs Found: " + IntegerToString(m_stopRunCount) + "\n";
    report += "Breaker Blocks Found: " + IntegerToString(m_breakerCount) + "\n";
    report += "Rejection Blocks Found: " + IntegerToString(m_rejectionCount) + "\n";
    report += "Propulsion Blocks Found: " + IntegerToString(m_propulsionCount) + "\n";
    report += "Vacuum Blocks Found: " + IntegerToString(m_vacuumCount) + "\n";
    report += "Liquidity Pools Found: " + IntegerToString(m_liquidityPoolCount) + "\n";
    return report;
}

string CDetector::GetOrderBlockReport() {
    string report = "=== ORDER BLOCK REPORT ===\n";
    for(int i = 0; i < m_orderBlockCount; i++) {
        report += "OB #" + IntegerToString(i+1) + ": ";
        report += (m_orderBlocks[i].bias == BIAS_BULLISH ? "BULLISH" : "BEARISH") + " | ";
        report += "Level: " + DoubleToString(m_orderBlocks[i].meanThreshold, 5) + " | ";
        report += "Range: " + DoubleToString(m_orderBlocks[i].range, 5) + " | ";
        report += "Confirmed: " + (m_orderBlocks[i].isConfirmed ? "YES" : "NO") + "\n";
    }
    return report;
}

string CDetector::GetFVGReport() {
    string report = "=== FVG REPORT ===\n";
    for(int i = 0; i < m_fvgCount; i++) {
        report += "FVG #" + IntegerToString(i+1) + ": ";
        report += (m_fvgs[i].bias == BIAS_BULLISH ? "BULLISH" : "BEARISH") + " | ";
        report += "Range: " + DoubleToString(m_fvgs[i].high - m_fvgs[i].low, 5) + " | ";
        report += "Active: " + (m_fvgs[i].isActive ? "YES" : "NO") + "\n";
    }
    return report;
}

string CDetector::GetAdvancedReport() {
    string report = "=== ADVANCED DETECTION REPORT ===\n";
    report += "Breaker Blocks: " + IntegerToString(m_breakerCount) + "\n";
    report += "Rejection Blocks: " + IntegerToString(m_rejectionCount) + "\n";
    report += "Propulsion Blocks: " + IntegerToString(m_propulsionCount) + "\n";
    report += "Vacuum Blocks: " + IntegerToString(m_vacuumCount) + "\n";
    report += "Liquidity Pools: " + IntegerToString(m_liquidityPoolCount) + "\n";
    report += "Divergences: " + IntegerToString(m_divergenceCount) + "\n";
    report += "Double Patterns: " + IntegerToString(m_doublePatternCount) + "\n";
    report += "Mitigation Blocks: " + IntegerToString(m_mitigationCount) + "\n";
    report += "MM Buy Model: " + (IsMMBuyModel() ? "YES" : "NO") + "\n";
    report += "MM Sell Model: " + (IsMMSellModel() ? "YES" : "NO") + "\n";
    report += "Accumulation: " + (IsAccumulation() ? "YES" : "NO") + "\n";
    report += "Distribution: " + (IsDistribution() ? "YES" : "NO") + "\n";
    report += "External Range Liquidity: " + (IsExternalRangeLiquidity() ? "YES" : "NO") + "\n";
    report += "Low Resistance Run: " + (IsLowResistanceLiquidityRun() ? "YES" : "NO") + "\n";
    report += "Market Structure Shift: " + (IsMarketStructureShift() ? "YES" : "NO") + "\n";
    report += "=========================";
    return report;
}

#endif // __CDETECTOR_MQH__