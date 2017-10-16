//C:\D\dmd2\src\druntime\import\core\sys\windows\basetsd.d(70,16)  [SJIS]:     alias long INT_PTR, LONG_PTR;
//C:\D\dmd2\src\druntime\import\core\sys\windows\windef.d(116,51)  [SJIS]: alias extern (Windows) INT_PTR function() nothrow FARPROC, NEARPROC, PROC;

/**
 * Load DLL from memory location.
 *
 * All dependencies are resolved using default LoadLibrary/GetProcAddress
 * calls through the Windows API.
 */
//HMEMORYMODULE MemoryLoadLibrary(const void *);
void * MemoryLoadLibrary(const unsigned char *);

/**
 * Get address of exported method.
 */
//FARPROC MemoryGetProcAddress(HMEMORYMODULE, LPCSTR);
void * MemoryGetProcAddress(void *, char *);

/**
 * Free previously loaded DLL.
 */
//void MemoryFreeLibrary(HMEMORYMODULE);
void MemoryFreeLibrary(void *);

