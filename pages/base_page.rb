# pages/base_page.rb

require 'appium_lib'
require 'selenium-webdriver'

module Pages
  # Clase base para todos los Page Objects
  class BasePage
    attr_reader :driver

    # El constructor recibe la instancia del driver de Appium
    def initialize(driver)
      @driver = driver
    end

    # Método robusto para encontrar un elemento con espera explícita
    # Se usa para evitar fallos cuando un elemento tarda en cargarse (Buena Práctica)
    def find_and_wait(locator_type, locator_value, timeout = 15)
      # Crea una instancia de espera de Selenium
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      
      # Espera hasta que el elemento sea encontrado
      wait.until { @driver.find_element(locator_type, locator_value) }
    rescue Selenium::WebDriver::Error::NoSuchElementError
      # Manejo de error si el elemento no se encuentra después del tiempo de espera
      raise "Error: Elemento con #{locator_type}='#{locator_value}' no encontrado después de #{timeout} segundos."
    end
    
    # Un método útil para hacer scroll si fuera necesario (no lo necesitamos aquí, pero es una buena práctica)
    def scroll_to(text)
      @driver.find_element(:ui_automator, "new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollIntoView(new UiSelector().text(\"#{text}\").instance(0))")
    end
  end
end