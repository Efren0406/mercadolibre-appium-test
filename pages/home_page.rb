# pages/home_page.rb

require_relative 'base_page'

module Pages
  # Representa la pantalla de inicio y el flujo de búsqueda inicial
  class HomePage < BasePage
    
    # --- SELECTORES (¡REEMPLAZA ESTOS VALORES!) ---
    SEARCH_BAR_ID = 'com.mercadolibre:id/ui_components_toolbar_search_field'     # ID de la barra de búsqueda inicial
    SEARCH_INPUT_ID = 'com.mercadolibre:id/autosuggest_input_search' # ID del campo de texto donde se escribe
    
    # -----------------------------------------------
    
    # Implementa el paso 2 del escenario: Buscar el término
    def search_for(term)
      puts "Paso 2: Buscando el término: '#{term}'"
      
      # 1. Toca la barra de búsqueda para ir a la pantalla de entrada
      find_and_wait(:id, SEARCH_BAR_ID).click

      sleep 1
      
      # 2. Escribe el término en el campo de texto
      search_input = find_and_wait(:id, SEARCH_INPUT_ID)
      search_input.send_keys(term)
      
      # 3. Presiona ENTER para iniciar la búsqueda (código de tecla 66 en Android)
      @driver.press_keycode(66)
    end
  end
end