/***
*	extend.h
*
*	DEFINEs and EXTERNs for interfacing with Clipper from C.
*
*	Large model C only (double word pointers to code and data)
*
*	Copyright (c) Nantucket Inc. 1985
*/


/* _parinfo types */
#define UNDEF		0
#define CHARACTER	1
#define NUMERIC		2
#define LOGICAL		4
#define DATE		8
#define ALIAS		16
#define MPTR		32		/* bitwise or'ed with type for pass by reference */
#define MEMO		65
#define WORD		128
#define ARRAY		512


/* parameter count/type */
extern int _parinfo();
extern int _parinfa();


/* parameter values */
extern char *_parc();
extern int _parni();
extern long _parnl();
extern double _parnd();
extern int _parl();
extern char *_pards();


/* one and only one of the _ret?? functions must used */

/* Clipper-function return values */
extern _retc();
extern _retni();
extern _retnl();
extern _retnd();
extern _retl();
extern _retds();

/* procedure (DO) return */
extern _ret();


/* parameter check macros */
#define PCOUNT		(_parinfo(0))
#define ISCHAR(n)	(_parinfo(n) & CHARACTER)
#define ISNUM(n)	(_parinfo(n) & NUMERIC)
#define ISLOG(n)	(_parinfo(n) & LOGICAL)
#define ISDATE(n)	(_parinfo(n) & DATE)
#define ISMEMO(n)	(_parinfo(n) & MEMO)
#define ISBYREF(n)	(_parinfo(n) & MPTR)
#define ISARRAY(n)	(_parinfo(n) & ARRAY)
#define ALENGTH(n)	(_parinfa(n, 0))


/* DBF */
extern struct
{
   char data1[32];
   long data2[2];
} *_dbf[];

#define DBF_DATE	(_dbf[0]->data1)		/* char pointer to header */
#define REC_SIZE	(_dbf[0]->data2[0])		/* long record size */
#define DATA_OFF	(_dbf[0]->data2[1])		/* long header size */
#define DBF_OPEN	(*_dbf)

