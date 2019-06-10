/*
|| This file is part of Pike. For copyright information see COPYRIGHT.
|| Pike is distributed under GPL, LGPL and MPL. See the file COPYING
|| for more information.
*/

#include "global.h"
#include "bignum.h"
#include "object.h"
#include "interpret.h"
#include "threads.h"

#include "fdlib.h"
#include "fd_control.h"

#include <sys/stat.h>

#include "shuffler.h"

#define CHUNK 8192


/* Source: Normal file
 * Argument: Stdio.File instance pointing to a normal file
 */

struct fd_source
{
  struct source s;
  struct object *obj;
  char buffer[CHUNK];
  int fd;
  off_t len;
};

static struct data get_data( struct source *src, off_t len )
{
  struct fd_source *s = (struct fd_source *)src;
  struct data res;
  int rr;
  len = CHUNK; /* It's safe to ignore the 'len' argument */

  res.data = s->buffer;

  if( len > s->len )
  {
    len = s->len;
    s->s.eof = 1;
  }
  THREADS_ALLOW();
  rr = fd_read( s->fd, res.data, len );
  THREADS_DISALLOW();
/*    printf("B[normal file]: get_data( %d / %d ) --> %d\n", len, */
/*  	 s->len, rr); */

  res.len = rr;

  if( rr<0 || rr < len )
    s->s.eof = 1;
  return res;
}


static void free_source( struct source *src )
{
  free_object(((struct fd_source *)src)->obj);
}

static int is_stdio_file(struct object *o)
{
  struct program *p = o->prog;
  INT32 i = p->num_inherits;
  while( i-- )
  {
    if( p->inherits[i].prog->id == PROG_STDIO_FD_ID ||
        p->inherits[i].prog->id == PROG_STDIO_FD_REF_ID )
      return 1;
  }
  return 0;
}

struct source *source_normal_file_make( struct svalue *s,
					INT64 start, INT64 len )
{
  struct fd_source *res;
  PIKE_STAT_T st;
  if(TYPEOF(*s) != PIKE_T_OBJECT)
    return 0;

  if(!is_stdio_file(s->u.object))
    return 0;

  if (find_identifier("query_fd", s->u.object->prog) < 0)
    return 0;

  res = calloc( 1, sizeof( struct fd_source ) );
  if( !res ) return NULL;

  apply( s->u.object, "query_fd", 0 );
  res->fd = Pike_sp[-1].u.integer;
  pop_stack();
  res->s.get_data = get_data;
  res->s.free_source = free_source;
  res->obj = s->u.object;
  add_ref(res->obj);

  if( fd_fstat( res->fd, &st ) < 0 )
  {
    goto fail;
  }
  if( !S_ISREG(st.st_mode) )
  {
    goto fail;
  }
  if( len > 0 )
  {
    if( len > st.st_size-start )
    {
      goto fail;
    }
    else
      res->len = len;
  }
  else
    res->len = st.st_size-start;

  if( fd_lseek( res->fd, (off_t)start, SEEK_SET ) < 0 )
  {
    goto fail;
  }
  return (struct source *)res;

fail:
  free_source((void *)res);
  free(res);
  return 0;
}

void source_normal_file_exit( )
{
}

void source_normal_file_init( )
{
}
