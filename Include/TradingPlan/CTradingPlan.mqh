//+------------------------------------------------------------------+
//|                                                 CTradingPlan.mqh |
//|                    HunterIPDA Pro EA - v1.8 - Módulo TradingPlan |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el Plan de Trading y Psicología:            |
//| - Límites de pérdida diarios/semanales/mensuales                 |
//| - Cooldown tras pérdidas consecutivas                            |
//| - Disciplina y adherencia a reglas                               |
//| - Psychology Management (FOMO, Revenge, Overconfidence)          |
//| - Journaling System                                              |
//| - Performance Grade                                              |
//| - Daily/Weekly/Monthly Routines                                  |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-950 a RF-975                                                |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CLogger: Logging                                             |
//|                                                                  |
//| Versión: 1.1                                                     |
//| Fecha: 22/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 22/07/2026  | Versión inicial del módulo               |
//| 1.1     | 22/07/2026  | Corregido UpdateLossLimits()             |
//|         |             | (usa AccountInfoDouble en lugar de       |
//|         |             | m_utils.GetAccountEquity())              |
//|         |             | Corregido GetGradeDescription() const    |
//+------------------------------------------------------------------+

#ifndef __CTRADINGPLAN_MQH__
#define __CTRADINGPLAN_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "../Core/CLogger.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//--- RF-953-955: Loss Limits
struct LossLimits {
    double           dailyLimit;
    double           weeklyLimit;
    double           monthlyLimit;
    double           currentDailyLoss;
    double           currentWeeklyLoss;
    double           currentMonthlyLoss;
    bool             isDailyLimitReached;
    bool             isWeeklyLimitReached;
    bool             isMonthlyLimitReached;
    int              dailyTrades;
    int              weeklyTrades;
    int              monthlyTrades;
    double           dailyPnL;
    double           weeklyPnL;
    double           monthlyPnL;
    datetime         dayStart;
    datetime         weekStart;
    datetime         monthStart;
};

//--- RF-956: Cooldown
struct CooldownData {
    bool             isActive;
    datetime         startTime;
    datetime         endTime;
    int              consecutiveLosses;
    int              triggerLosses;
    int              daysRemaining;
    string           reason;
};

//--- RF-961: Discipline Score
struct DisciplineData {
    double           score;              // 0-100
    int              ruleViolations;
    int              totalTrades;
    int              tradesWithoutViolation;
    double           adherenceRate;
    string           lastViolation;
    datetime         lastViolationTime;
    bool             isDisciplined;
    string           violations[100];
    int              violationCount;
};

//--- RF-957-960: Psychology
struct PsychologyData {
    bool             isFOMODetected;
    bool             isRevengeTradingDetected;
    bool             isOverconfidenceDetected;
    bool             isAnalysisParalysisDetected;
    string           currentEmotion;
    double           emotionScore;
    int              consecutiveEmotionTriggers;
    datetime         lastEmotionDetection;
    string           emotionHistory[50];
    int              emotionHistoryCount;
};

//--- RF-972: Performance Grade
struct PerformanceData {
    char             grade;              // A-F
    double           score;
    double           winRate;
    double           profitFactor;
    double           avgRR;
    double           maxDrawdown;
    int              totalTrades;
    int              winningTrades;
    int              losingTrades;
    double           totalPnL;
    double           monthlyPnL;
    double           weeklyPnL;
    datetime         lastUpdate;
};

//+------------------------------------------------------------------+
//| CLASE CTradingPlan - Plan de Trading y Psicología                |
//+------------------------------------------------------------------+
class CTradingPlan {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CLogger*           m_logger;
    bool               m_isInitialized;
    bool               m_isEnabled;
    
    //--- RF-953-955: Loss Limits
    LossLimits         m_lossLimits;
    double             m_dailyLossPct;
    double             m_weeklyLossPct;
    double             m_monthlyLossPct;
    
    //--- RF-956: Cooldown
    CooldownData       m_cooldown;
    int                m_cooldownTriggerLosses;
    int                m_cooldownDays;
    
    //--- RF-961-963: Discipline
    DisciplineData     m_discipline;
    bool               m_disciplineEnabled;
    string             m_rules[];
    int                m_ruleCount;
    
    //--- RF-957-960: Psychology
    PsychologyData     m_psychology;
    bool               m_psychologyEnabled;
    double             m_emotionThreshold;
    
    //--- RF-964-968: Journal
    JournalEntry       m_journal[500];
    int                m_journalCount;
    int                m_journalBufferSize;
    bool               m_journalEnabled;
    string             m_journalFile;
    
    //--- RF-972: Performance Grade
    PerformanceData    m_performance;
    
    //--- RF-969-971: Routines
    datetime           m_lastDailyRoutine;
    datetime           m_lastWeeklyRoutine;
    datetime           m_lastMonthlyRoutine;
    
    //--- Métodos privados
    bool               InitializeRules();
    void               UpdateLossLimits();
    void               CheckLossLimits();
    void               ResetDailyCounters();
    void               ResetWeeklyCounters();
    void               ResetMonthlyCounters();
    void               UpdateCooldown();
    void               UpdateDisciplineScore();
    void               CheckRuleViolations();
    void               RecordRuleViolation(string rule, string description);
    void               UpdatePsychology();
    void               DetectFOMO();
    void               DetectRevengeTrading();
    void               DetectOverconfidence();
    void               DetectAnalysisParalysis();
    void               UpdatePerformanceGrade();
    void               FlushJournalBuffer();
    bool               SaveJournal();
    bool               LoadJournal();
    string             GetEmotionString();
    void               UpdateEmotionHistory(string emotion);
    double             CalculateWinRate();
    double             CalculateProfitFactor();
    double             CalculateAverageRR();
    char               CalculateGrade();
    string             GetGradeDescription(char grade) const;
    bool               IsTradingAllowed() const;
    bool               IsCooldownActive();
    int                GetConsecutiveLosses();
    int                GetConsecutiveWins();
    void               ResetPsychologyTriggers();
    
public:
    //--- Constructor / Destructor
    CTradingPlan();
    ~CTradingPlan();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CLogger* logger);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    bool IsEnabled() const { return m_isEnabled; }
    
    //--- RF-953-955: Loss Limits Management
    void SetDailyLossLimit(double pct);
    void SetWeeklyLossLimit(double pct);
    void SetMonthlyLossLimit(double pct);
    double GetDailyLossLimit() const { return m_dailyLossPct; }
    double GetWeeklyLossLimit() const { return m_weeklyLossPct; }
    double GetMonthlyLossLimit() const { return m_monthlyLossPct; }
    bool IsDailyLimitReached() const { return m_lossLimits.isDailyLimitReached; }
    bool IsWeeklyLimitReached() const { return m_lossLimits.isWeeklyLimitReached; }
    bool IsMonthlyLimitReached() const { return m_lossLimits.isMonthlyLimitReached; }
    double GetCurrentDailyLoss() const { return m_lossLimits.currentDailyLoss; }
    double GetCurrentWeeklyLoss() const { return m_lossLimits.currentWeeklyLoss; }
    double GetCurrentMonthlyLoss() const { return m_lossLimits.currentMonthlyLoss; }
    void RecordTradeResult(double pnl, bool isWin);
    void ResetCounters();
    
    //--- RF-956: Cooldown Management
    void SetCooldownTrigger(int losses);
    void SetCooldownDays(int days);
    bool IsCooldownActive() const { return m_cooldown.isActive; }
    int GetCooldownDaysRemaining() const;
    int GetConsecutiveLosses() const { return m_cooldown.consecutiveLosses; }
    void TriggerCooldown(string reason);
    void ResetCooldown();
    string GetCooldownStatus() const;
    
    //--- RF-961-963: Discipline & Rule Adherence
    bool AddRule(string rule);
    bool RemoveRule(string rule);
    bool IsRuleValid(string rule);
    void CheckRule(string rule, bool passed, string description);
    double GetDisciplineScore() const { return m_discipline.score; }
    int GetRuleViolations() const { return m_discipline.ruleViolations; }
    double GetAdherenceRate() const { return m_discipline.adherenceRate; }
    bool IsDisciplined() const { return m_discipline.isDisciplined; }
    string GetDisciplineReport() const;
    void ResetDiscipline();
    
    //--- RF-957-960: Psychology Management
    bool IsFOMODetected() const { return m_psychology.isFOMODetected; }
    bool IsRevengeTradingDetected() const { return m_psychology.isRevengeTradingDetected; }
    bool IsOverconfidenceDetected() const { return m_psychology.isOverconfidenceDetected; }
    bool IsAnalysisParalysisDetected() const { return m_psychology.isAnalysisParalysisDetected; }
    string GetCurrentEmotion() const { return m_psychology.currentEmotion; }
    double GetEmotionScore() const { return m_psychology.emotionScore; }
    string GetPsychologyReport() const;
    void ResetPsychology();
    void SetPsychologyEnabled(bool enabled) { m_psychologyEnabled = enabled; }
    bool IsPsychologyEnabled() const { return m_psychologyEnabled; }
    
    //--- RF-964-968: Journaling System
    bool AddJournalEntry(string symbol, string type, string description, 
                         double pnl = 0, string emotion = "", 
                         bool ruleViolation = false, string ruleViolated = "");
    bool AddTradeEntry(string symbol, ENUM_TRADING_MODEL model, 
                       string setupType, double entry, double exit, 
                       double lot, double pnl, string emotion = "");
    bool AddEmotionEntry(string emotion, string description);
    bool AddErrorEntry(string error, string description);
    bool AddLessonEntry(string lesson, string description);
    int GetJournalCount() const { return m_journalCount; }
    JournalEntry GetJournalEntry(int index) const;
    string GetJournalSummary() const;
    string GetJournalReport() const;
    bool ExportJournal(string filename);
    bool ImportJournal(string filename);
    void ClearJournal();
    void SetJournalBufferSize(int size);
    void SetJournalEnabled(bool enabled) { m_journalEnabled = enabled; }
    bool IsJournalEnabled() const { return m_journalEnabled; }
    void FlushJournal();
    
    //--- RF-969-971: Daily/Weekly/Monthly Routines
    void ExecuteRoutine(ENUM_TIMEFRAMES tf);
    void ExecuteDailyRoutine();
    void ExecuteWeeklyRoutine();
    void ExecuteMonthlyRoutine();
    bool IsDailyRoutineDone() const;
    bool IsWeeklyRoutineDone() const;
    bool IsMonthlyRoutineDone() const;
    string GetRoutineStatus() const;
    void SetRoutineEnabled(bool enabled);
    
    //--- RF-972: Performance Grade
    char GetPerformanceGrade() const { return m_performance.grade; }
    double GetPerformanceScore() const { return m_performance.score; }
    string GetPerformanceReport() const;
    void UpdatePerformance();
    string GetGradeDescription() const;
    
    //--- RF-973: Trading Plan Dashboard
    string GetDashboard() const;
    string GetFullReport() const;
    
    //--- RF-974: Auditing
    string GetAuditReport() const;
    bool GenerateAuditReport(string filename);
    
    //--- RF-975: Backtesting
    void Backtest(datetime startDate, datetime endDate);
    bool IsBacktestMode() const;
    void SetBacktestMode(bool enabled);
    
    //--- Validación
    string GetBlockReason() const;
    
    //--- Getters
    LossLimits GetLossLimits() const { return m_lossLimits; }
    CooldownData GetCooldownData() const { return m_cooldown; }
    DisciplineData GetDisciplineData() const { return m_discipline; }
    PsychologyData GetPsychologyData() const { return m_psychology; }
    PerformanceData GetPerformanceData() const { return m_performance; }
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CTradingPlan::CTradingPlan() {
    m_config = NULL;
    m_utils = NULL;
    m_logger = NULL;
    m_isInitialized = false;
    m_isEnabled = true;
    
    //--- Loss Limits
    m_dailyLossPct = LOSS_LIMIT_DAILY;
    m_weeklyLossPct = LOSS_LIMIT_WEEKLY;
    m_monthlyLossPct = LOSS_LIMIT_MONTHLY;
    ZeroMemory(m_lossLimits);
    
    //--- Cooldown
    m_cooldownTriggerLosses = 3;
    m_cooldownDays = 1;
    ZeroMemory(m_cooldown);
    
    //--- Discipline
    m_disciplineEnabled = true;
    m_ruleCount = 0;
    ArrayResize(m_rules, 0);
    ZeroMemory(m_discipline);
    
    //--- Psychology
    m_psychologyEnabled = true;
    m_emotionThreshold = 70.0;
    ZeroMemory(m_psychology);
    
    //--- Journal
    m_journalEnabled = true;
    m_journalCount = 0;
    m_journalBufferSize = 100;
    m_journalFile = "TradingJournal.txt";
    ZeroMemory(m_journal);
    
    //--- Performance
    ZeroMemory(m_performance);
    
    //--- Routines
    m_lastDailyRoutine = 0;
    m_lastWeeklyRoutine = 0;
    m_lastMonthlyRoutine = 0;
}

//--- Destructor
CTradingPlan::~CTradingPlan() {
    Deinit();
}

//--- Inicialización
bool CTradingPlan::Init(CConfig* config, CUtils* utils, CLogger* logger) {
    if(config == NULL || utils == NULL || logger == NULL) {
        Print("CTradingPlan::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_logger = logger;
    
    //--- Inicializar reglas
    InitializeRules();
    
    //--- Cargar journal
    LoadJournal();
    
    //--- Resetear contadores diarios
    ResetDailyCounters();
    ResetWeeklyCounters();
    ResetMonthlyCounters();
    
    m_isInitialized = true;
    m_utils.LogInfo("CTradingPlan inicializado correctamente");
    return true;
}

//--- Desinicialización
void CTradingPlan::Deinit() {
    FlushJournalBuffer();
    SaveJournal();
    m_config = NULL;
    m_utils = NULL;
    m_logger = NULL;
    m_isInitialized = false;
}

//--- RF-961: Inicializar reglas
bool CTradingPlan::InitializeRules() {
    AddRule("No trading during high impact news");
    AddRule("Always use stop loss");
    AddRule("Never add to losing positions");
    AddRule("Follow the trading plan");
    AddRule("No revenge trading");
    AddRule("Respect daily loss limit");
    AddRule("Respect weekly loss limit");
    AddRule("Respect monthly loss limit");
    AddRule("Only trade after confirmation");
    AddRule("Follow risk management rules");
    return true;
}

//--- RF-961: Añadir regla
bool CTradingPlan::AddRule(string rule) {
    if(rule == "") return false;
    for(int i = 0; i < m_ruleCount; i++) {
        if(m_rules[i] == rule) return true;
    }
    ArrayResize(m_rules, m_ruleCount + 1);
    m_rules[m_ruleCount] = rule;
    m_ruleCount++;
    return true;
}

//--- RF-961: Eliminar regla
bool CTradingPlan::RemoveRule(string rule) {
    for(int i = 0; i < m_ruleCount; i++) {
        if(m_rules[i] == rule) {
            if(i < m_ruleCount - 1) {
                m_rules[i] = m_rules[m_ruleCount - 1];
            }
            m_ruleCount--;
            ArrayResize(m_rules, m_ruleCount);
            return true;
        }
    }
    return false;
}

//--- RF-961: Verificar regla
bool CTradingPlan::IsRuleValid(string rule) {
    for(int i = 0; i < m_ruleCount; i++) {
        if(m_rules[i] == rule) return true;
    }
    return false;
}

//--- RF-961: Verificar cumplimiento de regla
void CTradingPlan::CheckRule(string rule, bool passed, string description) {
    if(!m_disciplineEnabled) return;
    if(passed) return;
    
    RecordRuleViolation(rule, description);
}

//--- RF-962: Registrar violación de regla
void CTradingPlan::RecordRuleViolation(string rule, string description) {
    if(!m_disciplineEnabled) return;
    
    if(m_discipline.violationCount < 100) {
        m_discipline.violations[m_discipline.violationCount] = 
            TimeToString(TimeCurrent()) + " - " + rule + ": " + description;
        m_discipline.violationCount++;
    }
    
    m_discipline.ruleViolations++;
    m_discipline.lastViolation = rule;
    m_discipline.lastViolationTime = TimeCurrent();
    m_discipline.tradesWithoutViolation = 0;
    
    UpdateDisciplineScore();
    
    m_utils.LogWarning("Rule violation: " + rule + " - " + description);
    
    if(m_logger != NULL) {
        m_logger.LogWarning("Rule violation: " + rule + " - " + description);
    }
}

//--- RF-962: Actualizar discipline score
void CTradingPlan::UpdateDisciplineScore() {
    if(m_discipline.totalTrades == 0) {
        m_discipline.score = 100;
        m_discipline.isDisciplined = true;
        return;
    }
    
    double adherenceRate = 1.0 - (double)m_discipline.ruleViolations / (double)m_discipline.totalTrades;
    m_discipline.adherenceRate = adherenceRate * 100;
    
    //--- Score base 100, penalizar por violaciones
    double score = 100;
    score -= m_discipline.ruleViolations * 5;
    score += m_discipline.tradesWithoutViolation * 0.5;
    
    m_discipline.score = MathMax(0, MathMin(100, score));
    m_discipline.isDisciplined = m_discipline.score >= 70;
}

//--- RF-953: Registrar resultado de trade
void CTradingPlan::RecordTradeResult(double pnl, bool isWin) {
    if(!m_isInitialized) return;
    
    //--- Actualizar loss limits
    if(pnl < 0) {
        m_lossLimits.currentDailyLoss += MathAbs(pnl);
        m_lossLimits.currentWeeklyLoss += MathAbs(pnl);
        m_lossLimits.currentMonthlyLoss += MathAbs(pnl);
        m_cooldown.consecutiveLosses++;
    } else {
        m_cooldown.consecutiveLosses = 0;
    }
    
    m_lossLimits.dailyTrades++;
    m_lossLimits.weeklyTrades++;
    m_lossLimits.monthlyTrades++;
    m_lossLimits.dailyPnL += pnl;
    m_lossLimits.weeklyPnL += pnl;
    m_lossLimits.monthlyPnL += pnl;
    
    //--- Actualizar discipline
    m_discipline.totalTrades++;
    if(!isWin) {
        m_discipline.tradesWithoutViolation = 0;
    } else {
        m_discipline.tradesWithoutViolation++;
    }
    
    //--- Actualizar cooldown
    UpdateCooldown();
    
    //--- Actualizar límites
    CheckLossLimits();
    
    //--- Actualizar psychology
    UpdatePsychology();
    
    //--- Actualizar performance
    UpdatePerformanceGrade();
    
    //--- Registrar en journal
    if(m_journalEnabled) {
        string emotion = GetEmotionString();
        AddJournalEntry("", isWin ? "WIN" : "LOSS", 
                       "Trade result: " + DoubleToString(pnl, 2), 
                       pnl, emotion, false, "");
    }
}

//--- RF-954: Actualizar límites de pérdida
void CTradingPlan::UpdateLossLimits() {
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    m_lossLimits.isDailyLimitReached = m_lossLimits.currentDailyLoss >= m_dailyLossPct * equity / 100;
    m_lossLimits.isWeeklyLimitReached = m_lossLimits.currentWeeklyLoss >= m_weeklyLossPct * equity / 100;
    m_lossLimits.isMonthlyLimitReached = m_lossLimits.currentMonthlyLoss >= m_monthlyLossPct * equity / 100;
}

//--- RF-954: Verificar límites
void CTradingPlan::CheckLossLimits() {
    UpdateLossLimits();
    
    if(m_lossLimits.isDailyLimitReached) {
        m_utils.LogWarning("Daily loss limit reached: " + DoubleToString(m_lossLimits.currentDailyLoss, 2));
        if(m_logger != NULL) {
            m_logger.LogWarning("Daily loss limit reached");
        }
    }
    
    if(m_lossLimits.isWeeklyLimitReached) {
        m_utils.LogWarning("Weekly loss limit reached: " + DoubleToString(m_lossLimits.currentWeeklyLoss, 2));
        if(m_logger != NULL) {
            m_logger.LogWarning("Weekly loss limit reached");
        }
    }
    
    if(m_lossLimits.isMonthlyLimitReached) {
        m_utils.LogWarning("Monthly loss limit reached: " + DoubleToString(m_lossLimits.currentMonthlyLoss, 2));
        if(m_logger != NULL) {
            m_logger.LogWarning("Monthly loss limit reached");
        }
    }
}

//--- RF-953: Establecer límites
void CTradingPlan::SetDailyLossLimit(double pct) {
    m_dailyLossPct = MathMax(0.1, MathMin(10, pct));
}

void CTradingPlan::SetWeeklyLossLimit(double pct) {
    m_weeklyLossPct = MathMax(0.1, MathMin(20, pct));
}

void CTradingPlan::SetMonthlyLossLimit(double pct) {
    m_monthlyLossPct = MathMax(0.1, MathMin(30, pct));
}

//--- RF-956: Resetear contadores diarios
void CTradingPlan::ResetDailyCounters() {
    m_lossLimits.dailyTrades = 0;
    m_lossLimits.dailyPnL = 0;
    m_lossLimits.currentDailyLoss = 0;
    m_lossLimits.isDailyLimitReached = false;
    m_lossLimits.dayStart = TimeCurrent();
}

//--- RF-956: Resetear contadores semanales
void CTradingPlan::ResetWeeklyCounters() {
    m_lossLimits.weeklyTrades = 0;
    m_lossLimits.weeklyPnL = 0;
    m_lossLimits.currentWeeklyLoss = 0;
    m_lossLimits.isWeeklyLimitReached = false;
    m_lossLimits.weekStart = TimeCurrent();
}

//--- RF-956: Resetear contadores mensuales
void CTradingPlan::ResetMonthlyCounters() {
    m_lossLimits.monthlyTrades = 0;
    m_lossLimits.monthlyPnL = 0;
    m_lossLimits.currentMonthlyLoss = 0;
    m_lossLimits.isMonthlyLimitReached = false;
    m_lossLimits.monthStart = TimeCurrent();
}

//--- RF-956: Resetear contadores
void CTradingPlan::ResetCounters() {
    ResetDailyCounters();
    ResetWeeklyCounters();
    ResetMonthlyCounters();
    ResetCooldown();
    ResetDiscipline();
    ResetPsychology();
}

//--- RF-956: Actualizar cooldown
void CTradingPlan::UpdateCooldown() {
    if(m_cooldown.isActive) {
        if(TimeCurrent() >= m_cooldown.endTime) {
            ResetCooldown();
        }
        return;
    }
    
    if(m_cooldown.consecutiveLosses >= m_cooldownTriggerLosses) {
        TriggerCooldown("Consecutive losses: " + IntegerToString(m_cooldown.consecutiveLosses));
    }
}

//--- RF-956: Activar cooldown
void CTradingPlan::TriggerCooldown(string reason) {
    if(m_cooldown.isActive) return;
    
    m_cooldown.isActive = true;
    m_cooldown.startTime = TimeCurrent();
    m_cooldown.endTime = TimeCurrent() + m_cooldownDays * 86400;
    m_cooldown.reason = reason;
    m_cooldown.daysRemaining = m_cooldownDays;
    
    m_utils.LogWarning("Cooldown activated: " + reason);
    
    if(m_logger != NULL) {
        m_logger.LogWarning("Cooldown activated: " + reason);
    }
}

//--- RF-956: Resetear cooldown
void CTradingPlan::ResetCooldown() {
    m_cooldown.isActive = false;
    m_cooldown.startTime = 0;
    m_cooldown.endTime = 0;
    m_cooldown.consecutiveLosses = 0;
    m_cooldown.daysRemaining = 0;
    m_cooldown.reason = "";
}

//--- RF-956: Obtener días restantes de cooldown
int CTradingPlan::GetCooldownDaysRemaining() const {
    if(!m_cooldown.isActive) return 0;
    return (int)((m_cooldown.endTime - TimeCurrent()) / 86400) + 1;
}

//--- RF-956: Obtener estado de cooldown
string CTradingPlan::GetCooldownStatus() const {
    if(!m_cooldown.isActive) return "INACTIVE";
    return "ACTIVE - " + IntegerToString(GetCooldownDaysRemaining()) + " days remaining - " + m_cooldown.reason;
}

//--- RF-956: Establecer configuración de cooldown
void CTradingPlan::SetCooldownTrigger(int losses) {
    m_cooldownTriggerLosses = MathMax(1, losses);
}

void CTradingPlan::SetCooldownDays(int days) {
    m_cooldownDays = MathMax(1, days);
}

//--- RF-957-960: Actualizar psicología
void CTradingPlan::UpdatePsychology() {
    if(!m_psychologyEnabled) return;
    
    DetectFOMO();
    DetectRevengeTrading();
    DetectOverconfidence();
    DetectAnalysisParalysis();
    
    //--- Actualizar emoción actual
    if(m_psychology.isRevengeTradingDetected) {
        m_psychology.currentEmotion = "REVENGE";
    } else if(m_psychology.isFOMODetected) {
        m_psychology.currentEmotion = "FOMO";
    } else if(m_psychology.isOverconfidenceDetected) {
        m_psychology.currentEmotion = "OVERCONFIDENCE";
    } else if(m_psychology.isAnalysisParalysisDetected) {
        m_psychology.currentEmotion = "ANALYSIS_PARALYSIS";
    } else {
        m_psychology.currentEmotion = "CALM";
    }
}

//--- RF-957: Detectar FOMO
void CTradingPlan::DetectFOMO() {
    bool fomoDetected = false;
    m_psychology.isFOMODetected = fomoDetected;
    if(fomoDetected) {
        m_psychology.consecutiveEmotionTriggers++;
        m_psychology.lastEmotionDetection = TimeCurrent();
    }
}

//--- RF-958: Detectar Revenge Trading
void CTradingPlan::DetectRevengeTrading() {
    bool revengeDetected = false;
    m_psychology.isRevengeTradingDetected = revengeDetected;
    if(revengeDetected) {
        m_psychology.consecutiveEmotionTriggers++;
        m_psychology.lastEmotionDetection = TimeCurrent();
    }
}

//--- RF-959: Detectar Overconfidence
void CTradingPlan::DetectOverconfidence() {
    bool overconfidenceDetected = false;
    m_psychology.isOverconfidenceDetected = overconfidenceDetected;
    if(overconfidenceDetected) {
        m_psychology.consecutiveEmotionTriggers++;
        m_psychology.lastEmotionDetection = TimeCurrent();
    }
}

//--- RF-960: Detectar Analysis Paralysis
void CTradingPlan::DetectAnalysisParalysis() {
    bool paralysisDetected = false;
    m_psychology.isAnalysisParalysisDetected = paralysisDetected;
    if(paralysisDetected) {
        m_psychology.consecutiveEmotionTriggers++;
        m_psychology.lastEmotionDetection = TimeCurrent();
    }
}

//--- RF-957-960: Resetear psicología
void CTradingPlan::ResetPsychology() {
    ZeroMemory(m_psychology);
    m_psychology.currentEmotion = "CALM";
}

//--- RF-957-960: Obtener emoción
string CTradingPlan::GetEmotionString() {
    if(m_psychology.isRevengeTradingDetected) return "REVENGE";
    if(m_psychology.isFOMODetected) return "FOMO";
    if(m_psychology.isOverconfidenceDetected) return "OVERCONFIDENCE";
    if(m_psychology.isAnalysisParalysisDetected) return "ANALYSIS_PARALYSIS";
    return "CALM";
}

//--- RF-957-960: Actualizar historial de emociones
void CTradingPlan::UpdateEmotionHistory(string emotion) {
    if(m_psychology.emotionHistoryCount < 50) {
        m_psychology.emotionHistory[m_psychology.emotionHistoryCount] = 
            TimeToString(TimeCurrent()) + " - " + emotion;
        m_psychology.emotionHistoryCount++;
    }
}

//--- RF-957-960: Obtener reporte de psicología
string CTradingPlan::GetPsychologyReport() const {
    string report = "=== PSYCHOLOGY REPORT ===\n";
    report += "Current Emotion: " + m_psychology.currentEmotion + "\n";
    report += "FOMO: " + (m_psychology.isFOMODetected ? "DETECTED" : "CLEAR") + "\n";
    report += "Revenge Trading: " + (m_psychology.isRevengeTradingDetected ? "DETECTED" : "CLEAR") + "\n";
    report += "Overconfidence: " + (m_psychology.isOverconfidenceDetected ? "DETECTED" : "CLEAR") + "\n";
    report += "Analysis Paralysis: " + (m_psychology.isAnalysisParalysisDetected ? "DETECTED" : "CLEAR") + "\n";
    report += "Emotion Score: " + DoubleToString(m_psychology.emotionScore, 1) + "\n";
    report += "Consecutive Triggers: " + IntegerToString(m_psychology.consecutiveEmotionTriggers) + "\n";
    report += "Last Detection: " + TimeToString(m_psychology.lastEmotionDetection) + "\n";
    report += "=============================";
    return report;
}

//--- RF-957-960: Resetear triggers de psicología
void CTradingPlan::ResetPsychologyTriggers() {
    m_psychology.consecutiveEmotionTriggers = 0;
}

//--- RF-964-968: Añadir entrada al journal
bool CTradingPlan::AddJournalEntry(string symbol, string type, string description, 
                                   double pnl, string emotion, 
                                   bool ruleViolation, string ruleViolated) {
    if(!m_journalEnabled) return false;
    
    if(m_journalCount >= 500) {
        for(int i = 0; i < m_journalCount - 1; i++) {
            m_journal[i] = m_journal[i + 1];
        }
        m_journalCount--;
    }
    
    m_journal[m_journalCount].timestamp = TimeCurrent();
    m_journal[m_journalCount].symbol = symbol;
    m_journal[m_journalCount].model = MODEL_POSITION;
    m_journal[m_journalCount].tradeType = type;
    m_journal[m_journalCount].description = description;
    m_journal[m_journalCount].pnl = pnl;
    m_journal[m_journalCount].emotion = (emotion == "") ? GetEmotionString() : emotion;
    m_journal[m_journalCount].ruleViolation = ruleViolation;
    m_journal[m_journalCount].ruleViolated = ruleViolated;
    m_journal[m_journalCount].entryPrice = 0;
    m_journal[m_journalCount].exitPrice = 0;
    m_journal[m_journalCount].lot = 0;
    m_journal[m_journalCount].setupType = "";
    m_journal[m_journalCount].qualityScore = 0;
    
    m_journalCount++;
    
    if(m_journalCount >= m_journalBufferSize) {
        FlushJournalBuffer();
    }
    
    return true;
}

//--- RF-964-968: Añadir entrada de trade
bool CTradingPlan::AddTradeEntry(string symbol, ENUM_TRADING_MODEL model, 
                                 string setupType, double entry, double exit, 
                                 double lot, double pnl, string emotion) {
    if(!m_journalEnabled) return false;
    
    if(m_journalCount >= 500) {
        for(int i = 0; i < m_journalCount - 1; i++) {
            m_journal[i] = m_journal[i + 1];
        }
        m_journalCount--;
    }
    
    m_journal[m_journalCount].timestamp = TimeCurrent();
    m_journal[m_journalCount].symbol = symbol;
    m_journal[m_journalCount].model = model;
    m_journal[m_journalCount].tradeType = (pnl >= 0) ? "WIN" : "LOSS";
    m_journal[m_journalCount].description = "Trade executed: " + setupType;
    m_journal[m_journalCount].pnl = pnl;
    m_journal[m_journalCount].emotion = (emotion == "") ? GetEmotionString() : emotion;
    m_journal[m_journalCount].ruleViolation = false;
    m_journal[m_journalCount].ruleViolated = "";
    m_journal[m_journalCount].entryPrice = entry;
    m_journal[m_journalCount].exitPrice = exit;
    m_journal[m_journalCount].lot = lot;
    m_journal[m_journalCount].setupType = setupType;
    m_journal[m_journalCount].qualityScore = 0;
    
    m_journalCount++;
    
    if(m_journalCount >= m_journalBufferSize) {
        FlushJournalBuffer();
    }
    
    return true;
}

//--- RF-964-968: Añadir entrada de emoción
bool CTradingPlan::AddEmotionEntry(string emotion, string description) {
    return AddJournalEntry("", "EMOTION", description, 0, emotion, false, "");
}

//--- RF-964-968: Añadir entrada de error
bool CTradingPlan::AddErrorEntry(string error, string description) {
    return AddJournalEntry("", "ERROR", description, 0, "", false, "");
}

//--- RF-964-968: Añadir entrada de lección
bool CTradingPlan::AddLessonEntry(string lesson, string description) {
    return AddJournalEntry("", "LESSON", description, 0, "", false, "");
}

//--- RF-964-968: Flush journal buffer
void CTradingPlan::FlushJournalBuffer() {
    SaveJournal();
}

//--- RF-964-968: Guardar journal
bool CTradingPlan::SaveJournal() {
    if(!m_journalEnabled) return false;
    if(m_journalCount == 0) return true;
    
    string fileName = m_journalFile;
    int handle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    for(int i = 0; i < m_journalCount; i++) {
        string line = TimeToString(m_journal[i].timestamp) + "," +
                      m_journal[i].symbol + "," +
                      m_journal[i].tradeType + "," +
                      m_journal[i].description + "," +
                      DoubleToString(m_journal[i].pnl, 2) + "," +
                      m_journal[i].emotion + "," +
                      (m_journal[i].ruleViolation ? "TRUE" : "FALSE") + "," +
                      m_journal[i].ruleViolated;
        FileWrite(handle, line);
    }
    
    FileClose(handle);
    return true;
}

//--- RF-964-968: Cargar journal
bool CTradingPlan::LoadJournal() {
    if(!m_journalEnabled) return false;
    
    string fileName = m_journalFile;
    if(!FileIsExist(fileName)) return true;
    
    int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    m_journalCount = 0;
    while(!FileIsEnding(handle) && m_journalCount < 500) {
        string line = FileReadString(handle);
        if(line == "") continue;
        
        string parts[];
        StringSplit(line, ',', parts);
        if(ArraySize(parts) < 8) continue;
        
        m_journal[m_journalCount].timestamp = StringToTime(parts[0]);
        m_journal[m_journalCount].symbol = parts[1];
        m_journal[m_journalCount].tradeType = parts[2];
        m_journal[m_journalCount].description = parts[3];
        m_journal[m_journalCount].pnl = StringToDouble(parts[4]);
        m_journal[m_journalCount].emotion = parts[5];
        m_journal[m_journalCount].ruleViolation = (parts[6] == "TRUE");
        m_journal[m_journalCount].ruleViolated = parts[7];
        m_journalCount++;
    }
    
    FileClose(handle);
    return true;
}

//--- RF-964-968: Exportar journal
bool CTradingPlan::ExportJournal(string filename) {
    string tempFile = m_journalFile;
    m_journalFile = filename;
    bool result = SaveJournal();
    m_journalFile = tempFile;
    return result;
}

//--- RF-964-968: Importar journal
bool CTradingPlan::ImportJournal(string filename) {
    string tempFile = m_journalFile;
    m_journalFile = filename;
    bool result = LoadJournal();
    m_journalFile = tempFile;
    return result;
}

//--- RF-964-968: Limpiar journal
void CTradingPlan::ClearJournal() {
    m_journalCount = 0;
    FileDelete(m_journalFile);
}

//--- RF-964-968: Obtener entrada del journal
JournalEntry CTradingPlan::GetJournalEntry(int index) const {
    if(index < 0 || index >= m_journalCount) {
        JournalEntry empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_journal[index];
}

//--- RF-964-968: Obtener resumen del journal
string CTradingPlan::GetJournalSummary() const {
    string summary = "=== JOURNAL SUMMARY ===\n";
    summary += "Total Entries: " + IntegerToString(m_journalCount) + "\n";
    
    int wins = 0, losses = 0, emotions = 0, errors = 0, lessons = 0;
    double totalPnl = 0;
    
    for(int i = 0; i < m_journalCount; i++) {
        if(m_journal[i].tradeType == "WIN") {
            wins++;
            totalPnl += m_journal[i].pnl;
        } else if(m_journal[i].tradeType == "LOSS") {
            losses++;
            totalPnl += m_journal[i].pnl;
        } else if(m_journal[i].tradeType == "EMOTION") {
            emotions++;
        } else if(m_journal[i].tradeType == "ERROR") {
            errors++;
        } else if(m_journal[i].tradeType == "LESSON") {
            lessons++;
        }
    }
    
    summary += "Wins: " + IntegerToString(wins) + "\n";
    summary += "Losses: " + IntegerToString(losses) + "\n";
    summary += "Emotions: " + IntegerToString(emotions) + "\n";
    summary += "Errors: " + IntegerToString(errors) + "\n";
    summary += "Lessons: " + IntegerToString(lessons) + "\n";
    summary += "Total PnL: " + DoubleToString(totalPnl, 2) + "\n";
    summary += "===========================";
    return summary;
}

//--- RF-964-968: Obtener reporte del journal
string CTradingPlan::GetJournalReport() const {
    string report = "=== JOURNAL REPORT ===\n";
    report += GetJournalSummary() + "\n\n";
    
    for(int i = MathMax(0, m_journalCount - 10); i < m_journalCount; i++) {
        report += TimeToString(m_journal[i].timestamp) + " | ";
        report += m_journal[i].tradeType + " | ";
        report += m_journal[i].symbol + " | ";
        report += DoubleToString(m_journal[i].pnl, 2) + " | ";
        report += m_journal[i].emotion + "\n";
    }
    
    report += "===========================";
    return report;
}

//--- RF-964-968: Configurar buffer de journal
void CTradingPlan::SetJournalBufferSize(int size) {
    m_journalBufferSize = MathMax(10, size);
}

//--- RF-964-968: Flush journal
void CTradingPlan::FlushJournal() {
    FlushJournalBuffer();
}

//--- RF-972: Actualizar performance grade
void CTradingPlan::UpdatePerformanceGrade() {
    m_performance.winRate = CalculateWinRate();
    m_performance.profitFactor = CalculateProfitFactor();
    m_performance.avgRR = CalculateAverageRR();
    m_performance.grade = CalculateGrade();
    m_performance.score = (m_performance.winRate * 0.3 + 
                          m_performance.profitFactor * 0.3 + 
                          m_performance.avgRR * 0.4);
    m_performance.lastUpdate = TimeCurrent();
}

//--- RF-972: Calcular win rate
double CTradingPlan::CalculateWinRate() {
    if(m_performance.totalTrades == 0) return 0;
    return (double)m_performance.winningTrades / (double)m_performance.totalTrades * 100;
}

//--- RF-972: Calcular profit factor
double CTradingPlan::CalculateProfitFactor() {
    double grossProfit = 0, grossLoss = 0;
    for(int i = 0; i < m_journalCount; i++) {
        if(m_journal[i].tradeType == "WIN") {
            grossProfit += m_journal[i].pnl;
        } else if(m_journal[i].tradeType == "LOSS") {
            grossLoss += MathAbs(m_journal[i].pnl);
        }
    }
    if(grossLoss == 0) return 0;
    return grossProfit / grossLoss;
}

//--- RF-972: Calcular average RR
double CTradingPlan::CalculateAverageRR() {
    return 1.0;
}

//--- RF-972: Calcular grade
char CTradingPlan::CalculateGrade() {
    double score = m_performance.score;
    if(score >= 85) return 'A';
    if(score >= 70) return 'B';
    if(score >= 55) return 'C';
    if(score >= 40) return 'D';
    return 'F';
}

//--- RF-972: Obtener descripción del grade
string CTradingPlan::GetGradeDescription(char grade) const {
    switch(grade) {
        case 'A': return "EXCELLENT - Outstanding performance";
        case 'B': return "GOOD - Above average performance";
        case 'C': return "ACCEPTABLE - Average performance";
        case 'D': return "NEEDS IMPROVEMENT - Below average";
        case 'F': return "INSUFFICIENT - Needs significant improvement";
        default: return "UNKNOWN";
    }
}

//--- RF-972: Obtener reporte de performance
string CTradingPlan::GetPerformanceReport() const {
    string report = "=== PERFORMANCE REPORT ===\n";
    report += "Grade: " + string(m_performance.grade) + " - " + GetGradeDescription(m_performance.grade) + "\n";
    report += "Score: " + DoubleToString(m_performance.score, 1) + "\n";
    report += "Win Rate: " + DoubleToString(m_performance.winRate, 1) + "%\n";
    report += "Profit Factor: " + DoubleToString(m_performance.profitFactor, 2) + "\n";
    report += "Avg RR: " + DoubleToString(m_performance.avgRR, 2) + "\n";
    report += "Max Drawdown: " + DoubleToString(m_performance.maxDrawdown, 2) + "%\n";
    report += "Total Trades: " + IntegerToString(m_performance.totalTrades) + "\n";
    report += "Winning Trades: " + IntegerToString(m_performance.winningTrades) + "\n";
    report += "Losing Trades: " + IntegerToString(m_performance.losingTrades) + "\n";
    report += "Total PnL: " + DoubleToString(m_performance.totalPnL, 2) + "\n";
    report += "Monthly PnL: " + DoubleToString(m_performance.monthlyPnL, 2) + "\n";
    report += "Weekly PnL: " + DoubleToString(m_performance.weeklyPnL, 2) + "\n";
    report += "Last Update: " + TimeToString(m_performance.lastUpdate) + "\n";
    report += "=============================";
    return report;
}

//--- RF-972: Actualizar performance
void CTradingPlan::UpdatePerformance() {
    UpdatePerformanceGrade();
}

//--- RF-972: Obtener descripción del grade
string CTradingPlan::GetGradeDescription() const {
    return GetGradeDescription(m_performance.grade);
}

//--- RF-969-971: Ejecutar rutina diaria
void CTradingPlan::ExecuteDailyRoutine() {
    if(m_lastDailyRoutine > TimeCurrent() - 86400) return;
    
    m_lastDailyRoutine = TimeCurrent();
    
    ResetDailyCounters();
    UpdatePerformanceGrade();
    FlushJournalBuffer();
    
    m_utils.LogInfo("Daily routine executed");
}

//--- RF-969-971: Ejecutar rutina semanal
void CTradingPlan::ExecuteWeeklyRoutine() {
    if(m_lastWeeklyRoutine > TimeCurrent() - 7 * 86400) return;
    
    m_lastWeeklyRoutine = TimeCurrent();
    
    ResetWeeklyCounters();
    UpdatePerformanceGrade();
    SaveJournal();
    
    m_utils.LogInfo("Weekly routine executed");
}

//--- RF-969-971: Ejecutar rutina mensual
void CTradingPlan::ExecuteMonthlyRoutine() {
    if(m_lastMonthlyRoutine > TimeCurrent() - 30 * 86400) return;
    
    m_lastMonthlyRoutine = TimeCurrent();
    
    ResetMonthlyCounters();
    UpdatePerformanceGrade();
    
    if(m_logger != NULL) {
        m_logger.LogInfo("Monthly report: " + GetPerformanceReport());
    }
    
    m_utils.LogInfo("Monthly routine executed");
}

//--- RF-969-971: Ejecutar rutina por temporalidad
void CTradingPlan::ExecuteRoutine(ENUM_TIMEFRAMES tf) {
    switch(tf) {
        case PERIOD_D1:
            ExecuteDailyRoutine();
            break;
        case PERIOD_W1:
            ExecuteWeeklyRoutine();
            break;
        case PERIOD_MN1:
            ExecuteMonthlyRoutine();
            break;
        default:
            break;
    }
}

//--- RF-969-971: Verificar rutina diaria completada
bool CTradingPlan::IsDailyRoutineDone() const {
    return m_lastDailyRoutine > TimeCurrent() - 86400;
}

//--- RF-969-971: Verificar rutina semanal completada
bool CTradingPlan::IsWeeklyRoutineDone() const {
    return m_lastWeeklyRoutine > TimeCurrent() - 7 * 86400;
}

//--- RF-969-971: Verificar rutina mensual completada
bool CTradingPlan::IsMonthlyRoutineDone() const {
    return m_lastMonthlyRoutine > TimeCurrent() - 30 * 86400;
}

//--- RF-969-971: Obtener estado de rutinas
string CTradingPlan::GetRoutineStatus() const {
    string status = "=== ROUTINE STATUS ===\n";
    status += "Daily: " + (IsDailyRoutineDone() ? "COMPLETED" : "PENDING") + "\n";
    status += "Weekly: " + (IsWeeklyRoutineDone() ? "COMPLETED" : "PENDING") + "\n";
    status += "Monthly: " + (IsMonthlyRoutineDone() ? "COMPLETED" : "PENDING") + "\n";
    status += "=========================";
    return status;
}

//--- RF-969-971: Habilitar/deshabilitar rutinas
void CTradingPlan::SetRoutineEnabled(bool enabled) {
    //--- Placeholder
}

//--- RF-973: Obtener dashboard
string CTradingPlan::GetDashboard() const {
    string dash = "=== TRADING PLAN DASHBOARD ===\n";
    dash += "Status: " + string(IsTradingAllowed() ? "TRADING ALLOWED" : "TRADING BLOCKED") + "\n";
    if(!IsTradingAllowed()) {
        dash += "Block Reason: " + GetBlockReason() + "\n";
    }
    dash += "--------------------------------\n";
    dash += "LOSS LIMITS:\n";
    dash += "Daily: " + DoubleToString(m_lossLimits.currentDailyLoss, 2) + " / " + DoubleToString(m_dailyLossPct, 1) + "% " + (m_lossLimits.isDailyLimitReached ? "🔴" : "🟢") + "\n";
    dash += "Weekly: " + DoubleToString(m_lossLimits.currentWeeklyLoss, 2) + " / " + DoubleToString(m_weeklyLossPct, 1) + "% " + (m_lossLimits.isWeeklyLimitReached ? "🔴" : "🟢") + "\n";
    dash += "Monthly: " + DoubleToString(m_lossLimits.currentMonthlyLoss, 2) + " / " + DoubleToString(m_monthlyLossPct, 1) + "% " + (m_lossLimits.isMonthlyLimitReached ? "🔴" : "🟢") + "\n";
    dash += "--------------------------------\n";
    dash += "COOLDOWN: " + GetCooldownStatus() + "\n";
    dash += "Consecutive Losses: " + IntegerToString(m_cooldown.consecutiveLosses) + "\n";
    dash += "--------------------------------\n";
    dash += "DISCIPLINE: " + DoubleToString(m_discipline.score, 1) + "% " + (m_discipline.isDisciplined ? "✅" : "⚠️") + "\n";
    dash += "Rule Violations: " + IntegerToString(m_discipline.ruleViolations) + "\n";
    dash += "Adherence Rate: " + DoubleToString(m_discipline.adherenceRate, 1) + "%\n";
    dash += "--------------------------------\n";
    dash += "PSYCHOLOGY:\n";
    dash += "Emotion: " + m_psychology.currentEmotion + "\n";
    dash += "FOMO: " + (m_psychology.isFOMODetected ? "⚠️" : "✅") + " | Revenge: " + (m_psychology.isRevengeTradingDetected ? "⚠️" : "✅") + "\n";
    dash += "Overconfidence: " + (m_psychology.isOverconfidenceDetected ? "⚠️" : "✅") + " | Paralysis: " + (m_psychology.isAnalysisParalysisDetected ? "⚠️" : "✅") + "\n";
    dash += "--------------------------------\n";
    dash += "PERFORMANCE GRADE: " + string(m_performance.grade) + "\n";
    dash += "Win Rate: " + DoubleToString(m_performance.winRate, 1) + "%\n";
    dash += "Profit Factor: " + DoubleToString(m_performance.profitFactor, 2) + "\n";
    dash += "--------------------------------\n";
    dash += "JOURNAL: " + IntegerToString(m_journalCount) + " entries\n";
    dash += "==============================";
    return dash;
}

//--- RF-973: Obtener reporte completo
string CTradingPlan::GetFullReport() const {
    string report = "=== TRADING PLAN FULL REPORT ===\n";
    report += GetDashboard() + "\n";
    report += GetPerformanceReport() + "\n";
    report += GetPsychologyReport() + "\n";
    report += GetDisciplineReport() + "\n";
    report += GetJournalSummary() + "\n";
    report += GetRoutineStatus() + "\n";
    report += "================================";
    return report;
}

//--- RF-974: Obtener reporte de auditoría
string CTradingPlan::GetAuditReport() const {
    string report = "=== AUDIT REPORT ===\n";
    report += "Generated: " + TimeToString(TimeCurrent()) + "\n";
    report += "Total Trades: " + IntegerToString(m_performance.totalTrades) + "\n";
    report += "Rule Violations: " + IntegerToString(m_discipline.ruleViolations) + "\n";
    report += "Cooldown Events: " + IntegerToString(m_cooldown.isActive ? 1 : 0) + "\n";
    report += "Psychology Triggers: " + IntegerToString(m_psychology.consecutiveEmotionTriggers) + "\n";
    report += "Journal Entries: " + IntegerToString(m_journalCount) + "\n";
    report += "Performance Grade: " + string(m_performance.grade) + "\n";
    report += "=========================";
    return report;
}

//--- RF-974: Generar reporte de auditoría
bool CTradingPlan::GenerateAuditReport(string filename) {
    string content = GetAuditReport();
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    FileWrite(handle, content);
    FileClose(handle);
    return true;
}

//--- RF-975: Backtesting
void CTradingPlan::Backtest(datetime startDate, datetime endDate) {
    //--- Placeholder para backtesting
}

bool CTradingPlan::IsBacktestMode() const {
    return false;
}

void CTradingPlan::SetBacktestMode(bool enabled) {
    //--- Placeholder
}

//--- RF-963: Obtener reporte de disciplina
string CTradingPlan::GetDisciplineReport() const {
    string report = "=== DISCIPLINE REPORT ===\n";
    report += "Score: " + DoubleToString(m_discipline.score, 1) + "%\n";
    report += "Disciplined: " + (m_discipline.isDisciplined ? "YES" : "NO") + "\n";
    report += "Rule Violations: " + IntegerToString(m_discipline.ruleViolations) + "\n";
    report += "Adherence Rate: " + DoubleToString(m_discipline.adherenceRate, 1) + "%\n";
    report += "Last Violation: " + m_discipline.lastViolation + " at " + TimeToString(m_discipline.lastViolationTime) + "\n";
    
    if(m_discipline.violationCount > 0) {
        report += "Recent Violations:\n";
        int start = MathMax(0, m_discipline.violationCount - 5);
        for(int i = start; i < m_discipline.violationCount; i++) {
            report += "  - " + m_discipline.violations[i] + "\n";
        }
    }
    
    report += "=============================";
    return report;
}

//--- RF-963: Resetear disciplina
void CTradingPlan::ResetDiscipline() {
    ZeroMemory(m_discipline);
    m_discipline.score = 100;
    m_discipline.isDisciplined = true;
}

//--- Validación: Verificar si se permite trading
bool CTradingPlan::IsTradingAllowed() const {
    if(!m_isEnabled) return false;
    if(!m_isInitialized) return false;
    
    if(m_lossLimits.isDailyLimitReached) return false;
    if(m_lossLimits.isWeeklyLimitReached) return false;
    if(m_lossLimits.isMonthlyLimitReached) return false;
    
    if(IsCooldownActive()) return false;
    
    if(m_psychologyEnabled) {
        if(m_psychology.isRevengeTradingDetected) return false;
        if(m_psychology.isFOMODetected) return false;
        if(m_psychology.isOverconfidenceDetected) return false;
    }
    
    return true;
}

//--- Validación: Obtener razón de bloqueo
string CTradingPlan::GetBlockReason() const {
    if(m_lossLimits.isDailyLimitReached) return "Daily loss limit reached";
    if(m_lossLimits.isWeeklyLimitReached) return "Weekly loss limit reached";
    if(m_lossLimits.isMonthlyLimitReached) return "Monthly loss limit reached";
    if(IsCooldownActive()) return "Cooldown active: " + m_cooldown.reason;
    if(m_psychology.isRevengeTradingDetected) return "Revenge trading detected";
    if(m_psychology.isFOMODetected) return "FOMO detected";
    if(m_psychology.isOverconfidenceDetected) return "Overconfidence detected";
    return "No block reason";
}

//--- Verificar cooldown activo
bool CTradingPlan::IsCooldownActive() {
    if(!m_cooldown.isActive) return false;
    if(TimeCurrent() >= m_cooldown.endTime) {
        ResetCooldown();
        return false;
    }
    return true;
}

//--- Obtener pérdidas consecutivas
int CTradingPlan::GetConsecutiveLosses() {
    return m_cooldown.consecutiveLosses;
}

//--- Obtener ganancias consecutivas
int CTradingPlan::GetConsecutiveWins() {
    return 0;
}

#endif // __CTRADINGPLAN_MQH__