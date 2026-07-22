//+--------------------------------------------------------------------+
//|                                                     CDataRange.mqh |
//|                         HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                    Copyright 2026, HunterIPDA Team |
//+--------------------------------------------------------------------+
//+--------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                             |
//+--------------------------------------------------------------------+
//| Este módulo gestiona los IPDA Data Ranges y Quarterly Shifts:      |
//| - Cálculo de Data Ranges (20, 40, 60 días)                         |
//| - Look Back y Cast Forward                                         |
//| - Detección de Quarterly Shifts                                    |
//| - Institutional Order Flow (IOF)                                   |
//| - Open Float y Liquidity Pools                                     |
//| - Análisis de acumulación/distribución                             |
//|                                                                    |
//| RFs asociados:                                                     |
//|   RF-222: Detección de Quarterly Market Shift                      |
//|   RF-223: Cálculo de IPDA Data Ranges                              |
//|   RF-224: Look Back Analysis                                       |
//|   RF-225: Cast Forward Projection                                  |
//|   RF-226: Calibración por Market Structure Shift                   |
//|   RF-227: Smart Money Accumulation para Buy Programs               |
//|   RF-228: Smart Money Distribution para Sell Programs              |
//|   RF-229: Determinación de Institutional Order Flow (IOF)          |
//|   RF-230: Filtro de Setup por Data Range                           |
//|   RF-231: Identificación de Open Float                             |
//|   RF-232: Mapeo de Buy Stops                                       |
//|   RF-233: Mapeo de Sell Stops                                      |
//|   RF-234: Análisis de "Tug of War"                                 |
//|   RF-235: Determinación de Bias por Open Float                     |
//|   RF-236: Identificación de Intermediate Term Highs                |
//|   RF-237: Identificación de Intermediate Term Lows                 |
//|   RF-238: Detección de Agotamiento de Liquidez                     |
//|   RF-239: Integración de Open Interest (OI) de Futuros             |
//|   RF-240: Análisis de Open Interest para Confirmación              |
//|   RF-241: Correlación Forex vs. Futuros                            |
//|   RF-242: Filtro de Datos de Futuros                               |
//|   RF-243: Proyección de Objetivos por Data Ranges                  |
//|   RF-244: Definición de Open Float como Rango de 120 Días          |
//|   RF-245: Tres Niveles de Liquidity Pools (20-40-60 días)          |
//|   RF-246: Monitoreo de Institutional Order Flow por Default        |
//|   RF-247: Detección de Quarterly Shift por Cambio de IOF           |
//|   RF-248: Filtro de False Break (Turtle Soup) en Rangos de 20 días |
//|                                                                    |
//| Dependencias:                                                      |
//|   - CConstants: Constantes y enumeraciones                         |
//|   - CUtils: Utilidades                                             |
//|   - CConfig: Configuración                                         |
//|                                                                    |
//| Versión: 1.0                                                       |
//| Fecha: 21/07/2026                                                  |
//+--------------------------------------------------------------------+
//+--------------------------------------------------------------------+
//| CHANGELOG                                                          |
//+--------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                     |
//|---------|-------------|--------------------------------------------|
//| 1.0     | 21/07/2026  | Versión inicial del módulo                 |
//+--------------------------------------------------------------------+

#ifndef __CDATARANGE_MQH__
#define __CDATARANGE_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct DataRange {
    double range20;            // Rango de 20 días (pips)
    double range40;            // Rango de 40 días (pips)
    double range60;            // Rango de 60 días (pips)
    double high20;             // Máximo de 20 días
    double low20;              // Mínimo de 20 días
    double high40;             // Máximo de 40 días
    double low40;              // Mínimo de 40 días
    double high60;             // Máximo de 60 días
    double low60;              // Mínimo de 60 días
    datetime anchorDate;       // Fecha de anclaje
    datetime lookBackStart;    // Inicio de Look Back
    datetime castForwardEnd;   // Fin de Cast Forward
    ENUM_BIAS iof;             // Institutional Order Flow
    bool isQuarterlyShift;     // Quarterly Shift detectado
    datetime shiftDate;        // Fecha del shift
    ENUM_BIAS shiftDirection;  // Dirección del shift
    double shiftStrength;      // Fuerza del shift (0-100)
};

struct LiquidityPoolData {
    double nearTerm;          // Pool de 20 días
    double shortTerm;         // Pool de 40 días
    double intermediateTerm;  // Pool de 60 días
    bool nearTermActive;
    bool shortTermActive;
    bool intermediateTermActive;
};

//+------------------------------------------------------------------+
//| CLASE CDataRange - Gestión de IPDA Data Ranges                   |
//+------------------------------------------------------------------+
class CDataRange {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_symbol;
    
    //--- Data Ranges
    DataRange          m_dataRange;
    datetime           m_anchorDate;
    datetime           m_lookBackStart;
    datetime           m_castForwardEnd;
    ENUM_BIAS          m_iof;              // Institutional Order Flow
    double             m_openFloatHigh;    // Open Float High (120 días)
    double             m_openFloatLow;     // Open Float Low (120 días)
    double             m_equilibrium;      // Punto medio del Open Float
    
    //--- Liquidity Pools
    LiquidityPoolData  m_liquidityPools;
    
    //--- Arrays de precios
    double             m_buyStops[];
    double             m_sellStops[];
    int                m_buyStopsCount;
    int                m_sellStopsCount;
    
    //--- Estado de Quarterly Shift
    bool               m_isQuarterlyShift;
    datetime           m_quarterlyShiftDate;
    ENUM_BIAS          m_quarterlyShiftDirection;
    double             m_quarterlyShiftStrength;
    
    //--- Estado de Acumulación/Distribución
    bool               m_isAccumulation;
    bool               m_isDistribution;
    double             m_accumulationLevel;
    double             m_distributionLevel;
    
    //--- RF-234: Tug of War
    double             m_tugOfWarRatio;    // Ratio de fuerzas (0-100)
    bool               m_isTugOfWar;
    
    //--- Métodos privados
    bool               InitializeSymbol();
    bool               CalculateAnchorDate();
    bool               CalculateDataRanges();
    bool               CalculateLookBack();
    bool               CalculateCastForward();
    bool               DetectQuarterlyShift();
    ENUM_BIAS          DetermineIOF();
    bool               CalculateOpenFloat();
    bool               MapLiquidityPools();
    bool               DetectAccumulationDistribution();
    bool               DetectTugOfWar();
    bool               MapBuySellStops();
    bool               ValidateQuarterlyShift();
    double             CalculateRange(string symbol, int days);
    double             CalculateHigh(string symbol, int days);
    double             CalculateLow(string symbol, int days);
    double             CalculateShiftStrength();
    bool               IsMarketStructureShift();
    
public:
    //--- Constructor / Destructor
    CDataRange();
    ~CDataRange();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, string symbol = "");
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Update();
    void SetSymbol(string symbol);
    
    //--- Getters
    DataRange GetDataRange() const { return m_dataRange; }
    datetime GetAnchorDate() const { return m_anchorDate; }
    datetime GetLookBackStart() const { return m_lookBackStart; }
    datetime GetCastForwardEnd() const { return m_castForwardEnd; }
    ENUM_BIAS GetIOF() const { return m_iof; }
    double GetOpenFloatHigh() const { return m_openFloatHigh; }
    double GetOpenFloatLow() const { return m_openFloatLow; }
    double GetEquilibrium() const { return m_equilibrium; }
    
    //--- RF-222: Quarterly Shift
    bool IsQuarterlyShiftDetected() const { return m_isQuarterlyShift; }
    datetime GetQuarterlyShiftDate() const { return m_quarterlyShiftDate; }
    ENUM_BIAS GetQuarterlyShiftDirection() const { return m_quarterlyShiftDirection; }
    double GetQuarterlyShiftStrength() const { return m_quarterlyShiftStrength; }
    
    //--- RF-223: IPDA Data Ranges
    double GetRange20() const { return m_dataRange.range20; }
    double GetRange40() const { return m_dataRange.range40; }
    double GetRange60() const { return m_dataRange.range60; }
    double GetHigh20() const { return m_dataRange.high20; }
    double GetLow20() const { return m_dataRange.low20; }
    double GetHigh40() const { return m_dataRange.high40; }
    double GetLow40() const { return m_dataRange.low40; }
    double GetHigh60() const { return m_dataRange.high60; }
    double GetLow60() const { return m_dataRange.low60; }
    
    //--- RF-224: Look Back Analysis
    double GetLookBackHigh(int days);
    double GetLookBackLow(int days);
    double GetLookBackRange(int days);
    
    //--- RF-225: Cast Forward Projection
    datetime GetCastForwardDate(int days);
    double GetCastForwardLevel(int days, double price);
    
    //--- RF-231: Open Float
    double GetOpenFloatRange() const;
    bool IsPriceAboveOpenFloat(double price);
    bool IsPriceBelowOpenFloat(double price);
    bool IsPriceInOpenFloat(double price);
    double GetOpenFloatPercentile(double price);
    
    //--- RF-232/233: Buy/Sell Stops
    double GetNearestBuyStop(double price);
    double GetNearestSellStop(double price);
    int GetBuyStopsCount() const { return m_buyStopsCount; }
    int GetSellStopsCount() const { return m_sellStopsCount; }
    bool IsBuyStopAbove(double price);
    bool IsSellStopBelow(double price);
    
    //--- RF-235: Bias por Open Float
    ENUM_BIAS GetBiasByOpenFloat() const;
    
    //--- RF-236/237: Intermediate Term Highs/Lows
    double GetIntermediateHigh(int days = 60);
    double GetIntermediateLow(int days = 60);
    
    //--- RF-238: Agotamiento de Liquidez
    bool IsLiquidityExhausted(ENUM_BIAS side);
    double GetLiquidityExhaustionLevel(ENUM_BIAS side);
    
    //--- RF-239/240: Open Interest Integration
    bool IsOIReversalConfirmed(string futuresSymbol, double price);
    double GetOIChangePercent(string futuresSymbol);
    bool IsOISmartMoneyFootprint(string futuresSymbol, ENUM_BIAS bias);
    
    //--- RF-241: Correlación Forex vs. Futuros
    bool IsForexFuturesDivergence(string futuresSymbol);
    double GetForexFuturesCorrelation(string futuresSymbol);
    
    //--- RF-243: Proyección de Objetivos
    double GetProjectedTarget(ENUM_BIAS bias, double entryPrice);
    double GetMeanThreshold(ENUM_BIAS bias);
    
    //--- RF-245: Liquidity Pools
    double GetNearTermPool() const { return m_liquidityPools.nearTerm; }
    double GetShortTermPool() const { return m_liquidityPools.shortTerm; }
    double GetIntermediateTermPool() const { return m_liquidityPools.intermediateTerm; }
    bool IsNearTermPoolActive() const { return m_liquidityPools.nearTermActive; }
    bool IsShortTermPoolActive() const { return m_liquidityPools.shortTermActive; }
    bool IsIntermediateTermPoolActive() const { return m_liquidityPools.intermediateTermActive; }
    
    //--- RF-248: Turtle Soup en Rangos de 20 días
    bool IsTurtleSoupIn20Range(double price);
    bool IsTurtleSoupIn40Range(double price);
    bool IsTurtleSoupIn60Range(double price);
    
    //--- RF-234: Tug of War
    double GetTugOfWarRatio() const { return m_tugOfWarRatio; }
    bool IsTugOfWarActive() const { return m_isTugOfWar; }
    bool IsBullishWinning() const { return m_tugOfWarRatio > 50; }
    bool IsBearishWinning() const { return m_tugOfWarRatio < 50; }
    
    //--- RF-227/228: Acumulación/Distribución
    bool IsAccumulation() const { return m_isAccumulation; }
    bool IsDistribution() const { return m_isDistribution; }
    double GetAccumulationLevel() const { return m_accumulationLevel; }
    double GetDistributionLevel() const { return m_distributionLevel; }
    string GetMarketPhase();
    
    //--- Validación
    bool IsSetupValid(ENUM_BIAS bias, double price);
    
    //--- Reportes
    string GetSummary();
    string GetDataRangeReport();
    string GetQuarterlyShiftReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CDataRange::CDataRange() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_anchorDate = 0;
    m_lookBackStart = 0;
    m_castForwardEnd = 0;
    m_iof = BIAS_NEUTRAL;
    m_openFloatHigh = 0;
    m_openFloatLow = 0;
    m_equilibrium = 0;
    m_isQuarterlyShift = false;
    m_quarterlyShiftDate = 0;
    m_quarterlyShiftDirection = BIAS_NEUTRAL;
    m_quarterlyShiftStrength = 0;
    m_isAccumulation = false;
    m_isDistribution = false;
    m_accumulationLevel = 0;
    m_distributionLevel = 0;
    m_tugOfWarRatio = 50;
    m_isTugOfWar = false;
    m_buyStopsCount = 0;
    m_sellStopsCount = 0;
    ZeroMemory(m_dataRange);
    ZeroMemory(m_liquidityPools);
}

//--- Destructor
CDataRange::~CDataRange() {
    Deinit();
}

//--- Inicialización
bool CDataRange::Init(CConfig* config, CUtils* utils, string symbol = "") {
    if(config == NULL || utils == NULL) {
        Print("CDataRange::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    if(symbol != "") {
        m_symbol = symbol;
    } else {
        m_symbol = _Symbol;
    }
    
    //--- Inicializar símbolo
    if(!InitializeSymbol()) {
        m_utils.LogError("CDataRange::Init - Error al inicializar símbolo: " + m_symbol);
        return false;
    }
    
    //--- Calcular todo
    if(!CalculateAnchorDate()) {
        m_utils.LogError("CDataRange::Init - Error al calcular fecha de anclaje");
        return false;
    }
    
    if(!CalculateDataRanges()) {
        m_utils.LogError("CDataRange::Init - Error al calcular Data Ranges");
        return false;
    }
    
    if(!CalculateLookBack()) {
        m_utils.LogWarning("CDataRange::Init - Advertencia en Look Back");
    }
    
    if(!CalculateCastForward()) {
        m_utils.LogWarning("CDataRange::Init - Advertencia en Cast Forward");
    }
    
    if(!DetectQuarterlyShift()) {
        m_utils.LogWarning("CDataRange::Init - No se detectó Quarterly Shift");
    }
    
    if(!DetermineIOF()) {
        m_utils.LogWarning("CDataRange::Init - No se pudo determinar IOF");
    }
    
    if(!CalculateOpenFloat()) {
        m_utils.LogWarning("CDataRange::Init - No se pudo calcular Open Float");
    }
    
    if(!MapLiquidityPools()) {
        m_utils.LogWarning("CDataRange::Init - No se pudieron mapear Liquidity Pools");
    }
    
    if(!DetectAccumulationDistribution()) {
        m_utils.LogWarning("CDataRange::Init - No se detectó acumulación/distribución");
    }
    
    if(!DetectTugOfWar()) {
        m_utils.LogWarning("CDataRange::Init - No se detectó Tug of War");
    }
    
    if(!MapBuySellStops()) {
        m_utils.LogWarning("CDataRange::Init - No se pudieron mapear Buy/Sell Stops");
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CDataRange inicializado correctamente para " + m_symbol);
    return true;
}

//--- Desinicialización
void CDataRange::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Inicializar símbolo
bool CDataRange::InitializeSymbol() {
    if(m_symbol == "") return false;
    
    //--- Verificar que el símbolo existe
    if(!SymbolSelect(m_symbol, true)) {
        return false;
    }
    
    return true;
}

//--- Establecer símbolo
void CDataRange::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            InitializeSymbol();
            Update();
        }
    }
}

//--- Actualizar todos los datos
void CDataRange::Update() {
    if(!m_isInitialized) return;
    
    CalculateAnchorDate();
    CalculateDataRanges();
    CalculateLookBack();
    CalculateCastForward();
    DetectQuarterlyShift();
    DetermineIOF();
    CalculateOpenFloat();
    MapLiquidityPools();
    DetectAccumulationDistribution();
    DetectTugOfWar();
    MapBuySellStops();
}

//--- RF-222: Calcular fecha de anclaje
bool CDataRange::CalculateAnchorDate() {
    //--- El punto de anclaje es el primer día de trading del mes anterior
    datetime now = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(now, dt);
    
    //--- Ir al mes anterior
    dt.mon--;
    if(dt.mon < 1) { dt.mon = 12; dt.year--; }
    dt.day = 1;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    
    m_anchorDate = StructToTime(dt);
    m_dataRange.anchorDate = m_anchorDate;
    
    return true;
}

//--- RF-223: Calcular Data Ranges (20, 40, 60 días)
bool CDataRange::CalculateDataRanges() {
    if(m_anchorDate == 0) return false;
    
    //--- Calcular rangos desde el punto de anclaje
    m_dataRange.range20 = CalculateRange(m_symbol, 20);
    m_dataRange.range40 = CalculateRange(m_symbol, 40);
    m_dataRange.range60 = CalculateRange(m_symbol, 60);
    
    m_dataRange.high20 = CalculateHigh(m_symbol, 20);
    m_dataRange.low20 = CalculateLow(m_symbol, 20);
    m_dataRange.high40 = CalculateHigh(m_symbol, 40);
    m_dataRange.low40 = CalculateLow(m_symbol, 40);
    m_dataRange.high60 = CalculateHigh(m_symbol, 60);
    m_dataRange.low60 = CalculateLow(m_symbol, 60);
    
    return true;
}

//--- RF-224: Calcular Look Back
bool CDataRange::CalculateLookBack() {
    if(m_anchorDate == 0) return false;
    
    //--- Look Back: 60 días antes del punto de anclaje
    MqlDateTime dt;
    TimeToStruct(m_anchorDate, dt);
    
    //--- Retroceder 60 días hábiles (aproximadamente 90 días calendario)
    dt.day -= 90;
    if(dt.day < 1) {
        dt.mon--;
        if(dt.mon < 1) { dt.mon = 12; dt.year--; }
        dt.day += 31;
    }
    
    m_lookBackStart = StructToTime(dt);
    m_dataRange.lookBackStart = m_lookBackStart;
    
    return true;
}

//--- RF-225: Calcular Cast Forward
bool CDataRange::CalculateCastForward() {
    if(m_anchorDate == 0) return false;
    
    //--- Cast Forward: 60 días después del punto de anclaje
    MqlDateTime dt;
    TimeToStruct(m_anchorDate, dt);
    
    //--- Avanzar 60 días hábiles (aproximadamente 90 días calendario)
    dt.day += 90;
    if(dt.day > 31) {
        dt.mon++;
        if(dt.mon > 12) { dt.mon = 1; dt.year++; }
        dt.day -= 31;
    }
    
    m_castForwardEnd = StructToTime(dt);
    m_dataRange.castForwardEnd = m_castForwardEnd;
    
    return true;
}

//--- RF-222/247: Detectar Quarterly Shift
bool CDataRange::DetectQuarterlyShift() {
    if(!m_isInitialized) return false;
    
    //--- Analizar cambio en IOF
    ENUM_BIAS previousIOF = m_iof;
    ENUM_BIAS currentIOF = DetermineIOF();
    
    //--- Si hay cambio de dirección, es un Quarterly Shift
    if(previousIOF != BIAS_NEUTRAL && currentIOF != previousIOF) {
        m_isQuarterlyShift = true;
        m_quarterlyShiftDate = TimeCurrent();
        m_quarterlyShiftDirection = currentIOF;
        m_quarterlyShiftStrength = CalculateShiftStrength();
        m_dataRange.isQuarterlyShift = true;
        m_dataRange.shiftDate = m_quarterlyShiftDate;
        m_dataRange.shiftDirection = m_quarterlyShiftDirection;
        m_dataRange.shiftStrength = m_quarterlyShiftStrength;
        return true;
    }
    
    //--- Si no hay cambio, verificar si hay shift por estructura de mercado
    if(ValidateQuarterlyShift()) {
        m_isQuarterlyShift = true;
        m_quarterlyShiftDate = TimeCurrent();
        m_quarterlyShiftDirection = m_iof;
        m_quarterlyShiftStrength = CalculateShiftStrength();
        m_dataRange.isQuarterlyShift = true;
        m_dataRange.shiftDate = m_quarterlyShiftDate;
        m_dataRange.shiftDirection = m_quarterlyShiftDirection;
        m_dataRange.shiftStrength = m_quarterlyShiftStrength;
        return true;
    }
    
    m_isQuarterlyShift = false;
    m_dataRange.isQuarterlyShift = false;
    return false;
}

//--- RF-246: Determinar Institutional Order Flow (IOF)
ENUM_BIAS CDataRange::DetermineIOF() {
    if(!m_isInitialized) return BIAS_NEUTRAL;
    
    //--- Analizar la tendencia de los últimos 60 días
    double high60 = CalculateHigh(m_symbol, 60);
    double low60 = CalculateLow(m_symbol, 60);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    double range60 = high60 - low60;
    if(range60 <= 0) return BIAS_NEUTRAL;
    
    //--- Posición del precio en el rango de 60 días
    double position = (currentPrice - low60) / range60;
    
    //--- Determinar IOF basado en la posición
    if(position > 0.6) {
        m_iof = BIAS_BULLISH;
        m_dataRange.iof = BIAS_BULLISH;
        return BIAS_BULLISH;
    } else if(position < 0.4) {
        m_iof = BIAS_BEARISH;
        m_dataRange.iof = BIAS_BEARISH;
        return BIAS_BEARISH;
    } else {
        m_iof = BIAS_NEUTRAL;
        m_dataRange.iof = BIAS_NEUTRAL;
        return BIAS_NEUTRAL;
    }
}

//--- RF-231/244: Calcular Open Float (120 días)
bool CDataRange::CalculateOpenFloat() {
    if(!m_isInitialized) return false;
    
    //--- Open Float: rango de 120 días hábiles
    m_openFloatHigh = CalculateHigh(m_symbol, 120);
    m_openFloatLow = CalculateLow(m_symbol, 120);
    m_equilibrium = (m_openFloatHigh + m_openFloatLow) / 2.0;
    
    return (m_openFloatHigh > 0 && m_openFloatLow > 0);
}

//--- RF-245: Mapear Liquidity Pools
bool CDataRange::MapLiquidityPools() {
    if(!m_isInitialized) return false;
    
    //--- Near-Term (20 días)
    m_liquidityPools.nearTerm = CalculateHigh(m_symbol, 20);
    m_liquidityPools.nearTermActive = true;
    
    //--- Short-Term (40 días)
    m_liquidityPools.shortTerm = CalculateHigh(m_symbol, 40);
    m_liquidityPools.shortTermActive = true;
    
    //--- Intermediate-Term (60 días)
    m_liquidityPools.intermediateTerm = CalculateHigh(m_symbol, 60);
    m_liquidityPools.intermediateTermActive = true;
    
    return true;
}

//--- RF-227/228: Detectar Acumulación/Distribución
bool CDataRange::DetectAccumulationDistribution() {
    if(!m_isInitialized) return false;
    
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    
    //--- Detectar acumulación: precio en la parte baja del rango con soporte
    if(currentPrice < low20 + (high20 - low20) * 0.3) {
        m_isAccumulation = true;
        m_isDistribution = false;
        m_accumulationLevel = low20;
        return true;
    }
    
    //--- Detectar distribución: precio en la parte alta del rango con resistencia
    if(currentPrice > high20 - (high20 - low20) * 0.3) {
        m_isDistribution = true;
        m_isAccumulation = false;
        m_distributionLevel = high20;
        return true;
    }
    
    m_isAccumulation = false;
    m_isDistribution = false;
    return true;
}

//--- RF-234: Detectar Tug of War
bool CDataRange::DetectTugOfWar() {
    if(!m_isInitialized) return false;
    
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    double range = high20 - low20;
    if(range <= 0) return false;
    
    //--- Calcular ratio de fuerzas basado en la posición del precio
    double ratio = ((currentPrice - low20) / range) * 100;
    m_tugOfWarRatio = ratio;
    m_isTugOfWar = (ratio > 30 && ratio < 70);
    
    return true;
}

//--- RF-232/233: Mapear Buy/Sell Stops
bool CDataRange::MapBuySellStops() {
    if(!m_isInitialized) return false;
    
    //--- Limpiar arrays
    ArrayResize(m_buyStops, 0);
    ArrayResize(m_sellStops, 0);
    m_buyStopsCount = 0;
    m_sellStopsCount = 0;
    
    //--- Buy Stops: por encima de los máximos recientes
    double high20 = CalculateHigh(m_symbol, 20);
    double high40 = CalculateHigh(m_symbol, 40);
    double high60 = CalculateHigh(m_symbol, 60);
    
    if(high20 > 0) {
        ArrayResize(m_buyStops, m_buyStopsCount + 1);
        m_buyStops[m_buyStopsCount++] = high20 * 1.001;
    }
    if(high40 > 0) {
        ArrayResize(m_buyStops, m_buyStopsCount + 1);
        m_buyStops[m_buyStopsCount++] = high40 * 1.001;
    }
    if(high60 > 0) {
        ArrayResize(m_buyStops, m_buyStopsCount + 1);
        m_buyStops[m_buyStopsCount++] = high60 * 1.001;
    }
    
    //--- Sell Stops: por debajo de los mínimos recientes
    double low20 = CalculateLow(m_symbol, 20);
    double low40 = CalculateLow(m_symbol, 40);
    double low60 = CalculateLow(m_symbol, 60);
    
    if(low20 > 0) {
        ArrayResize(m_sellStops, m_sellStopsCount + 1);
        m_sellStops[m_sellStopsCount++] = low20 * 0.999;
    }
    if(low40 > 0) {
        ArrayResize(m_sellStops, m_sellStopsCount + 1);
        m_sellStops[m_sellStopsCount++] = low40 * 0.999;
    }
    if(low60 > 0) {
        ArrayResize(m_sellStops, m_sellStopsCount + 1);
        m_sellStops[m_sellStopsCount++] = low60 * 0.999;
    }
    
    return true;
}

//--- RF-248: Verificar Turtle Soup en rango de 20 días
bool CDataRange::IsTurtleSoupIn20Range(double price) {
    if(!m_isInitialized) return false;
    
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    
    //--- Turtle Soup Long: precio rompe el mínimo de 20 días y revierte
    if(price < low20) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice > low20);
    }
    
    //--- Turtle Soup Short: precio rompe el máximo de 20 días y revierte
    if(price > high20) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice < high20);
    }
    
    return false;
}

//--- RF-235: Obtener bias por Open Float
ENUM_BIAS CDataRange::GetBiasByOpenFloat() const {
    double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    
    if(currentPrice > m_equilibrium * 1.01) {
        return BIAS_BEARISH;  // En premium, esperar reversión bajista
    }
    if(currentPrice < m_equilibrium * 0.99) {
        return BIAS_BULLISH;   // En discount, esperar reversión alcista
    }
    
    return BIAS_NEUTRAL;
}

//--- RF-236/237: Obtener Intermediate Term High/Low
double CDataRange::GetIntermediateHigh(int days = 60) {
    return CalculateHigh(m_symbol, days);
}

double CDataRange::GetIntermediateLow(int days = 60) {
    return CalculateLow(m_symbol, days);
}

//--- RF-238: Verificar agotamiento de liquidez
bool CDataRange::IsLiquidityExhausted(ENUM_BIAS side) {
    if(!m_isInitialized) return false;
    
    if(side == BIAS_BULLISH) {
        //--- Verificar si los buy stops ya fueron tomados
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        double high20 = CalculateHigh(m_symbol, 20);
        return (currentPrice > high20);  // Buy stops tomados
    }
    
    if(side == BIAS_BEARISH) {
        //--- Verificar si los sell stops ya fueron tomados
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        double low20 = CalculateLow(m_symbol, 20);
        return (currentPrice < low20);   // Sell stops tomados
    }
    
    return false;
}

//--- RF-239/240: Integración con Open Interest
bool CDataRange::IsOIReversalConfirmed(string futuresSymbol, double price) {
    //--- Placeholder para implementación futura
    return false;
}

double CDataRange::GetOIChangePercent(string futuresSymbol) {
    //--- Placeholder para implementación futura
    return 0.0;
}

bool CDataRange::IsOISmartMoneyFootprint(string futuresSymbol, ENUM_BIAS bias) {
    //--- Placeholder para implementación futura
    return false;
}

//--- RF-241: Correlación Forex vs. Futuros
bool CDataRange::IsForexFuturesDivergence(string futuresSymbol) {
    //--- Placeholder para implementación futura
    return false;
}

double CDataRange::GetForexFuturesCorrelation(string futuresSymbol) {
    //--- Placeholder para implementación futura
    return 0.0;
}

//--- RF-243: Proyección de objetivos
double CDataRange::GetProjectedTarget(ENUM_BIAS bias, double entryPrice) {
    if(!m_isInitialized) return 0.0;
    
    double range = GetRange20();
    if(range <= 0) return 0.0;
    
    if(bias == BIAS_BULLISH) {
        return entryPrice + range;
    } else if(bias == BIAS_BEARISH) {
        return entryPrice - range;
    }
    
    return 0.0;
}

double CDataRange::GetMeanThreshold(ENUM_BIAS bias) {
    if(!m_isInitialized) return 0.0;
    
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    
    if(bias == BIAS_BULLISH) {
        return (high20 + low20) / 2.0;
    }
    
    return 0.0;
}

//--- RF-248: Turtle Soup en rangos
bool CDataRange::IsTurtleSoupIn40Range(double price) {
    if(!m_isInitialized) return false;
    
    double high40 = CalculateHigh(m_symbol, 40);
    double low40 = CalculateLow(m_symbol, 40);
    
    if(price < low40) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice > low40);
    }
    if(price > high40) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice < high40);
    }
    return false;
}

bool CDataRange::IsTurtleSoupIn60Range(double price) {
    if(!m_isInitialized) return false;
    
    double high60 = CalculateHigh(m_symbol, 60);
    double low60 = CalculateLow(m_symbol, 60);
    
    if(price < low60) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice > low60);
    }
    if(price > high60) {
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        return (currentPrice < high60);
    }
    return false;
}

//--- Validar setup
bool CDataRange::IsSetupValid(ENUM_BIAS bias, double price) {
    if(!m_isInitialized) return false;
    
    ENUM_BIAS iofBias = GetBiasByOpenFloat();
    
    //--- Verificar alineación con IOF
    if(bias != BIAS_NEUTRAL && iofBias != BIAS_NEUTRAL) {
        return (bias == iofBias);
    }
    
    return true;
}

//--- Validar Quarterly Shift
bool CDataRange::ValidateQuarterlyShift() {
    if(!m_isInitialized) return false;
    
    //--- Verificar cambio en estructura de mercado
    return IsMarketStructureShift();
}

//--- Verificar Market Structure Shift
bool CDataRange::IsMarketStructureShift() {
    if(!m_isInitialized) return false;
    
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    double high40 = CalculateHigh(m_symbol, 40);
    double low40 = CalculateLow(m_symbol, 40);
    
    //--- Si el rango de 20 días está dentro del rango de 40 días, no hay shift
    if(high20 <= high40 && low20 >= low40) {
        return false;
    }
    
    //--- Si el rango de 20 días se sale del rango de 40 días, hay shift
    return true;
}

//--- Calcular fuerza del shift
double CDataRange::CalculateShiftStrength() {
    if(!m_isInitialized) return 0.0;
    
    double high20 = CalculateHigh(m_symbol, 20);
    double low20 = CalculateLow(m_symbol, 20);
    double high40 = CalculateHigh(m_symbol, 40);
    double low40 = CalculateLow(m_symbol, 40);
    
    double range20 = high20 - low20;
    double range40 = high40 - low40;
    
    if(range40 <= 0) return 0.0;
    
    //--- Fuerza = proporción del rango de 20 vs 40 días
    double strength = (range20 / range40) * 100;
    if(strength > 100) strength = 100;
    
    return strength;
}

//--- Funciones de cálculo auxiliares
double CDataRange::CalculateRange(string symbol, int days) {
    double high = CalculateHigh(symbol, days);
    double low = CalculateLow(symbol, days);
    
    if(high <= 0 || low <= 0) return 0.0;
    
    return m_utils.CalculatePipsBetween(high, low, symbol);
}

double CDataRange::CalculateHigh(string symbol, int days) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    
    int copied = CopyHigh(symbol, PERIOD_D1, 1, days, highArray);
    if(copied < days) return 0.0;
    
    double maxHigh = highArray[0];
    for(int i = 1; i < copied; i++) {
        if(highArray[i] > maxHigh) maxHigh = highArray[i];
    }
    
    return maxHigh;
}

double CDataRange::CalculateLow(string symbol, int days) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    
    int copied = CopyLow(symbol, PERIOD_D1, 1, days, lowArray);
    if(copied < days) return 0.0;
    
    double minLow = lowArray[0];
    for(int i = 1; i < copied; i++) {
        if(lowArray[i] < minLow) minLow = lowArray[i];
    }
    
    return minLow;
}

//--- RF-224: Look Back functions
double CDataRange::GetLookBackHigh(int days) {
    return CalculateHigh(m_symbol, days);
}

double CDataRange::GetLookBackLow(int days) {
    return CalculateLow(m_symbol, days);
}

double CDataRange::GetLookBackRange(int days) {
    return CalculateRange(m_symbol, days);
}

//--- RF-225: Cast Forward functions
datetime CDataRange::GetCastForwardDate(int days) {
    if(m_anchorDate == 0) return 0;
    
    MqlDateTime dt;
    TimeToStruct(m_anchorDate, dt);
    
    dt.day += days;
    if(dt.day > 31) {
        dt.mon++;
        if(dt.mon > 12) { dt.mon = 1; dt.year++; }
        dt.day -= 31;
    }
    
    return StructToTime(dt);
}

double CDataRange::GetCastForwardLevel(int days, double price) {
    //--- Placeholder para proyección futura
    return price;
}

//--- Open Float functions
double CDataRange::GetOpenFloatRange() const {
    return m_openFloatHigh - m_openFloatLow;
}

bool CDataRange::IsPriceAboveOpenFloat(double price) {
    return price > m_openFloatHigh;
}

bool CDataRange::IsPriceBelowOpenFloat(double price) {
    return price < m_openFloatLow;
}

bool CDataRange::IsPriceInOpenFloat(double price) {
    return price >= m_openFloatLow && price <= m_openFloatHigh;
}

double CDataRange::GetOpenFloatPercentile(double price) {
    if(m_openFloatHigh <= m_openFloatLow) return 50.0;
    
    double range = m_openFloatHigh - m_openFloatLow;
    double position = price - m_openFloatLow;
    
    return (position / range) * 100;
}

//--- Buy/Sell Stops functions
double CDataRange::GetNearestBuyStop(double price) {
    if(m_buyStopsCount == 0) return 0.0;
    
    double nearest = 0;
    double minDiff = DBL_MAX;
    
    for(int i = 0; i < m_buyStopsCount; i++) {
        double diff = m_buyStops[i] - price;
        if(diff > 0 && diff < minDiff) {
            minDiff = diff;
            nearest = m_buyStops[i];
        }
    }
    
    return nearest;
}

double CDataRange::GetNearestSellStop(double price) {
    if(m_sellStopsCount == 0) return 0.0;
    
    double nearest = 0;
    double minDiff = DBL_MAX;
    
    for(int i = 0; i < m_sellStopsCount; i++) {
        double diff = price - m_sellStops[i];
        if(diff > 0 && diff < minDiff) {
            minDiff = diff;
            nearest = m_sellStops[i];
        }
    }
    
    return nearest;
}

bool CDataRange::IsBuyStopAbove(double price) {
    return GetNearestBuyStop(price) > 0;
}

bool CDataRange::IsSellStopBelow(double price) {
    return GetNearestSellStop(price) > 0;
}

//--- RF-238: Liquidity Exhaustion
double CDataRange::GetLiquidityExhaustionLevel(ENUM_BIAS side) {
    if(side == BIAS_BULLISH) {
        return CalculateHigh(m_symbol, 20);
    }
    if(side == BIAS_BEARISH) {
        return CalculateLow(m_symbol, 20);
    }
    return 0.0;
}

//--- Get Market Phase
string CDataRange::GetMarketPhase() {
    if(m_isAccumulation) return "ACCUMULATION";
    if(m_isDistribution) return "DISTRIBUTION";
    if(m_isTugOfWar) return "TUG_OF_WAR";
    if(m_isQuarterlyShift) return "QUARTERLY_SHIFT";
    return "NEUTRAL";
}

//--- Reportes
string CDataRange::GetSummary() {
    string summary = "=== DATA RANGE SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Anchor Date: " + TimeToString(m_anchorDate) + "\n";
    summary += "IOF: " + (m_iof == BIAS_BULLISH ? "BULLISH" : 
                          (m_iof == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Range 20: " + DoubleToString(m_dataRange.range20, 1) + " pips\n";
    summary += "Range 40: " + DoubleToString(m_dataRange.range40, 1) + " pips\n";
    summary += "Range 60: " + DoubleToString(m_dataRange.range60, 1) + " pips\n";
    summary += "Open Float: " + DoubleToString(m_openFloatLow, 5) + " - " + 
               DoubleToString(m_openFloatHigh, 5) + "\n";
    summary += "Equilibrium: " + DoubleToString(m_equilibrium, 5) + "\n";
    summary += "Quarterly Shift: " + (m_isQuarterlyShift ? "YES" : "NO") + "\n";
    if(m_isQuarterlyShift) {
        summary += "  Shift Date: " + TimeToString(m_quarterlyShiftDate) + "\n";
        summary += "  Direction: " + (m_quarterlyShiftDirection == BIAS_BULLISH ? "BULLISH" : "BEARISH") + "\n";
        summary += "  Strength: " + DoubleToString(m_quarterlyShiftStrength, 1) + "%\n";
    }
    summary += "Market Phase: " + GetMarketPhase() + "\n";
    summary += "Tug of War: " + (m_isTugOfWar ? "ACTIVE" : "INACTIVE") + 
               " (Ratio: " + DoubleToString(m_tugOfWarRatio, 1) + "%)\n";
    summary += "==============================";
    return summary;
}

string CDataRange::GetDataRangeReport() {
    string report = "=== DATA RANGES ===\n";
    report += "20 Days:\n";
    report += "  High: " + DoubleToString(m_dataRange.high20, 5) + "\n";
    report += "  Low: " + DoubleToString(m_dataRange.low20, 5) + "\n";
    report += "  Range: " + DoubleToString(m_dataRange.range20, 1) + " pips\n";
    report += "40 Days:\n";
    report += "  High: " + DoubleToString(m_dataRange.high40, 5) + "\n";
    report += "  Low: " + DoubleToString(m_dataRange.low40, 5) + "\n";
    report += "  Range: " + DoubleToString(m_dataRange.range40, 1) + " pips\n";
    report += "60 Days:\n";
    report += "  High: " + DoubleToString(m_dataRange.high60, 5) + "\n";
    report += "  Low: " + DoubleToString(m_dataRange.low60, 5) + "\n";
    report += "  Range: " + DoubleToString(m_dataRange.range60, 1) + " pips\n";
    report += "Look Back Start: " + TimeToString(m_lookBackStart) + "\n";
    report += "Cast Forward End: " + TimeToString(m_castForwardEnd) + "\n";
    report += "===================";
    return report;
}

string CDataRange::GetQuarterlyShiftReport() {
    string report = "=== QUARTERLY SHIFT REPORT ===\n";
    report += "Detected: " + (m_isQuarterlyShift ? "YES" : "NO") + "\n";
    if(m_isQuarterlyShift) {
        report += "Date: " + TimeToString(m_quarterlyShiftDate) + "\n";
        report += "Direction: " + (m_quarterlyShiftDirection == BIAS_BULLISH ? "BULLISH" : "BEARISH") + "\n";
        report += "Strength: " + DoubleToString(m_quarterlyShiftStrength, 1) + "%\n";
        report += "IOF: " + (m_iof == BIAS_BULLISH ? "BULLISH" : 
                            (m_iof == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    }
    report += "=============================";
    return report;
}

#endif // __CDATARANGE_MQH__