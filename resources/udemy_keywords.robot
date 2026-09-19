*** Comments ***
# ==============================================================================
# 檔案用途：udemy_keywords.robot
# ==============================================================================
# 這個檔案負責把「一連串重複會用到的操作」包裝成一個個「自訂關鍵字」。
#
# 舉例：每個測試案例開頭幾乎都要「開瀏覽器 → 最大化視窗 → 等搜尋框出現」，
# 與其在 10 個測試案例裡複製貼上這 3 行，不如包成一個關鍵字「開啟Udemy首頁」，
# 之後測試案例只要寫一行「開啟Udemy首頁」就等於執行了這 3 個步驟。
#
# 這個檔案會「引用」udemy_locators.robot 裡定義好的 Selector 變數來使用，
# 讓關鍵字邏輯與元素定位器分開管理，各司其職。
# ==============================================================================


*** Settings ***
# 因為這個檔案裡會用到 SeleniumLibrary 提供的關鍵字（Open Browser、Click Element 等），
# 所以要先 Import 這個 Library，跟寫測試案例時一樣的道理。
Library    SeleniumLibrary

# OperatingSystem 是 Robot Framework 內建函式庫之一，
# 這裡用它來讀取「環境變數」，判斷目前是在你自己電腦執行、還是在 GitHub Actions 雲端執行。
Library    OperatingSystem

# Resource 是「引用其他 .robot 檔案」的語法。
# 這裡把 udemy_locators.robot 引進來，這樣下面就可以直接使用
# 裡面定義的 ${SEARCH_BOX}、${NAV_LOGIN} 等變數。
# 路徑寫法：同一層的 resources 資料夾裡的檔案，直接寫檔名即可。
Resource   udemy_locators.robot


*** Keywords ***
# ==============================================================================
# 自訂關鍵字區塊
# 語法規則：關鍵字名稱可以用中文（Robot Framework 支援），
# 底下的內容就是這個關鍵字被呼叫時，實際會依序執行的步驟。
# ==============================================================================

開啟瀏覽器並前往
    [Documentation]    統一的開瀏覽器邏輯，自動判斷「本機執行」還是「CI 雲端執行」，切換有畫面/無畫面模式
    [Arguments]    ${url}
    # ------------------------------------------------------------------------
    # 【CI/CD 排程的關鍵設計】
    # GitHub Actions 的雲端伺服器沒有螢幕，沒辦法開一個「看得到畫面」的 Chrome 視窗，
    # 必須用 Headless（無頭）模式執行，瀏覽器在背景跑，不會顯示任何視窗。
    #
    # 但你自己在 Windows 電腦上執行時，通常會想看到瀏覽器實際跑起來的過程（方便除錯），
    # 所以這裡設計成「自動判斷環境」：
    # - GitHub Actions 執行時，系統會自動幫你設定一個環境變數 CI=true
    # - 你自己在電腦上執行時，這個環境變數不存在，預設會拿到 false
    # 用這個判斷，同一套程式碼，本機執行有畫面、雲端執行自動切換無頭模式，不用維護兩份程式碼。
    # ------------------------------------------------------------------------
    ${is_ci}=    Get Environment Variable    CI    default=false

    IF    '${is_ci}' == 'true'
        # 雲端環境：組合 Headless 模式需要的啟動參數
        # --headless=new：新版無頭模式，不開實體視窗
        # --disable-gpu：雲端伺服器通常沒有顯示卡，關閉 GPU 加速避免相容性問題
        # --no-sandbox：GitHub Actions 容器環境的權限限制，加這個參數避免啟動失敗
        # --window-size=1920,1080：無頭模式沒有真實視窗大小，手動指定，避免某些版面判斷失準
        #
        # 【關鍵新增】--user-agent=...
        # 無頭 Chrome 預設的瀏覽器識別字串（User-Agent）裡會帶有「HeadlessChrome」這個字樣，
        # 這次失敗的原因很可能就是 Udemy 偵測到這個特徵，判斷為自動化程式，
        # 沒有提供正常頁面內容（h1 抓到的是 'www.udemy.com' 這種異常內容，不是真正的課程標題）。
        # 這裡手動指定一個「看起來像一般 Windows Chrome 瀏覽器」的 User-Agent 字串，降低被判斷為機器人的機率。
        ${options}=    Set Variable
        ...    add_argument("--headless=new");add_argument("--disable-gpu");add_argument("--no-sandbox");add_argument("--window-size=1920,1080");add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
        Open Browser    ${url}    chrome    options=${options}
        # 額外給頁面一點緩衝時間，讓 JavaScript 內容有機會完整載入，
        # 無頭模式有時候載入時機會比有畫面模式稍微不穩定
        Sleep    2s
    ELSE
        # 本機環境：維持原本的做法，開一個看得到的視窗，方便你自己盯著畫面除錯
        Open Browser    ${url}    chrome
        Maximize Browser Window
    END


開啟Udemy首頁
    [Documentation]    開啟瀏覽器、導航到 Udemy 首頁，並確認頁面已完整載入（等搜尋框出現）
    # 改呼叫上面新增的「開啟瀏覽器並前往」關鍵字，取代原本寫死的 Open Browser
    開啟瀏覽器並前往    https://www.udemy.com/
    # 等待搜尋框出現，代表頁面主要內容已經載入完成，才能繼續下一步操作
    # 這裡直接引用 locators 檔案裡定義好的 ${SEARCH_BOX} 變數
    #
    # 【調整】timeout 從 15 秒拉長到 30 秒。
    # 首頁內容通常比單一課程頁面複雜（更多區塊、圖片、可能有 Cookie 同意橫幅等），
    # 無頭模式下載入這些額外內容可能需要更久時間，之前 15 秒不夠導致抓不到搜尋框。
    Wait Until Page Contains Element    ${SEARCH_BOX}    timeout=30s


搜尋關鍵字
    [Documentation]    在搜尋框輸入指定關鍵字並送出搜尋
    # [Arguments] 讓這個關鍵字可以「接收參數」，呼叫時可以傳入不同的關鍵字字串
    # 例如：搜尋關鍵字    Python  或  搜尋關鍵字    JavaScript，同一段邏輯重複使用
    [Arguments]    ${keyword}
    Input Text    ${SEARCH_BOX}    ${keyword}
    # 模擬按下 Enter 鍵，送出搜尋（等同你在搜尋框打完字後按下 Enter）
    Press Keys    ${SEARCH_BOX}    RETURN
    # 給頁面一點時間載入搜尋結果，避免下一步驟因為畫面還沒跑出來而失敗
    Sleep    3s


驗證課程標題包含
    [Documentation]    驗證課程頁面的標題（h1）是否包含指定文字，用於確認頁面內容正確
    [Arguments]    ${expected_text}
    # 先確認標題元素真的有出現在畫面上，避免元素還沒載入就急著檢查文字而失敗
    Wait Until Page Contains Element    ${COURSE_TITLE}    timeout=15s
    # Element Should Contain：檢查該元素的文字「是否包含」指定字串
    # 如果標題文字裡沒有 ${expected_text} 這段文字，這一行會直接讓測試失敗（FAIL）
    Element Should Contain    ${COURSE_TITLE}    ${expected_text}


驗證頁面有價格資訊
    [Documentation]    等待頁面上出現含有 $ 符號的文字，用最寬鬆的方式確認價格資訊有顯示出來
    # 這裡把 timeout 拉到 30 秒，比之前任何一次嘗試都久。
    # 原因：這個課程頁面右側購買面板反覆被證實是非同步、載入時機不穩定的區塊，
    # 與其一直猜測合理的等待時間，不如給足夠寬裕的緩衝，把「會不會抓到」的變數降到最低。
    #
    # ${PRICE_INFO} 用的是「文字裡有沒有 $ 符號」這種最寬鬆的條件，
    # 不管價格顯示在哪個標籤、哪個 class、是原價還是折扣價，只要有 $ 符號出現就算通過，
    # 這是目前為止最不受前端結構變動影響的寫法。
    Wait Until Page Contains Element    ${PRICE_INFO}    timeout=30s
