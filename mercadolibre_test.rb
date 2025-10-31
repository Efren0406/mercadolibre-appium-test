# mercadolibre_test.rb

require 'bundler/setup'
require_relative 'pages/home_page'
require_relative 'pages/results_page'

# --- 1. CONFIGURACIÓN DEL DRIVER (Revisa y confirma estos valores) ---
CAPS = {
  caps: {
    platformName: 'Android',
    deviceName: 'Pixel 8a',
    platformVersion: '16', 
    automationName: 'UiAutomator2',
    appPackage: 'com.mercadolibre',
    appActivity: 'com.mercadolibre.activities.HomeActivity',
    noReset: true,
    newCommandTimeout: 300
  },
  appium_lib: {
    server_url: 'http://127.0.0.1:4723/'
  }
}

def start_driver
  Appium::Driver.new(CAPS, true).start_driver
end

# --- 2. ESCENARIO DE PRUEBA ---
def mobile_automation_test
  puts "--- INICIANDO PRUEBA DE MERCADO LIBRE ---"
  driver = start_driver
  
  # Inicializar Page Objects
  home_page = Pages::HomePage.new(driver)
  results_page = Pages::ResultsPage.new(driver)

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