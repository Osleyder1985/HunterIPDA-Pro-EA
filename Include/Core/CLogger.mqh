//+------------------------------------------------------------------+
//|                                                      CLogger.mqh |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el logging y las estadísticas del EA:       |
//| - Registro de operaciones en archivo                             |
//| - Registro de señales y errores                                  |
//| - Cálculo de estadísticas de rendimiento                         |
//| - Exportación de datos a CSV                                     |
//| - Bufferizado para escritura en lotes (optimización)             |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-036: Log de Operaciones                                     |
//|   RF-037: Log de Señales                                         |
//|   RF-038: Log de Errores                                         |
//|   RF-039: Estadísticas de Rendimiento                            |
//|   RF-040: Exportación de Datos                                   |
//|   RF-041: Reseteo de Estadísticas                                |
//|   RF-323: Log de Datos Macro                                     |
//|   RF-041.1: Journal Logging Reference (referencia a RF-970)      |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
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
//| 1.1     | 21/07/2026  | Eliminada JournalEntry duplicada (ahora  |
//|         |             | en CConstants)                           |
//| 1.2     | 21/07/2026  | Eliminada referencia '&' en              |
//|         |             | UpdateModelStatistics()                  |
//| 1.3     | 21/07/2026  | Eliminada referencia '&' en              |
//|         |             | FlushJournalBuffer()                     |
//| 1.4     | 21/07/2026  | Eliminada referencia a signal.pdArray    |
//|         |             | (no existe en Signal)                    |
//+------------------------------------------------------------------+

#ifndef __CLOGGER_MQH__
#define __CLOGGER_MQH__

#include "CConstants.mqh"
#include "CUtils.mqh"
#include "CConfig.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+

//--- Estructura para registro de operaciones
struct TradeRecord {
    ulong        ticket;
    string       symbol;
    ENUM_TRADING_MODEL model;
    ENUM_ORDER_TYPE    type;
    double       entryPrice;
    double       exitPrice;
    double       lot;
    double       sl;
    double       tp;
    double       pnl;
    double       pips;
    datetime     openTime;
    datetime     closeTime;
    bool         isWin;
    ENUM_BIAS    bias;
    string       setupType;
    string       reason;
};

//--- Estructura para registro de señales
struct SignalRecord {
    datetime         signalTime;
    string           symbol;
    ENUM_TRADING_MODEL model;
    ENUM_BIAS        bias;
    ENUM_ENTRY_TYPE  entryType;
    double           entryPrice;
    double           stopLoss;
    double           takeProfit;
    double           rrRatio;
    int              qualityScore;
    bool             isQualified;
    string           setupType;
    string           reason;
    string           pdArrayType;
};

//--- Estructura para estadísticas
struct Statistics {
    int    totalTrades;
    int    winningTrades;
    int    losingTrades;
    double totalPnl;
    double totalPips;
    double winRate;
    double profitFactor;
    double maxDrawdown;
    double avgWin;
    double avgLoss;
    double bestTrade;
    double worstTrade;
    double avgRR;
    double totalRMultiple;
    double maxEquity;
    double minEquity;
    double startBalance;
    double currentBalance;
    datetime startDate;
    datetime lastUpdate;
};

//--- Estadísticas por modelo
struct ModelStatistics {
    ENUM_TRADING_MODEL model;
    Statistics         stats;
};

//+------------------------------------------------------------------+
//| CLASE CLogger - Logging y Estadísticas                           |
//+------------------------------------------------------------------+
class CLogger {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    string             m_logPath;
    string             m_logFile;
    string             m_journalFile;
    string             m_statsFile;
    
    //--- Estadísticas
    Statistics         m_stats;
    ModelStatistics    m_modelStats[9];  // Uno por modelo
    int                m_modelStatsCount;
    
    //--- Buffer para Journal (Optimización)
    JournalEntry       m_journalBuffer[100];
    int                m_journalBufferCount;
    
    //--- Métodos privados
    bool               InitializeFiles();
    void               WriteLog(string message);
    void               WriteTrade(TradeRecord &record);
    void               WriteSignal(SignalRecord &record);
    void               WriteError(string message, int errorCode);
    void               WriteStats();
    void               FlushJournalBuffer();
    void               UpdateStatistics(TradeRecord &record);
    void               UpdateModelStatistics(TradeRecord &record);
    void               CalculateStats();
    string             FormatTrade(TradeRecord &record);
    string             FormatSignal(SignalRecord &record);
    string             FormatStats();
    string             GetTimestamp();
    string             GetModelName(ENUM_TRADING_MODEL model);
    string             GetOrderTypeName(ENUM_ORDER_TYPE type);
    
public:
    //--- Constructor / Destructor
    CLogger();
    ~CLogger();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Logging principal
    void Log(string message, ENUM_LOG_LEVEL level = LOG_INFO);
    void LogTrade(Signal &signal, ulong ticket, double entryPrice, double exitPrice, 
                   double pnl, double pips, datetime openTime, datetime closeTime);
    void LogSignal(Signal &signal);
    void LogError(string message, int errorCode = 0);
    void LogMacro(MacroData &data);
    void LogSeasonal(SeasonalData &data);
    void LogCOT(COTData &data);
    void LogOI(OIData &data);
    void LogMultiAsset(MultiAssetData &data);
    void LogStock(StockData &data);
    void LogMega(MegaTradeData &data);
    void LogJournal(JournalEntry &entry);  // Usa bufferizado
    void LogWarning(string message);
    void LogInfo(string message);
    void LogDebug(string message);
    
    //--- Estadísticas
    void UpdateStats(TradeRecord &record);
    Statistics GetStatistics() const { return m_stats; }
    Statistics GetModelStatistics(ENUM_TRADING_MODEL model);
    void ResetStats();
    void ExportStats();
    void ExportJournal();
    
    //--- Getters
    int GetTotalTrades() const { return m_stats.totalTrades; }
    int GetWinningTrades() const { return m_stats.winningTrades; }
    int GetLosingTrades() const { return m_stats.losingTrades; }
    double GetTotalPnl() const { return m_stats.totalPnl; }
    double GetTotalPips() const { return m_stats.totalPips; }
    double GetWinRate() const { return m_stats.winRate; }
    double GetProfitFactor() const { return m_stats.profitFactor; }
    double GetMaxDrawdown() const { return m_stats.maxDrawdown; }
    double GetAvgWin() const { return m_stats.avgWin; }
    double GetAvgLoss() const { return m_stats.avgLoss; }
    double GetBestTrade() const { return m_stats.bestTrade; }
    double GetWorstTrade() const { return m_stats.worstTrade; }
    
    //--- Reportes
    string GetLogSummary();
    string GetStatsReport();
    string GetDailyReport();
    string GetWeeklyReport();
    string GetMonthlyReport();
    
    //--- Operaciones de buffer
    void FlushJournal();  // Forzar escritura del buffer
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CLogger::CLogger() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_logPath = "";
    m_logFile = "";
    m_journalFile = "";
    m_statsFile = "";
    m_journalBufferCount = 0;
    m_modelStatsCount = 0;
    ZeroMemory(m_stats);
    ZeroMemory(m_modelStats);
}

//--- Destructor
CLogger::~CLogger() {
    Deinit();
}

//--- Inicialización
bool CLogger::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CLogger::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Inicializar archivos
    if(!InitializeFiles()) {
        m_utils.LogError("CLogger::Init - Error al inicializar archivos");
        return false;
    }
    
    //--- Inicializar estadísticas
    m_stats.startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_stats.currentBalance = m_stats.startBalance;
    m_stats.maxEquity = m_stats.startBalance;
    m_stats.minEquity = m_stats.startBalance;
    m_stats.startDate = TimeCurrent();
    
    m_isInitialized = true;
    m_utils.LogInfo("CLogger inicializado correctamente");
    return true;
}

//--- Desinicialización
void CLogger::Deinit() {
    //--- Flushear buffer pendiente
    if(m_journalBufferCount > 0) {
        FlushJournalBuffer();
    }
    
    //--- Escribir estadísticas finales
    if(m_isInitialized) {
        WriteStats();
    }
    
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Inicializar archivos
bool CLogger::InitializeFiles() {
    //--- Obtener ruta del directorio de datos
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_logPath = terminalPath + "\\MQL5\\Files\\HunterIPDA_Logs\\";
    
    //--- Crear directorio si no existe
    if(!FolderCreate(m_logPath)) {
        //--- Si falla, usar ruta alternativa en el directorio del EA
        m_logPath = "\\HunterIPDA_Logs\\";
        FolderCreate(m_logPath);
    }
    
    //--- Nombres de archivos con fecha
    string dateStr = TimeToString(TimeCurrent(), TIME_DATE);
    StringReplace(dateStr, ".", "_");
    
    m_logFile = m_logPath + "HunterIPDA_" + dateStr + ".log";
    m_journalFile = m_logPath + "Journal_" + dateStr + ".log";
    m_statsFile = m_logPath + "Stats_" + dateStr + ".csv";
    
    return true;
}

//--- Obtener timestamp
string CLogger::GetTimestamp() {
    return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

//--- Obtener nombre del modelo
string CLogger::GetModelName(ENUM_TRADING_MODEL model) {
    if(m_utils != NULL) {
        return m_utils.GetModelName(model);
    }
    
    //--- Fallback si m_utils es NULL
    switch(model) {
        case MODEL_POSITION:      return "Position";
        case MODEL_SWING:         return "Swing";
        case MODEL_SHORT_TERM:    return "ShortTerm";
        case MODEL_OSOK:          return "OSOK";
        case MODEL_DAY_TRADING:   return "DayTrading";
        case MODEL_SCALPING:      return "Scalping";
        case MODEL_MEGA_TRADE:    return "MegaTrade";
        case MODEL_STOCK_TRADING: return "StockTrading";
        case MODEL_BONUS_HUNTER:  return "BonusHunter";
        default:                  return "Unknown";
    }
}

//--- Obtener nombre del tipo de orden
string CLogger::GetOrderTypeName(ENUM_ORDER_TYPE type) {
    switch(type) {
        case ORDER_TYPE_BUY:  return "BUY";
        case ORDER_TYPE_SELL: return "SELL";
        case ORDER_TYPE_BUY_LIMIT:  return "BUY_LIMIT";
        case ORDER_TYPE_SELL_LIMIT: return "SELL_LIMIT";
        case ORDER_TYPE_BUY_STOP:   return "BUY_STOP";
        case ORDER_TYPE_SELL_STOP:  return "SELL_STOP";
        default: return "UNKNOWN";
    }
}

//--- Escribir log
void CLogger::WriteLog(string message) {
    if(!m_isInitialized) return;
    
    int handle = FileOpen(m_logFile, FILE_WRITE | FILE_READ | FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, message);
        FileClose(handle);
    }
}

//--- Escribir operación
void CLogger::WriteTrade(TradeRecord &record) {
    if(!m_isInitialized) return;
    
    string line = FormatTrade(record);
    
    int handle = FileOpen(m_logFile, FILE_WRITE | FILE_READ | FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, line);
        FileClose(handle);
    }
}

//--- Escribir señal
void CLogger::WriteSignal(SignalRecord &record) {
    if(!m_isInitialized) return;
    
    string line = FormatSignal(record);
    
    int handle = FileOpen(m_logFile, FILE_WRITE | FILE_READ | FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, line);
        FileClose(handle);
    }
}

//--- Escribir error
void CLogger::WriteError(string message, int errorCode) {
    if(!m_isInitialized) return;
    
    string timestamp = GetTimestamp();
    string line = timestamp + " [ERROR] " + message;
    if(errorCode > 0) {
        line += " (código: " + IntegerToString(errorCode) + ")";
    }
    
    int handle = FileOpen(m_logFile, FILE_WRITE | FILE_READ | FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, line);
        FileClose(handle);
    }
}

//--- Escribir estadísticas
void CLogger::WriteStats() {
    if(!m_isInitialized) return;
    
    string content = FormatStats();
    
    int handle = FileOpen(m_statsFile, FILE_WRITE | FILE_READ | FILE_CSV);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, content);
        FileClose(handle);
    }
}

//--- Formatear operación
string CLogger::FormatTrade(TradeRecord &record) {
    string timestamp = GetTimestamp();
    string result = "";
    
    result += timestamp + " | ";
    result += "TRADE | ";
    result += "Ticket:" + IntegerToString(record.ticket) + " | ";
    result += "Symbol:" + record.symbol + " | ";
    result += "Model:" + GetModelName(record.model) + " | ";
    result += "Type:" + GetOrderTypeName(record.type) + " | ";
    result += "Lot:" + DoubleToString(record.lot, 2) + " | ";
    result += "Entry:" + DoubleToString(record.entryPrice, 5) + " | ";
    result += "Exit:" + DoubleToString(record.exitPrice, 5) + " | ";
    result += "SL:" + DoubleToString(record.sl, 5) + " | ";
    result += "TP:" + DoubleToString(record.tp, 5) + " | ";
    result += "Pips:" + DoubleToString(record.pips, 1) + " | ";
    result += "PnL:" + DoubleToString(record.pnl, 2) + " | ";
    result += "Result:" + (record.isWin ? "WIN" : "LOSS") + " | ";
    result += "Bias:" + (record.bias == BIAS_BULLISH ? "BULLISH" : 
                         (record.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + " | ";
    result += "Setup:" + record.setupType;
    
    if(record.reason != "") {
        result += " | Reason:" + record.reason;
    }
    
    return result;
}

//--- Formatear señal
string CLogger::FormatSignal(SignalRecord &record) {
    string timestamp = GetTimestamp();
    string result = "";
    
    result += timestamp + " | ";
    result += "SIGNAL | ";
    result += "Symbol:" + record.symbol + " | ";
    result += "Model:" + GetModelName(record.model) + " | ";
    result += "Bias:" + (record.bias == BIAS_BULLISH ? "BULLISH" : 
                         (record.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + " | ";
    result += "Entry:" + (record.entryType == ENTRY_BUY_STOP ? "BUY_STOP" :
                          (record.entryType == ENTRY_SELL_STOP ? "SELL_STOP" :
                           (record.entryType == ENTRY_BUY_LIMIT ? "BUY_LIMIT" :
                            (record.entryType == ENTRY_SELL_LIMIT ? "SELL_LIMIT" :
                             (record.entryType == ENTRY_HYBRID ? "HYBRID" : "MARKET"))))) + " | ";
    result += "Price:" + DoubleToString(record.entryPrice, 5) + " | ";
    result += "SL:" + DoubleToString(record.stopLoss, 5) + " | ";
    result += "TP:" + DoubleToString(record.takeProfit, 5) + " | ";
    result += "R:R:" + DoubleToString(record.rrRatio, 1) + ":1 | ";
    result += "Quality:" + IntegerToString(record.qualityScore) + " | ";
    result += "Qualified:" + (record.isQualified ? "YES" : "NO") + " | ";
    result += "Setup:" + record.setupType;
    
    if(record.reason != "") {
        result += " | Reason:" + record.reason;
    }
    
    if(record.pdArrayType != "") {
        result += " | PDArray:" + record.pdArrayType;
    }
    
    return result;
}

//--- Formatear estadísticas
string CLogger::FormatStats() {
    string result = "";
    result += "=== ESTADÍSTICAS ===\n";
    result += "Total Trades: " + IntegerToString(m_stats.totalTrades) + "\n";
    result += "Winning Trades: " + IntegerToString(m_stats.winningTrades) + "\n";
    result += "Losing Trades: " + IntegerToString(m_stats.losingTrades) + "\n";
    result += "Win Rate: " + DoubleToString(m_stats.winRate, 2) + "%\n";
    result += "Total PnL: " + DoubleToString(m_stats.totalPnl, 2) + "\n";
    result += "Total Pips: " + DoubleToString(m_stats.totalPips, 1) + "\n";
    result += "Profit Factor: " + DoubleToString(m_stats.profitFactor, 2) + "\n";
    result += "Max Drawdown: " + DoubleToString(m_stats.maxDrawdown, 2) + "%\n";
    result += "Avg Win: " + DoubleToString(m_stats.avgWin, 2) + "\n";
    result += "Avg Loss: " + DoubleToString(m_stats.avgLoss, 2) + "\n";
    result += "Best Trade: " + DoubleToString(m_stats.bestTrade, 2) + "\n";
    result += "Worst Trade: " + DoubleToString(m_stats.worstTrade, 2) + "\n";
    result += "Avg R:R: " + DoubleToString(m_stats.avgRR, 1) + ":1\n";
    result += "Total R-Multiple: " + DoubleToString(m_stats.totalRMultiple, 2) + "\n";
    result += "Start Balance: " + DoubleToString(m_stats.startBalance, 2) + "\n";
    result += "Current Balance: " + DoubleToString(m_stats.currentBalance, 2) + "\n";
    result += "Max Equity: " + DoubleToString(m_stats.maxEquity, 2) + "\n";
    result += "Min Equity: " + DoubleToString(m_stats.minEquity, 2) + "\n";
    result += "Start Date: " + TimeToString(m_stats.startDate) + "\n";
    result += "Last Update: " + TimeToString(m_stats.lastUpdate) + "\n";
    result += "=========================\n";
    return result;
}

//--- Flushear buffer de journal
void CLogger::FlushJournalBuffer() {
    if(m_journalBufferCount == 0) return;
    
    string content = "";
    for(int i = 0; i < m_journalBufferCount; i++) {
        //--- Acceder directamente al array sin referencia
        content += TimeToString(m_journalBuffer[i].timestamp, TIME_DATE | TIME_SECONDS) + " | ";
        content += "JOURNAL | ";
        content += "Symbol:" + m_journalBuffer[i].symbol + " | ";
        content += "Model:" + GetModelName(m_journalBuffer[i].model) + " | ";
        content += "Type:" + m_journalBuffer[i].tradeType + " | ";
        content += "Description:" + m_journalBuffer[i].description + " | ";
        content += "PnL:" + DoubleToString(m_journalBuffer[i].pnl, 2) + " | ";
        content += "Emotion:" + m_journalBuffer[i].emotion + " | ";
        content += "RuleViolation:" + (m_journalBuffer[i].ruleViolation ? "YES" : "NO");
        if(m_journalBuffer[i].ruleViolated != "") {
            content += " | Rule:" + m_journalBuffer[i].ruleViolated;
        }
        content += "\n";
    }
    
    int handle = FileOpen(m_journalFile, FILE_WRITE | FILE_READ | FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, content);
        FileClose(handle);
    }
    
    m_journalBufferCount = 0;
}

//--- Actualizar estadísticas
void CLogger::UpdateStatistics(TradeRecord &record) {
    //--- RF-039: Estadísticas de Rendimiento
    m_stats.totalTrades++;
    m_stats.totalPnl += record.pnl;
    m_stats.totalPips += record.pips;
     
    //--- Calcular R-Multiple (proteger contra división por cero)
    double stopDistance = MathAbs(record.entryPrice - record.sl);
    if(stopDistance > 0) {
        m_stats.totalRMultiple += (record.pips / stopDistance * 10);
    } else {
        m_stats.totalRMultiple += 0;
    }
    
    if(record.isWin) {
        m_stats.winningTrades++;
        m_stats.avgWin = (m_stats.avgWin * (m_stats.winningTrades - 1) + record.pnl) / m_stats.winningTrades;
        if(record.pnl > m_stats.bestTrade) m_stats.bestTrade = record.pnl;
    } else {
        m_stats.losingTrades++;
        m_stats.avgLoss = (m_stats.avgLoss * (m_stats.losingTrades - 1) + record.pnl) / m_stats.losingTrades;
        if(record.pnl < m_stats.worstTrade) m_stats.worstTrade = record.pnl;
    }
    
    //--- Calcular win rate
    if(m_stats.totalTrades > 0) {
        m_stats.winRate = (double)m_stats.winningTrades / m_stats.totalTrades * 100.0;
    }
    
    //--- Calcular profit factor
    double grossProfit = m_stats.avgWin * m_stats.winningTrades;
    double grossLoss = MathAbs(m_stats.avgLoss * m_stats.losingTrades);
    if(grossLoss > 0) {
        m_stats.profitFactor = grossProfit / grossLoss;
    } else {
        m_stats.profitFactor = 0;
    }
    
    //--- Calcular avg R:R
    if(m_stats.totalTrades > 0) {
        m_stats.avgRR = m_stats.totalRMultiple / m_stats.totalTrades;
    }
    
    //--- Actualizar balance y equity
    m_stats.currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    if(equity > m_stats.maxEquity) m_stats.maxEquity = equity;
    if(equity < m_stats.minEquity) m_stats.minEquity = equity;
    
    //--- Calcular drawdown máximo
    double drawdown = (m_stats.maxEquity - equity) / m_stats.maxEquity * 100.0;
    if(drawdown > m_stats.maxDrawdown) m_stats.maxDrawdown = drawdown;
    
    m_stats.lastUpdate = TimeCurrent();
}

//--- Actualizar estadísticas por modelo
void CLogger::UpdateModelStatistics(TradeRecord &record) {
    //--- Buscar estadísticas del modelo
    int idx = -1;
    for(int i = 0; i < m_modelStatsCount; i++) {
        if(m_modelStats[i].model == record.model) {
            idx = i;
            break;
        }
    }
    
    //--- Si no existe, crear
    if(idx == -1 && m_modelStatsCount < 9) {
        idx = m_modelStatsCount;
        m_modelStats[idx].model = record.model;
        ZeroMemory(m_modelStats[idx].stats);
        m_modelStatsCount++;
    }
    
    if(idx >= 0) {
        //--- Actualizar directamente sin referencia
        m_modelStats[idx].stats.totalTrades++;
        m_modelStats[idx].stats.totalPnl += record.pnl;
        m_modelStats[idx].stats.totalPips += record.pips;
         
        //--- Calcular R-Multiple (proteger contra división por cero)
        double stopDistance = MathAbs(record.entryPrice - record.sl);
        if(stopDistance > 0) {
            m_modelStats[idx].stats.totalRMultiple += (record.pips / stopDistance * 10);
        } else {
            m_modelStats[idx].stats.totalRMultiple += 0;
        }
        
        if(record.isWin) {
            m_modelStats[idx].stats.winningTrades++;
            int wins = m_modelStats[idx].stats.winningTrades;
            m_modelStats[idx].stats.avgWin = (m_modelStats[idx].stats.avgWin * (wins - 1) + record.pnl) / wins;
            if(record.pnl > m_modelStats[idx].stats.bestTrade) 
                m_modelStats[idx].stats.bestTrade = record.pnl;
        } else {
            m_modelStats[idx].stats.losingTrades++;
            int losses = m_modelStats[idx].stats.losingTrades;
            m_modelStats[idx].stats.avgLoss = (m_modelStats[idx].stats.avgLoss * (losses - 1) + record.pnl) / losses;
            if(record.pnl < m_modelStats[idx].stats.worstTrade) 
                m_modelStats[idx].stats.worstTrade = record.pnl;
        }
        
        if(m_modelStats[idx].stats.totalTrades > 0) {
            m_modelStats[idx].stats.winRate = (double)m_modelStats[idx].stats.winningTrades / 
                                               m_modelStats[idx].stats.totalTrades * 100.0;
        }
    }
}

//--- Log principal
void CLogger::Log(string message, ENUM_LOG_LEVEL level) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string timestamp = GetTimestamp();
    string levelStr = "";
    
    switch(level) {
        case LOG_ERROR:   levelStr = "ERROR"; break;
        case LOG_WARNING: levelStr = "WARNING"; break;
        case LOG_INFO:    levelStr = "INFO"; break;
        case LOG_DEBUG:   levelStr = "DEBUG"; break;
        case LOG_TRACE:   levelStr = "TRACE"; break;
    }
    
    string logLine = timestamp + " [" + levelStr + "] " + message;
    Print(logLine);
    WriteLog(logLine);
}

//--- Log de operación
void CLogger::LogTrade(Signal &signal, ulong ticket, double entryPrice, double exitPrice, 
                        double pnl, double pips, datetime openTime, datetime closeTime) {
    //--- RF-036: Log de Operaciones
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    TradeRecord record;
    record.ticket = ticket;
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.type = (signal.bias == BIAS_BULLISH) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    record.entryPrice = entryPrice;
    record.exitPrice = exitPrice;
    record.lot = signal.risk / 100.0 * AccountInfoDouble(ACCOUNT_BALANCE) / 
                 (MathAbs(entryPrice - signal.stopLoss) * 10);
    record.sl = signal.stopLoss;
    record.tp = signal.takeProfit;
    record.pnl = pnl;
    record.pips = pips;
    record.openTime = openTime;
    record.closeTime = closeTime;
    record.isWin = (pnl > 0);
    record.bias = signal.bias;
    record.setupType = signal.setupType;
    record.reason = signal.reason;
    
    WriteTrade(record);
    UpdateStatistics(record);
    UpdateModelStatistics(record);
}

//--- Log de señal
void CLogger::LogSignal(Signal &signal) {
    //--- RF-037: Log de Señales
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    SignalRecord record;
    record.signalTime = signal.signalTime;
    record.symbol = signal.symbol;
    record.model = signal.model;
    record.bias = signal.bias;
    record.entryType = signal.entryType;
    record.entryPrice = signal.entryPrice;
    record.stopLoss = signal.stopLoss;
    record.takeProfit = signal.takeProfit;
    record.rrRatio = signal.rrRatio;
    record.qualityScore = signal.qualityScore;
    record.isQualified = signal.isQualified;
    record.setupType = signal.setupType;
    record.reason = signal.reason;
    record.pdArrayType = "";
    
    WriteSignal(record);
}

//--- Log de error
void CLogger::LogError(string message, int errorCode = 0) {
    //--- RF-038: Log de Errores
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    WriteError(message, errorCode);
}

//--- Log de advertencia
void CLogger::LogWarning(string message) {
    Log("[WARNING] " + message, LOG_WARNING);
}

//--- Log de información
void CLogger::LogInfo(string message) {
    Log("[INFO] " + message, LOG_INFO);
}

//--- Log de depuración
void CLogger::LogDebug(string message) {
    Log("[DEBUG] " + message, LOG_DEBUG);
}

//--- Log de journal (bufferizado)
void CLogger::LogJournal(JournalEntry &entry) {
    //--- RF-041.1: Journal Logging Reference
    //--- RF-970: Journaling System (referenciado)
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    //--- Añadir al buffer
    if(m_journalBufferCount < 100) {
        m_journalBuffer[m_journalBufferCount] = entry;
        m_journalBufferCount++;
    }
    
    //--- Si el buffer está lleno, flushear
    if(m_journalBufferCount >= 100) {
        FlushJournalBuffer();
    }
}

//--- Log de datos macro
void CLogger::LogMacro(MacroData &data) {
    //--- RF-323: Log de Datos Macro
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [MACRO] ";
    line += "10Y:" + DoubleToString(data.tenYearYield, 2) + "% | ";
    line += "DXY:" + DoubleToString(data.dxy, 2) + " | ";
    line += "CRB:" + DoubleToString(data.crb, 2) + " | ";
    line += "Gold:" + DoubleToString(data.gold, 2) + " | ";
    line += "Oil:" + DoubleToString(data.oil, 2);
    
    WriteLog(line);
}

//--- Log de datos estacionales
void CLogger::LogSeasonal(SeasonalData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [SEASONAL] ";
    line += "Symbol:" + data.symbol + " | ";
    line += "Month:" + IntegerToString(data.month) + " | ";
    line += "Bias:" + (data.bias == BIAS_BULLISH ? "BULLISH" : 
                       (data.bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + " | ";
    line += "Return:" + DoubleToString(data.historicalReturn, 2) + "% | ";
    line += "WinRate:" + DoubleToString(data.winRate, 2) + "% | ";
    line += "Sample:" + IntegerToString(data.sampleSize);
    
    WriteLog(line);
}

//--- Log de COT
void CLogger::LogCOT(COTData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [COT] ";
    line += "Symbol:" + data.symbol + " | ";
    line += "Commercial Net:" + DoubleToString(data.commercialNet, 2) + " | ";
    line += "Program:" + (data.isBuyProgram ? "BUY" : 
                          (data.isSellProgram ? "SELL" : "HEDGE"));
    
    WriteLog(line);
}

//--- Log de Open Interest
void CLogger::LogOI(OIData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [OI] ";
    line += "Symbol:" + data.symbol + " | ";
    line += "Current:" + DoubleToString(data.currentOI, 0) + " | ";
    line += "Change:" + DoubleToString(data.changePercent, 2) + "% | ";
    line += "Trend:" + (data.isIncreasing ? "UP" : "DOWN");
    
    WriteLog(line);
}

//--- Log de Multi-Asset
void CLogger::LogMultiAsset(MultiAssetData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [MULTI-ASSET] ";
    line += "Risk:" + (data.isRiskOn ? "ON" : "OFF") + " | ";
    line += "Alignment:" + IntegerToString(data.alignmentScore) + " | ";
    line += "Leader:" + data.leadershipAsset;
    
    WriteLog(line);
}

//--- Log de Stock
void CLogger::LogStock(StockData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [STOCK] ";
    line += "Symbol:" + data.symbol + " | ";
    line += "Earnings Growth:" + DoubleToString(data.currentEarningsGrowth, 2) + "% | ";
    line += "Inst.Ownership:" + DoubleToString(data.institutionalOwnership, 2) + "% | ";
    line += "Watchlist:" + (data.isBuyWatchlist ? "BUY" : 
                            (data.isSellWatchlist ? "SELL" : "NONE"));
    
    WriteLog(line);
}

//--- Log de Mega Trade
void CLogger::LogMega(MegaTradeData &data) {
    if(!m_isInitialized) return;
    if(m_config != NULL && !m_config.IsEnabled()) return;
    
    string line = GetTimestamp() + " [MEGA] ";
    line += "Symbol:" + data.symbol + " | ";
    line += "Progress:" + DoubleToString(data.progressPercent, 1) + "% | ";
    line += "R:R:" + DoubleToString(data.targetRMultiple, 1) + ":1 | ";
    line += "Scenario:" + (data.scenario == SCENARIO_BASE ? "BASE" :
                           (data.scenario == SCENARIO_BULL ? "BULL" : "BEAR"));
    
    WriteLog(line);
}

//--- Actualizar estadísticas (público)
void CLogger::UpdateStats(TradeRecord &record) {
    UpdateStatistics(record);
    UpdateModelStatistics(record);
}

//--- Exportar estadísticas
void CLogger::ExportStats() {
    //--- RF-040: Exportación de Datos
    WriteStats();
}

//--- Exportar journal
void CLogger::ExportJournal() {
    //--- Forzar flush del buffer
    FlushJournalBuffer();
}

//--- Resetear estadísticas
void CLogger::ResetStats() {
    //--- RF-041: Reseteo de Estadísticas
    if(!m_isInitialized) return;
    
    ZeroMemory(m_stats);
    m_stats.startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_stats.currentBalance = m_stats.startBalance;
    m_stats.maxEquity = m_stats.startBalance;
    m_stats.minEquity = m_stats.startBalance;
    m_stats.startDate = TimeCurrent();
    
    for(int i = 0; i < m_modelStatsCount; i++) {
        ZeroMemory(m_modelStats[i].stats);
    }
    m_modelStatsCount = 0;
    
    //--- Escribir archivo de stats
    WriteStats();
    
    LogInfo("Estadísticas reseteadas");
}

//--- Obtener estadísticas por modelo
Statistics CLogger::GetModelStatistics(ENUM_TRADING_MODEL model) {
    for(int i = 0; i < m_modelStatsCount; i++) {
        if(m_modelStats[i].model == model) {
            return m_modelStats[i].stats;
        }
    }
    
    Statistics empty;
    ZeroMemory(empty);
    return empty;
}

//--- Forzar flush del journal
void CLogger::FlushJournal() {
    FlushJournalBuffer();
}

//--- Obtener resumen de log
string CLogger::GetLogSummary() {
    string summary = "=== LOG SUMMARY ===\n";
    summary += "Log Path: " + m_logPath + "\n";
    summary += "Log File: " + m_logFile + "\n";
    summary += "Journal File: " + m_journalFile + "\n";
    summary += "Stats File: " + m_statsFile + "\n";
    summary += "Buffer Entries: " + IntegerToString(m_journalBufferCount) + "\n";
    return summary;
}

//--- Obtener reporte de estadísticas
string CLogger::GetStatsReport() {
    return FormatStats();
}

//--- Obtener reporte diario
string CLogger::GetDailyReport() {
    string report = "=== DAILY REPORT ===\n";
    report += "Date: " + TimeToString(TimeCurrent(), TIME_DATE) + "\n";
    report += "Total Trades: " + IntegerToString(m_stats.totalTrades) + "\n";
    report += "Win Rate: " + DoubleToString(m_stats.winRate, 2) + "%\n";
    report += "Total PnL: " + DoubleToString(m_stats.totalPnl, 2) + "\n";
    report += "Profit Factor: " + DoubleToString(m_stats.profitFactor, 2) + "\n";
    report += "Max Drawdown: " + DoubleToString(m_stats.maxDrawdown, 2) + "%\n";
    report += "=========================\n";
    return report;
}

//--- Obtener reporte semanal
string CLogger::GetWeeklyReport() {
    string report = "=== WEEKLY REPORT ===\n";
    report += "Week: " + IntegerToString(m_utils.GetWeekNumber(TimeCurrent())) + "\n";
    report += "Total Trades: " + IntegerToString(m_stats.totalTrades) + "\n";
    report += "Win Rate: " + DoubleToString(m_stats.winRate, 2) + "%\n";
    report += "Total PnL: " + DoubleToString(m_stats.totalPnl, 2) + "\n";
    report += "Profit Factor: " + DoubleToString(m_stats.profitFactor, 2) + "\n";
    report += "Max Drawdown: " + DoubleToString(m_stats.maxDrawdown, 2) + "%\n";
    report += "=========================\n";
    return report;
}

//--- Obtener reporte mensual
string CLogger::GetMonthlyReport() {
    string report = "=== MONTHLY REPORT ===\n";
    report += "Month: " + TimeToString(TimeCurrent(), TIME_DATE) + "\n";
    report += "Total Trades: " + IntegerToString(m_stats.totalTrades) + "\n";
    report += "Win Rate: " + DoubleToString(m_stats.winRate, 2) + "%\n";
    report += "Total PnL: " + DoubleToString(m_stats.totalPnl, 2) + "\n";
    report += "Profit Factor: " + DoubleToString(m_stats.profitFactor, 2) + "\n";
    report += "Max Drawdown: " + DoubleToString(m_stats.maxDrawdown, 2) + "%\n";
    report += "=========================\n";
    return report;
}

#endif // __CLOGGER_MQH__