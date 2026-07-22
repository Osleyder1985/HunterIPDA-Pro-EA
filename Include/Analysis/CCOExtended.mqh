//+------------------------------------------------------------------+
//|                                                  CCOExtended.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo extiende el análisis de COT:                         |
//| - Buy/Sell Hedge Detection                                       |
//| - Hedging Nodule Identification                                  |
//| - COT Extremes Detection                                         |
//| - COT vs Price Divergence                                        |
//| - COT Alignment with Technicals                                  |
//| - COT como filtro para Swing, OSOK, Day Trading                  |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-601: COT Short Format Analysis                              |
//|   RF-602: Buy Program Identification                             |
//|   RF-603: Sell Program Identification                            |
//|   RF-604: Hedging Program Detection                              |
//|   RF-608: Buy Hedge (COT) Detection                              |
//|   RF-609: Sell Hedge (COT) Detection                             |
//|   RF-610: Hedging Nodule Identification                          |
//|   RF-611: COT Extremes Detection                                 |
//|   RF-613: COT vs Price Divergence                                |
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
//|   - CCOTAnalyzer: Análisis COT base                              |
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

#ifndef __CCOEXTENDED_MQH__
#define __CCOEXTENDED_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CCOTAnalyzer.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct COTExtendedData {
    string           symbol;
    double           commercialNet;
    double           commercialHigh12M;
    double           commercialLow12M;
    double           midPoint;
    bool             isBuyProgram;
    bool             isSellProgram;
    bool             isHedgingProgram;
    double           hedgingNodule;
    ENUM_BIAS        commercialBias;
    bool             isExtreme;
    bool             isDivergence;
    double           buyHedgeLevel;
    double           sellHedgeLevel;
    double           extremeLevel;
    double           divergenceScore;
    datetime         lastUpdate;
};

//+------------------------------------------------------------------+
//| CLASE CCOExtended - Análisis COT Extended                        |
//+------------------------------------------------------------------+
class CCOExtended {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CCOTAnalyzer*      m_cotAnalyzer;
    bool               m_isInitialized;
    string             m_symbol;
    string             m_dataPath;
    bool               m_isDataLoaded;
    datetime           m_lastUpdate;
    int                m_updateInterval;
    
    //--- Datos COT Extended
    COTExtendedData    m_currentData;
    COTExtendedData    m_historicalData[];
    int                m_historicalCount;
    
    //--- Estado extendido
    bool               m_isBuyHedge;
    bool               m_isSellHedge;
    double             m_buyHedgeLevel;
    double             m_sellHedgeLevel;
    double             m_hedgingNodule;
    double             m_hedgingNoduleStrength;
    bool               m_isHedgingNoduleActive;
    bool               m_isExtreme;
    double             m_extremeLevel;
    bool               m_isDivergence;
    double             m_divergenceScore;
    ENUM_BIAS          m_commercialBias;
    
    //--- Umbrales
    double             m_significantChangeThreshold;
    double             m_hedgingNoduleThreshold;
    
    //--- Métodos privados
    bool               LoadCOTExtendedData(string symbol);
    bool               LoadCOTDataFromFile(string symbol);
    bool               ParseCOTLine(string line, COTExtendedData &data);
    void               DetectBuyHedge(COTExtendedData &data);
    void               DetectSellHedge(COTExtendedData &data);
    void               DetectHedgingNodule(COTExtendedData &data);
    void               DetectExtremes(COTExtendedData &data);
    void               DetectDivergence(COTExtendedData &data);
    void               UpdateCurrentData(COTExtendedData &data);
    void               GenerateSimulatedData(string symbol);
    double             CalculateHedgingStrength(COTExtendedData &data);
    double             CalculateDivergenceScore(COTExtendedData &data);
    bool               IsSignificantChange(COTExtendedData &data);
    
public:
    //--- Constructor / Destructor
    CCOExtended();
    ~CCOExtended();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CCOTAnalyzer* cotAnalyzer);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    bool IsDataLoaded() const { return m_isDataLoaded; }
    
    //--- Métodos Principales
    void Update(string symbol = "");
    void SetSymbol(string symbol);
    bool LoadData(string symbol);
    void Refresh();
    
    //--- RF-608: Buy Hedge (COT) Detection
    bool IsBuyHedge() const { return m_isBuyHedge; }
    bool IsBuyHedgeForSymbol(string symbol);
    double GetBuyHedgeLevel() const { return m_buyHedgeLevel; }
    
    //--- RF-609: Sell Hedge (COT) Detection
    bool IsSellHedge() const { return m_isSellHedge; }
    bool IsSellHedgeForSymbol(string symbol);
    double GetSellHedgeLevel() const { return m_sellHedgeLevel; }
    
    //--- RF-610: Hedging Nodule Identification
    double GetHedgingNodule() const { return m_hedgingNodule; }
    double GetHedgingNoduleStrength() const { return m_hedgingNoduleStrength; }
    bool IsHedgingNoduleActive() const { return m_isHedgingNoduleActive; }
    double GetHedgingNoduleForSymbol(string symbol);
    
    //--- RF-611: COT Extremes Detection
    bool IsExtreme() const { return m_isExtreme; }
    bool IsExtremeForSymbol(string symbol);
    double GetExtremeLevel() const { return m_extremeLevel; }
    ENUM_BIAS GetExtremeBias() const;
    
    //--- RF-613: COT vs Price Divergence
    bool IsDivergence() const { return m_isDivergence; }
    bool IsDivergenceForSymbol(string symbol);
    double GetDivergenceScore() const { return m_divergenceScore; }
    
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
    COTExtendedData GetHistoricalData(int index) const;
    double GetHistoricalAverage(int periods) const;
    
    //--- RF-620: COT Logging
    string GetCOTLog();
    string GetCOTLogForSymbol(string symbol);
    
    //--- Getters
    string GetSymbol() const { return m_symbol; }
    datetime GetLastUpdate() const { return m_lastUpdate; }
    string GetCOTSummary();
    string GetCOTReport();
    string GetExtendedReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CCOExtended::CCOExtended() {
    m_config = NULL;
    m_utils = NULL;
    m_cotAnalyzer = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_dataPath = "";
    m_isDataLoaded = false;
    m_lastUpdate = 0;
    m_updateInterval = 7;
    m_historicalCount = 0;
    m_isBuyHedge = false;
    m_isSellHedge = false;
    m_buyHedgeLevel = 0;
    m_sellHedgeLevel = 0;
    m_hedgingNodule = 0;
    m_hedgingNoduleStrength = 0;
    m_isHedgingNoduleActive = false;
    m_isExtreme = false;
    m_extremeLevel = 0;
    m_isDivergence = false;
    m_divergenceScore = 0;
    m_commercialBias = BIAS_NEUTRAL;
    m_significantChangeThreshold = 15.0;
    m_hedgingNoduleThreshold = 20.0;
    ArrayResize(m_historicalData, 0);
}

//--- Destructor
CCOExtended::~CCOExtended() {
    Deinit();
}

//--- Inicialización
bool CCOExtended::Init(CConfig* config, CUtils* utils, CCOTAnalyzer* cotAnalyzer) {
    if(config == NULL || utils == NULL || cotAnalyzer == NULL) {
        Print("CCOExtended::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_cotAnalyzer = cotAnalyzer;
    
    //--- Establecer ruta de datos
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_dataPath = terminalPath + "\\MQL5\\Files\\COT_Extended_Data\\";
    FolderCreate(m_dataPath);
    
    m_isInitialized = true;
    m_utils.LogInfo("CCOExtended inicializado correctamente");
    return true;
}

//--- Desinicialización
void CCOExtended::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_cotAnalyzer = NULL;
    m_isInitialized = false;
    ArrayResize(m_historicalData, 0);
}

//--- Establecer símbolo
void CCOExtended::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            LoadData(symbol);
        }
    }
}

//--- Cargar datos COT Extended
bool CCOExtended::LoadData(string symbol) {
    if(!m_isInitialized) return false;
    
    m_symbol = symbol;
    m_isDataLoaded = LoadCOTExtendedData(symbol);
    
    if(m_isDataLoaded) {
        m_lastUpdate = TimeCurrent();
        m_utils.LogInfo("COT Extended data loaded for " + symbol);
    } else {
        m_utils.LogWarning("COT Extended data not available for " + symbol + " - using simulated data");
        GenerateSimulatedData(symbol);
        m_isDataLoaded = true;
        m_lastUpdate = TimeCurrent();
    }
    
    return m_isDataLoaded;
}

//--- Cargar datos COT Extended
bool CCOExtended::LoadCOTExtendedData(string symbol) {
    if(LoadCOTDataFromFile(symbol)) {
        return true;
    }
    return false;
}

//--- Cargar datos desde archivo
bool CCOExtended::LoadCOTDataFromFile(string symbol) {
    string fileName = m_dataPath + "COT_Extended_" + symbol + ".csv";
    if(!FileIsExist(fileName)) return false;
    
    int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    bool dataFound = false;
    while(!FileIsEnding(handle)) {
        string line = FileReadString(handle);
        if(line != "") {
            COTExtendedData data;
            if(ParseCOTLine(line, data)) {
                UpdateCurrentData(data);
                dataFound = true;
            }
        }
    }
    
    FileClose(handle);
    return dataFound;
}

//--- Parsear línea CSV
bool CCOExtended::ParseCOTLine(string line, COTExtendedData &data) {
    string parts[];
    int count = StringSplit(line, ',', parts);
    
    if(count < 8) return false;
    
    data.symbol = parts[0];
    data.commercialNet = StringToDouble(parts[1]);
    data.commercialHigh12M = StringToDouble(parts[2]);
    data.commercialLow12M = StringToDouble(parts[3]);
    data.midPoint = StringToDouble(parts[4]);
    data.isBuyProgram = StringToInteger(parts[5]) > 0;
    data.isSellProgram = StringToInteger(parts[6]) > 0;
    data.lastUpdate = (datetime)StringToInteger(parts[7]);
    
    data.isHedgingProgram = data.isBuyProgram && data.isSellProgram;
    data.commercialBias = data.commercialNet > data.midPoint ? BIAS_BULLISH : BIAS_BEARISH;
    
    return true;
}

//--- Generar datos simulados
void CCOExtended::GenerateSimulatedData(string symbol) {
    COTExtendedData data;
    data.symbol = symbol;
    data.lastUpdate = TimeCurrent();
    
    //--- Usar datos de CCOTAnalyzer si están disponibles
    if(m_cotAnalyzer != NULL && m_cotAnalyzer.IsDataLoaded()) {
        data.commercialNet = m_cotAnalyzer.GetCommercialNet();
        data.commercialHigh12M = data.commercialNet * 2.0;
        data.commercialLow12M = data.commercialNet * 0.0;
        data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
        data.isBuyProgram = m_cotAnalyzer.IsBuyProgram();
        data.isSellProgram = m_cotAnalyzer.IsSellProgram();
    } else {
        //--- Generar datos aleatorios
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
    }
    
    data.isHedgingProgram = data.isBuyProgram && data.isSellProgram;
    data.commercialBias = data.commercialNet > data.midPoint ? BIAS_BULLISH : BIAS_BEARISH;
    data.hedgingNodule = 0;
    data.isExtreme = false;
    data.isDivergence = false;
    data.buyHedgeLevel = 0;
    data.sellHedgeLevel = 0;
    data.extremeLevel = 0;
    data.divergenceScore = 0;
    
    UpdateCurrentData(data);
}

//--- Actualizar datos actuales
void CCOExtended::UpdateCurrentData(COTExtendedData &data) {
    m_currentData = data;
    m_commercialBias = data.commercialBias;
    
    //--- RF-608: Buy Hedge
    DetectBuyHedge(data);
    
    //--- RF-609: Sell Hedge
    DetectSellHedge(data);
    
    //--- RF-610: Hedging Nodule
    DetectHedgingNodule(data);
    
    //--- RF-611: Extremes
    DetectExtremes(data);
    
    //--- RF-613: Divergence
    DetectDivergence(data);
    
    //--- Guardar en histórico
    int idx = m_historicalCount;
    ArrayResize(m_historicalData, m_historicalCount + 1);
    m_historicalData[idx] = data;
    m_historicalCount++;
    
    m_lastUpdate = TimeCurrent();
}

//--- RF-608: Detectar Buy Hedge
void CCOExtended::DetectBuyHedge(COTExtendedData &data) {
    //--- Buy Hedge: dentro de Sell Program, compra agresiva
    m_isBuyHedge = data.isSellProgram && data.commercialNet > data.midPoint;
    
    if(m_isBuyHedge) {
        m_buyHedgeLevel = data.commercialNet;
        data.buyHedgeLevel = m_buyHedgeLevel;
    } else {
        m_buyHedgeLevel = 0;
        data.buyHedgeLevel = 0;
    }
}

bool CCOExtended::IsBuyHedgeForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-609: Detectar Sell Hedge
void CCOExtended::DetectSellHedge(COTExtendedData &data) {
    //--- Sell Hedge: dentro de Buy Program, venta agresiva
    m_isSellHedge = data.isBuyProgram && data.commercialNet < data.midPoint;
    
    if(m_isSellHedge) {
        m_sellHedgeLevel = data.commercialNet;
        data.sellHedgeLevel = m_sellHedgeLevel;
    } else {
        m_sellHedgeLevel = 0;
        data.sellHedgeLevel = 0;
    }
}

bool CCOExtended::IsSellHedgeForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-610: Detectar Nódulo de Hedging
void CCOExtended::DetectHedgingNodule(COTExtendedData &data) {
    //--- Nódulo: cambio abrupto en posición neta
    if(m_historicalCount < 2) {
        m_isHedgingNoduleActive = false;
        m_hedgingNodule = 0;
        m_hedgingNoduleStrength = 0;
        data.hedgingNodule = 0;
        return;
    }
    
    COTExtendedData prev = m_historicalData[m_historicalCount - 1];
    double change = MathAbs(data.commercialNet - prev.commercialNet);
    double avg = MathAbs(data.commercialNet + prev.commercialNet) / 2.0;
    
    if(avg > 0) {
        double changePct = change / avg * 100;
        m_hedgingNoduleStrength = changePct;
        m_isHedgingNoduleActive = changePct > m_hedgingNoduleThreshold;
        
        if(m_isHedgingNoduleActive) {
            m_hedgingNodule = data.commercialNet;
            data.hedgingNodule = m_hedgingNodule;
        } else {
            m_hedgingNodule = 0;
            data.hedgingNodule = 0;
        }
    }
}

double CCOExtended::GetHedgingNoduleForSymbol(string symbol) {
    //--- Placeholder
    return 0;
}

//--- RF-611: Detectar Extremos
void CCOExtended::DetectExtremes(COTExtendedData &data) {
    double range = data.commercialHigh12M - data.commercialLow12M;
    if(range == 0) {
        m_isExtreme = false;
        m_extremeLevel = 0;
        data.isExtreme = false;
        data.extremeLevel = 0;
        return;
    }
    
    double position = (data.commercialNet - data.commercialLow12M) / range;
    m_isExtreme = position > 0.9 || position < 0.1;
    
    if(m_isExtreme) {
        m_extremeLevel = data.commercialNet;
        data.extremeLevel = m_extremeLevel;
    } else {
        m_extremeLevel = 0;
        data.extremeLevel = 0;
    }
    
    data.isExtreme = m_isExtreme;
}

bool CCOExtended::IsExtremeForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

ENUM_BIAS CCOExtended::GetExtremeBias() const {
    if(!m_isExtreme) return BIAS_NEUTRAL;
    return m_commercialBias;
}

//--- RF-613: Detectar Divergencia
void CCOExtended::DetectDivergence(COTExtendedData &data) {
    m_divergenceScore = CalculateDivergenceScore(data);
    m_isDivergence = m_divergenceScore > 60;
    data.isDivergence = m_isDivergence;
    data.divergenceScore = m_divergenceScore;
}

double CCOExtended::CalculateDivergenceScore(COTExtendedData &data) {
    double currentPrice = SymbolInfoDouble(data.symbol, SYMBOL_BID);
    double price20 = iClose(data.symbol, PERIOD_D1, 20);
    
    if(price20 == 0) return 0;
    
    double priceChange = (currentPrice - price20) / price20 * 100;
    double cotChange = 0;
    
    if(m_historicalCount > 0) {
        double prevNet = m_historicalData[m_historicalCount - 1].commercialNet;
        if(prevNet != 0) {
            cotChange = (data.commercialNet - prevNet) / MathAbs(prevNet) * 100;
        }
    }
    
    //--- Divergencia si precio y COT van en direcciones opuestas
    bool priceUp = priceChange > 1.0;
    bool cotUp = cotChange > 5.0;
    
    if(priceUp != cotUp) {
        return MathMin(MathAbs(priceChange) + MathAbs(cotChange) * 2, 100);
    }
    
    return 0;
}

bool CCOExtended::IsDivergenceForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-614: COT Alignment with Technicals
bool CCOExtended::IsAligned(ENUM_BIAS bias) const {
    return m_commercialBias == bias;
}

bool CCOExtended::IsAlignedForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder
    return false;
}

double CCOExtended::GetAlignmentScore(ENUM_BIAS bias) const {
    if(m_commercialBias != bias) return 0;
    
    double score = 50;
    if(m_isExtreme) score += 20;
    if(m_isHedgingNoduleActive) score += 15;
    if(m_isDivergence) score -= 20;
    
    return MathMax(0, MathMin(100, score));
}

//--- RF-615: COT as Swing Filter
bool CCOExtended::IsSwingValid() const {
    //--- Swing requiere bias fuerte y no extremo
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    return !m_isExtreme && !m_isDivergence;
}

bool CCOExtended::IsSwingValidForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-616: COT as OSOK Filter
bool CCOExtended::IsOSOKValid() const {
    //--- OSOK requiere extremo y alineado
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    return m_isExtreme && !m_isDivergence;
}

bool CCOExtended::IsOSOKValidForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-617: COT as Day Trading Context
ENUM_BIAS CCOExtended::GetDayTradingContext() const {
    return m_commercialBias;
}

ENUM_BIAS CCOExtended::GetDayTradingContextForSymbol(string symbol) {
    //--- Placeholder
    return BIAS_NEUTRAL;
}

//--- RF-618: COT Data Update Automation
void CCOExtended::AutoUpdate() {
    if(IsUpdateNeeded()) {
        LoadData(m_symbol);
        m_utils.LogInfo("COT Extended data auto-updated for " + m_symbol);
    }
}

bool CCOExtended::IsUpdateNeeded() const {
    if(m_lastUpdate == 0) return true;
    return (TimeCurrent() - m_lastUpdate) > m_updateInterval * 86400;
}

void CCOExtended::SetUpdateInterval(int days) {
    m_updateInterval = MathMax(1, days);
}

//--- RF-619: COT Historical Database
COTExtendedData CCOExtended::GetHistoricalData(int index) const {
    if(index < 0 || index >= m_historicalCount) {
        COTExtendedData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_historicalData[index];
}

double CCOExtended::GetHistoricalAverage(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double sum = 0;
    for(int i = m_historicalCount - count; i < m_historicalCount; i++) {
        sum += m_historicalData[i].commercialNet;
    }
    return sum / count;
}

//--- RF-620: COT Logging
string CCOExtended::GetCOTLog() {
    string log = "=== COT EXTENDED LOG ===\n";
    log += "Symbol: " + m_symbol + "\n";
    log += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    log += "Mid Point: " + DoubleToString(m_currentData.midPoint, 0) + "\n";
    log += "Buy Program: " + (m_currentData.isBuyProgram ? "YES" : "NO") + "\n";
    log += "Sell Program: " + (m_currentData.isSellProgram ? "YES" : "NO") + "\n";
    log += "Hedging Program: " + (m_currentData.isHedgingProgram ? "YES" : "NO") + "\n";
    log += "Buy Hedge: " + (m_isBuyHedge ? "YES" : "NO") + "\n";
    log += "Sell Hedge: " + (m_isSellHedge ? "YES" : "NO") + "\n";
    log += "Hedging Nodule: " + (m_isHedgingNoduleActive ? "YES" : "NO") + "\n";
    log += "Extreme: " + (m_isExtreme ? "YES" : "NO") + "\n";
    log += "Divergence: " + (m_isDivergence ? "YES" : "NO") + "\n";
    log += "Divergence Score: " + DoubleToString(m_divergenceScore, 1) + "\n";
    log += "Commercial Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                                  (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Last Update: " + TimeToString(m_lastUpdate) + "\n";
    return log;
}

string CCOExtended::GetCOTLogForSymbol(string symbol) {
    //--- Placeholder
    return "";
}

//--- Actualizar
void CCOExtended::Update(string symbol = "") {
    if(symbol != "") SetSymbol(symbol);
    LoadData(m_symbol);
}

//--- Refresh
void CCOExtended::Refresh() {
    LoadData(m_symbol);
}

//--- Resumen COT
string CCOExtended::GetCOTSummary() {
    string summary = "=== COT EXTENDED SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    summary += "Program: " + (m_currentData.isBuyProgram ? "BUY" : 
                              (m_currentData.isSellProgram ? "SELL" : "HEDGE")) + "\n";
    summary += "Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                           (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Extreme: " + (m_isExtreme ? "YES" : "NO") + "\n";
    summary += "Divergence: " + (m_isDivergence ? "YES" : "NO") + "\n";
    summary += "Hedging Nodule: " + (m_isHedgingNoduleActive ? "YES" : "NO") + "\n";
    summary += "=========================";
    return summary;
}

//--- Reporte COT Extended
string CCOExtended::GetCOTReport() {
    string report = "=== COT EXTENDED REPORT ===\n";
    report += "Symbol: " + m_symbol + "\n";
    report += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    report += "12M High: " + DoubleToString(m_currentData.commercialHigh12M, 0) + "\n";
    report += "12M Low: " + DoubleToString(m_currentData.commercialLow12M, 0) + "\n";
    report += "Mid Point: " + DoubleToString(m_currentData.midPoint, 0) + "\n";
    report += "Buy Hedge Level: " + DoubleToString(m_buyHedgeLevel, 0) + "\n";
    report += "Sell Hedge Level: " + DoubleToString(m_sellHedgeLevel, 0) + "\n";
    report += "Extreme Level: " + DoubleToString(m_extremeLevel, 0) + "\n";
    report += "Hedging Nodule: " + DoubleToString(m_hedgingNodule, 0) + "\n";
    report += "Nodule Strength: " + DoubleToString(m_hedgingNoduleStrength, 1) + "%\n";
    report += "Divergence Score: " + DoubleToString(m_divergenceScore, 1) + "\n";
    report += "Historical Entries: " + IntegerToString(m_historicalCount) + "\n";
    report += "Historical Avg: " + DoubleToString(GetHistoricalAverage(10), 0) + "\n";
    report += "==============================";
    return report;
}

//--- Reporte Extendido
string CCOExtended::GetExtendedReport() {
    string report = "=== EXTENDED ANALYSIS ===\n";
    report += "Swing Valid: " + (IsSwingValid() ? "YES" : "NO") + "\n";
    report += "OSOK Valid: " + (IsOSOKValid() ? "YES" : "NO") + "\n";
    report += "Day Trading Context: " + (GetDayTradingContext() == BIAS_BULLISH ? "BULLISH" : 
                                         (GetDayTradingContext() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Alignment Score: " + DoubleToString(GetAlignmentScore(BIAS_BULLISH), 1) + "% (BULL)\n";
    report += "Alignment Score: " + DoubleToString(GetAlignmentScore(BIAS_BEARISH), 1) + "% (BEAR)\n";
    report += "=========================";
    return report;
}

#endif // __CCOEXTENDED_MQH__