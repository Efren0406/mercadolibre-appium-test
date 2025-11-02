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
    ITEM_CONTAINER_XPATH = "//android.view.View[@resource-id='polycard_component']" # Asumimos que el contenedor SÍ tiene ID
    
    # Título (No tiene ID)
    # Estrategia: Buscar el primer TextView (o una clase similar) DENTRO del contenedor del producto.
    ITEM_TITLE_XPATH = ".//android.widget.TextView[1]" 
    
    # Precio (Sí tiene resource-id)
    ITEM_PRICE_XPATH = './/android.widget.TextView[@resource-id="current amount"]'
    
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

      sleep 1

      puts " -> Scrollando hasta 'Ordenar por'"
      scroll_to_text_in_container("Ordenar por", "selectable")

      sleep 2

      # 4. Ordenar por "Mayor a menor precio" (Paso 5)
      puts " -> Aplicando filtro: Ordenar por 'Mayor precio'"
      apply_specific_filter("selectable-21", "Mayor precio") 
      
      # Volver a la pantalla de resultados (presionamos "Ver resultados" si existe)
      sleep 1
      find_and_wait(:xpath, "//android.widget.Button[@resource-id=':r3:']").click # Ejemplo común
    end
    
    def apply_specific_filter(category_text, option_text)
      # Encuentra la categoría (ej: Condición) y haz clic
      find_and_wait(:xpath, "//android.view.View[@resource-id='#{category_text}']").click

      sleep 0.5
      
      # Encuentra la opción (ej: Nuevo) y haz clic
      find_and_wait(:xpath, "//android.widget.ToggleButton[@text='#{option_text}']").click
    end
    
    def scroll_to_text_in_container(text, container_id = nil, direction = 'down')
        puts "  -> Realizando scroll hasta el texto: '#{text}' usando mobile:swipeGesture"
        
        # 1. Creamos el selector de destino (el elemento que queremos ver)
        # Usamos XPath, que es la forma más compatible de buscar por texto.
        target_selector = "//android.view.View[contains(@content-desc, '#{text}')]"
        
        # 2. El comando mobile:scroll requiere un elemento (el contenedor) para saber dónde scrollar.
        # Si se proporciona un ID, usamos ese contenedor; si no, buscamos el scrollable general.
        if container_id
          scrollable_element = find_and_wait(:xpath, "//android.widget.ListView[@resource-id='#{container_id}']") 
          puts " -> Scrollable encontrado con ID: #{container_id}"
        else
          # Si no hay ID, buscamos el primer elemento scrollable disponible (clase RecyclerView, ListView, etc.)
          scrollable_element = find_and_wait(:xpath, "//*[contains(@class, 'view') and @scrollable='true']") # Selector genérico de contenedor scrollable
        end

        # 1. Creamos el selector de destino (el elemento que queremos ver)
        # Ya no necesitamos crear una XPath compleja, solo la búsqueda por texto.
        # 4. Ejecutar gestos de swipe hasta encontrar el elemento o agotar intentos
        attempts = 8
        gesture_direction = case direction
                            when 'down' then 'up'   # Para desplazar el contenido hacia abajo, el gesto es hacia arriba
                            when 'up'   then 'down'
                            else direction
                            end

        attempts.times do |i|
          begin
            el = @driver.find_element(:xpath, target_selector)
            if el.displayed?
              puts "  -> Elemento '#{text}' visible tras #{i} swipes."
              return
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
            # Ignorar y realizar swipe
          end

          @driver.execute_script 'mobile: swipeGesture', {
            elementId: scrollable_element.id,
            direction: gesture_direction,
            percent: 0.75
          }
          sleep 0.3
        end

        # Intento final de verificación
        begin
          el = @driver.find_element(:xpath, target_selector)
          if el.displayed?
            puts "  -> Elemento '#{text}' visible al final de los swipes."
            return
          end
        rescue Selenium::WebDriver::Error::NoSuchElementError
        end

        raise Selenium::WebDriver::Error::NoSuchElementError, "No se encontró el texto '#{text}' después de swipes"
        
        puts "  -> Scroll ejecutado. El elemento '#{text}' debería ser visible."

    rescue Selenium::WebDriver::Error::NoSuchElementError
        # El elemento scrollable no fue encontrado o el texto final no apareció
        raise "Error: Falló al encontrar el contenedor scrollable o el texto '#{text}' no se hizo visible."
    rescue => e
        raise "Error al realizar scroll con 'mobile: swipeGesture': #{e.message}"
    end
    
    def get_top_5_products
      products = []
      puts "\n--- Obteniendo los primeros 5 productos (Paso 6 y 7) ---"

      seen_names = {}
      max_swipes = 8
      swipe_percent = 0.2
      swipe_pause = 0.6

      scrollable_element = nil
      begin
        scrollable_element = find_and_wait(:xpath, "//android.view.View[@resource-id='search_content']")
        puts " -> Scrollable encontrado con ID: #{scrollable_element.id}"
      rescue Selenium::WebDriver::Error::NoSuchElementError
      end

      tries = 0
      swipe_direction = 'up'
      while products.size < 5
        product_containers = @driver.find_elements(:xpath, ITEM_CONTAINER_XPATH)
        puts " -> Productos encontrados: #{product_containers.length}"

        collected_before = products.size
        product_containers.each do |product_el|
          break if products.size >= 5
          begin
            next unless product_el.displayed?
            name = product_el.find_element(:xpath, ITEM_TITLE_XPATH).text
            next if name.nil? || name.empty? || seen_names[name]
            price_el = nil
            begin
              price_el = product_el.find_element(:xpath, ITEM_PRICE_XPATH)
            rescue => _
            end
            price = nil
            begin
              price = price_el&.content_desc
            rescue => _
            end
            price ||= ''

            puts " -> Producto #{products.size + 1}: #{name}"
            puts " -> Precio: #{price}"
            products << { name: name, price: price }
            seen_names[name] = true
          rescue => e
            puts "Error al obtener datos de un producto visible: #{e.message}"
          end
        end

        break if products.size >= 5

        if scrollable_element && tries < max_swipes
          # Usar región del contenedor para asegurar el gesto dentro del viewport del listado
          args = { direction: swipe_direction, percent: swipe_percent }
          begin
            rect = scrollable_element.rect
            left = rect['x'] || rect[:x]
            top = rect['y'] || rect[:y]
            width = rect['width'] || rect[:width]
            height = rect['height'] || rect[:height]
            if left && top && width && height
              # Aplicar márgenes para evitar barras del sistema (nav/status) y bordes
              margin_x = (width * 0.10).to_i
              margin_y = (height * 0.30).to_i
              safe_left = left + margin_x
              safe_top = top + margin_y
              safe_width = [width - (margin_x * 2), 50].max
              safe_height = [height - (margin_y * 2), 50].max

              args[:left] = safe_left
              args[:top] = safe_top
              args[:width] = safe_width
              args[:height] = safe_height
              puts " -> Realizando swipe por región SEGURA (l=#{safe_left}, t=#{safe_top}, w=#{safe_width}, h=#{safe_height}) direction=#{swipe_direction}, percent=#{swipe_percent}"
            else
              args[:elementId] = scrollable_element.id
              puts " -> Realizando swipe por elementId direction=#{swipe_direction}, percent=#{swipe_percent}"
            end
          rescue => _
            args[:elementId] = scrollable_element.id
            puts " -> Realizando swipe por elementId (fallback) direction=#{swipe_direction}, percent=#{swipe_percent}"
          end
          @driver.execute_script 'mobile: swipeGesture', args
          sleep swipe_pause
          tries += 1
        else
          break
        end
      end

      return products
    end
  end
end