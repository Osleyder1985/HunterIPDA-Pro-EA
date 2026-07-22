//+------------------------------------------------------------------+
//|                                                      CConfig.mqh |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona toda la configuración del EA:               |
//| - Lectura de inputs de MT5                                       |
//| - Validación de parámetros                                       |
//| - Persistencia de configuración                                  |
//| - Parámetros de todos los modelos y dominios                     |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-042: Inputs de Configuración                                |
//|   RF-043: Panel en Gráfico                                       |
//|   RF-044: Botón de Activación                                    |
//|   RF-045: Confirmación de Configuración                          |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
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
//| 1.1     | 21/07/2026  | Eliminada dependencia de Input*() y      |
//|         |             | LoadFromInputs(), ahora recibe SConfig   |
//|         |             | desde el EA principal                    |
//| 1.2     | 21/07/2026  | Corregida firma de Init() para usar      |
//|         |             | SConfig &config                          |
//+------------------------------------------------------------------+

#ifndef __CCONFIG_MQH__
#define __CCONFIG_MQH__

#include "CConstants.mqh"
#include "CUtils.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURA DE CONFIGURACIÓN                                      |
//+------------------------------------------------------------------+
struct SConfig {
    //--- Generales
    int                magicNumber;        // Número mágico del EA
    string             comment;            // Comentario para órdenes
    bool               enabled;            // EA activado/desactivado
    ENUM_TRADING_MODEL tradingModel;       // Modelo de trading
    int                maxOrdersPerWeek;   // Máximo de operaciones por semana
    
    //--- Símbolos
    string             symbolList;         // Lista de símbolos a operar
    ENUM_TIMEFRAMES    timeframe;          // Temporalidad principal
    ENUM_TIMEFRAMES    htf1;               // Temporalidad alta 1 (contexto)
    ENUM_TIMEFRAMES    htf2;               // Temporalidad alta 2 (bias)
    
    //--- Gestión de Riesgo
    double             riskPerTrade;              // Riesgo por operación (%)
    double             riskPerSwingTrade;         // Riesgo por swing trading (%)
    double             riskPerDayTrade;           // Riesgo por day trading (%)
    double             riskPerScalpTrade;         // Riesgo por scalping (%)
    double             riskPerMegaTrade;          // Riesgo por Mega Trade (%)
    double             riskPerStockTrade;         // Riesgo por Stock Trading (%)
    double             maxDrawdown;               // Drawdown máximo permitido (%)
    double             minRR;                     // R:R mínimo
    double             optimalRR;                 // R:R óptimo para scaling out
    double             fixedLot;                  // Lote fijo (0 = dinámico)
    double             maxSpread;                 // Spread máximo permitido (pips)
    double             maxSpreadScalp;            // Spread máximo para scalping (pips)
    double             maxSpreadMega;             // Spread máximo para Mega Trades (pips)
    double             maxSlippage;               // Slippage máximo permitido (pips)
    double             maxSlippageScalp;          // Slippage máximo para scalping (pips)
    double             annualDrawdownLimit;       // Límite de drawdown anual (%)
    double             equityAllocation;          // Porcentaje del equity para posición trading
    int                maxPositionTradesPerYear;  // Máx operaciones de posición por año
    int                maxSwingTradesPerYear;     // Máx operaciones de swing por año
    int                maxMegaTradesPerYear;      // Máx Mega Trades por año
    
    //--- Stop Loss y Take Profit
    bool               slDynamic;          // SL dinámico (true) o fijo (false)
    int                slDynamicPips;      // Pips para SL fijo
    int                slSwingPips;        // Pips para SL en swing trading
    int                slDayPips;          // Pips para SL en day trading
    int                slScalpPips;        // Pips para SL en scalping
    int                slMegaPips;         // Pips para SL en Mega Trades
    bool               tpDynamic;          // TP dinámico (true) o fijo (false)
    int                tpScalpPips;        // Pips para TP en scalping
    double             tpMegaRRequirement; // R:R mínimo para Mega Trades
    
    //--- Scaling Out
    bool               scalingOutEnabled;  // Activar Scaling Out
    double             soLevel1RR;         // Nivel R:R para TP1
    double             soLevel1Pct;        // Porcentaje a cerrar en TP1
    double             soLevel2RR;         // Nivel R:R para TP2
    double             soLevel2Pct;        // Porcentaje a cerrar en TP2
    double             soLevel3RR;         // Nivel R:R para TP3
    double             soLevel3Pct;        // Porcentaje a cerrar en TP3
    
    //--- Trailing Stop
    bool               tsIPDAEnabled;         // Trailing Stop IPDA
    int                tsIPDAInitial;         // Lookback inicial (días)
    int                tsIPDAMid;             // Lookback al 50% (días)
    int                tsIPDAFinal;           // Lookback al 75% (días)
    bool               tsDayEnabled;          // Trailing stop para day trading
    int                tsDayBreakevenPips;    // Pips para breakeven en day trading
    bool               tsScalpEnabled;        // Trailing stop para scalping
    int                tsScalpBreakevenPips;  // Pips para breakeven en scalping
    bool               tsMegaEnabled;         // Trailing stop para Mega Trades
    
    //--- Breakeven
    bool               breakevenEnabled;         // Activar Breakeven
    int                breakevenActivationPips;  // Pips para activar Breakeven
    
    //--- Filtros
    bool               filterTimeEnabled;        // Filtro por horario
    int                filterTimeStart;          // Hora de inicio (GMT)
    int                filterTimeEnd;            // Hora de fin (GMT)
    bool               filterDayEnabled;         // Filtro por día de la semana
    bool               filterDayMonday;          // Operar lunes
    bool               filterDayTuesday;         // Operar martes
    bool               filterDayWednesday;       // Operar miércoles
    bool               filterDayThursday;        // Operar jueves
    bool               filterDayFriday;          // Operar viernes
    bool               filterVolatilityEnabled;  // Filtro por volatilidad
    int                filterVolatilityMax;      // ATR máximo permitido (pips)
    
    //--- Análisis Macro
    bool               macro10YearEnabled;         // Análisis 10-Year Treasury Note
    bool               macroDXYEnabled;            // Análisis Dólar Index
    bool               macroIntermarketEnabled;    // Análisis intermercado
    bool               macroSeasonalEnabled;       // Tendencias estacionales
    bool               macroInterestRatesEnabled;  // Diferenciales de tasas
    bool               macroCOTEnabled;            // Análisis de COT
    bool               macroOIEnabled;             // Análisis de Open Interest
    bool               macroNewsEnabled;           // Filtro de eventos de mercado
    bool               macroPremiumCarryEnabled;   // Premium vs Carrying Charge
    
    //--- Multi-Asset Analysis
    bool               maEnabled;            // Análisis Multi-Asset
    string             maAssetClasses;       // Clases de activos a monitorear
    bool               maRiskOnOffEnabled;   // Detección Risk On/Off
    int                maAlignmentScoreMin;  // Score mínimo de alineación
    bool               maDashboardEnabled;   // Mostrar dashboard multi-asset
    bool               maCacheEnabled;       // Caching para Multi-Asset
    
    //--- Quarterly Shifts
    bool               qsEnabled;            // Análisis de Quarterly Shifts
    int                qsLookBack;           // Look back máximo (días)
    int                qsCastForward;        // Cast forward máximo (días)
    
    //--- Short-Term Trading
    bool               stEnabled;            // Modelo Short-Term Trading
    ENUM_TIMEFRAMES    stExecutableTF;       // Temporalidad ejecutable
    int                stMinDuration;        // Duración mínima (días)
    int                stMaxDuration;        // Duración máxima (días)
    int                stMinPipsObjective;   // Mínimo de pips objetivo
    int                stMaxPipsObjective;   // Máximo de pips objetivo
    
    //--- One Shot One Kill (OSOK)
    bool               osokEnabled;               // Modo OSOK
    bool               osokSeasonalRequired;      // Seasonal obligatorio
    bool               osokCOTRequired;           // COT obligatorio
    bool               osokKillZoneEnabled;       // Ejecución solo en Kill Zones
    int                osokKillZoneAsianStart;    // Hora inicio Kill Zone Asia (NY)
    int                osokKillZoneAsianEnd;      // Hora fin Kill Zone Asia (NY)
    int                osokKillZoneLondonStart;   // Hora inicio Kill Zone London (NY)
    int                osokKillZoneLondonEnd;     // Hora fin Kill Zone London (NY)
    int                osokKillZoneNYStart;       // Hora inicio Kill Zone NY (NY)
    int                osokKillZoneNYEnd;         // Hora fin Kill Zone NY (NY)
    int                osokMaxTradesPerWeek;      // Máximo de operaciones OSOK por semana
    int                osokProjectionTolerance;   // Tolerancia de proyección (pips)
    ENUM_PROJECTION_METHOD osokProjectionMethod;  // Método de proyección
    double             osokFIBExtension1;         // Primer nivel de extensión Fibonacci
    double             osokFIBExtension2;         // Segundo nivel de extensión Fibonacci
    
    //--- Weekly Range Profiles
    bool               wrpEnabled;           // Perfiles de rango semanal
    bool               wrpSeekDestroyAvoid;  // Evitar perfiles Seek and Destroy
    bool               wrpSummerAvoidance;   // Evitar operativas en verano
    
    //--- Swing Trading
    bool               swingEnabled;              // Modo swing trading
    ENUM_TIMEFRAMES    swingEntryTF;              // Temporalidad de ejecución
    int                swingMinDuration;          // Duración mínima (días)
    int                swingMaxDuration;          // Duración máxima (días)
    int                swingMinPips;              // Mínimo de pips objetivo
    int                swingMaxPips;              // Máximo de pips objetivo
    bool               swingSeasonalRequired;     // Seasonal obligatorio
    bool               swingMajorMarketRequired;  // Major Market Analysis
    bool               swingCOTRequired;          // COT obligatorio
    bool               swingOIRequired;           // Open Interest obligatorio
    int                swingHallmarksMin;         // Mínimo de hallmarks requeridos
    double             swingProfit25Pct;          // Porcentaje a cerrar al 25%
    bool               swingReentry50Pct;         // Reentrada al 50%
    
    //--- Day Trading
    bool               dtEnabled;                 // Modelo Day Trading
    ENUM_TIMEFRAMES    dtExecutableTF;            // Temporalidad ejecutable
    bool               dtIPDATrueDay;             // IPDA True Day
    bool               dtKillZoneLondon;          // London Kill Zone
    bool               dtKillZoneNY;              // New York Kill Zone
    bool               dtKillZoneLC;              // London Close Kill Zone
    bool               dtCBDREnabled;             // CBDR
    int                dtCBDRStandardDeviations;  // Número de SD
    int                dtMaxTradesPerDay;         // Máximo de operaciones por día
    int                dtProfitTargetPips;        // Objetivo diario de pips
    bool               dtNewsAvoidance;           // Evitar eventos de alto impacto
    
    //--- Scalping
    bool               scEnabled;                // Modelo Scalping
    ENUM_TIMEFRAMES    scExecutableTF;           // Temporalidad ejecutable
    int                scMaxTradesPerDay;        // Máximo de operaciones por día
    bool               scAsianSessionEnabled;    // Sesión asiática
    bool               scNYSessionEnabled;       // Sesión NY
    bool               scPriceEngineEnabled;     // Price Engine Models
    bool               scADRExitEnabled;         // Regla de salida ADR
    int                scADRExitDistance;        // Distancia al ADR para salida (pips)
    bool               scBreadButterEnabled;     // Bread & Butter Setups
    bool               scFillingNumbersEnabled;  // Filling the Numbers
    
    //--- Mega Trades
    bool               megaEnabled;                  // Modelo Mega Trades
    double             megaMinRR;                    // R:R mínimo
    int                megaMaxPerYear;               // Máximo por año
    int                megaAlignmentScoreMin;        // Score mínimo de alineación
    bool               megaDecisionTreeEnabled;      // Árbol de decisión
    bool               megaScenarioPlanningEnabled;  // Planificación de escenarios
    bool               megaTopDownEnabled;           // Análisis Top-Down
    ENUM_TIMEFRAMES    megaHTFTimeframe;             // Temporalidad alta
    ENUM_TIMEFRAMES    megaEntryTF;                  // Temporalidad de ejecución
    int                megaDurationMonths;           // Duración esperada (meses)
    
    //--- Stock Trading
    bool               stockEnabled;                 // Modelo Stock Trading
    bool               stockWatchlistEnabled;        // Watchlists automáticas
    bool               stockCANSLIMEnabled;          // Filtro CAN SLIM
    double             stockCANSLIMEarningsGrowth;   // Crecimiento de earnings mínimo
    double             stockCANSLIMInstitutionalPct; // Propiedad institucional mínima
    bool               stockSeasonalEnabled;         // Análisis estacional
    bool               stockSMTEnabled;              // SMT divergencia
    bool               stockOptionsEnabled;          // Selección de opciones
    int                stockOptionsExpiryDays;       // Días hasta expiración
    bool               stockDogsOfDowEnabled;        // Dogs of the Dow
    int                stockMaxTradesPerMonth;       // Máximo de operaciones por mes
    
    //--- Trading Plan & Psychology
    bool               tpPlanEnabled;             // Trading Plan
    double             tpDailyLossLimit;          // Límite de pérdida diaria (%)
    double             tpWeeklyLossLimit;         // Límite de pérdida semanal (%)
    double             tpMonthlyLossLimit;        // Límite de pérdida mensual (%)
    bool               tpCooldownEnabled;         // Cooldown
    int                tpCooldownLosses;          // Número de pérdidas consecutivas para cooldown
    int                tpCooldownDays;            // Días de cooldown
    bool               tpDisciplineScoreEnabled;  // Cálculo de disciplina score
    bool               tpJournalEnabled;          // Sistema de journal
    int                tpJournalBufferSize;       // Tamaño del buffer para journal
    bool               tpPerformanceGradeEnabled; // Cálculo de performance grade
    
    //--- Técnicas de Entrada
    bool               entryStopEnabled;   // Stop Entries
    bool               entryLimitEnabled;  // Limit Entries
    bool               entryHybridMode;    // Modo híbrido
    bool               entryMarketEnabled; // Market Entries para scalping
    
    //--- PD Arrays
    bool               pdaEnabled;          // PD Arrays
    bool               pdaPriorityBreaker;  // Priorizar Breaker
    
    //--- Mitigación de Pérdidas
    bool               mitEnabled;           // Mitigación de pérdidas
    double             mitReductionFactor;   // Factor de reducción tras pérdida
    int                mitConsecutiveLosses; // Pérdidas consecutivas para reducción
    bool               mitR2Enabled;         // Objetivo R2
    
    //--- COT Analysis
    bool               cotEnabled;         // Análisis de COT
    int                cotUpdateInterval;  // Intervalo de actualización (días)
    int                cotRangeMonths;     // Rango de meses
    bool               cotCacheEnabled;    // Caching
    
    //--- Open Interest
    bool               oiEnabled;            // Análisis de Open Interest
    int                oiUpdateInterval;     // Intervalo de actualización (días)
    double             oiChangeSignificance; // Cambio mínimo significativo (%)
    bool               oiCacheEnabled;       // Caching
    
    //--- Logging y Panel
    bool               logEnabled;           // Logging
    ENUM_LOG_LEVEL     logLevel;             // Nivel de logging
    bool               panelEnabled;         // Panel en gráfico
    int                panelUpdateInterval;  // Intervalo de actualización (segundos)
    
    //--- Licencia
    string             licenseKey;           // Clave de licencia
    
    //--- Bonus Hunter
    bool               bonusHunterEnabled;   // Módulo Bonus Hunter
    double             bonusRiskPerTrade;    // Riesgo por operación (%)
    int                bonusMaxTradesPerDay; // Máximo de operaciones por día
    double             bonusVolumeThreshold; // Umbral de volumen por bono
    double             bonusMinProfit;       // Profit mínimo para liberar bono
    int                bonusMaxLossStreak;   // Máximo de pérdidas consecutivas
    int                bonusCooldownMinutes; // Cooldown tras pérdidas (minutos)
    
    //--- Valores por defecto
    void               SetDefaults();
    
    //--- Validación
    bool               Validate(CUtils* utils);
};

//+------------------------------------------------------------------+
//| CLASE CConfig - Gestor de Configuración                          |
//+------------------------------------------------------------------+
class CConfig {
private:
    //--- Miembros privados
    SConfig            m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    
    //--- Métodos privados
    bool               ValidateParameters();
    
public:
    //--- Constructor / Destructor
    CConfig();
    ~CConfig();
    
    //--- Inicialización
    bool Init(CUtils* utils, SConfig &config);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Cargar configuración desde inputs (llamado desde el EA principal)
    void LoadFromInputs();

    //--- Getters
    SConfig GetConfig() const { return m_config; }
    int GetMagicNumber() const { return m_config.magicNumber; }
    string GetComment() const { return m_config.comment; }
    bool IsEnabled() const { return m_config.enabled; }
    ENUM_TRADING_MODEL GetTradingModel() const { return m_config.tradingModel; }
    int GetMaxOrdersPerWeek() const { return m_config.maxOrdersPerWeek; }
    
    //--- Setters
    void SetEnabled(bool enabled) { m_config.enabled = enabled; }
    void SetTradingModel(ENUM_TRADING_MODEL model) { m_config.tradingModel = model; }
    
    //--- Validación
    bool IsValid() const { return m_isInitialized; }
    string GetLastError() const;
    
    //--- Reportes
    string GetSummary();
    string GetConfigReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN DE SConfig                                        |
//+------------------------------------------------------------------+

void SConfig::SetDefaults() {
    //--- Generales
    magicNumber = 20260720;
    comment = "HunterIPDA Pro EA";
    enabled = true;
    tradingModel = MODEL_SHORT_TERM;
    maxOrdersPerWeek = 5;
    
    //--- Símbolos
    symbolList = "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD,EURGBP,EURJPY";
    timeframe = PERIOD_H1;
    htf1 = PERIOD_D1;
    htf2 = PERIOD_W1;
    
    //--- Gestión de Riesgo
    riskPerTrade = 1.5;
    riskPerSwingTrade = 1.5;
    riskPerDayTrade = 1.5;
    riskPerScalpTrade = 0.75;
    riskPerMegaTrade = 0.3;
    riskPerStockTrade = 1.5;
    maxDrawdown = 20.0;
    minRR = 3.0;
    optimalRR = 5.0;
    fixedLot = 0.0;
    maxSpread = 3.0;
    maxSpreadScalp = 0.5;
    maxSpreadMega = 2.0;
    maxSlippage = 3.0;
    maxSlippageScalp = 1.0;
    annualDrawdownLimit = 15.0;
    equityAllocation = 30.0;
    maxPositionTradesPerYear = 3;
    maxSwingTradesPerYear = 8;
    maxMegaTradesPerYear = 3;
    
    //--- Stop Loss y Take Profit
    slDynamic = true;
    slDynamicPips = 20;
    slSwingPips = 70;
    slDayPips = 20;
    slScalpPips = 8;
    slMegaPips = 200;
    tpDynamic = true;
    tpScalpPips = 8;
    tpMegaRRequirement = 5.0;
    
    //--- Scaling Out
    scalingOutEnabled = true;
    soLevel1RR = 3.0;
    soLevel1Pct = 50.0;
    soLevel2RR = 5.0;
    soLevel2Pct = 25.0;
    soLevel3RR = 9.0;
    soLevel3Pct = 25.0;
    
    //--- Trailing Stop
    tsIPDAEnabled = true;
    tsIPDAInitial = 40;
    tsIPDAMid = 20;
    tsIPDAFinal = 10;
    tsDayEnabled = true;
    tsDayBreakevenPips = 15;
    tsScalpEnabled = true;
    tsScalpBreakevenPips = 5;
    tsMegaEnabled = true;
    
    //--- Breakeven
    breakevenEnabled = true;
    breakevenActivationPips = 15;
    
    //--- Filtros
    filterTimeEnabled = false;
    filterTimeStart = 0;
    filterTimeEnd = 23;
    filterDayEnabled = false;
    filterDayMonday = true;
    filterDayTuesday = true;
    filterDayWednesday = true;
    filterDayThursday = true;
    filterDayFriday = true;
    filterVolatilityEnabled = false;
    filterVolatilityMax = 100;
    
    //--- Análisis Macro
    macro10YearEnabled = true;
    macroDXYEnabled = true;
    macroIntermarketEnabled = true;
    macroSeasonalEnabled = true;
    macroInterestRatesEnabled = true;
    macroCOTEnabled = true;
    macroOIEnabled = true;
    macroNewsEnabled = true;
    macroPremiumCarryEnabled = true;
    
    //--- Multi-Asset Analysis
    maEnabled = true;
    maAssetClasses = "Bonds,Commodities,Currencies,Stocks";
    maRiskOnOffEnabled = true;
    maAlignmentScoreMin = 70;
    maDashboardEnabled = true;
    maCacheEnabled = true;
    
    //--- Quarterly Shifts
    qsEnabled = true;
    qsLookBack = 60;
    qsCastForward = 60;
    
    //--- Short-Term Trading
    stEnabled = true;
    stExecutableTF = PERIOD_H4;
    stMinDuration = 1;
    stMaxDuration = 5;
    stMinPipsObjective = 30;
    stMaxPipsObjective = 100;
    
    //--- One Shot One Kill (OSOK)
    osokEnabled = false;
    osokSeasonalRequired = true;
    osokCOTRequired = true;
    osokKillZoneEnabled = true;
    osokKillZoneAsianStart = 18;
    osokKillZoneAsianEnd = 21;
    osokKillZoneLondonStart = 2;
    osokKillZoneLondonEnd = 5;
    osokKillZoneNYStart = 8;
    osokKillZoneNYEnd = 11;
    osokMaxTradesPerWeek = 1;
    osokProjectionTolerance = 10;
    osokProjectionMethod = METHOD_FIB_CONVERGENCE;
    osokFIBExtension1 = 1.27;
    osokFIBExtension2 = 1.68;
    
    //--- Weekly Range Profiles
    wrpEnabled = true;
    wrpSeekDestroyAvoid = true;
    wrpSummerAvoidance = true;
    
    //--- Swing Trading
    swingEnabled = true;
    swingEntryTF = PERIOD_H4;
    swingMinDuration = 14;
    swingMaxDuration = 30;
    swingMinPips = 200;
    swingMaxPips = 500;
    swingSeasonalRequired = true;
    swingMajorMarketRequired = true;
    swingCOTRequired = true;
    swingOIRequired = true;
    swingHallmarksMin = 5;
    swingProfit25Pct = 25.0;
    swingReentry50Pct = true;
    
    //--- Day Trading
    dtEnabled = false;
    dtExecutableTF = PERIOD_H1;
    dtIPDATrueDay = true;
    dtKillZoneLondon = true;
    dtKillZoneNY = true;
    dtKillZoneLC = true;
    dtCBDREnabled = true;
    dtCBDRStandardDeviations = 3;
    dtMaxTradesPerDay = 2;
    dtProfitTargetPips = 50;
    dtNewsAvoidance = true;
    
    //--- Scalping
    scEnabled = false;
    scExecutableTF = PERIOD_M5;
    scMaxTradesPerDay = 5;
    scAsianSessionEnabled = true;
    scNYSessionEnabled = true;
    scPriceEngineEnabled = true;
    scADRExitEnabled = true;
    scADRExitDistance = 15;
    scBreadButterEnabled = true;
    scFillingNumbersEnabled = true;
    
    //--- Mega Trades
    megaEnabled = false;
    megaMinRR = 5.0;
    megaMaxPerYear = 3;
    megaAlignmentScoreMin = 70;
    megaDecisionTreeEnabled = true;
    megaScenarioPlanningEnabled = true;
    megaTopDownEnabled = true;
    megaHTFTimeframe = PERIOD_W1;
    megaEntryTF = PERIOD_D1;
    megaDurationMonths = 4;
    
    //--- Stock Trading
    stockEnabled = false;
    stockWatchlistEnabled = true;
    stockCANSLIMEnabled = true;
    stockCANSLIMEarningsGrowth = 25.0;
    stockCANSLIMInstitutionalPct = 30.0;
    stockSeasonalEnabled = true;
    stockSMTEnabled = true;
    stockOptionsEnabled = false;
    stockOptionsExpiryDays = 30;
    stockDogsOfDowEnabled = false;
    stockMaxTradesPerMonth = 5;
    
    //--- Trading Plan & Psychology
    tpPlanEnabled = true;
    tpDailyLossLimit = 2.0;
    tpWeeklyLossLimit = 5.0;
    tpMonthlyLossLimit = 10.0;
    tpCooldownEnabled = true;
    tpCooldownLosses = 3;
    tpCooldownDays = 1;
    tpDisciplineScoreEnabled = true;
    tpJournalEnabled = true;
    tpJournalBufferSize = 100;
    tpPerformanceGradeEnabled = true;
    
    //--- Técnicas de Entrada
    entryStopEnabled = true;
    entryLimitEnabled = true;
    entryHybridMode = false;
    entryMarketEnabled = true;
    
    //--- PD Arrays
    pdaEnabled = true;
    pdaPriorityBreaker = true;
    
    //--- Mitigación de Pérdidas
    mitEnabled = true;
    mitReductionFactor = 0.5;
    mitConsecutiveLosses = 2;
    mitR2Enabled = true;
    
    //--- COT Analysis
    cotEnabled = true;
    cotUpdateInterval = 7;
    cotRangeMonths = 12;
    cotCacheEnabled = true;
    
    //--- Open Interest
    oiEnabled = true;
    oiUpdateInterval = 1;
    oiChangeSignificance = 10.0;
    oiCacheEnabled = true;
    
    //--- Logging y Panel
    logEnabled = true;
    logLevel = LOG_INFO;
    panelEnabled = true;
    panelUpdateInterval = 5;
    
    //--- Licencia
    licenseKey = "";
    
    //--- Bonus Hunter
    bonusHunterEnabled = false;
    bonusRiskPerTrade = 0.25;
    bonusMaxTradesPerDay = 10;
    bonusVolumeThreshold = 1.0;
    bonusMinProfit = 50.0;
    bonusMaxLossStreak = 3;
    bonusCooldownMinutes = 15;
}

bool SConfig::Validate(CUtils* utils) {
    if(utils == NULL) return false;
    
    bool valid = true;
    
    //--- Validar riesgos
    if(riskPerTrade < 0.1 || riskPerTrade > 5.0) {
        utils.LogError("Risk_PerTrade fuera de rango: " + DoubleToString(riskPerTrade));
        valid = false;
    }
    if(riskPerScalpTrade < 0.1 || riskPerScalpTrade > 2.0) {
        utils.LogError("Risk_PerScalpTrade fuera de rango: " + DoubleToString(riskPerScalpTrade));
        valid = false;
    }
    if(riskPerMegaTrade < 0.1 || riskPerMegaTrade > 1.0) {
        utils.LogError("Risk_PerMegaTrade fuera de rango: " + DoubleToString(riskPerMegaTrade));
        valid = false;
    }
    
    //--- Validar drawdown
    if(maxDrawdown < 5.0 || maxDrawdown > 50.0) {
        utils.LogError("MaxDrawdown fuera de rango: " + DoubleToString(maxDrawdown));
        valid = false;
    }
    
    //--- Validar R:R
    if(minRR < 1.0 || minRR > 10.0) {
        utils.LogError("MinRR fuera de rango: " + DoubleToString(minRR));
        valid = false;
    }
    
    //--- Validar spreads
    if(maxSpread < 0.5 || maxSpread > 10.0) {
        utils.LogError("MaxSpread fuera de rango: " + DoubleToString(maxSpread));
        valid = false;
    }
    if(maxSpreadScalp < 0.1 || maxSpreadScalp > 2.0) {
        utils.LogError("MaxSpreadScalp fuera de rango: " + DoubleToString(maxSpreadScalp));
        valid = false;
    }
    
    //--- Validar símbolos
    if(symbolList == "") {
        utils.LogError("SymbolList está vacío");
        valid = false;
    }
    
    //--- Validar número mágico
    if(magicNumber < 1 || magicNumber > 99999999) {
        utils.LogError("MagicNumber fuera de rango: " + IntegerToString(magicNumber));
        valid = false;
    }
    
    return valid;
}

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN DE CConfig                                        |
//+------------------------------------------------------------------+

//--- Constructor
CConfig::CConfig() {
    m_utils = NULL;
    m_isInitialized = false;
    m_config.SetDefaults();
}

//--- Destructor
CConfig::~CConfig() {
    Deinit();
}

//--- Inicialización
bool CConfig::Init(CUtils* utils, SConfig &config) {
    if(utils == NULL) {
        Print("CConfig::Init - Error: CUtils es NULL");
        return false;
    }
    
    m_utils = utils;
     
    //--- Copiar configuración recibida
    m_config = config;
    
    //--- Validar parámetros
    if(!ValidateParameters()) {
        m_utils.LogError("CConfig::Init - Error en validación de parámetros");
        return false;
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CConfig inicializado correctamente");
    return true;
}

//--- Desinicialización
void CConfig::Deinit() {
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Cargar configuración desde inputs (llamado desde el EA principal)
void CConfig::LoadFromInputs() {
    //--- Este método será llamado desde el EA principal
    //--- Los inputs se cargarán directamente en el EA y se pasarán a CConfig
    //--- a través del constructor o del método Init()
    
    m_utils.LogInfo("CConfig::LoadFromInputs - La configuración se carga desde el EA principal");
}

//--- Validación de parámetros
bool CConfig::ValidateParameters() {
    if(m_utils == NULL) return false;
    return m_config.Validate(m_utils);
}

//--- Obtener último error
string CConfig::GetLastError() const {
    return "Configuración válida";
}

//--- Obtener resumen
string CConfig::GetSummary() {
    string summary = "=== CONFIGURACIÓN ===\n";
    summary += "Modelo: " + m_utils.GetModelName(m_config.tradingModel) + "\n";
    summary += "Símbolos: " + m_config.symbolList + "\n";
    summary += "Timeframe: " + EnumToString(m_config.timeframe) + "\n";
    summary += "Riesgo: " + DoubleToString(m_config.riskPerTrade, 2) + "%\n";
    summary += "R:R Mínimo: " + DoubleToString(m_config.minRR, 1) + ":1\n";
    summary += "Drawdown Máximo: " + DoubleToString(m_config.maxDrawdown, 1) + "%\n";
    summary += "=========================";
    return summary;
}

//--- Obtener reporte de configuración
string CConfig::GetConfigReport() {
    string report = "";
    report += "Magic Number: " + IntegerToString(m_config.magicNumber) + "\n";
    report += "Comment: " + m_config.comment + "\n";
    report += "Enabled: " + (m_config.enabled ? "Sí" : "No") + "\n";
    report += "Trading Model: " + m_utils.GetModelName(m_config.tradingModel) + "\n";
    report += "Symbol List: " + m_config.symbolList + "\n";
    report += "Timeframe: " + EnumToString(m_config.timeframe) + "\n";
    report += "Risk Per Trade: " + DoubleToString(m_config.riskPerTrade, 2) + "%\n";
    report += "Max Drawdown: " + DoubleToString(m_config.maxDrawdown, 1) + "%\n";
    report += "Min R:R: " + DoubleToString(m_config.minRR, 1) + ":1\n";
    report += "Max Spread: " + DoubleToString(m_config.maxSpread, 1) + " pips\n";
    return report;
}

#endif // __CCONFIG_MQH__