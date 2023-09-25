/* Filename: EXTENDC.C
*  Program.: Clipper Extended Library
*  Authors.: Tom Rettig, Brian Russell
*  Date....: November 1, 1985
*  Notice..: Placed in the public domain by Tom Rettig Associates.
*            Clipper is a trademark of Nantucket.
*            dBASE and dBASE III are trademarks of Ashton-Tate.
*  Notes...: User-defined dBASE III functions in C for Clipper.
*
*  dBASE III functions:
*      DISKSPACE() ::= Remaining empty space on a disk
*      GETE()      ::= Environmental variables from the operating system
*      LUPDATE()   ::= Date of last update of a database file
*      RECSIZE()   ::= Size of a record in a database file
*
*  Functions not in dBASE III or Clipper:
*      HEADER()    ::= Size of the dbf header in a database file
*
*/

#include "extend.h"


#define DEFAULT      0
#define FALSE        0
#define TRUE         1
#define NULL         ""


/******************************************************************************
*  DISKSPACE()
*  Syntax: DISKSPACE( [<expN>] )
*  Return: Numeric bytes of empty space on a disk drive
*  Note..: <expN> of one is drive A, two is B, three is C, etc.
*          Default is current drive if <expN> is omitted or zero.
*/

void DISKSPACE()

{
   struct                       /* structure to hold disk info */
   {
      unsigned no_clusts;       /* number of free clusters */
      unsigned secs_clusts;     /* sectors per cluster */
      unsigned clusts_drv;      /* total clusters per drive */
   } drv_info;

   /* if there is one parameter and it is numeric */
   if (PCOUNT == 1 && ISNUM(1))
   {
      _dspace(_parni(1), &drv_info);  /* specified drive */
   }
   else
      _dspace(DEFAULT, &drv_info);    /* default drive */

   /* Return long integer to Clipper
    * bytes ::= number of clusters times sectors per cluster times 512 */

   _retnl(512L * (long)drv_info.secs_clusts * (long)drv_info.no_clusts);
}


/******************************************************************************
* GETE()
* Syntax: GETE( <expC> )  
* Return: Any string contained in the operating system's 
*         environmental variable named in <expC>.
* Note..: Same as GETENV() in dBASE.  The name was changed because 
*         GETENV conflicts with the getenv() function used below.
*         E.g. GETE("PATH") returns the operating system's path.
*/

void GETE()

{
   char *_getenv();

   char *str;

   /* if there is one parameter and it is character */
   if (PCOUNT == 1 && ISCHAR(1))
   {
      _UPPER();                 /* convert parameter to uppercase
                                   using an internal Clipper function */

      str = _getenv(_parc(1));  /* get contents of the variable */

      _retc(str ? str : NULL);  /* return contents if there are any,
                                   otherwise return a null string */
   }
   else
      _retc(NULL);              /* return null if variable does not exist */
}


/******************************************************************************
*  HEADER()
*  Syntax: HEADER()
*  Return: Numeric bytes of header size in the currently selected database file
*  Note..: Use with RECCOUNT(), RECSIZE(), and DISKSPACE() for backup routines.
*/

void HEADER()

{
   /* Return long integer, size of header if there is a dbf in use, 
    * otherwise return zero */
   
   _retnl(DBF_OPEN ? DATA_OFF : 0L);
}


/******************************************************************************
*  LUPDATE()
*  Syntax: LUPDATE()
*  Return: Date of last writing of the currently selected database file
*/

void LUPDATE()

{
   unsigned year, month, day;
   char date_str[9];

   if (DBF_OPEN)           /* date info from header if dbf is in use */
   {
      year  = 1900 + DBF_DATE[1];
      month =        DBF_DATE[2];
      day   =        DBF_DATE[3];
   }
   else                    /* date info is zero if no dbf is in use,
                              returns a blank date */
      year = month = day = 0;

   /* build the date string */
   date_str[0] = '1';
   date_str[1] = '9';
   date_str[2] = '0' + (year % 100) / 10;
   date_str[3] = '0' + (year % 10);
   date_str[4] = '0' + (month / 10);
   date_str[5] = '0' + (month % 10);
   date_str[6] = '0' + (day / 10);
   date_str[7] = '0' + (day % 10);
   date_str[8] = '\0';

   _retds(date_str);            /* return date string to a date type */
}


/******************************************************************************
* RECSIZE()
* Syntax: RECSIZE()
* Return: Numeric bytes of record size in the currently selected dbf file
*/

void RECSIZE()

{
   /* Return long integer, size of record if there is a dbf in use, 
    * otherwise return zero */
   
   _retnl(DBF_OPEN ? REC_SIZE : 0L);
}


/******************************************************************************
*   eof: extendc.c
*/

