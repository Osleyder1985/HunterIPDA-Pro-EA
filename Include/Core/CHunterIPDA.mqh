//+------------------------------------------------------------------+
//|                                                  CHunterIPDA.mqh |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Esta es la clase principal del EA. Coordina todos los módulos    |
//| y gestiona el ciclo de vida del sistema:                         |
//| - Inicialización y configuración                                 |
//| - Bucle principal (OnTick) optimizado                            |
//| - Gestión de estados (23 estados)                                |
//| - Control de Drawdown Anual (15%)                                |
//| - Control de Frecuencia por modelo                               |
//|                                                                  |
//| RFs asociados:                                                   |
//|   - Todos los RFs del sistema (coordinación)                     |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CLogger: Logging y estadísticas                              |
//|   - CLicense: Licencias                                          |
//|   - CPanel: Panel de control                                     |
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

#ifndef __CHUNTERIPDA_MQH__
#define __CHUNTERIPDA_MQH__

#include "CConstants.mqh"
#include "CUtils.mqh"
#include "CConfig.mqh"
#include "CLogger.mqh"
#include "CLicense.mqh"
#include "CPanel.mqh"

//+------------------------------------------------------------------+
//| CLASE CHunterIPDA - Clase Principal del EA                       |
//+------------------------------------------------------------------+
class CHunterIPDA {
private:
    //--- Dominio Core
    CConfig*           m_config;
    CLogger*           m_logger;
    CLicense*          m_license;
    CPanel*            m_panel;
    CUtils*            m_utils;
    
    //--- Estado
    ENUM_EA_STATE      m_state;
    bool               m_isInitialized;
    bool               m_isPaused;
    datetime           m_lastTickTime;
    datetime           m_lastAnalysisTime;
    int                m_tickCount;
    int                m_weekNumber;
    double             m_annualDrawdown;
    ENUM_TRADING_MODEL m_currentModel;
    
    //--- Contadores de frecuencia por modelo
    int                m_positionTradesThisYear;
    int                m_swingTradesThisYear;
    int                m_osokTradesThisWeek;
    int                m_dayTradesToday;
    int                m_scalpTradeToday;
    int                m_megaTradesThisYear;
    int                m_stockTradesThisMonth;
    
    //--- Temporizadores para optimización
    int                m_analysisTimer;
    int                m_panelUpdateTimer;
    datetime           m_lastDayCheck;
    datetime           m_lastWeekCheck;
    datetime           m_lastMonthCheck;
    
    //--- Métodos privados
    bool               InitializeModules();
    void               DeinitializeModules();
    bool               ValidateConditions();
    void               ProcessTick();
    void               ProcessAnalysis();
    void               ProcessSignal();
    void               ProcessExecution();
    void               ProcessManagement();
    void               UpdateState();
    void               CheckWeekReset();
    void               CheckDayReset();
    void               CheckMonthReset();
    void               CheckFrequencyLimits();
    void               CheckDrawdownLimit();
    void               HandleError(int errorCode, string errorMsg);
    void               LogStateChange(ENUM_EA_STATE oldState, ENUM_EA_STATE newState);
    
public:
    //--- Constructor / Destructor
    CHunterIPDA();
    ~CHunterIPDA();
    
    //--- Métodos Públicos (llamados desde el EA principal)
    bool OnInit();
    void OnTick();
    void OnDeinit();
    void OnTrade();
    void OnTimer();
    
    //--- Getters
    ENUM_EA_STATE GetState() const { return m_state; }
    bool IsInitialized() const { return m_isInitialized; }
    bool IsPaused() const { return m_isPaused; }
    double GetAnnualDrawdown() const { return m_annualDrawdown; }
    ENUM_TRADING_MODEL GetCurrentModel() const { return m_currentModel; }
    int GetPositionTradesThisYear() const { return m_positionTradesThisYear; }
    int GetSwingTradesThisYear() const { return m_swingTradesThisYear; }
    int GetOSOKTradesThisWeek() const { return m_osokTradesThisWeek; }
    int GetDayTradesToday() const { return m_dayTradesToday; }
    int GetScalpTradesToday() const { return m_scalpTradeToday; }
    int GetMegaTradesThisYear() const { return m_megaTradesThisYear; }
    int GetStockTradesThisMonth() const { return m_stockTradesThisMonth; }
    
    //--- Setters
    void Pause();
    void Resume();
    void Reset();
    void SetTradingModel(ENUM_TRADING_MODEL model);
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CHunterIPDA::CHunterIPDA() {
    m_config = NULL;
    m_logger = NULL;
    m_license = NULL;
    m_panel = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_isPaused = false;
    m_state = STATE_INIT;
    m_lastTickTime = 0;
    m_lastAnalysisTime = 0;
    m_tickCount = 0;
    m_weekNumber = 0;
    m_annualDrawdown = 0.0;
    m_currentModel = MODEL_SHORT_TERM;
    
    //--- Inicializar contadores
    m_positionTradesThisYear = 0;
    m_swingTradesThisYear = 0;
    m_osokTradesThisWeek = 0;
    m_dayTradesToday = 0;
    m_scalpTradeToday = 0;
    m_megaTradesThisYear = 0;
    m_stockTradesThisMonth = 0;
    
    //--- Inicializar temporizadores
    m_analysisTimer = 0;
    m_panelUpdateTimer = 0;
    m_lastDayCheck = 0;
    m_lastWeekCheck = 0;
    m_lastMonthCheck = 0;
}

//--- Destructor
CHunterIPDA::~CHunterIPDA() {
    DeinitializeModules();
}

//--- Inicialización (llamado desde OnInit del EA)
bool CHunterIPDA::OnInit() {
    Print("=== HUNTERIPDA PRO EA - Inicializando ===");
    Print("Versión: 1.7");
    Print("Fecha: 21/07/2026");
    
    //--- Crear instancias de módulos
    m_utils = new CUtils();
    if(!m_utils.Init()) {
        Print("Error: No se pudo inicializar CUtils");
        return false;
    }
    
    m_config = new CConfig();
    //--- La configuración se cargará desde el EA principal
    //--- Por ahora, usamos valores por defecto
    SConfig defaultConfig;
    defaultConfig.SetDefaults();
    if(!m_config.Init(m_utils, defaultConfig)) {
        m_utils.LogError("CHunterIPDA::OnInit - Error al inicializar CConfig");
        return false;
    }
    
    m_logger = new CLogger();
    if(!m_logger.Init(m_config, m_utils)) {
        m_utils.LogError("CHunterIPDA::OnInit - Error al inicializar CLogger");
        return false;
    }
    
    m_license = new CLicense();
    if(!m_license.Init(m_config, m_utils)) {
        m_utils.LogError("CHunterIPDA::OnInit - Error al inicializar CLicense");
        return false;
    }
    
    //--- Verificar licencia
    if(!m_license.IsLicensed()) {
        m_utils.LogError("CHunterIPDA::OnInit - Licencia no válida");
        return false;
    }
    
    m_panel = new CPanel();
    if(!m_panel.Init(m_config, m_logger, m_utils)) {
        m_utils.LogWarning("CHunterIPDA::OnInit - Panel no disponible (continúa sin panel)");
        //--- No es crítico, continuamos
    }
    
    //--- Inicializar contadores de tiempo
    m_lastDayCheck = TimeCurrent();
    m_lastWeekCheck = TimeCurrent();
    m_lastMonthCheck = TimeCurrent();
    m_weekNumber = m_utils.GetWeekNumber(TimeCurrent());
    
    m_isInitialized = true;
    m_state = STATE_IDLE;
    
    m_utils.LogInfo("=== HUNTERIPDA PRO EA INICIALIZADO CORRECTAMENTE ===");
    m_utils.LogInfo("Modelo: " + m_utils.GetModelName(m_config.GetTradingModel()));
    m_utils.LogInfo("Licencia: " + m_license.GetLicenseSummary());
    
    return true;
}

//--- Bucle principal (llamado desde OnTick del EA)
void CHunterIPDA::OnTick() {
    if(!m_isInitialized || m_isPaused) return;
    
    m_tickCount++;
    m_lastTickTime = TimeCurrent();
    
    //--- Procesar tick
    ProcessTick();
}

//--- Desinicialización (llamado desde OnDeinit del EA)
void CHunterIPDA::OnDeinit() {
    m_utils.LogInfo("=== HUNTERIPDA PRO EA - Cerrando ===");
    DeinitializeModules();
    m_isInitialized = false;
}

//--- Evento de trading (llamado desde OnTrade del EA)
void CHunterIPDA::OnTrade() {
    if(!m_isInitialized || m_isPaused) return;
    ProcessManagement();
}

//--- Evento de timer (llamado desde OnTimer del EA)
void CHunterIPDA::OnTimer() {
    if(!m_isInitialized || m_isPaused) return;
    
    //--- Actualizar panel cada 5 segundos
    m_panelUpdateTimer++;
    if(m_panelUpdateTimer >= 5) {
        m_panelUpdateTimer = 0;
        if(m_panel != NULL && m_panel.IsVisible()) {
            m_panel.Update();
        }
    }
}

//--- Procesar tick
void CHunterIPDA::ProcessTick() {
    //--- Verificar condiciones de mercado
    if(!ValidateConditions()) {
        return;
    }
    
    //--- Verificar límites diarios/semanales
    CheckDayReset();
    CheckWeekReset();
    CheckMonthReset();
    CheckFrequencyLimits();
    CheckDrawdownLimit();
    
    //--- Procesar según estado
    switch(m_state) {
        case STATE_IDLE:
            m_state = STATE_ANALYZING;
            ProcessAnalysis();
            break;
            
        case STATE_ANALYZING:
            ProcessAnalysis();
            break;
            
        case STATE_SIGNAL:
            ProcessSignal();
            break;
            
        case STATE_EXECUTING:
            ProcessExecution();
            break;
            
        case STATE_IN_TRADE:
            ProcessManagement();
            break;
            
        default:
            break;
    }
    
    UpdateState();
}

//--- Procesar análisis
void CHunterIPDA::ProcessAnalysis() {
    //--- Verificar si es momento de analizar (cada X ticks)
    m_analysisTimer++;
    if(m_analysisTimer < 10) return;  // Analizar cada 10 ticks
    m_analysisTimer = 0;
    
    //--- Aquí se integrarán los módulos de análisis
    //--- CDetector, CContext, CMacroAnalyzer, etc.
    
    //--- Por ahora, simulamos una señal simple
    //--- En el futuro, esto llamará a los módulos reales
    
    m_state = STATE_SIGNAL;
}

//--- Procesar señal
void CHunterIPDA::ProcessSignal() {
    //--- Aquí se evaluará la señal detectada
    //--- Por ahora, no hacemos nada
    
    m_state = STATE_IDLE;
}

//--- Procesar ejecución
void CHunterIPDA::ProcessExecution() {
    //--- Aquí se ejecutarán las órdenes
    //--- CExecutor, CEntryManager, CRiskManager
    
    m_state = STATE_IN_TRADE;
}

//--- Procesar gestión
void CHunterIPDA::ProcessManagement() {
    //--- Aquí se gestionarán las posiciones abiertas
    //--- CExecutor (gestión de posiciones)
}

//--- Actualizar estado
void CHunterIPDA::UpdateState() {
    //--- Si hay drawdown excesivo, pausar
    if(m_annualDrawdown > DRAWDOWN_ANNUAL_LIMIT) {
        m_state = STATE_PAUSED;
        m_utils.LogWarning("Drawdown anual excedido: " + DoubleToString(m_annualDrawdown, 2) + "%");
    }
}

//--- Verificar condiciones de mercado
bool CHunterIPDA::ValidateConditions() {
    if(!m_license.IsLicensed()) {
        HandleError(-1, "Licencia no válida");
        return false;
    }
    
    //--- Verificar que el mercado esté abierto
    //--- (implementación simplificada)
    return true;
}

//--- Verificar reset diario
void CHunterIPDA::CheckDayReset() {
    datetime now = TimeCurrent();
    if(now - m_lastDayCheck >= 86400) {  // 24 horas
        m_dayTradesToday = 0;
        m_scalpTradeToday = 0;
        m_lastDayCheck = now;
        m_utils.LogDebug("Reset diario de contadores");
    }
}

//--- Verificar reset semanal
void CHunterIPDA::CheckWeekReset() {
    datetime now = TimeCurrent();
    int currentWeek = m_utils.GetWeekNumber(now);
    if(currentWeek != m_weekNumber) {
        m_osokTradesThisWeek = 0;
        m_weekNumber = currentWeek;
        m_lastWeekCheck = now;
        m_utils.LogDebug("Reset semanal de contadores");
    }
}

//--- Verificar reset mensual
void CHunterIPDA::CheckMonthReset() {
    datetime now = TimeCurrent();
    if(now - m_lastMonthCheck >= 2592000) {  // 30 días
        m_stockTradesThisMonth = 0;
        m_lastMonthCheck = now;
        m_utils.LogDebug("Reset mensual de contadores");
    }
}

//--- Verificar límites de frecuencia
void CHunterIPDA::CheckFrequencyLimits() {
    //--- Verificar límites según el modelo activo
    switch(m_currentModel) {
        case MODEL_POSITION:
            if(m_positionTradesThisYear >= MAX_POSITION_TRADES_YEAR) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Position Trades alcanzado");
            }
            break;
            
        case MODEL_SWING:
            if(m_swingTradesThisYear >= MAX_SWING_TRADES_YEAR) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Swing Trades alcanzado");
            }
            break;
            
        case MODEL_OSOK:
            if(m_osokTradesThisWeek >= MAX_OSOK_TRADES_WEEK) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de OSOK Trades alcanzado");
            }
            break;
            
        case MODEL_DAY_TRADING:
            if(m_dayTradesToday >= MAX_DAY_TRADES_DAY) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Day Trades alcanzado");
            }
            break;
            
        case MODEL_SCALPING:
            if(m_scalpTradeToday >= MAX_SCALP_TRADES_DAY) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Scalp Trades alcanzado");
            }
            break;
            
        case MODEL_MEGA_TRADE:
            if(m_megaTradesThisYear >= MAX_MEGA_TRADES_YEAR) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Mega Trades alcanzado");
            }
            break;
            
        case MODEL_STOCK_TRADING:
            if(m_stockTradesThisMonth >= MAX_STOCK_TRADES_MONTH) {
                m_state = STATE_PAUSED;
                m_utils.LogWarning("Límite de Stock Trades alcanzado");
            }
            break;
            
        default:
            break;
    }
}

//--- Verificar límite de drawdown
void CHunterIPDA::CheckDrawdownLimit() {
    if(m_annualDrawdown > DRAWDOWN_ANNUAL_LIMIT) {
        m_state = STATE_PAUSED;
        m_utils.LogError("Drawdown anual excedido: " + DoubleToString(m_annualDrawdown, 2) + "%");
    }
}

//--- Manejar error
void CHunterIPDA::HandleError(int errorCode, string errorMsg) {
    if(m_logger != NULL) {
        m_logger.LogError(errorMsg, errorCode);
    } else {
        Print("ERROR: " + errorMsg + " (código: " + IntegerToString(errorCode) + ")");
    }
}

//--- Registrar cambio de estado
void CHunterIPDA::LogStateChange(ENUM_EA_STATE oldState, ENUM_EA_STATE newState) {
    if(m_utils != NULL) {
        m_utils.LogDebug("Estado: " + m_utils.GetStateName(oldState) + " -> " + m_utils.GetStateName(newState));
    }
}

//--- Inicializar módulos
bool CHunterIPDA::InitializeModules() {
    //--- Ya se inicializan en OnInit
    return true;
}

//--- Desinicializar módulos
void CHunterIPDA::DeinitializeModules() {
    //--- Liberar memoria de los módulos
    if(m_panel != NULL) { delete m_panel; m_panel = NULL; }
    if(m_license != NULL) { delete m_license; m_license = NULL; }
    if(m_logger != NULL) { delete m_logger; m_logger = NULL; }
    if(m_config != NULL) { delete m_config; m_config = NULL; }
    if(m_utils != NULL) { delete m_utils; m_utils = NULL; }
}

//--- Pausar EA
void CHunterIPDA::Pause() {
    if(m_isPaused) return;
    m_isPaused = true;
    m_state = STATE_PAUSED;
    m_utils.LogInfo("EA pausado manualmente");
}

//--- Reanudar EA
void CHunterIPDA::Resume() {
    if(!m_isPaused) return;
    m_isPaused = false;
    m_state = STATE_IDLE;
    m_utils.LogInfo("EA reanudado");
}

//--- Resetear EA
void CHunterIPDA::Reset() {
    m_utils.LogInfo("Resetear EA...");
    m_positionTradesThisYear = 0;
    m_swingTradesThisYear = 0;
    m_osokTradesThisWeek = 0;
    m_dayTradesToday = 0;
    m_scalpTradeToday = 0;
    m_megaTradesThisYear = 0;
    m_stockTradesThisMonth = 0;
    m_annualDrawdown = 0.0;
    m_state = STATE_IDLE;
    m_utils.LogInfo("EA reseteado");
}

//--- Establecer modelo de trading
void CHunterIPDA::SetTradingModel(ENUM_TRADING_MODEL model) {
    m_currentModel = model;
    if(m_config != NULL) {
        m_config.SetTradingModel(model);
    }
    m_utils.LogInfo("Modelo de trading cambiado a: " + m_utils.GetModelName(model));
}

#endif // __CHUNTERIPDA_MQH__