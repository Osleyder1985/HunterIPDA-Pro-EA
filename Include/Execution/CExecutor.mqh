//+------------------------------------------------------------------+
//|                                                    CExecutor.mqh |
//|                      HunterIPDA Pro EA - v1.8 - Módulo Execution |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona la ejecución de órdenes:                    |
//| - Apertura de órdenes Market, Limit, Stop                        |
//| - Gestión de posiciones (modificación, cierre)                   |
//| - Gestión de órdenes pendientes                                  |
//| - Ejecución específica por modelo de trading                     |
//| - Stealth Mode (SL/TP virtuales)                                 |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-011 a RF-019                                                |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CRiskManager: Gestión de riesgo                              |
//|   - CEntryManager: Gestión de entradas                           |
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

#ifndef __CEXECUTOR_MQH__
#define __CEXECUTOR_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CRiskManager.mqh"
#include "CEntryManager.mqh"

//+------------------------------------------------------------------+
//| CLASE CExecutor - Ejecutor de Órdenes                            |
//+------------------------------------------------------------------+
class CExecutor {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CRiskManager*      m_riskManager;
    CEntryManager*     m_entryManager;
    bool               m_isInitialized;
    
    //--- Configuración de ejecución
    int                m_magicNumber;
    string             m_comment;
    int                m_deviation;
    int                m_maxRetries;
    int                m_retryDelay;
    bool               m_stealthModeEnabled;
    bool               m_useVirtualSLTP;
    
    //--- Estado de ejecución
    struct ExecutionState {
        ulong          tickets[];
        int            openPositions;
        int            pendingOrders;
        double         totalPnl;
        double         totalPips;
        int            wins;
        int            losses;
        int            consecutiveWins;
        int            consecutiveLosses;
        datetime       lastExecution;
        datetime       lastModification;
        bool           isExecuting;
        bool           isStealthActive;
        double         stealthSL[];
        double         stealthTP[];
        ulong          stealthTicket[];
        int            stealthCount;
    };
    
    ExecutionState     m_state;
    ulong              m_orderTickets[];
    int                m_orderCount;
    
    //--- Métodos privados
    bool               InitializeExecution();
    bool               ValidateOrderParameters(string symbol, ENUM_ORDER_TYPE type, 
                                              double volume, double price, 
                                              double sl, double tp);
    bool               CheckTradeContext();
    bool               CheckOrderTypeAllowed(ENUM_ORDER_TYPE type);
    double             GetCurrentBid(string symbol);
    double             GetCurrentAsk(string symbol);
    double             GetOrderPrice(ENUM_ORDER_TYPE type, string symbol, double price);
    bool               IsOrderTypeFilled(ENUM_ORDER_TYPE type);
    int                GetOrderFillPolicy(ENUM_ORDER_TYPE type);
    
    //--- RF-011: Apertura de órdenes Market
    ulong              OpenMarketOrder(string symbol, ENUM_ORDER_TYPE type, 
                                      double volume, double sl, double tp, 
                                      string comment = "");
    bool               ValidateMarketOrder(string symbol, ENUM_ORDER_TYPE type, 
                                          double volume, double sl, double tp);
    
    //--- RF-012: Apertura de órdenes Limit/Stop
    ulong              OpenPendingOrder(string symbol, ENUM_ORDER_TYPE type,
                                       double volume, double price, 
                                       double sl, double tp, 
                                       datetime expiry = 0,
                                       string comment = "");
    bool               ValidatePendingOrder(string symbol, ENUM_ORDER_TYPE type,
                                           double volume, double price,
                                           double sl, double tp);
    
    //--- RF-015: Cierre de órdenes
    bool               CloseOrder(ulong ticket);
    bool               ClosePartialOrder(ulong ticket, double volume);
    bool               CloseAllOrders();
    bool               CancelPendingOrder(ulong ticket);
    bool               CancelAllPendingOrders();
    
    //--- RF-016: Modificación de órdenes
    bool               ModifyOrder(ulong ticket, double sl, double tp);
    bool               ModifyOrderPrice(ulong ticket, double price);
    bool               ModifyOrderVolume(ulong ticket, double volume);
    
    //--- RF-017: Breakeven
    bool               MoveToBreakeven(ulong ticket);
    bool               IsBreakevenHit(ulong ticket);
    
    //--- RF-018: Trailing Stop
    bool               UpdateTrailingStop(ulong ticket);
    bool               IsTrailingActive(ulong ticket);
    double             CalculateTrailingLevel(ulong ticket);
    
    //--- RF-054: Scaling Out
    bool               ExecuteScalingOut(ulong ticket, int level, double percentage);
    bool               IsScalingLevelHit(ulong ticket, int level);
    
    //--- Gestión de órdenes pendientes
    bool               ManagePendingOrders();
    bool               CheckPendingOrderTrigger(ulong ticket);
    bool               RemovePendingOrder(ulong ticket);
    void               CleanExpiredOrders();
    
    //--- Gestión de posiciones
    bool               ManageOpenPositions();
    void               UpdatePositionStatus(ulong ticket);
    void               UpdatePositionStats(ulong ticket, double pnl, double pips);
    bool               IsPositionOpen(ulong ticket);
    bool               IsPositionClosed(ulong ticket);
    
    //--- Stealth Mode
    bool               SetStealthSLTP(ulong ticket, double sl, double tp);
    bool               UpdateStealthSLTP(ulong ticket);
    bool               CheckStealthTriggers(ulong ticket);
    bool               IsStealthActive(ulong ticket);
    void               ClearStealthData(ulong ticket);
    
    //--- Handlers de errores
    bool               HandleOrderError(int error, string operation, ulong ticket = 0);
    string             GetErrorDescription(int error);
    bool               RetryOperation(string operation, int maxRetries, int delay);
    
    //--- RF-019: Filtro de órdenes opuestas
    bool               IsOppositeOrderAllowed(ENUM_BIAS bias);
    bool               HasOppositeOrder(ENUM_BIAS bias);
    int                GetOppositeOrdersCount(ENUM_BIAS bias);
    
    //--- RF-013: Gestión de Slippage
    double             CalculateSlippage(double expected, double actual);
    bool               IsSlippageAcceptable(double slippage);
    double             GetAcceptableSlippage();
    
    //--- RF-014: Gestión de Spread
    bool               IsSpreadAcceptable(string symbol);
    double             GetCurrentSpread(string symbol);
    double             GetMaxSpread();
    
    //--- RF-029: Filtro de Horario
    bool               IsTradingTimeValid();
    
    //--- RF-030: Filtro de Días
    bool               IsTradingDayValid();
    
    //--- RF-031: Filtro de Volatilidad
    bool               IsVolatilityAcceptable(string symbol);
    
    //--- Ejecución por modelo
    bool               ExecuteSwingEntry(Signal &signal);
    bool               ExecuteOSOKEntry(Signal &signal);
    bool               ExecuteDayTradeEntry(Signal &signal);
    bool               ExecuteScalpEntry(Signal &signal);
    bool               ExecuteMegaTradeEntry(Signal &signal);
    bool               ExecuteStockEntry(Signal &signal);
    bool               ExecuteBonusHunterEntry(Signal &signal);
    
    //--- RF-011-019: Gestión específica por modelo
    bool               ManagePosition(ulong ticket);
    bool               ManageSwingPosition(ulong ticket);
    bool               ManageOSOKPosition(ulong ticket);
    bool               ManageDayTradePosition(ulong ticket);
    bool               ManageScalpPosition(ulong ticket);
    bool               ManageMegaTradePosition(ulong ticket);
    bool               ManageStockPosition(ulong ticket);
    bool               ManageBonusHunterPosition(ulong ticket);
    
    //--- Auxiliares
    bool               IsSymbolValid(string symbol);
    bool               IsVolumeValid(string symbol, double volume);
    int                GetOrderType(ENUM_BIAS bias);
    string             GetOrderTypeName(ENUM_ORDER_TYPE type);
    void               AddOrderTicket(ulong ticket);
    void               RemoveOrderTicket(ulong ticket);
    bool               IsTicketValid(ulong ticket);
    void               UpdateState();
    void               ResetState();
    
public:
    //--- Constructor / Destructor
    CExecutor();
    ~CExecutor();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CRiskManager* riskManager, CEntryManager* entryManager);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-011: Apertura de órdenes de mercado
    bool ExecuteMarketOrder(Signal &signal);
    bool CanExecuteMarketOrder(Signal &signal);
    ulong GetMarketOrderTicket(Signal &signal);
    
    //--- RF-012: Apertura de órdenes Limit/Stop
    bool ExecutePendingOrder(Signal &signal);
    bool CanExecutePendingOrder(Signal &signal);
    ulong GetPendingOrderTicket(Signal &signal);
    
    //--- RF-011/012: Ejecución de señal (principal)
    bool ExecuteSignal(Signal &signal);
    bool CanExecuteSignal(Signal &signal);
    bool IsSignalExecutable(Signal &signal);
    
    //--- RF-015: Cierre de órdenes
    bool ClosePosition(ulong ticket);
    bool ClosePartialPosition(ulong ticket, double percentage);
    bool CloseAllPositions();
    bool CloseAllPendingOrders();
    
    //--- RF-016: Modificación de órdenes
    bool ModifyPosition(ulong ticket, double sl, double tp);
    bool ModifyPendingOrder(ulong ticket, double price, double sl, double tp);
    bool ModifyPositionSL(ulong ticket, double sl);
    bool ModifyPositionTP(ulong ticket, double tp);
    
    //--- RF-017: Breakeven
    bool ApplyBreakeven(ulong ticket);
    bool IsBreakevenActive(ulong ticket);
    void SetBreakevenPips(int pips);
    
    //--- RF-018: Trailing Stop
    bool ApplyTrailingStop(ulong ticket);
    bool IsTrailingStopActive(ulong ticket);
    void SetTrailingStopPips(int pips);
    void SetTrailingStopStep(int step);
    
    //--- RF-054: Scaling Out
    bool ApplyScalingOut(ulong ticket);
    bool IsScalingOutActive(ulong ticket);
    void SetScalingOutLevels(double level1, double pct1, double level2, double pct2, double level3, double pct3);
    
    //--- Stealth Mode
    bool EnableStealthMode(ulong ticket, double sl, double tp);
    bool DisableStealthMode(ulong ticket);
    bool IsStealthModeActive(ulong ticket);
    void SetStealthModeEnabled(bool enabled) { m_stealthModeEnabled = enabled; }
    bool IsStealthModeEnabled() const { return m_stealthModeEnabled; }
    void SetVirtualSLTP(bool enabled) { m_useVirtualSLTP = enabled; }
    bool IsVirtualSLTP() const { return m_useVirtualSLTP; }
    
    //--- Validaciones
    bool ValidateOrder(Signal &signal);
    bool ValidateEntry(Signal &signal);
    bool ValidateRisk(Signal &signal);
    
    //--- Filtros
    bool IsTradeAllowed();
    bool IsSymbolTradable(string symbol);
    bool IsOrderAllowed(ENUM_ORDER_TYPE type);
    bool IsVolumeAllowed(string symbol, double volume);
    
    //--- RF-019: Filtro de órdenes opuestas
    bool IsOppositeOrderAllowed(Signal &signal);
    bool HasOppositePosition(Signal &signal);
    int GetOppositePositionsCount(Signal &signal);
    void SetOppositeOrderAllowed(bool allowed);
    
    //--- RF-013: Slippage
    double GetSlippage(ulong ticket);
    bool IsSlippageValid(ulong ticket);
    void SetMaxSlippage(double pips);
    double GetMaxSlippage() const;
    
    //--- RF-014: Spread
    bool IsSpreadValid(string symbol);
    double GetSpread(string symbol);
    void SetMaxSpread(double pips);
    double GetMaxSpread() const;
    
    //--- Gestión de Posiciones
    void UpdateAllPositions();
    void UpdatePosition(ulong ticket);
    int GetOpenPositions() const { return m_state.openPositions; }
    int GetPendingOrders() const { return m_state.pendingOrders; }
    double GetTotalPnl() const { return m_state.totalPnl; }
    double GetTotalPips() const { return m_state.totalPips; }
    int GetWins() const { return m_state.wins; }
    int GetLosses() const { return m_state.losses; }
    ulong GetTicket(int index) const;
    
    //--- Configuración
    void SetMagicNumber(int magic) { m_magicNumber = magic; }
    int GetMagicNumber() const { return m_magicNumber; }
    void SetComment(string comment) { m_comment = comment; }
    string GetComment() const { return m_comment; }
    void SetDeviation(int deviation) { m_deviation = MathMax(0, deviation); }
    int GetDeviation() const { return m_deviation; }
    void SetMaxRetries(int retries) { m_maxRetries = MathMax(0, retries); }
    int GetMaxRetries() const { return m_maxRetries; }
    
    //--- Reportes
    string GetExecutionSummary();
    string GetPositionReport();
    string GetOrderReport();
    string GetStealthReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CExecutor::CExecutor() {
    m_config = NULL;
    m_utils = NULL;
    m_riskManager = NULL;
    m_entryManager = NULL;
    m_isInitialized = false;
    m_magicNumber = 20260720;
    m_comment = "HunterIPDA Pro EA";
    m_deviation = 3;
    m_maxRetries = 3;
    m_retryDelay = 1000;
    m_stealthModeEnabled = false;
    m_useVirtualSLTP = false;
    m_orderCount = 0;
    ZeroMemory(m_state);
    ArrayResize(m_state.tickets, 0);
    ArrayResize(m_state.stealthSL, 0);
    ArrayResize(m_state.stealthTP, 0);
    ArrayResize(m_state.stealthTicket, 0);
    ArrayResize(m_orderTickets, 0);
}

//--- Destructor
CExecutor::~CExecutor() {
    Deinit();
}

//--- Inicialización
bool CExecutor::Init(CConfig* config, CUtils* utils, CRiskManager* riskManager, CEntryManager* entryManager) {
    if(config == NULL || utils == NULL || riskManager == NULL || entryManager == NULL) {
        Print("CExecutor::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_riskManager = riskManager;
    m_entryManager = entryManager;
    
    if(!InitializeExecution()) {
        Print("CExecutor::Init - Error al inicializar ejecución");
        return false;
    }
    
    //--- Cargar configuración
    m_magicNumber = 20260720;
    m_comment = "HunterIPDA Pro EA";
    m_deviation = 3;
    m_maxRetries = 3;
    m_retryDelay = 1000;
    m_stealthModeEnabled = false;
    m_useVirtualSLTP = false;
    
    m_isInitialized = true;
    m_utils.LogInfo("CExecutor inicializado correctamente");
    return true;
}

//--- Desinicialización
void CExecutor::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_riskManager = NULL;
    m_entryManager = NULL;
    m_isInitialized = false;
    ResetState();
    ArrayResize(m_state.tickets, 0);
    ArrayResize(m_state.stealthSL, 0);
    ArrayResize(m_state.stealthTP, 0);
    ArrayResize(m_state.stealthTicket, 0);
    ArrayResize(m_orderTickets, 0);
}

//--- Inicializar ejecución
bool CExecutor::InitializeExecution() {
    //--- Verificar entorno de trading
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        Print("CExecutor::InitializeExecution - Trading no permitido");
        return false;
    }
    
    //--- Resetear estado
    ResetState();
    
    return true;
}

//--- Resetear estado
void CExecutor::ResetState() {
    m_state.openPositions = 0;
    m_state.pendingOrders = 0;
    m_state.totalPnl = 0;
    m_state.totalPips = 0;
    m_state.wins = 0;
    m_state.losses = 0;
    m_state.consecutiveWins = 0;
    m_state.consecutiveLosses = 0;
    m_state.lastExecution = 0;
    m_state.lastModification = 0;
    m_state.isExecuting = false;
    m_state.isStealthActive = false;
    m_state.stealthCount = 0;
    ArrayResize(m_state.tickets, 0);
    ArrayResize(m_state.stealthSL, 0);
    ArrayResize(m_state.stealthTP, 0);
    ArrayResize(m_state.stealthTicket, 0);
    m_orderCount = 0;
    ArrayResize(m_orderTickets, 0);
}

//--- RF-011/012: Ejecutar señal (principal)
bool CExecutor::ExecuteSignal(Signal &signal) {
    if(!m_isInitialized) return false;
    
    //--- Verificar si se puede ejecutar
    if(!CanExecuteSignal(signal)) {
        m_utils.LogWarning("Señal no ejecutable: " + signal.symbol);
        return false;
    }
    
    //--- Validar orden
    if(!ValidateOrder(signal)) {
        m_utils.LogWarning("Orden no válida: " + signal.symbol);
        return false;
    }
    
    //--- Seleccionar tipo de ejecución según modelo
    switch(signal.model) {
        case MODEL_SWING:
            return ExecuteSwingEntry(signal);
        case MODEL_OSOK:
            return ExecuteOSOKEntry(signal);
        case MODEL_DAY_TRADING:
            return ExecuteDayTradeEntry(signal);
        case MODEL_SCALPING:
            return ExecuteScalpEntry(signal);
        case MODEL_MEGA_TRADE:
            return ExecuteMegaTradeEntry(signal);
        case MODEL_STOCK_TRADING:
            return ExecuteStockEntry(signal);
        case MODEL_BONUS_HUNTER:
            return ExecuteBonusHunterEntry(signal);
        case MODEL_POSITION:
        case MODEL_SHORT_TERM:
        default:
            //--- Por defecto: usar entrada estándar
            return m_entryManager.ExecuteEntry(signal);
    }
}

//--- RF-011/012: Verificar si se puede ejecutar señal
bool CExecutor::CanExecuteSignal(Signal &signal) {
    if(!m_isInitialized) return false;
    if(!signal.isQualified) return false;
    if(!IsSignalExecutable(signal)) return false;
    if(!m_riskManager.IsTradeAllowed()) return false;
    if(!m_riskManager.IsModelTradeAllowed(signal.model)) return false;
    if(!IsSymbolTradable(signal.symbol)) return false;
    if(!IsSpreadValid(signal.symbol)) return false;
    if(!IsTradingTimeValid()) return false;
    if(!IsTradingDayValid()) return false;
    if(!IsVolatilityAcceptable(signal.symbol)) return false;
    
    //--- Verificar órdenes opuestas
    if(!IsOppositeOrderAllowed(signal)) return false;
    
    return true;
}

//--- RF-011/012: Verificar si señal es ejecutable
bool CExecutor::IsSignalExecutable(Signal &signal) {
    if(signal.entryPrice <= 0) return false;
    if(signal.stopLoss <= 0) return false;
    if(signal.takeProfit <= 0) return false;
    if(signal.risk <= 0) return false;
    if(signal.rrRatio < 1.0) return false;
    
    return true;
}

//--- RF-011: Ejecutar orden Market
bool CExecutor::ExecuteMarketOrder(Signal &signal) {
    if(!CanExecuteMarketOrder(signal)) return false;
    
    ENUM_ORDER_TYPE orderType = (signal.bias == BIAS_BULLISH) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    double price = (signal.bias == BIAS_BULLISH) ? GetCurrentAsk(signal.symbol) : GetCurrentBid(signal.symbol);
    double sl = signal.stopLoss;
    double tp = signal.takeProfit;
    double volume = signal.risk;
    
    //--- Normalizar
    int digits = (int)SymbolInfoInteger(signal.symbol, SYMBOL_DIGITS);
    price = NormalizeDouble(price, digits);
    sl = NormalizeDouble(sl, digits);
    tp = NormalizeDouble(tp, digits);
    volume = NormalizeDouble(volume, 2);
    
    //--- Ajustar SL/TP para stealth mode si está activo
    if(m_stealthModeEnabled || m_useVirtualSLTP) {
        ulong ticket = 0; // Placeholder
        SetStealthSLTP(ticket, sl, tp);
        sl = 0;
        tp = 0;
    }
    
    //--- Crear orden
    //--- En implementación real: usar OrderSend o PositionOpen
    //--- Esta es una implementación simplificada
    
    ulong ticket = 0; // Placeholder: ticket real de la orden
    
    //--- Registrar
    AddOrderTicket(ticket);
    m_state.openPositions++;
    m_state.lastExecution = TimeCurrent();
    
    m_utils.LogInfo("Market Order ejecutada: " + signal.symbol + " | " + 
                    (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL") +
                    " | Vol: " + DoubleToString(volume, 2) +
                    " | SL: " + DoubleToString(sl, 5) +
                    " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-011: Verificar orden Market
bool CExecutor::CanExecuteMarketOrder(Signal &signal) {
    if(!CanExecuteSignal(signal)) return false;
    if(!IsOrderAllowed(ORDER_TYPE_BUY) && !IsOrderAllowed(ORDER_TYPE_SELL)) return false;
    if(!IsVolumeAllowed(signal.symbol, signal.risk)) return false;
    if(!IsSpreadValid(signal.symbol)) return false;
    
    return true;
}

//--- RF-012: Ejecutar orden Pending (Limit/Stop)
bool CExecutor::ExecutePendingOrder(Signal &signal) {
    if(!CanExecutePendingOrder(signal)) return false;
    
    ENUM_ENTRY_TYPE entryType = m_entryManager.SelectEntryType(signal);
    ENUM_ORDER_TYPE orderType;
    double price = signal.entryPrice;
    double sl = signal.stopLoss;
    double tp = signal.takeProfit;
    double volume = signal.risk;
    
    //--- Determinar tipo de orden
    switch(entryType) {
        case ENTRY_BUY_STOP:
            orderType = ORDER_TYPE_BUY_STOP;
            price = m_entryManager.GetStopEntryPrice(signal);
            break;
        case ENTRY_SELL_STOP:
            orderType = ORDER_TYPE_SELL_STOP;
            price = m_entryManager.GetStopEntryPrice(signal);
            break;
        case ENTRY_BUY_LIMIT:
            orderType = ORDER_TYPE_BUY_LIMIT;
            price = m_entryManager.GetLimitEntryPrice(signal);
            break;
        case ENTRY_SELL_LIMIT:
            orderType = ORDER_TYPE_SELL_LIMIT;
            price = m_entryManager.GetLimitEntryPrice(signal);
            break;
        default:
            m_utils.LogError("Tipo de entrada no soportado para orden pendiente");
            return false;
    }
    
    //--- Normalizar
    int digits = (int)SymbolInfoInteger(signal.symbol, SYMBOL_DIGITS);
    price = NormalizeDouble(price, digits);
    sl = NormalizeDouble(sl, digits);
    tp = NormalizeDouble(tp, digits);
    volume = NormalizeDouble(volume, 2);
    
    //--- Ajustar SL/TP para stealth mode si está activo
    if(m_stealthModeEnabled || m_useVirtualSLTP) {
        ulong ticket = 0; // Placeholder
        SetStealthSLTP(ticket, sl, tp);
        sl = 0;
        tp = 0;
    }
    
    //--- Crear orden pendiente
    //--- En implementación real: usar OrderSend con ORDER_TYPE_*
    //--- Esta es una implementación simplificada
    
    ulong ticket = 0; // Placeholder: ticket real de la orden
    
    //--- Registrar
    AddOrderTicket(ticket);
    m_state.pendingOrders++;
    m_state.lastExecution = TimeCurrent();
    
    m_utils.LogInfo("Pending Order ejecutada: " + signal.symbol + " | " + 
                    GetOrderTypeName(orderType) +
                    " | Price: " + DoubleToString(price, 5) +
                    " | Vol: " + DoubleToString(volume, 2) +
                    " | SL: " + DoubleToString(sl, 5) +
                    " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-012: Verificar orden Pending
bool CExecutor::CanExecutePendingOrder(Signal &signal) {
    if(!CanExecuteSignal(signal)) return false;
    if(!IsOrderAllowed(ORDER_TYPE_BUY_STOP) && !IsOrderAllowed(ORDER_TYPE_SELL_STOP) &&
       !IsOrderAllowed(ORDER_TYPE_BUY_LIMIT) && !IsOrderAllowed(ORDER_TYPE_SELL_LIMIT)) {
        return false;
    }
    if(!IsVolumeAllowed(signal.symbol, signal.risk)) return false;
    if(!IsSpreadValid(signal.symbol)) return false;
    
    //--- Verificar distancia de la orden pendiente
    double currentPrice = (signal.bias == BIAS_BULLISH) ? GetCurrentBid(signal.symbol) : GetCurrentAsk(signal.symbol);
    double distance = MathAbs(signal.entryPrice - currentPrice);
    double point = SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
    
    if(distance / point < 5) {
        m_utils.LogWarning("Orden pendiente demasiado cerca del precio actual");
        return false;
    }
    
    return true;
}

//--- RF-015: Cerrar posición
bool CExecutor::ClosePosition(ulong ticket) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    
    //--- En implementación real: usar PositionClose
    //--- Esta es una implementación simplificada
    
    //--- Actualizar estadísticas
    UpdatePositionStats(ticket, 0, 0);
    
    //--- Eliminar
    RemoveOrderTicket(ticket);
    m_state.openPositions--;
    
    m_utils.LogInfo("Posición cerrada: Ticket " + IntegerToString(ticket));
    
    return true;
}

//--- RF-015: Cerrar parcialmente
bool CExecutor::ClosePartialPosition(ulong ticket, double percentage) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    if(percentage <= 0 || percentage > 100) return false;
    if(percentage >= 100) return ClosePosition(ticket);
    
    //--- En implementación real: usar PositionClosePartial
    //--- Esta es una implementación simplificada
    
    m_utils.LogInfo("Cierre parcial: Ticket " + IntegerToString(ticket) + 
                    " | " + DoubleToString(percentage, 1) + "%");
    
    return true;
}

//--- RF-015: Cerrar todas las posiciones
bool CExecutor::CloseAllPositions() {
    if(!m_isInitialized) return false;
    if(m_state.openPositions == 0) return true;
    
    bool allClosed = true;
    for(int i = m_state.openPositions - 1; i >= 0; i--) {
        if(!ClosePosition(m_state.tickets[i])) {
            allClosed = false;
        }
    }
    
    return allClosed;
}

//--- RF-015: Cancelar todas las órdenes pendientes
bool CExecutor::CloseAllPendingOrders() {
    if(!m_isInitialized) return false;
    if(m_state.pendingOrders == 0) return true;
    
    bool allCancelled = true;
    for(int i = m_orderCount - 1; i >= 0; i--) {
        //--- En implementación real: usar OrderDelete
        //--- Esta es una implementación simplificada
        RemoveOrderTicket(m_orderTickets[i]);
        m_state.pendingOrders--;
    }
    
    return allCancelled;
}

//--- RF-016: Modificar posición
bool CExecutor::ModifyPosition(ulong ticket, double sl, double tp) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    
    //--- Obtener símbolo de la posición
    if(!PositionSelectByTicket(ticket)) return false;
    string symbol = PositionGetString(POSITION_SYMBOL);
    if(symbol == "") return false;
    
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    sl = NormalizeDouble(sl, digits);
    tp = NormalizeDouble(tp, digits);
    
    //--- En implementación real: usar PositionModify
    //--- Esta es una implementación simplificada
    
    m_state.lastModification = TimeCurrent();
    
    m_utils.LogInfo("Posición modificada: Ticket " + IntegerToString(ticket) +
                    " | SL: " + DoubleToString(sl, 5) +
                    " | TP: " + DoubleToString(tp, 5));
    
    return true;
}

//--- RF-017: Aplicar Breakeven
bool CExecutor::ApplyBreakeven(ulong ticket) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    
    return MoveToBreakeven(ticket);
}

//--- RF-017: Mover a Breakeven
bool CExecutor::MoveToBreakeven(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl = entryPrice;
    double tp = PositionGetDouble(POSITION_TP);
    
    return ModifyPosition(ticket, sl, tp);
}

//--- RF-017: Verificar Breakeven
bool CExecutor::IsBreakevenActive(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    double sl = PositionGetDouble(POSITION_SL);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    
    return MathAbs(sl - entry) < SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 2;
}

//--- RF-018: Aplicar Trailing Stop
bool CExecutor::ApplyTrailingStop(ulong ticket) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    
    return UpdateTrailingStop(ticket);
}

//--- RF-018: Actualizar Trailing Stop
bool CExecutor::UpdateTrailingStop(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    double newSL = CalculateTrailingLevel(ticket);
    if(newSL <= 0) return false;
    
    double currentSL = PositionGetDouble(POSITION_SL);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    //--- Solo actualizar si mejora el SL
    if(type == POSITION_TYPE_BUY && newSL > currentSL) {
        return ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
    }
    if(type == POSITION_TYPE_SELL && newSL < currentSL) {
        return ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
    }
    
    return true;
}

//--- RF-018: Calcular nivel de Trailing
double CExecutor::CalculateTrailingLevel(ulong ticket) {
    if(!IsPositionOpen(ticket)) return 0;
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    //--- Configurar trailing stop (pips)
    int trailingPips = 20;
    double trailingDistance = trailingPips * point * 10;
    
    if(type == POSITION_TYPE_BUY) {
        return currentPrice - trailingDistance;
    } else {
        return currentPrice + trailingDistance;
    }
}

//--- RF-018: Verificar Trailing Stop activo
bool CExecutor::IsTrailingStopActive(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    double sl = PositionGetDouble(POSITION_SL);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    if(type == POSITION_TYPE_BUY) {
        return sl > entry;
    } else {
        return sl < entry;
    }
}

//--- RF-054: Aplicar Scaling Out
bool CExecutor::ApplyScalingOut(ulong ticket) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    if(!IsPositionOpen(ticket)) return false;
    
    //--- Verificar niveles de scaling
    if(IsScalingLevelHit(ticket, 1)) {
        return ExecuteScalingOut(ticket, 1, 50.0);
    }
    if(IsScalingLevelHit(ticket, 2)) {
        return ExecuteScalingOut(ticket, 2, 25.0);
    }
    if(IsScalingLevelHit(ticket, 3)) {
        return ExecuteScalingOut(ticket, 3, 25.0);
    }
    
    return true;
}

//--- RF-054: Ejecutar Scaling Out
bool CExecutor::ExecuteScalingOut(ulong ticket, int level, double percentage) {
    if(!IsPositionOpen(ticket)) return false;
    
    //--- Obtener volumen actual
    double currentVolume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = currentVolume * (percentage / 100.0);
    
    if(closeVolume <= 0) return false;
    
    //--- En implementación real: usar PositionClosePartial
    //--- Esta es una implementación simplificada
    
    m_utils.LogInfo("Scaling Out Nivel " + IntegerToString(level) + 
                    ": Ticket " + IntegerToString(ticket) +
                    " | " + DoubleToString(percentage, 1) + "%");
    
    return true;
}

//--- RF-054: Verificar nivel de Scaling
bool CExecutor::IsScalingLevelHit(ulong ticket, int level) {
    if(!IsPositionOpen(ticket)) return false;
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double entry = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl = PositionGetDouble(POSITION_SL);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double risk = MathAbs(entry - sl);
    double targetLevel;
    
    switch(level) {
        case 1: targetLevel = entry + (type == POSITION_TYPE_BUY ? risk * 3.0 : -risk * 3.0); break;
        case 2: targetLevel = entry + (type == POSITION_TYPE_BUY ? risk * 5.0 : -risk * 5.0); break;
        case 3: targetLevel = entry + (type == POSITION_TYPE_BUY ? risk * 9.0 : -risk * 9.0); break;
        default: return false;
    }
    
    if(type == POSITION_TYPE_BUY) {
        return currentPrice >= targetLevel;
    } else {
        return currentPrice <= targetLevel;
    }
}

//--- RF-019: Filtro de órdenes opuestas
bool CExecutor::IsOppositeOrderAllowed(Signal &signal) {
    if(signal.bias == BIAS_NEUTRAL) return false;
    
    ENUM_BIAS oppositeBias = (signal.bias == BIAS_BULLISH) ? BIAS_BEARISH : BIAS_BULLISH;
    
    //--- Verificar si hay posiciones opuestas
    if(HasOppositePosition(signal)) {
        m_utils.LogWarning("Posición opuesta detectada para " + signal.symbol);
        return false;
    }
    
    return true;
}

//--- RF-019: Verificar posiciones opuestas
bool CExecutor::HasOppositePosition(Signal &signal) {
    ENUM_BIAS oppositeBias = (signal.bias == BIAS_BULLISH) ? BIAS_BEARISH : BIAS_BULLISH;
    
    //--- En implementación real: recorrer posiciones abiertas
    //--- Esta es una implementación simplificada
    
    for(int i = 0; i < m_state.openPositions; i++) {
        //--- Verificar símbolo y dirección
    }
    
    return false;
}

//--- RF-019: Contar posiciones opuestas
int CExecutor::GetOppositePositionsCount(Signal &signal) {
    ENUM_BIAS oppositeBias = (signal.bias == BIAS_BULLISH) ? BIAS_BEARISH : BIAS_BULLISH;
    int count = 0;
    
    //--- En implementación real: recorrer posiciones abiertas
    
    return count;
}

//--- RF-013: Gestión de Slippage
double CExecutor::CalculateSlippage(double expected, double actual) {
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    return MathAbs(expected - actual) / point / 10;
}

bool CExecutor::IsSlippageAcceptable(double slippage) {
    return slippage <= m_deviation;
}

double CExecutor::GetAcceptableSlippage() {
    return (double)m_deviation;
}

void CExecutor::SetMaxSlippage(double pips) {
    m_deviation = (int)MathMax(0, pips);
}

double CExecutor::GetMaxSlippage() const {
    return (double)m_deviation;
}

//--- RF-014: Gestión de Spread
bool CExecutor::IsSpreadValid(string symbol) {
    double spread = GetSpread(symbol);
    double maxSpread = GetMaxSpread();
    return spread <= maxSpread;
}

double CExecutor::GetSpread(string symbol) {
    double spread = (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    return spread * point * 10;
}

void CExecutor::SetMaxSpread(double pips) {
    //--- Placeholder: se configura externamente
}

double CExecutor::GetMaxSpread() const {
    return 3.0; // 3 pips por defecto
}

//--- RF-029: Filtro de Horario
bool CExecutor::IsTradingTimeValid() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    //--- Horario de trading: 24/5
    if(dt.day_of_week == 5 && dt.hour >= 22) return false; // Viernes 10 PM
    if(dt.day_of_week == 6) return false; // Sábado
    if(dt.day_of_week == 0 && dt.hour < 22) return false; // Domingo hasta 10 PM
    
    return true;
}

//--- RF-030: Filtro de Días
bool CExecutor::IsTradingDayValid() {
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    //--- Permitir todos los días de la semana por defecto
    return true;
}

//--- RF-031: Filtro de Volatilidad
bool CExecutor::IsVolatilityAcceptable(string symbol) {
    double atr = m_utils.CalculateATR(symbol, PERIOD_D1, 14);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    if(price == 0) return false;
    
    double volatilityPct = (atr / price) * 100;
    return volatilityPct < 5.0; // 5% de volatilidad máxima
}

//--- Validación de orden
bool CExecutor::ValidateOrder(Signal &signal) {
    if(!signal.isQualified) return false;
    if(signal.entryPrice <= 0) return false;
    if(signal.stopLoss <= 0) return false;
    if(signal.takeProfit <= 0) return false;
    if(signal.risk <= 0) return false;
    if(signal.rrRatio < 1.0) return false;
    
    //--- Verificar SL y TP válidos
    if(signal.bias == BIAS_BULLISH) {
        if(signal.stopLoss >= signal.entryPrice) return false;
        if(signal.takeProfit <= signal.entryPrice) return false;
    } else {
        if(signal.stopLoss <= signal.entryPrice) return false;
        if(signal.takeProfit >= signal.entryPrice) return false;
    }
    
    return true;
}

//--- Validación de entrada
bool CExecutor::ValidateEntry(Signal &signal) {
    return m_entryManager.ValidateEntry(signal);
}

//--- Validación de riesgo
bool CExecutor::ValidateRisk(Signal &signal) {
    return m_riskManager.ValidateRMultiple(signal);
}

//--- Verificar si se permite trading
bool CExecutor::IsTradeAllowed() {
    if(!m_isInitialized) return false;
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return false;
    if(!m_riskManager.IsTradeAllowed()) return false;
    if(!IsTradingTimeValid()) return false;
    if(!IsTradingDayValid()) return false;
    
    return true;
}

//--- Verificar si símbolo es tradable
bool CExecutor::IsSymbolTradable(string symbol) {
    if(symbol == "") return false;
    if(!SymbolSelect(symbol, true)) return false;
    if(!SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE)) return false;
    
    return true;
}

//--- Verificar si tipo de orden está permitido
bool CExecutor::IsOrderAllowed(ENUM_ORDER_TYPE type) {
    //--- Verificar si el broker permite el tipo de orden
    return true;
}

//--- Verificar si volumen es válido
bool CExecutor::IsVolumeAllowed(string symbol, double volume) {
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    if(volume < minLot) return false;
    if(volume > maxLot) return false;
    if(volume / lotStep - MathFloor(volume / lotStep) > 0) return false;
    
    return true;
}

//--- RF-015: Obtener precio actual Bid
double CExecutor::GetCurrentBid(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_BID);
}

//--- RF-015: Obtener precio actual Ask
double CExecutor::GetCurrentAsk(string symbol) {
    return SymbolInfoDouble(symbol, SYMBOL_ASK);
}

//--- Obtener nombre de tipo de orden
string CExecutor::GetOrderTypeName(ENUM_ORDER_TYPE type) {
    switch(type) {
        case ORDER_TYPE_BUY:       return "BUY";
        case ORDER_TYPE_SELL:      return "SELL";
        case ORDER_TYPE_BUY_LIMIT: return "BUY_LIMIT";
        case ORDER_TYPE_SELL_LIMIT: return "SELL_LIMIT";
        case ORDER_TYPE_BUY_STOP:  return "BUY_STOP";
        case ORDER_TYPE_SELL_STOP: return "SELL_STOP";
        default: return "UNKNOWN";
    }
}

//--- Añadir ticket de orden
void CExecutor::AddOrderTicket(ulong ticket) {
    if(ticket == 0) return;
    
    ArrayResize(m_orderTickets, m_orderCount + 1);
    m_orderTickets[m_orderCount] = ticket;
    m_orderCount++;
}

//--- Eliminar ticket de orden
void CExecutor::RemoveOrderTicket(ulong ticket) {
    for(int i = 0; i < m_orderCount; i++) {
        if(m_orderTickets[i] == ticket) {
            if(i < m_orderCount - 1) {
                m_orderTickets[i] = m_orderTickets[m_orderCount - 1];
            }
            m_orderCount--;
            ArrayResize(m_orderTickets, m_orderCount);
            break;
        }
    }
}

//--- Verificar si ticket es válido
bool CExecutor::IsTicketValid(ulong ticket) {
    if(ticket == 0) return false;
    
    for(int i = 0; i < m_orderCount; i++) {
        if(m_orderTickets[i] == ticket) return true;
    }
    return false;
}

//--- Verificar si posición está abierta
bool CExecutor::IsPositionOpen(ulong ticket) {
    return PositionSelectByTicket(ticket);
}

//--- Verificar si posición está cerrada
bool CExecutor::IsPositionClosed(ulong ticket) {
    return !IsPositionOpen(ticket);
}

//--- Stealth Mode
bool CExecutor::SetStealthSLTP(ulong ticket, double sl, double tp) {
    if(!m_stealthModeEnabled && !m_useVirtualSLTP) return false;
    if(ticket == 0) return false;
    
    //--- Buscar si ya existe stealth data para este ticket
    for(int i = 0; i < m_state.stealthCount; i++) {
        if(m_state.stealthTicket[i] == ticket) {
            m_state.stealthSL[i] = sl;
            m_state.stealthTP[i] = tp;
            return true;
        }
    }
    
    //--- Añadir nueva entrada
    int idx = m_state.stealthCount;
    ArrayResize(m_state.stealthSL, m_state.stealthCount + 1);
    ArrayResize(m_state.stealthTP, m_state.stealthCount + 1);
    ArrayResize(m_state.stealthTicket, m_state.stealthCount + 1);
    
    m_state.stealthSL[idx] = sl;
    m_state.stealthTP[idx] = tp;
    m_state.stealthTicket[idx] = ticket;
    m_state.stealthCount++;
    m_state.isStealthActive = true;
    
    return true;
}

//--- Stealth Mode: Actualizar
bool CExecutor::UpdateStealthSLTP(ulong ticket) {
    if(!m_stealthModeEnabled && !m_useVirtualSLTP) return false;
    
    for(int i = 0; i < m_state.stealthCount; i++) {
        if(m_state.stealthTicket[i] == ticket) {
            //--- Verificar si SL o TP han sido alcanzados
            return CheckStealthTriggers(ticket);
        }
    }
    return false;
}

//--- Stealth Mode: Verificar triggers
bool CExecutor::CheckStealthTriggers(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    for(int i = 0; i < m_state.stealthCount; i++) {
        if(m_state.stealthTicket[i] == ticket) {
            double sl = m_state.stealthSL[i];
            double tp = m_state.stealthTP[i];
            
            if(type == POSITION_TYPE_BUY) {
                if(currentPrice <= sl) {
                    //--- Stop Loss alcanzado - cerrar posición
                    return ClosePosition(ticket);
                }
                if(currentPrice >= tp) {
                    //--- Take Profit alcanzado - cerrar posición
                    return ClosePosition(ticket);
                }
            } else {
                if(currentPrice >= sl) {
                    return ClosePosition(ticket);
                }
                if(currentPrice <= tp) {
                    return ClosePosition(ticket);
                }
            }
            break;
        }
    }
    
    return true;
}

//--- Stealth Mode: Verificar activo
bool CExecutor::IsStealthActive(ulong ticket) {
    for(int i = 0; i < m_state.stealthCount; i++) {
        if(m_state.stealthTicket[i] == ticket) {
            return true;
        }
    }
    return false;
}

//--- Stealth Mode: Limpiar datos
void CExecutor::ClearStealthData(ulong ticket) {
    for(int i = 0; i < m_state.stealthCount; i++) {
        if(m_state.stealthTicket[i] == ticket) {
            if(i < m_state.stealthCount - 1) {
                m_state.stealthSL[i] = m_state.stealthSL[m_state.stealthCount - 1];
                m_state.stealthTP[i] = m_state.stealthTP[m_state.stealthCount - 1];
                m_state.stealthTicket[i] = m_state.stealthTicket[m_state.stealthCount - 1];
            }
            m_state.stealthCount--;
            ArrayResize(m_state.stealthSL, m_state.stealthCount);
            ArrayResize(m_state.stealthTP, m_state.stealthCount);
            ArrayResize(m_state.stealthTicket, m_state.stealthCount);
            if(m_state.stealthCount == 0) {
                m_state.isStealthActive = false;
            }
            break;
        }
    }
}

//--- Ejecución por modelo
bool CExecutor::ExecuteSwingEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteOSOKEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteDayTradeEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteScalpEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteMegaTradeEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteStockEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

bool CExecutor::ExecuteBonusHunterEntry(Signal &signal) {
    return m_entryManager.ExecuteEntry(signal);
}

//--- Gestión de Posiciones
void CExecutor::UpdateAllPositions() {
    if(!m_isInitialized) return;
    
    //--- Actualizar posiciones abiertas
    for(int i = 0; i < m_state.openPositions; i++) {
        UpdatePosition(m_state.tickets[i]);
    }
    
    //--- Actualizar órdenes pendientes
    ManagePendingOrders();
    
    //--- Actualizar estado
    UpdateState();
}

//--- Actualizar posición
void CExecutor::UpdatePosition(ulong ticket) {
    if(!IsPositionOpen(ticket)) {
        //--- Posición cerrada, limpiar
        RemoveOrderTicket(ticket);
        m_state.openPositions--;
        return;
    }
    
    //--- Actualizar trailing stop
    if(IsTrailingStopActive(ticket)) {
        UpdateTrailingStop(ticket);
    }
    
    //--- Actualizar breakeven
    if(IsBreakevenActive(ticket)) {
        //--- Ya en breakeven
    } else {
        //--- Verificar si mover a breakeven
        //--- Placeholder
    }
    
    //--- Actualizar scaling out
    ApplyScalingOut(ticket);
    
    //--- Actualizar stealth mode
    if(m_stealthModeEnabled || m_useVirtualSLTP) {
        UpdateStealthSLTP(ticket);
    }
    
    m_state.lastModification = TimeCurrent();
}

//--- Actualizar estadísticas de posición
void CExecutor::UpdatePositionStats(ulong ticket, double pnl, double pips) {
    if(pnl > 0) {
        m_state.wins++;
        m_state.consecutiveWins++;
        m_state.consecutiveLosses = 0;
        m_state.totalPnl += pnl;
        m_state.totalPips += pips;
    } else if(pnl < 0) {
        m_state.losses++;
        m_state.consecutiveLosses++;
        m_state.consecutiveWins = 0;
        m_state.totalPnl += pnl;
        m_state.totalPips += pips;
    }
    
    //--- Notificar a risk manager
    if(m_riskManager != NULL) {
        m_riskManager.RecordTradeResult(pnl, pnl > 0, MODEL_POSITION);
    }
}

//--- Actualizar estado
void CExecutor::UpdateState() {
    //--- En implementación real: actualizar desde MT5
    //--- Esta es una implementación simplificada
}

//--- RF-019: Verificar órdenes opuestas
void CExecutor::SetOppositeOrderAllowed(bool allowed) {
    //--- Placeholder: se configura externamente
}

//--- Reportes
string CExecutor::GetExecutionSummary() {
    string summary = "=== EXECUTION SUMMARY ===\n";
    summary += "Open Positions: " + IntegerToString(m_state.openPositions) + "\n";
    summary += "Pending Orders: " + IntegerToString(m_state.pendingOrders) + "\n";
    summary += "Total PnL: " + DoubleToString(m_state.totalPnl, 2) + "\n";
    summary += "Total Pips: " + DoubleToString(m_state.totalPips, 1) + "\n";
    summary += "Wins: " + IntegerToString(m_state.wins) + "\n";
    summary += "Losses: " + IntegerToString(m_state.losses) + "\n";
    summary += "Consecutive Wins: " + IntegerToString(m_state.consecutiveWins) + "\n";
    summary += "Consecutive Losses: " + IntegerToString(m_state.consecutiveLosses) + "\n";
    summary += "Magic Number: " + IntegerToString(m_magicNumber) + "\n";
    summary += "Deviation: " + IntegerToString(m_deviation) + " pips\n";
    summary += "Stealth Mode: " + (m_stealthModeEnabled ? "ENABLED" : "DISABLED") + "\n";
    summary += "Virtual SL/TP: " + (m_useVirtualSLTP ? "ENABLED" : "DISABLED") + "\n";
    summary += "=========================";
    return summary;
}

string CExecutor::GetPositionReport() {
    string report = "=== POSITION REPORT ===\n";
    report += "Open Positions: " + IntegerToString(m_state.openPositions) + "\n";
    
    for(int i = 0; i < m_state.openPositions; i++) {
        if(IsPositionOpen(m_state.tickets[i])) {
            report += "---\n";
            report += "Ticket: " + IntegerToString(m_state.tickets[i]) + "\n";
            report += "Symbol: " + PositionGetString(POSITION_SYMBOL) + "\n";
            report += "Type: " + (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? "BUY" : "SELL") + "\n";
            report += "Volume: " + DoubleToString(PositionGetDouble(POSITION_VOLUME), 2) + "\n";
            report += "Entry: " + DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN), 5) + "\n";
            report += "SL: " + DoubleToString(PositionGetDouble(POSITION_SL), 5) + "\n";
            report += "TP: " + DoubleToString(PositionGetDouble(POSITION_TP), 5) + "\n";
            report += "Current: " + DoubleToString(SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_BID), 5) + "\n";
        }
    }
    
    report += "=========================";
    return report;
}

string CExecutor::GetOrderReport() {
    string report = "=== ORDER REPORT ===\n";
    report += "Pending Orders: " + IntegerToString(m_state.pendingOrders) + "\n";
    report += "Total Orders: " + IntegerToString(m_orderCount) + "\n";
    report += "=========================";
    return report;
}

string CExecutor::GetStealthReport() {
    string report = "=== STEALTH REPORT ===\n";
    report += "Stealth Mode: " + (m_stealthModeEnabled ? "ENABLED" : "DISABLED") + "\n";
    report += "Virtual SL/TP: " + (m_useVirtualSLTP ? "ENABLED" : "DISABLED") + "\n";
    report += "Active Stealth Entries: " + IntegerToString(m_state.stealthCount) + "\n";
    
    for(int i = 0; i < m_state.stealthCount; i++) {
        report += "---\n";
        report += "Ticket: " + IntegerToString(m_state.stealthTicket[i]) + "\n";
        report += "Virtual SL: " + DoubleToString(m_state.stealthSL[i], 5) + "\n";
        report += "Virtual TP: " + DoubleToString(m_state.stealthTP[i], 5) + "\n";
    }
    
    report += "=========================";
    return report;
}

//--- RF-011: Obtener ticket de orden Market
ulong CExecutor::GetMarketOrderTicket(Signal &signal) {
    //--- Placeholder
    return 0;
}

//--- RF-012: Obtener ticket de orden Pending
ulong CExecutor::GetPendingOrderTicket(Signal &signal) {
    //--- Placeholder
    return 0;
}

//--- RF-016: Modificar orden pendiente
bool CExecutor::ModifyPendingOrder(ulong ticket, double price, double sl, double tp) {
    if(!m_isInitialized) return false;
    if(!IsTicketValid(ticket)) return false;
    
    //--- En implementación real: usar OrderModify
    //--- Esta es una implementación simplificada
    
    m_utils.LogInfo("Orden pendiente modificada: Ticket " + IntegerToString(ticket));
    return true;
}

//--- RF-016: Modificar SL de posición
bool CExecutor::ModifyPositionSL(ulong ticket, double sl) {
    if(!IsPositionOpen(ticket)) return false;
    return ModifyPosition(ticket, sl, PositionGetDouble(POSITION_TP));
}

//--- RF-016: Modificar TP de posición
bool CExecutor::ModifyPositionTP(ulong ticket, double tp) {
    if(!IsPositionOpen(ticket)) return false;
    return ModifyPosition(ticket, PositionGetDouble(POSITION_SL), tp);
}

//--- RF-054: Verificar Scaling Out activo
bool CExecutor::IsScalingOutActive(ulong ticket) {
    if(!IsPositionOpen(ticket)) return false;
    
    //--- Verificar si hay niveles de scaling pendientes
    for(int i = 1; i <= 3; i++) {
        if(IsScalingLevelHit(ticket, i)) {
            return true;
        }
    }
    return false;
}

//--- RF-054: Configurar niveles de Scaling Out
void CExecutor::SetScalingOutLevels(double level1, double pct1, double level2, double pct2, double level3, double pct3) {
    //--- Placeholder: se configura externamente
}

//--- RF-017: Configurar pips de Breakeven
void CExecutor::SetBreakevenPips(int pips) {
    //--- Placeholder
}

//--- RF-018: Configurar pips de Trailing Stop
void CExecutor::SetTrailingStopPips(int pips) {
    //--- Placeholder
}

void CExecutor::SetTrailingStopStep(int step) {
    //--- Placeholder
}

//--- RF-015: Cancelar orden pendiente
bool CExecutor::CancelPendingOrder(ulong ticket) {
    if(ticket == 0) return false;
    //--- En implementación real: usar OrderDelete
    return true;
}

//--- RF-017: Verificar si Breakeven ha sido alcanzado
bool CExecutor::IsBreakevenHit(ulong ticket) {
    return IsBreakevenActive(ticket);
}

//--- Stealth Mode
bool CExecutor::EnableStealthMode(ulong ticket, double sl, double tp) {
    if(!m_stealthModeEnabled && !m_useVirtualSLTP) return false;
    return SetStealthSLTP(ticket, sl, tp);
}

bool CExecutor::DisableStealthMode(ulong ticket) {
    if(ticket == 0) return false;
    ClearStealthData(ticket);
    return true;
}

bool CExecutor::IsStealthModeActive(ulong ticket) {
    return IsStealthActive(ticket);
}

//--- Getters
ulong CExecutor::GetTicket(int index) const {
    if(index < 0 || index >= m_state.openPositions) return 0;
    return m_state.tickets[index];
}

#endif // __CEXECUTOR_MQH__