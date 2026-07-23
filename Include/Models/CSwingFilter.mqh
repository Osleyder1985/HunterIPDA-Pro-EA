//+------------------------------------------------------------------+
//|                                                    CSwingFilter.mqh |
//|                     HunterIPDA Pro EA - v1.8 - Módulo Swing Filter |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo implementa el proceso de filtrado en cascada para    |
//| Swing Trading. Aplica 8 etapas de filtro:                        |
//|                                                                  |
//| 1. Seasonal Tendency (OBLIGATORIO - RF-377)                     |
//| 2. Major Market Analysis (4 Asset Classes - RF-378)             |
//| 3. Intermarket Analysis (RF-370)                                |
//| 4. COT Hedging Program (OBLIGATORIO - RF-379)                   |
//| 5. Open Interest Filter (10-15% cambio - RF-380)                |
//| 6. Top-Down Analysis (Monthly→Weekly→Daily→4H - RF-346)         |
//| 7. 8 Hallmarks Scoring (≥5/8 para calificar - RF-375)           |
//| 8. Volatility & Sentiment Filters (RF-373, RF-374)             |
//|                                                                  |
//| RFs asociados: RF-324 a RF-385                                  |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                      |
//|   - CUtils: Funciones auxiliares                                |
//|   - CConfig: Configuración                                      |
//|   - CSeasonal: Tendencias estacionales                          |
//|   - CCOTAnalyzer: Análisis COT                                  |
//|   - COIAnalyzer: Análisis Open Interest                         |
//|   - CMacroAnalyzer: Análisis macro                              |
//|   - CContext: Análisis de contexto                              |
//|   - CMultiAsset: Análisis multi-asset                           |
//|   - CDataRange: IPDA Data Ranges                                |
//|                                                                  |
//| Versión: 1.3                                                     |
//| Fecha: 23/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 23/07/2026  | Versión inicial del módulo               |
//| 1.1     | 23/07/2026  | Corregido CheckCOT - método sin         |
//|         |             | parámetros (GetCommercialBias)           |
//| 1.2     | 23/07/2026  | Corregido CheckOpenInterest - usar       |
//|         |             | métodos individuales de COIAnalyzer      |
//| 1.3     | 23/07/2026  | Añadida implementación de IsInsideBar()  |
//+------------------------------------------------------------------+

#ifndef __CSWINGFILTER_MQH__
#define __CSWINGFILTER_MQH__

//--- Includes necesarios
#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CSeasonal.mqh"
#include "../Analysis/CCOTAnalyzer.mqh"
#include "../Analysis/COIAnalyzer.mqh"
#include "../Analysis/CMacroAnalyzer.mqh"
#include "../Analysis/CContext.mqh"
#include "../Analysis/CMultiAsset.mqh"
#include "../Analysis/CDataRange.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//--- RF-375: Estructura para almacenar la puntuación de los 8 Hallmarks
struct HallmarkScore {
    bool marketProfiles;          // Market Profile (RF-325)
    bool intermarketAnalysis;     // Intermarket Analysis (RF-370)
    bool cotHedging;              // COT Hedging Program (RF-379)
    bool openInterest;            // Open Interest (RF-380)
    bool seasonal;                // Seasonal (RF-377)
    bool volatilityContraction;   // Volatility Contraction (RF-373)
    bool newsSentiment;           // News Sentiment (RF-509)
    bool williamsR;               // Williams %R Sentiment (RF-374)
    int totalScore;               // Puntuación total (0-8)
};

//--- RF-376: Estructura para el resultado del filtro en cascada
struct SwingFilterResult {
    bool seasonalPassed;
    bool majorMarketPassed;
    bool intermarketPassed;
    bool cotPassed;
    bool oiPassed;
    bool topDownPassed;
    bool hallmarksPassed;
    bool volatilityPassed;
    bool sentimentPassed;
    int hallmarkScore;
    bool isQualified;
    string reason;
    ENUM_BIAS expectedBias;
    string symbol;
    ENUM_TIMEFRAMES entryTF;
    datetime timestamp;
};

//+------------------------------------------------------------------+
//| CLASE CSwingFilter                                               |
//+------------------------------------------------------------------+
class CSwingFilter {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CUtils*            m_utils;
    CSeasonal*         m_seasonal;
    CCOTAnalyzer*      m_cotAnalyzer;
    COIAnalyzer*       m_oiAnalyzer;
    CMacroAnalyzer*    m_macroAnalyzer;
    CContext*          m_context;
    CMultiAsset*       m_multiAsset;
    CDataRange*        m_dataRange;
    
    bool               m_isInitialized;
    bool               m_useCOT;
    bool               m_useOI;
    bool               m_useVolatility;
    bool               m_useSentiment;
    double             m_minRR;
    int                m_minHallmarks;
    int                m_oiChangeThreshold;
    double             m_williamsRThreshold;
    double             m_volatilityThreshold;
    
    //--- Métodos privados
    bool               ValidateDependencies();
    
    //+------------------------------------------------------------------+
    //| RF-377: Seasonal como primer filtro obligatorio                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que la tendencia estacional del activo confirme la      |
    //| dirección esperada. Este es el PRIMER filtro obligatorio.       |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| En la metodología ICT, las tendencias estacionales de 40+ años   |
    //| son un filtro de contexto fundamental. Sin seasonal confirmada,  |
    //| no se ejecuta swing trade.                                       |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: La tendencia estacional confirma la dirección esperada  |
    //| - False: No hay confirmación estacional                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar al inicio del proceso de filtrado. Si retorna false,      |
    //| descartar el setup inmediatamente.                               |
    //+------------------------------------------------------------------+
    bool               CheckSeasonal(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-378: Major Market Analysis (4 Asset Classes)                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que al menos 2 de las 4 grandes clases de activos       |
    //| (Bonos, Acciones, Materias Primas, Divisas) estén en tendencia   |
    //| en la dirección esperada.                                        |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que el dinero fluye entre las 4 clases de activos.    |
    //| Si al menos 2 clases confirman la dirección, el contexto es      |
    //| favorable para swing trading.                                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: 2+ clases de activos confirman la dirección             |
    //| - False: Menos de 2 clases confirman la dirección               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después del filtro seasonal. Si retorna false, el         |
    //| contexto macro no es favorable.                                  |
    //+------------------------------------------------------------------+
    bool               CheckMajorMarket(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-370: Intermarket Analysis Confluences                         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que las relaciones intermercado (DXY/Bonos/Materias     |
    //| Primas) confirmen la dirección esperada.                         |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El análisis intermercado (4 grupos) es fundamental para          |
    //| determinar el contexto macro de swing trading.                   |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Las relaciones intermercado confirman la dirección      |
    //| - False: Las relaciones intermercado NO confirman               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Major Market Analysis.                         |
    //+------------------------------------------------------------------+
    bool               CheckIntermarket(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-379: COT Hedging Program como filtro obligatorio - CORREGIDO  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que los datos COT (Commercial Hedging Program)          |
    //| confirmen la dirección esperada. Rango de 12 meses.              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que los comerciales (smart money) marcan la           |
    //| dirección del mercado. El Hedging Program revela si los         |
    //| comerciales están acumulando o distribuyendo.                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: COT confirma la dirección esperada                      |
    //| - False: COT NO confirma o es neutral                           |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Intermarket Analysis. Filtro obligatorio.      |
    //+------------------------------------------------------------------+
    bool               CheckCOT(ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-380: Open Interest Filter (10-15% cambio) - CORREGIDO         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que el Open Interest haya cambiado 10-15%+ en la        |
    //| dirección correcta para confirmar el movimiento.                 |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT utiliza OI como confirmación de reversiones en niveles       |
    //| clave. Cambios significativos de OI indican entrada de           |
    //| smart money.                                                     |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: OI cambió 10-15%+ en la dirección correcta              |
    //| - False: OI no cambió significativamente                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de COT. Confirmación de entrada de smart money.   |
    //+------------------------------------------------------------------+
    bool               CheckOpenInterest(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-346: Top-Down Analysis (Monthly→Weekly→Daily→4H)              |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica que todas las temporalidades desde Monthly hasta 4H     |
    //| estén alineadas en la dirección esperada.                        |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña el análisis Top-Down: Monthly para contexto,          |
    //| Weekly para objetivos, Daily para dirección, 4H para entrada.    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Todas las TFs están alineadas                           |
    //| - False: Alguna TF no está alineada                             |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de OI. Asegura que la estructura de mercado       |
    //| soporta el swing trade.                                          |
    //+------------------------------------------------------------------+
    bool               CheckTopDown(ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-375: Calificación de Explosividad (8 Hallmarks)               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Calcula cuántos de los 8 Hallmarks están presentes para el       |
    //| mercado actual. Retorna una puntuación de 0 a 8.                 |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT define 8 Hallmarks que, cuando se alinean, indican alta      |
    //| probabilidad de movimiento explosivo en swing trading.           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - 8: Todos los hallmarks presentes (máxima confianza)            |
    //| - 5-7: Suficientes para calificar                                |
    //| - 0-4: Insuficiente (no califica)                               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Top-Down Analysis. Si score ≥ 5, el setup      |
    //| tiene alta probabilidad de éxito.                                |
    //+------------------------------------------------------------------+
    int                CalculateHallmarks(string symbol, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-373: Volatility Contraction (Inside Bar)                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta contracciones de volatilidad (inside bars, rango         |
    //| estrecho) como señal de expansión inminente.                     |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT enseña que la volatilidad se contrae antes de expandirse.    |
    //| Inside bars son señales de que el mercado está "cargando"        |
    //| para un movimiento explosivo.                                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Volatilidad contraída (expansión inminente)              |
    //| - False: Volatilidad normal o alta                               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar antes de la entrada. Si no hay contracción, el timing     |
    //| puede no ser óptimo.                                             |
    //+------------------------------------------------------------------+
    bool               CheckVolatilityContraction(string symbol, ENUM_TIMEFRAMES tf);
    
    //+------------------------------------------------------------------+
    //| RF-374: Williams %R como filtro de sentimiento                   |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Usa Williams %R (15 periodos) como filtro de sentimiento.        |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| ICT utiliza Williams %R para medir el sentimiento del retail.    |
    //| Extremos de sobrecompra/sobreventa pueden indicar reversiones.   |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Williams %R confirma la dirección esperada               |
    //| - False: Williams %R está en contra                               |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Volatility Contraction. Filtro de sentimiento.  |
    //+------------------------------------------------------------------+
    bool               CheckWilliamsR(string symbol, ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias);
    
    //+------------------------------------------------------------------+
    //| RF-373: Verificar Inside Bar (contracción de volatilidad)        |
    //+------------------------------------------------------------------+
    bool               IsInsideBar(string symbol, ENUM_TIMEFRAMES tf);

public:
    //--- Constructor / Destructor
    CSwingFilter();
    ~CSwingFilter();
    
    //+------------------------------------------------------------------+
    //| RF-324: Inicialización del módulo                                |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Inicializa el módulo CSwingFilter con las dependencias           |
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
    //| RF-324: Establecer dependencias                                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Establece las referencias a los módulos de análisis necesarios.  |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El filtro de swing trading depende de múltiples fuentes de       |
    //| análisis: Seasonal, COT, OI, Macro, Contexto, Multi-Asset,       |
    //| Data Ranges.                                                     |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Todas las dependencias establecidas                     |
    //| - False: Alguna dependencia es NULL                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar después de Init, antes de usar el módulo.                 |
    //+------------------------------------------------------------------+
    bool SetDependencies(CSeasonal* seasonal, CCOTAnalyzer* cot, COIAnalyzer* oi,
                          CMacroAnalyzer* macro, CContext* context, CMultiAsset* multi,
                          CDataRange* dataRange);
    
    //+------------------------------------------------------------------+
    //| RF-324: Desinicialización                                        |
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
    //| RF-376: Filtro Principal - Million Dollar Setup                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Ejecuta el proceso completo de filtrado en cascada (8 etapas)    |
    //| para determinar si un setup de swing trading es calificado.      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El "Million Dollar Swing Setup" es el setup de máxima calidad    |
    //| de ICT, que requiere la alineación de TODOS los filtros.         |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - SwingFilterResult: Estructura con el resultado de cada etapa   |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar cuando se detecta un setup potencial. Usar el resultado   |
    //| para decidir si ejecutar el swing trade.                         |
    //+------------------------------------------------------------------+
    SwingFilterResult IsQualifiedForSwing(string symbol, ENUM_BIAS expectedBias, ENUM_TIMEFRAMES entryTF);
    
    //--- Filtros por Etapa (Getters de resultados individuales)
    bool PassesSeasonalFilter(string symbol, ENUM_BIAS expectedBias);
    bool PassesMajorMarketFilter(ENUM_BIAS expectedBias);
    bool PassesIntermarketFilter(ENUM_BIAS expectedBias);
    bool PassesCOTFilter(ENUM_BIAS expectedBias);
    bool PassesOIFilter(string symbol, ENUM_BIAS expectedBias);
    bool PassesTopDownFilter(ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias);
    int  GetHallmarkScore(string symbol, ENUM_BIAS expectedBias);
    bool PassesHallmarkThreshold(int score);
    bool PassesVolatilityFilter(string symbol, ENUM_TIMEFRAMES tf);
    bool PassesSentimentFilter(string symbol, ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias);
    
    //--- RF-376: Verificación de Setup Completo
    bool IsMillionDollarSetup(string symbol, ENUM_BIAS expectedBias, ENUM_TIMEFRAMES entryTF);
    
    //--- RF-336/345/361: Getters y Setters
    double GetMinRR() const { return m_minRR; }
    int    GetMinHallmarks() const { return m_minHallmarks; }
    bool   GetUseCOT() const { return m_useCOT; }
    bool   GetUseOI() const { return m_useOI; }
    
    void SetMinRR(double minRR) { if(minRR >= 1.0) m_minRR = minRR; }
    void SetMinHallmarks(int minHallmarks) { if(minHallmarks >= 0 && minHallmarks <= 8) m_minHallmarks = minHallmarks; }
    void SetUseCOT(bool useCOT) { m_useCOT = useCOT; }
    void SetUseOI(bool useOI) { m_useOI = useOI; }
    void SetUseVolatility(bool useVolatility) { m_useVolatility = useVolatility; }
    void SetUseSentiment(bool useSentiment) { m_useSentiment = useSentiment; }
    void SetOIChangeThreshold(int threshold) { if(threshold >= 5 && threshold <= 30) m_oiChangeThreshold = threshold; }
    void SetWilliamsRThreshold(double threshold) { if(threshold >= 0 && threshold <= 100) m_williamsRThreshold = threshold; }
    
    //--- Reportes
    string GetFilterReport(string symbol, ENUM_BIAS expectedBias);
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CSwingFilter::CSwingFilter() {
    m_config = NULL;
    m_utils = NULL;
    m_seasonal = NULL;
    m_cotAnalyzer = NULL;
    m_oiAnalyzer = NULL;
    m_macroAnalyzer = NULL;
    m_context = NULL;
    m_multiAsset = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
    m_useCOT = true;
    m_useOI = true;
    m_useVolatility = true;
    m_useSentiment = true;
    m_minRR = 3.0;
    m_minHallmarks = 5;
    m_oiChangeThreshold = 10;
    m_williamsRThreshold = 20.0;
    m_volatilityThreshold = 30.0;
}

//--- Destructor
CSwingFilter::~CSwingFilter() {
    Deinit();
}

//+------------------------------------------------------------------+
//| RF-324: Inicialización                                           |
//+------------------------------------------------------------------+
bool CSwingFilter::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CSwingFilter::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    if(!ValidateDependencies()) {
        Print("CSwingFilter::Init - Error: Validación de dependencias fallida");
        return false;
    }
    
    //--- Cargar configuración desde CConfig usando GetConfig()
    SConfig cfg = m_config.GetConfig();
    m_useCOT = cfg.swingCOTRequired;
    m_useOI = cfg.swingOIRequired;
    m_minRR = cfg.minRR;
    m_minHallmarks = cfg.swingHallmarksMin;
    m_oiChangeThreshold = (int)cfg.oiChangeSignificance;
    m_williamsRThreshold = 20.0;  // Valor por defecto, no hay campo en SConfig
    
    m_isInitialized = true;
    Print("CSwingFilter inicializado correctamente");
    return true;
}

//+------------------------------------------------------------------+
//| RF-324: Establecer dependencias                                  |
//+------------------------------------------------------------------+
bool CSwingFilter::SetDependencies(CSeasonal* seasonal, CCOTAnalyzer* cot, COIAnalyzer* oi,
                                    CMacroAnalyzer* macro, CContext* context, CMultiAsset* multi,
                                    CDataRange* dataRange) {
    if(seasonal == NULL || cot == NULL || oi == NULL || 
       macro == NULL || context == NULL || multi == NULL || dataRange == NULL) {
        Print("CSwingFilter::SetDependencies - Error: Alguna dependencia es NULL");
        return false;
    }
    
    m_seasonal = seasonal;
    m_cotAnalyzer = cot;
    m_oiAnalyzer = oi;
    m_macroAnalyzer = macro;
    m_context = context;
    m_multiAsset = multi;
    m_dataRange = dataRange;
    
    Print("CSwingFilter: Dependencias establecidas correctamente");
    return true;
}

//--- Desinicialización
void CSwingFilter::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_seasonal = NULL;
    m_cotAnalyzer = NULL;
    m_oiAnalyzer = NULL;
    m_macroAnalyzer = NULL;
    m_context = NULL;
    m_multiAsset = NULL;
    m_dataRange = NULL;
    m_isInitialized = false;
}

//--- Validación de dependencias
bool CSwingFilter::ValidateDependencies() {
    if(m_config == NULL || m_utils == NULL) {
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| RF-377: Seasonal Filter (OBLIGATORIO)                            |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckSeasonal(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckSeasonal - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_seasonal == NULL) {
        Print("CSwingFilter::CheckSeasonal - Error: CSeasonal no disponible");
        return false;
    }
    
    if(!m_seasonal.IsInitialized()) {
        Print("CSwingFilter::CheckSeasonal - Error: CSeasonal no inicializado");
        return false;
    }
    
    //--- Obtener bias estacional
    ENUM_BIAS seasonalBias = m_seasonal.GetSeasonalBias(symbol);
    if(seasonalBias == BIAS_NEUTRAL) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckSeasonal - Seasonal neutral para " + symbol);
        }
        return false;  // Sin seasonal confirmada
    }
    
    //--- Verificar alineación con la dirección esperada
    bool isAligned = (seasonalBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckSeasonal - " + symbol + 
                         " | Seasonal: " + (seasonalBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-378: Major Market Analysis                                    |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckMajorMarket(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckMajorMarket - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_multiAsset == NULL) {
        Print("CSwingFilter::CheckMajorMarket - Error: CMultiAsset no disponible");
        return false;
    }
    
    if(!m_multiAsset.IsInitialized()) {
        Print("CSwingFilter::CheckMajorMarket - Error: CMultiAsset no inicializado");
        return false;
    }
    
    //--- Obtener conteo de clases de activos alineadas
    int alignedCount = 0;
    
    //--- Verificar cada clase de activo
    if(m_multiAsset.IsBondsAligned(expectedBias)) alignedCount++;
    if(m_multiAsset.IsCommoditiesAligned(expectedBias)) alignedCount++;
    if(m_multiAsset.IsCurrenciesAligned(expectedBias)) alignedCount++;
    if(m_multiAsset.IsStocksAligned(expectedBias)) alignedCount++;
    
    //--- Requerir al menos 2 clases alineadas
    bool isAligned = (alignedCount >= 2);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckMajorMarket - Clases alineadas: " + IntegerToString(alignedCount) +
                         "/4 | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-370: Intermarket Analysis                                     |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckIntermarket(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckIntermarket - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_macroAnalyzer == NULL) {
        Print("CSwingFilter::CheckIntermarket - Error: CMacroAnalyzer no disponible");
        return false;
    }
    
    if(!m_macroAnalyzer.IsInitialized()) {
        Print("CSwingFilter::CheckIntermarket - Error: CMacroAnalyzer no inicializado");
        return false;
    }
    
    //--- Verificar relaciones intermercado
    ENUM_BIAS intermarketBias = m_macroAnalyzer.GetIntermarketBias();
    if(intermarketBias == BIAS_NEUTRAL) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckIntermarket - Intermarket neutral - no bloquea");
        }
        return true;  // Neutral no bloquea
    }
    
    bool isAligned = (intermarketBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckIntermarket - Intermarket: " +
                         (intermarketBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-379: COT Hedging Program (OBLIGATORIO) - CORREGIDO            |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckCOT(ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckCOT - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_cotAnalyzer == NULL) {
        Print("CSwingFilter::CheckCOT - Error: CCOTAnalyzer no disponible");
        return false;
    }
    
    if(!m_cotAnalyzer.IsInitialized()) {
        Print("CSwingFilter::CheckCOT - Error: CCOTAnalyzer no inicializado");
        return false;
    }
    
    if(!m_useCOT) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckCOT - COT desactivado por configuración");
        }
        return true;  // COT desactivado, no bloquea
    }
    
    //--- Obtener bias COT (método sin parámetros)
    ENUM_BIAS cotBias = m_cotAnalyzer.GetCommercialBias();
    if(cotBias == BIAS_NEUTRAL) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckCOT - COT neutral - no confirma");
        }
        return false;  // COT neutral no confirma
    }
    
    bool isAligned = (cotBias == expectedBias);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckCOT - COT: " +
                         (cotBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-380: Open Interest Filter (10-15% cambio) - CORREGIDO         |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckOpenInterest(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckOpenInterest - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_oiAnalyzer == NULL) {
        Print("CSwingFilter::CheckOpenInterest - Error: COIAnalyzer no disponible");
        return false;
    }
    
    if(!m_oiAnalyzer.IsInitialized()) {
        Print("CSwingFilter::CheckOpenInterest - Error: COIAnalyzer no inicializado");
        return false;
    }
    
    if(!m_useOI) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckOpenInterest - OI desactivado por configuración");
        }
        return true;  // OI desactivado, no bloquea
    }
    
    //--- Actualizar datos OI para el símbolo
    m_oiAnalyzer.SetSymbol(symbol);
    m_oiAnalyzer.Update(symbol);
    
    //--- Obtener datos de OI usando métodos individuales de COIAnalyzer
    double changePercent = m_oiAnalyzer.GetOIChangePercent();
    bool isIncreasing = m_oiAnalyzer.IsOIIncreasing();
    bool isDecreasing = m_oiAnalyzer.IsOIDecreasing();
    
    //--- Verificar cambio significativo (10-15%+)
    if(MathAbs(changePercent) < m_oiChangeThreshold) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckOpenInterest - Cambio OI insuficiente: " +
                             DoubleToString(changePercent, 1) + "% < " + IntegerToString(m_oiChangeThreshold) + "%");
        }
        return false;  // Cambio insuficiente
    }
    
    //--- Verificar dirección
    bool isAligned = false;
    if(expectedBias == BIAS_BULLISH) {
        isAligned = isIncreasing;
    } else if(expectedBias == BIAS_BEARISH) {
        isAligned = isDecreasing;
    }
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckOpenInterest - OI cambio: " +
                         DoubleToString(changePercent, 1) + "%" +
                         " | Dirección: " + (isIncreasing ? "↑" : (isDecreasing ? "↓" : "=")) +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-346: Top-Down Analysis                                        |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckTopDown(ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckTopDown - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_context == NULL) {
        Print("CSwingFilter::CheckTopDown - Error: CContext no disponible");
        return false;
    }
    
    if(!m_context.IsInitialized()) {
        Print("CSwingFilter::CheckTopDown - Error: CContext no inicializado");
        return false;
    }
    
    if(m_dataRange == NULL) {
        Print("CSwingFilter::CheckTopDown - Error: CDataRange no disponible");
        return false;
    }
    
    if(!m_dataRange.IsInitialized()) {
        Print("CSwingFilter::CheckTopDown - Error: CDataRange no inicializado");
        return false;
    }
    
    //--- Verificar alineación Monthly
    ENUM_BIAS monthlyBias = m_context.GetMonthlyBias();
    if(monthlyBias != BIAS_NEUTRAL && monthlyBias != expectedBias) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckTopDown - Monthly no alineado: " +
                             (monthlyBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                             " vs Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH"));
        }
        return false;
    }
    
    //--- Verificar alineación Weekly
    ENUM_BIAS weeklyBias = m_context.GetWeeklyBias();
    if(weeklyBias != BIAS_NEUTRAL && weeklyBias != expectedBias) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckTopDown - Weekly no alineado: " +
                             (weeklyBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                             " vs Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH"));
        }
        return false;
    }
    
    //--- Verificar alineación Daily
    ENUM_BIAS dailyBias = m_context.GetDailyBias();
    if(dailyBias != BIAS_NEUTRAL && dailyBias != expectedBias) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckTopDown - Daily no alineado: " +
                             (dailyBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                             " vs Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH"));
        }
        return false;
    }
    
    //--- Verificar IOF (Institutional Order Flow)
    ENUM_BIAS iofBias = m_dataRange.GetIOF();
    if(iofBias != BIAS_NEUTRAL && iofBias != expectedBias) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckTopDown - IOF no alineado: " +
                             (iofBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                             " vs Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH"));
        }
        return false;
    }
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckTopDown - Todas las TFs alineadas para " +
                         (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH"));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| RF-375: 8 Hallmarks Scoring                                      |
//+------------------------------------------------------------------+
int CSwingFilter::CalculateHallmarks(string symbol, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CalculateHallmarks - Error: Módulo no inicializado");
        return 0;
    }
    
    int score = 0;
    
    //--- Hallmark 1: Market Profile (RF-325)
    if(m_context != NULL && m_context.IsInitialized() && 
       m_context.GetMarketStructureBias() == expectedBias) {
        score++;
    }
    
    //--- Hallmark 2: Intermarket Analysis (RF-370)
    if(CheckIntermarket(expectedBias)) {
        score++;
    }
    
    //--- Hallmark 3: COT Hedging (RF-379)
    if(CheckCOT(expectedBias)) {
        score++;
    }
    
    //--- Hallmark 4: Open Interest (RF-380)
    if(CheckOpenInterest(symbol, expectedBias)) {
        score++;
    }
    
    //--- Hallmark 5: Seasonal (RF-377)
    if(CheckSeasonal(symbol, expectedBias)) {
        score++;
    }
    
    //--- Hallmark 6: Volatility Contraction (RF-373)
    if(CheckVolatilityContraction(symbol, PERIOD_D1)) {
        score++;
    }
    
    //--- Hallmark 7: News Sentiment (RF-509)
    if(m_macroAnalyzer != NULL && m_macroAnalyzer.IsInitialized() && 
       !m_macroAnalyzer.IsRiskOn() && !m_macroAnalyzer.IsRiskOff()) {
        score++;  // Entorno neutral = favorable
    }
    
    //--- Hallmark 8: Williams %R Sentiment (RF-374)
    if(CheckWilliamsR(symbol, PERIOD_D1, expectedBias)) {
        score++;
    }
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CalculateHallmarks - Score: " + IntegerToString(score) + "/8");
    }
    
    return score;
}

//+------------------------------------------------------------------+
//| RF-373: IsInsideBar - Verificar contracción de volatilidad       |
//+------------------------------------------------------------------+
bool CSwingFilter::IsInsideBar(string symbol, ENUM_TIMEFRAMES tf) {
    if(!m_isInitialized || m_utils == NULL) {
        return false;
    }
    
    //--- Obtener vela actual y anterior usando CUtils
    double high0 = m_utils.GetHighPrice(symbol, tf, 0);
    double low0 = m_utils.GetLowPrice(symbol, tf, 0);
    double high1 = m_utils.GetHighPrice(symbol, tf, 1);
    double low1 = m_utils.GetLowPrice(symbol, tf, 1);
    
    if(high0 == 0 || low0 == 0 || high1 == 0 || low1 == 0) return false;
    
    //--- Verificar que la vela actual esté dentro de la anterior
    return (high0 <= high1 && low0 >= low1);
}

//+------------------------------------------------------------------+
//| RF-373: Volatility Contraction Filter                            |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckVolatilityContraction(string symbol, ENUM_TIMEFRAMES tf) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckVolatilityContraction - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_utils == NULL) {
        Print("CSwingFilter::CheckVolatilityContraction - Error: CUtils no disponible");
        return false;
    }
    
    if(!m_useVolatility) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckVolatilityContraction - Volatilidad desactivada por configuración");
        }
        return true;
    }
    
    //--- Verificar si hay inside bar (contracción de volatilidad)
    bool isInsideBar = IsInsideBar(symbol, tf);
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CSwingFilter::CheckVolatilityContraction - Inside Bar: " +
                         (isInsideBar ? "YES" : "NO"));
    }
    
    return isInsideBar;
}

//+------------------------------------------------------------------+
//| RF-374: Williams %R Sentiment Filter                             |
//+------------------------------------------------------------------+
bool CSwingFilter::CheckWilliamsR(string symbol, ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias) {
    if(!m_isInitialized) {
        Print("CSwingFilter::CheckWilliamsR - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_utils == NULL) {
        Print("CSwingFilter::CheckWilliamsR - Error: CUtils no disponible");
        return false;
    }
    
    if(!m_useSentiment) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckWilliamsR - Sentimiento desactivado por configuración");
        }
        return true;
    }
    
    //--- Calcular Williams %R (15 periodos)
    double williamsR = m_utils.CalculateWilliamsR(symbol, tf, 15);
    if(williamsR == 0) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CSwingFilter::CheckWilliamsR - No se pudo calcular Williams %R");
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
        m_utils.LogDebug("CSwingFilter::CheckWilliamsR - Williams %R: " + DoubleToString(williamsR, 1) +
                         " | Expected: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : "BEARISH") +
                         " | Aligned: " + (isAligned ? "YES" : "NO"));
    }
    
    return isAligned;
}

//+------------------------------------------------------------------+
//| RF-376: Filtro Principal - IsQualifiedForSwing                   |
//+------------------------------------------------------------------+
SwingFilterResult CSwingFilter::IsQualifiedForSwing(string symbol, ENUM_BIAS expectedBias, ENUM_TIMEFRAMES entryTF) {
    SwingFilterResult result;
    
    //--- Inicializar resultado
    ZeroMemory(result);
    result.symbol = symbol;
    result.expectedBias = expectedBias;
    result.entryTF = entryTF;
    result.timestamp = TimeCurrent();
    result.isQualified = false;
    result.reason = "";
    
    if(!m_isInitialized) {
        result.reason = "Módulo no inicializado";
        return result;
    }
    
    //--- Etapa 1: Seasonal (OBLIGATORIO)
    result.seasonalPassed = CheckSeasonal(symbol, expectedBias);
    if(!result.seasonalPassed) {
        result.reason = "Filtro Seasonal fallido (OBLIGATORIO)";
        return result;
    }
    
    //--- Etapa 2: Major Market Analysis
    result.majorMarketPassed = CheckMajorMarket(expectedBias);
    if(!result.majorMarketPassed) {
        result.reason = "Major Market Analysis fallido (menos de 2 clases alineadas)";
        return result;
    }
    
    //--- Etapa 3: Intermarket Analysis
    result.intermarketPassed = CheckIntermarket(expectedBias);
    if(!result.intermarketPassed) {
        result.reason = "Intermarket Analysis fallido";
        return result;
    }
    
    //--- Etapa 4: COT Hedging Program (OBLIGATORIO) - CORREGIDO
    result.cotPassed = CheckCOT(expectedBias);
    if(!result.cotPassed && m_useCOT) {
        result.reason = "COT Hedging Program fallido (OBLIGATORIO)";
        return result;
    }
    
    //--- Etapa 5: Open Interest Filter
    result.oiPassed = CheckOpenInterest(symbol, expectedBias);
    if(!result.oiPassed && m_useOI) {
        result.reason = "Open Interest Filter fallido (cambio insuficiente)";
        return result;
    }
    
    //--- Etapa 6: Top-Down Analysis
    result.topDownPassed = CheckTopDown(entryTF, expectedBias);
    if(!result.topDownPassed) {
        result.reason = "Top-Down Analysis fallido (alguna TF no alineada)";
        return result;
    }
    
    //--- Etapa 7: 8 Hallmarks
    result.hallmarkScore = CalculateHallmarks(symbol, expectedBias);
    result.hallmarksPassed = PassesHallmarkThreshold(result.hallmarkScore);
    if(!result.hallmarksPassed) {
        result.reason = "Hallmarks insuficientes (score: " + IntegerToString(result.hallmarkScore) + "/" + IntegerToString(m_minHallmarks) + " mínimo)";
        return result;
    }
    
    //--- Etapa 8: Volatility & Sentiment
    result.volatilityPassed = CheckVolatilityContraction(symbol, entryTF);
    result.sentimentPassed = CheckWilliamsR(symbol, entryTF, expectedBias);
    
    if(!result.volatilityPassed && m_useVolatility) {
        result.reason = "Volatility Contraction no detectada";
        return result;
    }
    
    if(!result.sentimentPassed && m_useSentiment) {
        result.reason = "Sentiment Filter fallido (Williams %R)";
        return result;
    }
    
    //--- TODOS los filtros pasaron
    result.isQualified = true;
    result.reason = "Setup calificado para Swing Trading - Todos los filtros pasaron";
    
    if(m_utils != NULL) {
        m_utils.LogInfo("CSwingFilter::IsQualifiedForSwing - " + symbol + " CALIFICADO para Swing Trading");
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| RF-376: Million Dollar Setup                                     |
//+------------------------------------------------------------------+
bool CSwingFilter::IsMillionDollarSetup(string symbol, ENUM_BIAS expectedBias, ENUM_TIMEFRAMES entryTF) {
    SwingFilterResult result = IsQualifiedForSwing(symbol, expectedBias, entryTF);
    return result.isQualified;
}

//--- Filtros por Etapa (Getters de resultados individuales)
bool CSwingFilter::PassesSeasonalFilter(string symbol, ENUM_BIAS expectedBias) {
    return CheckSeasonal(symbol, expectedBias);
}

bool CSwingFilter::PassesMajorMarketFilter(ENUM_BIAS expectedBias) {
    return CheckMajorMarket(expectedBias);
}

bool CSwingFilter::PassesIntermarketFilter(ENUM_BIAS expectedBias) {
    return CheckIntermarket(expectedBias);
}

bool CSwingFilter::PassesCOTFilter(ENUM_BIAS expectedBias) {
    return CheckCOT(expectedBias);
}

bool CSwingFilter::PassesOIFilter(string symbol, ENUM_BIAS expectedBias) {
    return CheckOpenInterest(symbol, expectedBias);
}

bool CSwingFilter::PassesTopDownFilter(ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias) {
    return CheckTopDown(tf, expectedBias);
}

int CSwingFilter::GetHallmarkScore(string symbol, ENUM_BIAS expectedBias) {
    return CalculateHallmarks(symbol, expectedBias);
}

bool CSwingFilter::PassesHallmarkThreshold(int score) {
    return (score >= m_minHallmarks);
}

bool CSwingFilter::PassesVolatilityFilter(string symbol, ENUM_TIMEFRAMES tf) {
    return CheckVolatilityContraction(symbol, tf);
}

bool CSwingFilter::PassesSentimentFilter(string symbol, ENUM_TIMEFRAMES tf, ENUM_BIAS expectedBias) {
    return CheckWilliamsR(symbol, tf, expectedBias);
}

//+------------------------------------------------------------------+
//| RF-376: Reporte de Filtro                                        |
//+------------------------------------------------------------------+
string CSwingFilter::GetFilterReport(string symbol, ENUM_BIAS expectedBias) {
    string report = "=== CSwingFilter - Reporte de Filtro ===\n";
    report += "Símbolo: " + symbol + "\n";
    report += "Bias Esperado: " + (expectedBias == BIAS_BULLISH ? "BULLISH" : (expectedBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Timestamp: " + TimeToString(TimeCurrent()) + "\n";
    report += "---\n";
    
    //--- Ejecutar filtro completo
    SwingFilterResult result = IsQualifiedForSwing(symbol, expectedBias, PERIOD_H4);
    
    report += "Etapa 1 - Seasonal: " + (result.seasonalPassed ? "✅ PASADO" : "❌ FALLIDO") + " (OBLIGATORIO)\n";
    report += "Etapa 2 - Major Market: " + (result.majorMarketPassed ? "✅ PASADO" : "❌ FALLIDO") + " (≥2 clases alineadas)\n";
    report += "Etapa 3 - Intermarket: " + (result.intermarketPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "Etapa 4 - COT: " + (result.cotPassed ? "✅ PASADO" : "❌ FALLIDO") + " (OBLIGATORIO)\n";
    report += "Etapa 5 - Open Interest: " + (result.oiPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "Etapa 6 - Top-Down: " + (result.topDownPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "Etapa 7 - Hallmarks: " + IntegerToString(result.hallmarkScore) + "/8 (mínimo: " + IntegerToString(m_minHallmarks) + ") " + (result.hallmarksPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "Etapa 8 - Volatility: " + (result.volatilityPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "Etapa 8 - Sentiment: " + (result.sentimentPassed ? "✅ PASADO" : "❌ FALLIDO") + "\n";
    report += "---\n";
    report += "RESULTADO FINAL: " + (result.isQualified ? "✅ CALIFICADO" : "❌ NO CALIFICADO") + "\n";
    report += "Razón: " + result.reason + "\n";
    report += "==============================";
    
    return report;
}

#endif // __CSWINGFILTER_MQH__