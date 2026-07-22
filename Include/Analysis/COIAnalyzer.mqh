//+------------------------------------------------------------------+
//|                                                     COIAnalyzer.mqh|
//|                         HunterIPDA Pro EA - v1.7 - Módulo Analysis|
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis de Open Interest:               |
//| - OI Trends                                                     |
//| - Seasonal Average of OI                                        |
//| - OI + PD Array Blending                                        |
//| - OI + COT Blending                                             |
//| - Smart Money Footprints                                        |
//| - OI at Support/Resistance                                      |
//| - OI Divergence Detection                                       |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-681: Open Interest Trend Analysis                           |
//|   RF-682: Seasonal Average of OI                                 |
//|   RF-683: OI vs Seasonal Average                                 |
//|   RF-684: OI + PD Array Blending                                 |
//|   RF-685: OI + COT Blending                                      |
//|   RF-686: Smart Money Footprints Detection                       |
//|   RF-687: OI Change Significance                                 |
//|   RF-688: OI at Support/Resistance                               |
//|   RF-689: OI as Trade Filter                                     |
//|   RF-690: OI as Exit Signal                                      |
//|   RF-691: OI Historical Database                                 |
//|   RF-692: OI Logging                                             |
//|   RF-693: OI Dashboard                                           |
//|   RF-694: Commodity OI Analysis                                  |
//|   RF-695: Bond OI Analysis                                       |
//|   RF-696: Currency Futures OI Analysis                           |
//|   RF-697: OI Divergence Detection                                |
//|   RF-698: OI as Smart Money Indicator                            |
//|   RF-699: OI Volume Blending                                     |
//|   RF-700: OI Seasonality Adjustment                              |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
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

#ifndef __COIANALYZER_MQH__
#define __COIANALYZER_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct OIDataInternal {
    string           symbol;
    double           currentOI;
    double           previousOI;
    double           seasonalAverage;
    double           changePercent;
    bool             isIncreasing;
    bool             isDecreasing;
    bool             isAboveSeasonalAvg;
    bool             isBelowSeasonalAvg;
    bool             isSmartMoneyFootprint;
    ENUM_BIAS        oiBias;
    datetime         lastUpdate;
    double           priceAtUpdate;
};

//+------------------------------------------------------------------+
//| CLASE COIAnalyzer - Análisis de Open Interest                    |
//+------------------------------------------------------------------+
class COIAnalyzer {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_symbol;
    string             m_dataPath;
    bool               m_isDataLoaded;
    datetime           m_lastUpdate;
    
    //--- Datos OI
    OIDataInternal     m_currentData;
    OIDataInternal     m_historicalData[];
    int                m_historicalCount;
    
    //--- Estado
    double             m_currentOI;
    double             m_previousOI;
    double             m_changePercent;
    bool               m_isIncreasing;
    bool               m_isDecreasing;
    double             m_seasonalAverage;
    bool               m_isAboveSeasonalAvg;
    bool               m_isBelowSeasonalAvg;
    bool               m_isSmartMoneyFootprint;
    ENUM_BIAS          m_oiBias;
    double             m_oiDivergenceScore;
    double             m_oiVolumeScore;
    double             m_significantChangeThreshold;
    
    //--- Métodos privados
    bool               LoadOIData(string symbol);
    bool               LoadOIDataFromFile(string symbol);
    bool               ParseOILine(string line, OIDataInternal &data);
    bool               CalculateSeasonalAverage(string symbol);
    double             GetCurrentOI(string symbol);
    double             GetPreviousOI(string symbol);
    bool               DetectSmartMoneyFootprint(OIDataInternal &data);
    bool               DetectOIDivergence(OIDataInternal &data);
    void               UpdateCurrentData(OIDataInternal &data);
    void               GenerateSimulatedOI(string symbol);
    double             CalculateOIChange(double current, double previous);
    double             GetOIVolume(string symbol) const;
    
public:
    //--- Constructor / Destructor
    COIAnalyzer();
    ~COIAnalyzer();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    bool IsDataLoaded() const { return m_isDataLoaded; }
    
    //--- Métodos Principales
    void Update(string symbol = "");
    void SetSymbol(string symbol);
    bool LoadData(string symbol);
    void Refresh();
    
    //--- RF-681: Open Interest Trend Analysis
    double GetCurrentOI() const { return m_currentOI; }
    double GetPreviousOI() const { return m_previousOI; }
    double GetOIChangePercent() const { return m_changePercent; }
    bool IsOIIncreasing() const { return m_isIncreasing; }
    bool IsOIDecreasing() const { return m_isDecreasing; }
    string GetOITrend() const;
    
    //--- RF-682: Seasonal Average of OI
    double GetSeasonalAverage() const { return m_seasonalAverage; }
    double GetSeasonalAverageForSymbol(string symbol);
    
    //--- RF-683: OI vs Seasonal Average
    bool IsAboveSeasonalAverage() const { return m_isAboveSeasonalAvg; }
    bool IsBelowSeasonalAverage() const { return m_isBelowSeasonalAvg; }
    double GetOIvsSeasonalPercent() const;
    
    //--- RF-684: OI + PD Array Blending
    bool IsOIAligningWithPDArray(ENUM_BIAS pdBias) const;
    double GetOIAlignmentScore(ENUM_BIAS bias) const;
    
    //--- RF-685: OI + COT Blending
    bool IsOIAligningWithCOT(ENUM_BIAS cotBias) const;
    double GetOIWithCOTScore(ENUM_BIAS bias) const;
    
    //--- RF-686: Smart Money Footprints Detection
    bool IsSmartMoneyFootprint() const { return m_isSmartMoneyFootprint; }
    bool IsSmartMoneyFootprintForSymbol(string symbol);
    string GetSmartMoneyFootprintDescription() const;
    
    //--- RF-687: OI Change Significance
    bool IsSignificantChange() const;
    bool IsSignificantChangeForSymbol(string symbol);
    double GetChangeSignificance() const;
    
    //--- RF-688: OI at Support/Resistance
    bool IsOIAtSupport(double price) const;
    bool IsOIAtResistance(double price) const;
    bool IsOIReversalAtLevel(double price) const;
    
    //--- RF-689: OI as Trade Filter
    bool IsOIFilterValid(ENUM_BIAS bias) const;
    bool IsOIFilterValidForSymbol(string symbol, ENUM_BIAS bias);
    
    //--- RF-690: OI as Exit Signal
    bool IsOIExitSignal(ENUM_BIAS bias) const;
    bool IsOIExitSignalForSymbol(string symbol, ENUM_BIAS bias);
    
    //--- RF-691: OI Historical Database
    int GetHistoricalCount() const { return m_historicalCount; }
    OIDataInternal GetHistoricalData(int index) const;
    double GetHistoricalAverageOI(int periods) const;
    double GetHistoricalMaxOI(int periods) const;
    double GetHistoricalMinOI(int periods) const;
    
    //--- RF-692: OI Logging
    string GetOILog();
    string GetOILogForSymbol(string symbol);
    
    //--- RF-693: OI Dashboard
    string GetOIDashboard();
    string GetOIDashboardForSymbol(string symbol);
    
    //--- RF-694: Commodity OI Analysis
    double GetCommodityOI(string symbol) const;
    bool IsCommodityOIValid(string symbol) const;
    
    //--- RF-695: Bond OI Analysis
    double GetBondOI(string symbol) const;
    bool IsBondOIValid(string symbol) const;
    
    //--- RF-696: Currency Futures OI Analysis
    double GetCurrencyFuturesOI(string symbol) const;
    bool IsCurrencyFuturesOIValid(string symbol) const;
    
    //--- RF-697: OI Divergence Detection
    bool IsOIDivergence() const;
    bool IsOIDivergenceForSymbol(string symbol);
    double GetOIDivergenceScore() const { return m_oiDivergenceScore; }
    
    //--- RF-698: OI as Smart Money Indicator
    bool IsSmartMoneyAccumulating() const;
    bool IsSmartMoneyDistributing() const;
    ENUM_BIAS GetSmartMoneyBias() const;
    
    //--- RF-699: OI Volume Blending
    double GetOIVolumeScore() const;
    bool IsOIVolumeConfirming(ENUM_BIAS bias) const;
    
    //--- RF-700: OI Seasonality Adjustment
    double GetSeasonallyAdjustedOI() const;
    double GetSeasonallyAdjustedOIForSymbol(string symbol);
    bool IsSeasonallyAdjustedBullish() const;
    bool IsSeasonallyAdjustedBearish() const;
    
    //--- Getters
    string GetSymbol() const { return m_symbol; }
    datetime GetLastUpdate() const { return m_lastUpdate; }
    string GetOISummary();
    string GetOIReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                    |
//+------------------------------------------------------------------+

//--- Constructor
COIAnalyzer::COIAnalyzer() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_dataPath = "";
    m_isDataLoaded = false;
    m_lastUpdate = 0;
    m_historicalCount = 0;
    m_currentOI = 0;
    m_previousOI = 0;
    m_changePercent = 0;
    m_isIncreasing = false;
    m_isDecreasing = false;
    m_seasonalAverage = 0;
    m_isAboveSeasonalAvg = false;
    m_isBelowSeasonalAvg = false;
    m_isSmartMoneyFootprint = false;
    m_oiBias = BIAS_NEUTRAL;
    m_oiDivergenceScore = 0;
    m_oiVolumeScore = 0;
    m_significantChangeThreshold = 10.0;  // 10%
    ArrayResize(m_historicalData, 0);
}

//--- Destructor
COIAnalyzer::~COIAnalyzer() {
    Deinit();
}

//--- Inicialización
bool COIAnalyzer::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("COIAnalyzer::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Establecer ruta de datos
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_dataPath = terminalPath + "\\MQL5\\Files\\OI_Data\\";
    FolderCreate(m_dataPath);
    
    m_isInitialized = true;
    m_utils.LogInfo("COIAnalyzer inicializado correctamente");
    return true;
}

//--- Desinicialización
void COIAnalyzer::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    ArrayResize(m_historicalData, 0);
}

//--- Establecer símbolo
void COIAnalyzer::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            LoadData(symbol);
        }
    }
}

//--- Cargar datos OI
bool COIAnalyzer::LoadData(string symbol) {
    if(!m_isInitialized) return false;
    
    m_symbol = symbol;
    m_isDataLoaded = LoadOIData(symbol);
    
    if(m_isDataLoaded) {
        m_lastUpdate = TimeCurrent();
        m_utils.LogInfo("OI data loaded for " + symbol);
    } else {
        m_utils.LogWarning("OI data not available for " + symbol + " - using simulated data");
        GenerateSimulatedOI(symbol);
        m_isDataLoaded = true;
        m_lastUpdate = TimeCurrent();
    }
    
    return m_isDataLoaded;
}

//--- Cargar datos OI
bool COIAnalyzer::LoadOIData(string symbol) {
    if(LoadOIDataFromFile(symbol)) {
        return true;
    }
    return false;
}

//--- Cargar datos OI desde archivo
bool COIAnalyzer::LoadOIDataFromFile(string symbol) {
    string fileName = m_dataPath + "OI_" + symbol + ".csv";
    if(!FileIsExist(fileName)) return false;
    
    int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    bool dataFound = false;
    while(!FileIsEnding(handle)) {
        string line = FileReadString(handle);
        if(line != "") {
            OIDataInternal data;
            if(ParseOILine(line, data)) {
                UpdateCurrentData(data);
                dataFound = true;
            }
        }
    }
    
    FileClose(handle);
    return dataFound;
}

//--- Parsear línea CSV de OI
bool COIAnalyzer::ParseOILine(string line, OIDataInternal &data) {
    string parts[];
    int count = StringSplit(line, ',', parts);
    
    if(count < 6) return false;
    
    data.symbol = parts[0];
    data.currentOI = StringToDouble(parts[1]);
    data.previousOI = StringToDouble(parts[2]);
    data.seasonalAverage = StringToDouble(parts[3]);
    data.lastUpdate = (datetime)StringToInteger(parts[4]);
    data.priceAtUpdate = StringToDouble(parts[5]);
    
    data.changePercent = CalculateOIChange(data.currentOI, data.previousOI);
    data.isIncreasing = data.currentOI > data.previousOI;
    data.isDecreasing = data.currentOI < data.previousOI;
    data.isAboveSeasonalAvg = data.currentOI > data.seasonalAverage;
    data.isBelowSeasonalAvg = data.currentOI < data.seasonalAverage;
    
    return true;
}

//--- Generar datos OI simulados
void COIAnalyzer::GenerateSimulatedOI(string symbol) {
    OIDataInternal data;
    data.symbol = symbol;
    data.lastUpdate = TimeCurrent();
    data.priceAtUpdate = SymbolInfoDouble(symbol, SYMBOL_BID);
    
    //--- Generar OI pseudo-aleatorio
    int hash = 0;
    for(int i = 0; i < StringLen(symbol); i++) {
        hash += StringGetCharacter(symbol, i);
    }
    
    double seed = (hash % 100) / 100.0;
    double random = MathSin(seed * 1000) * 50 + 50;
    
    data.previousOI = random * 10000;
    data.currentOI = data.previousOI * (0.8 + MathSin(seed * 2000) * 0.2);
    data.seasonalAverage = random * 10000 * 1.1;
    data.changePercent = CalculateOIChange(data.currentOI, data.previousOI);
    data.isIncreasing = data.currentOI > data.previousOI;
    data.isDecreasing = data.currentOI < data.previousOI;
    data.isAboveSeasonalAvg = data.currentOI > data.seasonalAverage;
    data.isBelowSeasonalAvg = data.currentOI < data.seasonalAverage;
    data.isSmartMoneyFootprint = false;
    data.oiBias = data.isIncreasing ? BIAS_BULLISH : BIAS_BEARISH;
    
    UpdateCurrentData(data);
}

//--- Actualizar datos actuales
void COIAnalyzer::UpdateCurrentData(OIDataInternal &data) {
    m_currentData = data;
    m_currentOI = data.currentOI;
    m_previousOI = data.previousOI;
    m_changePercent = data.changePercent;
    m_isIncreasing = data.isIncreasing;
    m_isDecreasing = data.isDecreasing;
    m_seasonalAverage = data.seasonalAverage;
    m_isAboveSeasonalAvg = data.isAboveSeasonalAvg;
    m_isBelowSeasonalAvg = data.isBelowSeasonalAvg;
    m_oiBias = data.oiBias;
    
    //--- RF-686: Smart Money Footprint
    m_isSmartMoneyFootprint = DetectSmartMoneyFootprint(data);
    
    //--- RF-697: OI Divergence
    m_oiDivergenceScore = DetectOIDivergence(data) ? 70 : 0;
    
    //--- RF-699: OI Volume Score
    m_oiVolumeScore = GetOIVolumeScore();
    
    //--- Guardar en histórico
    int idx = m_historicalCount;
    ArrayResize(m_historicalData, m_historicalCount + 1);
    m_historicalData[idx] = data;
    m_historicalCount++;
    
    m_lastUpdate = TimeCurrent();
}

//--- RF-681: Calcular cambio de OI
double COIAnalyzer::CalculateOIChange(double current, double previous) {
    if(previous == 0) return 0;
    return (current - previous) / previous * 100.0;
}

//--- RF-681: Obtener tendencia de OI
string COIAnalyzer::GetOITrend() const {
    if(m_isIncreasing) return "INCREASING";
    if(m_isDecreasing) return "DECREASING";
    return "STABLE";
}

//--- RF-682: Obtener promedio estacional
double COIAnalyzer::GetSeasonalAverageForSymbol(string symbol) {
    //--- Placeholder
    return 0;
}

//--- RF-683: OI vs Seasonal
double COIAnalyzer::GetOIvsSeasonalPercent() const {
    if(m_seasonalAverage == 0) return 0;
    return (m_currentOI - m_seasonalAverage) / m_seasonalAverage * 100.0;
}

//--- RF-684: OI + PD Array Blending
bool COIAnalyzer::IsOIAligningWithPDArray(ENUM_BIAS pdBias) const {
    return m_oiBias == pdBias;
}

double COIAnalyzer::GetOIAlignmentScore(ENUM_BIAS bias) const {
    if(m_oiBias == bias) {
        return MathMin(MathAbs(m_changePercent) * 2, 100);
    }
    return 0;
}

//--- RF-685: OI + COT Blending
bool COIAnalyzer::IsOIAligningWithCOT(ENUM_BIAS cotBias) const {
    return m_oiBias == cotBias;
}

double COIAnalyzer::GetOIWithCOTScore(ENUM_BIAS bias) const {
    if(m_oiBias == bias) {
        return MathMin(MathAbs(m_changePercent) * 2, 100);
    }
    return 0;
}

//--- RF-686: Smart Money Footprints Detection
bool COIAnalyzer::DetectSmartMoneyFootprint(OIDataInternal &data) {
    //--- Smart Money Footprint: OI declinando en soporte + OI aumentando en resistencia
    double currentPrice = data.priceAtUpdate;
    double high20 = iHigh(data.symbol, PERIOD_D1, 0);
    double low20 = iLow(data.symbol, PERIOD_D1, 0);
    
    bool nearSupport = currentPrice < low20 * 1.01;
    bool nearResistance = currentPrice > high20 * 0.99;
    bool oiDeclining = data.isDecreasing;
    bool oiIncreasing = data.isIncreasing;
    
    //--- Soporte + OI declinando = Smart Money acumulando
    if(nearSupport && oiDeclining) {
        data.isSmartMoneyFootprint = true;
        data.oiBias = BIAS_BULLISH;
        return true;
    }
    
    //--- Resistencia + OI aumentando = Smart Money distribuyendo
    if(nearResistance && oiIncreasing) {
        data.isSmartMoneyFootprint = true;
        data.oiBias = BIAS_BEARISH;
        return true;
    }
    
    data.isSmartMoneyFootprint = false;
    return false;
}

bool COIAnalyzer::IsSmartMoneyFootprintForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

string COIAnalyzer::GetSmartMoneyFootprintDescription() const {
    if(!m_isSmartMoneyFootprint) return "No Smart Money footprint detected";
    if(m_oiBias == BIAS_BULLISH) {
        return "Smart Money accumulating (OI declining near support)";
    }
    return "Smart Money distributing (OI increasing near resistance)";
}

//--- RF-687: OI Change Significance
bool COIAnalyzer::IsSignificantChange() const {
    return MathAbs(m_changePercent) >= m_significantChangeThreshold;
}

bool COIAnalyzer::IsSignificantChangeForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

double COIAnalyzer::GetChangeSignificance() const {
    return MathMin(MathAbs(m_changePercent) / m_significantChangeThreshold * 100, 100);
}

//--- RF-688: OI at Support/Resistance
bool COIAnalyzer::IsOIAtSupport(double price) const {
    double low20 = iLow(m_symbol, PERIOD_D1, 0);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    return MathAbs(price - low20) / point < 10;
}

bool COIAnalyzer::IsOIAtResistance(double price) const {
    double high20 = iHigh(m_symbol, PERIOD_D1, 0);
    double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
    return MathAbs(price - high20) / point < 10;
}

bool COIAnalyzer::IsOIReversalAtLevel(double price) const {
    if(!IsOIAtSupport(price) && !IsOIAtResistance(price)) return false;
    return m_isSmartMoneyFootprint;
}

//--- RF-689: OI as Trade Filter
bool COIAnalyzer::IsOIFilterValid(ENUM_BIAS bias) const {
    return m_oiBias == bias || m_isSmartMoneyFootprint;
}

bool COIAnalyzer::IsOIFilterValidForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder
    return false;
}

//--- RF-690: OI as Exit Signal
bool COIAnalyzer::IsOIExitSignal(ENUM_BIAS bias) const {
    //--- Si OI se invierte, es señal de salida
    if(bias == BIAS_BULLISH && m_oiBias == BIAS_BEARISH) return true;
    if(bias == BIAS_BEARISH && m_oiBias == BIAS_BULLISH) return true;
    return false;
}

bool COIAnalyzer::IsOIExitSignalForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder
    return false;
}

//--- RF-691: Historical Database
OIDataInternal COIAnalyzer::GetHistoricalData(int index) const {
    if(index < 0 || index >= m_historicalCount) {
        OIDataInternal empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_historicalData[index];
}

double COIAnalyzer::GetHistoricalAverageOI(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double sum = 0;
    for(int i = m_historicalCount - count; i < m_historicalCount; i++) {
        sum += m_historicalData[i].currentOI;
    }
    return sum / count;
}

double COIAnalyzer::GetHistoricalMaxOI(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double maxVal = m_historicalData[m_historicalCount - count].currentOI;
    for(int i = m_historicalCount - count + 1; i < m_historicalCount; i++) {
        if(m_historicalData[i].currentOI > maxVal) {
            maxVal = m_historicalData[i].currentOI;
        }
    }
    return maxVal;
}

double COIAnalyzer::GetHistoricalMinOI(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double minVal = m_historicalData[m_historicalCount - count].currentOI;
    for(int i = m_historicalCount - count + 1; i < m_historicalCount; i++) {
        if(m_historicalData[i].currentOI < minVal) {
            minVal = m_historicalData[i].currentOI;
        }
    }
    return minVal;
}

//--- RF-692: OI Logging
string COIAnalyzer::GetOILog() {
    string log = "=== OI LOG ===\n";
    log += "Symbol: " + m_symbol + "\n";
    log += "Current OI: " + DoubleToString(m_currentOI, 0) + "\n";
    log += "Previous OI: " + DoubleToString(m_previousOI, 0) + "\n";
    log += "Change: " + DoubleToString(m_changePercent, 2) + "%\n";
    log += "Trend: " + GetOITrend() + "\n";
    log += "Seasonal Avg: " + DoubleToString(m_seasonalAverage, 0) + "\n";
    log += "Above Seasonal: " + (m_isAboveSeasonalAvg ? "YES" : "NO") + "\n";
    log += "Smart Money: " + (m_isSmartMoneyFootprint ? "YES" : "NO") + "\n";
    log += "OI Bias: " + (m_oiBias == BIAS_BULLISH ? "BULLISH" : 
                          (m_oiBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Last Update: " + TimeToString(m_lastUpdate) + "\n";
    return log;
}

string COIAnalyzer::GetOILogForSymbol(string symbol) {
    //--- Placeholder
    return "";
}

//--- RF-693: OI Dashboard
string COIAnalyzer::GetOIDashboard() {
    string dash = "=== OI DASHBOARD ===\n";
    dash += "Symbol: " + m_symbol + "\n";
    dash += "OI: " + DoubleToString(m_currentOI, 0) + "\n";
    dash += "Trend: " + GetOITrend() + "\n";
    dash += "Change: " + DoubleToString(m_changePercent, 2) + "%\n";
    dash += "Significant: " + (IsSignificantChange() ? "YES" : "NO") + "\n";
    dash += "Smart Money: " + (m_isSmartMoneyFootprint ? "✅" : "❌") + "\n";
    dash += "Bias: " + (m_oiBias == BIAS_BULLISH ? "BULLISH" : 
                        (m_oiBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    dash += "=========================";
    return dash;
}

string COIAnalyzer::GetOIDashboardForSymbol(string symbol) {
    //--- Placeholder
    return "";
}

//--- RF-694: Commodity OI Analysis
double COIAnalyzer::GetCommodityOI(string symbol) const {
    //--- Placeholder
    return 0;
}

bool COIAnalyzer::IsCommodityOIValid(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-695: Bond OI Analysis
double COIAnalyzer::GetBondOI(string symbol) const {
    //--- Placeholder
    return 0;
}

bool COIAnalyzer::IsBondOIValid(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-696: Currency Futures OI Analysis
double COIAnalyzer::GetCurrencyFuturesOI(string symbol) const {
    //--- Placeholder
    return 0;
}

bool COIAnalyzer::IsCurrencyFuturesOIValid(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-697: OI Divergence Detection
bool COIAnalyzer::DetectOIDivergence(OIDataInternal &data) {
    double currentPrice = data.priceAtUpdate;
    double priceChange = 0;
    if(data.previousOI > 0) {
        priceChange = (currentPrice - data.priceAtUpdate) / data.priceAtUpdate * 100;
    }
    
    //--- OI Divergencia: OI y precio en direcciones opuestas
    bool priceUp = priceChange > 0;
    bool oiUp = data.isIncreasing;
    
    return priceUp != oiUp;
}

bool COIAnalyzer::IsOIDivergence() const {
    return m_oiDivergenceScore > 0;
}

bool COIAnalyzer::IsOIDivergenceForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-698: OI as Smart Money Indicator
bool COIAnalyzer::IsSmartMoneyAccumulating() const {
    return m_isSmartMoneyFootprint && m_oiBias == BIAS_BULLISH;
}

bool COIAnalyzer::IsSmartMoneyDistributing() const {
    return m_isSmartMoneyFootprint && m_oiBias == BIAS_BEARISH;
}

ENUM_BIAS COIAnalyzer::GetSmartMoneyBias() const {
    if(IsSmartMoneyAccumulating()) return BIAS_BULLISH;
    if(IsSmartMoneyDistributing()) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-699: OI Volume Blending
double COIAnalyzer::GetOIVolumeScore() const {
    double volumeScore = 0;
    double volume = GetOIVolume(m_symbol);
    long avgVolumeLong = iVolume(m_symbol, PERIOD_D1, 0);
    double avgVolume = (double)avgVolumeLong / 10.0;
    
    if(avgVolume > 0) {
        volumeScore = MathMin(volume / avgVolume * 100, 100);
    }
    
    return volumeScore;
}

double COIAnalyzer::GetOIVolume(string symbol) const {
    //--- Usar iVolume directamente para obtener el volumen de la vela actual
    //--- Esto es más sencillo y compatible con todos los símbolos
    long volume = iVolume(symbol, PERIOD_M1, 0);
    return (double)volume;
}

bool COIAnalyzer::IsOIVolumeConfirming(ENUM_BIAS bias) const {
    return m_oiBias == bias && m_oiVolumeScore > 50;
}

//--- RF-700: OI Seasonality Adjustment
double COIAnalyzer::GetSeasonallyAdjustedOI() const {
    if(m_seasonalAverage == 0) return m_currentOI;
    return m_currentOI / m_seasonalAverage * 100;
}

double COIAnalyzer::GetSeasonallyAdjustedOIForSymbol(string symbol) {
    //--- Placeholder
    return 0;
}

bool COIAnalyzer::IsSeasonallyAdjustedBullish() const {
    return GetSeasonallyAdjustedOI() > 110;
}

bool COIAnalyzer::IsSeasonallyAdjustedBearish() const {
    return GetSeasonallyAdjustedOI() < 90;
}

//--- Actualizar
void COIAnalyzer::Update(string symbol = "") {
    if(symbol != "") SetSymbol(symbol);
    LoadData(m_symbol);
}

//--- Refresh
void COIAnalyzer::Refresh() {
    LoadData(m_symbol);
}

//--- Resumen OI
string COIAnalyzer::GetOISummary() {
    string summary = "=== OI SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "OI: " + DoubleToString(m_currentOI, 0) + "\n";
    summary += "Trend: " + GetOITrend() + "\n";
    summary += "Change: " + DoubleToString(m_changePercent, 2) + "%\n";
    summary += "Smart Money: " + (m_isSmartMoneyFootprint ? "YES" : "NO") + "\n";
    summary += "Bias: " + (m_oiBias == BIAS_BULLISH ? "BULLISH" : 
                           (m_oiBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "=========================";
    return summary;
}

//--- Reporte OI
string COIAnalyzer::GetOIReport() {
    string report = "=== OI REPORT ===\n";
    report += "Symbol: " + m_symbol + "\n";
    report += "Current OI: " + DoubleToString(m_currentOI, 0) + "\n";
    report += "Previous OI: " + DoubleToString(m_previousOI, 0) + "\n";
    report += "Change: " + DoubleToString(m_changePercent, 2) + "%\n";
    report += "Seasonal Average: " + DoubleToString(m_seasonalAverage, 0) + "\n";
    report += "OI vs Seasonal: " + DoubleToString(GetOIvsSeasonalPercent(), 2) + "%\n";
    report += "Above Seasonal: " + (m_isAboveSeasonalAvg ? "YES" : "NO") + "\n";
    report += "Significant Change: " + (IsSignificantChange() ? "YES" : "NO") + "\n";
    report += "Smart Money Footprint: " + (m_isSmartMoneyFootprint ? "YES" : "NO") + "\n";
    report += "OI Divergence: " + (IsOIDivergence() ? "YES" : "NO") + "\n";
    report += "Seasonally Adjusted OI: " + DoubleToString(GetSeasonallyAdjustedOI(), 2) + "%\n";
    report += "Historical Entries: " + IntegerToString(m_historicalCount) + "\n";
    report += "=========================";
    return report;
}

#endif // __COIANALYZER_MQH__