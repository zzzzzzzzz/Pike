/*
 * $Id: sql.pike,v 1.7 1997/06/08 18:44:56 grubba Exp $
 *
 * Implements the generic parts of the SQL-interface
 *
 * Henrik Grubbström 1996-01-09
 */

//.
//. File:	sql.pike
//. RCSID:	$Id: sql.pike,v 1.7 1997/06/08 18:44:56 grubba Exp $
//. Author:	Henrik Grubbström (grubba@infovav.se)
//.
//. Synopsis:	Implements the generic parts of the SQL-interface.
//.
//. +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//.
//. Implements those functions that need not be present in all SQL-modules.
//.

#define throw_error(X)	throw(({ (X), backtrace() }))

import Array;
import Simulate;

//. + master_sql
//.   Object to use for the actual SQL-queries.
object master_sql;

//. - create
//.   Create a new generic SQL object.
//. > host
//.   object - Use this object to access the SQL-database.
//.   string - Use any available database server on this host.
//.            If "" or 0, access through UNIX-domain socket or similar.
//. > database
//.   Select this database.
//. > user
//.   User name to access the database as.
//. > password
//.   Password to access the database.
void create(void|string|object host, void|string db,
	    void|string user, void|string password)
{
  if (objectp(host)) {
    master_sql = host;
    if ((user && user != "") || (password && password != "")) {
      throw_error("Sql(): Only the database argument is supported when "
		  "first argument is an object\n");
    }
    if (db && db != "") {
      master_sql->select_db(db);
    }
    return;
  } else {
    foreach(get_dir(Sql->dirname), string program_name) {
      if ((sizeof(program_name / "_result") == 1) &&
	  (sizeof(program_name / ".pike") > 1) &&
	  (program_name != "sql.pike")) {
	/* Don't call ourselves... */
	array(mixed) err;

	err = catch {
	  program p = Sql[program_name];

	  if (p) {
	    array err2 = catch {
	      if (password && password != "") {
		master_sql = p(host||"", db||"", user||"", password);
	      } else if (user && user != "") {
		master_sql = p(host||"", db||"", user);
	      } else if (db && db != "") {
		master_sql = p(host||"", db);
	      } else if (host && host != "") {
		master_sql = p(host);
	      } else {
		master_sql = p();
	      }
	      return;
	    };
#ifdef PIKE_SQL_DEBUG
	    if (err2) {
	      Stdio.stderr->write(sprintf("Sql.sql(): Failed to connect using module Sql.%s\n",
					  program_name));
	    }
	  } else {
	    Stdio.stderr->write(sprintf("Sql.sql(): Failed to index module Sql.%s\n",
					program_name));
#endif /* PIKE_SQL_DEBUG */
	  }
	};
#ifdef PIKE_SQL_DEBUG
	if (err) {
	  Stdio.stderr->write(sprintf("Sql.sql(): Failed to compile module Sql.%s\n",
				      program_name));
	}
#endif /* PIKE_SQL_DEBUG */
      }
    }
  }

  throw_error("Sql(): Couldn't connect to database\n");
}

static private array(mapping(string:mixed)) res_obj_to_array(object res_obj)
{
  if (res_obj) {
    /* Not very efficient, but sufficient */
    array(mapping(string:mixed)) res = ({});
    array(string) fieldnames;
    array(mixed) row;
      
    fieldnames = map(res_obj->fetch_fields(),
		     lambda (mapping(string:mixed) m) {
      return(m->name);	/* Hope this is unique */
    } );

    while (row = res_obj->fetch_row()) {
      res += ({ mkmapping(fieldnames, row) });
    }
    return(res);
  } else {
    return(0);
  }
}

//. - error
//.   Return last error message.  
int|string error()
{
  return(master_sql->error());
}

//. - select_db
//.   Select database to access.
void select_db(string db)
{
  master_sql->select_db(db);
}

//. - compile_query
//.   Compiles the query (if possible). Otherwise returns it as is.
//.   The resulting object can be used multiple times in query() and
//.   big_query().
//. > q
//.   SQL-query to compile.
string|object compile_query(string q)
{
  if (functionp(master_sql->compile_query)) {
    return(master_sql->compile_query(q));
  }
  return(q);
}

//. - query
//.   Send an SQL query to the underlying SQL-server. The result is returned
//.   as an array of mappings indexed on the name of the columns.
//.   Returns 0 if the query didn't return any result (e.g. INSERT or similar).
//. > q
//.   Query to send to the SQL-server. This can either be a string with the
//.   query, or a previously compiled query (see compile_query()).
array(mapping(string:mixed)) query(object|string q)
{
  object res_obj;

  if (functionp(master_sql->query)) {
    return(master_sql->query(q));
  }
  return(res_obj_to_array(master_sql->big_query(q)));
}

//. - big_query
//.   Send an SQL query to the underlying SQL-server. The result is returned
//.   as a Sql.sql_result object. This allows for having results larger than
//.   the available memory, and returning some more info on the result.
//.   Returns 0 if the query didn't return any result (e.g. INSERT or similar).
//. > q
//.   Query to send to the SQL-server. This can either be a string with the
//.   query, or a previously compiled query (see compile_query()).
object big_query(object|string q)
{
  if (functionp(master_sql->big_query)) {
    return(Sql.sql_result(master_sql->big_query(q)));
  }
  return(Sql.sql_result(master_sql->query(q)));
}

//. - create_db
//.   Create a new database.
//. > db
//.   Name of database to create.
void create_db(string db)
{
  master_sql->create_db(db);
}

//. - drop_db
//.   Drop database
//. > db
//.   Name of database to drop.
void drop_db(string db)
{
  master_sql->drop_db(db);
}

//. - shutdown
//.   Shutdown a database server.
void shutdown()
{
  if (functionp(master_sql->shutdown)) {
    master_sql->shutdown();
  } else {
    throw_error("sql->shutdown(): Not supported by this database\n");
  }
}

//. - reload
//.   Reload the tables.
void reload()
{
  if (functionp(master_sql->reload)) {
    master_sql->reload();
  } else {
    /* Probably safe to make this a NOOP */
  }
}

//. - server_info
//.   Return info about the current SQL-server.
string server_info()
{
  if (functionp(master_sql->server_info)) {
    return(master_sql->server_info());
  }
  return("Unknown SQL-server");
}

//. - host_info
//.   Return info about the connection to the SQL-server.
string host_info()
{
  if (functionp(master_sql->host_info)) {
    return(master_sql->host_info());
  } 
  return("Unknown connection to host");
}

//. - list_dbs
//.   List available databases on this SQL-server.
//. > wild
//.   Optional wildcard to match against.
array(string) list_dbs(string|void wild)
{
  array(string)|array(mapping(string:mixed))|object res;
  
  if (functionp(master_sql->list_dbs)) {
    if (objectp(res = master_sql->list_dbs())) {
      res = res_obj_to_array(res);
    }
  } else {
    res = query("show databases");
  }
  if (sizeof(res) && mappingp(res[0])) {
    res = map(res, lambda (mapping m) {
      return(values(m)[0]);	/* Hope that there's only one field */
    } );
  }
  if (wild) {
    res = map_regexp(res, replace(wild, ({ "%", "_" }), ({ ".*", "." }) ));
  }
  return(res);
}

//. - list_tables
//.   List tables available in the current database.
//. > wild
//.   Optional wildcard to match against.
array(string) list_tables(string|void wild)
{
  array(string)|array(mapping(string:mixed))|object res;
  
  if (functionp(master_sql->list_tables)) {
    if (objectp(res = master_sql->list_tables())) {
      res = res_obj_to_array(res);
    }
  } else {
    res = query("show tables");
  }
  if (sizeof(res) && mappingp(res[0])) {
    res = map(res, lambda (mapping m) {
      return(values(m)[0]);	/* Hope that there's only one field */
    } );
  }
  if (wild) {
    res = map_regexp(res, replace(wild, ({ "%", "_" }), ({ ".*", "." }) ));
  }
  return(res);
}

//. - list_fields
//.   List fields available in the specified table
//. > table
//.   Table to list the fields of.
//. > wild
//.   Optional wildcard to match against.
array(mapping(string:mixed)) list_fields(string table, string|void wild)
{
  array(mapping(string:mixed))|object res;

  if (functionp(master_sql->list_fields)) {
    if (objectp(res = master_sql->list_fields(table))) {
      res = res_obj_to_array(res);
    }
    if (wild) {
      /* Not very efficient, but... */
      res = filter(res, lambda (mapping m, string re) {
	return(sizeof(map_regexp( ({ m->name }), re)));
      }, replace(wild, ({ "%", "_" }), ({ ".*", "." }) ) );
    }
    return(res);
  }
  if (wild) {
    res = query("show fields from \'" + table +
		"\' like \'" + wild + "\'");
  } else {
    res = query("show fields from \'" + table + "\'");
  }
  res = map(res, lambda (mapping m, string table) {
    foreach(indices(m), string str) {
      /* Add the lower case variants */
      string low_str = lower_case(str);
      if (low_str != str && !m[low_str]) {
	m[low_str] = m[str];
	m_delete(m, str);	/* Remove duplicate */
      }
    }
    if ((!m->name) && m->field) {
      m["name"] = m->field;
      m_delete(m, "field");	/* Remove duplicate */
    }
    if (!m->table) {
      m["table"] = table;
    }
    return(m);
  }, table);
  return(res);
}

