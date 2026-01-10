# 🔐 Configuración de Seguridad - API Keys

## Variables de Entorno

Este proyecto utiliza variables de entorno para almacenar información sensible como API keys.

### Configuración Inicial

1. **Copia el archivo de ejemplo:**

   ```bash
   cp .env.example .env
   ```

2. **Edita el archivo `.env` con tus credenciales:**

   ```
   GEMINI_API_KEY=tu_api_key_aqui
   ```

3. **IMPORTANTE:** El archivo `.env` está en `.gitignore` y **NUNCA** debe subirse a GitHub.

### Google AI Studio (Gemini) API Key

Para obtener tu API key de Gemini:

1. Ve a [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Inicia sesión con tu cuenta de Google
3. Crea una nueva API key o usa una existente
4. Copia la API key y agrégala al archivo `.env`

**Ubicación de la API key en el proyecto:**

- ✅ Archivo `.env` (correcto, seguro, ignorado por Git)
- ❌ Nunca en archivos de código fuente
- ❌ Nunca en commits de Git
- ❌ Nunca en capturas de pantalla públicas

### Uso en el Código

```dart
import 'package:financial_control/core/config/env_config.dart';

// La API key se carga automáticamente
final apiKey = EnvConfig.geminiApiKey;
```

### Verificación

Para verificar que la configuración es correcta:

```bash
# El archivo .env debe existir
ls -la .env

# El archivo .env NO debe aparecer en git status
git status
```

## 🚨 Seguridad

- **NUNCA** compartas tu archivo `.env`
- **NUNCA** hagas commit del archivo `.env`
- **NUNCA** publiques tu API key en mensajes, issues, o screenshots
- Si accidentalmente expones una API key, **revócala inmediatamente** en Google AI Studio y genera una nueva

## Deployment

Cuando despliegues la aplicación:

- **Desarrollo local:** Usa el archivo `.env`
- **CI/CD:** Configura las variables de entorno en los secrets del sistema (GitHub Actions, etc.)
- **Producción:** Usa variables de entorno del servidor o servicio de hosting

---

_Última actualización: Enero 2026_
