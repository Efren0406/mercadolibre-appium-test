# pages/base_page.rb

require 'appium_lib'
require 'selenium-webdriver'

module Pages
  # Clase base de Page Objects
  class BasePage
    attr_reader :driver

    # Recibe la instancia del driver
    def initialize(driver)
      @driver = driver
    end

    # Encuentra un elemento con espera explícita
    def find_and_wait(locator_type, locator_value, timeout = 15)
      wait = Selenium::WebDriver::Wait.new(timeout: timeout)
      wait.until { @driver.find_element(locator_type, locator_value) }
    rescue Selenium::WebDriver::Error::NoSuchElementError
      raise "Error: Elemento con #{locator_type}='#{locator_value}' no encontrado después de #{timeout} segundos."
    end
    
    # Scroll hasta un texto usando UiScrollable
    def scroll_to(text)
      @driver.find_element(:ui_automator, "new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollIntoView(new UiSelector().text(\"#{text}\").instance(0))")
    end
  end
end