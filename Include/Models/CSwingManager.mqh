//+------------------------------------------------------------------+
//|                                                    CSwingManager.mqh |
//|                     HunterIPDA Pro EA - v1.8 - Módulo Models       |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona las posiciones de Swing Trading:            |
//| - Toma de profits parciales (20-30% al 25% del objetivo)         |
//| - Reentradas al 50% del objetivo                                 |
//| - Trailing stop ajustado al 75% del objetivo                     |
//| - Detección de stop runs en swing trading                        |
//|                                                                  |
//| RFs asociados: RF-382 a RF-385                                  |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                      |
//|   - CUtils: Funciones auxiliares                                |
//|   - CConfig: Configuración                                      |
//|   - CExecutor: Ejecución de órdenes                             |
//|   - CRiskManager: Gestión de riesgo                             |
//|   - CEntryManager: Gestión de entradas (reentradas)             |
//|                                                                  |
//| Versión: 1.2                                                     |
//| Fecha: 23/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 23/07/2026  | Versión inicial del módulo               |
//| 1.1     | 23/07/2026  | Movido ENUM_SWING_PHASE antes de        |
//|         |             | SwingTradeState para evitar error        |
//| 1.2     | 23/07/2026  | Corregidos métodos para usar índices     |
//|         |             | en lugar de punteros/referencias         |
//+------------------------------------------------------------------+

#ifndef __CSWINGMANAGER_MQH__
#define __CSWINGMANAGER_MQH__

//--- Includes necesarios
#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Execution/CExecutor.mqh"
#include "../Execution/CRiskManager.mqh"
#include "../Execution/CEntryManager.mqh"

//+------------------------------------------------------------------+
//| ENUM: Fases de Swing Trade                                       |
//+------------------------------------------------------------------+
enum ENUM_SWING_PHASE {
    SWING_PHASE_INITIAL,          // Fase inicial (sin toma de profits)
    SWING_PHASE_25_PERCENT,       // Fase: tomó profit al 25%
    SWING_PHASE_REENTRY,          // Fase: reentrada al 50%
    SWING_PHASE_75_PERCENT,       // Fase: trailing ajustado al 75%
    SWING_PHASE_COMPLETED,        // Fase: completado
    SWING_PHASE_STOPPED           // Fase: stop alcanzado
};

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| RF-382/383/384/385: Estructura de estado de Swing Trade          |
//+------------------------------------------------------------------+
struct SwingTradeState {
    ulong            ticket;              // Ticket de la posición
    string           symbol;              // Símbolo
    ENUM_BIAS        bias;                // Dirección de la operación
    double           entryPrice;          // Precio de entrada
    double           stopLoss;            // Stop Loss inicial
    double           takeProfit;          // Take Profit inicial
    double           targetPrice;         // Precio objetivo final
    
    double           profit25Percent;     // Precio al 25% del objetivo
    double           profit50Percent;     // Precio al 50% del objetivo
    double           profit75Percent;     // Precio al 75% del objetivo
    
    bool             hasTaken25Percent;   // Ya tomó profit al 25%
    bool             hasReentered50;      // Ya reentró al 50%
    bool             hasAdjustedTrail;    // Ya ajustó trailing al 75%
    
    double           reentryPrice;        // Precio de reentrada (si aplica)
    double           reentryStop;         // Stop Loss de reentrada
    double           reentryTarget;       // Target de reentrada
    
    double           currentTrailStop;    // Trailing stop actual
    double           trailLookback;       // Lookback actual del trailing stop
    
    ENUM_SWING_PHASE phase;               // Fase actual del swing trade
    datetime         lastUpdate;          // Última actualización
};

//+------------------------------------------------------------------+
//| RF-385: Estructura para detección de Stop Runs                  |
//+------------------------------------------------------------------+
struct StopRunDetection {
    bool             isStopRun;           // Stop run detectado
    ENUM_BIAS        stopRunBias;         // Dirección del stop run
    double           stopRunLevel;        // Nivel del stop run
    double           equilibriumLevel;    // Nivel de equilibrio del rango
    double           distanceToEquil;     // Distancia al equilibrio
    bool             isNearEquilibrium;   // Está cerca del equilibrio
    double           stopRunStrength;     // Fuerza del stop run (0-100)
    datetime         detectionTime;       // Tiempo de detección
    string           description;         // Descripción
};

//+------------------------------------------------------------------+
//| CLASE CSwingManager                                              |
//+------------------------------------------------------------------+
class CSwingManager {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CUtils*            m_utils;
    CExecutor*         m_executor;
    CRiskManager*      m_riskManager;
    CEntryManager*     m_entryManager;
    
    bool               m_isInitialized;
    
    //--- Configuración
    double             m_profit25Pct;          // % a cerrar al 25%
    bool               m_reentry50Enabled;     // Reentrada al 50% activada
    double             m_trail75Pct;           // % de trailing al 75%
    double             m_stopRunThreshold;     // Umbral para stop run
    
    //--- Estado de swing trades activos
    SwingTradeState    m_swingTrades[];
    int                m_swingTradeCount;
    int                m_maxSwingTrades;
    
    //--- Detección de stop runs
    StopRunDetection   m_stopRunDetection;
    
    //--- Métodos privados
    bool               ValidateDependencies();
    int                FindSwingTrade(ulong ticket);
    int                FindSwingTradeBySymbol(string symbol);
    bool               IsValidSwingTrade(ulong ticket);
    bool               IsSwingTradeActive(ulong ticket);
    
    //+------------------------------------------------------------------+
    //| RF-382: Gestión de toma de profit al 25% + Breakeven             |
    //+------------------------------------------------------------------+
    bool               Manage25PercentProfit(int idx);
    
    //+------------------------------------------------------------------+
    //| RF-383: Reentrada al 50% del Objetivo                            |
    //+------------------------------------------------------------------+
    bool               Manage50PercentReentry(int idx);
    
    //+------------------------------------------------------------------+
    //| RF-384: Trailing Stop Ajustado al 75% del Objetivo               |
    //+------------------------------------------------------------------+
    bool               Manage75PercentTrail(int idx);
    
    //+------------------------------------------------------------------+
    //| RF-385: Detección de Stop Runs en Swing Trading                  |
    //+------------------------------------------------------------------+
    StopRunDetection   DetectStopRun(string symbol, ENUM_BIAS bias, double entryPrice, double targetPrice);
    void               HandleStopRun(int idx, StopRunDetection &detection);
    
public:
    //--- Constructor / Destructor
    CSwingManager();
    ~CSwingManager();
    
    //+------------------------------------------------------------------+
    //| RF-382/383/384/385: Inicialización del módulo                    |
    //+------------------------------------------------------------------+
    bool Init(CConfig* config, CUtils* utils, CExecutor* executor,
              CRiskManager* riskManager, CEntryManager* entryManager);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //+------------------------------------------------------------------+
    //| RF-382/383/384/385: Gestión principal de Swing Trade             |
    //+------------------------------------------------------------------+
    bool ManageSwingTrade(ulong ticket);
    void ManageAllSwingTrades();
    
    //--- Registro y seguimiento de swing trades
    bool RegisterSwingTrade(ulong ticket, string symbol, ENUM_BIAS bias,
                            double entryPrice, double stopLoss, double takeProfit);
    bool UpdateSwingTrade(ulong ticket, double currentPrice);
    bool CloseSwingTrade(ulong ticket);
    bool IsSwingTradeRegistered(ulong ticket);
    
    //--- RF-382: Gestión de toma de profit al 25% + Breakeven
    bool ShouldTake25PercentProfit(ulong ticket);
    bool Take25PercentProfit(ulong ticket);
    
    //--- RF-383: Reentrada al 50% del Objetivo
    bool ShouldReenter50Percent(ulong ticket);
    bool Reenter50Percent(ulong ticket);
    
    //--- RF-384: Trailing Stop al 75% del Objetivo
    bool ShouldAdjust75PercentTrail(ulong ticket);
    bool Adjust75PercentTrail(ulong ticket);
    
    //--- RF-385: Detección de Stop Runs
    StopRunDetection GetStopRunDetection(ulong ticket);
    bool IsStopRunDetected(ulong ticket);
    double GetStopRunDistance(ulong ticket);
    
    //--- Getters
    SwingTradeState GetSwingTrade(ulong ticket);
    int GetActiveSwingTradeCount() const { return m_swingTradeCount; }
    double GetProfit25Pct() const { return m_profit25Pct; }
    bool IsReentry50Enabled() const { return m_reentry50Enabled; }
    double GetTrail75Pct() const { return m_trail75Pct; }
    
    //--- Reportes
    string GetSwingTradeReport(ulong ticket);
    string GetAllSwingTradesReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CSwingManager::CSwingManager() {
    m_config = NULL;
    m_utils = NULL;
    m_executor = NULL;
    m_riskManager = NULL;
    m_entryManager = NULL;
    m_isInitialized = false;
    m_profit25Pct = 25.0;
    m_reentry50Enabled = true;
    m_trail75Pct = 75.0;
    m_stopRunThreshold = 1.5;
    m_swingTradeCount = 0;
    m_maxSwingTrades = 10;
    ArrayResize(m_swingTrades, m_maxSwingTrades);
    ZeroMemory(m_stopRunDetection);
}

//--- Destructor
CSwingManager::~CSwingManager() {
    Deinit();
}

//+------------------------------------------------------------------+
//| RF-382/383/384/385: Inicialización                               |
//+------------------------------------------------------------------+
bool CSwingManager::Init(CConfig* config, CUtils* utils, CExecutor* executor,
                          CRiskManager* riskManager, CEntryManager* entryManager) {
    if(config == NULL || utils == NULL || executor == NULL || 
       riskManager == NULL || entryManager == NULL) {
        Print("CSwingManager::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_executor = executor;
    m_riskManager = riskManager;
    m_entryManager = entryManager;
    
    if(!ValidateDependencies()) {
        Print("CSwingManager::Init - Error: Validación de dependencias fallida");
        return false;
    }
    
    //--- Cargar configuración
    SConfig cfg = m_config.GetConfig();
    m_profit25Pct = cfg.swingProfit25Pct;
    m_reentry50Enabled = cfg.swingReentry50Pct;
    m_maxSwingTrades = cfg.maxSwingTradesPerYear;
    ArrayResize(m_swingTrades, m_maxSwingTrades);
    m_swingTradeCount = 0;
    
    m_isInitialized = true;
    Print("CSwingManager inicializado correctamente");
    return true;
}

//--- Desinicialización
void CSwingManager::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_executor = NULL;
    m_riskManager = NULL;
    m_entryManager = NULL;
    m_isInitialized = false;
    m_swingTradeCount = 0;
    ArrayResize(m_swingTrades, 0);
}

//--- Validación de dependencias
bool CSwingManager::ValidateDependencies() {
    if(m_config == NULL || m_utils == NULL || m_executor == NULL ||
       m_riskManager == NULL || m_entryManager == NULL) {
        return false;
    }
    return true;
}

//--- Buscar swing trade por ticket
int CSwingManager::FindSwingTrade(ulong ticket) {
    for(int i = 0; i < m_swingTradeCount; i++) {
        if(m_swingTrades[i].ticket == ticket) {
            return i;
        }
    }
    return -1;
}

//--- Buscar swing trade por símbolo
int CSwingManager::FindSwingTradeBySymbol(string symbol) {
    for(int i = 0; i < m_swingTradeCount; i++) {
        if(m_swingTrades[i].symbol == symbol) {
            return i;
        }
    }
    return -1;
}

//--- Verificar si es un swing trade válido
bool CSwingManager::IsValidSwingTrade(ulong ticket) {
    return FindSwingTrade(ticket) >= 0;
}

//--- Verificar si el swing trade está activo
bool CSwingManager::IsSwingTradeActive(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    return (m_swingTrades[idx].phase != SWING_PHASE_COMPLETED &&
            m_swingTrades[idx].phase != SWING_PHASE_STOPPED);
}

//+------------------------------------------------------------------+
//| RF-382: Gestión de toma de profit al 25% + Breakeven             |
//+------------------------------------------------------------------+
bool CSwingManager::Manage25PercentProfit(int idx) {
    if(!m_isInitialized) {
        Print("CSwingManager::Manage25PercentProfit - Error: Módulo no inicializado");
        return false;
    }
    
    if(idx < 0 || idx >= m_swingTradeCount) return false;
    
    if(m_swingTrades[idx].hasTaken25Percent) {
        return true;
    }
    
    if(m_swingTrades[idx].phase == SWING_PHASE_COMPLETED || 
       m_swingTrades[idx].phase == SWING_PHASE_STOPPED) {
        return false;
    }
    
    //--- Obtener precio actual
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    //--- Verificar si alcanzó el 25% del objetivo
    bool reached25Percent = false;
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        reached25Percent = (currentPrice >= m_swingTrades[idx].profit25Percent);
    } else {
        reached25Percent = (currentPrice <= m_swingTrades[idx].profit25Percent);
    }
    
    if(!reached25Percent) {
        return false;
    }
    
    //--- Tomar profit al 25%
    if(m_executor != NULL) {
        if(m_executor.ClosePartialPosition(m_swingTrades[idx].ticket, m_profit25Pct)) {
            m_swingTrades[idx].hasTaken25Percent = true;
            m_swingTrades[idx].phase = SWING_PHASE_25_PERCENT;
            m_swingTrades[idx].lastUpdate = TimeCurrent();
            
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::Manage25PercentProfit - " +
                               "Tomado " + DoubleToString(m_profit25Pct, 1) + "% profit al 25% del objetivo");
            }
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| RF-383: Reentrada al 50% del Objetivo                            |
//+------------------------------------------------------------------+
bool CSwingManager::Manage50PercentReentry(int idx) {
    if(!m_isInitialized) {
        Print("CSwingManager::Manage50PercentReentry - Error: Módulo no inicializado");
        return false;
    }
    
    if(idx < 0 || idx >= m_swingTradeCount) return false;
    
    if(!m_reentry50Enabled) {
        return true;
    }
    
    if(m_swingTrades[idx].hasReentered50) {
        return true;
    }
    
    if(!m_swingTrades[idx].hasTaken25Percent) {
        return false;
    }
    
    if(m_swingTrades[idx].phase == SWING_PHASE_COMPLETED || 
       m_swingTrades[idx].phase == SWING_PHASE_STOPPED) {
        return false;
    }
    
    //--- Obtener precio actual
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    //--- Verificar si el precio retrocedió al 50% del objetivo
    bool reached50Percent = false;
    double point = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_POINT);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        reached50Percent = (currentPrice <= m_swingTrades[idx].profit50Percent + 10 * point);
    } else {
        reached50Percent = (currentPrice >= m_swingTrades[idx].profit50Percent - 10 * point);
    }
    
    if(!reached50Percent) {
        return false;
    }
    
    //--- Ejecutar reentrada usando ExecuteSignal
    if(m_executor != NULL && m_entryManager != NULL) {
        Signal signal;
        ZeroMemory(signal);
        signal.symbol = m_swingTrades[idx].symbol;
        signal.model = MODEL_SWING;
        signal.bias = m_swingTrades[idx].bias;
        signal.entryType = (m_swingTrades[idx].bias == BIAS_BULLISH) ? ENTRY_BUY_STOP : ENTRY_SELL_STOP;
        signal.entryPrice = currentPrice;
        signal.stopLoss = m_swingTrades[idx].stopLoss;
        signal.takeProfit = m_swingTrades[idx].takeProfit;
        signal.risk = 0.5;
        signal.rrRatio = 3.0;
        signal.isQualified = true;
        signal.signalTime = TimeCurrent();
        
        bool reentrySuccess = m_executor.ExecuteSignal(signal);
        
        if(reentrySuccess) {
            m_swingTrades[idx].hasReentered50 = true;
            m_swingTrades[idx].phase = SWING_PHASE_REENTRY;
            m_swingTrades[idx].reentryPrice = currentPrice;
            m_swingTrades[idx].reentryStop = m_swingTrades[idx].stopLoss;
            m_swingTrades[idx].reentryTarget = m_swingTrades[idx].takeProfit;
            m_swingTrades[idx].lastUpdate = TimeCurrent();
            
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::Manage50PercentReentry - " +
                               "Reentrada ejecutada al 50% del objetivo");
            }
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| RF-384: Trailing Stop Ajustado al 75% del Objetivo               |
//+------------------------------------------------------------------+
bool CSwingManager::Manage75PercentTrail(int idx) {
    if(!m_isInitialized) {
        Print("CSwingManager::Manage75PercentTrail - Error: Módulo no inicializado");
        return false;
    }
    
    if(idx < 0 || idx >= m_swingTradeCount) return false;
    
    if(m_swingTrades[idx].hasAdjustedTrail) {
        return true;
    }
    
    if(!m_swingTrades[idx].hasTaken25Percent) {
        return false;
    }
    
    if(m_swingTrades[idx].phase == SWING_PHASE_COMPLETED || 
       m_swingTrades[idx].phase == SWING_PHASE_STOPPED) {
        return false;
    }
    
    //--- Obtener precio actual
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    //--- Verificar si alcanzó el 75% del objetivo
    bool reached75Percent = false;
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        reached75Percent = (currentPrice >= m_swingTrades[idx].profit75Percent);
    } else {
        reached75Percent = (currentPrice <= m_swingTrades[idx].profit75Percent);
    }
    
    if(!reached75Percent) {
        return false;
    }
    
    //--- Ajustar trailing stop al 75% del objetivo
    if(m_executor != NULL) {
        double trailLevel;
        double point = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_POINT);
        if(m_swingTrades[idx].bias == BIAS_BULLISH) {
            trailLevel = m_swingTrades[idx].profit75Percent - 20 * point;
        } else {
            trailLevel = m_swingTrades[idx].profit75Percent + 20 * point;
        }
        
        if(m_executor.ModifyPositionSL(m_swingTrades[idx].ticket, trailLevel)) {
            m_swingTrades[idx].hasAdjustedTrail = true;
            m_swingTrades[idx].phase = SWING_PHASE_75_PERCENT;
            m_swingTrades[idx].currentTrailStop = trailLevel;
            m_swingTrades[idx].lastUpdate = TimeCurrent();
            
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::Manage75PercentTrail - " +
                               "Trailing stop ajustado al 75% del objetivo");
            }
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| RF-385: HandleStopRun                                            |
//+------------------------------------------------------------------+
void CSwingManager::HandleStopRun(int idx, StopRunDetection &detection) {
    if(idx < 0 || idx >= m_swingTradeCount) return;
    
    if(!detection.isStopRun) return;
    
    //--- Si el stop run es en contra de la posición, ajustar stop loss
    if(detection.stopRunBias != m_swingTrades[idx].bias) {
        if(m_executor != NULL) {
            //--- Mover stop loss al nivel de equilibrio
            double newStop = detection.equilibriumLevel;
            double point = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_POINT);
            if(m_swingTrades[idx].bias == BIAS_BULLISH) {
                newStop = detection.equilibriumLevel - 10 * point;
            } else {
                newStop = detection.equilibriumLevel + 10 * point;
            }
            
            if(m_executor.ModifyPositionSL(m_swingTrades[idx].ticket, newStop)) {
                m_swingTrades[idx].currentTrailStop = newStop;
                m_swingTrades[idx].lastUpdate = TimeCurrent();
                
                if(m_utils != NULL) {
                    m_utils.LogInfo("CSwingManager::HandleStopRun - " +
                                   "Stop loss ajustado por stop run en equilibrio");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| RF-382/383/384/385: Gestión principal de Swing Trade             |
//+------------------------------------------------------------------+
bool CSwingManager::ManageSwingTrade(ulong ticket) {
    if(!m_isInitialized) {
        Print("CSwingManager::ManageSwingTrade - Error: Módulo no inicializado");
        return false;
    }
    
    int idx = FindSwingTrade(ticket);
    if(idx < 0) {
        Print("CSwingManager::ManageSwingTrade - Error: Swing trade no encontrado");
        return false;
    }
    
    //--- Verificar si la posición aún está abierta
    if(!PositionSelectByTicket(ticket)) {
        m_swingTrades[idx].phase = SWING_PHASE_COMPLETED;
        m_swingTrades[idx].lastUpdate = TimeCurrent();
        return true;
    }
    
    //--- Gestionar toma de profit al 25% + breakeven (RF-382)
    if(!m_swingTrades[idx].hasTaken25Percent) {
        if(Manage25PercentProfit(idx)) {
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::ManageSwingTrade - " +
                               "25% profit tomado para ticket " + IntegerToString(ticket));
            }
        }
    }
    
    //--- Gestionar reentrada al 50% (RF-383)
    if(m_swingTrades[idx].hasTaken25Percent && 
       !m_swingTrades[idx].hasReentered50 && 
       m_reentry50Enabled) {
        if(Manage50PercentReentry(idx)) {
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::ManageSwingTrade - " +
                               "Reentrada al 50% ejecutada para ticket " + IntegerToString(ticket));
            }
        }
    }
    
    //--- Gestionar trailing stop al 75% (RF-384)
    if(m_swingTrades[idx].hasTaken25Percent && 
       !m_swingTrades[idx].hasAdjustedTrail) {
        if(Manage75PercentTrail(idx)) {
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::ManageSwingTrade - " +
                               "Trailing stop ajustado al 75% para ticket " + IntegerToString(ticket));
            }
        }
    }
    
    //--- Detectar stop runs (RF-385)
    if(m_swingTrades[idx].hasTaken25Percent) {
        StopRunDetection detection = DetectStopRun(m_swingTrades[idx].symbol, 
                                                    m_swingTrades[idx].bias, 
                                                    m_swingTrades[idx].entryPrice, 
                                                    m_swingTrades[idx].takeProfit);
        m_stopRunDetection = detection;
        
        if(detection.isStopRun) {
            HandleStopRun(idx, detection);
            if(m_utils != NULL) {
                m_utils.LogInfo("CSwingManager::ManageSwingTrade - " +
                               "Stop run detectado en ticket " + IntegerToString(ticket) +
                               " | Distancia al equilibrio: " + DoubleToString(detection.distanceToEquil, 0) + " pips");
            }
        }
    }
    
    m_swingTrades[idx].lastUpdate = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+
//| RF-382/383/384/385: Gestionar todos los swing trades activos     |
//+------------------------------------------------------------------+
void CSwingManager::ManageAllSwingTrades() {
    if(!m_isInitialized) {
        Print("CSwingManager::ManageAllSwingTrades - Error: Módulo no inicializado");
        return;
    }
    
    for(int i = 0; i < m_swingTradeCount; i++) {
        if(m_swingTrades[i].phase != SWING_PHASE_COMPLETED &&
           m_swingTrades[i].phase != SWING_PHASE_STOPPED) {
            ManageSwingTrade(m_swingTrades[i].ticket);
        }
    }
}

//+------------------------------------------------------------------+
//| Registro de swing trade                                          |
//+------------------------------------------------------------------+
bool CSwingManager::RegisterSwingTrade(ulong ticket, string symbol, ENUM_BIAS bias,
                                        double entryPrice, double stopLoss, double takeProfit) {
    if(!m_isInitialized) {
        Print("CSwingManager::RegisterSwingTrade - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_swingTradeCount >= m_maxSwingTrades) {
        Print("CSwingManager::RegisterSwingTrade - Error: Máximo de swing trades alcanzado");
        return false;
    }
    
    //--- Verificar si ya está registrado
    if(FindSwingTrade(ticket) >= 0) {
        return true;
    }
    
    //--- Calcular niveles de profit
    double range = MathAbs(takeProfit - entryPrice);
    double profit25 = 0, profit50 = 0, profit75 = 0;
    
    if(bias == BIAS_BULLISH) {
        profit25 = entryPrice + range * 0.25;
        profit50 = entryPrice + range * 0.50;
        profit75 = entryPrice + range * 0.75;
    } else {
        profit25 = entryPrice - range * 0.25;
        profit50 = entryPrice - range * 0.50;
        profit75 = entryPrice - range * 0.75;
    }
    
    //--- Registrar swing trade
    SwingTradeState state;
    state.ticket = ticket;
    state.symbol = symbol;
    state.bias = bias;
    state.entryPrice = entryPrice;
    state.stopLoss = stopLoss;
    state.takeProfit = takeProfit;
    state.targetPrice = takeProfit;
    state.profit25Percent = profit25;
    state.profit50Percent = profit50;
    state.profit75Percent = profit75;
    state.hasTaken25Percent = false;
    state.hasReentered50 = false;
    state.hasAdjustedTrail = false;
    state.reentryPrice = 0;
    state.reentryStop = 0;
    state.reentryTarget = 0;
    state.currentTrailStop = stopLoss;
    state.trailLookback = 0;
    state.phase = SWING_PHASE_INITIAL;
    state.lastUpdate = TimeCurrent();
    
    m_swingTrades[m_swingTradeCount] = state;
    m_swingTradeCount++;
    
    if(m_utils != NULL) {
        m_utils.LogInfo("CSwingManager::RegisterSwingTrade - " +
                       "Swing trade registrado: " + symbol +
                       " | Ticket: " + IntegerToString(ticket));
    }
    
    return true;
}

//--- Actualizar swing trade
bool CSwingManager::UpdateSwingTrade(ulong ticket, double currentPrice) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    m_swingTrades[idx].lastUpdate = TimeCurrent();
    return true;
}

//--- Cerrar swing trade
bool CSwingManager::CloseSwingTrade(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    m_swingTrades[idx].phase = SWING_PHASE_COMPLETED;
    m_swingTrades[idx].lastUpdate = TimeCurrent();
    
    if(m_utils != NULL) {
        m_utils.LogInfo("CSwingManager::CloseSwingTrade - " +
                       "Swing trade cerrado: " + IntegerToString(ticket));
    }
    
    return true;
}

//--- Verificar si está registrado
bool CSwingManager::IsSwingTradeRegistered(ulong ticket) {
    return FindSwingTrade(ticket) >= 0;
}

//+------------------------------------------------------------------+
//| RF-382: Métodos públicos para toma de profit al 25%              |
//+------------------------------------------------------------------+
bool CSwingManager::ShouldTake25PercentProfit(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    if(m_swingTrades[idx].hasTaken25Percent) return false;
    
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        return (currentPrice >= m_swingTrades[idx].profit25Percent);
    } else {
        return (currentPrice <= m_swingTrades[idx].profit25Percent);
    }
}

bool CSwingManager::Take25PercentProfit(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    return Manage25PercentProfit(idx);
}

//+------------------------------------------------------------------+
//| RF-383: Métodos públicos para reentrada al 50%                   |
//+------------------------------------------------------------------+
bool CSwingManager::ShouldReenter50Percent(ulong ticket) {
    if(!m_reentry50Enabled) return false;
    
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    if(!m_swingTrades[idx].hasTaken25Percent || m_swingTrades[idx].hasReentered50) return false;
    
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    double point = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_POINT);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        return (currentPrice <= m_swingTrades[idx].profit50Percent + 10 * point);
    } else {
        return (currentPrice >= m_swingTrades[idx].profit50Percent - 10 * point);
    }
}

bool CSwingManager::Reenter50Percent(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    return Manage50PercentReentry(idx);
}

//+------------------------------------------------------------------+
//| RF-384: Métodos públicos para trailing stop al 75%               |
//+------------------------------------------------------------------+
bool CSwingManager::ShouldAdjust75PercentTrail(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    if(!m_swingTrades[idx].hasTaken25Percent || m_swingTrades[idx].hasAdjustedTrail) return false;
    
    double currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_BID);
    } else {
        currentPrice = SymbolInfoDouble(m_swingTrades[idx].symbol, SYMBOL_ASK);
    }
    
    if(m_swingTrades[idx].bias == BIAS_BULLISH) {
        return (currentPrice >= m_swingTrades[idx].profit75Percent);
    } else {
        return (currentPrice <= m_swingTrades[idx].profit75Percent);
    }
}

bool CSwingManager::Adjust75PercentTrail(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) return false;
    
    return Manage75PercentTrail(idx);
}

//+------------------------------------------------------------------+
//| RF-385: Métodos públicos para detección de stop runs             |
//+------------------------------------------------------------------+
StopRunDetection CSwingManager::GetStopRunDetection(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) {
        StopRunDetection empty;
        ZeroMemory(empty);
        return empty;
    }
    
    return DetectStopRun(m_swingTrades[idx].symbol, 
                         m_swingTrades[idx].bias, 
                         m_swingTrades[idx].entryPrice, 
                         m_swingTrades[idx].takeProfit);
}

bool CSwingManager::IsStopRunDetected(ulong ticket) {
    StopRunDetection detection = GetStopRunDetection(ticket);
    return detection.isStopRun;
}

double CSwingManager::GetStopRunDistance(ulong ticket) {
    StopRunDetection detection = GetStopRunDetection(ticket);
    return detection.distanceToEquil;
}

//+------------------------------------------------------------------+
//| Getters                                                          |
//+------------------------------------------------------------------+
SwingTradeState CSwingManager::GetSwingTrade(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) {
        SwingTradeState empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_swingTrades[idx];
}

//+------------------------------------------------------------------+
//| Reportes                                                         |
//+------------------------------------------------------------------+
string CSwingManager::GetSwingTradeReport(ulong ticket) {
    int idx = FindSwingTrade(ticket);
    if(idx < 0) {
        return "Swing trade no encontrado";
    }
    
    string report = "=== SWING TRADE REPORT ===\n";
    report += "Ticket: " + IntegerToString(m_swingTrades[idx].ticket) + "\n";
    report += "Símbolo: " + m_swingTrades[idx].symbol + "\n";
    report += "Bias: " + m_utils.GetBiasName(m_swingTrades[idx].bias) + "\n";
    report += "Entrada: " + DoubleToString(m_swingTrades[idx].entryPrice, 5) + "\n";
    report += "Stop Loss: " + DoubleToString(m_swingTrades[idx].stopLoss, 5) + "\n";
    report += "Take Profit: " + DoubleToString(m_swingTrades[idx].takeProfit, 5) + "\n";
    report += "25% Profit: " + DoubleToString(m_swingTrades[idx].profit25Percent, 5) + "\n";
    report += "50% Profit: " + DoubleToString(m_swingTrades[idx].profit50Percent, 5) + "\n";
    report += "75% Profit: " + DoubleToString(m_swingTrades[idx].profit75Percent, 5) + "\n";
    report += "Fase: " + (m_swingTrades[idx].phase == SWING_PHASE_INITIAL ? "INICIAL" :
                          m_swingTrades[idx].phase == SWING_PHASE_25_PERCENT ? "25% TOMADO" :
                          m_swingTrades[idx].phase == SWING_PHASE_REENTRY ? "REENTRADA" :
                          m_swingTrades[idx].phase == SWING_PHASE_75_PERCENT ? "75% TRAILING" :
                          m_swingTrades[idx].phase == SWING_PHASE_COMPLETED ? "COMPLETADO" :
                          m_swingTrades[idx].phase == SWING_PHASE_STOPPED ? "STOP" : "UNKNOWN") + "\n";
    report += "25% Tomado: " + (m_swingTrades[idx].hasTaken25Percent ? "✅" : "❌") + "\n";
    report += "Reentrada 50%: " + (m_swingTrades[idx].hasReentered50 ? "✅" : "❌") + "\n";
    report += "Trail 75%: " + (m_swingTrades[idx].hasAdjustedTrail ? "✅" : "❌") + "\n";
    report += "=========================";
    
    return report;
}

string CSwingManager::GetAllSwingTradesReport() {
    if(m_swingTradeCount == 0) {
        return "No hay swing trades activos";
    }
    
    string report = "=== SWING TRADES SUMMARY ===\n";
    report += "Total: " + IntegerToString(m_swingTradeCount) + "\n";
    report += "---\n";
    
    for(int i = 0; i < m_swingTradeCount; i++) {
        report += m_swingTrades[i].symbol + " | " + m_utils.GetBiasName(m_swingTrades[i].bias) + 
                  " | Fase: " + (m_swingTrades[i].phase == SWING_PHASE_INITIAL ? "INICIAL" :
                                 m_swingTrades[i].phase == SWING_PHASE_25_PERCENT ? "25%" :
                                 m_swingTrades[i].phase == SWING_PHASE_REENTRY ? "REENT" :
                                 m_swingTrades[i].phase == SWING_PHASE_75_PERCENT ? "75%" :
                                 m_swingTrades[i].phase == SWING_PHASE_COMPLETED ? "✓" : "✗") + "\n";
    }
    report += "=========================";
    
    return report;
}

#endif // __CSWINGMANAGER_MQH__