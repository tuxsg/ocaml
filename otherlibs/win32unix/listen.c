/***********************************************************************/
/*                                                                     */
/*                           Objective Caml                            */
/*                                                                     */
/*  Xavier Leroy and Pascal Cuoq, projet Cristal, INRIA Rocquencourt   */
/*                                                                     */
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../../LICENSE.  */
/*                                                                     */
/***********************************************************************/

/* $Id: listen.c,v 1.9 2002-04-30 15:00:46 xleroy Exp $ */

#include <mlvalues.h>
#include "unixsupport.h"

CAMLprim value unix_listen(sock, backlog)
     value sock, backlog;
{
  if (listen(Socket_val(sock), Int_val(backlog)) == -1) {
    win32_maperr(WSAGetLastError());
    uerror("listen", Nothing);
  }
  return Val_unit;
}
