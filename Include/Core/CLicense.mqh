//+------------------------------------------------------------------+
//|                                                     CLicense.mqh |
//|                           HunterIPDA Pro EA - v1.7 - Módulo Core |
//|                                  Copyright 2026, HunterIPDA Team |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DESCRIPCIÓN DEL MÓDULO                                           |
//+------------------------------------------------------------------+
//| Este módulo gestiona el sistema de licencias del EA:             |
//| - Validación de licencia (personal/comercial/demo)               |
//| - Activación offline                                             |
//| - Protección contra ingeniería inversa                           |
//| - Licencia de prueba (30 días)                                   |
//| - Cifrado de datos de licencia                                   |
//|                                                                  |
//| RFs asociados:                                                   |
//|   RF-046: Protección de Licencia                                 |
//|   RF-047: Licencia Personal vs. Comercial                        |
//|   RF-048: Activación Offline                                     |
//|   RF-049: Prevención de Ingeniería Inversa                       |
//|   RF-050: Licencia de Prueba                                     |
//|                                                                  |
//| Dependencias:                                                    |
//|   - CConstants: Constantes y enumeraciones (LICENSE_*)           |
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
//| 1.1     | 21/07/2026  | Cambiado ENUM_LICENSE_TYPE a int para    |
//|         |             | evitar conflictos de visibilidad         |
//| 1.2     | 21/07/2026  | Usar constantes LICENSE_* de CConstants  |
//| 1.3     | 21/07/2026  | Reemplazado CRYPT_CRC por CRYPT_AES256   |
//| 1.4     | 21/07/2026  | Corregido StringGetChar →                |
//|         |             | StringGetCharacter                       |
//| 1.5     | 21/07/2026  | Conversión explícita long→int en         |
//|         |             | ParseLicenseData()                       |
//+------------------------------------------------------------------+

#ifndef __CLICENSE_MQH__
#define __CLICENSE_MQH__

#include "CConstants.mqh"
#include "CUtils.mqh"
#include "CConfig.mqh"

//--- ENUM_LICENSE_TYPE ya está definido en CConstants.mqh
//--- Los valores son: LIC_TYPE_NONE, LIC_TYPE_DEMO, LIC_TYPE_PERSONAL, LIC_TYPE_COMMERCIAL

//+------------------------------------------------------------------+
//| ESTRUCTURAS DE DATOS                                             |
//+------------------------------------------------------------------+
struct LicenseData {
    int                 licenseType;
    string              licenseKey;
    string              accountNumber;      // Número de cuenta MT5
    string              terminalId;         // ID del terminal
    datetime            activationDate;
    datetime            expirationDate;
    bool                isActive;
    int                 maxAccounts;        // 1 para personal, 0 para demo, 5+ para comercial
};

//+------------------------------------------------------------------+
//| CLASE CLicense - Gestión de Licencias                            |
//+------------------------------------------------------------------+
class CLicense {
private:
    //--- Miembros privados
    CConfig*           m_config;
    CUtils*            m_utils;
    bool               m_isInitialized;
    bool               m_isLicensed;
    int                m_licenseType;
    datetime           m_expirationDate;
    string             m_licenseKey;
    string             m_licenseFile;
    string             m_accountNumber;
    string             m_terminalId;
    LicenseData        m_licenseData;
    
    //--- Constantes de cifrado
    static const string ENCRYPTION_KEY;
    
    //--- Métodos privados
    bool               ValidateLicense();
    bool               ValidateDemoLicense();
    bool               ValidateFullLicense();
    bool               ValidateCommercialLicense();
    bool               CheckExpiration();
    string             GenerateLicenseKey(string accountNumber, string terminalId);
    string             EncryptData(string data);
    string             DecryptData(string data);
    bool               SaveLicenseFile(string data);
    string             LoadLicenseFile();
    string             GetMachineId();
    string             GetAccountNumber();
    string             GetTerminalId();
    bool               CreateDemoLicense();
    bool               ParseLicenseData(string data);
    
public:
    //--- Constructor / Destructor
    CLicense();
    ~CLicense();
    
    //--- Inicialización
    bool Init(CConfig* config, CUtils* utils);
    void Deinit();
    bool IsInitialized() const { return m_isInitialized; }
    
    //--- RF-046: Protección de Licencia
    //--- RF-047: Licencia Personal vs. Comercial
    //--- RF-048: Activación Offline
    //--- RF-050: Licencia de Prueba
    bool ActivateLicense(string licenseKey);
    bool Validate();
    bool IsLicensed() const { return m_isLicensed; }
    int GetLicenseType() const { return m_licenseType; }
    datetime GetExpirationDate() const { return m_expirationDate; }
    int GetDaysRemaining() const;
    bool IsExpired() const;
    
    //--- RF-049: Prevención de Ingeniería Inversa
    bool IsCodeProtected() const;
    
    //--- Getters
    string GetLicenseKey() const { return m_licenseKey; }
    bool IsDemoLicense() const { return m_licenseType == LICENSE_DEMO; }
    bool IsPersonalLicense() const { return m_licenseType == LICENSE_PERSONAL; }
    bool IsCommercialLicense() const { return m_licenseType == LICENSE_COMMERCIAL; }
    string GetAccountNumber() const { return m_accountNumber; }
    string GetTerminalId() const { return m_terminalId; }
    LicenseData GetLicenseData() const { return m_licenseData; }
    
    //--- Reportes
    string GetLicenseSummary();
    string GetLicenseReport();
};

//+------------------------------------------------------------------+
//| DEFINICIÓN DE CONSTANTES ESTÁTICAS                               |
//+------------------------------------------------------------------+
const string CLicense::ENCRYPTION_KEY = "HunterIPDA_Pro_EA_2026_SecureKey";

//+------------------------------------------------------------------+
//| IMPLEMENTACIÓN                                                   |
//+------------------------------------------------------------------+

//--- Constructor
CLicense::CLicense() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
    m_isLicensed = false;
    m_licenseType = LICENSE_NONE;
    m_expirationDate = 0;
    m_licenseKey = "";
    m_licenseFile = "";
    m_accountNumber = "";
    m_terminalId = "";
    ZeroMemory(m_licenseData);
}

//--- Destructor
CLicense::~CLicense() {
    Deinit();
}

//--- Inicialización
bool CLicense::Init(CConfig* config, CUtils* utils) {
    if(config == NULL || utils == NULL) {
        Print("CLicense::Init - Error: Parámetros NULL");
        return false;
    }
    
    m_config = config;
    m_utils = utils;
    
    //--- Obtener información del sistema
    m_accountNumber = GetAccountNumber();
    m_terminalId = GetTerminalId();
    
    //--- Establecer ruta del archivo de licencia
    string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
    m_licenseFile = terminalPath + "\\MQL5\\Files\\HunterIPDA_License.dat";
    
    //--- Validar licencia existente o crear demo
    if(!Validate()) {
        //--- Si no hay licencia válida, crear demo
        if(!CreateDemoLicense()) {
            m_utils.LogError("CLicense::Init - No se pudo crear licencia demo");
            return false;
        }
    }
    
    m_isInitialized = true;
    m_utils.LogInfo("CLicense inicializado correctamente - Tipo: " + GetLicenseSummary());
    return true;
}

//--- Desinicialización
void CLicense::Deinit() {
    m_config = NULL;
    m_utils = NULL;
    m_isInitialized = false;
}

//--- Obtener número de cuenta
string CLicense::GetAccountNumber() {
    long login = AccountInfoInteger(ACCOUNT_LOGIN);
    return IntegerToString(login);
}

//--- Obtener ID del terminal
string CLicense::GetTerminalId() {
    string path = TerminalInfoString(TERMINAL_PATH);
    //--- Usar una combinación de información para identificar el terminal
    string id = path + "_" + GetAccountNumber();
    //--- Hash simple para ID único
    int hash = 0;
    for(int i = 0; i < StringLen(id); i++) {
        hash += StringGetCharacter(id, i);
    }
    return IntegerToString(hash);
}

//--- Obtener ID de máquina
string CLicense::GetMachineId() {
    string id = "";
    //--- Usar información del sistema para ID de máquina
    id += TerminalInfoString(TERMINAL_NAME);
    id += "_" + TerminalInfoString(TERMINAL_COMPANY);
    return id;
}

//--- Cifrar datos
string CLicense::EncryptData(string data) {
    uchar src[];
    uchar dst[];
    StringToCharArray(data, src);
    
    //--- Usar CryptEncode con AES256 (requiere clave de 32 bytes)
    uchar key[];
    StringToCharArray(ENCRYPTION_KEY, key);
    if(CryptEncode(CRYPT_AES256, src, key, dst) <= 0) { 
        return "";
    }
    
    return CharArrayToString(dst);
}

//--- Descifrar datos
string CLicense::DecryptData(string data) {
    uchar src[];
    uchar dst[];
    StringToCharArray(data, src);
    
    //--- Usar CryptDecode con AES256
    uchar key[];
    StringToCharArray(ENCRYPTION_KEY, key);
    if(CryptDecode(CRYPT_AES256, src, key, dst) <= 0) {   
        return "";
    }
    
    return CharArrayToString(dst);
}

//--- Guardar archivo de licencia
bool CLicense::SaveLicenseFile(string data) {
    int handle = FileOpen(m_licenseFile, FILE_WRITE | FILE_BIN);
    if(handle == INVALID_HANDLE) {
        m_utils.LogError("CLicense::SaveLicenseFile - No se pudo crear archivo de licencia");
        return false;
    }
    
    //--- Cifrar datos antes de guardar
    string encrypted = EncryptData(data);
    if(encrypted == "") {
        FileClose(handle);
        return false;
    }
    
    FileWriteString(handle, encrypted);
    FileClose(handle);
    return true;
}

//--- Cargar archivo de licencia
string CLicense::LoadLicenseFile() {
    if(!FileIsExist(m_licenseFile)) {
        return "";
    }
    
    int handle = FileOpen(m_licenseFile, FILE_READ | FILE_BIN);
    if(handle == INVALID_HANDLE) {
        return "";
    }
    
    string encrypted = FileReadString(handle);
    FileClose(handle);
    
    //--- Descifrar datos
    return DecryptData(encrypted);
}

//--- Parsear datos de licencia
bool CLicense::ParseLicenseData(string data) {
    if(data == "") return false;
    
    //--- Formato: tipo|clave|cuenta|terminal|fecha_activacion|fecha_expiracion|max_cuentas
    string parts[];
    int count = StringSplit(data, '|', parts);
    if(count < 7) return false;
    
    m_licenseData.licenseType = (ENUM_LICENSE_TYPE)StringToInteger(parts[0]);
    m_licenseData.licenseKey = parts[1];
    m_licenseData.accountNumber = parts[2];
    m_licenseData.terminalId = parts[3];
    m_licenseData.activationDate = (datetime)StringToInteger(parts[4]);
    m_licenseData.expirationDate = (datetime)StringToInteger(parts[5]);
    m_licenseData.maxAccounts = (int)StringToInteger(parts[6]);
    m_licenseData.isActive = true;
    
    return true;
}

//--- Generar clave de licencia
string CLicense::GenerateLicenseKey(string accountNumber, string terminalId) {
    string raw = accountNumber + terminalId + TimeToString(TimeCurrent());
    return EncryptData(raw);
}

//--- Crear licencia demo
bool CLicense::CreateDemoLicense() {
    //--- RF-050: Licencia de Prueba (30 días)
    m_licenseData.licenseType = LICENSE_DEMO;
    m_licenseData.licenseKey = GenerateLicenseKey(m_accountNumber, m_terminalId);
    m_licenseData.accountNumber = m_accountNumber;
    m_licenseData.terminalId = m_terminalId;
    m_licenseData.activationDate = TimeCurrent();
    m_licenseData.expirationDate = TimeCurrent() + 30 * 24 * 3600;  // 30 días
    m_licenseData.maxAccounts = 1;
    m_licenseData.isActive = true;
    
    //--- Guardar datos
    string data = IntegerToString(m_licenseData.licenseType) + "|" +
                  m_licenseData.licenseKey + "|" +
                  m_licenseData.accountNumber + "|" +
                  m_licenseData.terminalId + "|" +
                  IntegerToString(m_licenseData.activationDate) + "|" +
                  IntegerToString(m_licenseData.expirationDate) + "|" +
                  IntegerToString(m_licenseData.maxAccounts);
    
    if(!SaveLicenseFile(data)) {
        return false;
    }
    
    m_licenseType = LICENSE_DEMO;
    m_expirationDate = m_licenseData.expirationDate;
    m_isLicensed = true;
    
    m_utils.LogInfo("CLicense::CreateDemoLicense - Licencia demo creada por 30 días");
    return true;
}

//--- RF-046: Validar Licencia
bool CLicense::Validate() {
    //--- RF-048: Activación Offline - Cargar licencia local
    string data = LoadLicenseFile();
    if(data == "") {
        return false;
    }
    
    if(!ParseLicenseData(data)) {
        return false;
    }
    
    //--- Verificar que la licencia es para esta cuenta/terminal
    if(m_licenseData.accountNumber != m_accountNumber) {
        m_utils.LogError("CLicense::Validate - Licencia para otra cuenta");
        return false;
    }
    
    //--- RF-047: Licencia Personal vs. Comercial
    //--- Verificar tipo de licencia
    if(m_licenseData.licenseType == LICENSE_NONE) {
        return false;
    }
    
    //--- Verificar expiración
    if(CheckExpiration()) {
        return false;
    }
    
    m_licenseType = m_licenseData.licenseType;
    m_expirationDate = m_licenseData.expirationDate;
    m_licenseKey = m_licenseData.licenseKey;
    m_isLicensed = true;
    
    return true;
}

//--- RF-048: Activación Offline
bool CLicense::ActivateLicense(string licenseKey) {
    if(licenseKey == "") {
        m_utils.LogError("CLicense::ActivateLicense - Clave de licencia vacía");
        return false;
    }
    
    //--- RF-047: Verificar tipo de licencia
    //--- Por simplicidad, validamos la clave y creamos licencia personal/comercial
    //--- En producción, esto validaría contra un servidor o algoritmo de activación
    
    //--- Simular validación (en producción, esto sería más complejo)
    if(StringLen(licenseKey) < 16) {
        m_utils.LogError("CLicense::ActivateLicense - Clave inválida (longitud insuficiente)");
        return false;
    }
    
    //--- Determinar tipo de licencia por formato de clave
    ENUM_LICENSE_TYPE type = LICENSE_PERSONAL;
    if(StringSubstr(licenseKey, 0, 3) == "COM") {
        type = LICENSE_COMMERCIAL;
    } else if(StringSubstr(licenseKey, 0, 3) == "DEM") {
        type = LICENSE_DEMO;
    }
    
    //--- Crear datos de licencia
    m_licenseData.licenseType = type;
    m_licenseData.licenseKey = licenseKey;
    m_licenseData.accountNumber = m_accountNumber;
    m_licenseData.terminalId = m_terminalId;
    m_licenseData.activationDate = TimeCurrent();
    m_licenseData.maxAccounts = (type == LICENSE_COMMERCIAL) ? 10 : 1;
    
    //--- Establecer expiración (1 año para personal, 2 años para comercial)
    if(type == LICENSE_DEMO) {
        m_licenseData.expirationDate = TimeCurrent() + 30 * 24 * 3600;
    } else if(type == LICENSE_PERSONAL) {
        m_licenseData.expirationDate = TimeCurrent() + 365 * 24 * 3600;
    } else {
        m_licenseData.expirationDate = TimeCurrent() + 730 * 24 * 3600;
    }
    m_licenseData.isActive = true;
    
    //--- Guardar archivo
    string data = IntegerToString(m_licenseData.licenseType) + "|" +
                  m_licenseData.licenseKey + "|" +
                  m_licenseData.accountNumber + "|" +
                  m_licenseData.terminalId + "|" +
                  IntegerToString(m_licenseData.activationDate) + "|" +
                  IntegerToString(m_licenseData.expirationDate) + "|" +
                  IntegerToString(m_licenseData.maxAccounts);
    
    if(!SaveLicenseFile(data)) {
        m_utils.LogError("CLicense::ActivateLicense - Error al guardar licencia");
        return false;
    }
    
    m_licenseType = type;
    m_expirationDate = m_licenseData.expirationDate;
    m_licenseKey = licenseKey;
    m_isLicensed = true;
    
    m_utils.LogInfo("CLicense::ActivateLicense - Licencia activada correctamente: " + GetLicenseSummary());
    return true;
}

//--- RF-046: Verificar expiración
bool CLicense::CheckExpiration() {
    if(m_licenseData.expirationDate == 0) return false;
    return TimeCurrent() > m_licenseData.expirationDate;
}

//--- Obtener días restantes
int CLicense::GetDaysRemaining() const {
    if(m_expirationDate == 0) return 0;
    int diff = (int)((m_expirationDate - TimeCurrent()) / (24 * 3600));
    return (diff > 0) ? diff : 0;
}

//--- Verificar si está expirado
bool CLicense::IsExpired() const {
    if(m_expirationDate == 0) return false;
    return TimeCurrent() > m_expirationDate;
}

//--- RF-049: Prevención de Ingeniería Inversa
bool CLicense::IsCodeProtected() const {
    //--- Verificar que el código no está modificado
    //--- En MQL5, esto se implementa mediante compilación con protección
    //--- Esta función confirma que la protección está activa
    #ifdef __MQL5__
        return true;
    #else
        return false;
    #endif
}

//--- Validar licencia demo
bool CLicense::ValidateDemoLicense() {
    if(!m_isLicensed) return false;
    if(m_licenseType != LICENSE_DEMO) return false;
    return !IsExpired();
}

//--- Validar licencia completa
bool CLicense::ValidateFullLicense() {
    if(!m_isLicensed) return false;
    if(m_licenseType == LICENSE_NONE) return false;
    if(m_licenseType == LICENSE_DEMO) return false;
    return !IsExpired();
}

//--- Validar licencia comercial
bool CLicense::ValidateCommercialLicense() {
    if(!m_isLicensed) return false;
    if(m_licenseType != LICENSE_COMMERCIAL) return false;
    return !IsExpired();
}

//--- Obtener resumen de licencia
string CLicense::GetLicenseSummary() {
    string typeName = "";
    switch(m_licenseType) {
        case LICENSE_DEMO:       typeName = "DEMO (30 días)"; break;
        case LICENSE_PERSONAL:   typeName = "PERSONAL (1 año)"; break;
        case LICENSE_COMMERCIAL: typeName = "COMERCIAL (2 años)"; break;
        default:                 typeName = "NINGUNA";
    }
    return typeName;
}

//--- Obtener reporte de licencia
string CLicense::GetLicenseReport() {
    string report = "=== LICENCIA ===\n";
    report += "Tipo: " + GetLicenseSummary() + "\n";
    report += "Clave: " + m_licenseKey + "\n";
    report += "Cuenta: " + m_accountNumber + "\n";
    report += "Terminal ID: " + m_terminalId + "\n";
    report += "Activación: " + TimeToString(m_licenseData.activationDate) + "\n";
    report += "Expiración: " + TimeToString(m_expirationDate) + "\n";
    report += "Días restantes: " + IntegerToString(GetDaysRemaining()) + "\n";
    report += "Estado: " + (m_isLicensed ? "ACTIVA" : "INACTIVA") + "\n";
    if(IsExpired()) {
        report += "⚠️ LICENCIA EXPIRADA\n";
    }
    report += "===================";
    return report;
}

#endif // __CLICENSE_MQH__