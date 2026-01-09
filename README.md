# 💰 Control Financiero Universitario SAGX-UP

Aplicación móvil multiplataforma para gestionar finanzas personales de estudiantes universitarios mediante IA, gamificación y métricas inteligentes.

## 🎯 Objetivo del Proyecto

Desarrollar una aplicación móvil que permita a los estudiantes universitarios:

- ✅ Gestionar ingresos y gastos
- 📊 Visualizar métricas financieras
- 🤖 Recibir recomendaciones basadas en IA
- 🎮 Mejorar hábitos mediante gamificación
- 📈 Evaluar impacto Pre/Post uso de la app

## 🏗️ Arquitectura

Este proyecto utiliza **arquitectura por features** para máxima escalabilidad:

```
lib/
├── core/                    # Configuración global
│   ├── theme/              # Diseño UI
│   ├── constants/          # Constantes
│   └── services/           # Firebase, Auth
├── features/               # Módulos funcionales
│   ├── auth/              # Autenticación
│   ├── transactions/      # Ingresos y Gastos
│   ├── budget/            # Presupuestos
│   ├── analytics/         # Métricas
│   ├── achievements/      # Gamificación
│   └── ai_assistant/      # IA
└── shared/                # Componentes compartidos
    ├── models/
    └── widgets/
```

## 🚀 Funcionalidades

### ✅ Implementado

- ✅ Autenticación (Email/Password)
- ✅ Diseño minimalista y moderno
- ✅ Manejo robusto de errores
- ✅ Arquitectura escalable
- ✅ Modelos de datos completos

### 🔄 En Desarrollo

- 🔄 Registro de transacciones
- 🔄 Gestión de presupuestos
- 🔄 Dashboard con métricas
- 🔄 Sistema de logros

## 🛠️ Tecnologías

- **Frontend**: Flutter 3.x
- **Backend**: Firebase (Auth + Firestore)
- **IA**: OpenAI API / Google Gemini
- **Estado**: Provider / Riverpod
- **Gráficas**: FL Chart

## 📦 Instalación

### Prerrequisitos

```bash
flutter --version  # Flutter 3.0+
dart --version     # Dart 3.0+
```

### Setup

```bash
# Clonar el repositorio
git clone [url-del-repo]
cd financial_control

# Instalar dependencias
flutter pub get

# Configurar Firebase
flutterfire configure --project=financial-control-ls

# Ejecutar la app
flutter run
```

## 📱 Capturas (Próximamente)

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 📄 Base de Datos (Firestore)

### Colecciones

**users**

```json
{
  "name": "Juan Pérez",
  "email": "juan@mail.com",
  "level": "Principiante",
  "createdAt": timestamp
}
```

**expenses**

```json
{
  "userId": "abc123",
  "amount": 12.50,
  "category": "Transporte",
  "date": timestamp,
  "description": "Bus universitario",
  "isImpulsive": false
}
```

**incomes**

```json
{
  "userId": "abc123",
  "amount": 200,
  "source": "Beca",
  "date": timestamp
}
```

Ver más en [ARCHITECTURE.md](ARCHITECTURE.md).

## 🎓 Contexto Académico

Este proyecto es parte de una investigación para evaluar el impacto de aplicaciones móviles con IA y gamificación en el comportamiento financiero de estudiantes universitarios.

### Metodología

1. **Pre-test**: Evaluación inicial de hábitos financieros
2. **Intervención**: Uso de la app por 4-8 semanas
3. **Post-test**: Re-evaluación de comportamiento
4. **Análisis**: Comparación de métricas Pre/Post

## 👥 Contribuir

Este proyecto está en desarrollo activo. Sugerencias y contribuciones son bienvenidas.

## 📝 Licencia

[MIT License](LICENSE)
