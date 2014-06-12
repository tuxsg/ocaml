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

/* $Id: getpid.c,v 1.4 2001-12-07 13:40:44 xleroy Exp $ */

#include <mlvalues.h>
#include "unixsupport.h"

extern value val_process_id;

CAMLprim value unix_getpid(value unit)
{
  return val_process_id;
}
