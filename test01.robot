*** Settings ***
Library           SeleniumLibrary

*** Variables ***
${URL}          https://www.udemy.com/
${BROWSER}      chrome

*** Test Cases ***


*** Test Cases ***
首頁基本載入測試
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath://input[@placeholder='搜尋任何事物']    timeout=15s
    Capture Page Screenshot    01_homepage_load.png
    Close Browser

搜尋功能測試
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath://input[@placeholder='搜尋任何事物']    timeout=15s
    Input Text    xpath://input[@placeholder='搜尋任何事物']    Python
    Press Keys    xpath://input[@placeholder='搜尋任何事物']    RETURN
    Sleep    3s
    Capture Page Screenshot    02_search_result.png
    Close Browser

導覽列連結存在性測試
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath://a[contains(.,'探索')]    timeout=15s
    Page Should Contain Element    xpath://a[contains(.,'探索')]
    Page Should Contain Element    xpath://a[contains(.,'登入')]
    Capture Page Screenshot    03_nav_links.png
    Close Browser

登入按鈕跳轉測試
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath://a[contains(.,'登入')]    timeout=15s
    Click Element    xpath://a[contains(.,'登入')]
    Sleep    3s
    Capture Page Screenshot    04_login_page.png
    Close Browser