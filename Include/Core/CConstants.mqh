//+------------------------------------------------------------------+
//|                                                   CConstants.mqh |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo contiene todas las enumeraciones y constantes        |
//| globales del sistema. Es el módulo base del que dependen         |
//| todos los demás módulos.                                         |
//|                                                                  |
//| RFs asociados:                                                   |
//|   - Todas las enumeraciones y constantes del sistema             |
//|                                                                  |
//| Dependencias:                                                    |
//|   - Ninguna (módulo base)                                        |
//|                                                                  |
//| Versión: 1.3                                                     |
//| Fecha: 22/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 21/07/2026  | Versión inicial del módulo               |
//| 1.1     | 21/07/2026  | Añadidas estructuras: Signal, MacroData, |
//|         |             | SeasonalData, COTData, OIData,           |
//|         |             | MultiAssetData, StockData, MegaTradeData,|
//|         |             | JournalEntry                             |
//| 1.2     | 21/07/2026  | Añadido ENUM_LICENSE_TYPE y constantes   |
//|         |             | de licencia (LICENSE_*)                  |
//| 1.3     | 22/07/2026  | Añadidas estructuras: AssetClassState,   |
//|         |             | AssetRotationData                        |
//|         |             | Ampliada MultiAssetData con              |
//|         |             | intermarketCorrelationMatrix[4][4]       |
//| 1.4     | 22/07/2026  | Ampliada MultiAssetData con campos       |
//|         |             | bonds, commodities, currencies, stocks   |
//+------------------------------------------------------------------+

#ifndef __CCONSTANTS_MQH__
#define __CCONSTANTS_MQH__

//+------------------------------------------------------------------+
//| ENUMERACIONES GLOBALES - Versión 1.7                             |
//+------------------------------------------------------------------+

//--- Estados del EA (23 estados)
enum ENUM_EA_STATE {
    STATE_INIT,                          // Inicializando
    STATE_IDLE,                          // En espera
    STATE_MACRO_ANALYSIS,                // Análisis macro
    STATE_MULTI_ASSET_ANALYSIS,          // Análisis multi-asset
    STATE_STOCK_TRADING_ANALYSIS,        // Análisis stock trading
    STATE_MEGA_TRADE_ANALYSIS,           // Análisis mega trades
    STATE_TRADING_PLAN_ANALYSIS,         // Análisis trading plan
    STATE_BONUS_HUNTER_ANALYSIS,         // Análisis bonus hunter
    STATE_SWING_FILTER_ANALYSIS,         // Análisis filtros swing
    STATE_SHORT_TERM_ANALYSIS,           // Análisis short-term
    STATE_OSOK_ANALYSIS,                 // Análisis OSOK
    STATE_DAY_TRADING_ANALYSIS,          // Análisis day trading
    STATE_SCALPING_ANALYSIS,             // Análisis scalping
    STATE_DATA_RANGE_ANALYSIS,           // Análisis data ranges
    STATE_SEASONAL_ANALYSIS,             // Análisis seasonal
    STATE_MODEL_SELECTION,               // Selección de modelo
    STATE_ANALYZING,                     // Analizando
    STATE_SIGNAL,                        // Señal detectada
    STATE_EXECUTING,                     // Ejecutando
    STATE_IN_TRADE,                      // En operación
    STATE_CLOSING,                       // Cerrando
    STATE_LOGGING,                       // Registrando
    STATE_PAUSED,                        // Pausado
    STATE_SHUTDOWN                       // Apagando
};

//--- Bias direccional
enum ENUM_BIAS {
    BIAS_BULLISH,                        // Alcista
    BIAS_BEARISH,                        // Bajista
    BIAS_NEUTRAL                         // Neutral
};

//--- Estado del mercado
enum ENUM_MARKET_STATE {
    STATE_EXPANSION,                     // Expansión
    STATE_RETRACEMENT,                   // Retracement
    STATE_REVERSAL,                      // Reversión
    STATE_CONSOLIDATION                  // Consolidación
};

//--- Zona de mercado
enum ENUM_MARKET_ZONE {
    ZONE_PREMIUM,                        // Zona de prima (sobrecompra)
    ZONE_DISCOUNT,                       // Zona de descuento (sobreventa)
    ZONE_EQUILIBRIUM                     // Equilibrio (50%)
};

//--- Modelos de trading (9 modelos)
enum ENUM_TRADING_MODEL {
    MODEL_POSITION,                      // Position Trading
    MODEL_SWING,                         // Swing Trading
    MODEL_SHORT_TERM,                    // Short-Term Trading
    MODEL_OSOK,                          // One Shot One Kill
    MODEL_DAY_TRADING,                   // Day Trading
    MODEL_SCALPING,                      // Scalping
    MODEL_MEGA_TRADE,                    // Mega Trade
    MODEL_STOCK_TRADING,                 // Stock Trading
    MODEL_BONUS_HUNTER                   // Bonus Hunter
};

//--- Tipos de entrada
enum ENUM_ENTRY_TYPE {
    ENTRY_BUY_STOP,                      // Buy Stop
    ENTRY_SELL_STOP,                     // Sell Stop
    ENTRY_BUY_LIMIT,                     // Buy Limit
    ENTRY_SELL_LIMIT,                    // Sell Limit
    ENTRY_HYBRID,                        // Híbrida (Stop + Limit)
    ENTRY_MARKET                         // Market
};

//--- PD Arrays (Premium/Discount Arrays) - Jerarquía
enum ENUM_PD_ARRAY {
    PD_OLD_HIGH_LOW,                     // 1. Old High/Low
    PD_REJECTION_BLOCK,                  // 2. Rejection Block
    PD_ORDER_BLOCK,                      // 3. Order Block
    PD_FVG,                              // 4. FVG
    PD_LIQUIDITY_VOID,                   // 5. Liquidity Void
    PD_BREAKER,                          // 6. Breaker
    PD_MITIGATION_BLOCK                  // 7. Mitigation Block
};

//--- Perfiles de rango semanal (13 tipos)
enum ENUM_WEEKLY_PROFILE {
    PROFILE_CLASSIC_TUESDAY_LOW,                // Martes Low
    PROFILE_CLASSIC_TUESDAY_HIGH,               // Martes High
    PROFILE_WEDNESDAY_LOW,                      // Miércoles Low
    PROFILE_WEDNESDAY_HIGH,                     // Miércoles High
    PROFILE_THURSDAY_REVERSAL_BULLISH,          // Jueves Reversal Bullish
    PROFILE_THURSDAY_REVERSAL_BEARISH,          // Jueves Reversal Bearish
    PROFILE_MIDWEEK_RALLY,                      // Midweek Rally
    PROFILE_MIDWEEK_DECLINE,                    // Midweek Decline
    PROFILE_SEEK_DESTROY_BULLISH,               // Seek & Destroy Bullish
    PROFILE_SEEK_DESTROY_BEARISH,               // Seek & Destroy Bearish
    PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH,  // Miércoles Reversal Bullish
    PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BEARISH,  // Miércoles Reversal Bearish
    PROFILE_UNKNOWN                             // Desconocido
};

//--- Plantillas de manipulación MM (13 tipos)
enum ENUM_MM_TEMPLATE {
    TEMPLATE_CLASSIC_TUESDAY_LOW,
    TEMPLATE_CLASSIC_TUESDAY_HIGH,
    TEMPLATE_WEDNESDAY_LOW,
    TEMPLATE_WEDNESDAY_HIGH,
    TEMPLATE_THURSDAY_REVERSAL_BULLISH,
    TEMPLATE_THURSDAY_REVERSAL_BEARISH,
    TEMPLATE_MIDWEEK_RALLY,
    TEMPLATE_MIDWEEK_DECLINE,
    TEMPLATE_SEEK_DESTROY_BULLISH,
    TEMPLATE_SEEK_DESTROY_BEARISH,
    TEMPLATE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH,
    TEMPLATE_WEDNESDAY_WEEKLY_REVERSAL_BEARISH,
    TEMPLATE_UNKNOWN
};

//--- Estado OSOK
enum ENUM_OSOK_STATUS {
    OSOK_INACTIVE,                       // Inactivo
    OSOK_ANALYZING,                      // Analizando
    OSOK_QUALIFIED,                      // Calificado
    OSOK_NOT_QUALIFIED,                  // No calificado
    OSOK_PROJECTION_SET,                 // Proyección establecida
    OSOK_TRADE_EXECUTED,                 // Trade ejecutado
    OSOK_TARGET_HIT,                     // Objetivo alcanzado
    OSOK_STOP_HIT,                       // Stop alcanzado
    OSOK_EXPIRED                         // Expirado
};

//--- Métodos de proyección OSOK
enum ENUM_PROJECTION_METHOD {
    METHOD_FIB_CONVERGENCE,              // Convergencia Fibonacci
    METHOD_PD_ARRAY_ONLY,                // Solo PD Arrays
    METHOD_BLENDED                       // Mixto
};

//--- Kill Zones (Day Trading)
enum ENUM_KILL_ZONE {
    KZ_ASIAN,                            // Asiática (6-9 PM NY)
    KZ_LONDON,                           // London (1-5 AM NY)
    KZ_NEW_YORK,                         // New York (7-10 AM NY)
    KZ_LONDON_CLOSE,                     // London Close (10 AM-12 PM NY)
    KZ_NONE                              // Ninguna
};

//--- Perfiles Intraday (Day Trading - Mes 8)
enum ENUM_INTRADAY_PROFILE {
    PROFILE_NORMAL_BUY,                  // Normal Buy
    PROFILE_NORMAL_SELL,                 // Normal Sell
    PROFILE_DELAYED_PROTRACTION_BUY,     // Delayed Protraction Buy
    PROFILE_DELAYED_PROTRACTION_SELL,    // Delayed Protraction Sell
    INTRADAY_PROFILE_UNKNOWN             // Desconocido
};

//--- Tipos de reversión (Day Trading - Mes 8)
enum ENUM_REVERSAL_TYPE {
    REVERSAL_PREV_DAY_HIGH,              // High del día anterior
    REVERSAL_PREV_DAY_LOW,               // Low del día anterior
    REVERSAL_INTRA_WEEK_HIGH,            // High de la semana
    REVERSAL_INTRA_WEEK_LOW,             // Low de la semana
    REVERSAL_INTERMEDIATE_HIGH,          // High intermedio
    REVERSAL_INTERMEDIATE_LOW,           // Low intermedio
    REVERSAL_NY_SESSION,                 // Sesión NY
    REVERSAL_LONDON_CLOSE,               // Cierre London
    REVERSAL_CME_OPEN,                   // Apertura CME
    REVERSAL_UNKNOWN                     // Desconocido
};

//--- Estado Day Trading
enum ENUM_DAY_STATUS {
    DAY_INACTIVE,                        // Inactivo
    DAY_ANALYZING,                       // Analizando
    DAY_QUALIFIED,                       // Calificado
    DAY_IN_TRADE,                        // En operación
    DAY_TARGET_HIT,                      // Objetivo alcanzado
    DAY_STOP_HIT,                        // Stop alcanzado
    DAY_PAUSED,                          // Pausado
    DAY_COMPLETED                        // Completado
};

//--- Price Engine Models (Scalping - Mes 9)
enum ENUM_PRICE_ENGINE_MODEL {
    MODEL_OFFSET_ACCUMULATION,           // Offset Accumulation (buy)
    MODEL_RE_ACCUMULATION,               // Re-Accumulation (buy)
    MODEL_OFFSET_DISTRIBUTION,           // Offset Distribution (sell)
    MODEL_REDISTRIBUTION,                // Redistribution (sell)
    MODEL_UNKNOWN                        // Desconocido
};

//--- Estado Scalping
enum ENUM_SCALP_STATUS {
    SCALP_INACTIVE,                      // Inactivo
    SCALP_ANALYZING,                     // Analizando
    SCALP_QUALIFIED,                     // Calificado
    SCALP_IN_TRADE,                      // En operación
    SCALP_TARGET_HIT,                    // Objetivo alcanzado
    SCALP_STOP_HIT,                      // Stop alcanzado
    SCALP_ADR_EXIT,                      // Salida por ADR
    SCALP_PAUSED                         // Pausado
};

//--- Clases de activos (Multi-Asset - Mes 10)
enum ENUM_ASSET_CLASS {
    ASSET_BONDS,                         // Bonos
    ASSET_COMMODITIES,                   // Materias Primas
    ASSET_CURRENCIES,                    // Divisas
    ASSET_STOCKS                         // Acciones
};

//--- Entorno de riesgo (Multi-Asset - Mes 10)
enum ENUM_RISK_ENVIRONMENT {
    RISK_ON,                             // Risk On
    RISK_OFF,                            // Risk Off
    RISK_NEUTRAL                         // Neutral
};

//--- Patrones de índices (8 tipos - Mes 10)
enum ENUM_INDEX_PATTERN {
    PATTERN_NORMAL_AM_TREND_PM_CONT,     // AM Trend + PM Continuation
    PATTERN_NORMAL_AM_TREND_PM_REV,      // AM Trend + PM Reversal
    PATTERN_OR_BREAKOUT_AM_TREND,        // OR Breakout + AM Trend
    PATTERN_OR_BREAKOUT_AM_REV,          // OR Breakout + AM Reversal
    PATTERN_AM_CONSOL_PM_BREAKOUT,       // AM Consolidation + PM Breakout
    PATTERN_AM_CONSOL_PM_REV,            // AM Consolidation + PM Reversal
    PATTERN_OR_RANGE_BOUND,              // OR Range-Bound
    PATTERN_OR_EXTENDED,                 // OR Extended
    PATTERN_UNKNOWN                      // Desconocido
};

//--- Bias estacional (Mes 10)
enum ENUM_SEASONAL_BIAS {
    SEASONAL_BULLISH,                    // Alcista
    SEASONAL_BEARISH,                    // Bajista
    SEASONAL_NEUTRAL                     // Neutral
};

//--- Estado Stock Trading
enum ENUM_STOCK_STATUS {
    STOCK_INACTIVE,                      // Inactivo
    STOCK_ANALYZING,                     // Analizando
    STOCK_WATCHLIST_BUY,                 // Watchlist de compra
    STOCK_WATCHLIST_SELL,                // Watchlist de venta
    STOCK_QUALIFIED,                     // Calificado
    STOCK_IN_TRADE,                      // En operación
    STOCK_TARGET_HIT,                    // Objetivo alcanzado
    STOCK_STOP_HIT                       // Stop alcanzado
};

//--- Escenarios Mega Trades (Mes 11)
enum ENUM_MEGA_SCENARIO {
    SCENARIO_BASE,                       // Caso base
    SCENARIO_BULL,                       // Caso alcista
    SCENARIO_BEAR                        // Caso bajista
};

//--- Estado Mega Trade
enum ENUM_MEGA_STATUS {
    MEGA_INACTIVE,                       // Inactivo
    MEGA_ANALYZING,                      // Analizando
    MEGA_QUALIFIED,                      // Calificado
    MEGA_DECISION_TREE_PASSED,           // Árbol de decisión aprobado
    MEGA_SCENARIOS_PLANNED,              // Escenarios planificados
    MEGA_IN_TRADE,                       // En operación
    MEGA_TARGET_HIT,                     // Objetivo alcanzado
    MEGA_STOP_HIT,                       // Stop alcanzado
    MEGA_EXPIRED                         // Expirado
};

//--- Impacto de noticias (Mes 12)
enum ENUM_NEWS_IMPACT {
    IMPACT_LOW,                          // Bajo
    IMPACT_MEDIUM,                       // Medio
    IMPACT_HIGH,                         // Alto
    IMPACT_EXTREME                       // Extremo
};

//--- Estado Bonus Hunter
enum ENUM_BONUS_STATUS {
    BONUS_INACTIVE,                      // Inactivo
    BONUS_SCANNING,                      // Escaneando
    BONUS_QUALIFIED,                     // Calificado
    BONUS_IN_TRADE,                      // En operación
    BONUS_TARGET_HIT,                    // Objetivo alcanzado
    BONUS_STOP_HIT,                      // Stop alcanzado
    BONUS_COMPLETED,                     // Completado (bono liberado)
    BONUS_FAILED                         // Fallido
};

//--- Niveles de logging
enum ENUM_LOG_LEVEL {
    LOG_ERROR,                           // Solo errores
    LOG_WARNING,                         // Errores y advertencias
    LOG_INFO,                            // Información general
    LOG_DEBUG,                           // Depuración
    LOG_TRACE                            // Traza completa
};

//+------------------------------------------------------------------+
//| CONSTANTES GLOBALES                                              |
//+------------------------------------------------------------------+

//--- Nombres de modelos de trading
#define MODEL_NAME_POSITION      "Position Trading"
#define MODEL_NAME_SWING         "Swing Trading"
#define MODEL_NAME_SHORT_TERM    "Short-Term Trading"
#define MODEL_NAME_OSOK          "One Shot One Kill"
#define MODEL_NAME_DAY_TRADING   "Day Trading"
#define MODEL_NAME_SCALPING      "Scalping"
#define MODEL_NAME_MEGA_TRADE    "Mega Trade"
#define MODEL_NAME_STOCK_TRADING "Stock Trading"
#define MODEL_NAME_BONUS_HUNTER  "Bonus Hunter"

//--- Niveles de riesgo por modelo (% del equity)
#define RISK_POSITION_DEFAULT    0.3    // 0.3% del equity
#define RISK_SWING_DEFAULT       1.5    // 1.5% del equity
#define RISK_SHORT_TERM_DEFAULT  1.5    // 1.5% del equity
#define RISK_OSOK_DEFAULT        1.5    // 1.5% del equity
#define RISK_DAY_TRADING_DEFAULT 1.5    // 1.5% del equity
#define RISK_SCALPING_DEFAULT    0.75   // 0.75% del equity
#define RISK_MEGA_DEFAULT        0.3    // 0.3% del equity
#define RISK_STOCK_DEFAULT       1.5    // 1.5% del equity
#define RISK_BONUS_DEFAULT       0.25   // 0.25% del equity

//--- Límites de frecuencia
#define MAX_POSITION_TRADES_YEAR  3     // Position: 2-3 por año
#define MAX_SWING_TRADES_YEAR     8     // Swing: 6-8 por año
#define MAX_OSOK_TRADES_WEEK      1     // OSOK: 1 por semana
#define MAX_DAY_TRADES_DAY        2     // Day Trading: 1-2 por día
#define MAX_SCALP_TRADES_DAY      5     // Scalping: 3-5 por día
#define MAX_MEGA_TRADES_YEAR      3     // Mega Trades: 1-3 por año
#define MAX_STOCK_TRADES_MONTH    5     // Stock Trading: configurable
#define MAX_BONUS_TRADES_DAY      10    // Bonus Hunter: hasta 10 por día

//--- Límites de drawdown
#define DRAWDOWN_ALERT           5.0    // Alerta al 5%
#define DRAWDOWN_REDUCTION       10.0   // Reducción al 10%
#define DRAWDOWN_STOP            20.0   // Parada al 20%
#define DRAWDOWN_ANNUAL_LIMIT    15.0   // Límite anual 15%

//--- Límites de pérdida (Trading Plan)
#define LOSS_LIMIT_DAILY         2.0    // 2% diario
#define LOSS_LIMIT_WEEKLY        5.0    // 5% semanal
#define LOSS_LIMIT_MONTHLY       10.0   // 10% mensual

//--- R:R Mínimos por modelo
#define RR_MIN_POSITION          3.0    // Position: 3:1 mínimo
#define RR_MIN_SWING             3.0    // Swing: 3:1 mínimo
#define RR_MIN_SHORT_TERM        3.0    // Short-Term: 3:1 mínimo
#define RR_MIN_OSOK              3.0    // OSOK: 3:1 mínimo
#define RR_MIN_DAY_TRADING       2.0    // Day Trading: 2:1 mínimo
#define RR_MIN_SCALPING          1.0    // Scalping: 1:1
#define RR_MIN_MEGA              5.0    // Mega Trade: 5:1 mínimo
#define RR_MIN_STOCK             3.0    // Stock: 3:1 mínimo
#define RR_MIN_BONUS             1.0    // Bonus Hunter: 1:1

//--- R:R Óptimos
#define RR_OPTIMAL_SWING         5.0    // Swing: 5:1 óptimo
#define RR_OPTIMAL_MEGA          5.0    // Mega Trade: 5:1 óptimo

//--- Scalping (ADR Exit Rule)
#define ADR_EXIT_DISTANCE        15     // 15 pips antes del ADR

//--- Niveles de Scaling Out
#define SO_LEVEL1_RR             3.0    // TP1: 3:1
#define SO_LEVEL1_PCT            50.0   // 50% en TP1
#define SO_LEVEL2_RR             5.0    // TP2: 5:1
#define SO_LEVEL2_PCT            25.0   // 25% en TP2
#define SO_LEVEL3_RR             9.0    // TP3: 9:1
#define SO_LEVEL3_PCT            25.0   // 25% en TP3

//--- IPDA Trailing Stop (días)
#define TS_IPDA_INITIAL          40     // 40 días inicial
#define TS_IPDA_MID              20     // 20 días al 50%
#define TS_IPDA_FINAL            10     // 10 días al 75%

//--- OSOK Proyección Fibonacci
#define OSOK_FIB_EXTENSION1      1.27   // Fibonacci 127%
#define OSOK_FIB_EXTENSION2      1.68   // Fibonacci 168%
#define OSOK_PROJECTION_TOLERANCE 10    // 10 pips de tolerancia

//--- CBDR (Day Trading) - Horas NY
#define CBDR_START_HOUR          14     // 2:00 PM NY
#define CBDR_END_HOUR            20     // 8:00 PM NY
#define CBDR_STANDARD_DEVIATIONS 3      // 3 desviaciones estándar

//--- IPDA True Day (Day Trading) - Horas NY
#define TRUE_DAY_START           0      // 12:00 AM NY
#define TRUE_DAY_END             15     // 3:00 PM NY

//--- Kill Zones (Day Trading) - Horas NY
#define KZ_LONDON_START          1      // 1:00 AM NY
#define KZ_LONDON_END            5      // 5:00 AM NY
#define KZ_NY_START              7      // 7:00 AM NY
#define KZ_NY_END                10     // 10:00 AM NY
#define KZ_LC_START              10     // 10:00 AM NY
#define KZ_LC_END                12     // 12:00 PM NY
#define KZ_ASIAN_START           18     // 6:00 PM NY
#define KZ_ASIAN_END             21     // 9:00 PM NY

//--- Sesiones Scalping - Horas NY
#define ASIAN_SESSION_START      18     // 6:00 PM NY
#define ASIAN_SESSION_END        21     // 9:00 PM NY
#define NY_SESSION_START         8      // 8:00 AM NY
#define NY_SESSION_END           11     // 11:00 AM NY

//--- Spread máximo por modelo (pips)
#define MAX_SPREAD_POSITION      3.0    // 3 pips
#define MAX_SPREAD_SWING         3.0    // 3 pips
#define MAX_SPREAD_SHORT_TERM    3.0    // 3 pips
#define MAX_SPREAD_OSOK          2.0    // 2 pips
#define MAX_SPREAD_DAY_TRADING   1.0    // 1 pip
#define MAX_SPREAD_SCALPING      0.5    // 0.5 pips
#define MAX_SPREAD_MEGA          2.0    // 2 pips
#define MAX_SPREAD_STOCK         3.0    // 3 pips
#define MAX_SPREAD_BONUS         2.0    // 2 pips

//--- Slippage máximo por modelo (pips)
#define MAX_SLIPPAGE_POSITION    3.0    // 3 pips
#define MAX_SLIPPAGE_SWING       3.0    // 3 pips
#define MAX_SLIPPAGE_SHORT_TERM  3.0    // 3 pips
#define MAX_SLIPPAGE_OSOK        2.0    // 2 pips
#define MAX_SLIPPAGE_DAY_TRADING 2.0    // 2 pips
#define MAX_SLIPPAGE_SCALPING    1.0    // 1 pip
#define MAX_SLIPPAGE_MEGA        2.0    // 2 pips
#define MAX_SLIPPAGE_STOCK       3.0    // 3 pips
#define MAX_SLIPPAGE_BONUS       1.0    // 1 pip

//--- Comisión por lote (Weltrade Raw Spread)
#define COMMISSION_PER_LOT       1.5    // $1.5 por lote (ida y vuelta)

//--- Configuración de Bonus Hunter
#define BONUS_VOLUME_THRESHOLD   1.0    // 1 lote por cada $100 de bono
#define BONUS_MIN_PROFIT         50.0   // $50 de profit mínimo para liberar
#define BONUS_MAX_TRADES_DAY     10     // Máximo 10 trades por día
#define BONUS_MAX_LOSS_STREAK    3      // Máximo 3 pérdidas consecutivas
#define BONUS_COOLDOWN_MINUTES   15     // 15 minutos de cooldown tras pérdidas

//--- Tipos de Licencias
#define LICENSE_NONE       0   // Sin licencia
#define LICENSE_DEMO       1   // Licencia de prueba (30 días)
#define LICENSE_PERSONAL   2   // Licencia personal (1 usuario)
#define LICENSE_COMMERCIAL 3   // Licencia comercial (múltiples cuentas)

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//--- RF-851: Estado de una clase de activo (Multi-Asset - Mes 10) 🆕
struct AssetClassState {
    string           className;           // "Bonds", "Commodities", "Currencies", "Stocks"
    ENUM_BIAS        bias;                // Bullish/Bearish/Neutral
    double           trendStrength;       // 0-100
    double           momentum;            // -100 a 100
    bool             isTrending;
    bool             isConsolidating;
    bool             isReversing;
    double           correlationWithRisk;
    double           priceChange;         // % cambio en 20 días
    double           volatility;          // ATR / Precio * 100
    datetime         lastUpdate;
};

//--- RF-869: Rotación de Activos (Multi-Asset - Mes 10) 🆕
struct AssetRotationData {
    string           fromAsset;
    string           toAsset;
    double           rotationStrength;
    datetime         rotationStart;
    datetime         rotationEnd;
    bool             isActive;
};

//--- Estructura para señales
struct Signal {
    string             symbol;
    ENUM_TIMEFRAMES    tf;
    ENUM_TRADING_MODEL model;
    ENUM_BIAS          bias;
    ENUM_ENTRY_TYPE    entryType;
    double             entryPrice;
    double             stopLoss;
    double             takeProfit;
    double             risk;
    double             reward;
    double             rrRatio;
    int                qualityScore;
    bool               isQualified;
    string             setupType;
    string             reason;
    datetime           signalTime;
    bool               isConfirmed;
};
 
//--- Estructura para datos macro
struct MacroData {
    double           tenYearYield;
    double           tenYearPrice;
    double           dxy;
    double           crb;
    double           gold;
    double           oil;
    double           thirtyYearYield;
    double           thirtyYearPrice;
    ENUM_BIAS        intermarketBias;
    bool             isCrackingCorrelation;
};
 
//--- Estructura para datos estacionales
struct SeasonalData {
    string           symbol;
    int              month;
    ENUM_BIAS        bias;
    double           historicalReturn;
    double           winRate;
    int              sampleSize;
    bool             isIdealSeasonal;
    bool             isConverged;
};
 
//--- Estructura para datos COT
struct COTData {
    string           symbol;
    double           commercialNet;
    double           commercialHigh12M;
    double           commercialLow12M;
    double           midPoint;
    bool             isBuyProgram;
    bool             isSellProgram;
    double           hedgingNodule;
    ENUM_BIAS        commercialBias;
    datetime         lastUpdate;
};
 
//--- Estructura para datos Open Interest
struct OIData {
    string           symbol;
    double           currentOI;
    double           previousOI;
    double           changePercent;
    bool             isIncreasing;
    bool             isDecreasing;
    double           seasonalAverage;
    bool             isSmartMoneyFootprint;
    datetime         lastUpdate;
};
 
//--- RF-850/857: Estructura para datos Multi-Asset (AMPLIADA) 🆕
struct MultiAssetData {
    AssetClassState       bonds;                               // Estado de Bonos
    AssetClassState       commodities;                         // Estado de Materias Primas
    AssetClassState       currencies;                          // Estado de Divisas
    AssetClassState       stocks;                              // Estado de Acciones
    ENUM_RISK_ENVIRONMENT riskEnvironment;                     // Entorno de riesgo
    bool                  isRiskOn;                            // Flag Risk On
    bool                  isRiskOff;                           // Flag Risk Off
    bool                  isSymmetrical;                       // Simetría detectada
    bool                  isDecoupled;                         // Desacoplamiento detectado
    string                leadershipAsset;                     // Clase líder
    int                   alignmentScore;                      // Score de alineación 0-100
    double                riskScore;                           // Score de riesgo 0-100
    double                intermarketCorrelationMatrix[4][4];  // Matriz de correlación 4x4
    datetime              lastUpdate;                          // Última actualización
};
 
//--- Estructura para datos de Stock
struct StockData {
    string             symbol;
    double             currentEarningsGrowth;
    double             annualEarningsGrowth;
    double             institutionalOwnership;
    double             floatSize;
    bool               isGrowthStock;
    bool               isIndexStock;
    bool               isLeader;
    bool               isLaggard;
    ENUM_SEASONAL_BIAS seasonalBias;
    bool               isSMTDivergence;
    bool               isBuyWatchlist;
    bool               isSellWatchlist;
    double             entryLevel;
    double             stopLevel;
    double             targetLevel;
    datetime           lastUpdate;
};
 
//--- Estructura para datos de Mega Trades
struct MegaTradeData {
    string             symbol;
    datetime           entryDate;
    datetime           projectedExitDate;
    double             entryPrice;
    double             stopLoss;
    double             takeProfit;
    double             riskPercent;
    double             currentRMultiple;
    double             targetRMultiple;
    double             progressPercent;
    ENUM_MEGA_SCENARIO scenario;
    bool               isDecisionTreePassed;
    int                alignmentScore;
    bool               isQuarterlyShiftConfirmed;
    bool               isTopDownConfirmed;
    ENUM_BIAS          expectedBias;
    datetime           lastUpdate;
};

//--- Estructura para entradas de Journal
struct JournalEntry {
    datetime           timestamp;
    string             symbol;
    ENUM_TRADING_MODEL model;
    string             tradeType;     // "Entry", "Exit", "Emotion", "Error", "Lesson", "WIN", "LOSS"
    string             description;
    double             pnl;
    string             emotion;       // "Calm", "FOMO", "Fear", "Greed", "Frustration", "REVENGE", "OVERCONFIDENCE", "ANALYSIS_PARALYSIS"
    bool               ruleViolation;
    string             ruleViolated;
    double             entryPrice;    // 🆕 Precio de entrada
    double             exitPrice;     // 🆕 Precio de salida
    double             lot;           // 🆕 Tamaño de lote
    string             setupType;     // 🆕 Tipo de setup
    int                qualityScore;  // 🆕 Score de calidad
};

struct EntryRecord {
    datetime            timestamp;
    string              symbol;
    ENUM_TRADING_MODEL  model;
    ENUM_ENTRY_TYPE     entryType;
    double              price;
    double              stopLoss;
    double              takeProfit;
    double              lot;
    bool                isExecuted;
    bool                isCancelled;
    string              reason;
};

#endif // __CCONSTANTS_MQH__