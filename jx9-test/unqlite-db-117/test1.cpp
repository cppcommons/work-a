/*
* Compile this file together with the jx9 scripting engine source code to generate
* the executable. For example:
* gcc -W -Wall -O6 -o test jx9_intro.c jx9.c
*/

/* Make sure you have the latest release of the JX9 engine
* from:
* http://jx9.symisc.net/downloads.html
*/
#include <stdio.h>
#include <stdlib.h>

/* Make sure this header file is available.*/
//#include "jx9.h"
#include "unqlite.h"

/*
* Display an error message and exit.
*/
static void Fatal(const char *zMsg)
{
   puts(zMsg);
  	/* Shutdown the library */
  	unqlite_lib_shutdown();
  	/* Exit immediately */
  	exit(0);
}

/*
* VM output consumer callback.
* Each time the virtual machine generates some outputs, the following
* function gets called by the underlying virtual machine to consume
* the generated output.
* All this function does is redirecting the VM output to STDOUT.
* This function is registered later via a call to jx9_vm_config()
* with a configuration verb set to: JX9_VM_CONFIG_OUTPUT.
*/
static int Output_Consumer(const void *pOutput, unsigned int nOutputLen, void *pUserData /* Unused */)
{
 	/*
  	* Note that it's preferable to use the write() system call to display the output
  	* rather than using the libc printf() which everybody now is extremely slow.
  	*/
  	printf("%.*s",
      	nOutputLen,
     	(const char *)pOutput /* Not null terminated */
  	);
    	/* All done, VM output was redirected to STDOUT */
    	return UNQLITE_OK;
}

/*
* Main program: Compile and execute the JX9 program defined above.
*/
int main(void)
{
  unqlite *pEngine; /* JX9 engine handle*/
 	unqlite_vm *pVm; /* Compiled JX9 program */
  int rc;

 	/* Allocate a new jx9 engine instance */
 	//rc = unqlite_init(&pEngine);
    rc = unqlite_open(&pEngine, ":mem:", UNQLITE_OPEN_READWRITE);
    rc = unqlite_lib_init();
 	if( rc != UNQLITE_OK ){
  	/*
   	* If the supplied memory subsystem is so sick that we are unable
   	* to allocate a tiny chunk of memory, there is no much we can do here.
   	*/
   	Fatal("Error while allocating a new JX9 engine instance");
 	}


  /* Compile the test program defined above */
 	rc = unqlite_compile(pEngine, "println(11+22)",-1,&pVm);
 	if( rc != UNQLITE_OK ){
   	if( rc == UNQLITE_COMPILE_ERR ){
    	const char *zErrLog;
    	int nLen;
   	/* Extract error log */
   	unqlite_config(pEngine,
       	UNQLITE_CONFIG_ERR_LOG,
      	&zErrLog,
      	&nLen
  	);
  	if( nLen > 0 ){
     	/* zErrLog is null terminated */
      puts(zErrLog);
   	}
 	}
 	/* Exit */
 	Fatal("Compile error");
}


/*
* Now we have our script compiled, it's time to configure our VM.
* We will install the VM output consumer callback defined above
* so that we can consume the VM output and redirect it to STDOUT.
*/
 	rc = unqlite_vm_config(pVm,
     	UNQLITE_VM_CONFIG_OUTPUT,
     	Output_Consumer, /* Output Consumer callback */
     	0 /* Callback private data */
   	);
 	if( rc != UNQLITE_OK ){
     	Fatal("Error while installing the VM output consumer callback");
  	}


 	/*
 	* And finally, execute our program. Note that your output (STDOUT in our case)
 	* should display the result.
 	*/
 	unqlite_vm_exec(pVm);


/* All done, cleanup the mess left behind. */
 unqlite_vm_release(pVm);
 unqlite_close(pEngine);

 	return 0;
}
