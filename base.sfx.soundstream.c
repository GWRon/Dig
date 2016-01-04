#include <unistd.h>

//forward declaration
int __startThread();

//global vars
int threadID;
int updateStreamsEnabled;
int updateInterval = 250;


int StopDigAudioStreamManagerUpdateThread(){
	updateStreamsEnabled = 0;
	return 1;
}


int StartDigAudioStreamManagerUpdateThread(){
	updateStreamsEnabled = 1;
	return __startThread();
};


//callback defined from within the BlitzMax code
int (*updateStreamManagerCallback)();
//callback defined from within the BlitzMax code
int (*printStreamManagerCallBack)(const char*);


void RegisterDigAudioStreamManagerUpdateCallback ( int (*cbFunc)() ) {
	updateStreamManagerCallback = cbFunc;
}

void RegisterDigAudioStreamManagerPrintCallback ( int (*printFunc)(const char*) ) {
	printStreamManagerCallBack = printFunc;
}

	
void *updateStreamManager(void *v) {
	while(updateStreamsEnabled) {
		//printStreamManagerCallBack("updateStreamManagerCallback()" );
		//call the blitzmax function which updates the streams buffers
		updateStreamManagerCallback();

		//wait some milliseconds till next update
		usleep(updateInterval * 1000);
	}
	return NULL;
}




#ifdef __linux
	#include <pthread.h>

	pthread_t  thread;
	
	int __startThread(){
		threadID = pthread_create(&thread, NULL, updateStreamManager, NULL);	
		return 0;
	};
#endif

#ifdef _WIN32
	#include <windows.h>

	HANDLE  thread;
	
	int __startThread(){
		thread = CreateThread(0, 0, updateStreamManager, NULL, 0, &threadID);
		return 0;
	};
#endif
