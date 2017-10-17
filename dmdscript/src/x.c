#include <windows.h>
#include <winhttp.h>
//#include <stdio.h>

int printf (const char *__format, ...);

int add2(int a, int b) {
	printf("a=%d, b=%d\n", a, b);
       	return a+b;
}

LPBYTE ReadData(HINTERNET hRequest, LPDWORD lpdwSize)
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

#ifdef TEST_MAIN
int main() {
    printf("start!\n");
    printf("%d\n", add2(11, 22));

    wchar_t * wszUrl = L"https://raw.githubusercontent.com/cyginst/ms2inst-v1/master/ms2inst.bat";
    wchar_t * wszAppName = L"Sample Application/1.0";

    HINTERNET      hSession, hConnect, hRequest;
    URL_COMPONENTS urlComponents;
    WCHAR          szHostName[1024], szUrlPath[8192];
    WCHAR          szUrl[] = L"http://eternalwindows.jp/winbase/base/base00.html";
    LPBYTE         lpHeader, lpData;
    DWORD          dwSize;

#if 0x0
    INTERNET_PORT nPort = 0;
    URL_COMPONENTS urlcomponents;
#endif
    ZeroMemory( &urlComponents, sizeof(urlComponents) );
    //WCHAR wszHostName[URLBUFFER_SIZE];
    //WCHAR wszUrlPath[URLBUFFER_SIZE];
    urlComponents.dwStructSize     = sizeof(URL_COMPONENTS);
    urlComponents.lpszHostName     = szHostName;
    urlComponents.dwHostNameLength = sizeof(szHostName) / sizeof(WCHAR);
    urlComponents.lpszUrlPath      = szUrlPath;
    urlComponents.dwUrlPathLength  = sizeof(szUrlPath) / sizeof(WCHAR);
    if( !WinHttpCrackUrl( wszUrl,
                          lstrlenW(wszUrl),
                          0,
                          &urlComponents ) )
    {
        // URLの解析に失敗
        printf("WinHttpCrackUrl() fail.\n");
        return 0;
    }
    printf("%ls\n", szHostName);
    printf("%ls\n", szUrlPath);
    printf("urlComponents.nPort=%u\n", urlComponents.nPort);

    // HTTPかHTTPSかそれ以外か
    DWORD dwOpenRequestFlag = (INTERNET_SCHEME_HTTPS == urlComponents.nScheme) ? WINHTTP_FLAG_SECURE : 0;
    printf("dwOpenRequestFlag=0x%08x\n", dwOpenRequestFlag);

    hSession = WinHttpOpen(wszAppName, WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (hSession == NULL) return 0;

    printf("(1)\n");

    hConnect = WinHttpConnect(hSession, szHostName, urlComponents.nPort, 0);
    if (hConnect == NULL) {
        WinHttpCloseHandle(hSession);
        return 0;
    }

    printf("(2)\n");

    hRequest = WinHttpOpenRequest(hConnect, L"GET", szUrlPath, NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, dwOpenRequestFlag );
    if (hRequest == NULL) {
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 0;
    }

    printf("(3)\n");

    if (!WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, WINHTTP_IGNORE_REQUEST_TOTAL_LENGTH, 0)) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 0;
    }

    printf("(4)\n");

    WinHttpReceiveResponse(hRequest, NULL);

    dwSize = 0;
    WinHttpQueryHeaders(hRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX, NULL, &dwSize, WINHTTP_NO_HEADER_INDEX);
    lpHeader = (LPBYTE)HeapAlloc(GetProcessHeap(), 0, dwSize);
    WinHttpQueryHeaders(hRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF, WINHTTP_HEADER_NAME_BY_INDEX, lpHeader, &dwSize, WINHTTP_NO_HEADER_INDEX);
    MessageBoxW(NULL, (LPWSTR)lpHeader, L"ヘッダ", MB_OK);
    HeapFree(GetProcessHeap(), 0, lpHeader);

    lpData = ReadData(hRequest, &dwSize);
    MessageBoxA(NULL, (LPSTR)lpData, "ボディ", MB_OK);
    HeapFree(GetProcessHeap(), 0, lpData);

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);


    return 0;
}
#endif
