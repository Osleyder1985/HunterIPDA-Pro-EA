//+------------------------------------------------------------------+
//|                                                  CCOExtended.mqh |
//|                       HunterIPDA Pro EA - v1.7 - Módulo Analysis |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo extiende el análisis de COT:                         |
//| - Buy/Sell Hedge Detection                                       |
//| - Hedging Nodule Identification                                  |
//| - COT Extremes Detection                                         |
//| - COT vs Price Divergence                                        |
//| - COT Alignment with Technicals                                  |
//| - COT como filtro para Swing, OSOK, Day Trading                  |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-601: COT Short Format Analysis                              |
//|   RF-602: Buy Program Identification                             |
//|   RF-603: Sell Program Identification                            |
//|   RF-604: Hedging Program Detection                              |
//|   RF-608: Buy Hedge (COT) Detection                              |
//|   RF-609: Sell Hedge (COT) Detection                             |
//|   RF-610: Hedging Nodule Identification                          |
//|   RF-611: COT Extremes Detection                                 |
//|   RF-613: COT vs Price Divergence                                |
//|   RF-614: COT Alignment with Technicals                          |
//|   RF-615: COT as Swing Filter                                    |
//|   RF-616: COT as OSOK Filter                                     |
//|   RF-617: COT as Day Trading Context                             |
//|   RF-618: COT Data Update Automation                             |
//|   RF-619: COT Historical Database                                |
//|   RF-620: COT Logging                                            |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones                       |
//|   - CUtils: Utilidades                                           |
//|   - CConfig: Configuración                                       |
//|   - CCOTAnalyzer: Análisis COT base                              |
//|                                                                  |
//| Versión: 1.1                                                     |
//| Fecha: 23/07/2026                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CHANGELOG                                                        |
//+------------------------------------------------------------------+
//| Versión | Fecha       | Cambio                                   |
//|---------|-------------|------------------------------------------|
//| 1.0     | 22/07/2026  | Versión inicial del módulo               |
//| 1.1     | 23/07/2026  | Corregidos comentarios de todos los       |
//|         |             | métodos siguiendo estructura obligatoria  |
//+------------------------------------------------------------------+

#ifndef __CCOEXTENDED_MQH__
#define __CCOEXTENDED_MQH__

#include "../Core/CConstants.mqh"
#include "../Core/CUtils.mqh"
#include "../Core/CConfig.mqh"
#include "CCOTAnalyzer.mqh"

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct COTExtendedData {
    string           symbol;
    double           commercialNet;
    double           commercialHigh12M;
    double           commercialLow12M;
    double           midPoint;
    bool             isBuyProgram;
    bool             isSellProgram;
    bool             isHedgingProgram;
    double           hedgingNodule;
    ENUM_BIAS        commercialBias;
    bool             isExtreme;
    bool             isDivergence;
    double           buyHedgeLevel;
    double           sellHedgeLevel;
    double           extremeLevel;
    double           divergenceScore;
    datetime         lastUpdate;
};

//+------------------------------------------------------------------+
//| CLASE CCOExtended - Análisis COT Extended                        |
//+------------------------------------------------------------------+
class CCOExtended {
private:
    //--- Referencias
    CConfig*           m_config;
    CUtils*            m_utils;
    CCOTAnalyzer*      m_cotAnalyzer;
    bool               m_isInitialized;
    string             m_symbol;
    string             m_dataPath;
    bool               m_isDataLoaded;
    datetime           m_lastUpdate;
    int                m_updateInterval;
    
    //--- Datos COT Extended
    COTExtendedData    m_currentData;
    COTExtendedData    m_historicalData[];
    int                m_historicalCount;
    
    //--- Estado extendido
    bool               m_isBuyHedge;
    bool               m_isSellHedge;
    double             m_buyHedgeLevel;
    double             m_sellHedgeLevel;
    double             m_hedgingNodule;
    double             m_hedgingNoduleStrength;
    bool               m_isHedgingNoduleActive;
    bool               m_isExtreme;
    double             m_extremeLevel;
    bool               m_isDivergence;
    double             m_divergenceScore;
    ENUM_BIAS          m_commercialBias;
    
    //--- Umbrales
    double             m_significantChangeThreshold;
    double             m_hedgingNoduleThreshold;
    
    //--- Métodos privados
    bool               LoadCOTExtendedData(string symbol);
    bool               LoadCOTDataFromFile(string symbol);
    bool               ParseCOTLine(string line, COTExtendedData &data);
    void               DetectBuyHedge(COTExtendedData &data);
    void               DetectSellHedge(COTExtendedData &data);
    void               DetectHedgingNodule(COTExtendedData &data);
    void               DetectExtremes(COTExtendedData &data);
    void               DetectDivergence(COTExtendedData &data);
    void               UpdateCurrentData(COTExtendedData &data);
    void               GenerateSimulatedData(string symbol);
    double             CalculateHedgingStrength(COTExtendedData &data);
    double             CalculateDivergenceScore(COTExtendedData &data);
    bool               IsSignificantChange(COTExtendedData &data);
    
public:
    //--- Constructor / Destructor
    CCOExtended();
    ~CCOExtended();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils, CCOTAnalyzer* cotAnalyzer);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    bool IsDataLoaded() const { return m_isDataLoaded; }
    
    //--- Métodos Principales
    void Update(string symbol = "");
    void SetSymbol(string symbol);
    bool LoadData(string symbol);
    void Refresh();
    
    //+------------------------------------------------------------------+
    //| RF-608: Buy Hedge (COT) Detection                                |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta cuando los comerciales (smart money) compran             |
    //| agresivamente dentro de un programa de venta (Sell Program).     |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| En la metodología ICT, cuando el mercado está en tendencia       |
    //| bajista (Sell Program), los comerciales aprovechan para          |
    //| acumular posiciones largas. Esto es una "Buy Hedge".            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Los comerciales están acumulando en un mercado bajista  |
    //| - False: No hay señal de acumulación                            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Confirmar entradas largas cuando el precio está en zonas de     |
    //| descuento y los comerciales están comprando (Buy Hedge).        |
    //+------------------------------------------------------------------+
    bool IsBuyHedge() const { return m_isBuyHedge; }
    
    //+------------------------------------------------------------------+
    //| RF-608: Buy Hedge (COT) Detection (por símbolo)                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de la detección de Buy Hedge.                |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsBuyHedge() pero aplicado a un símbolo       |
    //| específico cuando se analizan múltiples instrumentos.            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Buy Hedge detectado para el símbolo                     |
    //| - False: No hay Buy Hedge para el símbolo                       |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar         |
    //| Buy Hedge en instrumentos específicos.                          |
    //+------------------------------------------------------------------+
    bool IsBuyHedgeForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-608: Get Buy Hedge Level                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el nivel (posición neta comercial) donde se detectó      |
    //| la Buy Hedge.                                                    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El nivel de Buy Hedge indica la magnitud de la acumulación       |
    //| de los comerciales. Valores más altos indican mayor              |
    //| convicción en la acumulación.                                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Nivel de Buy Hedge activo                                |
    //| - 0: No hay Buy Hedge activa                                    |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para medir la fuerza de la señal de acumulación.            |
    //+------------------------------------------------------------------+
    double GetBuyHedgeLevel() const { return m_buyHedgeLevel; }
    
    //+------------------------------------------------------------------+
    //| RF-609: Sell Hedge (COT) Detection                               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta cuando los comerciales (smart money) venden              |
    //| agresivamente dentro de un programa de compra (Buy Program).     |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| En la metodología ICT, cuando el mercado está en tendencia       |
    //| alcista (Buy Program), los comerciales aprovechan para           |
    //| distribuir posiciones largas. Esto es una "Sell Hedge".         |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Los comerciales están distribuyendo en mercado alcista  |
    //| - False: No hay señal de distribución                           |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Confirmar entradas cortas cuando el precio está en zonas de     |
    //| prima y los comerciales están vendiendo (Sell Hedge).           |
    //+------------------------------------------------------------------+
    bool IsSellHedge() const { return m_isSellHedge; }
    
    //+------------------------------------------------------------------+
    //| RF-609: Sell Hedge (COT) Detection (por símbolo)                 |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de la detección de Sell Hedge.               |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsSellHedge() pero aplicado a un símbolo      |
    //| específico cuando se analizan múltiples instrumentos.            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Sell Hedge detectado para el símbolo                    |
    //| - False: No hay Sell Hedge para el símbolo                      |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar         |
    //| Sell Hedge en instrumentos específicos.                         |
    //+------------------------------------------------------------------+
    bool IsSellHedgeForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-609: Get Sell Hedge Level                                     |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el nivel (posición neta comercial) donde se detectó      |
    //| la Sell Hedge.                                                   |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El nivel de Sell Hedge indica la magnitud de la distribución     |
    //| de los comerciales. Valores más bajos indican mayor             |
    //| convicción en la distribución.                                   |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Nivel de Sell Hedge activo                               |
    //| - 0: No hay Sell Hedge activa                                   |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para medir la fuerza de la señal de distribución.           |
    //+------------------------------------------------------------------+
    double GetSellHedgeLevel() const { return m_sellHedgeLevel; }
    
    //+------------------------------------------------------------------+
    //| RF-610: Hedging Nodule Identification                            |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta cambios abruptos (>20%) en la posición neta de los       |
    //| comerciales, indicando actividad de cobertura agresiva.          |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los grandes jugadores (comerciales) mueven el mercado en         |
    //| bloques. Cuando cambian de dirección bruscamente, se forma       |
    //| un "nódulo de hedging" que anticipa reversiones.                |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Nódulo activo con valor de posición neta                 |
    //| - 0: No hay nódulo activo                                       |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Activar alertas de reversión y ajustar stops cuando se detecta  |
    //| un nódulo de hedging.                                           |
    //+------------------------------------------------------------------+
    double GetHedgingNodule() const { return m_hedgingNodule; }
    
    //+------------------------------------------------------------------+
    //| RF-610: Get Hedging Nodule Strength                              |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna la fuerza del nódulo de hedging como porcentaje de       |
    //| cambio en la posición neta comercial.                            |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| La fuerza del nódulo indica qué tan agresivo fue el cambio       |
    //| de posición de los comerciales.                                  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 20%: Nódulo fuerte - alta probabilidad de reversión         |
    //| - 10-20%: Nódulo moderado - monitorear                          |
    //| - < 10%: No significativo                                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar junto con GetHedgingNodule() para evaluar la fuerza de     |
    //| la señal de reversión.                                           |
    //+------------------------------------------------------------------+
    double GetHedgingNoduleStrength() const { return m_hedgingNoduleStrength; }
    
    //+------------------------------------------------------------------+
    //| RF-610: Is Hedging Nodule Active                                 |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Indica si el nódulo de hedging actualmente está activo.          |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Un nódulo activo significa que los comerciales están en medio    |
    //| de un cambio agresivo de posición.                               |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Nódulo activo - alerta de reversión                     |
    //| - False: Sin actividad de nódulo                                |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Activar modo de alerta cuando IsHedgingNoduleActive() es true.  |
    //+------------------------------------------------------------------+
    bool IsHedgingNoduleActive() const { return m_isHedgingNoduleActive; }
    
    //+------------------------------------------------------------------+
    //| RF-610: Get Hedging Nodule For Symbol                            |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de GetHedgingNodule().                       |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que GetHedgingNodule() pero para un símbolo       |
    //| específico en análisis multi-símbolo.                            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Nódulo activo para el símbolo                            |
    //| - 0: No hay nódulo para el símbolo                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| nódulos en instrumentos específicos.                            |
    //+------------------------------------------------------------------+
    double GetHedgingNoduleForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-611: COT Extremes Detection                                   |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta cuando la posición neta comercial está en niveles        |
    //| extremos (>90% o <10% del rango de 12 meses).                    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los extremos de COT indican que los comerciales están           |
    //| sobre-comprados (extremo superior) o sobre-vendidos             |
    //| (extremo inferior). Esto suele preceder reversiones.            |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Extremo detectado - posible reversión                  |
    //| - False: Sin extremo - tendencia actual puede continuar         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar como señal de alerta para posible reversión de tendencia.  |
    //| Especialmente útil para OSOK (One Shot One Kill).               |
    //+------------------------------------------------------------------+
    bool IsExtreme() const { return m_isExtreme; }
    
    //+------------------------------------------------------------------+
    //| RF-611: COT Extremes Detection (por símbolo)                     |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de IsExtreme().                              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsExtreme() pero para un símbolo específico.  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Extremo detectado para el símbolo                       |
    //| - False: Sin extremo para el símbolo                            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| extremos en instrumentos específicos.                           |
    //+------------------------------------------------------------------+
    bool IsExtremeForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-611: Get Extreme Level                                        |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el nivel (posición neta comercial) donde se detectó      |
    //| el extremo.                                                      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El nivel extremo indica la magnitud de la sobre-compra o         |
    //| sobre-venta de los comerciales.                                  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Nivel extremo detectado                                  |
    //| - 0: No hay extremo                                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para medir la fuerza de la señal de extremo.                |
    //+------------------------------------------------------------------+
    double GetExtremeLevel() const { return m_extremeLevel; }
    
    //+------------------------------------------------------------------+
    //| RF-611: Get Extreme Bias                                         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el bias (dirección) del extremo detectado.               |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El bias del extremo indica si los comerciales están             |
    //| sobre-comprados (BIAS_BEARISH - esperar bajada) o               |
    //| sobre-vendidos (BIAS_BULLISH - esperar subida).                 |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - BIAS_BULLISH: Extremo inferior - posible subida               |
    //| - BIAS_BEARISH: Extremo superior - posible bajada               |
    //| - BIAS_NEUTRAL: Sin extremo                                     |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar como confirmación para entradas en contra de tendencia.    |
    //+------------------------------------------------------------------+
    ENUM_BIAS GetExtremeBias() const;
    
    //+------------------------------------------------------------------+
    //| RF-613: COT vs Price Divergence                                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Detecta divergencia entre la dirección del precio y la           |
    //| dirección de la posición neta comercial.                         |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Cuando el precio sube pero los comerciales venden (o viceversa), |
    //| hay divergencia. Esto indica que el movimiento actual no tiene   |
    //| el respaldo de los grandes jugadores y puede revertirse.         |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Divergencia detectada - posible reversión               |
    //| - False: Sin divergencia - tendencia alineada con comerciales   |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar como señal de advertencia para evitar entrar en            |
    //| direcciones que no tienen respaldo institucional.               |
    //+------------------------------------------------------------------+
    bool IsDivergence() const { return m_isDivergence; }
    
    //+------------------------------------------------------------------+
    //| RF-613: COT vs Price Divergence (por símbolo)                    |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de IsDivergence().                           |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsDivergence() pero para un símbolo           |
    //| específico.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Divergencia detectada para el símbolo                   |
    //| - False: Sin divergencia para el símbolo                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| divergencias en instrumentos específicos.                       |
    //+------------------------------------------------------------------+
    bool IsDivergenceForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-613: Get Divergence Score                                     |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna un score (0-100) que mide la fuerza de la divergencia.   |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El score de divergencia combina la magnitud del cambio de        |
    //| precio y el cambio en COT para dar una medida de la fuerza       |
    //| de la señal.                                                     |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 60: Divergencia fuerte - alta probabilidad de reversión     |
    //| - 40-60: Divergencia moderada                                   |
    //| - < 40: Divergencia débil o sin divergencia                     |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para priorizar señales de divergencia según su fuerza.     |
    //+------------------------------------------------------------------+
    double GetDivergenceScore() const { return m_divergenceScore; }
    
    //+------------------------------------------------------------------+
    //| RF-614: COT Alignment with Technicals                            |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica si el bias del COT está alineado con un bias técnico   |
    //| proporcionado.                                                   |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| La alineación entre COT y análisis técnico es un filtro          |
    //| de alta probabilidad. Si ambos apuntan en la misma dirección,    |
    //| la señal es más fuerte.                                          |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: COT alineado con el bias técnico                        |
    //| - False: No hay alineación                                      |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar como filtro para todas las señales de trading.             |
    //| Ejecutar trades SOLO cuando IsAligned(bias) == true.            |
    //+------------------------------------------------------------------+
    bool IsAligned(ENUM_BIAS bias) const;
    
    //+------------------------------------------------------------------+
    //| RF-614: COT Alignment with Technicals (por símbolo)              |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de IsAligned().                              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsAligned() pero para un símbolo específico.  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: COT alineado para el símbolo                            |
    //| - False: No hay alineación para el símbolo                      |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| alineación en instrumentos específicos.                         |
    //+------------------------------------------------------------------+
    bool IsAlignedForSymbol(string symbol, ENUM_BIAS bias);
    
    //+------------------------------------------------------------------+
    //| RF-614: Get Alignment Score                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna un score (0-100) que mide la fuerza de la alineación.    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El score de alineación combina el bias, extremos, nódulos y      |
    //| divergencias para dar una medida de confianza.                   |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 70: Alineación fuerte - alta probabilidad                   |
    //| - 50-70: Alineación moderada                                    |
    //| - < 50: Alineación débil - evitar trades                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para priorizar señales según su fortaleza de alineación.   |
    //+------------------------------------------------------------------+
    double GetAlignmentScore(ENUM_BIAS bias) const;
    
    //+------------------------------------------------------------------+
    //| RF-615: COT as Swing Filter                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Valida si el contexto COT actual es favorable para Swing Trading.|
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los Swing Trades requieren alineación con los grandes jugadores. |
    //| Un bias fuerte y no extremo indica que los comerciales          |
    //| están posicionados para un movimiento sostenido.                |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Contexto favorable para Swing Trading                   |
    //| - False: Contexto desfavorable - evitar Swing Trades            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Ejecutar Swing Trades SOLO cuando IsSwingValid() == true.       |
    //| Es un filtro obligatorio antes de cualquier Swing Trade.        |
    //+------------------------------------------------------------------+
    bool IsSwingValid() const;
    
    //+------------------------------------------------------------------+
    //| RF-615: COT as Swing Filter (por símbolo)                        |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de IsSwingValid().                           |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsSwingValid() pero para un símbolo           |
    //| específico.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Swing válido para el símbolo                            |
    //| - False: Swing no válido para el símbolo                        |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| validez de Swing en instrumentos específicos.                   |
    //+------------------------------------------------------------------+
    bool IsSwingValidForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-616: COT as OSOK Filter                                       |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Valida si el contexto COT actual es favorable para OSOK          |
    //| (One Shot One Kill).                                             |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| OSOK requiere condiciones extremas: los comerciales deben       |
    //| estar en niveles extremos y alineados con la dirección del       |
    //| trade. Sin divergencia para asegurar que el movimiento           |
    //| tiene respaldo institucional.                                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Contexto favorable para OSOK                            |
    //| - False: Contexto desfavorable - evitar OSOK                    |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Ejecutar OSOK SOLO cuando IsOSOKValid() == true. Es un          |
    //| filtro obligatorio para el modelo OSOK.                         |
    //+------------------------------------------------------------------+
    bool IsOSOKValid() const;
    
    //+------------------------------------------------------------------+
    //| RF-616: COT as OSOK Filter (por símbolo)                         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de IsOSOKValid().                            |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que IsOSOKValid() pero para un símbolo            |
    //| específico.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: OSOK válido para el símbolo                             |
    //| - False: OSOK no válido para el símbolo                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita verificar        |
    //| validez de OSOK en instrumentos específicos.                    |
    //+------------------------------------------------------------------+
    bool IsOSOKValidForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-617: COT as Day Trading Context                               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el bias del COT para usar como contexto en Day Trading.  |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Day Trading requiere contexto general del mercado. El bias       |
    //| del COT indica la dirección general que los comerciales         |
    //| están siguiendo.                                                 |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - BIAS_BULLISH: Contexto alcista                                |
    //| - BIAS_BEARISH: Contexto bajista                                |
    //| - BIAS_NEUTRAL: Sin contexto claro                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar como filtro de contexto para Day Trading. Operar en        |
    //| la dirección del bias general.                                   |
    //+------------------------------------------------------------------+
    ENUM_BIAS GetDayTradingContext() const;
    
    //+------------------------------------------------------------------+
    //| RF-617: COT as Day Trading Context (por símbolo)                 |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Versión por símbolo de GetDayTradingContext().                   |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que GetDayTradingContext() pero para un símbolo   |
    //| específico.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - BIAS_BULLISH: Contexto alcista para el símbolo                |
    //| - BIAS_BEARISH: Contexto bajista para el símbolo                |
    //| - BIAS_NEUTRAL: Sin contexto claro para el símbolo              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita contexto         |
    //| específico por instrumento.                                     |
    //+------------------------------------------------------------------+
    ENUM_BIAS GetDayTradingContextForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| RF-618: COT Data Update Automation                               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Actualiza automáticamente los datos COT si ha pasado el          |
    //| intervalo configurado.                                           |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los datos COT se publican semanalmente. El EA debe               |
    //| actualizarlos automáticamente para mantener la información       |
    //| actualizada.                                                     |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - Ejecuta LoadData() si es necesario                            |
    //| - No retorna valor                                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Llamar en OnInit() y periódicamente para mantener datos         |
    //| COT actualizados.                                               |
    //+------------------------------------------------------------------+
    void AutoUpdate();
    
    //+------------------------------------------------------------------+
    //| RF-618: Is Update Needed                                         |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Verifica si los datos COT necesitan actualización.               |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Los datos COT se actualizan semanalmente. Si han pasado más      |
    //| de 7 días desde la última actualización, es necesario            |
    //| actualizar.                                                      |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - True: Se necesita actualización                                |
    //| - False: Datos actualizados                                      |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar antes de llamar a AutoUpdate() para evitar                 |
    //| actualizaciones innecesarias.                                    |
    //+------------------------------------------------------------------+
    bool IsUpdateNeeded() const;
    
    //+------------------------------------------------------------------+
    //| RF-618: Set Update Interval                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Configura el intervalo de actualización en días.                 |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Por defecto, los datos COT se actualizan semanalmente (7 días).  |
    //| Este método permite ajustar el intervalo según preferencias.     |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - No retorna valor                                              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Configurar según la frecuencia de publicación de datos COT.     |
    //+------------------------------------------------------------------+
    void SetUpdateInterval(int days);
    
    //+------------------------------------------------------------------+
    //| RF-619: COT Historical Database                                  |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el número de entradas históricas en la base de datos.    |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El historial de COT permite analizar tendencias y patrones       |
    //| en el posicionamiento de los comerciales.                        |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Número de entradas históricas                            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para análisis de tendencias y cálculos de promedios.       |
    //+------------------------------------------------------------------+
    int GetHistoricalCount() const { return m_historicalCount; }
    
    //+------------------------------------------------------------------+
    //| RF-619: Get Historical Data                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna una entrada histórica específica por índice.             |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Permite acceder a datos históricos de COT para análisis         |
    //| de tendencias y comparaciones.                                   |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - COTExtendedData: Datos históricos en el índice                |
    //| - Estructura vacía: Índice inválido                             |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para análisis de tendencias y cálculos de promedios.       |
    //+------------------------------------------------------------------+
    COTExtendedData GetHistoricalData(int index) const;
    
    //+------------------------------------------------------------------+
    //| RF-619: Get Historical Average                                   |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Calcula el promedio de la posición neta comercial en los         |
    //| últimos N períodos.                                              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El promedio histórico permite identificar si la posición         |
    //| actual es atípica o está dentro de la norma.                    |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - > 0: Promedio de los últimos N períodos                       |
    //| - 0: No hay datos suficientes                                   |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para identificar desviaciones significativas de la         |
    //| posición promedio.                                              |
    //+------------------------------------------------------------------+
    double GetHistoricalAverage(int periods) const;
    
    //+------------------------------------------------------------------+
    //| RF-620: COT Logging                                              |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un log detallado del estado actual del COT.              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El logging de COT permite auditar y analizar las decisiones      |
    //| basadas en datos de posicionamiento.                             |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - string: Log formateado con todos los datos COT                |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para depuración, auditoría y análisis posterior.           |
    //+------------------------------------------------------------------+
    string GetCOTLog();
    
    //+------------------------------------------------------------------+
    //| RF-620: COT Logging (por símbolo)                                |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un log detallado del estado COT para un símbolo           |
    //| específico.                                                      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Mismo concepto que GetCOTLog() pero para un símbolo específico.  |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - string: Log formateado con datos COT del símbolo              |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para análisis multi-símbolo cuando se necesita log específico   |
    //| por instrumento.                                                 |
    //+------------------------------------------------------------------+
    string GetCOTLogForSymbol(string symbol);
    
    //+------------------------------------------------------------------+
    //| Getters                                                          |
    //+------------------------------------------------------------------+
    //| RF-601-604: Obtener símbolo actual                               |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna el símbolo que se está analizando actualmente.           |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| El análisis COT se realiza por símbolo.                          |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - string: Símbolo actual (ej: "EURUSD")                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para saber qué instrumento se está analizando.                   |
    //+------------------------------------------------------------------+
    string GetSymbol() const { return m_symbol; }
    
    //+------------------------------------------------------------------+
    //| RF-618: Obtener última actualización                             |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Retorna la fecha y hora de la última actualización de datos.     |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Permite saber si los datos COT están actualizados.               |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - datetime: Fecha y hora de la última actualización             |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para verificar si los datos están actualizados antes de usar.   |
    //+------------------------------------------------------------------+
    datetime GetLastUpdate() const { return m_lastUpdate; }
    
    //+------------------------------------------------------------------+
    //| RF-620: Get COT Summary                                          |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un resumen conciso del estado COT Extended.               |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Resumen rápido de los datos más relevantes para tomar            |
    //| decisiones de trading.                                           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - string: Resumen formateado                                    |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Para visualización rápida en el panel de control.               |
    //+------------------------------------------------------------------+
    string GetCOTSummary();
    
    //+------------------------------------------------------------------+
    //| RF-620: Get COT Report                                           |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un reporte detallado con todos los datos COT Extended     |
    //| para el símbolo actual. Incluye posición neta, rangos de 12M,    |
    //| niveles de hedge, extremos, nódulos y divergencias.              |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Este reporte consolida toda la información de COT Extended en    |
    //| un solo lugar para facilitar el análisis rápido. Permite         |
    //| visualizar de un vistazo el posicionamiento de los comerciales   |
    //| y detectar señales de reversión.                                 |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - Commercial Net: Posición neta de comerciales                  |
    //| - 12M High/Low: Rango de 12 meses para detectar extremos        |
    //| - Mid Point: Nueva línea cero (punto medio del rango)           |
    //| - Buy/Sell Hedge Level: Niveles de cobertura detectados         |
    //| - Hedging Nodule: Cambio abrupto >20%                           |
    //| - Divergence Score: Fuerza de la divergencia (0-100)            |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para análisis rápido de COT en el panel de control o        |
    //| para depuración. El reporte se puede exportar para análisis     |
    //| fuera de MetaTrader.                                            |
    //+------------------------------------------------------------------+
    string GetCOTReport();
    
    //+------------------------------------------------------------------+
    //| RF-620: Get Extended Report                                      |
    //+------------------------------------------------------------------+
    //| DESCRIPCIÓN:                                                      |
    //| Genera un reporte extendido con análisis adicionales:            |
    //| - Swing validity                                                |
    //| - OSOK validity                                                  |
    //| - Day Trading context                                            |
    //| - Alignment scores por bias                                      |
    //|                                                                  |
    //| CONTEXTO ICT:                                                    |
    //| Este reporte va más allá de los datos brutos y proporciona       |
    //| interpretaciones directas para cada modelo de trading.           |
    //|                                                                  |
    //| SEÑAL:                                                           |
    //| - Swing Valid: true/false para Swing Trading                    |
    //| - OSOK Valid: true/false para OSOK                              |
    //| - Day Trading Context: Bias para Day Trading                    |
    //| - Alignment Score: 0-100 para cada bias                         |
    //|                                                                  |
    //| USO PRÁCTICO:                                                    |
    //| Usar para validar rápidamente si el contexto COT soporta        |
    //| cada modelo de trading antes de ejecutar señales.               |
    //+------------------------------------------------------------------+
    string GetExtendedReport();
};

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Inicializa todas las variables del módulo con valores por         |
//| defecto.                                                          |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Preparación del módulo para su uso.                              |
//|                                                                  |
//| SEÑAL:                                                           |
//| - No retorna valor                                              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado automáticamente al crear una instancia.                  |
//+------------------------------------------------------------------+
CCOExtended::CCOExtended() {
    m_config = NULL;
    m_utils = NULL;
    m_cotAnalyzer = NULL;
    m_isInitialized = false;
    m_symbol = "";
    m_dataPath = "";
    m_isDataLoaded = false;
    m_lastUpdate = 0;
    m_updateInterval = 7;
    m_historicalCount = 0;
    m_isBuyHedge = false;
    m_isSellHedge = false;
    m_buyHedgeLevel = 0;
    m_sellHedgeLevel = 0;
    m_hedgingNodule = 0;
    m_hedgingNoduleStrength = 0;
    m_isHedgingNoduleActive = false;
    m_isExtreme = false;
    m_extremeLevel = 0;
    m_isDivergence = false;
    m_divergenceScore = 0;
    m_commercialBias = BIAS_NEUTRAL;
    m_significantChangeThreshold = 15.0;
    m_hedgingNoduleThreshold = 20.0;
    ArrayResize(m_historicalData, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Libera los recursos utilizados por el módulo.                    |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Limpieza al finalizar el uso del módulo.                         |
//|                                                                  |
//| SEÑAL:                                                           |
//| - No retorna valor                                              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado automáticamente al destruir la instancia.                |
//+------------------------------------------------------------------+
CCOExtended::~CCOExtended() {
    Deinit();
}

//+------------------------------------------------------------------+
//| RF-601-604: Inicialización del módulo                            |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Inicializa el módulo COT Extended con configuración, utilidades   |
//| y referencia al analizador COT base.                             |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Este módulo extiende el análisis COT base con funcionalidades    |
//| avanzadas como detección de hedges, nódulos y extremos.          |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - config: Objeto de configuración del EA                         |
//| - utils: Objeto de utilidades                                    |
//| - cotAnalyzer: Referencia al analizador COT base                 |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: Inicialización exitosa                                   |
//| - false: Error de inicialización                                 |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamar en OnInit() después de inicializar el analizador COT.     |
//+------------------------------------------------------------------+
bool CCOExtended::Init(CConfig* config, CUtils* utils, CCOTAnalyzer* cotAnalyzer) {
    if(config == NULL || utils == NULL || cotAnalyzer == NULL) {
        Print("CCOExtended::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    m_cotAnalyzer = cotAnalyzer;
    
    //--- Establecer ruta de datos
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_dataPath = terminalPath + "\\MQL5\\Files\\COT_Extended_Data\\";
    FolderCreate(m_dataPath);
    
    m_isInitialized = true;
    m_utils.LogInfo("CCOExtended inicializado correctamente");
    return true;
}

//+------------------------------------------------------------------+
//| Desinicialización                                                 |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Libera los recursos y limpia el estado del módulo.               |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Limpieza al finalizar el uso.                                    |
//|                                                                  |
//| SEÑAL:                                                           |
//| - No retorna valor                                              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamar en OnDeinit() o al destruir el EA.                        |
//+------------------------------------------------------------------+
void CCOExtended::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_cotAnalyzer = NULL;
    m_isInitialized = false;
    ArrayResize(m_historicalData, 0);
}

//+------------------------------------------------------------------+
//| RF-601-604: Establecer símbolo                                   |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Cambia el símbolo actual y carga sus datos COT Extended.          |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Cada símbolo tiene sus propios datos COT. Este método permite    |
//| cambiar el análisis a otro instrumento.                          |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar en análisis multi-símbolo para cambiar el foco.             |
//+------------------------------------------------------------------+
void CCOExtended::SetSymbol(string symbol) {
    if(symbol != m_symbol) {
        m_symbol = symbol;
        if(m_isInitialized) {
            LoadData(symbol);
        }
    }
}

//+------------------------------------------------------------------+
//| RF-618: Cargar datos COT Extended                                |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Carga datos COT Extended desde archivo o genera datos            |
//| simulados si no están disponibles.                               |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos COT Extended se cargan desde archivos CSV generados    |
//| por el analizador COT base. Si no existen, se generan datos      |
//| simulados para pruebas.                                          |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a cargar                                      |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: Datos cargados correctamente                             |
//| - false: Error al cargar datos                                   |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamar en Update() o AutoUpdate() para mantener datos           |
//| actualizados.                                                    |
//+------------------------------------------------------------------+
bool CCOExtended::LoadData(string symbol) {
    if(!m_isInitialized) return false;
    
    m_symbol = symbol;
    m_isDataLoaded = LoadCOTExtendedData(symbol);
    
    if(m_isDataLoaded) {
        m_lastUpdate = TimeCurrent();
        m_utils.LogInfo("COT Extended data loaded for " + symbol);
    } else {
        m_utils.LogWarning("COT Extended data not available for " + symbol + " - using simulated data");
        GenerateSimulatedData(symbol);
        m_isDataLoaded = true;
        m_lastUpdate = TimeCurrent();
    }
    
    return m_isDataLoaded;
}

//+------------------------------------------------------------------+
//| RF-618: Cargar datos COT Extended                                |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Intenta cargar datos COT Extended desde archivo. Si falla,       |
//| retorna false para que LoadData() genere datos simulados.        |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos COT Extended se almacenan en archivos CSV.             |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a cargar                                      |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: Datos cargados correctamente                             |
//| - false: No se pudo cargar desde archivo                         |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por LoadData().                             |
//+------------------------------------------------------------------+
bool CCOExtended::LoadCOTExtendedData(string symbol) {
    if(LoadCOTDataFromFile(symbol)) {
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| RF-618: Cargar datos desde archivo CSV                           |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Carga datos COT Extended desde un archivo CSV en la carpeta      |
//| de datos de MetaTrader.                                          |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos COT se actualizan semanalmente. El EA los carga        |
//| desde archivos CSV para análisis sin necesidad de conexión       |
//| externa constante.                                               |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a cargar (ej: "EURUSD")                        |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: Datos cargados correctamente                             |
//| - false: Error al cargar (archivo no existe o corrupto)          |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por LoadCOTExtendedData().                  |
//+------------------------------------------------------------------+
bool CCOExtended::LoadCOTDataFromFile(string symbol) {
    string fileName = m_dataPath + "COT_Extended_" + symbol + ".csv";
    if(!FileIsExist(fileName)) return false;
    
    int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
    if(handle == INVALID_HANDLE) return false;
    
    bool dataFound = false;
    while(!FileIsEnding(handle)) {
        string line = FileReadString(handle);
        if(line != "") {
            COTExtendedData data;
            if(ParseCOTLine(line, data)) {
                UpdateCurrentData(data);
                dataFound = true;
            }
        }
    }
    
    FileClose(handle);
    return dataFound;
}

//+------------------------------------------------------------------+
//| RF-618: Parsear línea CSV                                        |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Parsea una línea del archivo CSV y la convierte en una           |
//| estructura COTExtendedData.                                      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| El formato CSV contiene: symbol,commercialNet,commercialHigh12M, |
//| commercialLow12M,midPoint,isBuyProgram,isSellProgram,lastUpdate  |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - line: Línea del archivo CSV                                    |
//| - data: Estructura donde se almacenará el resultado             |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: Línea parseada correctamente                             |
//| - false: Error al parsear (formato incorrecto)                   |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por LoadCOTDataFromFile().                  |
//+------------------------------------------------------------------+
bool CCOExtended::ParseCOTLine(string line, COTExtendedData &data) {
    string parts[];
    int count = StringSplit(line, ',', parts);
    
    if(count < 8) return false;
    
    data.symbol = parts[0];
    data.commercialNet = StringToDouble(parts[1]);
    data.commercialHigh12M = StringToDouble(parts[2]);
    data.commercialLow12M = StringToDouble(parts[3]);
    data.midPoint = StringToDouble(parts[4]);
    data.isBuyProgram = StringToInteger(parts[5]) > 0;
    data.isSellProgram = StringToInteger(parts[6]) > 0;
    data.lastUpdate = (datetime)StringToInteger(parts[7]);
    
    data.isHedgingProgram = data.isBuyProgram && data.isSellProgram;
    data.commercialBias = data.commercialNet > data.midPoint ? BIAS_BULLISH : BIAS_BEARISH;
    
    return true;
}

//+------------------------------------------------------------------+
//| RF-618: Generar datos simulados                                  |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera datos COT Extended simulados cuando no hay archivo        |
//| disponible. Usa datos de CCOTAnalyzer si están disponibles       |
//| o genera datos pseudo-aleatorios basados en el símbolo.          |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos simulados permiten probar el EA sin necesidad de       |
//| datos COT reales.                                                |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo para el cual se generan datos                  |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por LoadData() cuando no hay archivo.       |
//+------------------------------------------------------------------+
void CCOExtended::GenerateSimulatedData(string symbol) {
    COTExtendedData data;
    data.symbol = symbol;
    data.lastUpdate = TimeCurrent();
    
    //--- Usar datos de CCOTAnalyzer si están disponibles
    if(m_cotAnalyzer != NULL && m_cotAnalyzer.IsDataLoaded()) {
        data.commercialNet = m_cotAnalyzer.GetCommercialNet();
        data.commercialHigh12M = data.commercialNet * 2.0;
        data.commercialLow12M = data.commercialNet * 0.0;
        data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
        data.isBuyProgram = m_cotAnalyzer.IsBuyProgram();
        data.isSellProgram = m_cotAnalyzer.IsSellProgram();
    } else {
        //--- Generar datos pseudo-aleatorios basados en el símbolo
        int hash = 0;
        for(int i = 0; i < StringLen(symbol); i++) {
            hash += StringGetCharacter(symbol, i);
        }
        
        double seed = (hash % 100) / 100.0;
        double random = MathSin(seed * 1000) * 50 + 50;
        data.commercialNet = (random - 50) * 3000;
        data.commercialHigh12M = data.commercialNet * 2.0;
        data.commercialLow12M = data.commercialNet * 0.0;
        data.midPoint = (data.commercialHigh12M + data.commercialLow12M) / 2.0;
        data.isBuyProgram = data.commercialNet > data.midPoint;
        data.isSellProgram = data.commercialNet < data.midPoint;
    }
    
    data.isHedgingProgram = data.isBuyProgram && data.isSellProgram;
    data.commercialBias = data.commercialNet > data.midPoint ? BIAS_BULLISH : BIAS_BEARISH;
    data.hedgingNodule = 0;
    data.isExtreme = false;
    data.isDivergence = false;
    data.buyHedgeLevel = 0;
    data.sellHedgeLevel = 0;
    data.extremeLevel = 0;
    data.divergenceScore = 0;
    
    UpdateCurrentData(data);
}

//+------------------------------------------------------------------+
//| RF-608-613: Actualizar datos actuales                            |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Actualiza los datos actuales y ejecuta todas las detecciones:    |
//| - Buy Hedge (RF-608)                                             |
//| - Sell Hedge (RF-609)                                            |
//| - Hedging Nodule (RF-610)                                        |
//| - Extremes (RF-611)                                              |
//| - Divergence (RF-613)                                            |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Este método centraliza todas las detecciones en un solo lugar.   |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a procesar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente después de cargar o actualizar datos.       |
//+------------------------------------------------------------------+
void CCOExtended::UpdateCurrentData(COTExtendedData &data) {
    m_currentData = data;
    m_commercialBias = data.commercialBias;
    
    //--- RF-608: Buy Hedge
    DetectBuyHedge(data);
    
    //--- RF-609: Sell Hedge
    DetectSellHedge(data);
    
    //--- RF-610: Hedging Nodule
    DetectHedgingNodule(data);
    
    //--- RF-611: Extremes
    DetectExtremes(data);
    
    //--- RF-613: Divergence
    DetectDivergence(data);
    
    //--- Guardar en histórico
    int idx = m_historicalCount;
    ArrayResize(m_historicalData, m_historicalCount + 1);
    m_historicalData[idx] = data;
    m_historicalCount++;
    
    m_lastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| RF-608: Detectar Buy Hedge                                       |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Detecta compras agresivas de comerciales dentro de un programa   |
//| de venta (Sell Program).                                         |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Buy Hedge = Sell Program + Commercial Net > Mid Point            |
//| Indica acumulación en mercado bajista.                           |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void (actualiza m_isBuyHedge y m_buyHedgeLevel)               |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por UpdateCurrentData().                    |
//+------------------------------------------------------------------+
void CCOExtended::DetectBuyHedge(COTExtendedData &data) {
    //--- Buy Hedge: dentro de Sell Program, compra agresiva
    m_isBuyHedge = data.isSellProgram && data.commercialNet > data.midPoint;
    
    if(m_isBuyHedge) {
        m_buyHedgeLevel = data.commercialNet;
        data.buyHedgeLevel = m_buyHedgeLevel;
    } else {
        m_buyHedgeLevel = 0;
        data.buyHedgeLevel = 0;
    }
}

//+------------------------------------------------------------------+
//| RF-608: Buy Hedge (por símbolo) - Placeholder                    |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de la detección de Buy Hedge.               |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsBuyHedge() pero para un símbolo específico. |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsBuyHedgeForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-609: Detectar Sell Hedge                                      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Detecta ventas agresivas de comerciales dentro de un programa    |
//| de compra (Buy Program).                                         |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Sell Hedge = Buy Program + Commercial Net < Mid Point           |
//| Indica distribución en mercado alcista.                          |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void (actualiza m_isSellHedge y m_sellHedgeLevel)             |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por UpdateCurrentData().                    |
//+------------------------------------------------------------------+
void CCOExtended::DetectSellHedge(COTExtendedData &data) {
    //--- Sell Hedge: dentro de Buy Program, venta agresiva
    m_isSellHedge = data.isBuyProgram && data.commercialNet < data.midPoint;
    
    if(m_isSellHedge) {
        m_sellHedgeLevel = data.commercialNet;
        data.sellHedgeLevel = m_sellHedgeLevel;
    } else {
        m_sellHedgeLevel = 0;
        data.sellHedgeLevel = 0;
    }
}

//+------------------------------------------------------------------+
//| RF-609: Sell Hedge (por símbolo) - Placeholder                   |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de la detección de Sell Hedge.              |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsSellHedge() pero para un símbolo específico.|
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsSellHedgeForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-610: Detectar Nódulo de Hedging                               |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Detecta cambios abruptos (>umbral) en la posición neta comercial.|
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Un nódulo de hedging indica que los comerciales están cambiando  |
//| de posición agresivamente, lo que suele preceder reversiones.    |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void (actualiza m_hedgingNodule, m_hedgingNoduleStrength,     |
//|   m_isHedgingNoduleActive)                                       |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por UpdateCurrentData().                    |
//+------------------------------------------------------------------+
void CCOExtended::DetectHedgingNodule(COTExtendedData &data) {
    //--- Nódulo: cambio abrupto en posición neta
    if(m_historicalCount < 2) {
        m_isHedgingNoduleActive = false;
        m_hedgingNodule = 0;
        m_hedgingNoduleStrength = 0;
        data.hedgingNodule = 0;
        return;
    }
    
    COTExtendedData prev = m_historicalData[m_historicalCount - 1];
    double change = MathAbs(data.commercialNet - prev.commercialNet);
    double avg = MathAbs(data.commercialNet + prev.commercialNet) / 2.0;
    
    if(avg > 0) {
        double changePct = change / avg * 100;
        m_hedgingNoduleStrength = changePct;
        m_isHedgingNoduleActive = changePct > m_hedgingNoduleThreshold;
        
        if(m_isHedgingNoduleActive) {
            m_hedgingNodule = data.commercialNet;
            data.hedgingNodule = m_hedgingNodule;
        } else {
            m_hedgingNodule = 0;
            data.hedgingNodule = 0;
        }
    }
}

//+------------------------------------------------------------------+
//| RF-610: Get Hedging Nodule (por símbolo) - Placeholder           |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de GetHedgingNodule().                       |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que GetHedgingNodule() pero para un símbolo       |
//| específico.                                                      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - 0: Placeholder - implementar para multi-símbolo               |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
double CCOExtended::GetHedgingNoduleForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return 0;
}

//+------------------------------------------------------------------+
//| RF-611: Detectar Extremos                                        |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Detecta cuando la posición neta comercial está en niveles        |
//| extremos (>90% o <10% del rango de 12 meses).                    |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los extremos de COT indican sobre-compra o sobre-venta extrema   |
//| de los comerciales, lo que suele preceder reversiones.           |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void (actualiza m_isExtreme, m_extremeLevel, data.isExtreme,  |
//|   data.extremeLevel)                                             |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por UpdateCurrentData().                    |
//+------------------------------------------------------------------+
void CCOExtended::DetectExtremes(COTExtendedData &data) {
    double range = data.commercialHigh12M - data.commercialLow12M;
    if(range == 0) {
        m_isExtreme = false;
        m_extremeLevel = 0;
        data.isExtreme = false;
        data.extremeLevel = 0;
        return;
    }
    
    double position = (data.commercialNet - data.commercialLow12M) / range;
    m_isExtreme = position > 0.9 || position < 0.1;
    
    if(m_isExtreme) {
        m_extremeLevel = data.commercialNet;
        data.extremeLevel = m_extremeLevel;
    } else {
        m_extremeLevel = 0;
        data.extremeLevel = 0;
    }
    
    data.isExtreme = m_isExtreme;
}

//+------------------------------------------------------------------+
//| RF-611: Is Extreme (por símbolo) - Placeholder                   |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de IsExtreme().                              |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsExtreme() pero para un símbolo específico.  |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsExtremeForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-611: Get Extreme Bias                                         |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Retorna el bias (dirección) del extremo detectado.               |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| - BIAS_BULLISH: Extremo inferior (sobre-venta) → posible subida  |
//| - BIAS_BEARISH: Extremo superior (sobre-compra) → posible bajada |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - Ninguno                                                        |
//|                                                                  |
//| RETORNO:                                                          |
//| - BIAS_BULLISH: Extremo inferior                                |
//| - BIAS_BEARISH: Extremo superior                                |
//| - BIAS_NEUTRAL: No hay extremo                                  |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para confirmar entradas en contra de tendencia.             |
//+------------------------------------------------------------------+
ENUM_BIAS CCOExtended::GetExtremeBias() const {
    if(!m_isExtreme) return BIAS_NEUTRAL;
    return m_commercialBias;
}

//+------------------------------------------------------------------+
//| RF-613: Detectar Divergencia                                     |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Detecta divergencia entre precio y posición neta comercial.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Divergencia = precio y COT van en direcciones opuestas.          |
//| Indica que el movimiento actual no tiene respaldo institucional. |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - void (actualiza m_divergenceScore, m_isDivergence,            |
//|   data.isDivergence, data.divergenceScore)                       |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por UpdateCurrentData().                    |
//+------------------------------------------------------------------+
void CCOExtended::DetectDivergence(COTExtendedData &data) {
    m_divergenceScore = CalculateDivergenceScore(data);
    m_isDivergence = m_divergenceScore > 60;
    data.isDivergence = m_isDivergence;
    data.divergenceScore = m_divergenceScore;
}

//+------------------------------------------------------------------+
//| RF-613: Calcular Divergence Score                                |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Calcula un score (0-100) que mide la fuerza de la divergencia.   |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Combina la magnitud del cambio de precio y el cambio en COT.     |
//| Score > 60 = divergencia fuerte.                                 |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - data: Datos COT a analizar                                     |
//|                                                                  |
//| RETORNO:                                                          |
//| - double: Score de divergencia (0-100)                          |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamado internamente por DetectDivergence().                     |
//+------------------------------------------------------------------+
double CCOExtended::CalculateDivergenceScore(COTExtendedData &data) {
    double currentPrice = SymbolInfoDouble(data.symbol, SYMBOL_BID);
    double price20 = iClose(data.symbol, PERIOD_D1, 20);
    
    if(price20 == 0) return 0;
    
    double priceChange = (currentPrice - price20) / price20 * 100;
    double cotChange = 0;
    
    if(m_historicalCount > 0) {
        double prevNet = m_historicalData[m_historicalCount - 1].commercialNet;
        if(prevNet != 0) {
            cotChange = (data.commercialNet - prevNet) / MathAbs(prevNet) * 100;
        }
    }
    
    //--- Divergencia si precio y COT van en direcciones opuestas
    bool priceUp = priceChange > 1.0;
    bool cotUp = cotChange > 5.0;
    
    if(priceUp != cotUp) {
        return MathMin(MathAbs(priceChange) + MathAbs(cotChange) * 2, 100);
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| RF-613: Is Divergence (por símbolo) - Placeholder                |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de IsDivergence().                           |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsDivergence() pero para un símbolo           |
//| específico.                                                      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsDivergenceForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-614: COT Alignment with Technicals                            |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Verifica si el bias del COT está alineado con un bias técnico.   |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Alineación = COT bias == bias técnico.                          |
//| Filtro de alta probabilidad para todas las señales.              |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - bias: Bias técnico a verificar                                 |
//|                                                                  |
//| RETORNO:                                                          |
//| - true: COT alineado con el bias técnico                        |
//| - false: No hay alineación                                      |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar como filtro para todas las señales de trading.              |
//| Ejecutar trades SOLO cuando IsAligned(bias) == true.             |
//+------------------------------------------------------------------+
bool CCOExtended::IsAligned(ENUM_BIAS bias) const {
    return m_commercialBias == bias;
}

//+------------------------------------------------------------------+
//| RF-614: Is Aligned (por símbolo) - Placeholder                   |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de IsAligned().                              |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsAligned() pero para un símbolo específico.  |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//| - bias: Bias técnico a verificar                                 |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsAlignedForSymbol(string symbol, ENUM_BIAS bias) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-614: Get Alignment Score                                      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Retorna un score (0-100) que mide la fuerza de la alineación.    |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Score base 50 + extremo (+20) + nódulo activo (+15) -           |
//| divergencia (-20).                                               |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - bias: Bias para el cual se calcula el score                   |
//|                                                                  |
//| RETORNO:                                                          |
//| - double: Score de alineación (0-100)                           |
//| - 0: Si el bias no coincide                                      |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para priorizar señales según su fortaleza de alineación.    |
//+------------------------------------------------------------------+
double CCOExtended::GetAlignmentScore(ENUM_BIAS bias) const {
    if(m_commercialBias != bias) return 0;
    
    double score = 50;
    if(m_isExtreme) score += 20;
    if(m_isHedgingNoduleActive) score += 15;
    if(m_isDivergence) score -= 20;
    
    return MathMax(0, MathMin(100, score));
}

//+------------------------------------------------------------------+
//| RF-615: COT as Swing Filter                                      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Valida si el contexto COT actual es favorable para Swing Trading.|
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Swing requiere bias fuerte y no extremo.                         |
//|                                                                  |
//| SEÑAL:                                                           |
//| - True: Contexto favorable para Swing Trading                   |
//| - False: Contexto desfavorable - evitar Swing Trades            |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Ejecutar Swing Trades SOLO cuando IsSwingValid() == true.        |
//| Es un filtro obligatorio antes de cualquier Swing Trade.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsSwingValid() const {
    //--- Swing requiere bias fuerte y no extremo
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    return !m_isExtreme && !m_isDivergence;
}

//+------------------------------------------------------------------+
//| RF-615: Is Swing Valid (por símbolo) - Placeholder               |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de IsSwingValid().                           |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsSwingValid() pero para un símbolo           |
//| específico.                                                      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsSwingValidForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-616: COT as OSOK Filter                                       |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Valida si el contexto COT actual es favorable para OSOK.         |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| OSOK requiere condiciones extremas y alineadas, sin divergencia. |
//|                                                                  |
//| SEÑAL:                                                           |
//| - True: Contexto favorable para OSOK                            |
//| - False: Contexto desfavorable - evitar OSOK                    |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Ejecutar OSOK SOLO cuando IsOSOKValid() == true.                 |
//| Es un filtro obligatorio para el modelo OSOK.                    |
//+------------------------------------------------------------------+
bool CCOExtended::IsOSOKValid() const {
    //--- OSOK requiere extremo y alineado
    if(m_commercialBias == BIAS_NEUTRAL) return false;
    return m_isExtreme && !m_isDivergence;
}

//+------------------------------------------------------------------+
//| RF-616: Is OSOK Valid (por símbolo) - Placeholder                |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de IsOSOKValid().                            |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que IsOSOKValid() pero para un símbolo            |
//| específico.                                                      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - false: Placeholder - implementar para multi-símbolo           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
bool CCOExtended::IsOSOKValidForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return false;
}

//+------------------------------------------------------------------+
//| RF-617: COT as Day Trading Context                               |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Retorna el bias del COT para usar como contexto en Day Trading.  |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Day Trading requiere contexto general del mercado.               |
//|                                                                  |
//| SEÑAL:                                                           |
//| - BIAS_BULLISH: Contexto alcista                                |
//| - BIAS_BEARISH: Contexto bajista                                |
//| - BIAS_NEUTRAL: Sin contexto claro                              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar como filtro de contexto para Day Trading.                   |
//+------------------------------------------------------------------+
ENUM_BIAS CCOExtended::GetDayTradingContext() const {
    return m_commercialBias;
}

//+------------------------------------------------------------------+
//| RF-617: Get Day Trading Context (por símbolo) - Placeholder      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Versión por símbolo de GetDayTradingContext().                   |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Mismo concepto que GetDayTradingContext() pero para un símbolo   |
//| específico.                                                      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a verificar                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - BIAS_NEUTRAL: Placeholder - implementar para multi-símbolo    |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
ENUM_BIAS CCOExtended::GetDayTradingContextForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return BIAS_NEUTRAL;
}

//+------------------------------------------------------------------+
//| RF-618: Auto Update                                              |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Actualiza automáticamente los datos COT si ha pasado el          |
//| intervalo configurado.                                           |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos COT se publican semanalmente. El EA debe               |
//| actualizarlos automáticamente para mantener la información       |
//| actualizada.                                                     |
//|                                                                  |
//| SEÑAL:                                                           |
//| - Ejecuta LoadData() si es necesario                            |
//| - No retorna valor                                              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamar en OnInit() y periódicamente para mantener datos         |
//| COT actualizados.                                               |
//+------------------------------------------------------------------+
void CCOExtended::AutoUpdate() {
    if(IsUpdateNeeded()) {
        LoadData(m_symbol);
        m_utils.LogInfo("COT Extended data auto-updated for " + m_symbol);
    }
}

//+------------------------------------------------------------------+
//| RF-618: Is Update Needed                                         |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Verifica si los datos COT necesitan actualización.               |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Los datos COT se actualizan semanalmente.                        |
//|                                                                  |
//| SEÑAL:                                                           |
//| - True: Se necesita actualización                                |
//| - False: Datos actualizados                                      |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar antes de llamar a AutoUpdate().                             |
//+------------------------------------------------------------------+
bool CCOExtended::IsUpdateNeeded() const {
    if(m_lastUpdate == 0) return true;
    return (TimeCurrent() - m_lastUpdate) > m_updateInterval * 86400;
}

//+------------------------------------------------------------------+
//| RF-618: Set Update Interval                                      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Configura el intervalo de actualización en días.                 |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Por defecto: 7 días (semanal).                                   |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - days: Intervalo en días (mínimo 1)                            |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Configurar según la frecuencia de publicación de datos COT.      |
//+------------------------------------------------------------------+
void CCOExtended::SetUpdateInterval(int days) {
    m_updateInterval = MathMax(1, days);
}

//+------------------------------------------------------------------+
//| RF-619: Get Historical Data                                      |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Retorna una entrada histórica específica por índice.             |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Permite acceder a datos históricos de COT para análisis         |
//| de tendencias y comparaciones.                                   |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - index: Índice de la entrada histórica                          |
//|                                                                  |
//| RETORNO:                                                          |
//| - COTExtendedData: Datos históricos en el índice                |
//| - Estructura vacía: Índice inválido                             |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para análisis de tendencias y cálculos de promedios.        |
//+------------------------------------------------------------------+
COTExtendedData CCOExtended::GetHistoricalData(int index) const {
    if(index < 0 || index >= m_historicalCount) {
        COTExtendedData empty;
        ZeroMemory(empty);
        return empty;
    }
    return m_historicalData[index];
}

//+------------------------------------------------------------------+
//| RF-619: Get Historical Average                                   |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Calcula el promedio de la posición neta comercial en los         |
//| últimos N períodos.                                              |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| El promedio histórico permite identificar si la posición         |
//| actual es atípica o está dentro de la norma.                    |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - periods: Número de períodos a promediar                       |
//|                                                                  |
//| RETORNO:                                                          |
//| - double: Promedio de los últimos N períodos                    |
//| - 0: No hay datos suficientes                                   |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para identificar desviaciones significativas.               |
//+------------------------------------------------------------------+
double CCOExtended::GetHistoricalAverage(int periods) const {
    if(periods <= 0 || m_historicalCount == 0) return 0;
    
    int count = MathMin(periods, m_historicalCount);
    double sum = 0;
    for(int i = m_historicalCount - count; i < m_historicalCount; i++) {
        sum += m_historicalData[i].commercialNet;
    }
    return sum / count;
}

//+------------------------------------------------------------------+
//| RF-620: COT Logging                                              |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera un log detallado del estado actual del COT.              |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| El logging de COT permite auditar y analizar las decisiones.     |
//|                                                                  |
//| SEÑAL:                                                           |
//| - string: Log formateado con todos los datos COT                |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para depuración, auditoría y análisis posterior.            |
//+------------------------------------------------------------------+
string CCOExtended::GetCOTLog() {
    string log = "=== COT EXTENDED LOG ===\n";
    log += "Symbol: " + m_symbol + "\n";
    log += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    log += "Mid Point: " + DoubleToString(m_currentData.midPoint, 0) + "\n";
    log += "Buy Program: " + (m_currentData.isBuyProgram ? "YES" : "NO") + "\n";
    log += "Sell Program: " + (m_currentData.isSellProgram ? "YES" : "NO") + "\n";
    log += "Hedging Program: " + (m_currentData.isHedgingProgram ? "YES" : "NO") + "\n";
    log += "Buy Hedge: " + (m_isBuyHedge ? "YES" : "NO") + "\n";
    log += "Sell Hedge: " + (m_isSellHedge ? "YES" : "NO") + "\n";
    log += "Hedging Nodule: " + (m_isHedgingNoduleActive ? "YES" : "NO") + "\n";
    log += "Extreme: " + (m_isExtreme ? "YES" : "NO") + "\n";
    log += "Divergence: " + (m_isDivergence ? "YES" : "NO") + "\n";
    log += "Divergence Score: " + DoubleToString(m_divergenceScore, 1) + "\n";
    log += "Commercial Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                                  (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    log += "Last Update: " + TimeToString(m_lastUpdate) + "\n";
    return log;
}

//+------------------------------------------------------------------+
//| RF-620: COT Logging (por símbolo) - Placeholder                  |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera un log detallado del estado COT para un símbolo           |
//| específico.                                                      |
//| ACTUALMENTE: Placeholder para implementación multi-símbolo.      |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo para el log                                    |
//|                                                                  |
//| RETORNO:                                                          |
//| - "": Placeholder - implementar para multi-símbolo              |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Pendiente de implementación para análisis multi-símbolo.         |
//+------------------------------------------------------------------+
string CCOExtended::GetCOTLogForSymbol(string symbol) {
    //--- Placeholder para implementación multi-símbolo
    return "";
}

//+------------------------------------------------------------------+
//| RF-620: Actualizar                                               |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Actualiza los datos COT Extended para el símbolo actual.         |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Permite actualizar el análisis bajo demanda.                     |
//|                                                                  |
//| PARÁMETROS:                                                       |
//| - symbol: Símbolo a actualizar (opcional)                       |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Llamar cuando se necesita actualizar datos.                      |
//+------------------------------------------------------------------+
void CCOExtended::Update(string symbol = "") {
    if(symbol != "") SetSymbol(symbol);
    LoadData(m_symbol);
}

//+------------------------------------------------------------------+
//| RF-620: Refresh                                                  |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Fuerza la recarga de datos COT Extended.                         |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Útil cuando se han actualizado archivos manualmente.             |
//|                                                                  |
//| RETORNO:                                                          |
//| - void                                                           |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para recargar datos sin esperar el ciclo automático.        |
//+------------------------------------------------------------------+
void CCOExtended::Refresh() {
    LoadData(m_symbol);
}

//+------------------------------------------------------------------+
//| RF-620: COT Summary                                              |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera un resumen conciso del estado COT Extended.               |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Resumen rápido de los datos más relevantes.                      |
//|                                                                  |
//| SEÑAL:                                                           |
//| - string: Resumen formateado                                    |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Para visualización rápida en el panel de control.                |
//+------------------------------------------------------------------+
string CCOExtended::GetCOTSummary() {
    string summary = "=== COT EXTENDED SUMMARY ===\n";
    summary += "Symbol: " + m_symbol + "\n";
    summary += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    summary += "Program: " + (m_currentData.isBuyProgram ? "BUY" : 
                              (m_currentData.isSellProgram ? "SELL" : "HEDGE")) + "\n";
    summary += "Bias: " + (m_commercialBias == BIAS_BULLISH ? "BULLISH" : 
                           (m_commercialBias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    summary += "Extreme: " + (m_isExtreme ? "YES" : "NO") + "\n";
    summary += "Divergence: " + (m_isDivergence ? "YES" : "NO") + "\n";
    summary += "Hedging Nodule: " + (m_isHedgingNoduleActive ? "YES" : "NO") + "\n";
    summary += "=========================";
    return summary;
}

//+------------------------------------------------------------------+
//| RF-620: COT Report                                               |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera un reporte detallado con todos los datos COT Extended     |
//| para el símbolo actual.                                          |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Reporte completo para análisis detallado.                        |
//|                                                                  |
//| SEÑAL:                                                           |
//| - Commercial Net: Posición neta de comerciales                  |
//| - 12M High/Low: Rango de 12 meses                               |
//| - Mid Point: Nueva línea cero                                   |
//| - Buy/Sell Hedge Level: Niveles de cobertura                    |
//| - Hedging Nodule: Cambio abrupto >20%                           |
//| - Divergence Score: Fuerza de la divergencia (0-100)            |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para análisis rápido o depuración.                          |
//+------------------------------------------------------------------+
string CCOExtended::GetCOTReport() {
    string report = "=== COT EXTENDED REPORT ===\n";
    report += "Symbol: " + m_symbol + "\n";
    report += "Commercial Net: " + DoubleToString(m_currentData.commercialNet, 0) + "\n";
    report += "12M High: " + DoubleToString(m_currentData.commercialHigh12M, 0) + "\n";
    report += "12M Low: " + DoubleToString(m_currentData.commercialLow12M, 0) + "\n";
    report += "Mid Point: " + DoubleToString(m_currentData.midPoint, 0) + "\n";
    report += "Buy Hedge Level: " + DoubleToString(m_buyHedgeLevel, 0) + "\n";
    report += "Sell Hedge Level: " + DoubleToString(m_sellHedgeLevel, 0) + "\n";
    report += "Extreme Level: " + DoubleToString(m_extremeLevel, 0) + "\n";
    report += "Hedging Nodule: " + DoubleToString(m_hedgingNodule, 0) + "\n";
    report += "Nodule Strength: " + DoubleToString(m_hedgingNoduleStrength, 1) + "%\n";
    report += "Divergence Score: " + DoubleToString(m_divergenceScore, 1) + "\n";
    report += "Historical Entries: " + IntegerToString(m_historicalCount) + "\n";
    report += "Historical Avg: " + DoubleToString(GetHistoricalAverage(10), 0) + "\n";
    report += "==============================";
    return report;
}

//+------------------------------------------------------------------+
//| RF-620: Extended Report                                          |
//+------------------------------------------------------------------+
//| DESCRIPCIÓN:                                                      |
//| Genera un reporte extendido con análisis adicionales para cada   |
//| modelo de trading: Swing, OSOK, Day Trading.                     |
//|                                                                  |
//| CONTEXTO ICT:                                                    |
//| Interpretaciones directas para cada modelo de trading.           |
//|                                                                  |
//| SEÑAL:                                                           |
//| - Swing Valid: true/false para Swing Trading                    |
//| - OSOK Valid: true/false para OSOK                              |
//| - Day Trading Context: Bias para Day Trading                    |
//| - Alignment Score: 0-100 para cada bias                         |
//|                                                                  |
//| USO PRÁCTICO:                                                    |
//| Usar para validar rápidamente si el contexto COT soporta        |
//| cada modelo de trading antes de ejecutar señales.               |
//+------------------------------------------------------------------+
string CCOExtended::GetExtendedReport() {
    string report = "=== EXTENDED ANALYSIS ===\n";
    report += "Swing Valid: " + (IsSwingValid() ? "YES" : "NO") + "\n";
    report += "OSOK Valid: " + (IsOSOKValid() ? "YES" : "NO") + "\n";
    report += "Day Trading Context: " + (GetDayTradingContext() == BIAS_BULLISH ? "BULLISH" : 
                                         (GetDayTradingContext() == BIAS_BEARISH ? "BEARISH" : "NEUTRAL")) + "\n";
    report += "Alignment Score: " + DoubleToString(GetAlignmentScore(BIAS_BULLISH), 1) + "% (BULL)\n";
    report += "Alignment Score: " + DoubleToString(GetAlignmentScore(BIAS_BEARISH), 1) + "% (BEAR)\n";
    report += "=========================";
    return report;
}

#endif // __CCOEXTENDED_MQH__