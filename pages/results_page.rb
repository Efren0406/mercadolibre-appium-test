# pages/results_page.rb

require_relative 'base_page'

module Pages
  class ResultsPage < BasePage
    
    # Selectores principales
    FILTER_BUTTON_XPATH = "//android.widget.TextView[contains(@text,'Filtros')]"
    
    # Botón de Ordenar dentro del modal de Filtros
    SORT_BUTTON_XPATH = "//android.widget.TextView[@text='Ordenar por']" 
    
    MODAL_TITLE_ID = "//android.widget.ListView[@resource-id='selectable']" 

    # Datos del producto
    ITEM_CONTAINER_XPATH = "//android.view.View[@resource-id='polycard_component']" # Asumimos que el contenedor SÍ tiene ID
    
    # Título (primer TextView dentro del contenedor)
    ITEM_TITLE_XPATH = ".//android.widget.TextView[1]" 
    
    # Precio (resource-id)
    ITEM_PRICE_XPATH = './/android.widget.TextView[@resource-id="current amount"]'
    
    # -----------------------------------------------
    
    def apply_filters_and_sort
      puts "Paso 3, 4 y 5: Aplicando filtros y ordenación..."
      
      # Abrir filtros
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

      # Condición "Nuevo"
      puts "  -> Aplicando filtro: Condición 'Nuevo'"
      # Nota: Usamos XPath para categorías y opciones de filtro (el texto debe ser exacto)
      apply_specific_filter("selectable-4", "Nuevo")

      # Envío "Local"
      puts "  -> Aplicando filtro: Envio 'Local'"
      apply_specific_filter("selectable-9", "Local") 

      sleep 1

      puts " -> Scrollando hasta 'Ordenar por'"
      scroll_to_text_in_container("Ordenar por", "selectable")

      sleep 2

      # Ordenar por "Mayor precio"
      puts " -> Aplicando filtro: Ordenar por 'Mayor precio'"
      apply_specific_filter("selectable-21", "Mayor precio") 
      
      # Volver a resultados ("Ver resultados" si existe)
      sleep 1
      find_and_wait(:xpath, "//android.widget.Button[@resource-id=':r3:']").click # Ejemplo común
    end
    
    def apply_specific_filter(category_text, option_text)
      # Click en categoría
      find_and_wait(:xpath, "//android.view.View[@resource-id='#{category_text}']").click

      sleep 0.5
      
      # Click en opción
      find_and_wait(:xpath, "//android.widget.ToggleButton[@text='#{option_text}']").click
    end
    
    def scroll_to_text_in_container(text, container_id = nil, direction = 'down')
        puts "  -> Realizando scroll hasta el texto: '#{text}' usando mobile:swipeGesture"
        # Objetivo por texto
        target_selector = "//android.view.View[contains(@content-desc, '#{text}')]"
        # Contenedor scrollable por ID o genérico
        if container_id
          scrollable_element = find_and_wait(:xpath, "//android.widget.ListView[@resource-id='#{container_id}']") 
          puts " -> Scrollable encontrado con ID: #{container_id}"
        else
          scrollable_element = find_and_wait(:xpath, "//*[contains(@class, 'view') and @scrollable='true']") # Selector genérico de contenedor scrollable
        end

        # Swipes hasta encontrar el elemento o agotar intentos
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
            # Ignorar y hacer swipe
          end

          @driver.execute_script 'mobile: swipeGesture', {
            elementId: scrollable_element.id,
            direction: gesture_direction,
            percent: 0.75
          }
          sleep 0.3
        end

        # Verificación final
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
        # No se encontró contenedor o texto
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