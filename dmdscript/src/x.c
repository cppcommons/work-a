int printf (const char *__format, ...);

#include <windows.h>
#include <winhttp.h>

int add2(int a, int b) {
	printf("a=%d, b=%d\n", a, b);
       	return a+b;
}

static LPBYTE ReadData(HINTERNET hRequest, LPDWORD lpdwSize)
{
    LPBYTE lpData = NULL;
    LPBYTE lpPrev = NULL;
    DWORD  dwSize;
    DWORD  dwTotalSize = 0;
    DWORD  dwTotalSizePrev = 0;

    for (;;) {
        WinHttpQueryDataAvailable(hRequest, &dwSize);
        if (dwSize > 0) {
            dwTotalSizePrev = dwTotalSize;
            dwTotalSize += dwSize;
            //lpData = (LPBYTE)HeapAlloc(GetProcessHeap(), 0, dwTotalSize);
            lpData = (LPBYTE)HeapAlloc(GetProcessHeap(), 0, dwTotalSize+1);
            if (lpPrev != NULL) {
                CopyMemory(lpData, lpPrev, dwTotalSizePrev);
                HeapFree(GetProcessHeap(), 0, lpPrev);
            }
            WinHttpReadData(hRequest, lpData + dwTotalSizePrev, dwSize, NULL);
            lpData[dwTotalSize] = 0;
            lpPrev = lpData;
        }
        else
            break;
    }

    *lpdwSize= dwTotalSize;

    return lpData;
}

struct my_winhttp_stream {
    wchar_t     * szAppName;
    wchar_t     * szUrl;
    wchar_t     * szHostName;
    wchar_t     * szUrlPath;
    wchar_t     * szHeader;
    char        * lpData;
    unsigned long dwDataSize;
#ifdef MY_WINHTTP_INTERNAL
    HANDLE         hHeap;
    URL_COMPONENTS urlComponents;
    HINTERNET      hSession, hConnect, hRequest;
#endif
};

extern struct my_winhttp_stream * my_winhttp_stream_open(const wchar_t *szAppName, const wchar_t *szUrl);
extern void my_winhttp_stream_close(struct my_winhttp_stream *handle);

extern struct my_winhttp_stream * my_winhttp_stream_open(const wchar_t *szAppName, const wchar_t *szUrl) {
    printf("start!\n");
    printf("%d\n", add2(11, 22));

    HANDLE hHeap = HeapCreate(0, 0, 0);
    struct my_winhttp_stream * stream = (struct my_winhttp_stream *)HeapAlloc(hHeap, HEAP_ZERO_MEMORY, sizeof(struct my_winhttp_stream));
    stream->hHeap = hHeap;

    stream->szAppName = (wchar_t *)HeapAlloc(hHeap, HEAP_ZERO_MEMORY, sizeof(wchar_t) * (lstrlenW(szAppName)+1));
    lstrcpyW(stream->szAppName, szAppName);

    stream->szUrl = (wchar_t *)HeapAlloc(hHeap, HEAP_ZERO_MEMORY, sizeof(wchar_t) * (lstrlenW(szUrl)+1));
    lstrcpyW(stream->szUrl, szUrl);

    printf("stream->szAppName=%ls\n", stream->szAppName);
    printf("stream->szUrl=%ls\n", stream->szUrl);

    stream->szHostName = (wchar_t *)HeapAlloc(hHeap, HEAP_ZERO_MEMORY, sizeof(wchar_t) * (lstrlenW(szUrl)+1));
    stream->szUrlPath  = (wchar_t *)HeapAlloc(hHeap, HEAP_ZERO_MEMORY, sizeof(wchar_t) * (lstrlenW(szUrl)+1));

    //URL_COMPONENTS urlComponents;
    ZeroMemory( &stream->urlComponents, sizeof(URL_COMPONENTS) );
    stream->urlComponents.dwStructSize     = sizeof(URL_COMPONENTS);
    stream->urlComponents.lpszHostName     = stream->szHostName;
    stream->urlComponents.dwHostNameLength = lstrlenW(szUrl)+1;
    stream->urlComponents.lpszUrlPath      = stream->szUrlPath;
    stream->urlComponents.dwUrlPathLength  = lstrlenW(szUrl)+1;

    if( !WinHttpCrackUrl( szUrl,
                          lstrlenW(szUrl),
                          0,
                          &stream->urlComponents ) )
    {
        // URLの解析に失敗
        printf("WinHttpCrackUrl() fail.\n");
        return 0;
    }
    printf("stream->szHostName=%ls\n", stream->szHostName);
    printf("stream->szUrlPath=%ls\n", stream->szUrlPath);
    printf("urlComponents.nPort=%u\n", stream->urlComponents.nPort);

    stream->hSession = WinHttpOpen(stream->szAppName, WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (stream->hSession == NULL) {
        HeapDestroy(hHeap);
        return 0;
    }

    printf("(1)\n");

    stream->hConnect = WinHttpConnect(stream->hSession, stream->szHostName, stream->urlComponents.nPort, 0);
    if (stream->hConnect == NULL) {
        WinHttpCloseHandle(stream->hSession);
        HeapDestroy(hHeap);
        return 0;
    }

    printf("(2)\n");

    // HTTPかHTTPSかそれ以外か
    DWORD dwOpenRequestFlag = (INTERNET_SCHEME_HTTPS == stream->urlComponents.nScheme) ? WINHTTP_FLAG_SECURE : 0;
    printf("dwOpenRequestFlag=0x%08lx\n", dwOpenRequestFlag);
    stream->hRequest = WinHttpOpenRequest(stream->hConnect, L"GET", stream->szUrlPath, NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, dwOpenRequestFlag );
    if (stream->hRequest == NULL) {
        WinHttpCloseHandle(stream->hConnect);
        WinHttpCloseHandle(stream->hSession);
        HeapDestroy(hHeap);
        return 0;
    }

    printf("(3)\n");

    if (!WinHttpSendRequest(stream->hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, WINHTTP_IGNORE_REQUEST_TOTAL_LENGTH, 0)) {
        WinHttpCloseHandle(stream->hRequest);
        WinHttpCloseHandle(stream->hConnect);
        WinHttpCloseHandle(stream->hSession);
        HeapDestroy(hHeap);
        return 0;
    }

    printf("(4)\n");

    WinHttpReceiveResponse(stream->hRequest, NULL);

    DWORD dwSizeWithZero = 0; //unit = sizeof(wchar_t)
    WinHttpQueryHeaders(stream->hRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX, NULL, &dwSizeWithZero, WINHTTP_NO_HEADER_INDEX);
    stream->szHeader = (wchar_t *)HeapAlloc(hHeap, 0, dwSizeWithZero/sizeof(wchar_t));
    WinHttpQueryHeaders(stream->hRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX, stream->szHeader, &dwSizeWithZero, WINHTTP_NO_HEADER_INDEX);

    printf("(5)\n%ls\n", stream->szHeader);

    return stream;
#if 0x0









    lpData = ReadData(hRequest, &dwSize);
    MessageBoxA(NULL, (LPSTR)lpData, "ボディ", MB_OK);
    HeapFree(GetProcessHeap(), 0, lpData);

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);
#endif

}


#ifdef TEST_MAIN
int main() {
    printf("start!\n");
    printf("%d\n", add2(11, 22));

    wchar_t * wszUrl = L"https://raw.githubusercontent.com/cyginst/ms2inst-v1/master/ms2inst.bat";
    wchar_t * wszAppName = L"Sample Application/1.0";

    struct my_winhttp_stream *stream = my_winhttp_stream_open(wszAppName, wszUrl);

    stream->lpData = ReadData(stream->hRequest, &stream->dwDataSize);
    MessageBoxA(NULL, (LPSTR)stream->lpData, "ボディ", MB_OK);
    HeapFree(GetProcessHeap(), 0, stream->lpData);

    WinHttpCloseHandle(stream->hRequest);
    WinHttpCloseHandle(stream->hConnect);
    WinHttpCloseHandle(stream->hSession);


    return 0;
}
#endif
