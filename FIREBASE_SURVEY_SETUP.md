# 📊 Configuración de Firebase para el Sistema de Encuestas

## 🗄️ Estructura de Base de Datos

### Colección: `surveys`

Almacena las respuestas de encuestas PRE y POST de todos los usuarios.

```
surveys/
  ├── {surveyId}/
  │   ├── id: string
  │   ├── userId: string
  │   ├── type: string ('PRE' | 'POST')
  │   ├── completedAt: timestamp
  │   ├── career: string (solo PRE)
  │   ├── semester: number (solo PRE)
  │   ├── hasOwnIncome: boolean (solo PRE)
  │   ├── knowledgeIncomeExpenses: number (1-5)
  │   ├── knowledgeBudget: number (1-5)
  │   ├── knowledgeDecisions: number (1-5)
  │   ├── knowledgeSavings: number (1-5)
  │   ├── savingsConsistency: number (1-5)
  │   ├── savingsConsideration: number (1-5)
  │   ├── savingsAllocation: number (1-5)
  │   ├── savingsGoals: number (1-5)
  │   ├── trackingOrganization: number (1-5)
  │   ├── trackingFrequency: number (1-5)
  │   ├── trackingCategories: number (1-5)
  │   ├── trackingAwareness: number (1-5)
  │   ├── selfRegulationPlanning: number (1-5)
  │   ├── selfRegulationEvaluation: number (1-5)
  │   ├── selfRegulationAdjustment: number (1-5)
  │   ├── selfRegulationImprovement: number (1-5)
  │   ├── toolsPerception: number (1-5)
  │   ├── toolsEaseOfUse: number (1-5)
  │   ├── toolsInfluence: number (1-5)
  │   └── toolsMotivation: number (1-5)
```

### Colección existente: `users`

**NO requiere cambios**. La fecha de creación (`createdAt`) ya existe y se usa para calcular si han pasado 15 días.

---

## 🔒 Reglas de Seguridad de Firebase

Agrega estas reglas en **Firebase Console > Firestore Database > Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Reglas existentes de users, expenses, income, budgets, etc.
    // ... (no modificar) ...

    // NUEVA REGLA: Encuestas
    match /surveys/{surveyId} {
      // Los usuarios pueden leer solo sus propias encuestas
      allow read: if request.auth != null
                  && resource.data.userId == request.auth.uid;

      // Los usuarios pueden crear su propia encuesta PRE o POST
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.type in ['PRE', 'POST'];

      // No se permite actualizar o eliminar encuestas
      allow update, delete: if false;

      // El admin puede leer todas las encuestas
      allow read: if request.auth != null
                  && request.auth.token.email == 'admin@example.com';
    }
  }
}
```

**⚠️ IMPORTANTE:** Reemplaza `'admin@example.com'` con el email que tienes en tu variable `ADMIN_EMAIL` del archivo `.env`.

---

## 📋 Índices Compuestos Necesarios

Firebase creará automáticamente los índices cuando ejecutes las consultas por primera vez. Si ves errores de índices, Firebase te dará un enlace directo para crearlos.

### Índices recomendados:

1. **Para obtener encuestas por usuario y tipo:**

   - Colección: `surveys`
   - Campos: `userId` (Ascending), `type` (Ascending)

2. **Para el panel de admin:**

   - Colección: `surveys`
   - Campos: `completedAt` (Descending)

3. **Para obtener todas las encuestas de un usuario:**
   - Colección: `surveys`
   - Campos: `userId` (Ascending), `completedAt` (Ascending)

---

## ✅ Checklist de Configuración

- [ ] Agregar la colección `surveys` en Firestore (se crea automáticamente al enviar la primera encuesta)
- [ ] Actualizar las reglas de seguridad en Firebase Console
- [ ] Reemplazar el email del admin en las reglas
- [ ] Probar registro de un nuevo usuario y verificar que se guarde la encuesta PRE
- [ ] Verificar que después de 15 días aparezca la opción de encuesta POST en el perfil
- [ ] Confirmar que el admin puede exportar todas las encuestas desde el panel

---

## 🔍 Cómo Verificar que Funciona

1. **Registro nuevo usuario:**

   ```
   1. Completar formulario de registro
   2. Automáticamente ve pantalla de Encuesta PRE
   3. Completar encuesta
   4. Redirige a HomePage
   5. En Firestore debe aparecer un documento en surveys/ con type: 'PRE'
   ```

2. **Encuesta POST (después de 15 días):**

   ```
   1. Ir a Perfil
   2. Debe aparecer opción "Encuesta Final"
   3. Completar encuesta
   4. En Firestore aparece nuevo documento con type: 'POST'
   5. La opción desaparece del perfil
   ```

3. **Panel de Admin:**
   ```
   1. Ingresar con cuenta admin
   2. En "Panel Investigador" debe haber nueva opción para exportar encuestas
   3. El CSV debe contener todas las respuestas PRE y POST
   ```

---

## 🆘 Solución de Problemas

### Error: "Missing or insufficient permissions"

- Verifica que las reglas de seguridad estén actualizadas
- Confirma que el usuario esté autenticado

### La encuesta POST no aparece

- Verifica que hayan pasado al menos 15 días desde `createdAt` del usuario
- Confirma que no haya completado ya la encuesta POST

### Error de índices compuestos

- Firebase te dará un link directo para crearlos
- Haz clic y espera 1-2 minutos a que se construya

---

## 📊 Exportación de Datos (para tu Artículo)

Las encuestas se pueden exportar desde el panel de admin en formato CSV con todas las dimensiones para análisis estadístico en SPSS, R o Python.

Columnas incluidas:

- Datos demográficos (carrera, semestre, ingresos)
- 5 dimensiones con 4 preguntas cada una
- Timestamp de completado
- Tipo (PRE/POST)
- Usuario ID (anonimizado)
