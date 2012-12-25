#ifndef WAZLIBS_GLOBAL_H
#define WAZLIBS_GLOBAL_H


#include <QtCore/qglobal.h>

#if defined(WAZLIBS_LIBRARY)
#  define WAZLIBSSHARED_EXPORT Q_DECL_EXPORT
#else
#  define WAZLIBSSHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // WAZLIBS_GLOBAL_H

