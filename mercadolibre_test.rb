# mercadolibre_test.rb

require 'bundler/setup'
require_relative 'pages/home_page'
require_relative 'pages/results_page'

# --- 1. CONFIGURACIÓN DEL DRIVER (Revisa y confirma estos valores) ---
CAPS = {
  caps: {
    platformName: 'Android',
    deviceName: ENV['ANDROID_DEVICE'] || 'Pixel 8a',
    automationName: 'UiAutomator2',
    appPackage: 'com.mercadolibre',
    appActivity: 'com.mercadolibre.splash.SplashActivity',
    appWaitActivity: 'com.mercadolibre.*',
    appWaitDuration: 30000,
    appWaitForLaunch: true,
    autoGrantPermissions: true,
    noReset: true,
    newCommandTimeout: 300
  },
  appium_lib: {
    server_url: ENV['APPIUM_SERVER_URL'] || 'http://127.0.0.1:4723/'
  }
}

# Si se define ANDROID_AVD, usarlo para arrancar un emulador específico
if ENV['ANDROID_AVD'] && !ENV['ANDROID_AVD'].empty?
  CAPS[:caps][:avd] = ENV['ANDROID_AVD']
end

def start_driver
  Appium::Driver.new(CAPS, true).start_driver
end

# --- 2. ESCENARIO DE PRUEBA ---
def mobile_automation_test
  puts "--- INICIANDO PRUEBA DE MERCADO LIBRE ---"
  driver = start_driver
  begin
    # Asegurar que la app esté activa en primer plano
    driver.activate_app('com.mercadolibre')
  rescue => e
    puts "Aviso: no se pudo activar la app explícitamente: #{e.message}"
  end
  sleep 2
  # Esperar a que la app esté lista en foreground
  begin
    wait_deadline = Time.now + 20
    loop do
      pkg = driver.current_package rescue nil
      act = driver.current_activity rescue nil
      puts "Paquete actual: #{pkg} | Actividad: #{act}"
      break if pkg == 'com.mercadolibre'
      break if Time.now > wait_deadline
      sleep 1
    end
  rescue => e
    puts "Aviso: no se pudo obtener package/activity: #{e.message}"
  end
  
  # Inicializar Page Objects
  home_page = Pages::HomePage.new(driver)
  results_page = Pages::ResultsPage.new(driver)

  # Esperar explícitamente a que exista la barra de búsqueda; si no, forzar activity de inicio
  begin
    Selenium::WebDriver::Wait.new(timeout: 20).until {
      driver.find_element(:id, 'com.mercadolibre:id/ui_components_toolbar_search_field')
    }
  rescue => _
    puts "No se detectó la barra de búsqueda aún. Intentando lanzar SplashActivity..."
    begin
      driver.start_activity('com.mercadolibre', 'com.mercadolibre.splash.SplashActivity')
    rescue => e
      puts "Aviso start_activity: #{e.message}"
    end
    sleep 2
  end

  begin
    # PASO 1 y 2
    home_page.search_for("playstation 5")

    # PASOS 3, 4 y 5
    results_page.apply_filters_and_sort

    # PASOS 6 y 7
    products = results_page.get_top_5_products
    
    puts "\n--- RESULTADO FINAL DE PRODUCTOS ---"
    products.each_with_index do |product, index|
      puts "#{index + 1}. Nombre: #{product[:name]}"
      puts "   Precio: #{product[:price]}"
    end
    puts "-----------------------------------"
    
    puts "✅ PRUEBA EJECUTADA CON ÉXITO."

  rescue => e
    puts "❌ ERROR EN LA PRUEBA: #{e.message}"
    puts "  -> Trazabilidad: #{e.backtrace.first(5).join("\n  -> ")}"
    
  ensure
    puts "Cerrando sesión..."
    driver.quit if driver
  end
end

mobile_automation_test