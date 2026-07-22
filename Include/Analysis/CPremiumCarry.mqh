//+------------------------------------------------------------------+
//|                                                CPremiumCarry.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el análisis de Premium vs Carrying Charge:  |
//| - Nearby/Next Month Price Analysis                               |
//| - Spread Chart Calculation                                       |
//| - Premium Market Identification                                  |
//| - Carrying Charge Market Identification                          |
//| - Spread Divergence Detection                                    |
//| - Commercial Bull/Bear Market Detection                          |
//| - Contract Rollover Management                                   |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-661: Nearby Contract Price Analysis                         |
//|   RF-662: Next Month Out Price Analysis                          |
//|   RF-663: Spread Chart Calculation                               |
//|   RF-664: Premium Market Identification                          |
//|   RF-665: Carrying Charge Market Identification                  |
//|   RF-666: Spread Divergence Detection                            |
//|   RF-667: Premium Magnitude Analysis                             |
//|   RF-668: Commercial Bull Market Detection                       |
//|   RF-669: Commercial Bear Market Detection                       |
//|   RF-670: Spread as Trade Filter                                 |
//|   RF-671: Spread as Exit Signal                                  |
//|   RF-672: Contract Rollover Management                           |
//|   RF-673: Spread Historical Database                             |
//|   RF-674: Spread Divergence with PD Arrays                       |
//|   RF-675: Spread Logging                                         |
//|   RF-676: Spread Dashboard                                       |
//|   RF-677: Commodity Spread Analysis                              |
//|   RF-678: Bond Spread Analysis                                   |
//|   RF-679: Currency Futures Spread Analysis                       |
//|   RF-680: Spread as Leading Indicator                            |
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

#ifndef __CPREMIUMCARRY_MQH__
#define __CPREMIUMCARRY_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct SpreadRecord {
    datetime         timestamp;
    double           spread;
    double           nearbyPrice;
    double           nextMonthPrice;
    bool             isPremium;
};

//+------------------------------------------------------------------+
//| CLASE CPremiumCarry - Análisis de Premium vs Carrying Charge     |
//+------------------------------------------------------------------+
class CPremiumCarry {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_symbol;
    string             m_nearbySymbol;
    string             m_nextMonthSymbol;
    
    //--- Datos de contratos
    double             m_nearbyPrice;
    double             m_nextMonthPrice;
    double             m_spread;
    double             m_previousSpread;
    double             m_spreadChange;
    double             m_premiumMagnitude;
    bool               m_isPremiumMarket;
    bool               m_isCarryingCharge;
    bool               m_isSpreadDivergence;
    bool               m_isCommercialBull;
    bool               m_isCommercialBear;
    bool               m_isRolloverNear;
    datetime           m_rolloverDate;
    int                m_rolloverDays;
    
    //--- Datos históricos de spread
    SpreadRecord       m_spreadHistory[];
    int                m_spreadHistoryCount;
    int                m_maxHistorySize;
    
    //--- Constantes
    double             m_significantSpreadThreshold;
    double             m_strongPremiumThreshold;
    int                m_rolloverWarningDays;
    
    //--- Métodos privados
    bool               InitializeContracts();
    bool               UpdatePrices();
    void               CalculateSpread();
    void               DetectMarketType();
    void               DetectSpreadDivergence();
    void               DetectCommercialBias();
    void               CheckRollover();
    bool               LoadSpreadHistory();
    void               SaveSpreadHistory();
    double             GetContractPrice(string symbol);
    string             GetNearbySymbol();
    string             GetNextMonthSymbol();
    bool               IsValidContract(string symbol);
    double             CalculateSpreadPercent();
    bool               IsSymbolFutures(string symbol);
    
public:
    //--- Constructor / Destructor
    CPremiumCarry();
    ~CPremiumCarry();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Update(string symbol = "");
    void SetSymbol(string symbol);
    void Refresh();
    
    //--- RF-661: Nearby Contract Price Analysis
    double GetNearbyPrice() const { return m_nearbyPrice; }
    double GetNearbyPriceChange() const;
    
    //--- RF-662: Next Month Out Price Analysis
    double GetNextMonthPrice() const { return m_nextMonthPrice; }
    double GetNextMonthPriceChange() const;
    
    //--- RF-663: Spread Chart Calculation
    double GetSpread() const { return m_spread; }
    double GetSpreadChange() const { return m_spreadChange; }
    double GetSpreadPercent() const;
    double GetHistoricalSpread(int index) const;
    
    //--- RF-664: Premium Market Identification
    bool IsPremiumMarket() const { return m_isPremiumMarket; }
    bool IsPremiumMarketForSymbol(string symbol);
    
    //--- RF-665: Carrying Charge Market Identification
    bool IsCarryingCharge() const { return m_isCarryingCharge; }
    bool IsCarryingChargeForSymbol(string symbol);
    
    //--- RF-666: Spread Divergence Detection
    bool IsSpreadDivergence() const { return m_isSpreadDivergence; }
    bool IsSpreadDivergenceForSymbol(string symbol);
    double GetDivergenceScore() const;
    
    //--- RF-667: Premium Magnitude Analysis
    double GetPremiumMagnitude() const { return m_premiumMagnitude; }
    string GetPremiumMagnitudeLevel() const;
    bool IsStrongPremium() const;
    bool IsWeakPremium() const;
    
    //--- RF-668: Commercial Bull Market Detection
    bool IsCommercialBull() const { return m_isCommercialBull; }
    bool IsCommercialBullForSymbol(string symbol);
    
    //--- RF-669: Commercial Bear Market Detection
    bool IsCommercialBear() const { return m_isCommercialBear; }
    bool IsCommercialBearForSymbol(string symbol);
    
    //--- RF-670: Spread as Trade Filter
    bool IsTradeFilterValid(ENUM_BIAS bias) const;
    bool IsTradeFilterValidForSymbol(string symbol, ENUM_BIAS bias);
    ENUM_BIAS GetSpreadBias() const;
    
    //--- RF-671: Spread as Exit Signal
    bool IsExitSignal(ENUM_BIAS bias) const;
    bool IsExitSignalForSymbol(string symbol, ENUM_BIAS bias);
    
    //--- RF-672: Contract Rollover Management
    bool IsRolloverNear() const { return m_isRolloverNear; }
    int GetRolloverDays() const { return m_rolloverDays; }
    datetime GetRolloverDate() const { return m_rolloverDate; }
    void PerformRollover();
    
    //--- RF-673: Spread Historical Database
    int GetSpreadHistoryCount() const { return m_spreadHistoryCount; }
    SpreadRecord GetSpreadHistory(int index) const;
    double GetSpreadAverage(int periods) const;
    double GetSpreadMax(int periods) const;
    double GetSpreadMin(int periods) const;
    
    //--- RF-674: Spread Divergence with PD Arrays
    bool IsDivergenceWithPDArray(ENUM_BIAS pdBias) const;
    double GetDivergenceAlignmentScore(ENUM_BIAS bias) const;
    
    //--- RF-675: Spread Logging
    string GetSpreadLog();
    string GetSpreadLogForSymbol(string symbol);
    
    //--- RF-676: Spread Dashboard
    string GetSpreadDashboard();
    string GetSpreadDashboardForSymbol(string symbol);
    
    //--- RF-677: Commodity Spread Analysis
    double GetCommoditySpread(string symbol) const;
    bool IsCommodityPremium(string symbol) const;
    
    //--- RF-678: Bond Spread Analysis
    double GetBondSpread(string symbol) const;
    bool IsBondPremium(string symbol) const;
    
    //--- RF-679: Currency Futures Spread Analysis
    double GetCurrencyFuturesSpread(string symbol) const;
    bool IsCurrencyFuturesPremium(string symbol) const;
    
    //--- RF-680: Spread as Leading Indicator
    bool IsSpreadLeading() const;
    double GetLeadingIndicatorScore() const;
    ENUM_BIAS GetLeadingBias() const;
    
    //--- Getters
    string GetSymbol() const { return m_symbol; }
    string GetNearbySymbol() const { return m_nearbySymbol; }
    string GetNextMonthSymbol() const { return m_nextMonthSymbol; }
    string GetSummary();
    string GetReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CPremiumCarry::CPremiumCarry() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_nearbySymbol = "";
    m_nextMonthSymbol = "";
    m_nearbyPrice = 0;
    m_nextMonthPrice = 0;
    m_spread = 0;
    m_previousSpread = 0;
    m_spreadChange = 0;
    m_premiumMagnitude = 0;
    m_isPremiumMarket = false;
    m_isCarryingCharge = false;
    m_isSpreadDivergence = false;
    m_isCommercialBull = false;
    m_isCommercialBear = false;
    m_isRolloverNear = false;
    m_rolloverDate = 0;
    m_rolloverDays = 0;
    m_spreadHistoryCount = 0;
    m_maxHistorySize = 1000;
    m_significantSpreadThreshold = 0.5;
    m_strongPremiumThreshold = 2.0;
    m_rolloverWarningDays = 5;
    ArrayResize(m_spreadHistory, 0);
}

//--- Destructor
CPremiumCarry::~CPremiumCarry() {
    Deinit();
}

//--- Inicialización
bool CPremiumCarry::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CPremiumCarry::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Cargar historial
    LoadSpreadHistory();
    
    m_isInitialized = true;
    m_utils.LogInfo("CPremiumCarry inicializado correctamente");
    return true;
}

//--- Desinicialización
void CPremiumCarry::Deinit() {
    SaveSpreadHistory();
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    ArrayResize(m_spreadHistory, 0);
}

//--- Establecer símbolo
void CPremiumCarry::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            InitializeContracts();
            UpdatePrices();
            CalculateSpread();
            DetectMarketType();
            DetectSpreadDivergence();
            DetectCommercialBias();
            CheckRollover();
        }
    }
}

//--- Inicializar contratos
bool CPremiumCarry::InitializeContracts() {
    //--- Para futuros, el nearby es el contrato actual
    //--- Para Forex, usar el símbolo directamente
    if(!IsSymbolFutures(m_symbol)) {
        m_nearbySymbol = m_symbol;
        m_nextMonthSymbol = m_symbol;
        return true;
    }
    
    //--- Para futuros: determinar símbolos de contrato
    m_nearbySymbol = m_symbol + "M1";  // Ejemplo
    m_nextMonthSymbol = m_symbol + "M2";
    
    return true;
}

//--- Verificar si es símbolo de futuros
bool CPremiumCarry::IsSymbolFutures(string symbol) {
    //--- Placeholder: asumir que símbolos con "FUT" son futuros
    return StringFind(symbol, "FUT") != -1;
}

//--- RF-661/662: Actualizar precios de contratos
bool CPremiumCarry::UpdatePrices() {
    m_nearbyPrice = GetContractPrice(m_nearbySymbol);
    m_nextMonthPrice = GetContractPrice(m_nextMonthSymbol);
    
    return (m_nearbyPrice > 0 && m_nextMonthPrice > 0);
}

//--- Obtener precio de contrato
double CPremiumCarry::GetContractPrice(string symbol) {
    if(symbol == m_symbol) {
        return SymbolInfoDouble(symbol, SYMBOL_BID);
    }
    return SymbolInfoDouble(symbol, SYMBOL_BID);
}

//--- RF-663: Calcular Spread
void CPremiumCarry::CalculateSpread() {
    m_previousSpread = m_spread;
    m_spread = m_nearbyPrice - m_nextMonthPrice;
    m_spreadChange = m_spread - m_previousSpread;
    m_premiumMagnitude = MathAbs(m_spread);
}

//--- RF-663: Calcular Spread en porcentaje
double CPremiumCarry::GetSpreadPercent() const {
    if(m_nextMonthPrice == 0) return 0;
    return (m_spread / m_nextMonthPrice) * 100.0;
}

//--- RF-664/665: Detectar tipo de mercado
void CPremiumCarry::DetectMarketType() {
    m_isPremiumMarket = m_spread > 0;
    m_isCarryingCharge = m_spread < 0;
}

//--- RF-664: Verificar Premium Market
bool CPremiumCarry::IsPremiumMarketForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-665: Verificar Carrying Charge
bool CPremiumCarry::IsCarryingChargeForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-666: Detectar Divergencia de Spread
void CPremiumCarry::DetectSpreadDivergence() {
    //--- Divergencia: precio y spread se mueven en direcciones opuestas
    double priceChange = 0;
    if(m_spreadHistoryCount > 0) {
        double prevPrice = m_spreadHistory[m_spreadHistoryCount - 1].nearbyPrice;
        if(prevPrice > 0) {
            priceChange = (m_nearbyPrice - prevPrice) / prevPrice * 100;
        }
    }
    
    bool priceUp = priceChange > 0.5;
    bool spreadUp = m_spreadChange > 0.1;
    
    m_isSpreadDivergence = (priceUp && !spreadUp) || (!priceUp && spreadUp);
}

//--- RF-666: Verificar Divergencia
bool CPremiumCarry::IsSpreadDivergenceForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-666: Obtener Score de Divergencia
double CPremiumCarry::GetDivergenceScore() const {
    if(!m_isSpreadDivergence) return 0;
    return MathMin(MathAbs(m_spreadChange) * 10, 100);
}

//--- RF-667: Análisis de Magnitud de Premium
string CPremiumCarry::GetPremiumMagnitudeLevel() const {
    if(m_isCarryingCharge) return "CARRYING_CHARGE";
    if(m_premiumMagnitude > m_strongPremiumThreshold) return "STRONG_PREMIUM";
    if(m_premiumMagnitude > m_significantSpreadThreshold) return "MODERATE_PREMIUM";
    return "WEAK_PREMIUM";
}

bool CPremiumCarry::IsStrongPremium() const {
    return m_isPremiumMarket && m_premiumMagnitude > m_strongPremiumThreshold;
}

bool CPremiumCarry::IsWeakPremium() const {
    return m_isPremiumMarket && m_premiumMagnitude <= m_significantSpreadThreshold;
}

//--- RF-668/669: Detectar Bias Comercial
void CPremiumCarry::DetectCommercialBias() {
    //--- Commercial Bull: Premium aumentando
    //--- Commercial Bear: Premium disminuyendo
    m_isCommercialBull = m_isPremiumMarket && m_spreadChange > 0;
    m_isCommercialBear = m_isCarryingCharge && m_spreadChange < 0;
}

//--- RF-668: Verificar Commercial Bull
bool CPremiumCarry::IsCommercialBullForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-669: Verificar Commercial Bear
bool CPremiumCarry::IsCommercialBearForSymbol(string symbol) {
    //--- Placeholder
    return false;
}

//--- RF-670: Spread como Filtro de Trading
bool CPremiumCarry::IsTradeFilterValid(ENUM_BIAS bias) const {
    if(bias == BIAS_BULLISH) {
        return m_isPremiumMarket && !m_isCarryingCharge;
    }
    if(bias == BIAS_BEARISH) {
        return m_isCarryingCharge && !m_isPremiumMarket;
    }
    return false;
}

bool CPremiumCarry::IsTradeFilterValidForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder
    return false;
}

ENUM_BIAS CPremiumCarry::GetSpreadBias() const {
    if(m_isPremiumMarket) return BIAS_BULLISH;
    if(m_isCarryingCharge) return BIAS_BEARISH;
    return BIAS_NEUTRAL;
}

//--- RF-671: Spread como Señal de Salida
bool CPremiumCarry::IsExitSignal(ENUM_BIAS bias) const {
    if(bias == BIAS_BULLISH && m_isCarryingCharge) return true;
    if(bias == BIAS_BEARISH && m_isPremiumMarket) return true;
    return false;
}

bool CPremiumCarry::IsExitSignalForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder
    return false;
}

//--- RF-672: Gestión de Rollover
void CPremiumCarry::CheckRollover() {
    //--- Detectar rollover basado en fecha
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    //--- Rollover típico al final del mes
    int daysInMonth = 30;
    if(dt.day > 25) {
        m_rolloverDays = daysInMonth - dt.day + 1;
        m_isRolloverNear = m_rolloverDays <= m_rolloverWarningDays;
    } else {
        m_rolloverDays = daysInMonth - dt.day;
        m_isRolloverNear = false;
    }
    
    m_rolloverDate = TimeCurrent() + m_rolloverDays * 86400;
}

void CPremiumCarry::PerformRollover() {
    if(!m_isRolloverNear) return;
    
    //--- Actualizar símbolos de contrato
    m_nearbySymbol = m_nextMonthSymbol;
    //--- Buscar siguiente mes
    //--- Placeholder: actualización manual
    m_utils.LogInfo("Rollover performed for " + m_symbol);
}

//--- RF-673: Base de Datos Histórica
bool CPremiumCarry::LoadSpreadHistory() {
    //--- Placeholder: cargar desde archivo
    ArrayResize(m_spreadHistory, 0);
    m_spreadHistoryCount = 0;
    return true;
}

void CPremiumCarry::SaveSpreadHistory() {
    //--- Placeholder: guardar en archivo
}

double CPremiumCarry::GetSpreadAverage(int periods) const {
    if(periods <= 0 || m_spreadHistoryCount == 0) return 0;
    
    int count = MathMin(periods, m_spreadHistoryCount);
    double sum = 0;
    for(int i = m_spreadHistoryCount - count; i < m_spreadHistoryCount; i++) {
        sum += m_spreadHistory[i].spread;
    }
    return sum / count;
}

double CPremiumCarry::GetSpreadMax(int periods) const {
    if(periods <= 0 || m_spreadHistoryCount == 0) return 0;
    
    int count = MathMin(periods, m_spreadHistoryCount);
    double maxVal = m_spreadHistory[m_spreadHistoryCount - count].spread;
    for(int i = m_spreadHistoryCount - count + 1; i < m_spreadHistoryCount; i++) {
        if(m_spreadHistory[i].spread > maxVal) maxVal = m_spreadHistory[i].spread;
    }
    return maxVal;
}

double CPremiumCarry::GetSpreadMin(int periods) const {
    if(periods <= 0 || m_spreadHistoryCount == 0) return 0;
    
    int count = MathMin(periods, m_spreadHistoryCount);
    double minVal = m_spreadHistory[m_spreadHistoryCount - count].spread;
    for(int i = m_spreadHistoryCount - count + 1; i < m_spreadHistoryCount; i++) {
        if(m_spreadHistory[i].spread < minVal) minVal = m_spreadHistory[i].spread;
    }
    return minVal;
}

//--- RF-674: Divergencia con PD Arrays
bool CPremiumCarry::IsDivergenceWithPDArray(ENUM_BIAS pdBias) const {
    ENUM_BIAS spreadBias = GetSpreadBias();
    return spreadBias == pdBias && m_isSpreadDivergence;
}

double CPremiumCarry::GetDivergenceAlignmentScore(ENUM_BIAS bias) const {
    if(GetSpreadBias() != bias) return 0;
    return MathMin(MathAbs(m_spreadChange) * 10, 100);
}

//--- RF-675: Spread Logging
string CPremiumCarry::GetSpreadLog() {
    string log = "=== SPREAD LOG ===\n";
    log += "Symbol: " + m_symbol + "\n";
    log += "Nearby: " + DoubleToString(m_nearbyPrice, 5) + "\n";
    log += "Next Month: " + DoubleToString(m_nextMonthPrice, 5) + "\n";
    log += "Spread: " + DoubleToString(m_spread, 5) + "\n";
    log += "Spread Change: " + DoubleToString(m_spreadChange, 5) + "\n";
    log += "Market Type: " + (m_isPremiumMarket ? "PREMIUM" : 
                              (m_isCarryingCharge ? "CARRYING_CHARGE" : "NEUTRAL")) + "\n";
    log += "Commercial Bias: " + (m_isCommercialBull ? "BULL" : 
                                  (m_isCommercialBear ? "BEAR" : "NEUTRAL")) + "\n";
    log += "Divergence: " + (m_isSpreadDivergence ? "YES" : "NO") + "\n";
    log += "Rollover in: " + IntegerToString(m_rolloverDays) + " days\n";
    return log;
}

string CPremiumCarry::GetSpreadLogForSymbol(string symbol) {
    //--- Placeholder
    return "";
}

//--- RF-676: Spread Dashboard
string CPremiumCarry::GetSpreadDashboard() {
    string dash = "=== SPREAD DASHBOARD ===\n";
    dash += "Symbol: " + m_symbol + "\n";
    dash += "Spread: " + DoubleToString(m_spread, 5) + "\n";
    dash += "Market: " + (m_isPremiumMarket ? "PREMIUM" : 
                          (m_isCarryingCharge ? "CARRYING CHARGE" : "NEUTRAL")) + "\n";
    dash += "Magnitude: " + GetPremiumMagnitudeLevel() + "\n";
    dash += "Bias: " + (GetSpreadBias() == BIAS_BULLISH ? "BULLISH" : 
                        (GetSpreadBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    dash += "Divergence: " + (m_isSpreadDivergence ? "⚠️ YES" : "✅ NO") + "\n";
    dash += "Commercial: " + (m_isCommercialBull ? "BULL" : 
                              (m_isCommercialBear ? "BEAR" : "NEUTRAL")) + "\n";
    dash += "Rollover: " + IntegerToString(m_rolloverDays) + " days\n";
    return dash;
}

string CPremiumCarry::GetSpreadDashboardForSymbol(string symbol) {
    //--- Placeholder
    return "";
}

//--- RF-677: Commodity Spread Analysis
double CPremiumCarry::GetCommoditySpread(string symbol) const {
    //--- Placeholder
    return 0;
}

bool CPremiumCarry::IsCommodityPremium(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-678: Bond Spread Analysis
double CPremiumCarry::GetBondSpread(string symbol) const {
    //--- Placeholder
    return 0;
}

bool CPremiumCarry::IsBondPremium(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-679: Currency Futures Spread Analysis
double CPremiumCarry::GetCurrencyFuturesSpread(string symbol) const {
    //--- Placeholder
    return 0;
}

bool CPremiumCarry::IsCurrencyFuturesPremium(string symbol) const {
    //--- Placeholder
    return false;
}

//--- RF-680: Spread como Indicador Adelantado
bool CPremiumCarry::IsSpreadLeading() const {
    //--- El spread adelanta al precio en 1-2 semanas
    return m_isSpreadDivergence;
}

double CPremiumCarry::GetLeadingIndicatorScore() const {
    if(!IsSpreadLeading()) return 0;
    return 70.0;
}

ENUM_BIAS CPremiumCarry::GetLeadingBias() const {
    if(m_isPremiumMarket && m_isSpreadDivergence) return BIAS_BEARISH;
    if(m_isCarryingCharge && m_isSpreadDivergence) return BIAS_BULLISH;
    return BIAS_NEUTRAL;
}

//--- RF-661/662: Cambios de precio
double CPremiumCarry::GetNearbyPriceChange() const {
    if(m_spreadHistoryCount < 2) return 0;
    double prev = m_spreadHistory[m_spreadHistoryCount - 2].nearbyPrice;
    if(prev == 0) return 0;
    return (m_nearbyPrice - prev) / prev * 100.0;
}

double CPremiumCarry::GetNextMonthPriceChange() const {
    if(m_spreadHistoryCount < 2) return 0;
    double prev = m_spreadHistory[m_spreadHistoryCount - 2].nextMonthPrice;
    if(prev == 0) return 0;
    return (m_nextMonthPrice - prev) / prev * 100.0;
}

//--- RF-663: Spread Histórico
double CPremiumCarry::GetHistoricalSpread(int index) const {
    if(index < 0 || index >= m_spreadHistoryCount) return 0;
    return m_spreadHistory[index].spread;
}

//--- Actualizar
void CPremiumCarry::Update(string symbol = "") {
    if(symbol != "") SetSymbol(symbol);
    if(!m_isInitialized) return;
    
    UpdatePrices();
    CalculateSpread();
    DetectMarketType();
    DetectSpreadDivergence();
    DetectCommercialBias();
    CheckRollover();
    
    //--- Guardar en histórico
    if(m_spreadHistoryCount < m_maxHistorySize) {
        int idx = m_spreadHistoryCount;
        ArrayResize(m_spreadHistory, m_spreadHistoryCount + 1);
        m_spreadHistory[idx].timestamp = TimeCurrent();
        m_spreadHistory[idx].spread = m_spread;
        m_spreadHistory[idx].nearbyPrice = m_nearbyPrice;
        m_spreadHistory[idx].nextMonthPrice = m_nextMonthPrice;
        m_spreadHistory[idx].isPremium = m_isPremiumMarket;
        m_spreadHistoryCount++;
    }
}

//--- Refresh
void CPremiumCarry::Refresh() {
    Update(m_symbol);
}

//--- Resumen
string CPremiumCarry::GetSummary() {
    string summary = "=== PREMIUM/CARRY SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Spread: " + DoubleToString(m_spread, 5) + "\n";
    summary += "Market: " + (m_isPremiumMarket ? "PREMIUM" : 
                             (m_isCarryingCharge ? "CARRYING CHARGE" : "NEUTRAL")) + "\n";
    summary += "Magnitude: " + GetPremiumMagnitudeLevel() + "\n";
    summary += "Bias: " + (GetSpreadBias() == BIAS_BULLISH ? "BULLISH" : 
                           (GetSpreadBias() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Divergence: " + (m_isSpreadDivergence ? "YES" : "NO") + "\n";
    summary += "Commercial: " + (m_isCommercialBull ? "BULL" : 
                                 (m_isCommercialBear ? "BEAR" : "NEUTRAL")) + "\n";
    summary += "Rollover in: " + IntegerToString(m_rolloverDays) + " days\n";
    return summary;
}

//--- Reporte
string CPremiumCarry::GetReport() {
    string report = "=== PREMIUM/CARRY REPORT ===\n";
    report += "Nearby Price: " + DoubleToString(m_nearbyPrice, 5) + "\n";
    report += "Next Month Price: " + DoubleToString(m_nextMonthPrice, 5) + "\n";
    report += "Spread: " + DoubleToString(m_spread, 5) + "\n";
    report += "Spread Change: " + DoubleToString(m_spreadChange, 5) + "\n";
    report += "Spread %: " + DoubleToString(GetSpreadPercent(), 2) + "%\n";
    report += "Premium Magnitude: " + DoubleToString(m_premiumMagnitude, 5) + "\n";
    report += "Historical Avg (10): " + DoubleToString(GetSpreadAverage(10), 5) + "\n";
    report += "Historical Max (10): " + DoubleToString(GetSpreadMax(10), 5) + "\n";
    report += "Historical Min (10): " + DoubleToString(GetSpreadMin(10), 5) + "\n";
    report += "Divergence Score: " + DoubleToString(GetDivergenceScore(), 1) + "\n";
    report += "Leading Score: " + DoubleToString(GetLeadingIndicatorScore(), 1) + "\n";
    report += "==============================";
    return report;
}

#endif // __CPREMIUMCARRY_MQH__