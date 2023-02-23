class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  # This code creates a table in a database called 'dogs' with three columns: id, name, and breed.
  # The id column is set to be the primary key for the table.
  # If the table already exists, it will not be recreated.
  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
                )
            SQL
    DB[:conn].execute(sql)
  end

  # This code is a method that is used to drop a table from a database.
  # The method takes the name of the table as an argument, in this case "dogs".
  # It then creates an SQL statement to drop the table and executes it using the DB[:conn] connection.
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  # This code is a method that saves a dog object to the database.
  # If the dog object already has an id (meaning it already exists in the database), it will update the existing record.
  # Otherwise, it will create a new record in the database for that dog object.
  # The method returns the dog object with its id set if it was created.

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  # This code creates a new instance of the Dog class, with the given name and breed.
  # It then saves the new instance to the database.

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  # This code is a method for a class. It takes in an argument of row which is an array of data.
  # The method then creates a new instance of the class with the data from the row array, assigning each element to its respective attribute (id, name, breed).
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  # This code is a class method of the Dog class.
  # It uses SQL to select all of the records from the dogs table in the database and then creates a new instance of the Dog class for each row returned.
  # The new_from_db method is used to create each instance with the data from the row.
  def self.all
    sql = <<-SQL
            SELECT *
            FROM dogs;
        SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  # This code is a class method of the Dog class.
  # It takes in a name as an argument and uses an SQL query to search the dogs table for a row with that name.
  # If it finds one, it creates a new instance of the Dog class using the data from that row and returns it.
  # If no row is found, it returns nil.
  def self.find_by_name(name)
    sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.name = ?
            LIMIT 1;
        SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # This code is a method for finding a dog in the database by its id.
  # It begins by creating a SQL query that selects all columns from the dogs table where the id matches the given argument.
  # It then uses the DB[:conn] object to execute the query and map each row to a new instance of self (the Dog class).
  # Finally, it returns the first result of this mapping.
  def self.find(id)
    sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.id = ?
            LIMIT 1;
        SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  # This code is a class method that is used to find or create a dog object in the database.
  # It takes two arguments, name and breed, and uses them to query the database for a row with matching values.
  # If a row is found, it will create a new instance of the Dog class using the row data.
  # If no row is found, it will create a new dog object in the database with the given name and breed.
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            LIMIT 1
        SQL

    row = DB[:conn].execute(sql, name, breed).first

    if row
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

  # This code is a method that updates the name and breed of a dog in a database.
  # The method takes three arguments: self.name, self.breed, and self.id.
  # It then creates an SQL statement that updates the dogs table in the database with the new name and breed values for the row with the specified id.
  # Finally, it executes the SQL statement using DB[:conn].execute() to make the changes in the database.
  def update
    sql = <<-SQL
            UPDATE dogs 
            SET 
                name = ?, 
                breed = ?  
            WHERE id = ?;
        SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
