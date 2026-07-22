//+------------------------------------------------------------------+
//|                                                    CSeasonal.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona las tendencias estacionales:                |
//| - Datos estacionales de 40+ años                                 |
//| - Ideal Seasonal Tendency                                        |
//| - Convergencia 40/15 años                                        |
//| - Seasonal como filtro obligatorio para OSOK y Swing             |
//| - Análisis estacional para stocks y commodities                  |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-641: 40-Year Seasonal Data Integration                      |
//|   RF-642: 15-Year Seasonal Data Integration                      |
//|   RF-643: Ideal Seasonal Tendency Detection                      |
//|   RF-644: Seasonal Convergence (40/15 Year)                      |
//|   RF-645: Seasonal Calendar Integration                          |
//|   RF-646: Seasonal Bias Determination                            |
//|   RF-647: Seasonal as Mandatory Filter                           |
//|   RF-648: Seasonal as Context Filter                             |
//|   RF-649: Seasonal Timing for Entries                            |
//|   RF-650: Seasonal Divergence Detection                          |
//|   RF-651: Seasonal Strength Score                                |
//|   RF-652: Seasonal Ranking                                       |
//|   RF-653: Seasonal Historical Validation                         |
//|   RF-654: Seasonal Exception Detection                           |
//|   RF-655: Seasonal Logging                                       |
//|   RF-656: Seasonal Dashboard                                     |
//|   RF-657: Commodity Seasonal Analysis                            |
//|   RF-658: Bond Seasonal Analysis                                 |
//|   RF-659: Stock Seasonal Analysis                                |
//|   RF-660: Currency Pair Seasonal Analysis                        |
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

#ifndef __CSEASONAL_MQH__
#define __CSEASONAL_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
//--- SeasonalData ya está definido en CConstants.mqh

//--- Estructura adicional para ranking (no definida en CConstants)
struct SeasonalRanking {
    string           symbol;
    double           score;
    ENUM_BIAS        bias;
    int              rank;
};

//+------------------------------------------------------------------+
//| CLASE CSeasonal - Gestión de Tendencias Estacionales             |
//+------------------------------------------------------------------+
class CSeasonal {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_dataPath;
    
    //--- Datos estacionales
    SeasonalData       m_seasonalData[];
    SeasonalData       m_dxySeasonalData[];
    SeasonalData       m_commoditySeasonalData[];
    SeasonalData       m_bondSeasonalData[];
    SeasonalData       m_stockSeasonalData[];
    int                m_dataCount;
    int                m_dxyCount;
    int                m_commodityCount;
    int                m_bondCount;
    int                m_stockCount;
    
    //--- Estado actual
    ENUM_BIAS          m_currentBias;
    ENUM_BIAS          m_dxyBias;
    bool               m_isIdealSeasonal;
    bool               m_isConverged;
    double             m_strengthScore;
    int                m_currentMonth;
    string             m_currentSymbol;
    
    //--- Constantes de datos estacionales integrados
    //--- Datos aproximados para EUR/USD (40 años)
    static const double EURUSD_SEASONAL_40[12];
    static const double EURUSD_SEASONAL_15[12];
    static const double EURUSD_WINRATE_40[12];
    static const double EURUSD_WINRATE_15[12];
    
    //--- Datos aproximados para GBP/USD (40 años)
    static const double GBPUSD_SEASONAL_40[12];
    static const double GBPUSD_SEASONAL_15[12];
    static const double GBPUSD_WINRATE_40[12];
    static const double GBPUSD_WINRATE_15[12];
    
    //--- Datos aproximados para USD/JPY (40 años)
    static const double USDJPY_SEASONAL_40[12];
    static const double USDJPY_SEASONAL_15[12];
    static const double USDJPY_WINRATE_40[12];
    static const double USDJPY_WINRATE_15[12];
    
    //--- Datos aproximados para DXY (40 años)
    static const double DXY_SEASONAL_40[12];
    static const double DXY_SEASONAL_15[12];
    static const double DXY_WINRATE_40[12];
    static const double DXY_WINRATE_15[12];
    
    //--- Datos aproximados para Oro (40 años)
    static const double GOLD_SEASONAL_40[12];
    static const double GOLD_SEASONAL_15[12];
    static const double GOLD_WINRATE_40[12];
    static const double GOLD_WINRATE_15[12];
    
    //--- Datos aproximados para Bonos (30-Year Treasury)
    static const double BOND_SEASONAL_40[12];
    static const double BOND_SEASONAL_15[12];
    static const double BOND_WINRATE_40[12];
    static const double BOND_WINRATE_15[12];
    
    //--- Datos aproximados para Stocks (Dow 30)
    static const double STOCK_SEASONAL_40[12];
    static const double STOCK_SEASONAL_15[12];
    static const double STOCK_WINRATE_40[12];
    static const double STOCK_WINRATE_15[12];
    
    //--- Métodos privados
    bool               InitializeData();
    bool               LoadSeasonalData();
    bool               LoadDXYData();
    bool               LoadCommodityData();
    bool               LoadBondData();
    bool               LoadStockData();
    ENUM_BIAS          GetBiasFromReturn(double ret) const;
    double             GetReturnForSymbol(string symbol, int month, bool use40Year = true) const;
    double             GetWinRateForSymbol(string symbol, int month, bool use40Year = true) const;
    bool               IsSymbolInData(string symbol);
    bool               IsDXYInData();
    bool               IsCommodityInData(string symbol);
    bool               IsBondInData(string symbol);
    bool               IsStockInData(string symbol);
    
public:
    //--- Constructor / Destructor
    CSeasonal();
    ~CSeasonal();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-641/642: Seasonal Data Integration
    bool LoadData(string symbol);
    bool HasData(string symbol) const;
    bool HasDataForMonth(string symbol, int month) const;
    
    //--- RF-643: Ideal Seasonal Tendency
    bool IsIdealSeasonal(string symbol) const;
    bool IsIdealSeasonalWithDXY(string symbol) const;
    ENUM_BIAS GetIdealSeasonalBias(string symbol) const;
    
    //--- RF-644: Seasonal Convergence
    bool IsConverged(string symbol) const;
    double GetConvergenceScore(string symbol) const;
    bool IsConvergedForMonth(string symbol, int month) const;
    
    //--- RF-646: Seasonal Bias
    ENUM_BIAS GetSeasonalBias(string symbol) const;
    ENUM_BIAS GetSeasonalBiasForMonth(string symbol, int month) const;
    ENUM_BIAS GetSeasonalBiasForCurrentMonth(string symbol) const;
    
    //--- RF-647: Seasonal as Mandatory Filter
    bool IsSeasonalValid(string symbol) const;
    bool IsSeasonalValidForModel(string symbol, ENUM_TRADING_MODEL model) const;
    bool IsSeasonalValidForCurrentMonth(string symbol) const;
    
    //--- RF-648: Seasonal as Context Filter
    bool IsContextValid(string symbol, ENUM_BIAS bias) const;
    bool IsContextValidForCurrentMonth(string symbol, ENUM_BIAS bias) const;
    
    //--- RF-649: Seasonal Timing
    bool IsOptimalTiming(string symbol) const;
    int GetOptimalMonth(string symbol) const;
    int GetOptimalMonthForBias(string symbol, ENUM_BIAS bias) const;
    
    //--- RF-650: Seasonal Divergence
    bool IsDivergence(string symbol) const;
    bool IsDivergenceWithPrice(string symbol, double price) const;
    bool IsDivergenceWithDXY(string symbol) const;
    
    //--- RF-651: Seasonal Strength Score
    double GetStrengthScore(string symbol) const;
    double GetStrengthScoreForMonth(string symbol, int month) const;
    double GetStrengthScoreForCurrentMonth(string symbol) const;
    
    //--- RF-652: Seasonal Ranking
    void GetRanking(string &symbols[], double &scores[]);
    string GetBestSymbol();
    string GetBestSymbolForBias(ENUM_BIAS bias);
    
    //--- RF-653: Seasonal Historical Validation
    double GetHistoricalWinRate(string symbol) const;
    double GetHistoricalReturn(string symbol) const;
    int GetSampleSize(string symbol) const;
    double GetHistoricalWinRateForMonth(string symbol, int month) const;
    
    //--- RF-654: Seasonal Exception Detection
    bool IsException(string symbol) const;
    string GetExceptionReason(string symbol) const;
    bool IsExceptionForMonth(string symbol, int month) const;
    
    //--- RF-657-660: Asset Class Specific
    ENUM_BIAS GetCommoditySeasonalBias(string symbol) const;
    ENUM_BIAS GetBondSeasonalBias(string symbol) const;
    ENUM_BIAS GetStockSeasonalBias(string symbol) const;
    ENUM_BIAS GetCurrencySeasonalBias(string symbol) const;
    bool IsCommoditySeasonalValid(string symbol) const;
    bool IsBondSeasonalValid(string symbol) const;
    bool IsStockSeasonalValid(string symbol) const;
    
    //--- RF-645: Seasonal Calendar
    string GetSeasonalCalendar(int month);
    string GetCurrentMonthCalendar();
    string GetOptimalSymbolsForMonth(int month);
    
    //--- Getters
    int GetCurrentMonth() const { return m_currentMonth; }
    ENUM_BIAS GetCurrentBias() const { return m_currentBias; }
    ENUM_BIAS GetDXYBias() const { return m_dxyBias; }
    bool IsIdealSeasonalDetected() const { return m_isIdealSeasonal; }
    bool IsConvergenceDetected() const { return m_isConverged; }
    double GetStrengthScore() const { return m_strengthScore; }
    string GetCurrentSymbol() const { return m_currentSymbol; }
    
    //--- Reportes
    string GetSummary(string symbol);
    string GetSeasonalReport(string symbol);
    string GetCalendarReport();
    string GetRankingReport();
};

//+------------------------------------------------------------------+
//| DATOS ESTACIONALES GLOBALES (valores aproximados para demo)      |
//+------------------------------------------------------------------+
//--- EUR/USD 40 años (retornos mensuales promedio %)
double g_EURUSD_SEASONAL_40[12] = {
    0.5, 0.8, -0.3, 1.2, -0.5, -0.8, 1.0, 0.6, -0.2, 1.5, 0.9, 0.3
};
double g_EURUSD_SEASONAL_15[12] = {
    0.4, 0.9, -0.2, 1.1, -0.4, -0.7, 0.9, 0.5, -0.1, 1.4, 0.8, 0.2
};
double g_EURUSD_WINRATE_40[12] = {
    55, 60, 45, 65, 40, 35, 58, 52, 48, 70, 62, 52
};
double g_EURUSD_WINRATE_15[12] = {
    53, 58, 47, 63, 42, 37, 56, 50, 50, 68, 60, 50
};
 
//--- GBP/USD 40 años
double g_GBPUSD_SEASONAL_40[12] = {
    0.3, 0.6, -0.5, 1.5, -0.3, -0.6, 1.2, 0.4, -0.4, 1.8, 0.7, 0.1
};
double g_GBPUSD_SEASONAL_15[12] = {
    0.2, 0.5, -0.4, 1.4, -0.2, -0.5, 1.1, 0.3, -0.3, 1.7, 0.6, 0.0
};
double g_GBPUSD_WINRATE_40[12] = {
    52, 58, 42, 68, 38, 32, 60, 48, 45, 72, 58, 48
};
double g_GBPUSD_WINRATE_15[12] = {
    50, 56, 44, 66, 40, 34, 58, 46, 47, 70, 56, 46
};

//--- USD/JPY 40 años
double g_USDJPY_SEASONAL_40[12] = {
    0.8, 1.2, 0.5, -0.3, 1.5, 0.2, -0.8, -1.2, 0.6, 1.0, 0.3, 0.7
};
double g_USDJPY_SEASONAL_15[12] = {
    0.7, 1.1, 0.4, -0.2, 1.4, 0.1, -0.7, -1.1, 0.5, 0.9, 0.2, 0.6
};
double g_USDJPY_WINRATE_40[12] = {
    58, 62, 52, 45, 65, 48, 38, 32, 55, 60, 50, 55
};
double g_USDJPY_WINRATE_15[12] = {
    56, 60, 50, 47, 63, 50, 40, 34, 53, 58, 48, 53
};

//--- DXY 40 años
double g_DXY_SEASONAL_40[12] = {
    -0.4, -0.7, 0.2, -1.0, 0.3, 0.6, -0.8, -0.4, 0.1, -1.3, -0.7, -0.2
};
double g_DXY_SEASONAL_15[12] = {
    -0.3, -0.6, 0.1, -0.9, 0.2, 0.5, -0.7, -0.3, 0.0, -1.2, -0.6, -0.1
};
double g_DXY_WINRATE_40[12] = {
    45, 40, 52, 35, 58, 62, 42, 48, 50, 30, 38, 48
};
double g_DXY_WINRATE_15[12] = {
    47, 42, 50, 37, 56, 60, 44, 50, 48, 32, 40, 50
};

//--- Gold 40 años
double g_GOLD_SEASONAL_40[12] = {
    0.8, 1.0, 0.2, 2.0, 0.5, -0.5, 1.5, 1.2, 0.0, 2.5, 1.8, 0.6
};
double g_GOLD_SEASONAL_15[12] = {
    0.7, 0.9, 0.1, 1.8, 0.4, -0.4, 1.4, 1.1, -0.1, 2.3, 1.7, 0.5
};
double g_GOLD_WINRATE_40[12] = {
    55, 58, 48, 68, 52, 42, 62, 60, 45, 72, 65, 52
};
double g_GOLD_WINRATE_15[12] = {
    53, 56, 50, 66, 50, 44, 60, 58, 47, 70, 63, 50
};

//--- Bonds (30-Year Treasury) 40 años
double g_BOND_SEASONAL_40[12] = {
    -0.3, -0.5, 0.1, -1.2, 0.4, 0.8, -0.6, -0.2, 0.0, -1.5, -0.8, -0.1
};
double g_BOND_SEASONAL_15[12] = {
    -0.2, -0.4, 0.0, -1.1, 0.3, 0.7, -0.5, -0.1, -0.1, -1.4, -0.7, 0.0
};
double g_BOND_WINRATE_40[12] = {
    48, 42, 50, 35, 55, 60, 45, 48, 48, 32, 40, 48
};
double g_BOND_WINRATE_15[12] = {
    50, 44, 48, 37, 53, 58, 47, 50, 46, 34, 42, 50
};

//--- Stocks (Dow 30) 40 años
double g_STOCK_SEASONAL_40[12] = {
    0.5, 0.8, 1.2, 2.0, 0.3, -0.8, 1.0, 0.2, -0.5, 1.8, 2.5, 1.0
};
double g_STOCK_SEASONAL_15[12] = {
    0.4, 0.7, 1.1, 1.8, 0.2, -0.7, 0.9, 0.1, -0.4, 1.7, 2.3, 0.9
};
double g_STOCK_WINRATE_40[12] = {
    52, 55, 60, 68, 48, 38, 55, 50, 42, 65, 70, 55
};
double g_STOCK_WINRATE_15[12] = {
    50, 53, 58, 66, 46, 40, 53, 48, 44, 63, 68, 53
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                    |
//+------------------------------------------------------------------+

//--- Constructor
CSeasonal::CSeasonal() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_dataPath = "";
    m_dataCount = 0;
    m_dxyCount = 0;
    m_commodityCount = 0;
    m_bondCount = 0;
    m_stockCount = 0;
    m_currentBias = BIAS_NEUTRAL;
    m_dxyBias = BIAS_NEUTRAL;
    m_isIdealSeasonal = false;
    m_isConverged = false;
    m_strengthScore = 0.0;
    m_currentMonth = 0;
    m_currentSymbol = "";
}

//--- Destructor
CSeasonal::~CSeasonal() {
    Deinit();
}

//--- Inicialización
bool CSeasonal::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CSeasonal::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Obtener mes actual
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    m_currentMonth = dt.mon;
    
    //--- Inicializar datos
    if(!InitializeData()) {
        m_utils.LogError("CSeasonal::Init - Error al inicializar datos");
        return false;
    }
    
    //--- Cargar datos
    if(!LoadSeasonalData()) {
        m_utils.LogWarning("CSeasonal::Init - No se pudieron cargar datos estacionales");
    }
    
    if(!LoadDXYData()) {
        m_utils.LogWarning("CSeasonal::Init - No se pudieron cargar datos DXY");
    }
    
    if(!LoadCommodityData()) {
        m_utils.LogWarning("CSeasonal::Init - No se pudieron cargar datos de commodities");
    }
    
    if(!LoadBondData()) {
        m_utils.LogWarning("CSeasonal::Init - No se pudieron cargar datos de bonos");
    }
    
    if(!LoadStockData()) {
        m_utils.LogWarning("CSeasonal::Init - No se pudieron cargar datos de stocks");
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CSeasonal inicializado correctamente");
    return true;
}

//--- Desinicialización
void CSeasonal::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    
    ArrayResize(m_seasonalData, 0);
    ArrayResize(m_dxySeasonalData, 0);
    ArrayResize(m_commoditySeasonalData, 0);
    ArrayResize(m_bondSeasonalData, 0);
    ArrayResize(m_stockSeasonalData, 0);
}

//--- RF-641/642: Inicializar datos estacionales
bool CSeasonal::InitializeData() {
    //--- Aquí se cargarían datos reales desde archivos CSV
    //--- Por ahora usamos datos integrados para demostración
    
    return true;
}

//--- Cargar datos estacionales
bool CSeasonal::LoadSeasonalData() {
    //--- Cargar datos para pares principales
    string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD"};
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        LoadData(symbols[i]);
    }
    
    return true;
}

//--- Cargar datos DXY
bool CSeasonal::LoadDXYData() {
    //--- DXY tiene datos integrados
    return true;
}

//--- Cargar datos de commodities
bool CSeasonal::LoadCommodityData() {
    //--- Commodities tienen datos integrados
    return true;
}

//--- Cargar datos de bonos
bool CSeasonal::LoadBondData() {
    //--- Bonos tienen datos integrados
    return true;
}

//--- Cargar datos de stocks
bool CSeasonal::LoadStockData() {
    //--- Stocks tienen datos integrados
    return true;
}

//--- Cargar datos para un símbolo específico
bool CSeasonal::LoadData(string symbol) {
    if(!m_isInitialized) return false;
    
    //--- Verificar si ya está cargado
    if(HasData(symbol)) return true;
    
    //--- Crear entrada en el array
    int idx = m_dataCount;
    ArrayResize(m_seasonalData, m_dataCount + 12);
    
    //--- Cargar datos para cada mes
    for(int month = 1; month <= 12; month++) {
        m_seasonalData[idx + month - 1].symbol = symbol;
        m_seasonalData[idx + month - 1].month = month;
        m_seasonalData[idx + month - 1].bias = GetSeasonalBiasForMonth(symbol, month);
        m_seasonalData[idx + month - 1].historicalReturn = GetReturnForSymbol(symbol, month);
        m_seasonalData[idx + month - 1].winRate = GetWinRateForSymbol(symbol, month);
        m_seasonalData[idx + month - 1].sampleSize = 40;
        m_seasonalData[idx + month - 1].isIdealSeasonal = false;
        m_seasonalData[idx + month - 1].isConverged = IsConvergedForMonth(symbol, month);
        //--- strength no es parte de SeasonalData en CConstants
        //--- El valor se obtiene mediante GetStrengthScoreForMonth()
        //--- exceptionReason no es parte de SeasonalData en CConstants
        //--- La excepción se verifica mediante IsException()
    }
    
    m_dataCount += 12;
    return true;
}

//--- Obtener retorno para un símbolo y mes
double CSeasonal::GetReturnForSymbol(string symbol, int month, bool use40Year = true) const {
    if(month < 1 || month > 12) return 0.0;
    
    int idx = month - 1;
    
    if(symbol == "EURUSD" || symbol == "EURUSD") {
        return use40Year ? g_EURUSD_SEASONAL_40[idx] : g_EURUSD_SEASONAL_15[idx];
    }
    if(symbol == "GBPUSD" || symbol == "GBPUSD") {
        return use40Year ? g_GBPUSD_SEASONAL_40[idx] : g_GBPUSD_SEASONAL_15[idx];
    }
    if(symbol == "USDJPY" || symbol == "USDJPY") {
        return use40Year ? g_USDJPY_SEASONAL_40[idx] : g_USDJPY_SEASONAL_15[idx];
    }
    if(symbol == "DXY" || symbol == "DXY") {
        return use40Year ? g_DXY_SEASONAL_40[idx] : g_DXY_SEASONAL_15[idx];
    }
    if(symbol == "XAUUSD" || symbol == "GOLD" || symbol == "Gold") {
        return use40Year ? g_GOLD_SEASONAL_40[idx] : g_GOLD_SEASONAL_15[idx];
    }
    if(symbol == "BOND" || symbol == "30Y" || symbol == "Bonds") {
        return use40Year ? g_BOND_SEASONAL_40[idx] : g_BOND_SEASONAL_15[idx];
    }
    if(symbol == "STOCK" || symbol == "DOW" || symbol == "Dow30") {
        return use40Year ? g_STOCK_SEASONAL_40[idx] : g_STOCK_SEASONAL_15[idx];
    }
    
    return 0.0;
}

//--- Obtener win rate para un símbolo y mes
double CSeasonal::GetWinRateForSymbol(string symbol, int month, bool use40Year = true) const {
    if(month < 1 || month > 12) return 50.0;
    
    int idx = month - 1;
    
    if(symbol == "EURUSD" || symbol == "EURUSD") {
        return use40Year ? g_EURUSD_WINRATE_40[idx] : g_EURUSD_WINRATE_15[idx];
    }
    if(symbol == "GBPUSD" || symbol == "GBPUSD") {
        return use40Year ? g_GBPUSD_WINRATE_40[idx] : g_GBPUSD_WINRATE_15[idx];
    }
    if(symbol == "USDJPY" || symbol == "USDJPY") {
        return use40Year ? g_USDJPY_WINRATE_40[idx] : g_USDJPY_WINRATE_15[idx];
    }
    if(symbol == "DXY" || symbol == "DXY") {
        return use40Year ? g_DXY_WINRATE_40[idx] : g_DXY_WINRATE_15[idx];
    }
    if(symbol == "XAUUSD" || symbol == "GOLD" || symbol == "Gold") {
        return use40Year ? g_GOLD_WINRATE_40[idx] : g_GOLD_WINRATE_15[idx];
    }
    if(symbol == "BOND" || symbol == "30Y" || symbol == "Bonds") {
        return use40Year ? g_BOND_WINRATE_40[idx] : g_BOND_WINRATE_15[idx];
    }
    if(symbol == "STOCK" || symbol == "DOW" || symbol == "Dow30") {
        return use40Year ? g_STOCK_WINRATE_40[idx] : g_STOCK_WINRATE_15[idx];
    }
    
    return 50.0;
}

//--- Obtener bias de retorno
ENUM_BIAS CSeasonal::GetBiasFromReturn(double ret) const {
    if(ret > 0.3) return BIAS_BULLISH;
    if(ret < -0.3) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-646: Obtener bias estacional para un símbolo
ENUM_BIAS CSeasonal::GetSeasonalBias(string symbol) const {
    return GetSeasonalBiasForMonth(symbol, m_currentMonth);
}

//--- RF-646: Obtener bias estacional para un símbolo y mes
ENUM_BIAS CSeasonal::GetSeasonalBiasForMonth(string symbol, int month) const {
    double ret = GetReturnForSymbol(symbol, month);
    return GetBiasFromReturn(ret);
}

//--- RF-646: Obtener bias estacional para el mes actual
ENUM_BIAS CSeasonal::GetSeasonalBiasForCurrentMonth(string symbol) const {
    return GetSeasonalBiasForMonth(symbol, m_currentMonth);
}

//--- RF-643: Verificar si es Ideal Seasonal
bool CSeasonal::IsIdealSeasonal(string symbol) const {
    //--- Ideal Seasonal: activo bullish y DXY bearish, o viceversa
    ENUM_BIAS symbolBias = GetSeasonalBias(symbol);
    ENUM_BIAS dxyBias = GetSeasonalBias("DXY");
    
    //--- Calcular resultado sin modificar el estado
    bool result = (symbolBias != BIAS_NEUTRAL && 
                   dxyBias != BIAS_NEUTRAL && 
                   symbolBias != dxyBias);
    
    //--- Actualizar el estado (esto no debería hacerse en un método const)
    //--- La variable m_isIdealSeasonal se actualiza en Update() o Init()
    return result;
}

//--- RF-643: Ideal Seasonal con DXY
bool CSeasonal::IsIdealSeasonalWithDXY(string symbol) const {
    return IsIdealSeasonal(symbol);
}

//--- RF-643: Obtener bias de Ideal Seasonal
ENUM_BIAS CSeasonal::GetIdealSeasonalBias(string symbol) const {
    if(!IsIdealSeasonal(symbol)) return BIAS_NEUTRAL;
    return GetSeasonalBias(symbol);
}

//--- RF-644: Verificar convergencia 40/15 años
bool CSeasonal::IsConverged(string symbol) const {
    return IsConvergedForMonth(symbol, m_currentMonth);
}

//--- RF-644: Verificar convergencia para un mes específico
bool CSeasonal::IsConvergedForMonth(string symbol, int month) const {
    double ret40 = GetReturnForSymbol(symbol, month, true);
    double ret15 = GetReturnForSymbol(symbol, month, false);
    double win40 = GetWinRateForSymbol(symbol, month, true);
    double win15 = GetWinRateForSymbol(symbol, month, false);
    
    //--- Convergencia si ambos retornos tienen el mismo signo y win rates > 55%
    bool sameSign = (ret40 > 0 && ret15 > 0) || (ret40 < 0 && ret15 < 0);
    bool highWinRate = win40 > 55 && win15 > 55;
    
    return sameSign && highWinRate;
}

//--- RF-644: Obtener score de convergencia
double CSeasonal::GetConvergenceScore(string symbol) const {
    double ret40 = GetReturnForSymbol(symbol, m_currentMonth, true);
    double ret15 = GetReturnForSymbol(symbol, m_currentMonth, false);
    double win40 = GetWinRateForSymbol(symbol, m_currentMonth, true);
    double win15 = GetWinRateForSymbol(symbol, m_currentMonth, false);
    
    double score = 0.0;
    
    //--- Score basado en alineación de retornos
    if((ret40 > 0 && ret15 > 0) || (ret40 < 0 && ret15 < 0)) {
        score += 40;
    } else {
        score += 10;
    }
    
    //--- Score basado en win rate
    score += (win40 - 50) * 1.5;
    score += (win15 - 50) * 1.5;
    
    if(score > 100) score = 100;
    if(score < 0) score = 0;
    
    return score;
}

//--- RF-647: Verificar si seasonal es válido (filtro obligatorio)
bool CSeasonal::IsSeasonalValid(string symbol) const {
    ENUM_BIAS bias = GetSeasonalBias(symbol);
    return bias != BIAS_NEUTRAL;
}

//--- RF-647: Verificar seasonal para un modelo específico
bool CSeasonal::IsSeasonalValidForModel(string symbol, ENUM_TRADING_MODEL model) const {
    //--- OSOK y Swing requieren seasonal obligatorio
    if(model == MODEL_OSOK || model == MODEL_SWING) {
        ENUM_BIAS bias = GetSeasonalBias(symbol);
        if(bias == BIAS_NEUTRAL) return false;
        return IsConverged(symbol);
    }
    
    //--- Otros modelos usan seasonal como contexto
    return IsSeasonalValid(symbol);
}

//--- RF-648: Verificar contexto estacional
bool CSeasonal::IsContextValid(string symbol, ENUM_BIAS bias) const {
    ENUM_BIAS seasonalBias = GetSeasonalBias(symbol);
    
    //--- Si el seasonal es neutral, siempre válido como contexto
    if(seasonalBias == BIAS_NEUTRAL) return true;
    
    //--- Si el bias coincide con el seasonal, contexto válido
    return seasonalBias == bias;
}

//--- RF-648: Verificar contexto para el mes actual
bool CSeasonal::IsContextValidForCurrentMonth(string symbol, ENUM_BIAS bias) const {
    return IsContextValid(symbol, bias);
}

//--- RF-649: Verificar timing óptimo
bool CSeasonal::IsOptimalTiming(string symbol) const {
    double strength = GetStrengthScoreForCurrentMonth(symbol);
    return strength > 60;
}

//--- RF-649: Obtener mes óptimo
int CSeasonal::GetOptimalMonth(string symbol) const {
    int bestMonth = 1;
    double bestScore = -1;
    
    for(int month = 1; month <= 12; month++) {
        double score = GetStrengthScoreForMonth(symbol, month);
        if(score > bestScore) {
            bestScore = score;
            bestMonth = month;
        }
    }
    
    return bestMonth;
}

//--- RF-649: Obtener mes óptimo para un bias específico
int CSeasonal::GetOptimalMonthForBias(string symbol, ENUM_BIAS bias) const {
    int bestMonth = 1;
    double bestScore = -1;
    
    for(int month = 1; month <= 12; month++) {
        ENUM_BIAS monthBias = GetSeasonalBiasForMonth(symbol, month);
        if(monthBias == bias) {
            double score = GetStrengthScoreForMonth(symbol, month);
            if(score > bestScore) {
                bestScore = score;
                bestMonth = month;
            }
        }
    }
    
    return bestMonth;
}

//--- RF-650: Verificar divergencia
bool CSeasonal::IsDivergence(string symbol) const {
    return IsDivergenceWithPrice(symbol, SymbolInfoDouble(symbol, SYMBOL_BID));
}

//--- RF-650: Verificar divergencia con precio
bool CSeasonal::IsDivergenceWithPrice(string symbol, double price) const {
    ENUM_BIAS seasonalBias = GetSeasonalBias(symbol);
    if(seasonalBias == BIAS_NEUTRAL) return false;
    
    //--- Verificar si el precio se mueve contra la tendencia estacional
    double currentPrice = price;
    double price20 = iClose(symbol, PERIOD_D1, 20);
    double price40 = iClose(symbol, PERIOD_D1, 40);
    
    bool priceUp = currentPrice > price20;
    bool seasonalUp = seasonalBias == BIAS_BULLISH;
    
    return priceUp != seasonalUp;
}

//--- RF-650: Verificar divergencia con DXY
bool CSeasonal::IsDivergenceWithDXY(string symbol) const {
    ENUM_BIAS symbolBias = GetSeasonalBias(symbol);
    ENUM_BIAS dxyBias = GetSeasonalBias("DXY");
    
    if(symbolBias == BIAS_NEUTRAL || dxyBias == BIAS_NEUTRAL) return false;
    
    return symbolBias == dxyBias; // Ideal Seasonal es cuando son opuestos
}

//--- RF-651: Obtener score de fuerza estacional
double CSeasonal::GetStrengthScore(string symbol) const {
    return GetStrengthScoreForCurrentMonth(symbol);
}

//--- RF-651: Obtener score de fuerza para un mes específico
double CSeasonal::GetStrengthScoreForMonth(string symbol, int month) const {
    double ret = GetReturnForSymbol(symbol, month);
    double win = GetWinRateForSymbol(symbol, month);
    bool converged = IsConvergedForMonth(symbol, month);
    
    double score = 0.0;
    
    //--- Score basado en retorno
    if(ret > 1.0) score += 30;
    else if(ret > 0.5) score += 20;
    else if(ret > 0.0) score += 10;
    else if(ret < -1.0) score += 30;
    else if(ret < -0.5) score += 20;
    else if(ret < 0.0) score += 10;
    
    //--- Score basado en win rate
    score += (win - 50) * 2;
    
    //--- Score basado en convergencia
    if(converged) score += 20;
    
    //--- Score basado en ideal seasonal
    if(IsIdealSeasonal(symbol)) score += 10;
    
    if(score > 100) score = 100;
    if(score < 0) score = 0;
    
    return score;
}

//--- RF-651: Obtener score para el mes actual
double CSeasonal::GetStrengthScoreForCurrentMonth(string symbol) const {
    return GetStrengthScoreForMonth(symbol, m_currentMonth);
}

//--- RF-652: Obtener ranking de símbolos
void CSeasonal::GetRanking(string &symbols[], double &scores[]) {
    string allSymbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD"};
    ArrayResize(symbols, ArraySize(allSymbols));
    ArrayResize(scores, ArraySize(allSymbols));
    
    for(int i = 0; i < ArraySize(allSymbols); i++) {
        symbols[i] = allSymbols[i];
        scores[i] = GetStrengthScore(allSymbols[i]);
    }
}

//--- RF-652: Obtener mejor símbolo
string CSeasonal::GetBestSymbol() {
    string symbols[];
    double scores[];
    GetRanking(symbols, scores);
    
    int bestIdx = 0;
    for(int i = 1; i < ArraySize(scores); i++) {
        if(scores[i] > scores[bestIdx]) bestIdx = i;
    }
    
    return symbols[bestIdx];
}

//--- RF-652: Obtener mejor símbolo para un bias
string CSeasonal::GetBestSymbolForBias(ENUM_BIAS bias) {
    string symbols[];
    double scores[];
    GetRanking(symbols, scores);
    
    int bestIdx = -1;
    double bestScore = -1;
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        ENUM_BIAS symbolBias = GetSeasonalBias(symbols[i]);
        if(symbolBias == bias && scores[i] > bestScore) {
            bestScore = scores[i];
            bestIdx = i;
        }
    }
    
    if(bestIdx == -1) return "";
    return symbols[bestIdx];
}

//--- RF-653: Obtener win rate histórico
double CSeasonal::GetHistoricalWinRate(string symbol) const {
    return GetWinRateForSymbol(symbol, m_currentMonth);
}

//--- RF-653: Obtener retorno histórico
double CSeasonal::GetHistoricalReturn(string symbol) const {
    return GetReturnForSymbol(symbol, m_currentMonth);
}

//--- RF-653: Obtener tamaño de muestra
int CSeasonal::GetSampleSize(string symbol) const {
    return 40;
}

//--- RF-653: Obtener win rate para un mes específico
double CSeasonal::GetHistoricalWinRateForMonth(string symbol, int month) const {
    return GetWinRateForSymbol(symbol, month);
}

//--- RF-654: Verificar si hay excepción
bool CSeasonal::IsException(string symbol) const {
    return false; // Placeholder para detección de excepciones
}

//--- RF-654: Obtener razón de excepción
string CSeasonal::GetExceptionReason(string symbol) const {
    return "";
}

//--- RF-654: Verificar excepción para un mes
bool CSeasonal::IsExceptionForMonth(string symbol, int month) const {
    return false;
}

//--- RF-657: Obtener bias estacional de commodities
ENUM_BIAS CSeasonal::GetCommoditySeasonalBias(string symbol) const {
    if(symbol == "XAUUSD" || symbol == "GOLD" || symbol == "Gold") {
        return GetSeasonalBias("GOLD");
    }
    return BIAS_NEUTRAL;
}

//--- RF-657: Verificar validez de seasonal de commodities
bool CSeasonal::IsCommoditySeasonalValid(string symbol) const {
    return GetCommoditySeasonalBias(symbol) != BIAS_NEUTRAL;
}

//--- RF-658: Obtener bias estacional de bonos
ENUM_BIAS CSeasonal::GetBondSeasonalBias(string symbol) const {
    if(symbol == "BOND" || symbol == "30Y" || symbol == "Bonds") {
        return GetSeasonalBias("BOND");
    }
    return BIAS_NEUTRAL;
}

//--- RF-658: Verificar validez de seasonal de bonos
bool CSeasonal::IsBondSeasonalValid(string symbol) const {
    return GetBondSeasonalBias(symbol) != BIAS_NEUTRAL;
}

//--- RF-659: Obtener bias estacional de stocks
ENUM_BIAS CSeasonal::GetStockSeasonalBias(string symbol) const {
    if(symbol == "STOCK" || symbol == "DOW" || symbol == "Dow30") {
        return GetSeasonalBias("STOCK");
    }
    return BIAS_NEUTRAL;
}

//--- RF-659: Verificar validez de seasonal de stocks
bool CSeasonal::IsStockSeasonalValid(string symbol) const {
    return GetStockSeasonalBias(symbol) != BIAS_NEUTRAL;
}

//--- RF-660: Obtener bias estacional de divisas
ENUM_BIAS CSeasonal::GetCurrencySeasonalBias(string symbol) const {
    return GetSeasonalBias(symbol);
}

//--- RF-645: Obtener calendario estacional
string CSeasonal::GetSeasonalCalendar(int month) {
    string result = "=== CALENDARIO ESTACIONAL - MES " + IntegerToString(month) + " ===\n";
    result += "EURUSD: " + (GetSeasonalBiasForMonth("EURUSD", month) == BIAS_BULLISH ? "BULLISH" : 
                            (GetSeasonalBiasForMonth("EURUSD", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "GBPUSD: " + (GetSeasonalBiasForMonth("GBPUSD", month) == BIAS_BULLISH ? "BULLISH" : 
                            (GetSeasonalBiasForMonth("GBPUSD", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "USDJPY: " + (GetSeasonalBiasForMonth("USDJPY", month) == BIAS_BULLISH ? "BULLISH" : 
                            (GetSeasonalBiasForMonth("USDJPY", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "DXY: " + (GetSeasonalBiasForMonth("DXY", month) == BIAS_BULLISH ? "BULLISH" : 
                         (GetSeasonalBiasForMonth("DXY", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "GOLD: " + (GetSeasonalBiasForMonth("GOLD", month) == BIAS_BULLISH ? "BULLISH" : 
                          (GetSeasonalBiasForMonth("GOLD", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "BONDS: " + (GetSeasonalBiasForMonth("BOND", month) == BIAS_BULLISH ? "BULLISH" : 
                           (GetSeasonalBiasForMonth("BOND", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "STOCKS: " + (GetSeasonalBiasForMonth("STOCK", month) == BIAS_BULLISH ? "BULLISH" : 
                            (GetSeasonalBiasForMonth("STOCK", month) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    result += "=====================================";
    return result;
}

//--- RF-645: Obtener calendario del mes actual
string CSeasonal::GetCurrentMonthCalendar() {
    return GetSeasonalCalendar(m_currentMonth);
}

//--- RF-645: Obtener símbolos óptimos para un mes
string CSeasonal::GetOptimalSymbolsForMonth(int month) {
    string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "DXY", "GOLD", "BOND", "STOCK"};
    string result = "=== SÍMBOLOS ÓPTIMOS - MES " + IntegerToString(month) + " ===\n";
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        double score = GetStrengthScoreForMonth(symbols[i], month);
        result += symbols[i] + ": " + DoubleToString(score, 1) + "%\n";
    }
    
    return result;
}

//--- Verificar si un símbolo está en los datos
bool CSeasonal::HasData(string symbol) const {
    for(int i = 0; i < m_dataCount; i++) {
        if(m_seasonalData[i].symbol == symbol) return true;
    }
    return false;
}

//--- Verificar si hay datos para un mes específico
bool CSeasonal::HasDataForMonth(string symbol, int month) const {
    if(month < 1 || month > 12) return false;
    
    for(int i = 0; i < m_dataCount; i++) {
        if(m_seasonalData[i].symbol == symbol && m_seasonalData[i].month == month) {
            return true;
        }
    }
    return false;
}

//--- Verificar si DXY está en los datos
bool CSeasonal::IsDXYInData() {
    return HasData("DXY");
}

//--- Verificar si un commodity está en los datos
bool CSeasonal::IsCommodityInData(string symbol) {
    return HasData(symbol) || symbol == "GOLD" || symbol == "XAUUSD";
}

//--- Verificar si bonos están en los datos
bool CSeasonal::IsBondInData(string symbol) {
    return HasData(symbol) || symbol == "BOND" || symbol == "30Y";
}

//--- Verificar si stocks están en los datos
bool CSeasonal::IsStockInData(string symbol) {
    return HasData(symbol) || symbol == "STOCK" || symbol == "DOW";
}

//--- Reportes
string CSeasonal::GetSummary(string symbol) {
    string summary = "=== SEASONAL SUMMARY ===\n";
    summary += "Symbol: " + symbol + "\n";
    summary += "Current Month: " + IntegerToString(m_currentMonth) + "\n";
    summary += "Seasonal Bias: " + (GetSeasonalBias(symbol) == BIAS_BULLISH ? "BULLISH" : 
                                     (GetSeasonalBias(symbol) == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Strength Score: " + DoubleToString(GetStrengthScore(symbol), 1) + "%\n";
    summary += "Converged: " + (IsConverged(symbol) ? "YES" : "NO") + "\n";
    summary += "Ideal Seasonal: " + (IsIdealSeasonal(symbol) ? "YES" : "NO") + "\n";
    summary += "Historical Win Rate: " + DoubleToString(GetHistoricalWinRate(symbol), 1) + "%\n";
    summary += "Historical Return: " + DoubleToString(GetHistoricalReturn(symbol), 2) + "%\n";
    summary += "Optimal Month: " + IntegerToString(GetOptimalMonth(symbol)) + "\n";
    summary += "Valid: " + (IsSeasonalValid(symbol) ? "YES" : "NO") + "\n";
    summary += "=========================";
    return summary;
}

string CSeasonal::GetSeasonalReport(string symbol) {
    string report = "=== SEASONAL REPORT ===\n";
    report += "Symbol: " + symbol + "\n\n";
    
    for(int month = 1; month <= 12; month++) {
        double ret = GetReturnForSymbol(symbol, month);
        double win = GetWinRateForSymbol(symbol, month);
        ENUM_BIAS bias = GetSeasonalBiasForMonth(symbol, month);
        double strength = GetStrengthScoreForMonth(symbol, month);
        bool converged = IsConvergedForMonth(symbol, month);
        
        report += "Month " + IntegerToString(month) + ": ";
        report += "Bias: " + (bias == BIAS_BULLISH ? "BULL" : (bias == BIAS_BEARISH ? "BEAR" : "NEUT")) + " | ";
        report += "Return: " + DoubleToString(ret, 2) + "% | ";
        report += "Win: " + DoubleToString(win, 1) + "% | ";
        report += "Strength: " + DoubleToString(strength, 1) + "% | ";
        report += "Converged: " + (converged ? "YES" : "NO") + "\n";
    }
    
    report += "=========================";
    return report;
}

string CSeasonal::GetCalendarReport() {
    return GetCurrentMonthCalendar();
}

string CSeasonal::GetRankingReport() {
    string symbols[];
    double scores[];
    GetRanking(symbols, scores);
    
    string report = "=== SEASONAL RANKING ===\n";
    for(int i = 0; i < ArraySize(symbols); i++) {
        report += IntegerToString(i + 1) + ". " + symbols[i] + ": " + DoubleToString(scores[i], 1) + "%\n";
    }
    report += "=========================";
    return report;
}

#endif // __CSEASONAL_MQH__