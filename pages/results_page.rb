# pages/results_page.rb

require_relative 'base_page'

module Pages
  class ResultsPage < BasePage
    
    # --- SELECTORES ALTERNATIVOS (¡AJUSTADOS SEGÚN TUS HALLAZGOS!) ---
    
    # 1. Botón de Filtros (No tiene ID, es un LinearLayout)
    # Estrategia: Buscar el elemento por su clase y, si tiene un texto o content-desc, usarlo.
    # Si es solo un LinearLayout, debemos buscar un elemento hijo que sí tenga algo único (icono, texto)
    # o usar un XPath absoluto/indexado si es el primer/único botón en esa barra.
    # Aquí asumimos que tiene una descripción o se puede encontrar por el texto 'Filtrar'.
    FILTER_BUTTON_XPATH = "//android.widget.TextView[contains(@text,'Filtros')]"
    
    # 2. Botón de Ordenar (No está en la página principal, se encuentra DENTRO del menú de Filtros)
    SORT_BUTTON_XPATH = "//android.widget.TextView[@text='Ordenar por']" 
    
    MODAL_TITLE_ID = "//android.widget.ListView[@resource-id='selectable']" 

    # 3. Datos del Producto
    ITEM_CONTAINER_ID = 'com.mercadolibre:id/item_card_container' # Asumimos que el contenedor SÍ tiene ID
    
    # Título (No tiene ID)
    # Estrategia: Buscar el primer TextView (o una clase similar) DENTRO del contenedor del producto.
    ITEM_TITLE_XPATH = ".//android.widget.TextView[1]" 
    
    # Precio (Sí tiene resource-id)
    ITEM_PRICE_ID = 'com.mercadolibre:id/current amount'
    
    # -----------------------------------------------
    
    def apply_filters_and_sort
      puts "Paso 3, 4 y 5: Aplicando filtros y ordenación..."
      
      # 1. Abrir filtros usando la nueva XPath
      find_and_wait(:xpath, FILTER_BUTTON_XPATH).click

      sleep 2

      puts " -> Buscado Modal."
      find_and_wait(:xpath, MODAL_TITLE_ID, 10) 
      puts "  -> Modal de filtros detectado."

      puts " -> Buscando Seleccionables."
      find_and_wait(:xpath, "//android.widget.ListView[@resource-id='selectable']")
      puts " -> Seleccionables detectados."

      sleep 2

      puts " -> Obteniendo Hijos."
      filters = @driver.find_elements(:xpath, "//android.widget.ListView[@resource-id='selectable']")
      if filters.length > 2
        puts " -> Hijos detectados."
      else
        puts " -> No se detectaron hijos."
      end

      # 2. Aplicar Condición "Nuevos" (Paso 3)
      puts "  -> Aplicando filtro: Condición 'Nuevo'"
      # Nota: Usamos XPath para categorías y opciones de filtro (el texto debe ser exacto)
      apply_specific_filter("selectable-4", "Nuevo")

      # 3. Aplicar Ubicación "CDMX" (Paso 4)
      puts "  -> Aplicando filtro: Envio 'Local'"
      apply_specific_filter("selectable-9", "Local") 
      
      # Volver a la pantalla de resultados (presionamos BACK o un botón "Aplicar" si existe)
      # Si la app tiene un botón "Aplicar" o "Ver resultados", debes usar su selector.
      # Usaremos BACK si la app navega de vuelta automáticamente.
      # @driver.press_keycode(4) 
      sleep 1
      find_and_wait(:xpath, "//android.widget.Button[@resource-id=':r3:']").click # Ejemplo común
      
      # 4. Ordenar por "Mayor a menor precio" (Paso 5)
      # Primero, volvemos a abrir la pantalla de filtros para acceder a la opción "Ordenar" (si no está visible)
      find_and_wait(:xpath, FILTER_BUTTON_XPATH).click
      
      # Toca el botón de Ordenar, que ahora se encuentra DENTRO del menú de filtros
      find_and_wait(:xpath, SORT_BUTTON_XPATH).click

      # Encontrar la opción de ordenamiento: Mayor precio
      find_and_wait(:xpath, "//android.widget.TextView[@text='Mayor precio']").click 
      
      # Volver a la pantalla de resultados
      find_and_wait(:xpath, "//android.widget.Button[@text='Ver resultados']").click # Ejemplo

    end
    
    def apply_specific_filter(category_text, option_text)
      # Encuentra la categoría (ej: Condición) y haz clic
      find_and_wait(:xpath, "//android.view.View[@resource-id='#{category_text}']").click

      sleep 0.5
      
      # Encuentra la opción (ej: Nuevo) y haz clic
      find_and_wait(:xpath, "//android.widget.ToggleButton[@text='#{option_text}']").click
    end

    def get_top_5_products
      products = []
      puts "\n--- Obteniendo los primeros 5 productos (Paso 6 y 7) ---"
      
      product_containers = @driver.find_elements(:id, ITEM_CONTAINER_ID)
      
      product_containers.first(5).each_with_index do |product_el, index|
        begin
          # Título: Buscar el TextView indexado dentro del contenedor
          name = product_el.find_element(:xpath, ITEM_TITLE_XPATH).text
          
          # Precio: Buscar por ID (recurso parcial)
          # NOTA: En Appium/Ruby, si solo tienes el resource-id parcial, a menudo funciona así:
          price = product_el.find_element(:id, ITEM_PRICE_ID).text 

          products << { name: name, price: price }
          
        rescue Selenium::WebDriver::Error::NoSuchElementError
          products << { name: "PRODUCTO NO ENCONTRADO", price: "N/A" }
        end
      end
      
      return products
    end
  end
end