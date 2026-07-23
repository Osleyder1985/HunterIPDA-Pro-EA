//+------------------------------------------------------------------+
//|                                                  CHallmarkAnalyzer.mqh |
//|                     HunterIPDA Pro EA - v1.8 - Módulo Models       |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo implementa la detección y puntuación de los 8        |
//| Hallmarks que ICT define para identificar movimientos explosivos  |
//| en swing trading.                                                |
//|                                                                  |
//| Los 8 Hallmarks son:                                             |
//| 1. Market Profiles                                               |
//| 2. Intermarket Analysis                                          |
//| 3. COT Hedging Program                                           |
//| 4. Open Interest (10-15% cambio)                                 |
//| 5. Seasonal Tendencies                                           |
//| 6. Volatility Contraction (Inside Bar)                           |
//| 7. News Sentiment (ausencia de alto impacto)                     |
//| 8. Williams %R Sentiment                                         |
//|                                                                  |
//| RFs asociados: RF-375                                            |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                      |
//|   - CUtils: Funciones auxiliares                                |
//|   - CConfig: Configuración                                      |
//|   - CContext: Market Profiles                                   |
//|   - CMacroAnalyzer: Intermarket, News Sentiment                 |
//|   - CCOTAnalyzer: COT Hedging                                   |
//|   - COIAnalyzer: Open Interest                                  |
//|   - CSeasonal: Seasonal Tendencies                              |
//|   - CDataRange: Volatility Contraction                          |
//|                                                                  |
//| Versión: 1.0                                                     |
//| Fecha: 23/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 23/07/2026  | Versión inicial del módulo               |
//+------------------------------------------------------------------+

#ifndef __CHALLMARKANALYZER_MQH__
#define __CHALLMARKANALYZER_MQH__

//--- Includes necesarios
#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CContext.mqh"
#include "../Analysis/CMacroAnalyzer.mqh"
#include "../Analysis/CCOTAnalyzer.mqh"
#include "../Analysis/COIAnalyzer.mqh"
#include "../Analysis/CSeasonal.mqh"
#include "../Analysis/CDataRange.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| RF-375: Estructura para almacenar la puntuación de los 8 Hallmarks |
//+------------------------------------------------------------------+
struct HallmarkResult {
    bool marketProfiles;          // Hallmark 1: Market Profile
    bool intermarketAnalysis;     // Hallmark 2: Intermarket Analysis
    bool cotHedging;              // Hallmark 3: COT Hedging Program
    bool openInterest;            // Hallmark 4: Open Interest
    bool seasonal;                // Hallmark 5: Seasonal Tendency
    bool volatilityContraction;   // Hallmark 6: Volatility Contraction
    bool newsSentiment;           // Hallmark 7: News Sentiment
    bool williamsR;               // Hallmark 8: Williams %R Sentiment
    int totalScore;               // Puntuación total (0-8)
    string details[8];            // Detalles de cada hallmark
    bool isQualified;             // Si supera el umbral mínimo
    string summary;               // Resumen del análisis
};

//+------------------------------------------------------------------+
//| CLASE CHallmarkAnalyzer                                          |
//+------------------------------------------------------------------+
class CHallmarkAnalyzer {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CUtils*            m_utils;
    CContext*          m_context;
    CMacroAnalyzer*    m_macroAnalyzer;
    CCOTAnalyzer*      m_cotAnalyzer;
    COIAnalyzer*       m_oiAnalyzer;
    CSeasonal*         m_seasonal;
    CDataRange*        m_dataRange;
    
    bool               m_isInitialized;
    int                m_minHallmarks;        // Mínimo para calificar (default 5)
    bool               m_useCOT;
    bool               m_useOI;
    bool               m_useVolatility;
    bool               m_useSentiment;
    
    //--- Métodos privados de verificación de cada Hallmark
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 1 - Market Profiles                             |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que la estructura de mercado (Market Profile) esté      |
    //| alineada con la dirección esperada.                              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT define 3 perfiles de mercado: Consolidación, Trending y      |
    //| Reversal. Un mercado en tendencia es favorable para movimientos  |
    //| explosivos.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Market Profile alineado con la dirección esperada        |
    //| - False: Market Profile NO alineado                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar al inicio del análisis de Hallmarks.                      |
    //+------------------------------------------------------------------+
    bool               CheckMarketProfiles(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 2 - Intermarket Analysis                         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que el análisis intermercado (4 grupos: Bonos,          |
    //| Commodities, Acciones, Divisas) confirme la dirección esperada.  |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que el dinero fluye entre las 4 clases de activos.    |
    //| La alineación intermercado es fundamental para movimientos       |
    //| explosivos.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Intermarket Analysis confirma la dirección               |
    //| - False: Intermarket Analysis NO confirma                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Market Profiles.                               |
    //+------------------------------------------------------------------+
    bool               CheckIntermarket(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 3 - COT Hedging Program                          |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que el programa de cobertura de comerciales (COT)       |
    //| confirme la dirección esperada.                                  |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT utiliza el COT para identificar la dirección del smart money.|
    //| Cuando los comerciales están alineados con la dirección, hay    |
    //| alta probabilidad de movimiento explosivo.                       |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: COT confirma la dirección esperada                       |
    //| - False: COT NO confirma o es neutral                            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Intermarket Analysis.                          |
    //+------------------------------------------------------------------+
    bool               CheckCOTHedging(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 4 - Open Interest (10-15% cambio)               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que el Open Interest haya cambiado 10-15%+ en la        |
    //| dirección correcta para confirmar el movimiento explosivo.       |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT utiliza OI como confirmación de entrada de smart money.      |
    //| Cambios significativos de OI indican acumulación o distribución.  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: OI cambió 10-15%+ en la dirección correcta               |
    //| - False: OI no cambió significativamente                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de COT. Confirmación de smart money.              |
    //+------------------------------------------------------------------+
    bool               CheckOpenInterest(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 5 - Seasonal Tendencies                          |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que la tendencia estacional del activo confirme la      |
    //| dirección esperada.                                              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Las tendencias estacionales de 40+ años son un filtro de         |
    //| contexto fundamental. La convergencia de datos de 40 y 15 años   |
    //| aumenta la probabilidad de movimiento explosivo.                 |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Seasonal confirma la dirección esperada                  |
    //| - False: Seasonal no confirma o es neutral                       |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Open Interest.                                 |
    //+------------------------------------------------------------------+
    bool               CheckSeasonal(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 6 - Volatility Contraction (Inside Bar)         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta contracciones de volatilidad (inside bars) como señal    |
    //| de expansión inminente.                                          |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que la volatilidad se contrae antes de expandirse.    |
    //| Los inside bars son señales de que el mercado está "cargando"    |
    //| para un movimiento explosivo.                                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Volatilidad contraída (expansión inminente)              |
    //| - False: Volatilidad normal o alta                               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Seasonal. Si no hay contracción, el timing     |
    //| puede no ser óptimo.                                             |
    //+------------------------------------------------------------------+
    bool               CheckVolatilityContraction(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 7 - News Sentiment                               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que no haya eventos de noticias de alto impacto que     |
    //| puedan distorsionar el movimiento esperado.                      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los eventos de alto impacto (FOMC, NFP, CPI) pueden crear        |
    //| movimientos erráticos que distorsionan los movimientos           |
    //| explosivos orgánicos del mercado.                                |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: No hay eventos de alto impacto (favorable)               |
    //| - False: Hay eventos de alto impacto (desfavorable)              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Volatility Contraction.                        |
    //+------------------------------------------------------------------+
    bool               CheckNewsSentiment();
    
    //+------------------------------------------------------------------+
    //| RF-375: Hallmark 8 - Williams %R Sentiment                       |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Usa Williams %R (15 periodos) para medir el sentimiento del      |
    //| retail y confirmar la dirección esperada.                        |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT utiliza Williams %R para medir el sentimiento del retail.    |
    //| Extremos de sobrecompra/sobreventa pueden indicar que el retail  |
    //| está atrapado, lo que favorece movimientos explosivos.           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Williams %R confirma la dirección esperada               |
    //| - False: Williams %R está en contra o neutral                    |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar al final del análisis. Filtro de sentimiento.             |
    //+------------------------------------------------------------------+
    bool               CheckWilliamsR(string symbol, ENUM_BIAS expectedBias);
    
    bool               ValidateDependencies();
    
public:
    //--- Constructor / Destructor
    CHallmarkAnalyzer();
    ~CHallmarkAnalyzer();
    
    //+------------------------------------------------------------------+
    //| RF-375: Inicialización del módulo                                |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Inicializa el módulo CHallmarkAnalyzer con las dependencias      |
    //| necesarias.                                                      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| La inicialización es el paso fundamental para que el módulo      |
    //| pueda operar correctamente.                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Inicialización exitosa                                  |
    //| - False: Error de inicialización                                |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar desde CHunterIPDA durante OnInit.                        |
    //+------------------------------------------------------------------+
    bool Init(CConfig* config, CUtils* utils);
    
    //+------------------------------------------------------------------+
    //| RF-375: Establecer dependencias                                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Establece las referencias a los módulos de análisis necesarios.  |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El análisis de Hallmarks depende de múltiples fuentes de         |
    //| análisis: Context, Macro, COT, OI, Seasonal, DataRange.         |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Todas las dependencias establecidas                     |
    //| - False: Alguna dependencia es NULL                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Init, antes de usar el módulo.                 |
    //+------------------------------------------------------------------+
    bool SetDependencies(CContext* context, CMacroAnalyzer* macro,
                         CCOTAnalyzer* cot, COIAnalyzer* oi,
                         CSeasonal* seasonal, CDataRange* dataRange);
    
    //+------------------------------------------------------------------+
    //| RF-375: Desinicialización                                        |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Libera los recursos y limpia el estado del módulo.               |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| La desinicialización asegura que no queden referencias colgantes.|
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - void: No retorna valor                                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar desde CHunterIPDA durante OnDeinit.                      |
    //+------------------------------------------------------------------+
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //+------------------------------------------------------------------+
    //| RF-375: Análisis completo de los 8 Hallmarks                     |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Ejecuta el análisis completo de los 8 Hallmarks para un símbolo  |
    //| y dirección esperada. Retorna un HallmarkResult con la           |
    //| puntuación y detalles.                                           |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT define 8 Hallmarks que, cuando se alinean, indican alta      |
    //| probabilidad de movimiento explosivo en swing trading.           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - HallmarkResult: Estructura con el resultado de cada hallmark   |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar cuando se detecta un setup potencial. Usar el resultado   |
    //| para decidir si el setup tiene alta probabilidad de éxito.      |
    //+------------------------------------------------------------------+
    HallmarkResult Analyze(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Obtener puntuación de Hallmarks                          |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Calcula y retorna la puntuación de Hallmarks (0-8) para un       |
    //| símbolo y dirección esperada.                                    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| La puntuación de Hallmarks indica cuántos de los 8 factores      |
    //| están alineados. Mayor puntuación = mayor probabilidad de        |
    //| movimiento explosivo.                                            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - 0-8: Número de Hallmarks alineados                            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar para obtener una puntuación rápida sin detalles.          |
    //+------------------------------------------------------------------+
    int GetScore(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Verificar si es un setup explosivo                       |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica si un setup es explosivo basado en el umbral mínimo     |
    //| de Hallmarks configurado.                                        |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT considera que un setup es explosivo cuando al menos 5 de     |
    //| los 8 Hallmarks están alineados (≥5/8).                          |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Setup explosivo (≥ umbral mínimo)                       |
    //| - False: Setup NO explosivo                                      |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar para decidir si ejecutar un swing trade.                  |
    //+------------------------------------------------------------------+
    bool IsExplosive(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Generar reporte de Hallmarks                             |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un reporte detallado del análisis de Hallmarks para un    |
    //| símbolo y dirección esperada.                                    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El reporte permite al trader entender qué Hallmarks están        |
    //| alineados y cuáles no.                                           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - string: Reporte formateado                                     |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar para mostrar información detallada en el panel o logs.   |
    //+------------------------------------------------------------------+
    string GetHallmarkReport(string symbol, ENUM_BIAS expectedBias);
    
    //--- Configuración
    void SetMinHallmarks(int min) { if(min >= 0 && min <= 8) m_minHallmarks = min; }
    int GetMinHallmarks() const { return m_minHallmarks; }
    void SetUseCOT(bool use) { m_useCOT = use; }
    void SetUseOI(bool use) { m_useOI = use; }
    void SetUseVolatility(bool use) { m_useVolatility = use; }
    void SetUseSentiment(bool use) { m_useSentiment = use; }
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CHallmarkAnalyzer::CHallmarkAnalyzer() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_macroAnalyzer = NULL;
    m_cotAnalyzer = NULL;
    m_oiAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
    m_minHallmarks = 5;
    m_useCOT = true;
    m_useOI = true;
    m_useVolatility = true;
    m_useSentiment = true;
}

//--- Destructor
CHallmarkAnalyzer::~CHallmarkAnalyzer() {
    Deinit();
}

//+------------------------------------------------------------------+
//| RF-375: Inicialización                                           |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CHallmarkAnalyzer::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Cargar configuración
    SConfig cfg = m_config.GetConfig();
    m_minHallmarks = cfg.swingHallmarksMin;
    m_useCOT = cfg.swingCOTRequired;
    m_useOI = cfg.swingOIRequired;
    
    if(!ValidateDependencies()) {
        Print("CHallmarkAnalyzer::Init - Error: Validación de dependencias fallida");
        return false;
    }
    
    m_isInitialized = true;
    Print("CHallmarkAnalyzer inicializado correctamente");
    return true;
}

//+------------------------------------------------------------------+
//| RF-375: Establecer dependencias                                  |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::SetDependencies(CContext* context, CMacroAnalyzer* macro,
                                         CCOTAnalyzer* cot, COIAnalyzer* oi,
                                         CSeasonal* seasonal, CDataRange* dataRange) {
    if(context == NULL || macro == NULL || cot == NULL || 
       oi == NULL || seasonal == NULL || dataRange == NULL) {
        Print("CHallmarkAnalyzer::SetDependencies - Error: Alguna dependencia es NULL");
        return false;
    }
    
    m_context = context;
    m_macroAnalyzer = macro;
    m_cotAnalyzer = cot;
    m_oiAnalyzer = oi;
    m_seasonal = seasonal;
    m_dataRange = dataRange;
    
    Print("CHallmarkAnalyzer: Dependencias establecidas correctamente");
    return true;
}

//--- Desinicialización
void CHallmarkAnalyzer::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_macroAnalyzer = NULL;
    m_cotAnalyzer = NULL;
    m_oiAnalyzer = NULL;
    m_seasonal = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
}

//--- Validación de dependencias
bool CHallmarkAnalyzer::ValidateDependencies() {
    if(m_config == NULL || m_utils == NULL) {
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 1 - Market Profiles                             |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckMarketProfiles(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckMarketProfiles - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_context == NULL) {
        Print("CHallmarkAnalyzer::CheckMarketProfiles - Error: CContext no disponible");
        return false;
    }
    
    if(!m_context.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckMarketProfiles - Error: CContext no inicializado");
        return false;
    }
    
    //--- Obtener bias de estructura de mercado
    ENUM_BIAS structureBias = m_context.GetMarketStructureBias();
    bool isAligned = (structureBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckMarketProfiles - " + symbol +
                         " | Structure Bias: " + m_utils.GetBiasName(structureBias) +
                         " | Expected: " + m_utils.GetBiasName(expectedBias) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 2 - Intermarket Analysis                        |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckIntermarket(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckIntermarket - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_macroAnalyzer == NULL) {
        Print("CHallmarkAnalyzer::CheckIntermarket - Error: CMacroAnalyzer no disponible");
        return false;
    }
    
    if(!m_macroAnalyzer.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckIntermarket - Error: CMacroAnalyzer no inicializado");
        return false;
    }
    
    //--- Obtener bias intermercado
    ENUM_BIAS intermarketBias = m_macroAnalyzer.GetIntermarketBias();
    bool isAligned = (intermarketBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckIntermarket - " +
                         "Intermarket Bias: " + m_utils.GetBiasName(intermarketBias) +
                         " | Expected: " + m_utils.GetBiasName(expectedBias) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 3 - COT Hedging Program                         |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckCOTHedging(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckCOTHedging - Error: Módulo no inicializado");
        return false;
    }
    
    if(!m_useCOT) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckCOTHedging - COT desactivado por configuración");
        }
        return true;
    }
    
    if(m_cotAnalyzer == NULL) {
        Print("CHallmarkAnalyzer::CheckCOTHedging - Error: CCOTAnalyzer no disponible");
        return false;
    }
    
    if(!m_cotAnalyzer.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckCOTHedging - Error: CCOTAnalyzer no inicializado");
        return false;
    }
    
    //--- Obtener bias COT (método sin parámetros)
    ENUM_BIAS cotBias = m_cotAnalyzer.GetCommercialBias();
    bool isAligned = (cotBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckCOTHedging - " +
                         "COT Bias: " + m_utils.GetBiasName(cotBias) +
                         " | Expected: " + m_utils.GetBiasName(expectedBias) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 4 - Open Interest (10-15% cambio)               |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckOpenInterest(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckOpenInterest - Error: Módulo no inicializado");
        return false;
    }
    
    if(!m_useOI) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckOpenInterest - OI desactivado por configuración");
        }
        return true;
    }
    
    if(m_oiAnalyzer == NULL) {
        Print("CHallmarkAnalyzer::CheckOpenInterest - Error: COIAnalyzer no disponible");
        return false;
    }
    
    if(!m_oiAnalyzer.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckOpenInterest - Error: COIAnalyzer no inicializado");
        return false;
    }
    
    //--- Actualizar datos OI para el símbolo
    m_oiAnalyzer.SetSymbol(symbol);
    m_oiAnalyzer.Update(symbol);
    
    //--- Obtener datos de OI
    double changePercent = m_oiAnalyzer.GetOIChangePercent();
    bool isIncreasing = m_oiAnalyzer.IsOIIncreasing();
    bool isDecreasing = m_oiAnalyzer.IsOIDecreasing();
    
    //--- Verificar cambio significativo (10-15%+)
    double threshold = 10.0;
    if(MathAbs(changePercent) < threshold) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckOpenInterest - Cambio OI insuficiente: " +
                             DoubleToString(changePercent, 1) + "% < " + DoubleToString(threshold, 1) + "%");
        }
        return false;
    }
    
    //--- Verificar dirección
    bool isAligned = false;
    if(expectedBias == BIAS_BULLISH) {
        isAligned = isIncreasing;
    } else if(expectedBias == BIAS_BEARISH) {
        isAligned = isDecreasing;
    }
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckOpenInterest - OI cambio: " +
                         DoubleToString(changePercent, 1) + "%" +
                         " | Dirección: " + (isIncreasing ? "↑" : (isDecreasing ? "↓" : "=")) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 5 - Seasonal Tendencies                         |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckSeasonal(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckSeasonal - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_seasonal == NULL) {
        Print("CHallmarkAnalyzer::CheckSeasonal - Error: CSeasonal no disponible");
        return false;
    }
    
    if(!m_seasonal.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckSeasonal - Error: CSeasonal no inicializado");
        return false;
    }
    
    //--- Obtener bias estacional
    ENUM_BIAS seasonalBias = m_seasonal.GetSeasonalBias(symbol);
    bool isAligned = (seasonalBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckSeasonal - " + symbol +
                         " | Seasonal Bias: " + m_utils.GetBiasName(seasonalBias) +
                         " | Expected: " + m_utils.GetBiasName(expectedBias) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 6 - Volatility Contraction (Inside Bar)         |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckVolatilityContraction(string symbol) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckVolatilityContraction - Error: Módulo no inicializado");
        return false;
    }
    
    if(!m_useVolatility) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckVolatilityContraction - Volatilidad desactivada por configuración");
        }
        return true;
    }
    
    if(m_utils == NULL) {
        Print("CHallmarkAnalyzer::CheckVolatilityContraction - Error: CUtils no disponible");
        return false;
    }
    
    //--- Verificar inside bar
    double high0 = m_utils.GetHighPrice(symbol, PERIOD_D1, 0);
    double low0 = m_utils.GetLowPrice(symbol, PERIOD_D1, 0);
    double high1 = m_utils.GetHighPrice(symbol, PERIOD_D1, 1);
    double low1 = m_utils.GetLowPrice(symbol, PERIOD_D1, 1);
    
    if(high0 == 0 || low0 == 0 || high1 == 0 || low1 == 0) return false;
    
    bool isInsideBar = (high0 <= high1 && low0 >= low1);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckVolatilityContraction - Inside Bar: " +
                         (isInsideBar ? "YES" : "NO"));
    }
    
    return isInsideBar;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 7 - News Sentiment                              |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckNewsSentiment() {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckNewsSentiment - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_macroAnalyzer == NULL) {
        Print("CHallmarkAnalyzer::CheckNewsSentiment - Error: CMacroAnalyzer no disponible");
        return false;
    }
    
    if(!m_macroAnalyzer.IsInitialized()) {
        Print("CHallmarkAnalyzer::CheckNewsSentiment - Error: CMacroAnalyzer no inicializado");
        return false;
    }
    
    //--- Entorno neutral = favorable
    bool isFavorable = !m_macroAnalyzer.IsRiskOn() && !m_macroAnalyzer.IsRiskOff();
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckNewsSentiment - " +
                         "Favorable: " + (isFavorable ? "YES" : "NO"));
    }
    
    return isFavorable;
}

//+------------------------------------------------------------------+
//| RF-375: Hallmark 8 - Williams %R Sentiment                       |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::CheckWilliamsR(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CHallmarkAnalyzer::CheckWilliamsR - Error: Módulo no inicializado");
        return false;
    }
    
    if(!m_useSentiment) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckWilliamsR - Sentimiento desactivado por configuración");
        }
        return true;
    }
    
    if(m_utils == NULL) {
        Print("CHallmarkAnalyzer::CheckWilliamsR - Error: CUtils no disponible");
        return false;
    }
    
    //--- Calcular Williams %R (15 periodos)
    double williamsR = m_utils.CalculateWilliamsR(symbol, PERIOD_D1, 15);
    if(williamsR == 0) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CHallmarkAnalyzer::CheckWilliamsR - No se pudo calcular Williams %R");
        }
        return true;  // No se pudo calcular, no bloquea
    }
    
    //--- Interpretación
    //  0 a -20: Sobrecompra extrema (bajista)
    // -80 a -100: Sobreventa extrema (alcista)
    bool isAligned = false;
    
    if(expectedBias == BIAS_BULLISH) {
        isAligned = (williamsR <= -80);  // Sobreventa = señal alcista
    } else if(expectedBias == BIAS_BEARISH) {
        isAligned = (williamsR >= -20);  // Sobrecompra = señal bajista
    }
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CHallmarkAnalyzer::CheckWilliamsR - Williams %R: " + DoubleToString(williamsR, 1) +
                         " | Expected: " + m_utils.GetBiasName(expectedBias) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-375: Análisis completo de los 8 Hallmarks                     |
//+------------------------------------------------------------------+
HallmarkResult CHallmarkAnalyzer::Analyze(string symbol, ENUM_BIAS expectedBias) {
    HallmarkResult result;
    
    //--- Inicializar resultado
    ZeroMemory(result);
    result.totalScore = 0;
    result.isQualified = false;
    result.summary = "";
    
    if(!m_isInitialized) {
        result.summary = "Módulo no inicializado";
        return result;
    }
    
    //--- Hallmark 1: Market Profiles
    result.marketProfiles = CheckMarketProfiles(symbol, expectedBias);
    if(result.marketProfiles) {
        result.totalScore++;
        result.details[0] = "✅ Market Profile alineado";
    } else {
        result.details[0] = "❌ Market Profile NO alineado";
    }
    
    //--- Hallmark 2: Intermarket Analysis
    result.intermarketAnalysis = CheckIntermarket(expectedBias);
    if(result.intermarketAnalysis) {
        result.totalScore++;
        result.details[1] = "✅ Intermarket alineado";
    } else {
        result.details[1] = "❌ Intermarket NO alineado";
    }
    
    //--- Hallmark 3: COT Hedging
    result.cotHedging = CheckCOTHedging(expectedBias);
    if(result.cotHedging) {
        result.totalScore++;
        result.details[2] = "✅ COT alineado";
    } else {
        result.details[2] = "❌ COT NO alineado";
    }
    
    //--- Hallmark 4: Open Interest
    result.openInterest = CheckOpenInterest(symbol, expectedBias);
    if(result.openInterest) {
        result.totalScore++;
        result.details[3] = "✅ Open Interest alineado";
    } else {
        result.details[3] = "❌ Open Interest NO alineado";
    }
    
    //--- Hallmark 5: Seasonal
    result.seasonal = CheckSeasonal(symbol, expectedBias);
    if(result.seasonal) {
        result.totalScore++;
        result.details[4] = "✅ Seasonal alineado";
    } else {
        result.details[4] = "❌ Seasonal NO alineado";
    }
    
    //--- Hallmark 6: Volatility Contraction
    result.volatilityContraction = CheckVolatilityContraction(symbol);
    if(result.volatilityContraction) {
        result.totalScore++;
        result.details[5] = "✅ Volatilidad contraída";
    } else {
        result.details[5] = "❌ Volatilidad NO contraída";
    }
    
    //--- Hallmark 7: News Sentiment
    result.newsSentiment = CheckNewsSentiment();
    if(result.newsSentiment) {
        result.totalScore++;
        result.details[6] = "✅ Sin noticias de alto impacto";
    } else {
        result.details[6] = "❌ Hay noticias de alto impacto";
    }
    
    //--- Hallmark 8: Williams %R Sentiment
    result.williamsR = CheckWilliamsR(symbol, expectedBias);
    if(result.williamsR) {
        result.totalScore++;
        result.details[7] = "✅ Williams %R alineado";
    } else {
        result.details[7] = "❌ Williams %R NO alineado";
    }
    
    //--- Determinar si califica
    result.isQualified = (result.totalScore >= m_minHallmarks);
    result.summary = "Score: " + IntegerToString(result.totalScore) + "/8" +
                     (result.isQualified ? " - ✅ CALIFICADO" : " - ❌ NO CALIFICADO");
    
    if(m_utils != NULL) {
        m_utils.LogInfo("CHallmarkAnalyzer::Analyze - " + symbol +
                        " | Score: " + IntegerToString(result.totalScore) + "/8" +
                        " | Min: " + IntegerToString(m_minHallmarks) +
                        " | Qualified: " + (result.isQualified ? "YES" : "NO"));
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| RF-375: Obtener puntuación de Hallmarks                          |
//+------------------------------------------------------------------+
int CHallmarkAnalyzer::GetScore(string symbol, ENUM_BIAS expectedBias) {
    HallmarkResult result = Analyze(symbol, expectedBias);
    return result.totalScore;
}

//+------------------------------------------------------------------+
//| RF-375: Verificar si es un setup explosivo                       |
//+------------------------------------------------------------------+
bool CHallmarkAnalyzer::IsExplosive(string symbol, ENUM_BIAS expectedBias) {
    HallmarkResult result = Analyze(symbol, expectedBias);
    return result.isQualified;
}

//+------------------------------------------------------------------+
//| RF-375: Generar reporte de Hallmarks                             |
//+------------------------------------------------------------------+
string CHallmarkAnalyzer::GetHallmarkReport(string symbol, ENUM_BIAS expectedBias) {
    HallmarkResult result = Analyze(symbol, expectedBias);
    
    string report = "=== HALLMARK REPORT ===\n";
    report += "Símbolo: " + symbol + "\n";
    report += "Bias Esperado: " + m_utils.GetBiasName(expectedBias) + "\n";
    report += "---\n";
    report += "1. Market Profiles: " + result.details[0] + "\n";
    report += "2. Intermarket: " + result.details[1] + "\n";
    report += "3. COT Hedging: " + result.details[2] + "\n";
    report += "4. Open Interest: " + result.details[3] + "\n";
    report += "5. Seasonal: " + result.details[4] + "\n";
    report += "6. Volatility: " + result.details[5] + "\n";
    report += "7. News Sentiment: " + result.details[6] + "\n";
    report += "8. Williams %R: " + result.details[7] + "\n";
    report += "---\n";
    report += "SCORE: " + IntegerToString(result.totalScore) + "/8\n";
    report += "MÍNIMO: " + IntegerToString(m_minHallmarks) + "/8\n";
    report += "RESULTADO: " + (result.isQualified ? "✅ EXPLOSIVO" : "❌ NO EXPLOSIVO") + "\n";
    report += "=========================";
    
    return report;
}

#endif // __CHALLMARKANALYZER_MQH__