//+------------------------------------------------------------------+
//|                                                 CRelStrength.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis de fortaleza relativa:          |
//| - DXY Context                                                    |
//| - Relative Strength/Weakness Calculation                         |
//| - Higher Low / Lower High Detection                              |
//| - Accumulation / Distribution Patterns                           |
//| - Leadership Markets                                             |
//| - Sympathetic Rallies/Declines                                   |
//| - Commodity Basket Groups                                        |
//| - Cross-Currency Strength Analysis                               |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-621: DXY Context Analysis                                   |
//|   RF-622: Relative Strength Calculation                          |
//|   RF-623: Higher Low Identification                              |
//|   RF-624: Lower High Identification                              |
//|   RF-625: Accumulation Pattern Detection                         |
//|   RF-626: Distribution Pattern Detection                         |
//|   RF-627: Leadership Market Identification                       |
//|   RF-628: Sympathetic Rally Detection                            |
//|   RF-629: Sympathetic Decline Detection                          |
//|   RF-630: Commodity Basket Group Analysis                        |
//|   RF-631: Relative Strength Ranking                              |
//|   RF-632: Relative Weakness Ranking                              |
//|   RF-633: Cross-Currency Strength Analysis                       |
//|   RF-634: Strength Divergence Detection                          |
//|   RF-635: Relative Strength as Trade Filter                      |
//|   RF-636: Relative Strength as Exit Filter                       |
//|   RF-637: Relative Strength Logging                              |
//|   RF-638: Relative Strength Dashboard                            |
//|   RF-639: Multi-Period Strength Analysis                         |
//|   RF-640: Strength Momentum Detection                            |
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

#ifndef __CRELSTRENGTH_MQH__
#define __CRELSTRENGTH_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct StrengthData {
    string           symbol;
    double           strengthScore;
    double           weaknessScore;
    ENUM_BIAS        bias;
    bool             isHigherLow;
    bool             isLowerHigh;
    bool             isAccumulating;
    bool             isDistributing;
    bool             isLeadershipMarket;
    bool             isSympatheticRally;
    bool             isSympatheticDecline;
    string           commodityGroup;
    double           momentum;
    datetime         lastUpdate;
};

//+------------------------------------------------------------------+
//| CLASE CRelStrength - Análisis de Fortaleza Relativa              |
//+------------------------------------------------------------------+
class CRelStrength {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_symbol;
    
    //--- Símbolos para análisis
    string             m_majorSymbols[];
    string             m_commoditySymbols[];
    int                m_symbolCount;
    
    //--- Datos de fortaleza
    StrengthData       m_strengthData[];
    int                m_strengthCount;
    
    //--- DXY Context
    double             m_dxyPrice;
    double             m_dxyChange;
    ENUM_BIAS          m_dxyBias;
    double             m_dxyPrevClose;
    
    //--- Constantes
    double             m_significantMoveThreshold;
    int                m_periodsDefault;
    
    //--- Métodos privados
    bool               InitializeSymbols();
    void               CalculateStrengthScores();
    void               CalculateDXYContext();
    void               DetectHigherLow(string symbol);
    void               DetectLowerHigh(string symbol);
    void               DetectAccumulation(string symbol);
    void               DetectDistribution(string symbol);
    bool               DetectSympatheticRally(string symbol1, string symbol2);
    bool               DetectSympatheticDecline(string symbol1, string symbol2);
    double             CalculateStrengthScore(string symbol) const;
    double             CalculateWeaknessScore(string symbol);
    double             CalculateMomentum(string symbol);
    ENUM_BIAS          DetermineBias(string symbol);
    string             GetCommodityGroupInternal(string symbol);
    double             GetPercentChange(string symbol, int periods) const;
    double             GetRelativeStrength(string symbol, string benchmark);
    double             GetHighestHigh(string symbol, int periods);
    double             GetLowestLow(string symbol, int periods);
    bool               IsSymbolInData(string symbol) const;
    int                FindSymbolIndex(string symbol) const;
    
public:
    //--- Constructor / Destructor
    CRelStrength();
    ~CRelStrength();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Update();
    void UpdateSymbol(string symbol);
    void AddSymbol(string symbol);
    
    //--- RF-621: DXY Context Analysis
    double GetDXYPrice() const { return m_dxyPrice; }
    double GetDXYChange() const { return m_dxyChange; }
    ENUM_BIAS GetDXYBias() const { return m_dxyBias; }
    bool IsDXYBullish() const { return m_dxyBias == BIAS_BULLISH; }
    bool IsDXYBearish() const { return m_dxyBias == BIAS_BEARISH; }
    
    //--- RF-622: Relative Strength Calculation
    double GetStrengthScore(string symbol) const;
    double GetWeaknessScore(string symbol) const;
    ENUM_BIAS GetBias(string symbol) const;
    
    //--- RF-623: Higher Low Identification
    bool IsHigherLow(string symbol) const;
    bool IsHigherLowForSymbol(string symbol, int periods);
    
    //--- RF-624: Lower High Identification
    bool IsLowerHigh(string symbol) const;
    bool IsLowerHighForSymbol(string symbol, int periods);
    
    //--- RF-625: Accumulation Pattern Detection
    bool IsAccumulating(string symbol) const;
    bool IsAccumulatingForSymbol(string symbol, int periods);
    
    //--- RF-626: Distribution Pattern Detection
    bool IsDistributing(string symbol) const;
    bool IsDistributingForSymbol(string symbol, int periods);
    
    //--- RF-627: Leadership Market Identification
    bool IsLeadershipMarket(string symbol) const;
    string GetLeadershipSymbol();
    string GetLeadershipSymbolForBias(ENUM_BIAS bias);
    
    //--- RF-628: Sympathetic Rally Detection
    bool IsSympatheticRally(string symbol) const;
    bool IsSympatheticRallyBetween(string symbol1, string symbol2);
    
    //--- RF-629: Sympathetic Decline Detection
    bool IsSympatheticDecline(string symbol) const;
    bool IsSympatheticDeclineBetween(string symbol1, string symbol2);
    
    //--- RF-630: Commodity Basket Group Analysis
    string GetCommodityGroup(string symbol) const;
    double GetCommodityGroupStrength(string group);
    double GetCommodityGroupWeakness(string group);
    
    //--- RF-631: Relative Strength Ranking
    void GetStrengthRanking(string &symbols[], double &scores[]);
    string GetStrongestSymbol();
    void GetTopSymbols(int count, string &symbols[], double &scores[]);
    
    //--- RF-632: Relative Weakness Ranking
    void GetWeaknessRanking(string &symbols[], double &scores[]);
    string GetWeakestSymbol();
    void GetBottomSymbols(int count, string &symbols[], double &scores[]);
    
    //--- RF-633: Cross-Currency Strength Analysis
    double GetCurrencyStrength(string currency) const;
    double GetCurrencyWeakness(string currency) const;
    string GetStrongestCurrency();
    string GetWeakestCurrency();
    
    //--- RF-634: Strength Divergence Detection
    bool IsStrengthDivergence(string symbol) const;
    bool IsStrengthDivergenceForSymbol(string symbol, int periods);
    double GetDivergenceScore(string symbol) const;
    
    //--- RF-635: Relative Strength as Trade Filter
    bool IsTradeFilterValid(string symbol, ENUM_BIAS bias) const;
    bool IsStrengthConfirming(string symbol, ENUM_BIAS bias) const;
    
    //--- RF-636: Relative Strength as Exit Filter
    bool IsExitSignal(string symbol, ENUM_BIAS bias) const;
    bool IsStrengthExhausted(string symbol) const;
    
    //--- RF-637: Relative Strength Logging
    string GetStrengthLog();
    string GetStrengthLogForSymbol(string symbol);
    
    //--- RF-638: Relative Strength Dashboard
    string GetStrengthDashboard();
    string GetStrengthDashboardForSymbol(string symbol);
    
    //--- RF-639: Multi-Period Strength Analysis
    double GetStrengthByPeriod(string symbol, ENUM_TIMEFRAMES tf);
    double GetWeaknessByPeriod(string symbol, ENUM_TIMEFRAMES tf);
    bool IsStrengthConsistent(string symbol);
    
    //--- RF-640: Strength Momentum Detection
    double GetStrengthMomentum(string symbol) const;
    bool IsStrengthIncreasing(string symbol) const;
    bool IsStrengthDecreasing(string symbol) const;
    double GetMomentumScore(string symbol) const;
    
    //--- Getters
    int GetSymbolCount() const { return m_strengthCount; }
    StrengthData GetStrengthData(int index) const;
    string GetSummary();
    string GetReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CRelStrength::CRelStrength() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_symbolCount = 0;
    m_strengthCount = 0;
    m_dxyPrice = 0;
    m_dxyChange = 0;
    m_dxyBias = BIAS_NEUTRAL;
    m_dxyPrevClose = 0;
    m_significantMoveThreshold = 1.0;
    m_periodsDefault = 20;
    ArrayResize(m_strengthData, 0);
    ArrayResize(m_majorSymbols, 0);
    ArrayResize(m_commoditySymbols, 0);
}

//--- Destructor
CRelStrength::~CRelStrength() {
    Deinit();
}

//--- Inicialización
bool CRelStrength::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CRelStrength::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Inicializar símbolos
    if(!InitializeSymbols()) {
        m_utils.LogWarning("CRelStrength::Init - No se pudieron inicializar los símbolos");
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CRelStrength inicializado correctamente");
    
    //--- Actualizar datos
    Update();
    
    return true;
}

//--- Desinicialización
void CRelStrength::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    ArrayResize(m_strengthData, 0);
}

//--- Inicializar símbolos
bool CRelStrength::InitializeSymbols() {
    //--- Símbolos mayores
    ArrayResize(m_majorSymbols, 7);
    m_majorSymbols[0] = "EURUSD";
    m_majorSymbols[1] = "GBPUSD";
    m_majorSymbols[2] = "USDJPY";
    m_majorSymbols[3] = "AUDUSD";
    m_majorSymbols[4] = "USDCAD";
    m_majorSymbols[5] = "NZDUSD";
    m_majorSymbols[6] = "USDCHF";
    
    //--- Commodities
    ArrayResize(m_commoditySymbols, 4);
    m_commoditySymbols[0] = "XAUUSD";
    m_commoditySymbols[1] = "XAGUSD";
    m_commoditySymbols[2] = "WTI";
    m_commoditySymbols[3] = "BRENT";
    
    m_symbolCount = ArraySize(m_majorSymbols);
    
    return true;
}

//--- Actualizar
void CRelStrength::Update() {
    if(!m_isInitialized) return;
    
    CalculateDXYContext();
    
    //--- Actualizar cada símbolo
    for(int i = 0; i < ArraySize(m_majorSymbols); i++) {
        UpdateSymbol(m_majorSymbols[i]);
    }
    
    for(int i = 0; i < ArraySize(m_commoditySymbols); i++) {
        UpdateSymbol(m_commoditySymbols[i]);
    }
}

//--- Actualizar símbolo
void CRelStrength::UpdateSymbol(string symbol) {
    if(!m_isInitialized) return;
    
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) {
        //--- Añadir nuevo símbolo
        idx = m_strengthCount;
        ArrayResize(m_strengthData, m_strengthCount + 1);
        m_strengthData[idx].symbol = symbol;
        m_strengthCount++;
    }
    
    //--- Calcular datos
    m_strengthData[idx].strengthScore = CalculateStrengthScore(symbol);
    m_strengthData[idx].weaknessScore = CalculateWeaknessScore(symbol);
    m_strengthData[idx].bias = DetermineBias(symbol);
    m_strengthData[idx].momentum = CalculateMomentum(symbol);
    m_strengthData[idx].lastUpdate = TimeCurrent();
    
    //--- Detectar patrones
    DetectHigherLow(symbol);
    DetectLowerHigh(symbol);
    DetectAccumulation(symbol);
    DetectDistribution(symbol);
    
    //--- Commodity group
    m_strengthData[idx].commodityGroup = GetCommodityGroupInternal(symbol);
    
    //--- Leadership
    m_strengthData[idx].isLeadershipMarket = false;
    m_strengthData[idx].isSympatheticRally = false;
    m_strengthData[idx].isSympatheticDecline = false;
}

//--- RF-621: Calcular DXY Context
void CRelStrength::CalculateDXYContext() {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    
    int copied = CopyClose("DXY", PERIOD_D1, 0, 2, closeArray);
    if(copied < 2) {
        m_dxyPrice = 0;
        m_dxyChange = 0;
        m_dxyBias = BIAS_NEUTRAL;
        return;
    }
    
    m_dxyPrice = closeArray[0];
    m_dxyPrevClose = closeArray[1];
    m_dxyChange = (m_dxyPrice - m_dxyPrevClose) / m_dxyPrevClose * 100.0;
    
    if(m_dxyChange > 0.5) m_dxyBias = BIAS_BULLISH;
    else if(m_dxyChange < -0.5) m_dxyBias = BIAS_BEARISH;
    else m_dxyBias = BIAS_NEUTRAL;
}

//--- RF-622: Calcular Strength Score
double CRelStrength::CalculateStrengthScore(string symbol) const {
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double price20 = iClose(symbol, PERIOD_D1, 20);
    double price50 = iClose(symbol, PERIOD_D1, 50);
    
    if(price50 == 0) return 50.0;
    
    //--- Score basado en posición relativa
    double score = 50.0;
    
    //--- Factor 1: Precio vs EMA20 (30%)
    if(currentPrice > price20) score += 15;
    else score -= 15;
    
    //--- Factor 2: Precio vs EMA50 (30%)
    if(currentPrice > price50) score += 15;
    else score -= 15;
    
    //--- Factor 3: EMA20 vs EMA50 (20%)
    if(price20 > price50) score += 10;
    else score -= 10;
    
    //--- Factor 4: RSI (20%)
    double rsi = m_utils.CalculateRSI(symbol, PERIOD_D1, 14);
    if(rsi > 50) score += (rsi - 50) * 0.4;
    else score -= (50 - rsi) * 0.4;
    
    //--- Limitar entre 0 y 100
    if(score > 100) score = 100;
    if(score < 0) score = 0;
    
    return score;
}

//--- RF-622: Calcular Weakness Score
double CRelStrength::CalculateWeaknessScore(string symbol) {
    return 100.0 - CalculateStrengthScore(symbol);
}

//--- RF-622: Determinar Bias
ENUM_BIAS CRelStrength::DetermineBias(string symbol) {
    double score = CalculateStrengthScore(symbol);
    if(score > 60) return BIAS_BULLISH;
    if(score < 40) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-622: Obtener Strength Score
double CRelStrength::GetStrengthScore(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return 50.0;
    return m_strengthData[idx].strengthScore;
}

//--- RF-622: Obtener Weakness Score
double CRelStrength::GetWeaknessScore(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return 50.0;
    return m_strengthData[idx].weaknessScore;
}

//--- RF-622: Obtener Bias
ENUM_BIAS CRelStrength::GetBias(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return BIAS_NEUTRAL;
    return m_strengthData[idx].bias;
}

//--- RF-623: Higher Low Detection
void CRelStrength::DetectHigherLow(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return;
    
    double low1 = GetLowestLow(symbol, 10);
    double low2 = GetLowestLow(symbol, 20);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    
    m_strengthData[idx].isHigherLow = (low1 > low2) && (low1 - low2) / point > 10;
}

bool CRelStrength::IsHigherLow(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isHigherLow;
}

bool CRelStrength::IsHigherLowForSymbol(string symbol, int periods) {
    //--- Placeholder
    return false;
}

//--- RF-624: Lower High Detection
void CRelStrength::DetectLowerHigh(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return;
    
    double high1 = GetHighestHigh(symbol, 10);
    double high2 = GetHighestHigh(symbol, 20);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    
    m_strengthData[idx].isLowerHigh = (high1 < high2) && (high2 - high1) / point > 10;
}

bool CRelStrength::IsLowerHigh(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isLowerHigh;
}

bool CRelStrength::IsLowerHighForSymbol(string symbol, int periods) {
    //--- Placeholder
    return false;
}

//--- RF-625: Accumulation Pattern Detection
void CRelStrength::DetectAccumulation(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return;
    
    bool higherLow = IsHigherLow(symbol);
    bool strengthIncreasing = IsStrengthIncreasing(symbol);
    
    m_strengthData[idx].isAccumulating = higherLow && strengthIncreasing;
}

bool CRelStrength::IsAccumulating(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isAccumulating;
}

bool CRelStrength::IsAccumulatingForSymbol(string symbol, int periods) {
    //--- Placeholder
    return false;
}

//--- RF-626: Distribution Pattern Detection
void CRelStrength::DetectDistribution(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return;
    
    bool lowerHigh = IsLowerHigh(symbol);
    bool strengthDecreasing = IsStrengthDecreasing(symbol);
    
    m_strengthData[idx].isDistributing = lowerHigh && strengthDecreasing;
}

bool CRelStrength::IsDistributing(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isDistributing;
}

bool CRelStrength::IsDistributingForSymbol(string symbol, int periods) {
    //--- Placeholder
    return false;
}

//--- RF-627: Leadership Market Identification
bool CRelStrength::IsLeadershipMarket(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isLeadershipMarket;
}

string CRelStrength::GetLeadershipSymbol() {
    string symbols[];
    double scores[];
    GetStrengthRanking(symbols, scores);
    
    if(ArraySize(symbols) == 0) return "";
    return symbols[0];
}

string CRelStrength::GetLeadershipSymbolForBias(ENUM_BIAS bias) {
    string symbols[];
    double scores[];
    GetStrengthRanking(symbols, scores);
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        ENUM_BIAS symbolBias = GetBias(symbols[i]);
        if(symbolBias == bias) {
            return symbols[i];
        }
    }
    return "";
}

//--- RF-628: Sympathetic Rally Detection
bool CRelStrength::IsSympatheticRally(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isSympatheticRally;
}

bool CRelStrength::IsSympatheticRallyBetween(string symbol1, string symbol2) {
    return DetectSympatheticRally(symbol1, symbol2);
}

bool CRelStrength::DetectSympatheticRally(string symbol1, string symbol2) {
    double change1 = GetPercentChange(symbol1, 5);
    double change2 = GetPercentChange(symbol2, 5);
    
    return change1 > 1.0 && change2 > 1.0;
}

//--- RF-629: Sympathetic Decline Detection
bool CRelStrength::IsSympatheticDecline(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].isSympatheticDecline;
}

bool CRelStrength::IsSympatheticDeclineBetween(string symbol1, string symbol2) {
    return DetectSympatheticDecline(symbol1, symbol2);
}

bool CRelStrength::DetectSympatheticDecline(string symbol1, string symbol2) {
    double change1 = GetPercentChange(symbol1, 5);
    double change2 = GetPercentChange(symbol2, 5);
    
    return change1 < -1.0 && change2 < -1.0;
}

//--- RF-630: Commodity Basket Group Analysis
string CRelStrength::GetCommodityGroup(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return "";
    return m_strengthData[idx].commodityGroup;
}

string CRelStrength::GetCommodityGroupInternal(string symbol) {
    if(symbol == "XAUUSD" || symbol == "XAGUSD") return "Precious Metals";
    if(symbol == "WTI" || symbol == "BRENT") return "Energy";
    return "Other";
}

double CRelStrength::GetCommodityGroupStrength(string group) {
    double total = 0;
    int count = 0;
    
    for(int i = 0; i < m_strengthCount; i++) {
        if(m_strengthData[i].commodityGroup == group) {
            total += m_strengthData[i].strengthScore;
            count++;
        }
    }
    
    if(count == 0) return 0;
    return total / count;
}

double CRelStrength::GetCommodityGroupWeakness(string group) {
    return 100.0 - GetCommodityGroupStrength(group);
}

//--- RF-631: Relative Strength Ranking
void CRelStrength::GetStrengthRanking(string &symbols[], double &scores[]) {
    int count = m_strengthCount;
    ArrayResize(symbols, count);
    ArrayResize(scores, count);
    
    for(int i = 0; i < count; i++) {
        symbols[i] = m_strengthData[i].symbol;
        scores[i] = m_strengthData[i].strengthScore;
    }
    
    //--- Ordenamiento simple (burbuja)
    for(int i = 0; i < count - 1; i++) {
        for(int j = i + 1; j < count; j++) {
            if(scores[i] < scores[j]) {
                double tempScore = scores[i];
                scores[i] = scores[j];
                scores[j] = tempScore;
                
                string tempSymbol = symbols[i];
                symbols[i] = symbols[j];
                symbols[j] = tempSymbol;
            }
        }
    }
}

string CRelStrength::GetStrongestSymbol() {
    string symbols[];
    double scores[];
    GetStrengthRanking(symbols, scores);
    if(ArraySize(symbols) == 0) return "";
    return symbols[0];
}

void CRelStrength::GetTopSymbols(int count, string &symbols[], double &scores[]) {
    string allSymbols[];
    double allScores[];
    GetStrengthRanking(allSymbols, allScores);
    
    int resultCount = MathMin(count, ArraySize(allSymbols));
    ArrayResize(symbols, resultCount);
    ArrayResize(scores, resultCount);
    
    for(int i = 0; i < resultCount; i++) {
        symbols[i] = allSymbols[i];
        scores[i] = allScores[i];
    }
}

//--- RF-632: Relative Weakness Ranking
void CRelStrength::GetWeaknessRanking(string &symbols[], double &scores[]) {
    int count = m_strengthCount;
    ArrayResize(symbols, count);
    ArrayResize(scores, count);
    
    for(int i = 0; i < count; i++) {
        symbols[i] = m_strengthData[i].symbol;
        scores[i] = m_strengthData[i].weaknessScore;
    }
    
    for(int i = 0; i < count - 1; i++) {
        for(int j = i + 1; j < count; j++) {
            if(scores[i] < scores[j]) {
                double tempScore = scores[i];
                scores[i] = scores[j];
                scores[j] = tempScore;
                
                string tempSymbol = symbols[i];
                symbols[i] = symbols[j];
                symbols[j] = tempSymbol;
            }
        }
    }
}

string CRelStrength::GetWeakestSymbol() {
    string symbols[];
    double scores[];
    GetWeaknessRanking(symbols, scores);
    if(ArraySize(symbols) == 0) return "";
    return symbols[0];
}

void CRelStrength::GetBottomSymbols(int count, string &symbols[], double &scores[]) {
    string allSymbols[];
    double allScores[];
    GetWeaknessRanking(allSymbols, allScores);
    
    int resultCount = MathMin(count, ArraySize(allSymbols));
    ArrayResize(symbols, resultCount);
    ArrayResize(scores, resultCount);
    
    for(int i = 0; i < resultCount; i++) {
        symbols[i] = allSymbols[i];
        scores[i] = allScores[i];
    }
}

//--- RF-633: Cross-Currency Strength Analysis
double CRelStrength::GetCurrencyStrength(string currency) const {
    double total = 0;
    int count = 0;
    
    for(int i = 0; i < m_strengthCount; i++) {
        if(StringFind(m_strengthData[i].symbol, currency) != -1) {
            total += m_strengthData[i].strengthScore;
            count++;
        }
    }
    
    if(count == 0) return 50.0;
    return total / count;
}

double CRelStrength::GetCurrencyWeakness(string currency) const {
    return 100.0 - GetCurrencyStrength(currency);
}

string CRelStrength::GetStrongestCurrency() {
    string currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "NZD", "CHF"};
    double bestScore = -1;
    string bestCurrency = "";
    
    for(int i = 0; i < ArraySize(currencies); i++) {
        double score = GetCurrencyStrength(currencies[i]);
        if(score > bestScore) {
            bestScore = score;
            bestCurrency = currencies[i];
        }
    }
    
    return bestCurrency;
}

string CRelStrength::GetWeakestCurrency() {
    string currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "NZD", "CHF"};
    double worstScore = 101;
    string worstCurrency = "";
    
    for(int i = 0; i < ArraySize(currencies); i++) {
        double score = GetCurrencyStrength(currencies[i]);
        if(score < worstScore) {
            worstScore = score;
            worstCurrency = currencies[i];
        }
    }
    
    return worstCurrency;
}

//--- RF-634: Strength Divergence Detection
bool CRelStrength::IsStrengthDivergence(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double price20 = iClose(symbol, PERIOD_D1, 20);
    double strength = m_strengthData[idx].strengthScore;
    double strength20 = CalculateStrengthScore(symbol) - GetPercentChange(symbol, 20);
    
    bool priceUp = currentPrice > price20;
    bool strengthUp = strength > strength20;
    
    return priceUp != strengthUp;
}

bool CRelStrength::IsStrengthDivergenceForSymbol(string symbol, int periods) {
    //--- Placeholder
    return false;
}

double CRelStrength::GetDivergenceScore(string symbol) const {
    if(!IsStrengthDivergence(symbol)) return 0;
    return 70.0;
}

//--- RF-635: Relative Strength as Trade Filter
bool CRelStrength::IsTradeFilterValid(string symbol, ENUM_BIAS bias) const {
    ENUM_BIAS symbolBias = GetBias(symbol);
    if(symbolBias == BIAS_NEUTRAL) return false;
    return symbolBias == bias;
}

bool CRelStrength::IsStrengthConfirming(string symbol, ENUM_BIAS bias) const {
    return IsTradeFilterValid(symbol, bias);
}

//--- RF-636: Relative Strength as Exit Filter
bool CRelStrength::IsExitSignal(string symbol, ENUM_BIAS bias) const {
    ENUM_BIAS symbolBias = GetBias(symbol);
    return symbolBias != bias && symbolBias != BIAS_NEUTRAL;
}

bool CRelStrength::IsStrengthExhausted(string symbol) const {
    double score = GetStrengthScore(symbol);
    return score > 80 || score < 20;
}

//--- RF-637: Relative Strength Logging
string CRelStrength::GetStrengthLog() {
    string log = "=== STRENGTH LOG ===\n";
    log += "DXY: " + DoubleToString(m_dxyPrice, 2) + " (" + DoubleToString(m_dxyChange, 2) + "%)\n";
    log += "DXY Bias: " + (m_dxyBias == BIAS_BULLISH ? "BULLISH" : 
                           (m_dxyBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Strongest: " + GetStrongestSymbol() + "\n";
    log += "Weakest: " + GetWeakestSymbol() + "\n";
    log += "Strongest Currency: " + GetStrongestCurrency() + "\n";
    log += "Weakest Currency: " + GetWeakestCurrency() + "\n";
    return log;
}

string CRelStrength::GetStrengthLogForSymbol(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return "Symbol not found: " + symbol;
    
    string log = "=== STRENGTH LOG - " + symbol + " ===\n";
    log += "Strength: " + DoubleToString(m_strengthData[idx].strengthScore, 1) + "\n";
    log += "Weakness: " + DoubleToString(m_strengthData[idx].weaknessScore, 1) + "\n";
    log += "Bias: " + (m_strengthData[idx].bias == BIAS_BULLISH ? "BULLISH" : 
                       (m_strengthData[idx].bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Higher Low: " + (m_strengthData[idx].isHigherLow ? "YES" : "NO") + "\n";
    log += "Lower High: " + (m_strengthData[idx].isLowerHigh ? "YES" : "NO") + "\n";
    log += "Accumulating: " + (m_strengthData[idx].isAccumulating ? "YES" : "NO") + "\n";
    log += "Distributing: " + (m_strengthData[idx].isDistributing ? "YES" : "NO") + "\n";
    log += "Momentum: " + DoubleToString(m_strengthData[idx].momentum, 1) + "\n";
    return log;
}

//--- RF-638: Relative Strength Dashboard
string CRelStrength::GetStrengthDashboard() {
    string dash = "=== STRENGTH DASHBOARD ===\n";
    dash += "DXY: " + DoubleToString(m_dxyPrice, 2) + "\n";
    dash += "Strongest: " + GetStrongestSymbol() + "\n";
    dash += "Weakest: " + GetWeakestSymbol() + "\n";
    dash += "Strongest Currency: " + GetStrongestCurrency() + "\n";
    dash += "Weakest Currency: " + GetWeakestCurrency() + "\n";
    dash += "============================\n";
    
    string symbols[];
    double scores[];
    GetStrengthRanking(symbols, scores);
    
    for(int i = 0; i < MathMin(5, ArraySize(symbols)); i++) {
        dash += IntegerToString(i+1) + ". " + symbols[i] + ": " + DoubleToString(scores[i], 1) + "\n";
    }
    
    return dash;
}

string CRelStrength::GetStrengthDashboardForSymbol(string symbol) {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return "Symbol not found: " + symbol;
    
    string dash = "=== STRENGTH - " + symbol + " ===\n";
    dash += "Score: " + DoubleToString(m_strengthData[idx].strengthScore, 1) + "\n";
    dash += "Bias: " + (m_strengthData[idx].bias == BIAS_BULLISH ? "BULLISH" : 
                        (m_strengthData[idx].bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    dash += "Momentum: " + DoubleToString(m_strengthData[idx].momentum, 1) + "\n";
    dash += "Accumulating: " + (m_strengthData[idx].isAccumulating ? "✅" : "❌") + "\n";
    dash += "Distributing: " + (m_strengthData[idx].isDistributing ? "✅" : "❌") + "\n";
    return dash;
}

//--- RF-639: Multi-Period Strength Analysis
double CRelStrength::GetStrengthByPeriod(string symbol, ENUM_TIMEFRAMES tf) {
    double close0 = iClose(symbol, tf, 0);
    double close20 = iClose(symbol, tf, 20);
    
    if(close20 == 0) return 50.0;
    
    double change = (close0 - close20) / close20 * 100;
    return 50 + change * 2;
}

double CRelStrength::GetWeaknessByPeriod(string symbol, ENUM_TIMEFRAMES tf) {
    return 100.0 - GetStrengthByPeriod(symbol, tf);
}

bool CRelStrength::IsStrengthConsistent(string symbol) {
    double d1 = GetStrengthByPeriod(symbol, PERIOD_D1);
    double h4 = GetStrengthByPeriod(symbol, PERIOD_H4);
    double h1 = GetStrengthByPeriod(symbol, PERIOD_H1);
    
    bool d1Bull = d1 > 50;
    bool h4Bull = h4 > 50;
    bool h1Bull = h1 > 50;
    
    return (d1Bull == h4Bull) && (h4Bull == h1Bull);
}

//--- RF-640: Strength Momentum Detection
double CRelStrength::GetStrengthMomentum(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return 0;
    return m_strengthData[idx].momentum;
}

bool CRelStrength::IsStrengthIncreasing(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].momentum > 0;
}

bool CRelStrength::IsStrengthDecreasing(string symbol) const {
    int idx = FindSymbolIndex(symbol);
    if(idx == -1) return false;
    return m_strengthData[idx].momentum < 0;
}

double CRelStrength::GetMomentumScore(string symbol) const {
    return GetStrengthMomentum(symbol);
}

//--- RF-640: Calcular Momentum
double CRelStrength::CalculateMomentum(string symbol) {
    double currentScore = CalculateStrengthScore(symbol);
    double previousScore = CalculateStrengthScore(symbol) - GetPercentChange(symbol, 5);
    return currentScore - previousScore;
}

//--- Funciones auxiliares
double CRelStrength::GetPercentChange(string symbol, int periods) const {
    double close0 = iClose(symbol, PERIOD_D1, 0);
    double closeN = iClose(symbol, PERIOD_D1, periods);
    
    if(closeN == 0) return 0;
    return (close0 - closeN) / closeN * 100.0;
}

double CRelStrength::GetHighestHigh(string symbol, int periods) {
    double highArray[];
    ArraySetAsSeries(highArray, true);
    if(CopyHigh(symbol, PERIOD_D1, 0, periods, highArray) < periods) return 0;
    
    double maxHigh = highArray[0];
    for(int i = 1; i < periods; i++) {
        if(highArray[i] > maxHigh) maxHigh = highArray[i];
    }
    return maxHigh;
}

double CRelStrength::GetLowestLow(string symbol, int periods) {
    double lowArray[];
    ArraySetAsSeries(lowArray, true);
    if(CopyLow(symbol, PERIOD_D1, 0, periods, lowArray) < periods) return 0;
    
    double minLow = lowArray[0];
    for(int i = 1; i < periods; i++) {
        if(lowArray[i] < minLow) minLow = lowArray[i];
    }
    return minLow;
}

//--- Buscar índice de símbolo
int CRelStrength::FindSymbolIndex(string symbol) const {
    for(int i = 0; i < m_strengthCount; i++) {
        if(m_strengthData[i].symbol == symbol) return i;
    }
    return -1;
}

//--- Verificar si símbolo está en datos
bool CRelStrength::IsSymbolInData(string symbol) const {
    return FindSymbolIndex(symbol) != -1;
}

//--- Añadir símbolo
void CRelStrength::AddSymbol(string symbol) {
    if(!IsSymbolInData(symbol)) {
        UpdateSymbol(symbol);
    }
}

//--- Obtener datos de fortaleza por índice
StrengthData CRelStrength::GetStrengthData(int index) const {
    if(index < 0 || index >= m_strengthCount) {
        StrengthData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_strengthData[index];
}

//--- Resumen
string CRelStrength::GetSummary() {
    string summary = "=== STRENGTH SUMMARY ===\n";
    summary += "Symbols: " + IntegerToString(m_strengthCount) + "\n";
    summary += "DXY: " + DoubleToString(m_dxyPrice, 2) + " (" + DoubleToString(m_dxyChange, 2) + "%)\n";
    summary += "Strongest: " + GetStrongestSymbol() + "\n";
    summary += "Weakest: " + GetWeakestSymbol() + "\n";
    summary += "Strongest Currency: " + GetStrongestCurrency() + "\n";
    summary += "Weakest Currency: " + GetWeakestCurrency() + "\n";
    summary += "=========================";
    return summary;
}

//--- Reporte
string CRelStrength::GetReport() {
    string report = "=== STRENGTH REPORT ===\n";
    for(int i = 0; i < m_strengthCount; i++) {
        report += m_strengthData[i].symbol + ": ";
        report += DoubleToString(m_strengthData[i].strengthScore, 1) + " | ";
        report += (m_strengthData[i].bias == BIAS_BULLISH ? "BULL" : 
                   (m_strengthData[i].bias == BIAS_BEARISH ? "BEAR" : "NEUT")) + " | ";
        report += "Momentum: " + DoubleToString(m_strengthData[i].momentum, 1) + "\n";
    }
    return report;
}

#endif // __CRELSTRENGTH_MQH__