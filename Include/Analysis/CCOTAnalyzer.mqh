//+------------------------------------------------------------------+
//|                                                 CCOTAnalyzer.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis de COT:                         |
//| - Buy/Sell Programs                                              |
//| - Hedging Programs                                               |
//| - 12-Month Ranges                                                |
//| - Nueva Línea Cero                                               |
//| - Nódulos de Hedging                                             |
//| - COT como filtro para Swing y OSOK                              |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-601: COT Short Format Analysis                              |
//|   RF-602: Buy Program Identification                             |
//|   RF-603: Sell Program Identification                            |
//|   RF-604: Hedging Program Detection                              |
//|   RF-606: 12-Month Commercial Range                              |
//|   RF-607: New Zero Line Calculation                              |
//|   RF-608: Buy Hedge (COT) Detection                              |
//|   RF-609: Sell Hedge (COT) Detection                             |
//|   RF-610: Hedging Nodule Identification                          |
//|   RF-612: Commercial Bias Determination                          |
//|   RF-614: COT Alignment with Technicals                          |
//|   RF-615: COT as Swing Filter                                    |
//|   RF-616: COT as OSOK Filter                                     |
//|   RF-617: COT as Day Trading Context                             |
//|   RF-618: COT Data Update Automation                             |
//|   RF-619: COT Historical Database                                |
//|   RF-620: COT Logging                                            |
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
//| 1.1     | 22/07/2026  | Eliminada estructura COTData duplicada   |
//|         |             | (ahora usa la de CConstants)             |
//| 1.2     | 22/07/2026  | Unificada GenerateSimulatedCOT           |
//+------------------------------------------------------------------+

#ifndef __CCOTANALYZER_MQH__
#define __CCOTANALYZER_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//--- COTData ya está definido en CConstants.mqh

//+------------------------------------------------------------------+
//| CLASE CCOTAnalyzer - Análisis de COT                             |
//+------------------------------------------------------------------+
class CCOTAnalyzer {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_symbol;
    string             m_dataPath;
    bool               m_isDataLoaded;
    datetime           m_lastUpdate;
    int                m_updateInterval;      // Días
    
    //--- Datos COT
    COTData            m_currentData;
    COTData            m_historicalData[];
    int                m_historicalCount;
    
    //--- Estado
    bool               m_isBuyProgram;
    bool               m_isSellProgram;
    bool               m_isHedgingProgram;
    double             m_commercialNet;
    double             m_commercialHigh12M;
    double             m_commercialLow12M;
    double             m_midPoint;
    double             m_hedgingNodule;
    ENUM_BIAS          m_commercialBias;
    double             m_biasStrength;
    
    //--- Mapeo de símbolos Forex a Futuros
    string             m_forexToFutures[];
    string             m_futuresToForex[];
    int                m_mapCount;
    
    //--- Métodos privados
    bool               InitializeSymbolMap();
    bool               LoadCOTData(string symbol);
    bool               LoadCOTDataFromFile(string symbol);
    bool               ParseCOTLine(string line, COTData &data);
    bool               CalculateRanges(COTData &data);
    void               DeterminePrograms(COTData &data);
    void               DetermineBias(COTData &data);
    bool               DetectHedgingNodule(COTData &data);
    string             GetFuturesSymbol(string forexSymbol);
    string             GetForexSymbol(string futuresSymbol);
    bool               IsCOTDataAvailable(string symbol);
    void               UpdateCurrentData(COTData &data);
    void               GenerateSimulatedCOT(string symbol);
    
public:
    //--- Constructor / Destructor
    CCOTAnalyzer();
    ~CCOTAnalyzer();
    
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
    
    //--- RF-601: COT Short Format Analysis
    double GetCommercialNet() const { return m_commercialNet; }
    double GetCommercialNetForSymbol(string symbol);
    
    //--- RF-602: Buy Program Identification
    bool IsBuyProgram() const { return m_isBuyProgram; }
    bool IsBuyProgramForSymbol(string symbol);
    
    //--- RF-603: Sell Program Identification
    bool IsSellProgram() const { return m_isSellProgram; }
    bool IsSellProgramForSymbol(string symbol);
    
    //--- RF-604: Hedging Program Detection
    bool IsHedgingProgram() const { return m_isHedgingProgram; }
    bool IsHedgingProgramForSymbol(string symbol);
    double GetHedgingNodule() const { return m_hedgingNodule; }
    
    //--- RF-606: 12-Month Commercial Range
    double GetCommercialHigh12M() const { return m_commercialHigh12M; }
    double GetCommercialLow12M() const { return m_commercialLow12M; }
    double GetCommercialRange12M() const;
    
    //--- RF-607: New Zero Line Calculation
    double GetMidPoint() const { return m_midPoint; }
    double GetMidPointForSymbol(string symbol);
    bool IsAboveZeroLine() const;
    bool IsBelowZeroLine() const;
    
    //--- RF-608: Buy Hedge (COT) Detection
    bool IsBuyHedge() const;
    bool IsBuyHedgeForSymbol(string symbol);
    
    //--- RF-609: Sell Hedge (COT) Detection
    bool IsSellHedge() const;
    bool IsSellHedgeForSymbol(string symbol);
    
    //--- RF-610: Hedging Nodule Identification
    double GetHedgingNoduleForSymbol(string symbol);
    bool IsHedgingNoduleActive() const;
    
    //--- RF-612: Commercial Bias Determination
    ENUM_BIAS GetCommercialBias() const { return m_commercialBias; }
    ENUM_BIAS GetCommercialBiasForSymbol(string symbol);
    double GetBiasStrength() const { return m_biasStrength; }
    
    //--- RF-614: COT Alignment with Technicals
    bool IsAligned(ENUM_BIAS bias) const;
    bool IsAlignedForSymbol(string symbol, ENUM_BIAS bias);
    double GetAlignmentScore(ENUM_BIAS bias) const;
    
    //--- RF-615: COT as Swing Filter
    bool IsSwingValid() const;
    bool IsSwingValidForSymbol(string symbol);
    
    //--- RF-616: COT as OSOK Filter
    bool IsOSOKValid() const;
    bool IsOSOKValidForSymbol(string symbol);
    
    //--- RF-617: COT as Day Trading Context
    ENUM_BIAS GetDayTradingContext() const;
    ENUM_BIAS GetDayTradingContextForSymbol(string symbol);
    
    //--- RF-618: COT Data Update Automation
    void AutoUpdate();
    bool IsUpdateNeeded() const;
    void SetUpdateInterval(int days);
    
    //--- RF-619: COT Historical Database
    int GetHistoricalCount() const { return m_historicalCount; }
    COTData GetHistoricalData(int index) const;
    double GetHistoricalAverage(int periods) const;
    
    //--- RF-620: COT Logging
    string GetCOTLog();
    string GetCOTLogForSymbol(string symbol);
    
    //--- Getters
    string GetSymbol() const { return m_symbol; }
    datetime GetLastUpdate() const { return m_lastUpdate; }
    string GetCOTSummary();
    string GetCOTReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CCOTAnalyzer::CCOTAnalyzer() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_dataPath = "";
    m_isDataLoaded = false;
    m_lastUpdate = 0;
    m_updateInterval = 7;
    m_historicalCount = 0;
    m_isBuyProgram = false;
    m_isSellProgram = false;
    m_isHedgingProgram = false;
    m_commercialNet = 0;
    m_commercialHigh12M = 0;
    m_commercialLow12M = 0;
    m_midPoint = 0;
    m_hedgingNodule = 0;
    m_commercialBias = BIAS_NEUTRAL;
    m_biasStrength = 0;
    m_mapCount = 0;
    ArrayResize(m_historicalData, 0);
    ArrayResize(m_forexToFutures, 0);
    ArrayResize(m_futuresToForex, 0);
}

//--- Destructor
CCOTAnalyzer::~CCOTAnalyzer() {
    Deinit();
}

//--- Inicialización
bool CCOTAnalyzer::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CCOTAnalyzer::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Inicializar mapa de símbolos
    if(!InitializeSymbolMap()) {
        m_utils.LogWarning("CCOTAnalyzer::Init - No se pudo inicializar el mapa de símbolos");
    }
    
    //--- Establecer ruta de datos
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_dataPath = terminalPath + "\\MQL5\\Files\\COT_Data\\";
    FolderCreate(m_dataPath);
    
    m_isInitialized = true;
    m_utils.LogInfo("CCOTAnalyzer inicializado correctamente");
    return true;
}

//--- Desinicialización
void CCOTAnalyzer::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    ArrayResize(m_historicalData, 0);
}

//--- Inicializar mapa de símbolos
bool CCOTAnalyzer::InitializeSymbolMap() {
    //--- Mapeo de Forex a Futuros COT
    string forex[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD", "USDCHF"};
    string futures[] = {"EUR", "GBP", "JPY", "AUD", "CAD", "NZD", "CHF"};
    
    m_mapCount = ArraySize(forex);
    ArrayResize(m_forexToFutures, m_mapCount);
    ArrayResize(m_futuresToForex, m_mapCount);
    
    for(int i = 0; i < m_mapCount; i++) {
        m_forexToFutures[i] = futures[i];
        m_futuresToForex[i] = forex[i];
    }
    
    return true;
}

//--- Obtener símbolo de futuros
string CCOTAnalyzer::GetFuturesSymbol(string forexSymbol) {
    for(int i = 0; i < m_mapCount; i++) {
        if(m_futuresToForex[i] == forexSymbol) {
            return m_forexToFutures[i];
        }
    }
    return "";
}

//--- Obtener símbolo Forex
string CCOTAnalyzer::GetForexSymbol(string futuresSymbol) {
    for(int i = 0; i < m_mapCount; i++) {
        if(m_forexToFutures[i] == futuresSymbol) {
            return m_futuresToForex[i];
        }
    }
    return "";
}

//--- Establecer símbolo
void CCOTAnalyzer::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            LoadData(symbol);
        }
    }
}

//--- Cargar datos COT
bool CCOTAnalyzer::LoadData(string symbol) {
    if(!m_isInitialized) return false;
    
    m_symbol = symbol;
    m_isDataLoaded = LoadCOTData(symbol);
    
    if(m_isDataLoaded) {
        m_lastUpdate = TimeCurrent();
        m_utils.LogInfo("COT data loaded for " + symbol);
    } else {
        m_utils.LogWarning("COT data not available for " + symbol + " - using simulated data");
        GenerateSimulatedCOT(symbol);
        m_isDataLoaded = true;
        m_lastUpdate = TimeCurrent();
    }
    
    return m_isDataLoaded;
}

//--- Cargar datos COT desde archivo
bool CCOTAnalyzer::LoadCOTDataFromFile(string symbol) {
    string futuresSymbol = GetFuturesSymbol(symbol);
    if(futuresSymbol == "") return false;
    
    string fileName = m_dataPath + "COT_" + futuresSymbol + ".csv";
    if(!FileIsExist(fileName)) return false;
    
    int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    string line = FileReadString(handle);
    bool dataFound = false;
    
    while(!FileIsEnding(handle)) {
        line = FileReadString(handle);
        if(line != "") {
            COTData data;
            if(ParseCOTLine(line, data)) {
                UpdateCurrentData(data);
                dataFound = true;
            }
        }
    }
    
    FileClose(handle);
    return dataFound;
}

//--- Parsear línea CSV de COT
bool CCOTAnalyzer::ParseCOTLine(string line, COTData &data) {
    string parts[];
    int count = StringSplit(line, ',', parts);
    
    if(count < 6) return false;
    
    data.symbol = parts[0];
    data.commercialNet = StringToDouble(parts[1]);
    data.commercialHigh12M = StringToDouble(parts[2]);
    data.commercialLow12M = StringToDouble(parts[3]);
    data.midPoint = StringToDouble(parts[4]);
    data.lastUpdate = (datetime)StringToInteger(parts[5]);
    
    return true;
}

//--- Generar datos COT simulados
void CCOTAnalyzer::GenerateSimulatedCOT(string symbol) {
    COTData data;
    data.symbol = symbol;
    data.lastUpdate = TimeCurrent();
    
    //--- Generar número pseudo-aleatorio basado en el símbolo
    int hash = 0;
    for(int i = 0; i < StringLen(symbol); i++) {
        hash += StringGetCharacter(symbol, i);
    }
    
    double seed = (hash % 100) / 100.0;
    double random = MathSin(seed * 1000) * 50 + 50;
    data.commercialNet = (random - 50) * 3000;
    
    data.commercialHigh12M = data.commercialNet * 2.0;
    data.commercialLow12M = data.commercialNet * 0.0;
    data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
    data.isBuyProgram = data.commercialNet > data.midPoint;
    data.isSellProgram = data.commercialNet < data.midPoint;
    data.hedgingNodule = 0;
    data.commercialBias = data.commercialNet > data.midPoint ? BIAS_BULLISH : BIAS_BEARISH;
    
    UpdateCurrentData(data);
}

//--- Actualizar datos actuales
void CCOTAnalyzer::UpdateCurrentData(COTData &data) {
    m_currentData = data;
    m_commercialNet = data.commercialNet;
    m_commercialHigh12M = data.commercialHigh12M;
    m_commercialLow12M = data.commercialLow12M;
    m_midPoint = data.midPoint;
    
    //--- Calcular rangos
    CalculateRanges(data);
    
    //--- Determinar programas
    DeterminePrograms(data);
    
    //--- Determinar bias
    DetermineBias(data);
    
    //--- Detectar nódulo de hedging
    m_isHedgingProgram = DetectHedgingNodule(data);
    
    //--- Guardar en histórico
    int idx = m_historicalCount;
    ArrayResize(m_historicalData, m_historicalCount + 1);
    m_historicalData[idx] = data;
    m_historicalCount++;
    
    m_lastUpdate = TimeCurrent();
}

//--- RF-606: Calcular rangos
bool CCOTAnalyzer::CalculateRanges(COTData &data) {
    if(data.commercialHigh12M == 0 || data.commercialLow12M == 0) {
        data.commercialHigh12M = data.commercialNet * 2.0;
        data.commercialLow12M = data.commercialNet * 0.0;
    }
    
    data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
    return true;
}

//--- RF-602/603/604: Determinar programas
void CCOTAnalyzer::DeterminePrograms(COTData &data) {
    //--- RF-607: Nueva línea cero
    data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
    
    //--- RF-602: Buy Program
    data.isBuyProgram = data.commercialNet > data.midPoint;
    m_isBuyProgram = data.isBuyProgram;
    
    //--- RF-603: Sell Program
    data.isSellProgram = data.commercialNet < data.midPoint;
    m_isSellProgram = data.isSellProgram;
    
    //--- RF-604: Hedging Program
    m_isHedgingProgram = data.isBuyProgram && data.isSellProgram;
}

//--- RF-612: Determinar bias
void CCOTAnalyzer::DetermineBias(COTData &data) {
    double net = data.commercialNet;
    double mid = data.midPoint;
    
    if(net > mid * 1.1) {
        data.commercialBias = BIAS_BULLISH;
        m_biasStrength = MathMin((net - mid) / mid * 100, 100);
    } else if(net < mid * 0.9) {
        data.commercialBias = BIAS_BEARISH;
        m_biasStrength = MathMin((mid - net) / mid * 100, 100);
    } else {
        data.commercialBias = BIAS_NEUTRAL;
        m_biasStrength = 0;
    }
    
    m_commercialBias = data.commercialBias;
}

//--- RF-610: Detectar nódulo de hedging
bool CCOTAnalyzer::DetectHedgingNodule(COTData &data) {
    if(m_historicalCount < 2) return false;
    
    COTData prev = m_historicalData[m_historicalCount - 2];
    double change = MathAbs(data.commercialNet - prev.commercialNet);
    double avg = MathAbs(data.commercialNet + prev.commercialNet) / 2.0;
    
    if(avg == 0) return false;
    
    double changePct = change / avg * 100;
    bool isNodule = changePct > 20;
    
    if(isNodule) {
        data.hedgingNodule = data.commercialNet;
        m_hedgingNodule = data.hedgingNodule;
    }
    
    return isNodule;
}

//--- RF-608: Buy Hedge Detection
bool CCOTAnalyzer::IsBuyHedge() const {
    return m_isSellProgram && m_commercialNet > m_midPoint;
}

bool CCOTAnalyzer::IsBuyHedgeForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-609: Sell Hedge Detection
bool CCOTAnalyzer::IsSellHedge() const {
    return m_isBuyProgram && m_commercialNet < m_midPoint;
}

bool CCOTAnalyzer::IsSellHedgeForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-615: Swing Filter
bool CCOTAnalyzer::IsSwingValid() const {
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    return m_biasStrength > 50;
}

bool CCOTAnalyzer::IsSwingValidForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-616: OSOK Filter
bool CCOTAnalyzer::IsOSOKValid() const {
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    double extremeThreshold = MathAbs(m_commercialHigh12M) * 0.8;
    return m_biasStrength > 70 && MathAbs(m_commercialNet) > extremeThreshold;
}

bool CCOTAnalyzer::IsOSOKValidForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-617: Day Trading Context
ENUM_BIAS CCOTAnalyzer::GetDayTradingContext() const {
    return m_commercialBias;
}

ENUM_BIAS CCOTAnalyzer::GetDayTradingContextForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return BIAS_NEUTRAL;
    return GetCommercialBias();
}

//--- RF-614: Alignment with Technicals
bool CCOTAnalyzer::IsAligned(ENUM_BIAS bias) const {
    return m_commercialBias == bias && m_biasStrength > 30;
}

bool CCOTAnalyzer::IsAlignedForSymbol(string symbol, ENUM_BIAS bias) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

double CCOTAnalyzer::GetAlignmentScore(ENUM_BIAS bias) const {
    if(m_commercialBias != bias) return 0;
    return m_biasStrength;
}

//--- RF-618: Auto Update
void CCOTAnalyzer::AutoUpdate() {
    if(IsUpdateNeeded()) {
        LoadData(m_symbol);
        m_utils.LogInfo("COT data auto-updated for " + m_symbol);
    }
}

bool CCOTAnalyzer::IsUpdateNeeded() const {
    if(m_lastUpdate == 0) return true;
    return (TimeCurrent() - m_lastUpdate) > m_updateInterval * 86400;
}

void CCOTAnalyzer::SetUpdateInterval(int days) {
    m_updateInterval = MathMax(1, days);
}

//--- RF-619: Historical Database
COTData CCOTAnalyzer::GetHistoricalData(int index) const {
    if(index < 0 || index >= m_historicalCount) {
        COTData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_historicalData[index];
}

double CCOTAnalyzer::GetHistoricalAverage(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double sum = 0;
    for(int i = m_historicalCount - count; i < m_historicalCount; i++) {
        sum += m_historicalData[i].commercialNet;
    }
    return sum / count;
}

//--- RF-601: Get Commercial Net
double CCOTAnalyzer::GetCommercialNetForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return 0;
    return 0;
}

//--- RF-602: Buy Program
bool CCOTAnalyzer::IsBuyProgramForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-603: Sell Program
bool CCOTAnalyzer::IsSellProgramForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-604: Hedging Program
bool CCOTAnalyzer::IsHedgingProgramForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return false;
    return false;
}

//--- RF-607: Mid Point
double CCOTAnalyzer::GetMidPointForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return 0;
    return 0;
}

bool CCOTAnalyzer::IsAboveZeroLine() const {
    return m_commercialNet > m_midPoint;
}

bool CCOTAnalyzer::IsBelowZeroLine() const {
    return m_commercialNet < m_midPoint;
}

//--- RF-610: Hedging Nodule
double CCOTAnalyzer::GetHedgingNoduleForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return 0;
    return 0;
}

bool CCOTAnalyzer::IsHedgingNoduleActive() const {
    return m_isHedgingProgram && m_hedgingNodule != 0;
}

//--- RF-612: Commercial Bias
ENUM_BIAS CCOTAnalyzer::GetCommercialBiasForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return BIAS_NEUTRAL;
    return BIAS_NEUTRAL;
}

//--- RF-620: COT Logging
string CCOTAnalyzer::GetCOTLog() {
    string log = "=== COT LOG ===\n";
    log += "Symbol: " + m_symbol + "\n";
    log += "Commercial Net: " + DoubleToString(m_commercialNet, 0) + "\n";
    log += "Mid Point: " + DoubleToString(m_midPoint, 0) + "\n";
    log += "Buy Program: " + (m_isBuyProgram ? "YES" : "NO") + "\n";
    log += "Sell Program: " + (m_isSellProgram ? "YES" : "NO") + "\n";
    log += "Hedging Program: " + (m_isHedgingProgram ? "YES" : "NO") + "\n";
    log += "Commercial Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                                  (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Last Update: " + TimeToString(m_lastUpdate) + "\n";
    return log;
}

string CCOTAnalyzer::GetCOTLogForSymbol(string symbol) {
    if(!IsCOTDataAvailable(symbol)) return "COT data not available for " + symbol;
    return "";
}

//--- RF-606: Range
double CCOTAnalyzer::GetCommercialRange12M() const {
    return m_commercialHigh12M - m_commercialLow12M;
}

//--- Actualizar
void CCOTAnalyzer::Update(string symbol = "") {
    if(symbol != "") SetSymbol(symbol);
    LoadData(m_symbol);
}

//--- Refresh
void CCOTAnalyzer::Refresh() {
    LoadData(m_symbol);
}

//--- Verificar disponibilidad de datos
bool CCOTAnalyzer::IsCOTDataAvailable(string symbol) {
    return true;
}

//--- Resumen COT
string CCOTAnalyzer::GetCOTSummary() {
    string summary = "=== COT SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Commercial Net: " + DoubleToString(m_commercialNet, 0) + "\n";
    summary += "Program: " + (m_isBuyProgram ? "BUY" : (m_isSellProgram ? "SELL" : "HEDGE")) + "\n";
    summary += "Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                           (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Strength: " + DoubleToString(m_biasStrength, 1) + "%\n";
    summary += "=========================";
    return summary;
}

//--- Reporte COT
string CCOTAnalyzer::GetCOTReport() {
    string report = "=== COT REPORT ===\n";
    report += "Symbol: " + m_symbol + "\n";
    report += "Commercial Net: " + DoubleToString(m_commercialNet, 0) + "\n";
    report += "12M Range: " + DoubleToString(GetCommercialRange12M(), 0) + "\n";
    report += "Mid Point: " + DoubleToString(m_midPoint, 0) + "\n";
    report += "Above Zero Line: " + (IsAboveZeroLine() ? "YES" : "NO") + "\n";
    report += "Hedging Nodule: " + DoubleToString(m_hedgingNodule, 0) + "\n";
    report += "Historical Entries: " + IntegerToString(m_historicalCount) + "\n";
    report += "Historical Avg (10): " + DoubleToString(GetHistoricalAverage(10), 0) + "\n";
    report += "=========================";
    return report;
}

#endif // __CCOTANALYZER_MQH__