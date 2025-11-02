# MercadoLibre Appium Test (Ruby)

Automatización de búsqueda en Mercado Libre usando Appium + Ruby:
- Abre la app de Mercado Libre en Android.
- Busca un término (ej. "playstation 5").
- Aplica filtros/ordenamiento.
- Extrae nombre y precio de los 5 primeros productos visibles (con swipes).

## Requerimientos
- Android SDK + adb en PATH (y un emulador o dispositivo físico)
- Node.js + npm
- Appium CLI
- Driver de Android para Appium: UiAutomator2
- Ruby (>= 3.1 recomendado) y Bundler

## Instalación
1) Android SDK/adb
- Instala Android Studio o SDK Tools y asegúrate de tener `adb` en PATH.
- Verifica con: `adb devices`

2) Node.js + Appium CLI
- Instala Node.js (https://nodejs.org)
- Instala Appium CLI: `npm i -g appium`
- Instala driver UiAutomator2: `appium driver install uiautomator2`
- Prueba Appium: `appium -v`

3) Ruby + dependencias
- Instala Ruby (Windows: RubyInstaller; Linux/macOS: gestor de paquetes o rbenv/rvm)
- En el proyecto, instala gems: `bundle install`

## Configuración
- Asegúrate de tener un emulador o dispositivo Android listo y con la app de Mercado Libre instalada.
- Variables de entorno opcionales:
  - `APPIUM_SERVER_URL` (por defecto `http://127.0.0.1:4723/`)
  - `ANDROID_DEVICE` (por defecto `Pixel 8a` en las caps del ejemplo)
  - `ANDROID_AVD` (para lanzar un AVD específico, ej. `Pixel_8_API_34`)

## Cómo ejecutar

### Opción 1: Windows (PowerShell)
- Abre PowerShell en la carpeta del proyecto.
- Permite ejecución temporal:
  - `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
- Ejecuta:
  - `./run_test_windows.ps1`
  - El script:
    - Arranca Appium en `127.0.0.1:4723` y espera readiness.
    - Ejecuta `mercadolibre_test.rb` con `bundle exec` si hay Gemfile.

### Opción 2: Linux/macOS (bash)
- Da permisos de ejecución: `chmod +x ./run_test_linux.sh`
- Ejecuta: `./run_test_linux.sh`
  - Inicia Appium y luego corre el test Ruby.

### Opción 3: Manual (para diagnóstico)
- Terminal 1: `appium -a 127.0.0.1 -p 4723`
- Terminal 2 (proyecto): `bundle exec ruby ./mercadolibre_test.rb`

## Qué hace el script
- Archivo principal: `mercadolibre_test.rb`
  - Configura capabilities para `com.mercadolibre`.
  - Inicia driver (UiAutomator2).
  - Activa la app y espera que esté en foreground.
  - HomePage: escribe el término en búsqueda y envía ENTER.
  - ResultsPage: aplica filtros/ordenamiento y obtiene top 5 productos, haciendo swipes seguros dentro del contenedor.

## Estructura relevante
- `mercadolibre_test.rb`: escenario de prueba y capabilities.
- `pages/base_page.rb`: utilidades básicas (espera, find).
- `pages/home_page.rb`: selectores y flujo de búsqueda.
- `pages/results_page.rb`: filtros, ordenamiento, y recolección de productos con swipe.
- `run_test_windows.ps1`: levanta Appium y ejecuta el test en Windows.
- `run_test_linux.sh`: idem para Linux/macOS.

## Troubleshooting
- Appium no arranca desde PowerShell
  - Verifica `where appium`. Si no aparece, `npm i -g appium` y abre una nueva terminal.
  - Instala el driver: `appium driver install uiautomator2`.
- El test no conecta a Appium
  - Abre `http://127.0.0.1:4723/status`. Debe responder JSON.
  - Revisa logs: `appium.out.log` y `appium.err.log` generados por `run_test_windows.ps1`.
- No abre la app o no detecta elementos
  - Asegúrate de que la app esté instalada en el emulador.
  - Puede haber pantallas de onboarding/permisos. Concédelos o indica los textos/ids para automatizar el cierre.
  - Ajusta `ANDROID_DEVICE`/`ANDROID_AVD` según tu entorno.

## Capturas y GIF de demostración
- Crea la carpeta `assets/` en la raíz del proyecto (no incluida por defecto).
- Coloca:
  - GIF principal de la ejecución: `assets/demo.gif`
  - Capturas opcionales:
    - `assets/01_home.png` (pantalla de inicio con barra de búsqueda)
    - `assets/02_results.png` (resultados con filtros aplicados)
    - `assets/03_products.png` (lista mostrando al menos 5 productos)

### Cómo referenciar en el README
- GIF en la portada:
  
  `![Demo de ejecución](assets/demo.gif)`

- Capturas en secciones:
  
  `![Home](assets/01_home.png)`
  
  `![Resultados](assets/02_results.png)`

## Notas
- Si tu app muestra un Activity de arranque distinto, actualiza `appActivity` en `mercadolibre_test.rb` (por ejemplo `com.mercadolibre.splash.SplashActivity`) o exporta `APP_ACTIVITY` y ajusta el script para leerlo.
- Para entornos lentos, incrementa tiempos de espera (`appWaitDuration`, esperas explícitas en el test).

## Salida de ejemplo (terminal)

```text
.\run_test_windows.ps1
==> Starting Appium...
-> Appium started with PID 17352
==> Running Ruby test...                                                                                                
C:/Ruby34-x64/lib/ruby/3.4.0/win32/registry.rb:2: warning: fiddle/import is found in fiddle, which will no longer be part of the default gems starting from Ruby 3.5.0.
You can add fiddle to your Gemfile or gemspec to silence this warning.
--- INICIANDO PRUEBA DE MERCADO LIBRE ---
Paquete actual: com.mercadolibre | Actividad: .navigation.activities.BottomBarActivity
Paso 2: Buscando el término: 'playstation 5'
Paso 3, 4 y 5: Aplicando filtros y ordenación...
 -> Buscado Modal.
  -> Modal de filtros detectado.
 -> Buscando Seleccionables.
 -> Seleccionables detectados.
 -> Obteniendo Hijos.
 -> No se detectaron hijos.
  -> Aplicando filtro: Condición 'Nuevo'
  -> Aplicando filtro: Envio 'Local'
 -> Scrollando hasta 'Ordenar por'
  -> Realizando scroll hasta el texto: 'Ordenar por' usando mobile:swipeGesture
 -> Scrollable encontrado con ID: selectable
  -> Elemento 'Ordenar por' visible tras 1 swipes.
 -> Aplicando filtro: Ordenar por 'Mayor precio'

--- Obteniendo los primeros 5 productos (Paso 6 y 7) ---
 -> Scrollable encontrado con ID: 00000000-0000-0208-0000-03a200000425
 -> Productos encontrados: 4
 -> Producto 1: Consola Sony Playstation 5 Digital Edición 30º Aniversario 1 Tb Gris - Gris
 -> Precio: 26,249 Pesos
 -> Producto 2: Sony Playstation 5 Slim Digital 1tb Edición 30 Aniversario + Unidad Lectora De Discos Para Ps5.
 -> Precio: 21,499 Pesos
 -> Producto 3: Playstation 5 Pro Playstation 5 Pro Sony 2024
 -> Precio: 20,000 Pesos
 -> Producto 4: Playstation Sony PlayStation 5 CFI-2014 Digital Slim Editio Color Gris
 -> Precio: 18,999 Pesos
 -> Realizando swipe por región SEGURA (l=108, t=1132, w=864, h=725) direction=up, percent=0.2
 -> Productos encontrados: 6
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
 -> Realizando swipe por región SEGURA (l=108, t=902, w=864, h=736) direction=up, percent=0.2
 -> Productos encontrados: 6
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
 -> Realizando swipe por región SEGURA (l=108, t=842, w=864, h=771) direction=up, percent=0.2
 -> Productos encontrados: 6
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
Error al obtener datos de un producto visible: An element could not be located on the page using the given search parameters.; For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#nosuchelementexception
 -> Realizando swipe por región SEGURA (l=108, t=834, w=864, h=775) direction=up, percent=0.2
 -> Productos encontrados: 6
 -> Producto 5: Sony Playstation 5 Digital Edición 30o Aniversario 1 Tb Gris
 -> Precio: 18,904 Pesos

--- RESULTADO FINAL DE PRODUCTOS ---
1. Nombre: Consola Sony Playstation 5 Digital Edición 30º Aniversario 1 Tb Gris - Gris
   Precio: 26,249 Pesos
2. Nombre: Sony Playstation 5 Slim Digital 1tb Edición 30 Aniversario + Unidad Lectora De Discos Para Ps5.
   Precio: 21,499 Pesos
3. Nombre: Playstation 5 Pro Playstation 5 Pro Sony 2024
   Precio: 20,000 Pesos
4. Nombre: Playstation Sony PlayStation 5 CFI-2014 Digital Slim Editio Color Gris
   Precio: 18,999 Pesos
5. Nombre: Sony Playstation 5 Digital Edición 30o Aniversario 1 Tb Gris
   Precio: 18,904 Pesos
-----------------------------------
✅ PRUEBA EJECUTADA CON ÉXITO.
Cerrando sesión...
```

> Nota: Los nombres y precios son de ejemplo. Pueden variar según el dispositivo, región y momento de ejecución.
