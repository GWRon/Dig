#include <unistd.h>


//forward declaration
int __startThread();

//global vars
int threadID;
int updateStreamsEnabled = -1; //-1 = auto activate on registering a callback
int updateInterval = 100;

//definition and variable for callback
typedef int (*intCallback)(void);
intCallback updateStreamManagerCallback;




int stopThread() {
	updateStreamsEnabled = 0;
	return 1;
}


int startThread(){
	updateStreamsEnabled = 1;
	return __startThread();
};


int RegisterUpdateStreamManagerCallback ( intCallback callback ) {
	updateStreamManagerCallback = callback;
	if (updateStreamsEnabled == 1)
		__startThread();
		
	return 1;
}


void *updateStreamManager(void *v) {
	while(updateStreamsEnabled) {
		//call the blitzmax function which updates the streams buffers
		if(updateStreamManagerCallback != NULL)
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
