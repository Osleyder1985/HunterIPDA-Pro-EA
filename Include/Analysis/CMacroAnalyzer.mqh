//+------------------------------------------------------------------+
//|                                               CMacroAnalyzer.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis macroeconómico:                 |
//| - 10-Year Treasury Note y DXY                                    |
//| - Intermarket Analysis (4 grupos)                                |
//| - Interest Rate Differentials                                    |
//| - Cracking Correlation                                           |
//| - Seasonal Tendencies                                            |
//| - Open Interest confirmación                                     |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-254: Integración de Datos del 10-Year Treasury Note         |
//|   RF-255: Cálculo de Yield del 10-Year                           |
//|   RF-256: Detección de Condición de Mercado                      |
//|   RF-257: Filtro Estacional                                      |
//|   RF-258: Uso del 10-Year como Leading Indicator                 |
//|   RF-259: Detección de "Cracking Correlation"                    |
//|   RF-260: Verificación de Market Symmetry                        |
//|   RF-261: Confirmación con Yield del 10-Year                     |
//|   RF-262: Blending de Filtros Macro y Técnicos                   |
//|   RF-263: Calificación de Trade como Requisito Previo            |
//|   RF-264: Integración de Tasas de Interés                        |
//|   RF-265: Cálculo de Diferenciales de Tasas                      |
//|   RF-266: Selección de Pares por Diferencial de Tasas            |
//|   RF-267: Confirmación de Setup con Open Interest                |
//|   RF-268: Blending de Diferenciales con Análisis Técnico         |
//|   RF-269: Integración de Análisis Intermercado (4 Grupos)        |
//|   RF-270: Verificación de Relación Bonos vs. Acciones            |
//|   RF-271: Verificación de Relación Bonos vs. Materias Primas     |
//|   RF-272: Verificación de Relación Dólar vs. Materias Primas     |
//|   RF-273: Uso de Indicadores Adelantados                         |
//|   RF-274: Reglas de Correlación Clave                            |
//|   RF-275: Integración de Tendencias Estacionales                 |
//|   RF-276: Inversión de Seasonal para Pares USD/XXX               |
//|   RF-277: Blending de Seasonal + Quarterly Shifts                |
//|   RF-278: Correlación Estacional CAD vs. Crude Oil               |
//|   RF-279: Seasonal como Filtro de Contexto                       |
//|   RF-280: Integración de Bearish Seasonal Tendencies             |
//|   RF-281: Uso Dual de Bearish Seasonal                           |
//|   RF-282: Convergencia de Datos Estacionales                     |
//|   RF-283: Contextualización de Seasonal Tendencies               |
//|   RF-284: Seasonal como Elemento Temporal                        |
//|   RF-285: Definición de "Ideal Seasonal Tendency" por Par        |
//|   RF-286: Comparación de Seasonal Tendencies                     |
//|   RF-287: Verificación de Convergencia 40-Year vs. 15-Year       |
//|   RF-288: Calendario Estacional Integrado                        |
//|   RF-289: Seasonal como Filtro de Contexto                       |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
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

#ifndef __CMACROANALYZER_MQH__
#define __CMACROANALYZER_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| CLASE CMacroAnalyzer - Análisis Macroeconómico                   |
//+------------------------------------------------------------------+
class CMacroAnalyzer {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    
    //--- Símbolos macro
    string             m_tenYearSymbol;
    string             m_thirtyYearSymbol;
    string             m_dxySymbol;
    string             m_crbSymbol;
    string             m_goldSymbol;
    string             m_oilSymbol;
    string             m_nikkeiSymbol;
    string             m_sp500Symbol;
    
    //--- Datos macro
    MacroData          m_macroData;
    double             m_tenYearYield;
    double             m_tenYearPrice;
    double             m_dxy;
    double             m_crb;
    double             m_gold;
    double             m_oil;
    double             m_thirtyYearYield;
    double             m_nikkei;
    double             m_sp500;
    
    //--- Estado
    ENUM_BIAS          m_intermarketBias;
    bool               m_isCrackingCorrelation;
    bool               m_isMarketSymmetry;
    double             m_correlationScore;
    int                m_alignedMarkets;
    ENUM_MARKET_STATE  m_marketCondition;
    
    //--- Tasas de interés
    double             m_fedRate;
    double             m_ecbRate;
    double             m_bojRate;
    double             m_boeRate;
    double             m_rbaRate;
    double             m_rbnzRate;
    double             m_bocRate;
    double             m_snbRate;
    datetime           m_ratesLastUpdate;
    
    //--- Tasas por defecto (valores aproximados)
    static const double DEFAULT_FED_RATE;
    static const double DEFAULT_ECB_RATE;
    static const double DEFAULT_BOJ_RATE;
    static const double DEFAULT_BOE_RATE;
    static const double DEFAULT_RBA_RATE;
    static const double DEFAULT_RBNZ_RATE;
    static const double DEFAULT_BOC_RATE;
    static const double DEFAULT_SNB_RATE;
    
    //--- Métodos privados
    bool               InitializeSymbols();
    bool               LoadTenYearData();
    bool               LoadDXYData();
    bool               LoadCRBData();
    bool               LoadGoldData();
    bool               LoadOilData();
    bool               LoadThirtyYearData();
    bool               LoadNikkeiData();
    bool               LoadSP500Data();
    bool               UpdateMacroData();
    void               CalculateYield();
    void               CalculateIntermarketBias();
    void               DetectCrackingCorrelation();
    void               DetectMarketSymmetry();
    void               CalculateMarketCondition();
    void               LoadInterestRates();
    double             GetRateForSymbol(string symbol);
    double             CalculateYieldFromPrice(double price);
    
public:
    //--- Constructor / Destructor
    CMacroAnalyzer();
    ~CMacroAnalyzer();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Update();
    void SetSymbols(string tenYear, string thirtyYear, string dxy, string crb, 
                    string gold, string oil, string nikkei = "", string sp500 = "");
    
    //--- RF-254: 10-Year Treasury Note
    double GetTenYearYield() const { return m_tenYearYield; }
    double GetTenYearPrice() const { return m_tenYearPrice; }
    double GetThirtyYearYield() const { return m_thirtyYearYield; }
    bool IsTenYearRising() const;
    bool IsTenYearFalling() const;
    double GetTenYearChange() const;
    
    //--- RF-255: Cálculo de Yield
    double GetCurrentYield() const { return m_tenYearYield; }
    
    //--- RF-256: Condición de Mercado
    ENUM_MARKET_STATE GetMarketCondition() const { return m_marketCondition; }
    bool IsTrending() const { return m_marketCondition == STATE_EXPANSION || m_marketCondition == STATE_RETRACEMENT; }
    bool IsConsolidating() const { return m_marketCondition == STATE_CONSOLIDATION; }
    
    //--- RF-257: Filtro Estacional
    bool IsSeasonalValid() const;
    ENUM_BIAS GetSeasonalBias() const;
    
    //--- RF-258: 10-Year como Leading Indicator
    ENUM_BIAS GetLeadingIndicatorBias() const;
    double GetLeadingIndicatorScore() const;
    
    //--- RF-259: Cracking Correlation
    bool IsCrackingCorrelation() const { return m_isCrackingCorrelation; }
    double GetCrackingCorrelationScore() const;
    
    //--- RF-260: Market Symmetry
    bool IsMarketSymmetry() const { return m_isMarketSymmetry; }
    double GetMarketSymmetryScore() const;
    
    //--- RF-261: Confirmación con Yield
    bool IsYieldConfirming(ENUM_BIAS bias) const;
    bool IsYieldConfirmingBullish() const;
    bool IsYieldConfirmingBearish() const;
    
    //--- RF-262: Blending Macro y Técnico
    double GetMacroAlignmentScore(ENUM_BIAS bias) const;
    bool IsMacroAligned(ENUM_BIAS bias) const;
    
    //--- RF-263: Calificación de Trade
    bool IsTradeQualified(ENUM_BIAS bias) const;
    int GetMacroQualificationScore(ENUM_BIAS bias) const;
    
    //--- RF-264-266: Tasas de Interés y Diferenciales
    double GetFedRate() const { return m_fedRate; }
    double GetECBRate() const { return m_ecbRate; }
    double GetBoJRate() const { return m_bojRate; }
    double GetBoERate() const { return m_boeRate; }
    double GetRBARate() const { return m_rbaRate; }
    double GetRBNZRate() const { return m_rbnzRate; }
    double GetBOCRate() const { return m_bocRate; }
    double GetSNBRate() const { return m_snbRate; }
    double GetDifferential(string base, string quote) const;
    string GetBestPairByDifferential() const;
    double GetPairScoreByDifferential(string pair) const;
    
    //--- RF-267: Open Interest Confirmación
    bool IsOIConfirming(ENUM_BIAS bias) const;
    double GetOIChangePercent(string symbol) const;
    
    //--- RF-268: Blending con Diferenciales
    double GetBlendedScore(ENUM_BIAS bias) const;
    bool IsBlendedValid(ENUM_BIAS bias) const;
    
    //--- RF-269-274: Análisis Intermercado
    ENUM_BIAS GetBondBias() const;
    ENUM_BIAS GetCommodityBias() const;
    ENUM_BIAS GetStockBias() const;
    ENUM_BIAS GetCurrencyBias() const;
    double GetIntermarketAlignment() const;
    bool IsRiskOn() const;
    bool IsRiskOff() const;
    int GetAlignedMarketsCount() const;
    ENUM_RISK_ENVIRONMENT GetRiskEnvironment() const;
    
    //--- RF-270: Bonos vs. Acciones
    bool IsBondStockCorrelation() const;
    double GetBondStockCorrelation() const;
    
    //--- RF-271: Bonos vs. Materias Primas
    bool IsBondCommodityCorrelation() const;
    double GetBondCommodityCorrelation() const;
    
    //--- RF-272: Dólar vs. Materias Primas
    bool IsDollarCommodityCorrelation() const;
    double GetDollarCommodityCorrelation() const;
    
    //--- RF-273: Indicadores Adelantados
    ENUM_BIAS GetLeadIndicatorBias() const;
    double GetLeadIndicatorConfidence() const;
    
    //--- RF-274: Correlaciones Clave
    double GetGoldCorrelation() const;
    double GetOilCorrelation() const;
    double GetNikkeiCorrelation() const;
    bool IsGoldConfirming(ENUM_BIAS bias) const;
    bool IsOilConfirming(ENUM_BIAS bias) const;
    bool IsNikkeiConfirming(ENUM_BIAS bias) const;
    
    //--- RF-275-289: Seasonal
    double GetSeasonalStrength() const;
    bool IsSeasonalIdeal() const;
    bool IsSeasonalConverged() const;
    string GetSeasonalCalendar();
    ENUM_BIAS GetSeasonalBiasForPair(string pair) const;
    ENUM_BIAS GetInvertedSeasonalBias(string pair) const;
    bool IsSeasonalOppo(string pair) const;
    
    //--- RF-371: COT Alignment
    bool IsCOTAligned() const;
    bool IsCOTHedgingProgramAligned() const;
    
    //--- Getters
    MacroData GetMacroData() const { return m_macroData; }
    ENUM_BIAS GetIntermarketBias() const { return m_intermarketBias; }
    double GetDXY() const { return m_dxy; }
    double GetCRB() const { return m_crb; }
    double GetGold() const { return m_gold; }
    double GetOil() const { return m_oil; }
    double GetNikkei() const { return m_nikkei; }
    double GetSP500() const { return m_sp500; }
    double GetCorrelationScore() const { return m_correlationScore; }
    
    //--- Reportes
    string GetSummary();
    string GetMacroReport();
    string GetIntermarketReport();
    string GetRatesReport();
};

//+------------------------------------------------------------------+
//| CONSTANTES ESTÁTICAS                                             |
//+------------------------------------------------------------------+
const double CMacroAnalyzer::DEFAULT_FED_RATE = 5.50;
const double CMacroAnalyzer::DEFAULT_ECB_RATE = 4.00;
const double CMacroAnalyzer::DEFAULT_BOJ_RATE = -0.10;
const double CMacroAnalyzer::DEFAULT_BOE_RATE = 5.25;
const double CMacroAnalyzer::DEFAULT_RBA_RATE = 4.10;
const double CMacroAnalyzer::DEFAULT_RBNZ_RATE = 5.50;
const double CMacroAnalyzer::DEFAULT_BOC_RATE = 5.00;
const double CMacroAnalyzer::DEFAULT_SNB_RATE = 1.75;

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CMacroAnalyzer::CMacroAnalyzer() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_tenYearSymbol = "";
    m_thirtyYearSymbol = "";
    m_dxySymbol = "";
    m_crbSymbol = "";
    m_goldSymbol = "";
    m_oilSymbol = "";
    m_nikkeiSymbol = "";
    m_sp500Symbol = "";
    m_tenYearYield = 0.0;
    m_tenYearPrice = 0.0;
    m_dxy = 0.0;
    m_crb = 0.0;
    m_gold = 0.0;
    m_oil = 0.0;
    m_thirtyYearYield = 0.0;
    m_nikkei = 0.0;
    m_sp500 = 0.0;
    m_intermarketBias = BIAS_NEUTRAL;
    m_isCrackingCorrelation = false;
    m_isMarketSymmetry = false;
    m_correlationScore = 0.0;
    m_alignedMarkets = 0;
    m_marketCondition = STATE_CONSOLIDATION;
    m_fedRate = DEFAULT_FED_RATE;
    m_ecbRate = DEFAULT_ECB_RATE;
    m_bojRate = DEFAULT_BOJ_RATE;
    m_boeRate = DEFAULT_BOE_RATE;
    m_rbaRate = DEFAULT_RBA_RATE;
    m_rbnzRate = DEFAULT_RBNZ_RATE;
    m_bocRate = DEFAULT_BOC_RATE;
    m_snbRate = DEFAULT_SNB_RATE;
    m_ratesLastUpdate = 0;
    ZeroMemory(m_macroData);
}

//--- Destructor
CMacroAnalyzer::~CMacroAnalyzer() {
    Deinit();
}

//--- Inicialización
bool CMacroAnalyzer::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CMacroAnalyzer::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Establecer símbolos por defecto
    m_tenYearSymbol = "US10Y";
    m_thirtyYearSymbol = "US30Y";
    m_dxySymbol = "DXY";
    m_crbSymbol = "CRB";
    m_goldSymbol = "XAUUSD";
    m_oilSymbol = "WTI";
    m_nikkeiSymbol = "JP225";
    m_sp500Symbol = "US500";
    
    //--- Cargar tasas de interés
    LoadInterestRates();
    
    //--- Inicializar símbolos
    if(!InitializeSymbols()) {
        m_utils.LogWarning("CMacroAnalyzer::Init - Algunos símbolos macro no están disponibles");
    }
    
    //--- Actualizar datos
    Update();
    
    m_isInitialized = true;
    m_utils.LogInfo("CMacroAnalyzer inicializado correctamente");
    return true;
}

//--- Desinicialización
void CMacroAnalyzer::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Establecer símbolos
void CMacroAnalyzer::SetSymbols(string tenYear, string thirtyYear, string dxy, string crb, 
                                string gold, string oil, string nikkei = "", string sp500 = "") {
    m_tenYearSymbol = tenYear;
    m_thirtyYearSymbol = thirtyYear;
    m_dxySymbol = dxy;
    m_crbSymbol = crb;
    m_goldSymbol = gold;
    m_oilSymbol = oil;
    if(nikkei != "") m_nikkeiSymbol = nikkei;
    if(sp500 != "") m_sp500Symbol = sp500;
}

//--- Inicializar símbolos
bool CMacroAnalyzer::InitializeSymbols() {
    bool result = true;
    
    //--- Intentar seleccionar cada símbolo
    if(!SymbolSelect(m_tenYearSymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_tenYearSymbol);
        result = false;
    }
    if(!SymbolSelect(m_thirtyYearSymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_thirtyYearSymbol);
        result = false;
    }
    if(!SymbolSelect(m_dxySymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_dxySymbol);
        result = false;
    }
    if(!SymbolSelect(m_crbSymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_crbSymbol);
        result = false;
    }
    if(!SymbolSelect(m_goldSymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_goldSymbol);
        result = false;
    }
    if(!SymbolSelect(m_oilSymbol, true)) {
        m_utils.LogWarning("Símbolo no disponible: " + m_oilSymbol);
        result = false;
    }
    
    return result;
}

//--- Actualizar datos
void CMacroAnalyzer::Update() {
    if(!m_isInitialized) return;
    
    LoadTenYearData();
    LoadDXYData();
    LoadCRBData();
    LoadGoldData();
    LoadOilData();
    LoadThirtyYearData();
    LoadNikkeiData();
    LoadSP500Data();
    UpdateMacroData();
    CalculateYield();
    DetectCrackingCorrelation();
    DetectMarketSymmetry();
    CalculateIntermarketBias();
    CalculateMarketCondition();
    LoadInterestRates();
}

//--- RF-254: Cargar datos del 10-Year
bool CMacroAnalyzer::LoadTenYearData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_tenYearSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        m_utils.LogWarning("No se pudo cargar datos de " + m_tenYearSymbol);
        return false;
    }
    
    m_tenYearPrice = closeArray[0];
    return true;
}

//--- Cargar datos del 30-Year
bool CMacroAnalyzer::LoadThirtyYearData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_thirtyYearSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        return false;
    }
    
    m_thirtyYearYield = closeArray[0] / 100.0;
    return true;
}

//--- Cargar datos DXY
bool CMacroAnalyzer::LoadDXYData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_dxySymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        m_utils.LogWarning("No se pudo cargar datos de " + m_dxySymbol);
        return false;
    }
    
    m_dxy = closeArray[0];
    return true;
}

//--- Cargar datos CRB
bool CMacroAnalyzer::LoadCRBData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_crbSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        return false;
    }
    
    m_crb = closeArray[0];
    return true;
}

//--- Cargar datos Gold
bool CMacroAnalyzer::LoadGoldData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_goldSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        m_utils.LogWarning("No se pudo cargar datos de " + m_goldSymbol);
        return false;
    }
    
    m_gold = closeArray[0];
    return true;
}

//--- Cargar datos Oil
bool CMacroAnalyzer::LoadOilData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_oilSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        m_utils.LogWarning("No se pudo cargar datos de " + m_oilSymbol);
        return false;
    }
    
    m_oil = closeArray[0];
    return true;
}

//--- Cargar datos Nikkei
bool CMacroAnalyzer::LoadNikkeiData() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_nikkeiSymbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        return false;
    }
    
    m_nikkei = closeArray[0];
    return true;
}

//--- Cargar datos SP500
bool CMacroAnalyzer::LoadSP500Data() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose(m_sp500Symbol, PERIOD_D1, 0, 1, closeArray);
    if(copied < 1) {
        return false;
    }
    
    m_sp500 = closeArray[0];
    return true;
}

//--- Actualizar datos macro
bool CMacroAnalyzer::UpdateMacroData() {
    m_macroData.tenYearYield = m_tenYearYield;
    m_macroData.tenYearPrice = m_tenYearPrice;
    m_macroData.dxy = m_dxy;
    m_macroData.crb = m_crb;
    m_macroData.gold = m_gold;
    m_macroData.oil = m_oil;
    m_macroData.thirtyYearYield = m_thirtyYearYield;
    m_macroData.intermarketBias = m_intermarketBias;
    m_macroData.isCrackingCorrelation = m_isCrackingCorrelation;
    return true;
}

//--- RF-255: Calcular Yield
void CMacroAnalyzer::CalculateYield() {
    //--- Yield = 100 / Price (simplificado)
    if(m_tenYearPrice > 0) {
        m_tenYearYield = 100.0 / m_tenYearPrice;
        m_macroData.tenYearYield = m_tenYearYield;
    }
}

//--- RF-255: Calcular Yield desde precio
double CMacroAnalyzer::CalculateYieldFromPrice(double price) {
    if(price <= 0) return 0.0;
    return 100.0 / price;
}

//--- RF-259: Detectar Cracking Correlation
void CMacroAnalyzer::DetectCrackingCorrelation() {
    //--- Cracking Correlation: 10-Year y DXY se mueven en la misma dirección
    //--- (normalmente son inversos)
    double tenYearChange = GetTenYearChange();
    double dxyChange = 0.0;
    
    //--- Obtener cambio en DXY
    double dxyPrev[];
    ArraySetAsSeries(dxyPrev, true);
    if(CopyClose(m_dxySymbol, PERIOD_D1, 1, 1, dxyPrev) > 0) {
        dxyChange = (m_dxy - dxyPrev[0]) / dxyPrev[0] * 100.0;
    }
    
    //--- Si ambos se mueven en la misma dirección, hay cracking correlation
    if((tenYearChange > 0 && dxyChange > 0) || (tenYearChange < 0 && dxyChange < 0)) {
        m_isCrackingCorrelation = true;
        m_correlationScore = MathMin(MathAbs(tenYearChange + dxyChange) * 5, 100);
    } else {
        m_isCrackingCorrelation = false;
        m_correlationScore = 50;
    }
    
    m_macroData.isCrackingCorrelation = m_isCrackingCorrelation;
}

//--- RF-260: Detectar Market Symmetry
void CMacroAnalyzer::DetectMarketSymmetry() {
    //--- Market Symmetry: DXY y pares FX se mueven en direcciones opuestas
    //--- (simplificado)
    m_isMarketSymmetry = !m_isCrackingCorrelation;
}

//--- RF-256: Calcular condición de mercado
void CMacroAnalyzer::CalculateMarketCondition() {
    //--- Basado en el rango de 20 días
    double high20 = 0, low20 = 0;
    double highArray[], lowArray[];
    ArraySetAsSeries(highArray, true);
    ArraySetAsSeries(lowArray, true);
    
    if(CopyHigh(m_tenYearSymbol, PERIOD_D1, 0, 20, highArray) > 0) {
        high20 = highArray[ArrayMaximum(highArray)];
    }
    if(CopyLow(m_tenYearSymbol, PERIOD_D1, 0, 20, lowArray) > 0) {
        low20 = lowArray[ArrayMinimum(lowArray)];
    }
    
    if(high20 <= 0 || low20 <= 0) {
        m_marketCondition = STATE_CONSOLIDATION;
        return;
    }
    
    double range = high20 - low20;
    double currentPrice = m_tenYearPrice;
    double position = (currentPrice - low20) / range;
    
    if(position > 0.8) {
        m_marketCondition = STATE_EXPANSION;
    } else if(position < 0.2) {
        m_marketCondition = STATE_RETRACEMENT;
    } else if(position > 0.4 && position < 0.6) {
        m_marketCondition = STATE_CONSOLIDATION;
    } else {
        m_marketCondition = STATE_REVERSAL;
    }
}

//--- Calcular bias intermercado
void CMacroAnalyzer::CalculateIntermarketBias() {
    int bullishCount = 0;
    int bearishCount = 0;
    
    //--- Evaluar cada mercado
    ENUM_BIAS bondBias = GetBondBias();
    ENUM_BIAS commodityBias = GetCommodityBias();
    ENUM_BIAS stockBias = GetStockBias();
    ENUM_BIAS currencyBias = GetCurrencyBias();
    
    if(bondBias == BIAS_BULLISH) bullishCount++;
    else if(bondBias == BIAS_BEARISH) bearishCount++;
    
    if(commodityBias == BIAS_BULLISH) bullishCount++;
    else if(commodityBias == BIAS_BEARISH) bearishCount++;
    
    if(stockBias == BIAS_BULLISH) bullishCount++;
    else if(stockBias == BIAS_BEARISH) bearishCount++;
    
    if(currencyBias == BIAS_BULLISH) bullishCount++;
    else if(currencyBias == BIAS_BEARISH) bearishCount++;
    
    m_alignedMarkets = MathMax(bullishCount, bearishCount);
    m_correlationScore = (double)m_alignedMarkets / 4.0 * 100.0;
    
    if(bullishCount > bearishCount) {
        m_intermarketBias = BIAS_BULLISH;
    } else if(bearishCount > bullishCount) {
        m_intermarketBias = BIAS_BEARISH;
    } else {
        m_intermarketBias = BIAS_NEUTRAL;
    }
}

//--- RF-269: Obtener bias de Bonos
ENUM_BIAS CMacroAnalyzer::GetBondBias() const {
    //--- Si el yield sube, los bonos bajan (bearish)
    if(m_tenYearYield > 4.5) return BIAS_BEARISH;
    if(m_tenYearYield < 3.5) return BIAS_BULLISH;
    return BIAS_NEUTRAL;
}

//--- RF-269: Obtener bias de Materias Primas
ENUM_BIAS CMacroAnalyzer::GetCommodityBias() const {
    double crbChange = 0.0;
    double crbPrev[];
    ArraySetAsSeries(crbPrev, true);
    if(CopyClose(m_crbSymbol, PERIOD_D1, 1, 1, crbPrev) > 0) {
        crbChange = (m_crb - crbPrev[0]) / crbPrev[0] * 100.0;
    }
    
    if(crbChange > 1.0) return BIAS_BULLISH;
    if(crbChange < -1.0) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-269: Obtener bias de Acciones
ENUM_BIAS CMacroAnalyzer::GetStockBias() const {
    double spChange = 0.0;
    double spPrev[];
    ArraySetAsSeries(spPrev, true);
    if(CopyClose(m_sp500Symbol, PERIOD_D1, 1, 1, spPrev) > 0) {
        spChange = (m_sp500 - spPrev[0]) / spPrev[0] * 100.0;
    }
    
    if(spChange > 1.0) return BIAS_BULLISH;
    if(spChange < -1.0) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-269: Obtener bias de Divisas
ENUM_BIAS CMacroAnalyzer::GetCurrencyBias() const {
    if(m_dxy > 105) return BIAS_BEARISH;
    if(m_dxy < 100) return BIAS_BULLISH;
    return BIAS_NEUTRAL;
}

//--- RF-270: Correlación Bonos vs. Acciones
bool CMacroAnalyzer::IsBondStockCorrelation() const {
    //--- Normalmente inversa
    ENUM_BIAS bondBias = GetBondBias();
    ENUM_BIAS stockBias = GetStockBias();
    return bondBias != stockBias;
}

double CMacroAnalyzer::GetBondStockCorrelation() const {
    //--- Placeholder: retorna -0.5 (correlación inversa típica)
    return -0.5;
}

//--- RF-271: Correlación Bonos vs. Materias Primas
bool CMacroAnalyzer::IsBondCommodityCorrelation() const {
    ENUM_BIAS bondBias = GetBondBias();
    ENUM_BIAS commodityBias = GetCommodityBias();
    return bondBias != commodityBias;
}

double CMacroAnalyzer::GetBondCommodityCorrelation() const {
    return -0.3;
}

//--- RF-272: Correlación Dólar vs. Materias Primas
bool CMacroAnalyzer::IsDollarCommodityCorrelation() const {
    ENUM_BIAS dxyBias = (m_dxy > 102) ? BIAS_BEARISH : (m_dxy < 100) ? BIAS_BULLISH : BIAS_NEUTRAL;
    ENUM_BIAS commodityBias = GetCommodityBias();
    return dxyBias != commodityBias;
}

double CMacroAnalyzer::GetDollarCommodityCorrelation() const {
    return -0.4;
}

//--- RF-273: Indicadores Adelantados
ENUM_BIAS CMacroAnalyzer::GetLeadIndicatorBias() const {
    //--- Los bonos lideran
    return GetBondBias();
}

double CMacroAnalyzer::GetLeadIndicatorConfidence() const {
    //--- Basado en la fuerza de la señal de bonos
    if(MathAbs(m_tenYearYield - 4.0) > 1.0) return 80.0;
    return 50.0;
}

//--- RF-274: Correlaciones Clave
double CMacroAnalyzer::GetGoldCorrelation() const {
    //--- Oro vs DXY (inversa)
    return -0.6;
}

double CMacroAnalyzer::GetOilCorrelation() const {
    //--- Petróleo vs USD/CAD (directa)
    return 0.5;
}

double CMacroAnalyzer::GetNikkeiCorrelation() const {
    //--- Nikkei vs USD/JPY (directa)
    return 0.4;
}

bool CMacroAnalyzer::IsGoldConfirming(ENUM_BIAS bias) const {
    //--- Si bias es bullish, el oro debería subir
    double goldChange = 0.0;
    double goldPrev[];
    ArraySetAsSeries(goldPrev, true);
    if(CopyClose(m_goldSymbol, PERIOD_D1, 1, 1, goldPrev) > 0) {
        goldChange = (m_gold - goldPrev[0]) / goldPrev[0] * 100.0;
    }
    
    bool goldUp = goldChange > 0.5;
    return (bias == BIAS_BULLISH && goldUp) || (bias == BIAS_BEARISH && !goldUp);
}

bool CMacroAnalyzer::IsOilConfirming(ENUM_BIAS bias) const {
    double oilChange = 0.0;
    double oilPrev[];
    ArraySetAsSeries(oilPrev, true);
    if(CopyClose(m_oilSymbol, PERIOD_D1, 1, 1, oilPrev) > 0) {
        oilChange = (m_oil - oilPrev[0]) / oilPrev[0] * 100.0;
    }
    
    bool oilUp = oilChange > 1.0;
    return (bias == BIAS_BULLISH && oilUp) || (bias == BIAS_BEARISH && !oilUp);
}

bool CMacroAnalyzer::IsNikkeiConfirming(ENUM_BIAS bias) const {
    double nikkeiChange = 0.0;
    double nikkeiPrev[];
    ArraySetAsSeries(nikkeiPrev, true);
    if(CopyClose(m_nikkeiSymbol, PERIOD_D1, 1, 1, nikkeiPrev) > 0) {
        nikkeiChange = (m_nikkei - nikkeiPrev[0]) / nikkeiPrev[0] * 100.0;
    }
    
    bool nikkeiUp = nikkeiChange > 1.0;
    return (bias == BIAS_BULLISH && nikkeiUp) || (bias == BIAS_BEARISH && !nikkeiUp);
}

//--- RF-261: Confirmación con Yield
bool CMacroAnalyzer::IsYieldConfirming(ENUM_BIAS bias) const {
    if(bias == BIAS_BULLISH) {
        return IsYieldConfirmingBullish();
    } else if(bias == BIAS_BEARISH) {
        return IsYieldConfirmingBearish();
    }
    return false;
}

bool CMacroAnalyzer::IsYieldConfirmingBullish() const {
    //--- Bullish: yield en descenso (bonos suben)
    return m_tenYearYield < 4.0;
}

bool CMacroAnalyzer::IsYieldConfirmingBearish() const {
    //--- Bearish: yield en ascenso (bonos bajan)
    return m_tenYearYield > 4.5;
}

//--- RF-258: Leading Indicator
ENUM_BIAS CMacroAnalyzer::GetLeadingIndicatorBias() const {
    if(m_tenYearYield < 3.8) return BIAS_BULLISH;
    if(m_tenYearYield > 4.8) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

double CMacroAnalyzer::GetLeadingIndicatorScore() const {
    if(m_tenYearYield < 3.5) return 80.0;
    if(m_tenYearYield < 4.0) return 60.0;
    if(m_tenYearYield < 4.5) return 40.0;
    return 20.0;
}

//--- RF-262: Blending Macro y Técnico
double CMacroAnalyzer::GetMacroAlignmentScore(ENUM_BIAS bias) const {
    double score = 0.0;
    int factors = 0;
    
    //--- Factor 1: Yield confirmación (30%)
    if(IsYieldConfirming(bias)) { score += 30; }
    factors++;
    
    //--- Factor 2: Intermarket bias (30%)
    if(m_intermarketBias == bias) { score += 30; }
    factors++;
    
    //--- Factor 3: DXY confirmación (20%)
    bool dxyBullish = m_dxy < 100;
    bool dxyBearish = m_dxy > 105;
    if((bias == BIAS_BULLISH && dxyBullish) || (bias == BIAS_BEARISH && dxyBearish)) {
        score += 20;
    }
    factors++;
    
    //--- Factor 4: Seasonal confirmación (20%)
    ENUM_BIAS seasonalBias = GetSeasonalBias();
    if(seasonalBias == bias) { score += 20; }
    factors++;
    
    return score;
}

bool CMacroAnalyzer::IsMacroAligned(ENUM_BIAS bias) const {
    return GetMacroAlignmentScore(bias) >= 60.0;
}

//--- RF-263: Calificación de Trade
bool CMacroAnalyzer::IsTradeQualified(ENUM_BIAS bias) const {
    return GetMacroQualificationScore(bias) >= 70;
}

int CMacroAnalyzer::GetMacroQualificationScore(ENUM_BIAS bias) const {
    double score = GetMacroAlignmentScore(bias);
    return (int)score;
}

//--- RF-264-266: Tasas de Interés
void CMacroAnalyzer::LoadInterestRates() {
    //--- En un sistema real, estas se cargarían desde una fuente externa
    //--- Usamos valores por defecto
    m_ratesLastUpdate = TimeCurrent();
}

double CMacroAnalyzer::GetDifferential(string base, string quote) const {
    double baseRate = 0.0;
    double quoteRate = 0.0;
    
    if(base == "USD") baseRate = m_fedRate;
    else if(base == "EUR") baseRate = m_ecbRate;
    else if(base == "JPY") baseRate = m_bojRate;
    else if(base == "GBP") baseRate = m_boeRate;
    else if(base == "AUD") baseRate = m_rbaRate;
    else if(base == "NZD") baseRate = m_rbnzRate;
    else if(base == "CAD") baseRate = m_bocRate;
    else if(base == "CHF") baseRate = m_snbRate;
    
    if(quote == "USD") quoteRate = m_fedRate;
    else if(quote == "EUR") quoteRate = m_ecbRate;
    else if(quote == "JPY") quoteRate = m_bojRate;
    else if(quote == "GBP") quoteRate = m_boeRate;
    else if(quote == "AUD") quoteRate = m_rbaRate;
    else if(quote == "NZD") quoteRate = m_rbnzRate;
    else if(quote == "CAD") quoteRate = m_bocRate;
    else if(quote == "CHF") quoteRate = m_snbRate;
    
    return baseRate - quoteRate;
}

string CMacroAnalyzer::GetBestPairByDifferential() const {
    string pairs[] = {"EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDJPY", "USDCAD", "USDCHF"};
    double bestScore = -999;
    string bestPair = "";
    
    for(int i = 0; i < ArraySize(pairs); i++) {
        double score = GetPairScoreByDifferential(pairs[i]);
        if(score > bestScore) {
            bestScore = score;
            bestPair = pairs[i];
        }
    }
    
    return bestPair;
}

double CMacroAnalyzer::GetPairScoreByDifferential(string pair) const {
    string base = StringSubstr(pair, 0, 3);
    string quote = StringSubstr(pair, 3, 3);
    double diff = GetDifferential(base, quote);
    
    //--- Si el diferencial es positivo y el par es base/quote, es bullish
    if(StringFind(pair, "USD") == 0) {
        //--- Pares USD/XXX: diff positivo = USD fuerte = bearish para el par
        return -diff;
    } else {
        return diff;
    }
}

//--- RF-267: Open Interest
bool CMacroAnalyzer::IsOIConfirming(ENUM_BIAS bias) const {
    //--- Placeholder: retorna true
    return true;
}

double CMacroAnalyzer::GetOIChangePercent(string symbol) const {
    //--- Placeholder
    return 0.0;
}

//--- RF-268: Blending con Diferenciales
double CMacroAnalyzer::GetBlendedScore(ENUM_BIAS bias) const {
    double macroScore = GetMacroAlignmentScore(bias);
    double diffScore = 50.0;
    
    //--- Mejorar con diferenciales
    string bestPair = GetBestPairByDifferential();
    if(bestPair != "") {
        diffScore = 50 + GetPairScoreByDifferential(bestPair) * 2;
    }
    
    return (macroScore * 0.6 + diffScore * 0.4);
}

bool CMacroAnalyzer::IsBlendedValid(ENUM_BIAS bias) const {
    return GetBlendedScore(bias) >= 60.0;
}

//--- Risk Environment
ENUM_RISK_ENVIRONMENT CMacroAnalyzer::GetRiskEnvironment() const {
    if(GetStockBias() == BIAS_BULLISH && GetCommodityBias() == BIAS_BULLISH && m_dxy < 102) {
        return RISK_ON;
    }
    if(GetStockBias() == BIAS_BEARISH && GetCommodityBias() == BIAS_BEARISH && m_dxy > 103) {
        return RISK_OFF;
    }
    return RISK_NEUTRAL;
}

bool CMacroAnalyzer::IsRiskOn() const {
    return GetRiskEnvironment() == RISK_ON;
}

bool CMacroAnalyzer::IsRiskOff() const {
    return GetRiskEnvironment() == RISK_OFF;
}

int CMacroAnalyzer::GetAlignedMarketsCount() const {
    return m_alignedMarkets;
}

//--- RF-258: 10-Year Change
double CMacroAnalyzer::GetTenYearChange() const {
    double tenYearPrev[];
    ArraySetAsSeries(tenYearPrev, true);
    if(CopyClose(m_tenYearSymbol, PERIOD_D1, 1, 1, tenYearPrev) > 0) {
        return (m_tenYearPrice - tenYearPrev[0]) / tenYearPrev[0] * 100.0;
    }
    return 0.0;
}

bool CMacroAnalyzer::IsTenYearRising() const {
    return GetTenYearChange() > 0.5;
}

bool CMacroAnalyzer::IsTenYearFalling() const {
    return GetTenYearChange() < -0.5;
}

//--- RF-259: Cracking Correlation Score
double CMacroAnalyzer::GetCrackingCorrelationScore() const {
    return m_correlationScore;
}

//--- RF-260: Market Symmetry Score
double CMacroAnalyzer::GetMarketSymmetryScore() const {
    return m_isMarketSymmetry ? 70.0 : 30.0;
}

//--- RF-275-289: Seasonal (placeholder)
double CMacroAnalyzer::GetSeasonalStrength() const {
    return 50.0;
}

bool CMacroAnalyzer::IsSeasonalIdeal() const {
    return false;
}

bool CMacroAnalyzer::IsSeasonalConverged() const {
    return false;
}

string CMacroAnalyzer::GetSeasonalCalendar() {
    return "Seasonal calendar not implemented";
}

ENUM_BIAS CMacroAnalyzer::GetSeasonalBias() const {
    return BIAS_NEUTRAL;
}

ENUM_BIAS CMacroAnalyzer::GetSeasonalBiasForPair(string pair) const {
    return BIAS_NEUTRAL;
}

ENUM_BIAS CMacroAnalyzer::GetInvertedSeasonalBias(string pair) const {
    ENUM_BIAS bias = GetSeasonalBiasForPair(pair);
    if(bias == BIAS_BULLISH) return BIAS_BEARISH;
    if(bias == BIAS_BEARISH) return BIAS_BULLISH;
    return BIAS_NEUTRAL;
}

bool CMacroAnalyzer::IsSeasonalOppo(string pair) const {
    return GetSeasonalBiasForPair(pair) != BIAS_NEUTRAL;
}

//--- RF-257: Seasonal Valid
bool CMacroAnalyzer::IsSeasonalValid() const {
    return GetSeasonalBias() != BIAS_NEUTRAL;
}

//--- RF-269: Intermarket Alignment
double CMacroAnalyzer::GetIntermarketAlignment() const {
    return m_correlationScore;
}

//--- RF-278: CAD vs Oil Correlation
bool CMacroAnalyzer::IsOilConfirming(ENUM_BIAS bias) const;

//--- RF-371: COT Alignment
bool CMacroAnalyzer::IsCOTAligned() const {
    //--- Placeholder: retorna true si COT está alineado
    //--- En implementación real, se verificarían los datos COT
    return true;
}

bool CMacroAnalyzer::IsCOTHedgingProgramAligned() const {
    //--- Placeholder: retorna true si el programa de cobertura está alineado
    return true;
}

//--- Reportes
string CMacroAnalyzer::GetSummary() {
    string summary = "=== MACRO SUMMARY ===\n";
    summary += "10-Year Yield: " + DoubleToString(m_tenYearYield, 2) + "%\n";
    summary += "DXY: " + DoubleToString(m_dxy, 2) + "\n";
    summary += "Gold: " + DoubleToString(m_gold, 2) + "\n";
    summary += "Oil: " + DoubleToString(m_oil, 2) + "\n";
    summary += "Intermarket Bias: " + (m_intermarketBias == BIAS_BULLISH ? "BULLISH" : 
                                        (m_intermarketBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Cracking Correlation: " + (m_isCrackingCorrelation ? "YES" : "NO") + "\n";
    summary += "Market Symmetry: " + (m_isMarketSymmetry ? "YES" : "NO") + "\n";
    summary += "Risk Environment: " + (IsRiskOn() ? "RISK ON" : (IsRiskOff() ? "RISK OFF" : "NEUTRAL")) + "\n";
    summary += "Market Condition: " + (m_marketCondition == STATE_EXPANSION ? "EXPANSION" :
                                        (m_marketCondition == STATE_RETRACEMENT ? "RETRACEMENT" :
                                         (m_marketCondition == STATE_REVERSAL ? "REVERSAL" : "CONSOLIDATION"))) + "\n";
    summary += "=========================";
    return summary;
}

string CMacroAnalyzer::GetMacroReport() {
    string report = "=== MACRO REPORT ===\n";
    report += "10-Year Price: " + DoubleToString(m_tenYearPrice, 2) + "\n";
    report += "10-Year Yield: " + DoubleToString(m_tenYearYield, 2) + "%\n";
    report += "30-Year Yield: " + DoubleToString(m_thirtyYearYield, 2) + "%\n";
    report += "DXY: " + DoubleToString(m_dxy, 2) + "\n";
    report += "CRB: " + DoubleToString(m_crb, 2) + "\n";
    report += "Gold: " + DoubleToString(m_gold, 2) + "\n";
    report += "Oil: " + DoubleToString(m_oil, 2) + "\n";
    report += "=========================";
    return report;
}

string CMacroAnalyzer::GetIntermarketReport() {
    string report = "=== INTERMARKET REPORT ===\n";
    report += "Bonds: " + (GetBondBias() == BIAS_BULLISH ? "BULLISH" : 
                           (GetBondBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Commodities: " + (GetCommodityBias() == BIAS_BULLISH ? "BULLISH" : 
                                 (GetCommodityBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Stocks: " + (GetStockBias() == BIAS_BULLISH ? "BULLISH" : 
                            (GetStockBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Currencies: " + (GetCurrencyBias() == BIAS_BULLISH ? "BULLISH" : 
                                (GetCurrencyBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Aligned Markets: " + IntegerToString(m_alignedMarkets) + "/4\n";
    report += "Correlation Score: " + DoubleToString(m_correlationScore, 1) + "%\n";
    report += "Risk Environment: " + (IsRiskOn() ? "RISK ON" : (IsRiskOff() ? "RISK OFF" : "NEUTRAL")) + "\n";
    report += "=============================";
    return report;
}

string CMacroAnalyzer::GetRatesReport() {
    string report = "=== RATES REPORT ===\n";
    report += "Fed: " + DoubleToString(m_fedRate, 2) + "%\n";
    report += "ECB: " + DoubleToString(m_ecbRate, 2) + "%\n";
    report += "BoJ: " + DoubleToString(m_bojRate, 2) + "%\n";
    report += "BoE: " + DoubleToString(m_boeRate, 2) + "%\n";
    report += "RBA: " + DoubleToString(m_rbaRate, 2) + "%\n";
    report += "RBNZ: " + DoubleToString(m_rbnzRate, 2) + "%\n";
    report += "BoC: " + DoubleToString(m_bocRate, 2) + "%\n";
    report += "SNB: " + DoubleToString(m_snbRate, 2) + "%\n";
    report += "Best Pair by Differential: " + GetBestPairByDifferential() + "\n";
    report += "=========================";
    return report;
}

#endif // __CMACROANALYZER_MQH__