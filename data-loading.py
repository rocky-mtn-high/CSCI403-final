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

def insert_episode(db: Connection, show: str, season: str, episode_in_season: str, title: str, writers: List[str], director: str, air_date: str, us_viewers: str):
    """
    Inserts a new episode with the given info into the database.
    Does not return anything.
    """
    try:
        cursor=db.cursor()
        cursor.execute(f"""INSERT INTO episode (show, season, episode_in_season, title, director, air_date, us_viewers)
                           VALUES (%s,%s,%s,%s,%s,%s,%s)""", (show, season, episode_in_season, title, director, air_date, us_viewers))
        for writer in writers:
            cursor.execute(f"""INSERT INTO episode_writer (name, episode_show, episode_season, episode_episode_in_season) VALUES (%s, %s, %s, %s)""",(writer, show, season, episode_in_season))
        db.commit()
        print('Save new episode of \"' + show + '\": S' + season + 'E' + episode_in_season + ' ' + '\"' + title + '\"')
    except pg8000.Error as e:
        db.rollback()
        print("Show, season, and episode number combination already exists.")
        traceback.print_exc()
        print(e)


def update_episode_info(db: Connection, show: str, season: str, episode_in_season: str, column_name: str, value: str):
    """
    Updates the episode info with the given id to have the given properties. Cannot update writers Does not return anything.
    """
    try:
        cursor=db.cursor()
        
        #Which table has the column we want to update?
        episode_column_search = """SELECT column_name FROM information_schema.columns
                                   WHERE table_name = 'episode'"""
        cursor.execute(episode_column_search)
        episode_columns = [sublist[0] for sublist in cursor.fetchall()]
        if column_name == "id" or column_name == "episode_id":
            print("You may not modify this column")
            return
        elif column_name in episode_columns:
            cursor.execute(f"""UPDATE episode SET {identifier(column_name)} = {literal(value)}
                               WHERE show = {literal(show)} AND season = {literal(season)} AND episode_in_season = {literal(episode_in_season)}""")
        else:
            print("Invalid column")
            return
        
        
        db.commit()
        print('Updated value \"' + column_name + '\" of ' + ' episode ' + episode_in_season + ' of season ' + season + ' of ' + show + ' to \"' + value + '\"')
    except pg8000.Error as e:
        db.rollback()
        print("Episode does not exist.")
        print('Details: Could not update value \"' + column_name + '\" of episode ' + episode_in_season + ' of season ' + season + ' of ' + show + ' to \"' + value + '\"')
        traceback.print_exc()
        print(e)


def delete_episode(db: Connection, show: str, season: str, episode_in_season: str):
    """
    Deletes the episode of the given show. Does not return anything.
    """
    try:
        cursor=db.cursor()
        cursor.execute(f"""DELETE FROM episode_writer
                           WHERE episode_show = {literal(show)} AND episode_season = {literal(season)} AND episode_episode_in_season = {literal(episode_in_season)}""")
        cursor.execute(f"""DELETE FROM episode
                           WHERE show = {literal(show)} AND season = {literal(season)} AND episode_in_season = {literal(episode_in_season)}""")
        db.commit()
        print('Delete episode: Show: ' + show + ' Season: ' + season + ' Episode in Season: ' + episode_in_season)
    except pg8000.Error as e:
        db.rollback()
        print("Episode does not exist.")
        print('Details: Show: ' + show + ' Season: ' + season + ' Episode in Season: ' + episode_in_season)
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
    Inserts new episodes into the database.
    """
    show = input('Show name: ')
    season = input('Enter season (REQUIRED): ')
    episode = input('Enter episode number in season (REQUIRED): ')
    title = input('Enter episode title: ')
    writer_raw = input('Enter writers, separated by commas: ')
    writer = [item.lstrip() for item in writer_raw.split(',')]
    director = input('Enter director: ')
    air_date = input('Enter air date (yyyy-mm-dd): ')
    us_viewers = input('Enter US viewers: ')
    insert_episode(db, show, season, episode, title, writer, director, air_date, us_viewers)
    print(' ')


def update(db: Connection):
    """
    Updates an episode in the database.
    """
    show = input('Show name: ')
    season = input('Enter season of episode to update: ')
    episode = input('Enter episode number in season to update: ')
    column_name = input('Enter column to update: ')
    value = input('Enter new value: ')
    update_episode_info(db, show, season, episode, column_name, value)
    print(' ')
    


def delete(db: Connection):
    """
    Deletes an episode or table from the database.
    """
    show = input('Enter show: ')
    season = input('Enter season of episode to delete: ')
    episode = input('Enter episode number in season to delete: ')
    delete_episode(db, show, season, episode)
    
    
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
        choice = input('Insert (I)\nUpdate episode info (U)\nDelete (D)\nQuit (Q)\n> ').lower()
        if choice == 'i':
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
