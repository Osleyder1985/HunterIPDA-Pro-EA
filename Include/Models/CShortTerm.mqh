//+------------------------------------------------------------------+
//|                                                    CShortTerm.mqh |
//|                     HunterIPDA Pro EA - v1.8 - Módulo Models      |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo implementa el modelo de Short-Term Trading con       |
//| ejecución en 4H/1H, gestión de weekly range profiles y           |
//| MM manipulation templates.                                       |
//|                                                                  |
//| Incluye:                                                         |
//| - Weekly Range Profiles (10+ tipos)                              |
//| - MM Manipulation Templates                                      |
//| - Intra-Week Reversal Detection                                  |
//| - OSOK (One Shot One Kill) Mode                                  |
//| - Time + Price Blending                                          |
//| - PD Arrays Hierarchy                                            |
//|                                                                  |
//| RFs asociados: RF-386 a RF-471                                  |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                      |
//|   - CUtils: Funciones auxiliares                                |
//   - CConfig: Configuración                                      |
//|   - CContext: Análisis de contexto                              |
//|   - CDataRange: IPDA Data Ranges                                |
//|   - CSeasonal: Tendencias estacionales                          |
//|   - CCOTAnalyzer: Análisis COT                                  |
//|   - CMultiAsset: Análisis multi-asset                           |
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

#ifndef __CSHORTTERM_MQH__
#define __CSHORTTERM_MQH__

//--- Includes necesarios
#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Analysis/CContext.mqh"
#include "../Analysis/CDataRange.mqh"
#include "../Analysis/CSeasonal.mqh"
#include "../Analysis/CCOTAnalyzer.mqh"
#include "../Analysis/CMultiAsset.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//--- RF-404: Estructura para Weekly Range Profile
struct WeeklyProfileData {
    ENUM_WEEKLY_PROFILE profile;
    string             name;
    bool               isConfirmed;
    bool               isHighProbability;
    double             expectedHigh;
    double             expectedLow;
    datetime           formationStart;
    datetime           formationEnd;
    ENUM_BIAS          expectedBias;
    string             description;
    double             probabilityScore;
};

//+------------------------------------------------------------------+
//| RF-419: Estructura para MM Manipulation Template - CORREGIDO     |
//+------------------------------------------------------------------+
struct MMTemplateData {
    ENUM_MM_TEMPLATE   tmpl;              // CORREGIDO
    string             name;
    bool               isActive;
    double             triggerLevel;
    double             targetLevel;
    double             stopLevel;
    ENUM_BIAS          expectedBias;
    datetime           detectionTime;
    string             description;
};

//--- RF-459: Estructura para Reversal Detection
struct ReversalDetectionData {
    bool               isReversal;
    ENUM_REVERSAL_TYPE type;
    ENUM_BIAS          bias;
    double             reversalLevel;
    double             speed;
    double             magnitude;
    double             strength;
    datetime           detectionTime;
    string             description;
};

//--- RF-465: Estructura para OSOK Projection
struct OSOKProjectionData {
    double             highProjection;
    double             lowProjection;
    double             fib127;
    double             fib168;
    double             pdArrayLevel;
    bool               isConverged;
    ENUM_PROJECTION_METHOD method;
    double             tolerance;
    datetime           projectionTime;
    bool               isValid;
    string             description;
};

//+------------------------------------------------------------------+
//| CLASE CShortTerm                                                  |
//+------------------------------------------------------------------+
class CShortTerm {
private:
    //--- Dependencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CContext*          m_context;
    CDataRange*        m_dataRange;
    CSeasonal*         m_seasonal;
    CCOTAnalyzer*      m_cotAnalyzer;
    CMultiAsset*       m_multiAsset;
    bool               m_isInitialized;
    
    //--- Configuración
    ENUM_TIMEFRAMES    m_executableTF;
    int                m_minDuration;
    int                m_maxDuration;
    int                m_minPipsObjective;
    int                m_maxPipsObjective;
    bool               m_osokEnabled;
    int                m_osokMaxPerWeek;
    double             m_osokProjectionTolerance;
    ENUM_PROJECTION_METHOD m_osokProjectionMethod;
    double             m_fibExtension1;
    double             m_fibExtension2;
    bool               m_wrpEnabled;
    bool               m_wrpSeekDestroyAvoid;
    bool               m_wrpSummerAvoidance;
    
    //--- Estado
    WeeklyProfileData  m_currentProfile;
    MMTemplateData     m_currentTemplate;
    OSOKProjectionData m_currentProjection;
    ReversalDetectionData m_currentReversal;
    
    double             m_weeklyHigh;
    double             m_weeklyLow;
    double             m_mondayRange;
    double             m_tuesdayRange;
    double             m_wednesdayRange;
    datetime           m_weekStart;
    datetime           m_weekEnd;
    bool               m_isWeekRangeComplete;
    double             m_weekRangeProgress;
    int                m_osokCounter;
    datetime           m_osokWeekStart;
    
    //--- PD Arrays cache
    bool               m_pdArrayCache[7];
    double             m_pdArrayLevels[7];
    bool               m_pdArrayExhausted[7];
    datetime           m_pdArrayCacheTime;
    
    //--- Métodos privados
    bool               ValidateDependencies();
    void               DetectWeeklyRangeProfile(string symbol);
    void               DetectMMManipulationTemplate(string symbol);
    void               CalculateWeeklyHighLow(string symbol);
    void               ResetWeeklyState();
    void               UpdateOSOKCounter();
    bool               IsOSOKFrequencyValid();
    
    //--- RF-398-404: Weekly Range Detection
    bool               DetectClassicTuesdayLow(string symbol);
    bool               DetectClassicTuesdayHigh(string symbol);
    bool               DetectWednesdayLow(string symbol);
    bool               DetectWednesdayHigh(string symbol);
    bool               DetectThursdayReversal(string symbol);
    bool               DetectMidweekRally(string symbol);
    bool               DetectMidweekDecline(string symbol);
    bool               DetectSeekDestroy(string symbol);
    bool               DetectWednesdayWeeklyReversal(string symbol);
    ENUM_WEEKLY_PROFILE ClassifyProfile(string symbol);
    
    //--- RF-409: MM Manipulation Templates
    ENUM_MM_TEMPLATE   ClassifyMMTemplate(string symbol);
    bool               DetectTemplateClassicTuesdayLow(string symbol);
    bool               DetectTemplateClassicTuesdayHigh(string symbol);
    bool               DetectTemplateWednesdayLow(string symbol);
    bool               DetectTemplateWednesdayHigh(string symbol);
    bool               DetectTemplateThursdayReversal(string symbol);
    bool               DetectTemplateMidweekRally(string symbol);
    bool               DetectTemplateMidweekDecline(string symbol);
    bool               DetectTemplateSeekDestroy(string symbol);
    bool               DetectTemplateWednesdayWeeklyReversal(string symbol);
    
    //--- RF-451-460: Intra-Week Reversal
    bool               DetectSpeedMagnitudeSignal(string symbol);
    double             CalculateSpeed(string symbol, int bars);
    double             CalculateMagnitude(string symbol, int bars);
    bool               IsOverlappingModelsConflict();
    ENUM_REVERSAL_TYPE ClassifyReversal(string symbol);
    
    //--- RF-461-471: OSOK
    bool               IsOSOKSeasonalValid(string symbol);
    bool               IsOSOKCOTValid();
    bool               IsOSOKKillZoneValid();
    double             CalculateOSOKHighProjection(string symbol);
    double             CalculateOSOKLowProjection(string symbol);
    bool               CheckFIBConvergence(string symbol, double high, double low);
    
    //--- RF-422-428: Time + Price Blending - DUPLICADO ELIMINADO
    // double          GetBlendedEntry(string symbol, ENUM_BIAS bias);  // ← ELIMINADO
    bool               IsLowResistanceLiquidityRun(string symbol, ENUM_BIAS bias);
    bool               IsHighResistanceLiquidityRun(string symbol, ENUM_BIAS bias);
    
    //--- RF-431-440: Range Quadrants
    bool               IsInLowerQuadrant(double price, double high, double low);
    bool               IsInUpperQuadrant(double price, double high, double low);
    bool               IsInChopZone(double price, double high, double low);
    
    //--- PD Arrays Helper
    void               UpdatePDArrayCache(string symbol);
    ENUM_PD_ARRAY      GetNextPDArray(ENUM_BIAS bias);
    
public:
    //--- Constructor / Destructor
    CShortTerm();
    ~CShortTerm();
    
    //+------------------------------------------------------------------+
    //| RF-386: Inicialización del módulo                                |
    //+------------------------------------------------------------------+
    bool Init(CConfig* config, CUtils* utils);
    
    //+------------------------------------------------------------------+
    //| RF-386: Establecer dependencias                                  |
    //+------------------------------------------------------------------+
    bool SetDependencies(CContext* context, CDataRange* dataRange,
                         CSeasonal* seasonal, CCOTAnalyzer* cotAnalyzer,
                         CMultiAsset* multiAsset);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //+------------------------------------------------------------------+
    //| RF-386: Análisis principal                                       |
    //+------------------------------------------------------------------+
    bool Analyze(string symbol);
    bool IsShortTermValid(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-461: OSOK Analysis                                            |
    //+------------------------------------------------------------------+
    bool IsOSOKValid(string symbol);
    bool IsOSOKQualified(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-387-404: Weekly Range Profiles                                |
    //+------------------------------------------------------------------+
    ENUM_WEEKLY_PROFILE GetCurrentProfile() const { return m_currentProfile.profile; }
    WeeklyProfileData GetProfileData() const { return m_currentProfile; }
    string GetProfileName(ENUM_WEEKLY_PROFILE profile) const;
    bool IsProfileHighProbability(ENUM_WEEKLY_PROFILE profile) const;
    bool IsProfileValid(ENUM_WEEKLY_PROFILE profile) const;
    bool ShouldAvoidProfile(ENUM_WEEKLY_PROFILE profile) const;
    
    //+------------------------------------------------------------------+
    //| RF-409-412: MM Manipulation Templates                            |
    //+------------------------------------------------------------------+
    ENUM_MM_TEMPLATE GetCurrentTemplate() const { return m_currentTemplate.tmpl; }  // CORREGIDO
    MMTemplateData GetTemplateData() const { return m_currentTemplate; }
    string GetTemplateName(ENUM_MM_TEMPLATE tmpl) const;      // CORREGIDO
    bool IsTemplateValid(ENUM_MM_TEMPLATE tmpl) const;        // CORREGIDO
    
    //+------------------------------------------------------------------+
    //| RF-413-415: Fibonacci Projections                                |
    //+------------------------------------------------------------------+
    double GetFibonacci127(double high, double low);
    double GetFibonacci168(double high, double low);
    double GetSymmetricalTarget(double high, double low);
    
    //+------------------------------------------------------------------+
    //| RF-422: Time + Price Blending                                    |
    //+------------------------------------------------------------------+
    bool IsTimePriceBlended(string symbol);
    double GetBlendedEntry(string symbol, ENUM_BIAS bias);
    double GetBlendedTarget(string symbol, ENUM_BIAS bias);
    
    //+------------------------------------------------------------------+
    //| RF-423-424: PD Arrays                                            |
    //+------------------------------------------------------------------+
    bool IsPDArrayAvailable(ENUM_PD_ARRAY type);
    bool IsPDArrayFresh(ENUM_PD_ARRAY type);
    bool IsPDArrayExhausted(ENUM_PD_ARRAY type);
    double GetPDArrayLevel(ENUM_PD_ARRAY type);
    ENUM_PD_ARRAY GetBestPDArray(ENUM_BIAS bias);
    
    //+------------------------------------------------------------------+
    //| RF-431-440: Range Quadrants                                      |
    //+------------------------------------------------------------------+
    bool IsInLowerQuadrant(double price);
    bool IsInUpperQuadrant(double price);
    bool IsInChopZone(double price);
    bool IsBuyZoneValid(double price);
    bool IsSellZoneValid(double price);
    double GetQuadrantEntry(ENUM_BIAS bias);
    
    //+------------------------------------------------------------------+
    //| RF-441: Executable TF                                            |
    //+------------------------------------------------------------------+
    ENUM_TIMEFRAMES GetExecutableTF() const { return m_executableTF; }
    void SetExecutableTF(ENUM_TIMEFRAMES tf);
    
    //+------------------------------------------------------------------+
    //| RF-451-460: Intra-Week Reversal Detection                        |
    //+------------------------------------------------------------------+
    bool IsIntraWeekReversal(string symbol);
    ReversalDetectionData GetReversalData() const { return m_currentReversal; }
    ENUM_REVERSAL_TYPE GetReversalType();
    double GetReversalStrength();
    bool IsSpeedMagnitudeSignal();
    
    //+------------------------------------------------------------------+
    //| RF-461-471: OSOK Getters                                         |
    //+------------------------------------------------------------------+
    OSOKProjectionData GetOSOKProjection() const { return m_currentProjection; }
    double GetOSOKHighProjection();
    double GetOSOKLowProjection();
    bool IsOSOKProjectionValid();
    int GetOSOKTradesThisWeek() const { return m_osokCounter; }
    bool IsOSOKFrequencyValid() const;
    void ResetOSOKCounter();
    
    //--- Getters
    double GetWeeklyHigh() const { return m_weeklyHigh; }
    double GetWeeklyLow() const { return m_weeklyLow; }
    datetime GetWeekStart() const { return m_weekStart; }
    datetime GetWeekEnd() const { return m_weekEnd; }
    bool IsWeekRangeComplete() const { return m_isWeekRangeComplete; }
    double GetWeekRangeProgress() const { return m_weekRangeProgress; }
    
    //--- RF-442: Weekly Dividers (visualización)
    string GetWeeklyDividers();
    
    //--- Configuración OSOK
    void SetOSOKEnabled(bool enabled) { m_osokEnabled = enabled; }
    void SetOSOKMaxPerWeek(int max) { if(max > 0) m_osokMaxPerWeek = max; }
    void SetOSOKProjectionTolerance(double tolerance) { m_osokProjectionTolerance = MathMax(0, tolerance); }
    
    //--- Reportes
    string GetWeeklyProfileReport();
    string GetShortTermReport(string symbol);
    string GetOSOKReport(string symbol);
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CShortTerm::CShortTerm() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_dataRange = NULL;
    m_seasonal = NULL;
    m_cotAnalyzer = NULL;
    m_multiAsset = NULL;
    m_isInitialized = false;
    
    //--- Configuración por defecto
    m_executableTF = PERIOD_H4;
    m_minDuration = 1;
    m_maxDuration = 5;
    m_minPipsObjective = 30;
    m_maxPipsObjective = 100;
    m_osokEnabled = false;
    m_osokMaxPerWeek = 1;
    m_osokProjectionTolerance = 10;
    m_osokProjectionMethod = METHOD_FIB_CONVERGENCE;
    m_fibExtension1 = 1.27;
    m_fibExtension2 = 1.68;
    m_wrpEnabled = true;
    m_wrpSeekDestroyAvoid = true;
    m_wrpSummerAvoidance = true;
    
    //--- Estado
    ZeroMemory(m_currentProfile);
    ZeroMemory(m_currentTemplate);
    ZeroMemory(m_currentProjection);
    ZeroMemory(m_currentReversal);
    m_weeklyHigh = 0;
    m_weeklyLow = 0;
    m_mondayRange = 0;
    m_tuesdayRange = 0;
    m_wednesdayRange = 0;
    m_weekStart = 0;
    m_weekEnd = 0;
    m_isWeekRangeComplete = false;
    m_weekRangeProgress = 0;
    m_osokCounter = 0;
    m_osokWeekStart = 0;
    m_pdArrayCacheTime = 0;
    
    for(int i = 0; i < 7; i++) {
        m_pdArrayCache[i] = false;
        m_pdArrayLevels[i] = 0;
        m_pdArrayExhausted[i] = false;
    }
}

//--- Destructor
CShortTerm::~CShortTerm() {
    Deinit();
}

//+------------------------------------------------------------------+
//| RF-386: Inicialización                                           |
//+------------------------------------------------------------------+
bool CShortTerm::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CShortTerm::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    if(!ValidateDependencies()) {
        Print("CShortTerm::Init - Error: Validación de dependencias fallida");
        return false;
    }
    
    //--- Cargar configuración
    SConfig cfg = m_config.GetConfig();
    m_executableTF = cfg.stExecutableTF;
    m_minDuration = cfg.stMinDuration;
    m_maxDuration = cfg.stMaxDuration;
    m_minPipsObjective = cfg.stMinPipsObjective;
    m_maxPipsObjective = cfg.stMaxPipsObjective;
    m_osokEnabled = cfg.osokEnabled;
    m_osokMaxPerWeek = cfg.osokMaxTradesPerWeek;
    m_osokProjectionTolerance = cfg.osokProjectionTolerance;
    m_osokProjectionMethod = cfg.osokProjectionMethod;
    m_fibExtension1 = cfg.osokFIBExtension1;
    m_fibExtension2 = cfg.osokFIBExtension2;
    m_wrpEnabled = cfg.wrpEnabled;
    m_wrpSeekDestroyAvoid = cfg.wrpSeekDestroyAvoid;
    m_wrpSummerAvoidance = cfg.wrpSummerAvoidance;
    
    m_isInitialized = true;
    Print("CShortTerm inicializado correctamente");
    return true;
}

//+------------------------------------------------------------------+
//| RF-386: Establecer dependencias                                  |
//+------------------------------------------------------------------+
bool CShortTerm::SetDependencies(CContext* context, CDataRange* dataRange,
                                  CSeasonal* seasonal, CCOTAnalyzer* cotAnalyzer,
                                  CMultiAsset* multiAsset) {
    if(context == NULL || dataRange == NULL || seasonal == NULL || 
       cotAnalyzer == NULL || multiAsset == NULL) {
        Print("CShortTerm::SetDependencies - Error: Alguna dependencia es NULL");
        return false;
    }
    
    m_context = context;
    m_dataRange = dataRange;
    m_seasonal = seasonal;
    m_cotAnalyzer = cotAnalyzer;
    m_multiAsset = multiAsset;
    
    Print("CShortTerm: Dependencias establecidas correctamente");
    return true;
}

//--- Desinicialización
void CShortTerm::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_context = NULL;
    m_dataRange = NULL;
    m_seasonal = NULL;
    m_cotAnalyzer = NULL;
    m_multiAsset = NULL;
    m_isInitialized = false;
}

//--- Validación de dependencias
bool CShortTerm::ValidateDependencies() {
    if(m_config == NULL || m_utils == NULL) {
        return false;
    }
    return true;
}

//--- Resetear estado semanal
void CShortTerm::ResetWeeklyState() {
    m_weeklyHigh = 0;
    m_weeklyLow = 0;
    m_mondayRange = 0;
    m_tuesdayRange = 0;
    m_wednesdayRange = 0;
    m_weekStart = 0;
    m_weekEnd = 0;
    m_isWeekRangeComplete = false;
    m_weekRangeProgress = 0;
    ZeroMemory(m_currentProfile);
    ZeroMemory(m_currentTemplate);
}

//+------------------------------------------------------------------+
//| RF-386: Análisis principal                                       |
//+------------------------------------------------------------------+
bool CShortTerm::Analyze(string symbol) {
    if(!m_isInitialized) {
        Print("CShortTerm::Analyze - Error: Módulo no inicializado");
        return false;
    }
    
    if(m_context == NULL || m_dataRange == NULL) {
        return false;
    }
    
    //--- Calcular weekly high/low
    CalculateWeeklyHighLow(symbol);
    
    //--- Detectar weekly range profile
    if(m_wrpEnabled) {
        DetectWeeklyRangeProfile(symbol);
    }
    
    //--- Detectar MM manipulation template
    DetectMMManipulationTemplate(symbol);
    
    //--- Actualizar PD Arrays cache
    UpdatePDArrayCache(symbol);
    
    //--- Detectar intra-week reversal
    m_currentReversal.isReversal = DetectSpeedMagnitudeSignal(symbol);
    if(m_currentReversal.isReversal) {
        m_currentReversal.type = ClassifyReversal(symbol);
        m_currentReversal.detectionTime = TimeCurrent();
    }
    
    //--- Calcular OSOK projection si está habilitado
    if(m_osokEnabled) {
        m_currentProjection.highProjection = CalculateOSOKHighProjection(symbol);
        m_currentProjection.lowProjection = CalculateOSOKLowProjection(symbol);
        m_currentProjection.fib127 = GetFibonacci127(m_weeklyHigh, m_weeklyLow);
        m_currentProjection.fib168 = GetFibonacci168(m_weeklyHigh, m_weeklyLow);
        m_currentProjection.isConverged = CheckFIBConvergence(symbol, m_currentProjection.highProjection, m_currentProjection.lowProjection);
        m_currentProjection.projectionTime = TimeCurrent();
        m_currentProjection.method = m_osokProjectionMethod;
        m_currentProjection.tolerance = m_osokProjectionTolerance;
        m_currentProjection.isValid = IsOSOKProjectionValid();
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| RF-386: Verificar validez de Short-Term                          |
//+------------------------------------------------------------------+
bool CShortTerm::IsShortTermValid(string symbol) {
    if(!m_isInitialized) return false;
    
    //--- Verificar que estamos dentro de la semana
    datetime now = TimeCurrent();
    if(now < m_weekStart || now > m_weekEnd) {
        ResetWeeklyState();
        CalculateWeeklyHighLow(symbol);
    }
    
    //--- Verificar que el perfil semanal sea válido
    if(!IsProfileValid(m_currentProfile.profile)) return false;
    
    //--- Verificar que no sea un perfil de baja probabilidad
    if(ShouldAvoidProfile(m_currentProfile.profile)) return false;
    
    //--- Verificar rango semanal completado
    if(m_isWeekRangeComplete && m_weekRangeProgress > 90) {
        return false;  // Rango ya completado
    }
    
    //--- Verificar días permitidos (Mon-Wed para entradas)
    int day = m_utils.GetDayOfWeek(now);
    if(day < 1 || day > 3) return false;  // Solo Lunes a Miércoles
    
    return true;
}

//+------------------------------------------------------------------+
//| RF-461: OSOK Analysis                                            |
//+------------------------------------------------------------------+
bool CShortTerm::IsOSOKValid(string symbol) {
    if(!m_isInitialized) return false;
    if(!m_osokEnabled) return false;
    
    //--- Verificar frecuencia (1 por semana)
    if(!IsOSOKFrequencyValid()) return false;
    
    //--- Verificar seasonal (obligatorio)
    if(!IsOSOKSeasonalValid(symbol)) return false;
    
    //--- Verificar COT (obligatorio)
    if(!IsOSOKCOTValid()) return false;
    
    //--- Verificar Kill Zone
    if(!IsOSOKKillZoneValid()) return false;
    
    //--- Verificar proyección
    if(!m_currentProjection.isValid) return false;
    
    return true;
}

bool CShortTerm::IsOSOKQualified(string symbol) {
    return IsOSOKValid(symbol) && IsShortTermValid(symbol);
}

//+------------------------------------------------------------------+
//| RF-387-404: Weekly Range Profiles                                |
//+------------------------------------------------------------------+
void CShortTerm::CalculateWeeklyHighLow(string symbol) {
    datetime now = TimeCurrent();
    m_weekStart = m_utils.GetWeekStart(now);
    m_weekEnd = m_utils.GetWeekEnd(now);
    
    //--- Obtener high y low de la semana
    m_weeklyHigh = m_utils.GetHighestHigh(symbol, PERIOD_D1, 5);
    m_weeklyLow = m_utils.GetLowestLow(symbol, PERIOD_D1, 5);
    
    //--- Calcular progreso del rango semanal
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double range = m_weeklyHigh - m_weeklyLow;
    if(range > 0) {
        m_weekRangeProgress = ((currentPrice - m_weeklyLow) / range) * 100;
    }
    m_isWeekRangeComplete = m_weekRangeProgress > 95;
}

void CShortTerm::DetectWeeklyRangeProfile(string symbol) {
    //--- Detectar cada tipo de perfil
    if(DetectClassicTuesdayLow(symbol)) {
        m_currentProfile.profile = PROFILE_CLASSIC_TUESDAY_LOW;
    } else if(DetectClassicTuesdayHigh(symbol)) {
        m_currentProfile.profile = PROFILE_CLASSIC_TUESDAY_HIGH;
    } else if(DetectWednesdayLow(symbol)) {
        m_currentProfile.profile = PROFILE_WEDNESDAY_LOW;
    } else if(DetectWednesdayHigh(symbol)) {
        m_currentProfile.profile = PROFILE_WEDNESDAY_HIGH;
    } else if(DetectThursdayReversal(symbol)) {
        m_currentProfile.profile = PROFILE_THURSDAY_REVERSAL_BULLISH;
    } else if(DetectMidweekRally(symbol)) {
        m_currentProfile.profile = PROFILE_MIDWEEK_RALLY;
    } else if(DetectMidweekDecline(symbol)) {
        m_currentProfile.profile = PROFILE_MIDWEEK_DECLINE;
    } else if(DetectSeekDestroy(symbol)) {
        m_currentProfile.profile = PROFILE_SEEK_DESTROY_BULLISH;
    } else if(DetectWednesdayWeeklyReversal(symbol)) {
        m_currentProfile.profile = PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH;
    } else {
        m_currentProfile.profile = PROFILE_UNKNOWN;
    }
    
    m_currentProfile.name = GetProfileName(m_currentProfile.profile);
    m_currentProfile.isConfirmed = true;
    m_currentProfile.isHighProbability = IsProfileHighProbability(m_currentProfile.profile);
    m_currentProfile.expectedHigh = m_weeklyHigh;
    m_currentProfile.expectedLow = m_weeklyLow;
    m_currentProfile.formationStart = m_weekStart;
    m_currentProfile.formationEnd = m_weekEnd;
    m_currentProfile.expectedBias = m_context.GetOverallBias();
    m_currentProfile.probabilityScore = m_currentProfile.isHighProbability ? 70.0 : 30.0;
}

//--- RF-398: Classic Tuesday Low
bool CShortTerm::DetectClassicTuesdayLow(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 2) return false;  // Martes
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double low20 = m_utils.GetLowestLow(symbol, PERIOD_D1, 20);
    
    return currentPrice < low20 && currentPrice < m_weeklyLow;
}

//--- RF-398: Classic Tuesday High
bool CShortTerm::DetectClassicTuesdayHigh(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 2) return false;  // Martes
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double high20 = m_utils.GetHighestHigh(symbol, PERIOD_D1, 20);
    
    return currentPrice > high20 && currentPrice > m_weeklyHigh;
}

//--- RF-399: Wednesday Low
bool CShortTerm::DetectWednesdayLow(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 3) return false;  // Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double low40 = m_utils.GetLowestLow(symbol, PERIOD_D1, 40);
    
    return currentPrice < low40 && currentPrice < m_weeklyLow;
}

//--- RF-399: Wednesday High
bool CShortTerm::DetectWednesdayHigh(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 3) return false;  // Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double high40 = m_utils.GetHighestHigh(symbol, PERIOD_D1, 40);
    
    return currentPrice > high40 && currentPrice > m_weeklyHigh;
}

//--- RF-400: Thursday Reversal
bool CShortTerm::DetectThursdayReversal(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 4) return false;  // Jueves
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return false;
    
    double position = (currentPrice - m_weeklyLow) / range;
    
    //--- Reversión en zona premium o discount
    return position > 0.7 || position < 0.3;
}

//--- RF-401: Midweek Rally
bool CShortTerm::DetectMidweekRally(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day < 2 || day > 3) return false;  // Martes o Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double mondayClose = m_utils.GetClosePrice(symbol, PERIOD_D1, 2);
    
    return currentPrice > mondayClose * 1.01;
}

//--- RF-401: Midweek Decline
bool CShortTerm::DetectMidweekDecline(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day < 2 || day > 3) return false;  // Martes o Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double mondayClose = m_utils.GetClosePrice(symbol, PERIOD_D1, 2);
    
    return currentPrice < mondayClose * 0.99;
}

//--- RF-402: Seek and Destroy
bool CShortTerm::DetectSeekDestroy(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day < 1 || day > 3) return false;  // Lunes a Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return false;
    
    double position = (currentPrice - m_weeklyLow) / range;
    
    //--- Consolidación en el rango medio
    return position > 0.35 && position < 0.65;
}

//--- RF-403: Wednesday Weekly Reversal
bool CShortTerm::DetectWednesdayWeeklyReversal(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day != 3) return false;  // Miércoles
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return false;
    
    double position = (currentPrice - m_weeklyLow) / range;
    
    //--- Reversión desde extremo
    return position > 0.8 || position < 0.2;
}

//--- RF-404: Clasificar perfil
ENUM_WEEKLY_PROFILE CShortTerm::ClassifyProfile(string symbol) {
    if(DetectClassicTuesdayLow(symbol)) return PROFILE_CLASSIC_TUESDAY_LOW;
    if(DetectClassicTuesdayHigh(symbol)) return PROFILE_CLASSIC_TUESDAY_HIGH;
    if(DetectWednesdayLow(symbol)) return PROFILE_WEDNESDAY_LOW;
    if(DetectWednesdayHigh(symbol)) return PROFILE_WEDNESDAY_HIGH;
    if(DetectThursdayReversal(symbol)) return PROFILE_THURSDAY_REVERSAL_BULLISH;
    if(DetectMidweekRally(symbol)) return PROFILE_MIDWEEK_RALLY;
    if(DetectMidweekDecline(symbol)) return PROFILE_MIDWEEK_DECLINE;
    if(DetectSeekDestroy(symbol)) return PROFILE_SEEK_DESTROY_BULLISH;
    if(DetectWednesdayWeeklyReversal(symbol)) return PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH;
    return PROFILE_UNKNOWN;
}

//--- Obtener nombre del perfil
string CShortTerm::GetProfileName(ENUM_WEEKLY_PROFILE profile) const {
    switch(profile) {
        case PROFILE_CLASSIC_TUESDAY_LOW:   return "Classic Tuesday Low";
        case PROFILE_CLASSIC_TUESDAY_HIGH:  return "Classic Tuesday High";
        case PROFILE_WEDNESDAY_LOW:         return "Wednesday Low";
        case PROFILE_WEDNESDAY_HIGH:        return "Wednesday High";
        case PROFILE_THURSDAY_REVERSAL_BULLISH: return "Thursday Reversal Bullish";
        case PROFILE_THURSDAY_REVERSAL_BEARISH: return "Thursday Reversal Bearish";
        case PROFILE_MIDWEEK_RALLY:         return "Midweek Rally";
        case PROFILE_MIDWEEK_DECLINE:       return "Midweek Decline";
        case PROFILE_SEEK_DESTROY_BULLISH:  return "Seek & Destroy Bullish";
        case PROFILE_SEEK_DESTROY_BEARISH:  return "Seek & Destroy Bearish";
        case PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH: return "Wednesday Weekly Reversal Bullish";
        case PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BEARISH: return "Wednesday Weekly Reversal Bearish";
        default: return "Unknown Profile";
    }
}

//--- RF-404: Verificar si perfil es de alta probabilidad
bool CShortTerm::IsProfileHighProbability(ENUM_WEEKLY_PROFILE profile) const {
    switch(profile) {
        case PROFILE_CLASSIC_TUESDAY_LOW:
        case PROFILE_CLASSIC_TUESDAY_HIGH:
        case PROFILE_WEDNESDAY_LOW:
        case PROFILE_WEDNESDAY_HIGH:
        case PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH:
        case PROFILE_WEDNESDAY_WEEKLY_REVERSAL_BEARISH:
            return true;
        default:
            return false;
    }
}

//--- RF-402: Verificar si se debe evitar el perfil
bool CShortTerm::ShouldAvoidProfile(ENUM_WEEKLY_PROFILE profile) const {
    if(!m_wrpSeekDestroyAvoid) return false;
    
    return (profile == PROFILE_SEEK_DESTROY_BULLISH || 
            profile == PROFILE_SEEK_DESTROY_BEARISH);
}

//--- RF-404: Verificar si perfil es válido
bool CShortTerm::IsProfileValid(ENUM_WEEKLY_PROFILE profile) const {
    return profile != PROFILE_UNKNOWN;
}

//+------------------------------------------------------------------+
//| RF-409: MM Manipulation Templates                                |
//+------------------------------------------------------------------+
void CShortTerm::DetectMMManipulationTemplate(string symbol) {
    ENUM_MM_TEMPLATE detected = ClassifyMMTemplate(symbol);
    m_currentTemplate.tmpl = detected;     // CORREGIDO
    m_currentTemplate.name = GetTemplateName(detected);
    m_currentTemplate.isActive = detected != TEMPLATE_UNKNOWN;
    m_currentTemplate.detectionTime = TimeCurrent();
    m_currentTemplate.expectedBias = m_context.GetOverallBias();
}

ENUM_MM_TEMPLATE CShortTerm::ClassifyMMTemplate(string symbol) {
    if(DetectTemplateClassicTuesdayLow(symbol)) return TEMPLATE_CLASSIC_TUESDAY_LOW;
    if(DetectTemplateClassicTuesdayHigh(symbol)) return TEMPLATE_CLASSIC_TUESDAY_HIGH;
    if(DetectTemplateWednesdayLow(symbol)) return TEMPLATE_WEDNESDAY_LOW;
    if(DetectTemplateWednesdayHigh(symbol)) return TEMPLATE_WEDNESDAY_HIGH;
    if(DetectTemplateThursdayReversal(symbol)) return TEMPLATE_THURSDAY_REVERSAL_BULLISH;
    if(DetectTemplateMidweekRally(symbol)) return TEMPLATE_MIDWEEK_RALLY;
    if(DetectTemplateMidweekDecline(symbol)) return TEMPLATE_MIDWEEK_DECLINE;
    if(DetectTemplateSeekDestroy(symbol)) return TEMPLATE_SEEK_DESTROY_BULLISH;
    if(DetectTemplateWednesdayWeeklyReversal(symbol)) return TEMPLATE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH;
    return TEMPLATE_UNKNOWN;
}

bool CShortTerm::DetectTemplateClassicTuesdayLow(string symbol) {
    return DetectClassicTuesdayLow(symbol);
}

bool CShortTerm::DetectTemplateClassicTuesdayHigh(string symbol) {
    return DetectClassicTuesdayHigh(symbol);
}

bool CShortTerm::DetectTemplateWednesdayLow(string symbol) {
    return DetectWednesdayLow(symbol);
}

bool CShortTerm::DetectTemplateWednesdayHigh(string symbol) {
    return DetectWednesdayHigh(symbol);
}

bool CShortTerm::DetectTemplateThursdayReversal(string symbol) {
    return DetectThursdayReversal(symbol);
}

bool CShortTerm::DetectTemplateMidweekRally(string symbol) {
    return DetectMidweekRally(symbol);
}

bool CShortTerm::DetectTemplateMidweekDecline(string symbol) {
    return DetectMidweekDecline(symbol);
}

bool CShortTerm::DetectTemplateSeekDestroy(string symbol) {
    return DetectSeekDestroy(symbol);
}

bool CShortTerm::DetectTemplateWednesdayWeeklyReversal(string symbol) {
    return DetectWednesdayWeeklyReversal(symbol);
}

//--- Obtener nombre de la plantilla
string CShortTerm::GetTemplateName(ENUM_MM_TEMPLATE tmpl) const {
    switch(tmpl) {
        case TEMPLATE_CLASSIC_TUESDAY_LOW:   return "Classic Tuesday Low";
        case TEMPLATE_CLASSIC_TUESDAY_HIGH:  return "Classic Tuesday High";
        case TEMPLATE_WEDNESDAY_LOW:         return "Wednesday Low";
        case TEMPLATE_WEDNESDAY_HIGH:        return "Wednesday High";
        case TEMPLATE_THURSDAY_REVERSAL_BULLISH: return "Thursday Reversal Bullish";
        case TEMPLATE_THURSDAY_REVERSAL_BEARISH: return "Thursday Reversal Bearish";
        case TEMPLATE_MIDWEEK_RALLY:         return "Midweek Rally";
        case TEMPLATE_MIDWEEK_DECLINE:       return "Midweek Decline";
        case TEMPLATE_SEEK_DESTROY_BULLISH:  return "Seek & Destroy Bullish";
        case TEMPLATE_SEEK_DESTROY_BEARISH:  return "Seek & Destroy Bearish";
        case TEMPLATE_WEDNESDAY_WEEKLY_REVERSAL_BULLISH: return "Wednesday Weekly Reversal Bullish";
        case TEMPLATE_WEDNESDAY_WEEKLY_REVERSAL_BEARISH: return "Wednesday Weekly Reversal Bearish";
        default: return "Unknown Template";
    }
}

//--- Verificar si plantilla es válida
bool CShortTerm::IsTemplateValid(ENUM_MM_TEMPLATE tmpl) const {
    return tmpl != TEMPLATE_UNKNOWN;
}

//+------------------------------------------------------------------+
//| RF-413-415: Fibonacci Projections                                |
//+------------------------------------------------------------------+
double CShortTerm::GetFibonacci127(double high, double low) {
    if(high <= low) return 0;
    return low + (high - low) * m_fibExtension1;
}

double CShortTerm::GetFibonacci168(double high, double low) {
    if(high <= low) return 0;
    return low + (high - low) * m_fibExtension2;
}

double CShortTerm::GetSymmetricalTarget(double high, double low) {
    if(high <= low) return 0;
    double range = high - low;
    return high + range;  // 100% medida simétrica
}

//+------------------------------------------------------------------+
//| RF-422: Time + Price Blending                                    |
//+------------------------------------------------------------------+
bool CShortTerm::IsTimePriceBlended(string symbol) {
    if(m_context == NULL || m_dataRange == NULL) return false;
    
    //--- Verificar tiempo (Data Range)
    ENUM_BIAS timeBias = m_dataRange.GetIOF();
    if(timeBias == BIAS_NEUTRAL) return false;
    
    //--- Verificar precio (PD Array)
    ENUM_BIAS priceBias = BIAS_NEUTRAL;
    for(int i = 0; i < 7; i++) {
        if(m_pdArrayCache[i]) {
            priceBias = BIAS_BULLISH;
            break;
        }
    }
    
    return timeBias == priceBias;
}

double CShortTerm::GetBlendedEntry(string symbol, ENUM_BIAS bias) {
    if(m_dataRange == NULL) return 0;
    
    DataRange range = m_dataRange.GetDataRange();
    double entry = 0;
    
    if(bias == BIAS_BULLISH) {
        entry = range.low20 + (range.high20 - range.low20) * 0.382;
    } else {
        entry = range.high20 - (range.high20 - range.low20) * 0.382;
    }
    
    return entry;
}

double CShortTerm::GetBlendedTarget(string symbol, ENUM_BIAS bias) {
    if(m_dataRange == NULL) return 0;
    
    DataRange range = m_dataRange.GetDataRange();
    double target = 0;
    
    if(bias == BIAS_BULLISH) {
        target = range.high20 + (range.high20 - range.low20) * 0.618;
    } else {
        target = range.low20 - (range.high20 - range.low20) * 0.618;
    }
    
    return target;
}

//+------------------------------------------------------------------+
//| RF-435-438: Low/High Resistance Liquidity Run                    |
//+------------------------------------------------------------------+
bool CShortTerm::IsLowResistanceLiquidityRun(string symbol, ENUM_BIAS bias) {
    if(m_context == NULL) return false;
    
    ENUM_BIAS iof = m_context.GetIOF();
    if(iof == BIAS_NEUTRAL) return true;
    
    return iof == bias;
}

bool CShortTerm::IsHighResistanceLiquidityRun(string symbol, ENUM_BIAS bias) {
    if(m_context == NULL) return false;
    
    ENUM_BIAS iof = m_context.GetIOF();
    if(iof == BIAS_NEUTRAL) return false;
    
    return iof != bias;
}

//+------------------------------------------------------------------+
//| RF-431-440: Range Quadrants                                      |
//+------------------------------------------------------------------+
bool CShortTerm::IsInLowerQuadrant(double price, double high, double low) {
    if(high <= low) return false;
    double midpoint = (high + low) / 2;
    return price < midpoint;
}

bool CShortTerm::IsInUpperQuadrant(double price, double high, double low) {
    if(high <= low) return false;
    double midpoint = (high + low) / 2;
    return price > midpoint;
}

bool CShortTerm::IsInChopZone(double price, double high, double low) {
    if(high <= low) return false;
    double range = high - low;
    double lowerChop = low + range * 0.35;
    double upperChop = high - range * 0.35;
    return price >= lowerChop && price <= upperChop;
}

bool CShortTerm::IsInLowerQuadrant(double price) {
    return IsInLowerQuadrant(price, m_weeklyHigh, m_weeklyLow);
}

bool CShortTerm::IsInUpperQuadrant(double price) {
    return IsInUpperQuadrant(price, m_weeklyHigh, m_weeklyLow);
}

bool CShortTerm::IsInChopZone(double price) {
    return IsInChopZone(price, m_weeklyHigh, m_weeklyLow);
}

//--- RF-436: Best Buy Zone
bool CShortTerm::IsBuyZoneValid(double price) {
    if(m_weeklyHigh <= m_weeklyLow) return false;
    double range = m_weeklyHigh - m_weeklyLow;
    double lowerZone = m_weeklyLow + range * 0.0;
    double upperZone = m_weeklyLow + range * 0.3;
    return price >= lowerZone && price <= upperZone;
}

//--- RF-437: Best Sell Zone
bool CShortTerm::IsSellZoneValid(double price) {
    if(m_weeklyHigh <= m_weeklyLow) return false;
    double range = m_weeklyHigh - m_weeklyLow;
    double lowerZone = m_weeklyHigh - range * 0.3;
    double upperZone = m_weeklyHigh - range * 0.0;
    return price >= lowerZone && price <= upperZone;
}

//--- RF-436/437: Obtener entrada por cuadrante
double CShortTerm::GetQuadrantEntry(ENUM_BIAS bias) {
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return 0;
    
    if(bias == BIAS_BULLISH) {
        return m_weeklyLow + range * 0.25;  // Zona de compra
    } else {
        return m_weeklyHigh - range * 0.25;  // Zona de venta
    }
}

//+------------------------------------------------------------------+
//| RF-441: Executable TF                                            |
//+------------------------------------------------------------------+
void CShortTerm::SetExecutableTF(ENUM_TIMEFRAMES tf) {
    m_executableTF = tf;
}

//+------------------------------------------------------------------+
//| RF-451-460: Intra-Week Reversal Detection                        |
//+------------------------------------------------------------------+
bool CShortTerm::DetectSpeedMagnitudeSignal(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    if(day < 1 || day > 2) return false;  // Solo Lunes o Martes
    
    double speed = CalculateSpeed(symbol, 24);  // Velocidad en 24 horas
    double magnitude = CalculateMagnitude(symbol, 24);  // Magnitud en 24 horas
    
    m_currentReversal.speed = speed;
    m_currentReversal.magnitude = magnitude;
    
    //--- Umbrales: >200 pips en 24 horas o >2x ADR
    double adr = m_utils.CalculateADR(symbol, 5);
    if(adr <= 0) return false;
    
    return magnitude > 200 || magnitude > adr * 2;
}

double CShortTerm::CalculateSpeed(string symbol, int bars) {
    double closeArray[];
    ArraySetAsSeries(closeArray, true);
    if(CopyClose(symbol, PERIOD_H1, 0, bars + 1, closeArray) < bars + 1) return 0;
    
    double totalMovement = MathAbs(closeArray[0] - closeArray[bars]);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0;
    
    return totalMovement / point / bars;
}

double CShortTerm::CalculateMagnitude(string symbol, int bars) {
    double highArray[], lowArray[];
    ArraySetAsSeries(highArray, true);
    ArraySetAsSeries(lowArray, true);
    if(CopyHigh(symbol, PERIOD_H1, 0, bars, highArray) < bars) return 0;
    if(CopyLow(symbol, PERIOD_H1, 0, bars, lowArray) < bars) return 0;
    
    double high = highArray[ArrayMaximum(highArray)];
    double low = lowArray[ArrayMinimum(lowArray)];
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    if(point <= 0) return 0;
    
    return (high - low) / point;
}

bool CShortTerm::IsOverlappingModelsConflict() {
    if(m_context == NULL) return false;
    
    ENUM_BIAS monthlyBias = m_context.GetMonthlyBias();
    ENUM_BIAS weeklyBias = m_context.GetWeeklyBias();
    ENUM_BIAS dailyBias = m_context.GetDailyBias();
    
    //--- Conflicto: modelos de diferentes temporalidades no alineados
    if(monthlyBias != BIAS_NEUTRAL && weeklyBias != BIAS_NEUTRAL) {
        if(monthlyBias != weeklyBias) return true;
    }
    if(weeklyBias != BIAS_NEUTRAL && dailyBias != BIAS_NEUTRAL) {
        if(weeklyBias != dailyBias) return true;
    }
    
    return false;
}

ENUM_REVERSAL_TYPE CShortTerm::ClassifyReversal(string symbol) {
    datetime now = TimeCurrent();
    int day = m_utils.GetDayOfWeek(now);
    
    if(day == 4) return REVERSAL_INTRA_WEEK_HIGH;
    if(day == 3) return REVERSAL_INTRA_WEEK_LOW;
    
    return REVERSAL_UNKNOWN;
}

bool CShortTerm::IsIntraWeekReversal(string symbol) {
    return m_currentReversal.isReversal;
}

ENUM_REVERSAL_TYPE CShortTerm::GetReversalType() {
    return m_currentReversal.type;
}

double CShortTerm::GetReversalStrength() {
    return m_currentReversal.strength;
}

bool CShortTerm::IsSpeedMagnitudeSignal() {
    return DetectSpeedMagnitudeSignal(_Symbol);
}

//+------------------------------------------------------------------+
//| RF-461-471: OSOK                                                 |
//+------------------------------------------------------------------+
void CShortTerm::UpdateOSOKCounter() {
    datetime now = TimeCurrent();
    datetime weekStart = m_utils.GetWeekStart(now);
    
    if(weekStart > m_osokWeekStart) {
        m_osokCounter = 0;
        m_osokWeekStart = weekStart;
    }
}

bool CShortTerm::IsOSOKFrequencyValid() const {
    return m_osokCounter < m_osokMaxPerWeek;
}

void CShortTerm::ResetOSOKCounter() {
    m_osokCounter = 0;
    m_osokWeekStart = 0;
}

bool CShortTerm::IsOSOKSeasonalValid(string symbol) {
    if(m_seasonal == NULL) return false;
    return m_seasonal.IsSeasonalValid(symbol);
}

//+------------------------------------------------------------------+
//| RF-463/464: OSOK COT Validation - CORREGIDO v2                   |
//+------------------------------------------------------------------+
bool CShortTerm::IsOSOKCOTValid() {
    if(m_cotAnalyzer == NULL) {
        Print("CShortTerm::IsOSOKCOTValid - Error: CCOTAnalyzer no disponible");
        return false;
    }
    
    if(!m_cotAnalyzer.IsInitialized()) {
        Print("CShortTerm::IsOSOKCOTValid - Error: CCOTAnalyzer no inicializado");
        return false;
    }
    
    //--- Obtener bias COT
    ENUM_BIAS cotBias = m_cotAnalyzer.GetCommercialBias();
    
    //--- COT neutral no es válido para OSOK
    if(cotBias == BIAS_NEUTRAL) {
        if(m_utils != NULL) {
            m_utils.LogDebug("CShortTerm::IsOSOKCOTValid - COT neutral");
        }
        return false;
    }
    
    //--- Verificar que haya un programa activo (Buy Program o Sell Program)
    bool isBuyProgram = m_cotAnalyzer.IsBuyProgram();
    bool isSellProgram = m_cotAnalyzer.IsSellProgram();
    bool isHedgingProgram = m_cotAnalyzer.IsHedgingProgram();
    
    //--- Para OSOK, necesitamos un programa claro (Buy o Sell)
    bool isValid = isBuyProgram || isSellProgram || isHedgingProgram;
    
    if(m_utils != NULL) {
        m_utils.LogDebug("CShortTerm::IsOSOKCOTValid - " + 
                         "Buy: " + (isBuyProgram ? "S" : "N") +
                         " | Sell: " + (isSellProgram ? "S" : "N") +
                         " | Hedge: " + (isHedgingProgram ? "S" : "N") +
                         " | Valid: " + (isValid ? "YES" : "NO"));
    }
    
    return isValid;
}

bool CShortTerm::IsOSOKKillZoneValid() {
    if(m_utils == NULL) return false;
    datetime now = TimeCurrent();
    
    //--- Verificar Kill Zones: Asian (6-9 PM NY), London (1-5 AM NY), NY (7-10 AM NY)
    return m_utils.IsKillZoneActive(KZ_ASIAN, now) ||
           m_utils.IsKillZoneActive(KZ_LONDON, now) ||
           m_utils.IsKillZoneActive(KZ_NEW_YORK, now);
}

double CShortTerm::CalculateOSOKHighProjection(string symbol) {
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return 0;
    
    //--- Usar método de proyección configurado
    if(m_osokProjectionMethod == METHOD_FIB_CONVERGENCE) {
        double fib127 = GetFibonacci127(m_weeklyHigh, m_weeklyLow);
        double pdLevel = GetPDArrayLevel(PD_ORDER_BLOCK);
        if(pdLevel > 0) {
            return (fib127 + pdLevel) / 2;
        }
        return fib127;
    } else if(m_osokProjectionMethod == METHOD_PD_ARRAY_ONLY) {
        return GetPDArrayLevel(PD_ORDER_BLOCK);
    } else {
        //--- BLENDED
        double fib168 = GetFibonacci168(m_weeklyHigh, m_weeklyLow);
        double pdLevel = GetPDArrayLevel(PD_ORDER_BLOCK);
        if(pdLevel > 0) {
            return (fib168 + pdLevel) / 2;
        }
        return fib168;
    }
}

double CShortTerm::CalculateOSOKLowProjection(string symbol) {
    double range = m_weeklyHigh - m_weeklyLow;
    if(range <= 0) return 0;
    
    //--- Usar método de proyección configurado
    if(m_osokProjectionMethod == METHOD_FIB_CONVERGENCE) {
        double fib127 = m_weeklyHigh - (m_weeklyHigh - m_weeklyLow) * m_fibExtension1;
        double pdLevel = GetPDArrayLevel(PD_ORDER_BLOCK);
        if(pdLevel > 0) {
            return (fib127 + pdLevel) / 2;
        }
        return fib127;
    } else if(m_osokProjectionMethod == METHOD_PD_ARRAY_ONLY) {
        return GetPDArrayLevel(PD_ORDER_BLOCK);
    } else {
        //--- BLENDED
        double fib168 = m_weeklyHigh - (m_weeklyHigh - m_weeklyLow) * m_fibExtension2;
        double pdLevel = GetPDArrayLevel(PD_ORDER_BLOCK);
        if(pdLevel > 0) {
            return (fib168 + pdLevel) / 2;
        }
        return fib168;
    }
}

bool CShortTerm::CheckFIBConvergence(string symbol, double high, double low) {
    if(high <= 0 || low <= 0) return false;
    
    //--- Verificar convergencia con PD Arrays
    double pdLevel = GetPDArrayLevel(PD_ORDER_BLOCK);
    if(pdLevel <= 0) return false;
    
    double tolerance = m_osokProjectionTolerance * SymbolInfoDouble(symbol, SYMBOL_POINT);
    return MathAbs(high - pdLevel) < tolerance || MathAbs(low - pdLevel) < tolerance;
}

bool CShortTerm::IsOSOKProjectionValid() {
    if(m_currentProjection.highProjection <= 0 || m_currentProjection.lowProjection <= 0) return false;
    if(m_currentProjection.highProjection <= m_currentProjection.lowProjection) return false;
    
    //--- Verificar tolerancia
    if(m_currentProjection.isConverged) return true;
    
    //--- Si no hay convergencia, validar por rango
    double range = m_currentProjection.highProjection - m_currentProjection.lowProjection;
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    return range > 50 * point;
}

double CShortTerm::GetOSOKHighProjection() {
    return m_currentProjection.highProjection;
}

double CShortTerm::GetOSOKLowProjection() {
    return m_currentProjection.lowProjection;
}

//+------------------------------------------------------------------+
//| PD Arrays Helper                                                 |
//+------------------------------------------------------------------+
void CShortTerm::UpdatePDArrayCache(string symbol) {
    //--- Verificar si el caché está actualizado
    datetime now = TimeCurrent();
    if(now - m_pdArrayCacheTime < 3600) return;  // 1 hora de caché
    
    //--- Simular búsqueda de PD Arrays
    //--- En implementación real, se consultaría a CDetector
    m_pdArrayCache[PD_OLD_HIGH_LOW] = true;
    m_pdArrayCache[PD_REJECTION_BLOCK] = false;
    m_pdArrayCache[PD_ORDER_BLOCK] = true;
    m_pdArrayCache[PD_FVG] = true;
    m_pdArrayCache[PD_LIQUIDITY_VOID] = false;
    m_pdArrayCache[PD_BREAKER] = false;
    m_pdArrayCache[PD_MITIGATION_BLOCK] = true;
    
    //--- Niveles simulados
    m_pdArrayLevels[PD_OLD_HIGH_LOW] = m_weeklyHigh;
    m_pdArrayLevels[PD_ORDER_BLOCK] = m_weeklyLow + (m_weeklyHigh - m_weeklyLow) * 0.382;
    m_pdArrayLevels[PD_FVG] = m_weeklyLow + (m_weeklyHigh - m_weeklyLow) * 0.5;
    m_pdArrayLevels[PD_MITIGATION_BLOCK] = m_weeklyLow;
    
    m_pdArrayCacheTime = now;
}

bool CShortTerm::IsPDArrayAvailable(ENUM_PD_ARRAY type) {
    if(type < 0 || type >= 7) return false;
    return m_pdArrayCache[type];
}

bool CShortTerm::IsPDArrayFresh(ENUM_PD_ARRAY type) {
    if(type < 0 || type >= 7) return false;
    return m_pdArrayCache[type] && !m_pdArrayExhausted[type];
}

bool CShortTerm::IsPDArrayExhausted(ENUM_PD_ARRAY type) {
    if(type < 0 || type >= 7) return false;
    return m_pdArrayExhausted[type];
}

double CShortTerm::GetPDArrayLevel(ENUM_PD_ARRAY type) {
    if(type < 0 || type >= 7) return 0;
    if(!m_pdArrayCache[type]) return 0;
    return m_pdArrayLevels[type];
}

ENUM_PD_ARRAY CShortTerm::GetBestPDArray(ENUM_BIAS bias) {
    //--- Jerarquía: Breaker > Mitigation > Order Block > FVG > Rejection > Old High/Low
    if(IsPDArrayFresh(PD_BREAKER)) return PD_BREAKER;
    if(IsPDArrayFresh(PD_MITIGATION_BLOCK)) return PD_MITIGATION_BLOCK;
    if(IsPDArrayFresh(PD_ORDER_BLOCK)) return PD_ORDER_BLOCK;
    if(IsPDArrayFresh(PD_FVG)) return PD_FVG;
    if(IsPDArrayFresh(PD_REJECTION_BLOCK)) return PD_REJECTION_BLOCK;
    if(IsPDArrayFresh(PD_OLD_HIGH_LOW)) return PD_OLD_HIGH_LOW;
    return PD_LIQUIDITY_VOID;
}

//+------------------------------------------------------------------+
//| RF-442: Weekly Dividers (visualización)                          |
//+------------------------------------------------------------------+
string CShortTerm::GetWeeklyDividers() {
    string result = "=== WEEKLY DIVIDERS ===\n";
    result += "Week Start: " + m_utils.FormatDate(m_weekStart) + "\n";
    result += "Week End: " + m_utils.FormatDate(m_weekEnd) + "\n";
    result += "Weekly High: " + m_utils.FormatPrice(m_weeklyHigh, 5) + "\n";
    result += "Weekly Low: " + m_utils.FormatPrice(m_weeklyLow, 5) + "\n";
    result += "Range Progress: " + m_utils.FormatPercentage(m_weekRangeProgress) + "\n";
    result += "Range Complete: " + (m_isWeekRangeComplete ? "YES" : "NO") + "\n";
    return result;
}

//+------------------------------------------------------------------+
//| Reportes                                                         |
//+------------------------------------------------------------------+
string CShortTerm::GetWeeklyProfileReport() {
    string report = "=== WEEKLY PROFILE REPORT ===\n";
    report += "Profile: " + m_currentProfile.name + "\n";
    report += "Confirmed: " + (m_currentProfile.isConfirmed ? "YES" : "NO") + "\n";
    report += "High Probability: " + (m_currentProfile.isHighProbability ? "YES" : "NO") + "\n";
    report += "Expected Bias: " + m_utils.GetBiasName(m_currentProfile.expectedBias) + "\n";
    report += "Probability Score: " + DoubleToString(m_currentProfile.probabilityScore, 1) + "%\n";
    report += "---\n";
    report += "Template: " + m_currentTemplate.name + "\n";
    report += "Template Active: " + (m_currentTemplate.isActive ? "YES" : "NO") + "\n";
    report += "===============================";
    return report;
}

string CShortTerm::GetShortTermReport(string symbol) {
    string report = "=== SHORT-TERM REPORT ===\n";
    report += "Symbol: " + symbol + "\n";
    report += "Executable TF: " + EnumToString(m_executableTF) + "\n";
    report += "---\n";
    report += GetWeeklyProfileReport() + "\n";
    report += "---\n";
    report += "Weekly High: " + m_utils.FormatPrice(m_weeklyHigh, 5) + "\n";
    report += "Weekly Low: " + m_utils.FormatPrice(m_weeklyLow, 5) + "\n";
    report += "Range: " + m_utils.FormatPips((m_weeklyHigh - m_weeklyLow) / SymbolInfoDouble(symbol, SYMBOL_POINT)) + " pips\n";
    report += "Progress: " + m_utils.FormatPercentage(m_weekRangeProgress) + "\n";
    report += "---\n";
    report += "Reversal: " + (m_currentReversal.isReversal ? "DETECTED" : "NONE") + "\n";
    report += "Reversal Type: " + m_utils.GetReversalTypeName(m_currentReversal.type) + "\n";
    report += "Reversal Strength: " + DoubleToString(m_currentReversal.strength, 1) + "%\n";
    report += "---\n";
    report += "OSOK Enabled: " + (m_osokEnabled ? "YES" : "NO") + "\n";
    if(m_osokEnabled) {
        report += "OSOK High: " + m_utils.FormatPrice(m_currentProjection.highProjection, 5) + "\n";
        report += "OSOK Low: " + m_utils.FormatPrice(m_currentProjection.lowProjection, 5) + "\n";
        report += "OSOK Valid: " + (m_currentProjection.isValid ? "YES" : "NO") + "\n";
        report += "OSOK Trades This Week: " + IntegerToString(m_osokCounter) + "\n";
    }
    report += "=========================";
    return report;
}

string CShortTerm::GetOSOKReport(string symbol) {
    if(!m_osokEnabled) {
        return "OSOK not enabled";
    }
    
    string report = "=== OSOK REPORT ===\n";
    report += "Symbol: " + symbol + "\n";
    report += "Projection Method: " + (m_osokProjectionMethod == METHOD_FIB_CONVERGENCE ? "FIB_CONVERGENCE" :
                                       m_osokProjectionMethod == METHOD_PD_ARRAY_ONLY ? "PD_ARRAY_ONLY" : "BLENDED") + "\n";
    report += "---\n";
    report += "High Projection: " + m_utils.FormatPrice(m_currentProjection.highProjection, 5) + "\n";
    report += "Low Projection: " + m_utils.FormatPrice(m_currentProjection.lowProjection, 5) + "\n";
    report += "FIB 127: " + m_utils.FormatPrice(m_currentProjection.fib127, 5) + "\n";
    report += "FIB 168: " + m_utils.FormatPrice(m_currentProjection.fib168, 5) + "\n";
    report += "Converged: " + (m_currentProjection.isConverged ? "YES" : "NO") + "\n";
    report += "Tolerance: " + DoubleToString(m_osokProjectionTolerance, 1) + " pips\n";
    report += "Valid: " + (m_currentProjection.isValid ? "YES" : "NO") + "\n";
    report += "---\n";
    report += "Seasonal: " + (IsOSOKSeasonalValid(symbol) ? "✅" : "❌") + "\n";
    report += "COT: " + (IsOSOKCOTValid() ? "✅" : "❌") + "\n";
    report += "Kill Zone: " + (IsOSOKKillZoneValid() ? "✅" : "❌") + "\n";
    report += "Frequency: " + (IsOSOKFrequencyValid() ? "✅" : "❌") + " (" + IntegerToString(m_osokCounter) + "/" + IntegerToString(m_osokMaxPerWeek) + ")\n";
    report += "Qualified: " + (IsOSOKQualified(symbol) ? "✅" : "❌") + "\n";
    report += "=========================";
    return report;
}

#endif // __CSHORTTERM_MQH__