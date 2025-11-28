Design Doc – Text to Analixer 📝
1. Objetivo del sistema

El propósito del sistema Text to Analixer es analizar un texto en español y calcular qué tan relacionado está con el campo de las Matemáticas, generando un puntaje en una escala del 0% al 100%.

El sistema fue diseñado con los siguientes objetivos:

  Proveer una herramienta sencilla para detectar contenido matemático dentro de un texto.
  
  Servir como ejemplo práctico para cursos de:

    Procesamiento básico de lenguaje natural (NLP simple),
    
    Manejo de bases de datos (PostgreSQL),
    
    Desarrollo rápido de interfaces web (Streamlit).

  Permitir probar textos diversos:

    Matemáticos puros,
    
    Textos mixtos con matemáticas integradas,
    
    Textos no matemáticos.

2. Arquitectura General

La arquitectura está diseñada para ser simple y fácilmente entendible:

Usuario ──> Interfaz Streamlit (buscale.py)
             │
             ├── Carga vocabulario matemático desde PostgreSQL
             │
             ├── Tokenización del texto
             │
             └── Algoritmo MatCompat v5:
                 Calcula el puntaje con base en:
                   ● Promedio de pesos de palabras matemáticas
                   ● Densidad matemática del texto

Componentes principales:

Frontend + Backend:
Todo el procesamiento y la interfaz están unificados en buscale.py usando Streamlit.

Base de Datos:
Una tabla PostgreSQL llamada palabras_clave contiene:

términos matemáticos,

porcentaje de identidad (peso),

sinónimos.

Algoritmo MatCompat v5:
Es un clasificador basado en vocabulario que mide:

relevancia promedio de términos matemáticos,

densidad matemática.


3. Modelo de Datos
  3.1. Tabla public.palabras_clave

  Define el vocabulario matemático.

  Campos:
  
  | Campo                  | Tipo         | Descripción                             |
  | ---------------------- | ------------ | --------------------------------------- |
  | `id`                   | SERIAL       | Identificador único                     |
  | `palabra`              | TEXT         | Término base (ej. “derivada”, “matriz”) |
  | `porcentaje_identidad` | NUMERIC(5,2) | Peso (relevancia del término)           |
  | `sinonimos`            | TEXT[]       | Lista de sinónimos (sin espacios)       |


Ejemplo de registros:

    ("derivada", 97.00, ARRAY['derivadas','derivar'])
    
    ("matriz", 93.00, ARRAY['matrices'])
    
    ("integral", 97.00, ARRAY['integrales','integrar'])

3.2. Índice en memoria

    Una vez que la app arranca, se transforma la tabla en un diccionario:
    
    token_normalizado  →  (palabra_base, peso)
    
    Donde:
    
    token_normalizado: versión en minúsculas y sin acentos.
    
    palabra_base: término original de la BD.
    
    peso: porcentaje_identidad convertido a número entre 0 y 1.


4. Flujo de Ejecución

  4.1.- Cargar vocabulario desde PostgreSQL
  
    Para no hacer consultas por cada token, se carga todo al inicio.
  
    Los sinónimos se normalizan igual que los tokens del texto.
  
  4.2.- Usuario ingresa un texto
  
    Se usa un text_area de Streamlit.
  
  4.3.- Tokenización
  
    minúsculas,
  
    eliminación de acentos,
  
    separación por expresiones regulares,
  
    filtrado de stopwords en español.
  
  4.4.-Coincidencias matemáticas
  
    Por cada token:
  
      Si existe en vocab_index, cuenta como “término matemático”.
  
  4.5.- Cálculo de métricas
  
    avg_peso: promedio de pesos de términos encontrados.
  
    densidad_matematica: proporción de tokens significativos que son matemáticos.
  
    distinct_terms: número de términos matemáticos diferentes.
  
  4.6.-Cálculo del puntaje
  
    Se aplica el algoritmo MatCompat v5:
    score = 100 * (0.55 * avg_peso + 0.45 * densidad_matematica)
  
  4.7.-Presentación
  
    Barra de compatibilidad,
  
    Métricas auxiliares,
  
    Tabla con términos matemáticos encontrados ordenados por aporte.

5. Decisiones de Diseño
  ✔ Uso de PostgreSQL en lugar de listas en Python
  
        Separación entre datos y lógica.
        
        Fácil de ampliar sin tocar código.
        
        Control de calidad (CHECK, triggers, normalización).

  ✔ Normalización unificada
  
    Se aplica la misma normalización a:
    
    texto del usuario,
    
    palabras base,
    
    sinónimos.

    Esto asegura coincidencias consistentes aun si el usuario escribe:

    “cálculo”, “calculo”, “CalCULO”, “caĺculo”.

  ✔ Clases simples en lugar de IA pesada

    El algoritmo se basa en vocabulario y densidad:
    
    Fácil de explicar en clase,
    
    No requiere GPU,
    
    No necesita modelos entrenados.

  ✔ Streamlit

    Fácil de usar para proyectos escolares,
    
    Genera interfaces limpias sin HTML/CSS,
    
    Ideal para una demo interactiva.

