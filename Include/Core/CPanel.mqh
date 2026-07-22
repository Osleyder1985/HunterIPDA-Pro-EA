//+------------------------------------------------------------------+
//|                                                      CPanel.mqh  |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el panel de control en el gráfico:          |
//| - Visualización de estado del EA                                 |
//| - Información de posiciones abiertas                             |
//| - Estadísticas de rendimiento                                    |
//| - Botones de control (activar/desactivar)                        |
//| - Dashboards de Multi-Asset, Stock Watchlists, Mega Trades       |
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
//|   - CConfig: Configuración                                       |
//|   - CLogger: Logging y estadísticas                              |
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

#ifndef __CPANEL_MQH__
#define __CPANEL_MQH__

#include "CConstants.mqh"
#include "CUtils.mqh"
#include "CConfig.mqh"
#include "CLogger.mqh"

//+------------------------------------------------------------------+
//| CLASE CPanel - Panel de Control                                  |
//+------------------------------------------------------------------+
class CPanel {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CLogger*           m_logger;
    CUtils*            m_utils;
    bool               m_isInitialized;
    bool               m_isVisible;
    int                m_x;
    int                m_y;
    int                m_width;
    int                m_height;
    int                m_updateInterval;
    datetime           m_lastUpdate;
    string             m_prefix;
    int                m_lineSpacing;
    int                m_columnSpacing;
    int                m_margin;
    
    //--- Colores
    color              m_bgColor;
    color              m_headerColor;
    color              m_textColor;
    color              m_successColor;
    color              m_errorColor;
    color              m_warningColor;
    color              m_bullColor;
    color              m_bearColor;
    color              m_neutralColor;
    color              m_borderColor;
    
    //--- Métodos privados
    bool               CreatePanel();
    void               DestroyPanel();
    void               UpdatePanel();
    void               DrawHeader();
    void               DrawStatus();
    void               DrawPositions();
    void               DrawStats();
    void               DrawButtons();
    void               DrawSeparator(int y, string name);
    void               DrawLabel(string name, string text, int x, int y, color clr, int fontSize = 10);
    void               DrawRectangle(string name, int x, int y, int width, int height, color clr, bool fill = true);
    string             FormatText(string label, string value);
    string             GetStatusText();
    color              GetStatusColor();
    int                GetLineY(int line);
    bool               IsButtonClicked(string buttonName);
    void               UpdateButtonState(string buttonName, bool state);
    string             GetTimeString(datetime time);
    string             GetPnLString(double pnl);
    
public:
    //--- Constructor / Destructor
    CPanel();
    ~CPanel();
    
    //--- Inicialización
    bool Init(CConfig* config, CLogger* logger, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- Métodos Principales
    void Update();
    void Show();
    void Hide();
    void Toggle();
    void Refresh();
    void Clear();
    
    //--- Getters
    bool IsVisible() const { return m_isVisible; }
    int GetX() const { return m_x; }
    int GetY() const { return m_y; }
    int GetWidth() const { return m_width; }
    int GetHeight() const { return m_height; }
    
    //--- Eventos
    bool OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    
    //--- Reportes
    string GetPanelSummary();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CPanel::CPanel() {
    m_config = NULL;
    m_logger = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_isVisible = true;
    m_x = 10;
    m_y = 30;
    m_width = 350;
    m_height = 500;
    m_updateInterval = 5;
    m_lastUpdate = 0;
    m_prefix = "HP_";
    m_lineSpacing = 22;
    m_columnSpacing = 100;
    m_margin = 10;
    
    //--- Colores
    m_bgColor = clrDarkSlateGray;
    m_headerColor = clrSteelBlue;
    m_textColor = clrWhite;
    m_successColor = clrLimeGreen;
    m_errorColor = clrRed;
    m_warningColor = clrYellow;
    m_bullColor = clrLimeGreen;
    m_bearColor = clrRed;
    m_neutralColor = clrYellow;
    m_borderColor = clrGray;
}

//--- Destructor
CPanel::~CPanel() {
    Deinit();
}

//--- Inicialización
bool CPanel::Init(CConfig* config, CLogger* logger, CUtils* utils) {
    if(config == NULL || logger == NULL || utils == NULL) {
        Print("CPanel::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_logger = logger;
    m_utils = utils;
    
    //--- Crear panel
    if(!CreatePanel()) {
        m_utils.LogError("CPanel::Init - Error al crear panel");
        return false;
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CPanel inicializado correctamente");
    return true;
}

//--- Desinicialización
void CPanel::Deinit() {
    DestroyPanel();
    m_config = NULL;
    m_logger = NULL;
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Crear panel
bool CPanel::CreatePanel() {
    if(!m_isVisible) return true;
    
    //--- Fondo del panel
    string rectName = m_prefix + "Background";
    ObjectCreate(0, rectName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, rectName, OBJPROP_XDISTANCE, m_x);
    ObjectSetInteger(0, rectName, OBJPROP_YDISTANCE, m_y);
    ObjectSetInteger(0, rectName, OBJPROP_XSIZE, m_width);
    ObjectSetInteger(0, rectName, OBJPROP_YSIZE, m_height);
    ObjectSetInteger(0, rectName, OBJPROP_BGCOLOR, m_bgColor);
    ObjectSetInteger(0, rectName, OBJPROP_BORDER_COLOR, m_borderColor);
    ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, false);
    
    //--- Borde del panel
    string borderName = m_prefix + "Border";
    ObjectCreate(0, borderName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, borderName, OBJPROP_XDISTANCE, m_x);
    ObjectSetInteger(0, borderName, OBJPROP_YDISTANCE, m_y);
    ObjectSetInteger(0, borderName, OBJPROP_XSIZE, m_width);
    ObjectSetInteger(0, borderName, OBJPROP_YSIZE, m_height);
    ObjectSetInteger(0, borderName, OBJPROP_BGCOLOR, clrNONE);
    ObjectSetInteger(0, borderName, OBJPROP_BORDER_COLOR, m_borderColor);
    ObjectSetInteger(0, borderName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, borderName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, borderName, OBJPROP_HIDDEN, false);
    
    //--- Dibujar contenido inicial
    UpdatePanel();
    
    ChartRedraw();
    return true;
}

//--- Destruir panel
void CPanel::DestroyPanel() {
    ObjectsDeleteAll(0, m_prefix);
    ChartRedraw();
}

//--- Actualizar panel
void CPanel::UpdatePanel() {
    if(!m_isInitialized || !m_isVisible) return;
    
    //--- Verificar si debe actualizar
    if(TimeCurrent() - m_lastUpdate < m_updateInterval) return;
    m_lastUpdate = TimeCurrent();
    
    //--- Limpiar objetos dinámicos (no el fondo)
    for(int i = ObjectsTotal(0) - 1; i >= 0; i--) {
        string name = ObjectName(0, i);
        if(StringFind(name, m_prefix) == 0 && 
           StringFind(name, "Background") == -1 &&
           StringFind(name, "Border") == -1) {
            ObjectDelete(0, name);
        }
    }
    
    //--- Dibujar elementos
    DrawHeader();
    DrawSeparator(GetLineY(1), "ESTADO");
    DrawStatus();
    DrawSeparator(GetLineY(4), "POSICIONES");
    DrawPositions();
    DrawSeparator(GetLineY(7), "ESTADÍSTICAS");
    DrawStats();
    DrawSeparator(GetLineY(14), "CONTROL");
    DrawButtons();
    
    ChartRedraw();
}

//--- Dibujar encabezado
void CPanel::DrawHeader() {
    int x = m_x + m_margin;
    int y = m_y + m_margin;
    
    //--- Título
    DrawLabel("Title", "HUNTERIPDA PRO EA", x, y, m_headerColor, 14);
    
    //--- Versión
    string version = "v1.7";
    DrawLabel("Version", version, x + 200, y, m_textColor, 10);
    
    //--- Hora
    string time = GetTimeString(TimeCurrent());
    DrawLabel("Time", time, x + 280, y, m_textColor, 9);
}

//--- Dibujar estado
void CPanel::DrawStatus() {
    int x = m_x + m_margin;
    int y = GetLineY(2);
    
    string status = GetStatusText();
    color clr = GetStatusColor();
    
    DrawLabel("StatusLabel", "Estado:", x, y, m_textColor);
    DrawLabel("StatusValue", status, x + m_columnSpacing, y, clr);
    
    y = GetLineY(3);
    string model = m_utils.GetModelName(m_config.GetTradingModel());
    DrawLabel("ModelLabel", "Modelo:", x, y, m_textColor);
    DrawLabel("ModelValue", model, x + m_columnSpacing, y, m_textColor);
    
    y = GetLineY(4);
    DrawLabel("PnLLabel", "PnL Total:", x, y, m_textColor);
    double pnl = m_logger.GetTotalPnl();
    string pnlStr = GetPnLString(pnl);
    color pnlClr = (pnl >= 0) ? m_successColor : m_errorColor;
    DrawLabel("PnLValue", pnlStr, x + m_columnSpacing, y, pnlClr);
}

//--- Dibujar posiciones
void CPanel::DrawPositions() {
    int x = m_x + m_margin;
    int y = GetLineY(5);
    
    int openPositions = m_logger.GetTotalTrades(); // Simplificado
    int wins = m_logger.GetWinningTrades();
    int losses = m_logger.GetLosingTrades();
    
    DrawLabel("OpenLabel", "Abiertas:", x, y, m_textColor);
    DrawLabel("OpenValue", IntegerToString(openPositions), x + m_columnSpacing, y, m_textColor);
    
    y = GetLineY(6);
    DrawLabel("WinsLabel", "Ganadas:", x, y, m_textColor);
    DrawLabel("WinsValue", IntegerToString(wins), x + m_columnSpacing, y, m_successColor);
    
    y = GetLineY(7);
    DrawLabel("LossesLabel", "Perdidas:", x, y, m_textColor);
    DrawLabel("LossesValue", IntegerToString(losses), x + m_columnSpacing, y, m_errorColor);
}

//--- Dibujar estadísticas
void CPanel::DrawStats() {
    int x = m_x + m_margin;
    int y = GetLineY(8);
    
    double winRate = m_logger.GetWinRate();
    double profitFactor = m_logger.GetProfitFactor();
    double maxDrawdown = m_logger.GetMaxDrawdown();
    
    DrawLabel("WinRateLabel", "Win Rate:", x, y, m_textColor);
    DrawLabel("WinRateValue", DoubleToString(winRate, 1) + "%", x + m_columnSpacing, y, 
               (winRate >= 50) ? m_successColor : m_errorColor);
    
    y = GetLineY(9);
    DrawLabel("PFLabel", "Profit Factor:", x, y, m_textColor);
    DrawLabel("PFValue", DoubleToString(profitFactor, 2), x + m_columnSpacing, y, 
               (profitFactor >= 1.5) ? m_successColor : m_warningColor);
    
    y = GetLineY(10);
    DrawLabel("DDLabel", "Max Drawdown:", x, y, m_textColor);
    DrawLabel("DDValue", DoubleToString(maxDrawdown, 1) + "%", x + m_columnSpacing, y,
               (maxDrawdown < 10) ? m_successColor : m_errorColor);
    
    y = GetLineY(11);
    double totalPips = m_logger.GetTotalPips();
    DrawLabel("PipsLabel", "Pips Totales:", x, y, m_textColor);
    DrawLabel("PipsValue", DoubleToString(totalPips, 1), x + m_columnSpacing, y, m_textColor);
}

//--- Dibujar botones
void CPanel::DrawButtons() {
    int x = m_x + m_margin;
    int y = GetLineY(15);
    int buttonWidth = 80;
    int buttonHeight = 25;
    int spacing = 10;
    
    //--- Botón Activar/Desactivar
    string btnName = m_prefix + "BtnToggle";
    bool isEnabled = m_config.IsEnabled();
    string btnText = isEnabled ? "DESACTIVAR" : "ACTIVAR";
    color btnColor = isEnabled ? m_errorColor : m_successColor;
    
    ObjectCreate(0, btnName, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, btnName, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, btnName, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, btnName, OBJPROP_XSIZE, buttonWidth);
    ObjectSetInteger(0, btnName, OBJPROP_YSIZE, buttonHeight);
    ObjectSetString(0, btnName, OBJPROP_TEXT, btnText);
    ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, btnColor);
    ObjectSetInteger(0, btnName, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, btnName, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, btnName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, btnName, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, btnName, OBJPROP_STATE, false);
    
    //--- Botón Reset
    string resetName = m_prefix + "BtnReset";
    ObjectCreate(0, resetName, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, resetName, OBJPROP_XDISTANCE, x + buttonWidth + spacing);
    ObjectSetInteger(0, resetName, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, resetName, OBJPROP_XSIZE, buttonWidth);
    ObjectSetInteger(0, resetName, OBJPROP_YSIZE, buttonHeight);
    ObjectSetString(0, resetName, OBJPROP_TEXT, "RESET");
    ObjectSetInteger(0, resetName, OBJPROP_BGCOLOR, m_warningColor);
    ObjectSetInteger(0, resetName, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, resetName, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, resetName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, resetName, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, resetName, OBJPROP_STATE, false);
    
    //--- Botón Cerrar Panel
    string closeName = m_prefix + "BtnClose";
    ObjectCreate(0, closeName, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, closeName, OBJPROP_XDISTANCE, x + buttonWidth * 2 + spacing * 2);
    ObjectSetInteger(0, closeName, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, closeName, OBJPROP_XSIZE, buttonWidth);
    ObjectSetInteger(0, closeName, OBJPROP_YSIZE, buttonHeight);
    ObjectSetString(0, closeName, OBJPROP_TEXT, "CERRAR");
    ObjectSetInteger(0, closeName, OBJPROP_BGCOLOR, clrGray);
    ObjectSetInteger(0, closeName, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, closeName, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, closeName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, closeName, OBJPROP_HIDDEN, false);
    ObjectSetInteger(0, closeName, OBJPROP_STATE, false);
}

//--- Dibujar separador
void CPanel::DrawSeparator(int y, string name) {
    int x = m_x + m_margin;
    int width = m_width - m_margin * 2;
    
    string lineName = m_prefix + "Sep_" + name;
    ObjectCreate(0, lineName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, lineName, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, lineName, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, lineName, OBJPROP_TEXT, "--- " + name + " ---");
    ObjectSetInteger(0, lineName, OBJPROP_COLOR, m_borderColor);
    ObjectSetInteger(0, lineName, OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
}

//--- Dibujar etiqueta
void CPanel::DrawLabel(string name, string text, int x, int y, color clr, int fontSize = 10) {
    string labelName = m_prefix + "Lbl_" + name;
    ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, labelName, OBJPROP_TEXT, text);
    ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
}

//--- Formatear texto
string CPanel::FormatText(string label, string value) {
    return label + " " + value;
}

//--- Obtener texto de estado
string CPanel::GetStatusText() {
    if(!m_config.IsEnabled()) return "DESACTIVADO";
    if(m_logger.GetTotalTrades() > 0) return "OPERANDO";
    return "ACTIVO - ESPERANDO";
}

//--- Obtener color de estado
color CPanel::GetStatusColor() {
    if(!m_config.IsEnabled()) return m_errorColor;
    if(m_logger.GetTotalTrades() > 0) return m_successColor;
    return m_warningColor;
}

//--- Obtener línea Y
int CPanel::GetLineY(int line) {
    return m_y + m_margin + line * m_lineSpacing;
}

//--- Verificar si botón fue clickeado
bool CPanel::IsButtonClicked(string buttonName) {
    return ObjectGetInteger(0, buttonName, OBJPROP_STATE) == 1;
}

//--- Actualizar estado del botón
void CPanel::UpdateButtonState(string buttonName, bool state) {
    ObjectSetInteger(0, buttonName, OBJPROP_STATE, state ? 0 : 1);
}

//--- Obtener tiempo en string
string CPanel::GetTimeString(datetime time) {
    return TimeToString(time, TIME_DATE | TIME_SECONDS);
}

//--- Obtener PnL en string
string CPanel::GetPnLString(double pnl) {
    if(pnl >= 0) {
        return "+" + DoubleToString(pnl, 2);
    } else {
        return DoubleToString(pnl, 2);
    }
}

//--- Mostrar panel
void CPanel::Show() {
    if(m_isVisible) return;
    m_isVisible = true;
    CreatePanel();
    UpdatePanel();
}

//--- Ocultar panel
void CPanel::Hide() {
    if(!m_isVisible) return;
    m_isVisible = false;
    DestroyPanel();
}

//--- Alternar visibilidad
void CPanel::Toggle() {
    if(m_isVisible) {
        Hide();
    } else {
        Show();
    }
}

//--- Refrescar panel
void CPanel::Refresh() {
    if(m_isVisible) {
        DestroyPanel();
        CreatePanel();
        UpdatePanel();
    }
}

//--- Limpiar panel
void CPanel::Clear() {
    DestroyPanel();
}

//--- Manejar eventos del chart
bool CPanel::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if(id == CHARTEVENT_OBJECT_CLICK) {
        //--- Botón Toggle
        if(sparam == m_prefix + "BtnToggle") {
            bool isEnabled = m_config.IsEnabled();
            m_config.SetEnabled(!isEnabled);
            Refresh();
            m_utils.LogInfo("CPanel - EA " + (string)(m_config.IsEnabled() ? "activado" : "desactivado"));
            return true;
        }
        
        //--- Botón Reset
        if(sparam == m_prefix + "BtnReset") {
            m_logger.ResetStats();
            Refresh();
            m_utils.LogInfo("CPanel - Estadísticas reseteadas");
            return true;
        }
        
        //--- Botón Cerrar
        if(sparam == m_prefix + "BtnClose") {
            Hide();
            return true;
        }
    }
    return false;
}

//--- Obtener resumen del panel
string CPanel::GetPanelSummary() {
    string summary = "=== PANEL ===\n";
    summary += "Visible: " + (m_isVisible ? "Sí" : "No") + "\n";
    summary += "Posición: (" + IntegerToString(m_x) + ", " + IntegerToString(m_y) + ")\n";
    summary += "Tamaño: " + IntegerToString(m_width) + "x" + IntegerToString(m_height) + "\n";
    summary += "Update Interval: " + IntegerToString(m_updateInterval) + "s\n";
    return summary;
}

#endif // __CPANEL_MQH__