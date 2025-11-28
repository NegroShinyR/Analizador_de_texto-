

-- Crear/rehacer la tabla en el esquema PUBLIC
DROP TABLE IF EXISTS public.palabras_clave CASCADE;

CREATE TABLE public.palabras_clave (
  id SERIAL PRIMARY KEY,
  palabra TEXT UNIQUE NOT NULL,
  porcentaje_identidad NUMERIC(5,2) NOT NULL CHECK (porcentaje_identidad BETWEEN 0 AND 100),
  sinonimos TEXT[] NOT NULL DEFAULT '{}',
  CONSTRAINT chk_palabra_sin_espacios CHECK (palabra !~ '\s'),
  -- sin subconsultas en CHECK: validamos que ningún sinónimo tenga espacios
  CONSTRAINT chk_sinonimos_sin_espacios CHECK (array_to_string(sinonimos, '') !~ '\s')
);

-- Verifica que exista:
SELECT current_database() AS db, current_schema() AS schema,
       to_regclass('public.palabras_clave') AS existe_tabla;



-- Función de normalización (completa)
CREATE OR REPLACE FUNCTION public.normalizar_palabra_sinonimos()
RETURNS TRIGGER AS $$
BEGIN
  NEW.palabra := lower(trim(NEW.palabra));
  IF NEW.sinonimos IS NOT NULL THEN
    NEW.sinonimos := (
      SELECT ARRAY(
        SELECT lower(trim(x))
        FROM UNNEST(NEW.sinonimos) AS x
        WHERE x IS NOT NULL AND x <> ''
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger (nota: referimos a public.palabras_clave)
DROP TRIGGER IF EXISTS trg_normalizar_palabra_sinonimos ON public.palabras_clave;
CREATE TRIGGER trg_normalizar_palabra_sinonimos
BEFORE INSERT OR UPDATE ON public.palabras_clave
FOR EACH ROW
EXECUTE FUNCTION public.normalizar_palabra_sinonimos();

-- Índices
CREATE INDEX IF NOT EXISTS idx_palabras_palabra
  ON public.palabras_clave (palabra);
CREATE INDEX IF NOT EXISTS idx_palabras_porcentaje
  ON public.palabras_clave (porcentaje_identidad);


INSERT INTO public.palabras_clave (palabra, porcentaje_identidad, sinonimos) VALUES
('álgebra',95.00,ARRAY['algebra','algebras']),
('geometría',92.00,ARRAY['geometria','geometrico','geometrica']),
('cálculo',96.00,ARRAY['calculo','calculos']),
('topología',85.00,ARRAY['topologia','topologico']),
('combinatoria',88.00,ARRAY['combinatorio']),
('estadística',94.00,ARRAY['estadistica','estadistico','estadisticos']),
('probabilidad',94.00,ARRAY['probabilidades']),
('trigonometría',90.00,ARRAY['trigonometria']),
('aritmética',90.00,ARRAY['aritmetica']),
('logaritmo',86.00,ARRAY['logaritmos','log']),
('derivada',97.00,ARRAY['derivadas','derivar']),
('integral',97.00,ARRAY['integrales','integrar']),
('matriz',93.00,ARRAY['matrices']),
('vector',92.00,ARRAY['vectores','vectorial']),
('escalar',80.00,ARRAY['escalares']),
('tensor',88.00,ARRAY['tensores']),
('límite',95.00,ARRAY['limite','limites']),
('serie',85.00,ARRAY['series']),
('sucesión',84.00,ARRAY['sucesion','sucesiones']),
('polinomio',90.00,ARRAY['polinomios']),
('ecuación',92.00,ARRAY['ecuacion','ecuaciones']),
('función',93.00,ARRAY['funcion','funciones','funcional']),
('conjunto',91.00,ARRAY['conjuntos']),
('número',90.00,ARRAY['numero','numeros','numerico','numérico']),
('entero',86.00,ARRAY['enteros']),
('real',86.00,ARRAY['reales']),
('complejo',88.00,ARRAY['complejos','compleja']),
('racional',84.00,ARRAY['racionales']),
('irracional',84.00,ARRAY['irracionales']),
('primo',86.00,ARRAY['primos']),
('factor',82.00,ARRAY['factores','factorizar']),
('potencia',86.00,ARRAY['potencias']),
('exponente',84.00,ARRAY['exponentes','exponencial']),
('raíz',86.00,ARRAY['raiz','raíces','raices']),
('módulo',80.00,ARRAY['modulo','modular']),
('congruencia',82.00,ARRAY['congruencias']),
('algoritmo',88.00,ARRAY['algoritmos']),
('variable',86.00,ARRAY['variables']),
('constante',84.00,ARRAY['constantes']),
('parámetro',82.00,ARRAY['parametro','parametros','parametrica','paramétrica']),
('gradiente',86.00,ARRAY['gradientes']),
('divergencia',84.00,ARRAY['divergencias']),
('rotacional',82.00,ARRAY['rotacionales']),
('intervalo',84.00,ARRAY['intervalos']),
('dominio',84.00,ARRAY['dominios']),
('rango',82.00,ARRAY['rangos','imagen']),
('hipótesis',80.00,ARRAY['hipotesis']),
('teorema',90.00,ARRAY['teoremas']),
('axioma',88.00,ARRAY['axiomas']),
('lema',82.00,ARRAY['lemas']),
('corolario',82.00,ARRAY['corolarios']);

--------
INSERT INTO public.palabras_clave (palabra, porcentaje_identidad, sinonimos) VALUES
-- Lógica matemática
('lógica',90.00,ARRAY['logica','logicas','logico','logicos']),
('proposición',88.00,ARRAY['proposicion','proposiciones']),
('predicado',86.00,ARRAY['predicados']),
('cuantificador',84.00,ARRAY['cuantificadores']),
('tautología',86.00,ARRAY['tautologia','tautologias']),
('contradicción',86.00,ARRAY['contradiccion','contradicciones']),
('implicación',84.00,ARRAY['implicacion','implicaciones']),
('conjunción',84.00,ARRAY['conjuncion','conjunciones']),
('disyunción',84.00,ARRAY['disyuncion','disyunciones']),
('negación',84.00,ARRAY['negacion','negaciones']),
('equivalencia',84.00,ARRAY['equivalencias']),
('bicondicional',82.00,ARRAY['bicondicionales']),

-- Teoría de conjuntos
('subconjunto',84.00,ARRAY['subconjuntos']),
('unión',84.00,ARRAY['union','uniones']),
('intersección',84.00,ARRAY['interseccion','intersecciones']),
('complemento',82.00,ARRAY['complementos']),
('cardinalidad',82.00,ARRAY['cardinalidades']),
('partición',82.00,ARRAY['particion','particiones']),

-- Geometría básica
('triángulo',88.00,ARRAY['triangulo','triangulos']),
('cuadrado',88.00,ARRAY['cuadrados']),
('rectángulo',88.00,ARRAY['rectangulo','rectangulos']),
('círculo',88.00,ARRAY['circulo','circulos']),
('esfera',86.00,ARRAY['esferas']),
('cilindro',86.00,ARRAY['cilindros']),
('cono',84.00,ARRAY['conos']),
('pirámide',84.00,ARRAY['piramide','pirámides','pirámides']),
('ángulo',88.00,ARRAY['angulo','angulos']),
('perímetro',88.00,ARRAY['perimetro','perimetros']),
('área',90.00,ARRAY['area','areas']),
('volumen',90.00,ARRAY['volumenes']),
('radio',86.00,ARRAY['radios']),
('diámetro',86.00,ARRAY['diametro','diametros']),
('paralela',84.00,ARRAY['paralelas','paralelo','paralelos']),
('perpendicular',84.00,ARRAY['perpendiculares']),
('diagonal',84.00,ARRAY['diagonales']),

-- Cálculo y análisis
('continuidad',86.00,ARRAY['continuo','continua','continuas','continuos']),
('diferenciable',84.00,ARRAY['diferenciables']),
('creciente',84.00,ARRAY['crecientes']),
('decreciente',84.00,ARRAY['decrecientes']),
('máximo',86.00,ARRAY['maximo','maximos','máximos']),
('mínimo',86.00,ARRAY['minimo','minimos','mínimos']),
('optimización',86.00,ARRAY['optimizacion','optimizar','optimo','optimos']),
('convexo',84.00,ARRAY['convexa','convexos','convexas']),
('cóncavo',84.00,ARRAY['concavo','concavos','concava','concavas']),

-- Álgebra lineal
('determinante',90.00,ARRAY['determinantes']),
('autovalor',88.00,ARRAY['autovalores','valor_propio','valores_propios']),
('autovector',88.00,ARRAY['autovectores','vector_propio','vectores_propios']),
('base',84.00,ARRAY['bases']),
('dimensión',84.00,ARRAY['dimension','dimensiones']),
('subespacio',84.00,ARRAY['subespacios']),
('diagonalización',84.00,ARRAY['diagonalizacion','diagonalizar']),
('escalar_producto',82.00,ARRAY['producto_escalar','producto_interno']),

-- Ecuaciones y sistemas
('sistema',84.00,ARRAY['sistemas']),
('incógnita',84.00,ARRAY['incognita','incognitas']),
('inecuación',84.00,ARRAY['inecuacion','inecuaciones','desigualdad','desigualdades']),
('identidad',84.00,ARRAY['identidades']),
('gauss',82.00,ARRAY['gaussiana','gaussiano']),
('jacobi',82.00,ARRAY['metodo_jacobi']),
('seidel',82.00,ARRAY['gauss_seidel','seidel_gauss']),

-- Probabilidad y estadística
('media',90.00,ARRAY['promedio','promedios']),
('mediana',88.00,ARRAY['medianas']),
('moda',88.00,ARRAY['modas']),
('varianza',90.00,ARRAY['varianzas']),
('desviación',90.00,ARRAY['desviacion','desviaciones','desviacion_tipica']),
('distribución',88.00,ARRAY['distribucion','distribuciones']),
('normal',86.00,ARRAY['gaussiana','campana']),
('binomial',86.00,ARRAY['binomiales']),
('poisson',86.00,ARRAY['poissoniana']),
('muestra',88.00,ARRAY['muestras']),
('población',88.00,ARRAY['poblacion','poblaciones']),
('estimador',86.00,ARRAY['estimadores']),
('sesgo',84.00,ARRAY['sesgada','sesgado','sesgados','sesgadas']),
('error',84.00,ARRAY['errores']),
('intervalo_confianza',86.00,ARRAY['intervalo_de_confianza','intervalos_confianza']),

-- Números y estructuras
('par',84.00,ARRAY['pares']),
('impar',84.00,ARRAY['impares']),
('divisor',84.00,ARRAY['divisores']),
('múltiplo',84.00,ARRAY['multiplo','multiplos','múltiplos']),
('factorial',86.00,ARRAY['factoriales']),
('permutación',86.00,ARRAY['permutacion','permutaciones']),
('combinación',86.00,ARRAY['combinacion','combinaciones']),
('probabilidad_condicional',86.00,ARRAY['condicional','probabilidad_condicionada']),

-- Otras ramas
('fractal',82.00,ARRAY['fractales']),
('chaos',82.00,ARRAY['caos','caotico','caoticos']),
('transformada',84.00,ARRAY['transformadas']),
('fourier',84.00,ARRAY['transformada_fourier']),
('laplace',84.00,ARRAY['transformada_laplace']);

INSERT INTO public.palabras_clave (palabra, porcentaje_identidad, sinonimos) VALUES
('matemáticas', 99.00, ARRAY['matematicas','matematica','matematico','matematicos']);

----------

SELECT COUNT(*) FROM public.palabras_clave;           -- debe dar 50
SELECT * FROM public.palabras_clave ORDER BY palabra; -- lista
