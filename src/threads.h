#ifndef THREADS_H
#define THREADS_H

#include "machine.h"
#include "interpret.h"
#include "object.h"
#include "error.h"
#ifdef HAVE_SYS_TYPES_H
/* Needed for pthread_t on OSF/1 */
#include <sys/types.h>
#endif /* HAVE_SYS_TYPES_H */
#ifdef _REENTRANT

/*
 * Decide which type of threads to use
 *
 * UNIX_THREADS      : Unix international threads
 * POSIX_THREADS     : POSIX standard threads
 * SGI_SPROC_THREADS : SGI sproc() based threads
 * NT_THREADS        : NT threads
 */

#ifdef _UNIX_THREADS
#ifdef HAVE_THREAD_H
#define UNIX_THREADS
#include <thread.h>
#undef HAVE_PTHREAD_H
#undef HAVE_THREAD_H
#endif
#endif /* _UNIX_THREADS */

#ifdef _MIT_POSIX_THREADS
#ifdef HAVE_PTHREAD_H
#define POSIX_THREADS
#include <pthread.h>
#undef HAVE_PTHREAD_H
#endif
#endif /* _MIT_POSIX_THREADS */

#ifdef _SGI_SPROC_THREADS
/* Not supported yet */
#undef SGI_SPROC_THREADS
#undef HAVE_SPROC
#endif /* _SGI_SPROC_THREADS */


extern int num_threads;
struct object;
extern struct object *thread_id;

#define DEFINE_MUTEX(X) MUTEX_T X


#ifdef POSIX_THREADS
#define THREAD_T pthread_t
#define MUTEX_T pthread_mutex_t
#define mt_init(X) pthread_mutex_init((X),0)
#define mt_lock(X) pthread_mutex_lock(X)
#define mt_trylock(X) pthread_mutex_trylock(X)
#define mt_unlock(X) pthread_mutex_unlock(X)
#define mt_destroy(X) pthread_mutex_destroy(X)

/* SIGH! No setconcurrency in posix threads. This is more or less
 * needed to make usable multi-threaded programs on solaris machines
 * with only one CPU. Otherwise, only systemcalls are actually
 * threaded.
 */
#define th_setconcurrency(X) 
#ifdef HAVE_PTHREAD_YIELD
#define th_yield()	pthread_yield()
#else
#define th_yield()
#endif /* HAVE_PTHREAD_YIELD */
extern pthread_attr_t pattr;
extern pthread_attr_t small_pattr;

#define th_create(ID,fun,arg) pthread_create(ID,&pattr,fun,arg)
#define th_create_small(ID,fun,arg) pthread_create(ID,&small_pattr,fun,arg)
#define th_exit(foo) pthread_exit(foo)
#define th_self() pthread_self()

#ifdef HAVE_PTHREAD_COND_INIT
#define COND_T pthread_cond_t

#ifdef HAVE_PTHREAD_CONDATTR_DEFAULT
#define co_init(X) pthread_cond_init((X), pthread_condattr_default)
#else
#define co_init(X) pthread_cond_init((X), 0)
#endif /* HAVE_PTHREAD_CONDATTR_DEFAULT */

#define co_wait(COND, MUTEX) pthread_cond_wait((COND), (MUTEX))
#define co_signal(X) pthread_cond_signal(X)
#define co_broadcast(X) pthread_cond_broadcast(X)
#define co_destroy(X) pthread_cond_destroy(X)
#else
#error No way to make cond-vars
#endif /* HAVE_PTHREAD_COND_INIT */

#endif /* POSIX_THREADS */




#ifdef UNIX_THREADS
#define THREAD_T thread_t
#define PTHREAD_MUTEX_INITIALIZER DEFAULTMUTEX
#define MUTEX_T mutex_t
#define mt_init(X) mutex_init((X),USYNC_THREAD,0)
#define mt_lock(X) mutex_lock(X)
#define mt_trylock(X) mutex_trylock(X)
#define mt_unlock(X) mutex_unlock(X)
#define mt_destroy(X) mutex_destroy(X)

#define th_setconcurrency(X) thr_setconcurrency(X)

#define th_create(ID,fun,arg) thr_create(NULL,0,fun,arg,THR_DAEMON,ID)
#define th_create_small(ID,fun,arg) thr_create(NULL,32768,fun,arg,THR_DAEMON|THR_DETACHED,ID)
#define th_exit(foo) thr_exit(foo)
#define th_self() thr_self()
#define th_yield() thr_yield()

#define COND_T cond_t
#define co_init(X) cond_init((X),USYNC_THREAD,0)
#define co_wait(COND, MUTEX) cond_wait((COND), (MUTEX))
#define co_signal(X) cond_signal(X)
#define co_broadcast(X) cond_broadcast(X)
#define co_destroy(X) cond_destroy(X)


#endif /* UNIX_THREADS */

#ifdef SGI_SPROC_THREADS

/*
 * Not fully supported yet
 */
#define THREAD_T	int

#define MUTEX_T		ulock_t
#define mt_init(X)	(usinitlock(((*X) = usnewlock(/*********/))))
#define mt_lock(X)	ussetlock(*X)
#define mt_unlock(X)	usunsetlock(*X)
#define mt_destroy(X)	usfreelock((*X), /*******/)

#define th_setconcurrency(X)	/*******/

#define PIKE_SPROC_FLAGS	(PR_SADDR|PR_SFDS|PR_SDIR|PS_SETEXITSIG)
#define th_create(ID, fun, arg)	(((*(ID)) = sproc(fun, PIKE_SPROC_FLAGS, arg)) == -1)
#define th_create_small(ID, fun, arg)	(((*(ID)) = sproc(fun, PIKE_SPROC_FLAGS, arg)) == -1)
#define th_exit(X)	exit(X)
#define th_self()	getpid()
#define th_yield()	sginap(0)

/*
 * No cond_vars yet
 */

#endif /* SGI_SPROC_THREADS */


#ifdef NT_THREADS
#include <process.h>
#include <windows.h>

#define THREAD_T HANDLE
#define th_setconcurrency(X)
#define th_create(ID,fun,arg)  (!(*(ID)=_beginthread(fun, 2*1024*1024, arg)))
#define th_create_small(ID,fun,arg)  (!(*(ID)=_beginthread(fun, 32768, arg)))
#define th_exit(foo) _endthread(foo)
#define th_self() GetCurrentThread()
#define th_destroy(X)
#define th_yield() Sleep(0)

#define MUTEX_T HANDLE
#define mt_init(X) CheckValidHandle((*(X)=CreateMutex(NULL, 0, NULL)))
#define mt_lock(X) (CheckValidHandle(*(X)),WaitForSingleObject(*(X), INFINITE))
#define mt_trylock(X) (CheckValidHandle(*(X)),WaitForSingleObject(*(X), 0))
#define mt_unlock(X) (CheckValidHandle(*(X)),ReleaseMutex(*(X)))
#define mt_destroy(X) (CheckValidHandle(*(X)),CloseHandle(*(X)))

#define EVENT_T HANDLE
#define event_init(X) CheckValidHandle(*(X)=CreateEvent(NULL, 1, 0, NULL))
#define event_signal(X) (CheckValidHandle(*(X)),SetEvent(*(X)))
#define event_destroy(X) (CheckValidHandle(*(X)),CloseHandle(*(X)))
#define event_wait(X) (CheckValidHandle(*(X)),WaitForSingleObject(*(X), INFINITE))

#endif


#if !defined(COND_T) && defined(EVENT_T) && defined(MUTEX_T)

#define SIMULATE_COND_WITH_EVENT

struct cond_t_queue
{
  struct cond_t_queue *next;
  EVENT_T event;
};

typedef struct cond_t_s
{
  MUTEX_T lock;
  struct cond_t_queue *head, *tail;
} COND_T;

#define COND_T struct cond_t_s

#define co_init(X) do { mt_init(& (X)->lock), (X)->head=(X)->tail=0; }while(0)

int co_wait(COND_T *c, MUTEX_T *m);
int co_signal(COND_T *c);
int co_broadcast(COND_T *c);
int co_destroy(COND_T *c);

#endif


extern MUTEX_T interpreter_lock;


struct svalue;
struct frame;

#define THREAD_NOT_STARTED -1
#define THREAD_RUNNING 0
#define THREAD_EXITED 1

struct thread_state {
  char swapped;
  char status;
  COND_T status_change;
  THREAD_T id;

  /* Swapped variables */
  struct svalue *sp,*evaluator_stack;
  struct svalue **mark_sp,**mark_stack;
  struct frame *fp;
  int evaluator_stack_malloced;
  int mark_stack_malloced;
  JMP_BUF *recoveries;
  struct object * thread_id;
};

#ifndef th_destroy
#define th_destroy(X)
#endif

#ifndef th_yield
#define th_yield()
#endif

/* Define to get a debug-trace of some of the threads operations. */
/* #define VERBOSE_THREADS_DEBUG */

#ifndef VERBOSE_THREADS_DEBUG
#define THREADS_FPRINTF(X)
#else
#define THREADS_FPRINTF(X)	fprintf X
#endif /* VERBOSE_THREADS_DEBUG */

#define SWAP_OUT_THREAD(_tmp) do { \
       (_tmp)->swapped=1; \
       (_tmp)->evaluator_stack=evaluator_stack;\
       (_tmp)->evaluator_stack_malloced=evaluator_stack_malloced;\
       (_tmp)->fp=fp;\
       (_tmp)->mark_sp=mark_sp;\
       (_tmp)->mark_stack=mark_stack;\
       (_tmp)->mark_stack_malloced=mark_stack_malloced;\
       (_tmp)->recoveries=recoveries;\
       (_tmp)->sp=sp; \
       (_tmp)->thread_id=thread_id;\
      } while(0)

#define SWAP_IN_THREAD(_tmp) do {\
       (_tmp)->swapped=0; \
       evaluator_stack=(_tmp)->evaluator_stack;\
       evaluator_stack_malloced=(_tmp)->evaluator_stack_malloced;\
       fp=(_tmp)->fp;\
       mark_sp=(_tmp)->mark_sp;\
       mark_stack=(_tmp)->mark_stack;\
       mark_stack_malloced=(_tmp)->mark_stack_malloced;\
       recoveries=(_tmp)->recoveries;\
       sp=(_tmp)->sp;\
       thread_id=(_tmp)->thread_id;\
     } while(0)

#define SWAP_OUT_CURRENT_THREAD() \
  do {\
     struct thread_state *_tmp=(struct thread_state *)thread_id->storage; \
     SWAP_OUT_THREAD(_tmp); \
     THREADS_FPRINTF((stderr, "SWAP_OUT_CURRENT_THREAD() %s:%d t:%08x\n", \
			__FILE__, __LINE__, (unsigned int)_tmp->thread_id)) \

#define SWAP_IN_CURRENT_THREAD() \
   THREADS_FPRINTF((stderr, "SWAP_IN_CURRENT_THREAD() %s:%d ... t:%08x\n", \
		    __FILE__, __LINE__, (unsigned int)_tmp->thread_id)); \
   SWAP_IN_THREAD(_tmp);\
 } while(0)

#if defined(DEBUG) && ! defined(DONT_HIDE_GLOBALS)
/* Note that scalar types are used in place of pointers and vice versa
 * below. This is intended to cause compiler warnings/errors if
 * there is an attempt to use the global variables in an unsafe
 * environment.
 */
#define HIDE_GLOBAL_VARIABLES() do { \
   int sp = 0, evaluator_stack = 0, mark_sp = 0, mark_stack = 0, fp = 0; \
   void *evaluator_stack_malloced = NULL, *mark_stack_malloced = NULL; \
   int recoveries = 0, thread_id = 0; \
   int error = 0, xalloc = 0, low_my_putchar = 0, low_my_binary_strcat = 0; \
   int low_make_buf_space = 0, pop_n_elems = 0; \
   int push_sp_mark = 0, pop_sp_mark = 0

/* Note that the semi-colon below is needed to add an empty statement
 * in case there is a label before the macro.
 */
#define REVEAL_GLOBAL_VARIABLES() ; } while(0)
#else /* DEBUG */
#define HIDE_GLOBAL_VARIABLES()
#define REVEAL_GLOBAL_VARIABLES()
#endif /* DEBUG */
			   

#define THREADS_ALLOW() do { \
     struct thread_state *_tmp=(struct thread_state *)thread_id->storage; \
     if(num_threads > 1 && !threads_disabled) { \
       SWAP_OUT_THREAD(_tmp); \
       THREADS_FPRINTF((stderr, "THREADS_ALLOW() %s:%d t:%08x\n", \
			__FILE__, __LINE__, (unsigned int)_tmp->thread_id)); \
       mt_unlock(& interpreter_lock); \
     } else {} \
     HIDE_GLOBAL_VARIABLES()

#define THREADS_DISALLOW() \
     REVEAL_GLOBAL_VARIABLES(); \
     if(_tmp->swapped) { \
       mt_lock(& interpreter_lock); \
       THREADS_FPRINTF((stderr, "THREADS_DISALLOW() %s:%d ... t:%08x\n", \
			__FILE__, __LINE__, (unsigned int)_tmp->thread_id)); \
       SWAP_IN_THREAD(_tmp);\
     } \
   } while(0)

/* Prototypes begin here */
struct thread_starter;
void *new_thread_func(void * data);
void f_thread_create(INT32 args);
void f_thread_set_concurrency(INT32 args);
void f_this_thread(INT32 args);
struct mutex_storage;
struct key_storage;
void f_mutex_lock(INT32 args);
void f_mutex_trylock(INT32 args);
void init_mutex_obj(struct object *o);
void exit_mutex_obj(struct object *o);
void init_mutex_key_obj(struct object *o);
void exit_mutex_key_obj(struct object *o);
void f_cond_wait(INT32 args);
void f_cond_signal(INT32 args);
void f_cond_broadcast(INT32 args);
void init_cond_obj(struct object *o);
void exit_cond_obj(struct object *o);
void f_thread_backtrace(INT32 args);
void f_thread_id_status(INT32 args);
void init_thread_obj(struct object *o);
void exit_thread_obj(struct object *o);
void th_init(void);
void th_cleanup(void);
/* Prototypes end here */

#else
#define th_setconcurrency(X)
#define DEFINE_MUTEX(X)
#define mt_init(X)
#define mt_lock(X)
#define mt_unlock(X)
#define mt_destroy(X)
#define THREADS_ALLOW()
#define THREADS_DISALLOW()
#define HIDE_GLOBAL_VARIABLES()
#define REVEAL_GLOBAL_VARIABLES()
#define th_init()
#define th_cleanup()
#define th_init_programs()
#define th_self() ((void*)0)
#endif /* _REENTRANT */

#ifdef __NT__
#ifndef DEBUG
#define CheckValidHandle(X) 0
#else
void CheckValidHandle(HANDLE h);
#endif
#endif

extern int threads_disabled;

#endif /* THREADS_H */
