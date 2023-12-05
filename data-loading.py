import pg8000
from pg8000.native import Connection, identifier, literal
import getpass
import re
import traceback

# imports for type annotations
from pg8000 import Connection, Cursor
from typing import List, Tuple, Optional

# Things to keep in mind:
# 1. We are using the 'dbapi' interface to pg8000, as described here:
#      https://github.com/tlocke/pg8000#db-api-2-docs
# 2. You will need to use the 'cursor' object to execute queries.
# 3. Don't forget to create the tables and insert the data from the lab7setup.sql file!
# 4. Don't forget to get a new cursor from the connection for each query
# 5. Don't forget to commit your changes to the database after each update
# 6. Don't forget to rollback your changes if an error occurs
# 7. Make sure your personal schema is at the beginning of your search path
def get_id_from_show_and_number(db: Connection, show: str, target_season: str, target_episode_in_season: str) -> str:
    cursor=db.cursor()
    table = table_from_show(show) + '_episodes'
    try:
        cursor.execute(f"""SELECT id,title FROM {identifier(table)} WHERE season = %s AND episode_in_season = %s""", (target_season, target_episode_in_season))
        id,title = str(cursor.fetchone())
        print("Found matching episode in database: \"" + title + "\" with id " + id)
        return id
    except pg8000.Error as e:
        print("Database error\n")
        print(e)
        traceback.print_exc()
        return "-1"

def table_from_show(name: str) -> str:
    return re.sub(r'[^a-zA-Z0-9]+', '_', name.lower())


def show_has_table(db: Connection, name: str) -> bool:
    table = table_from_show(name) + "_episodes"
    if table == None:
        return False
    cursor=db.cursor()
    try:
        cursor.execute(f"""SELECT (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_type = 'BASE TABLE' AND table_name = {literal(table)}))""")
        return cursor.fetchone()[0]
    except pg8000.Error as e:
        print("Database error\n")
        print(e)
        traceback.print_exc()
        return False
    
    

def new_table(db: Connection):
    """
    Inserts a table for a new show into the database. Does not return anything.
    """
    show = input("Show name: ")
    if show_has_table(db, show):
        print("Show already exists")
        return []
    cursor=db.cursor()
    show = table_from_show(show)
    show_episodes = show + "_episodes"
    show_ratings = show + "_ratings"
    show_writers = show + "_episode_writers"
    foreign_ratings_name = "FK_" + show_ratings
    foreign_writers_name = "FK_" + show_writers
    foreign_reference = show + "_episodes"
    unique_name = "UC_" + show_episodes

    try:
        cursor.execute(f"""CREATE TABLE {identifier(show_episodes)} (
        id SERIAL PRIMARY KEY,
        season NUMERIC(1) NOT NULL,
        episode_in_season NUMERIC(3) NOT NULL,
        episode_overall NUMERIC(4) NOT NULL UNIQUE,
        title TEXT,
        director TEXT,
        air_date DATE,
        prod_code TEXT,
        us_viewers INT,
        CONSTRAINT {identifier(unique_name)} UNIQUE (season, episode_in_season)
        )
        """)
        cursor.execute(f"""ALTER TABLE {"f23_group2." + identifier(show_episodes)} OWNER TO f23_group2""")
        cursor.execute(f"""DROP TABLE IF EXISTS {identifier(show_writers)} CASCADE""")
        cursor.execute(f"""CREATE TABLE {identifier(show_writers)} (
            name TEXT,
            episode_id SERIAL,
            CONSTRAINT {identifier(foreign_writers_name)} FOREIGN KEY (episode_id) REFERENCES {identifier(foreign_reference) + "(id)"}
        )
        """)
        cursor.execute(f"""ALTER TABLE {"f23_group2." + identifier(show_writers)} OWNER TO f23_group2""")
        cursor.execute(f"""DROP TABLE IF EXISTS {identifier(show_ratings)} CASCADE""")
        cursor.execute(f"""CREATE TABLE {identifier(show_ratings)} (
            episode_id SERIAL PRIMARY KEY,
            CONSTRAINT {identifier(foreign_ratings_name)} FOREIGN KEY (episode_id) REFERENCES {identifier(foreign_reference) + "(id)"},
            rating FLOAT,
            total_votes NUMERIC(5),
            description TEXT
        )
        """)
        cursor.execute(f"""ALTER TABLE {"f23_group2." + identifier(show_ratings)} OWNER TO f23_group2""")
        db.commit()
    except pg8000.Error as e:
        print("Database error\n")
        print(e)
        traceback.print_exc()
        return []
        
    
    print('Save new show: ' + show)


def insert_episode(db: Connection, show: str, season: str, episode_in_season: str, episode_overall: str, title: str, writers: List[str], director: str, air_date: str, prod_code: str, us_viewers: str):
    """
    NEEDS TEST
    Inserts a new episode with the given info into the database.
    Does not return anything.
    """
    try:
        cursor=db.cursor()
        table = table_from_show(show)
        cursor.execute(f"""INSERT INTO {identifier(table) + "_episodes"} (season, episode_in_season, episode_overall, title, director, air_date, prod_code, us_viewers)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""", (season, episode_in_season, episode_overall, title, director, air_date, prod_code, us_viewers))
        cursor.execute(f"""SELECT id FROM {identifier(table) + "_episodes"} WHERE season = %s AND episode_in_season = %s""", (season,episode_in_season))
        result = cursor.fetchone()[0]
        for writer in writers:
            cursor.execute(f"""INSERT INTO {identifier(table) + "_episode_writers"} (name, episode_id) VALUES (%s, %s)""",(writer, result))
        cursor.execute(f"""INSERT INTO {identifier(table) + "_ratings"} (episode_id) VALUES (%s)""",(result,)) 
        db.commit()
        print('Save new episode of \"' + show + '\": S' + season + 'E' + episode_in_season + ' ' + '\"' + title + '\"')
    except pg8000.Error as e:
        db.rollback()
        print("Show does not exist or season and episode number already exist.")
        traceback.print_exc()
        print(e)


def update_episode_info(db: Connection, show: str, episode_id: str, column_name: str, value: str):
    """
    NEEDS TEST
    Updates the episode info with the given id to have the given properties. Cannot update writers Does not return anything.
    """
    try:
        cursor=db.cursor()
        table = table_from_show(show)
        
        #Which table has the column we want to update?
        ratings_column_search = """SELECT column_name FROM information_schema.columns
        WHERE table_name = %s
        """
        cursor.execute(ratings_column_search, (table + "_ratings",))
        ratings_columns = [sublist[0] for sublist in cursor.fetchall()]
        episode_column_search = """SELECT column_name FROM information_schema.columns
        WHERE table_name = %s
        """
        cursor.execute(episode_column_search, (table + "_episodes",))
        episode_columns = [sublist[0] for sublist in cursor.fetchall()]
        if column_name == "id" or column_name == "episode_id":
            print("You may not modify this column")
            return
        elif column_name in ratings_columns:
            cursor.execute(f"""UPDATE {identifier(table) + "_ratings"} SET {identifier(column_name)} = {literal(value)}
                   WHERE episode_id = {literal(episode_id)}""")
        elif column_name in episode_columns:
            cursor.execute(f"""UPDATE {identifier(table) + "_ratings"} SET {identifier(column_name)} = {literal(value)}
                   WHERE id = {literal(episode_id)}""")
        else:
            print("Invalid column")
            return
        
        
        db.commit()
        print('Updated value \"' + column_name + '\" of ' + ' episode ' + episode_id + ' of ' + show + ' to \"' + value + '\"')
    except pg8000.Error as e:
        db.rollback()
        print("Episode does not exist (invalid id), or not properly implemented.")
        print('Details: Could not update value \"' + column_name + '\" of episode ' + episode_id + ' of ' + show + ' to \"' + value + '\"')
        traceback.print_exc()
        print(e)


def delete_episode(db: Connection, show: str, episode_id: str):
    """
    NEEDS TEST
    Deletes the episode of the given show. Does not return anything.
    """
    try:
        cursor=db.cursor()
        table = table_from_show(show)
        cursor.execute(f"""DELETE FROM {identifier(table + "_ratings")}
                    WHERE episode_id = {literal(episode_id)}""")
        cursor.execute(f"""DELETE FROM {identifier(table + "_episode_writers")}
                    WHERE episode_id = {literal(episode_id)}""")
        cursor.execute(f"""DELETE FROM {identifier(table + "_episodes")}
                    WHERE id = {literal(episode_id)}""")
        db.commit()
        print('Delete episode: ' + episode_id)
    except pg8000.Error as e:
        db.rollback()
        print("Episode does not exist (invalid episode id), show does not exist, or not properly implemented.")
        print('Details: ID: ' + episode_id + ' Show: ' + show)
        print(e)

def get_connection() -> Optional[Connection]:
    """
    Creates a connection to the database
    """
    # get the username and password
    username = input('Username: ')
    password = getpass.getpass('Password: ')

    # connect to the database
    credentials = {
        'user': username,
        'password': password,
        'database': 'csci403',
        'port': 5433,
        'host': 'codd.mines.edu'
    }
    try:
        db = pg8000.connect(**credentials)
        # do not change the autocommit line below or set autocommit to true in your solution
        # this lab requires you add appropriate db.commit() calls
        db.autocommit = False
    except pg8000.Error as e:
        print(f'Authentication failed for user "{username}" (error: {e})\n')
        return None

    return db

def insert(db: Connection):
    """
    NEEDS TEST
    Inserts new episodes into the database.
    """
    while True:
        show = input('Show name: ')
        if show_has_table(db, show):
            #Get properties
            season = input('Enter season (REQUIRED): ')
            episode = input('Enter episode number in season (REQUIRED): ')
            episode_overall = input('Enter overall episode number (REQUIRED): ')
            title = input('Enter episode title: ')
            writer_raw = input('Enter writers, separated by commas: ')
            writer = [item.lstrip() for item in writer_raw.split(',')]
            director = input('Enter director: ')
            air_date = input('Enter air date (yyyy-mm-dd): ')
            prod_code = input('Enter production code: ')
            us_viewers = input('Enter US viewers: ')
            #show: str, season: str, episode_in_season: str, episode_overall: str, title: str, writer: str[], director: str, air_date: str, prod_code: str, us_viewers: str
            insert_episode(db, show, season, episode, episode_overall, title, writer, director, air_date, prod_code, us_viewers)
            break
        else:
            print('Invalid show: \"' + show + '\". Try again.')
        print(' ')


def update(db: Connection):
    """
    NEEDS TEST
    Updates an episode in the database.
    """
    while True:
        show = input('Show name: ')
        if show == '':
            return
        if show_has_table(db, show):
            season = input('Enter season of episode to update: ')
            episode = input('Enter episode number in season to update: ')
            episode_id = get_id_from_show_and_number(db, show, season, episode)
            if episode_id == None:
                print('Invalid season/episode combination')
                continue
            column_name = input('Enter column to update: ')
            value = input('Enter new value: ')
            update_episode_info(db, show, episode_id, column_name, value)
            break
        else:
            print('Invalid show: \"' + show + '\". Try again.')
        print(' ')
    


def delete(db: Connection):
    """
    NEEDS TEST
    Deletes an episode or table from the database.
    """
    show = input('Enter show: ')
    if show_has_table(db, show):
        season = input('Enter season of episode to delete: ')
        episode = input('Enter episode number in season to delete: ')
        episode_id = get_id_from_show_and_number(db, show, season, episode)
        if episode_id == None:
            print('Invalid season/episode combination')
        else:
            delete_episode(db, show, episode_id)
    
    
def cli():
    """
    Runs the command line interface.
    """
    # connect to the database. Loop until we get a db object.
    # This tells us that the user has successfully logged in.
    while True:
        db = get_connection()
        if db is not None:
            break
    db.run("SET search_path TO f23_group2")

    # main loop
    while True:
        choice = input('New table (N)\nInsert (I)\nUpdate episode info (U)\nDelete (D)\nQuit (Q)\n> ').lower()
        if choice == 'n':
            new_table(db)
        elif choice == 'i':
            insert(db)
        elif choice == 'u':
            update(db)
        elif choice == 'd':
            delete(db)
        elif choice == 'q':
            print(" ")
            break
        else:
            print("Invalid choice. Try again.")
        print(" ")

if __name__ == '__main__':
    cli()
