# pages/home_page.rb

require_relative 'base_page'

module Pages
  # Pantalla de inicio: búsqueda inicial
  class HomePage < BasePage
    
    # Selectores
    SEARCH_BAR_ID = 'com.mercadolibre:id/ui_components_toolbar_search_field' # Barra de búsqueda
    SEARCH_INPUT_ID = 'com.mercadolibre:id/autosuggest_input_search'         # Campo de texto
    
    # Ejecuta una búsqueda
    def search_for(term)
      puts "Paso 2: Buscando el término: '#{term}'"
      
      # Abrir el campo de búsqueda
      find_and_wait(:id, SEARCH_BAR_ID).click

      sleep 1
      
      # Escribir y enviar
      search_input = find_and_wait(:id, SEARCH_INPUT_ID)
      search_input.send_keys(term)
      @driver.press_keycode(66) # ENTER
    end
  end
end