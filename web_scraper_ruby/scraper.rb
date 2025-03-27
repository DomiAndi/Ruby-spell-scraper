require "net/http"
require "json"
require "csv"
require "sqlite3"

URL = "https://api.open5e.com/spells/"

def fetch_spells
  uri = URI(URL)
  response = Net::HTTP.get(uri)
  JSON.parse(response)["results"]
end

def save_to_csv(data, filename = "spells.csv")
  CSV.open(filename, "w", write_headers: true, headers: ["Nombre", "Nivel", "Escuela", "Descripción", "Enlace"]) do |csv|
    data.each do |spell|
      csv << [spell["name"], spell["level"], spell["school"], spell["desc"], spell["dnd_class"]]
    end
  end
  puts "✅ Datos guardados en #{filename}"
end

def save_to_db(data)
  db = SQLite3::Database.new "spells.db"

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS spells (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      level TEXT,
      school TEXT,
      description TEXT,
      dnd_class TEXT
    );
  SQL

  data.each do |spell|
    db.execute "INSERT INTO spells (name, level, school, description, dnd_class) VALUES (?, ?, ?, ?, ?)",
               [spell["name"], spell["level"], spell["school"], spell["desc"], spell["dnd_class"]]
  end

  puts "✅ Datos guardados en la base de datos."
end

# Ejecutar el scraper con la API
spells = fetch_spells
save_to_csv(spells)
save_to_db(spells)