utils = { }
 
 
function utils.getPercent(_curV, _maxV)
    local _percent = _curV / _maxV * 100
    if _percent > 100 then
        _percent = 100
    end
    return _percent
end

--- 富文本格式化（内容格式：<color=0,0,0>文本内容</color>）
-- 返回一个table
-- table.color : c3b对象, table.text : 要显示的文本内容
function utils.richTextFormat(_msgContent)
    local contentData = { }
    local root = utils.stringSplit(_msgContent, "<color=")
    for key, rootObj in pairs(root) do
        local a = utils.stringSplit(rootObj, "</color>")
        for _aKey, _aObj in pairs(a) do
            local b = utils.stringSplit(_aObj, ">")
            if #b == 2 then
                local c = utils.stringSplit(b[1], ",")
                contentData[#contentData + 1] = {
                    color = cc.c3b(c[1],c[2],c[3]),
                    text = b[2]
                }
            else
                contentData[#contentData + 1] = {
                    color = cc.c3b(255,255,255),
                    text = b[1]
                }
            end
        end
    end
    return contentData
end

--- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function utils.stringSplit(str, split_char)
    local sub_str_tab = { };
    if str == nil then
        return sub_str_tab
    end
    while (true) do
        local pos, pos1 = string.find(str, split_char);
        if (not pos) then
            if str ~= "" then
                sub_str_tab[#sub_str_tab + 1] = str;
            end
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        if pos1 + 1 > #str then break end
        str = string.sub(str, pos1 + 1, #str);
    end

    return sub_str_tab;
end
--- 字符串的长度(包括中文)
function utils.utf8len(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end
--- 获得指定字符串长度(包括中文)---
function utils.getUTF8Str(str, index)
    local _str = nil

    local cnt = 0
    local len = #str
    local left = len
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if cnt == index then
            _str = string.sub(str, - left - i, - left - 1)
            break
        end
    end
    return _str
end
--- 截取指定字符串(包括中文)
--- index_l 左指针
--- index_r 右指针
function utils.UTF8StrSub(str, index_l, index_r)
    local _str = nil
    local _index_l = nil
    local _index_r = nil
    local cnt = 0
    local len = #str
    local left = len
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(str, - left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if cnt == index_l then
            _index_l = - left - i
            if not index_r then
                _str = string.sub(str, _index_l, len)
                break
            end
        elseif cnt == index_r then
            _index_r = - left
            _str = string.sub(str, _index_l, _index_r - 1)
            break
        end
    end
    return _str
end
--- 参数:时间字符串 less 减少几个小时(24小时内)
-- FormatTime  yyyy-MM-dd HH:mm:ss
-- 返回table表
function utils.changeTimeFormat(FormatTime, less)
    local time_tab = { }
    local temp = utils.stringSplit(FormatTime, " ")
    local date = utils.stringSplit(temp[1], "-")
    local time = utils.stringSplit(temp[2], ":")
    if less then
        time[1] = time[1] - less
        if time[1] < 0 then
            time[1] =(time[1] % 24)
            date[3] = date[3] -1
        end
    end
    table.insert(time_tab, date[1])
    -- 年
    table.insert(time_tab, date[2])
    -- 月
    table.insert(time_tab, date[3])
    -- 日
    table.insert(time_tab, tonumber(time[1]) * 3600 + tonumber(time[2]) * 60 + tonumber(time[3]))
    table.insert(time_tab, time[1])
    -- 时
    table.insert(time_tab, time[2])
    -- 分
    table.insert(time_tab, time[3])
    -- 秒
    return time_tab
end

---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss less 减少几个小时(24小时内)
function utils.GetTimeByDate(FormatTime, less)
    local temp = utils.stringSplit(FormatTime, " ")
    local date = utils.stringSplit(temp[1], "-")
    local time = utils.stringSplit(temp[2], ":")
    if less then
        time[1] = time[1] - less
        if time[1] < 0 then
            time[1] = time[1] % 24
            date[3] = date[3] -1
        end
    end
    local t = os.time( { year = date[1], month = date[2], day = date[3], hour = time[1], min = time[2], sec = time[3] })

    return t
end

-- 返回m~n之间的随机数
function utils.random(m, n)
    while (true) do
        timenow = os.time()
        if timenow ~= lasttime then
            return math.random(m, n)
        end
        lasttime = timenow
    end
end

--- 返回size个m~n之间不同的随机数
function utils.randoms(m, n, size)
    local function isContains(t_, v_)
        if t_ and table.getn(t_) > 0 then
            for i = 1, table.getn(t_) do
                if t_[i] == v_ then
                    return true
                end
            end
        else
            return false
        end
    end

    local rnd = { }
    for i = 1, size do
        local value = utils.random(m, n)
        while (isContains(rnd, value)) do
            value = utils.random(m, n)
        end
        rnd[i] = value
    end

    return rnd
end

--- 快速排序
-- @_table : 需要排序的表
-- @compareFunc : 比较函数
function utils.quickSort(_table, compareFunc)

    local function partion(_table, left, right, compareFunc)
        local key = _table[left]
        local index = left
        _table[index], _table[right] = _table[right], _table[index]
        local i = left
        while i < right do
            if compareFunc(key, _table[i]) then
                _table[index], _table[i] = _table[i], _table[index]
                index = index + 1
            end
            i = i + 1
        end
        _table[right], _table[index] = _table[index], _table[right]
        return index
    end

    local function quick(_table, left, right, compareFunc)
        if left < right then
            local index = partion(_table, left, right, compareFunc)
            quick(_table, left, index - 1, compareFunc)
            quick(_table, index + 1, right, compareFunc)
        end
    end

    quick(_table, 1, #_table, compareFunc)
end

function utils.updateHorzontalScrollView(uiItem, scrollView, listItem, thingData, setScrollViewItem, config)
    config = config or { }
    local space = config.space or 0
    local leftSpace = config.leftSpace or 0
    local rightSpace = config.rightSpace or 0
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local innerWidth = leftSpace +(listItemSize.width + space) * #thingData - space + rightSpace
    innerWidth = innerWidth < scrollViewSize.width and scrollViewSize.width or innerWidth
    scrollView:setInnerContainerSize(cc.size(innerWidth, scrollViewSize.height))

    local bufferCount = math.ceil(scrollViewSize.width /(listItemSize.width + space)) + 1
    bufferCount = math.min(#thingData, bufferCount)
    local left = 1
    local right = math.min(left + bufferCount - 1, #thingData)

    local children = scrollView:getChildren()

    while #children > bufferCount do
        children[#children]:removeFromParent()
        children[#children] = nil
    end
    while #children < bufferCount do
        children[#children + 1] = listItem:clone()
        scrollView:addChild(children[#children])
    end

    local function getPositionX(i)
        return leftSpace +(i - 1) *(listItemSize.width + space) + listItemSize.width / 2
    end

    local function scrollingEvent(scrollUpdate)
        if scrollView:getChildrenCount() <= 0 then return end

        local containerX = scrollView:getInnerContainer():getPositionX()

        local showLeft = math.floor((0 - containerX - leftSpace) /(listItemSize.width + space)) + 1
        local showRight = math.floor((scrollViewSize.width - containerX - leftSpace) /(listItemSize.width + space)) + 1

        showLeft = math.max(1, math.min(#thingData, showLeft))
        showRight = math.max(1, math.min(#thingData, showRight))

        scrollUpdate = scrollUpdate or(showRight < left or showLeft > right)

        if scrollUpdate then
            if showLeft + right - left > #thingData then
                left = left - right + showRight
                right = showRight
            else
                right = showLeft + right - left
                left = showLeft
            end

            for tag = left, right do
                local i = math.ceil((tag - 1) % bufferCount) + 1
                local child = children[i]
                if config.setTag then child:setTag(tag) end
                child:setPositionX(getPositionX(tag))
                child:setLocalZOrder(tag)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[tag])
                else
                    setScrollViewItem(child, thingData[tag])
                end
            end
        else
            while showLeft < left do
                left = left - 1
                local child = children[math.ceil((right - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(left) end
                child:setPositionX(getPositionX(left))
                child:setLocalZOrder(left)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[left])
                else
                    setScrollViewItem(child, thingData[left])
                end
                right = right - 1
            end

            while showRight > right do
                right = right + 1
                local child = children[math.ceil((left - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(right) end
                child:setPositionX(getPositionX(right))
                child:setLocalZOrder(right)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[right])
                else
                    setScrollViewItem(child, thingData[right])
                end
                left = left + 1
            end
        end
    end

    scrollView:addEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            scrollingEvent()
        end
    end )

    if uiItem.isFlush then
        uiItem.isFlush = nil
        scrollingEvent(true)
    else
        local jumpTo = config.jumpTo or 1
        local max = innerWidth - scrollViewSize.width
        local thumb =(jumpTo - 1) *(listItemSize.width + space) + leftSpace
        local percent = 100 * math.min(1, math.max(0, thumb / max))
        scrollView:jumpToPercentHorizontal(percent)
        scrollingEvent(true)
    end
end

function utils.updateScrollView(uiItem, scrollView, listItem, thingData, setScrollViewItem, config)
    config = config or { }
    local space = config.space or 0
    local topSpace = config.topSpace or 5
    local bottomSpace = config.bottomSpace or 0
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local innerHeight = topSpace +(listItemSize.height + space) * #thingData - space + bottomSpace
    innerHeight = innerHeight < scrollViewSize.height and scrollViewSize.height or innerHeight
    scrollView:setInnerContainerSize(cc.size(scrollViewSize.width, innerHeight))

    local bufferCount = math.ceil(scrollViewSize.height /(listItemSize.height + space)) + 1
    bufferCount = math.min(#thingData, bufferCount)
    local top = 1
    local bottom = math.min(top + bufferCount - 1, #thingData)

    local children = scrollView:getChildren()

    while #children > bufferCount do
        children[#children]:removeFromParent()
        children[#children] = nil
    end
    while #children < bufferCount do
        children[#children + 1] = listItem:clone()
        scrollView:addChild(children[#children])
    end

    local function getPositionY(i)
        return innerHeight - topSpace -(i - 1) *(listItemSize.height + space) - listItemSize.height / 2
    end

    local function scrollingEvent(scrollUpdate)
        if scrollView:getChildrenCount() <= 0 then return end

        local containerY = scrollView:getInnerContainer():getPositionY()

        local showTop = math.floor((containerY + innerHeight - topSpace - scrollViewSize.height) /(listItemSize.height + space)) + 1
        local showBottom = math.floor((containerY + innerHeight - topSpace) /(listItemSize.height + space)) + 1

        showTop = math.max(1, math.min(#thingData, showTop))
        showBottom = math.max(1, math.min(#thingData, showBottom))

        scrollUpdate = scrollUpdate or(showBottom < top or showTop > bottom)

        if scrollUpdate then
            if showTop + bottom - top > #thingData then
                top = top - bottom + showBottom
                bottom = showBottom
            else
                bottom = showTop + bottom - top
                top = showTop
            end

            for tag = top, bottom do
                local i = math.ceil((tag - 1) % bufferCount) + 1
                local child = children[i]
                if config.setTag then child:setTag(tag) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(tag))
                child:setLocalZOrder(tag)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[tag])
                else
                    setScrollViewItem(child, thingData[tag])
                end
            end
        else
            while showTop < top do
                top = top - 1
                local child = children[math.ceil((bottom - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(top) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(top))
                child:setLocalZOrder(top)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[top])
                else
                    setScrollViewItem(child, thingData[top])
                end
                bottom = bottom - 1
            end

            while showBottom > bottom do
                bottom = bottom + 1
                local child = children[math.ceil((top - 1) % bufferCount) + 1]
                if config.setTag then child:setTag(bottom) end
                child:setPosition(config.noAction and 0 or scrollViewSize.width / 2, getPositionY(bottom))
                child:setLocalZOrder(bottom)
                if config.flag ~= nil then
                    setScrollViewItem(config.flag, child, thingData[bottom])
                else
                    setScrollViewItem(child, thingData[bottom])
                end
                top = top + 1
            end
        end
    end

    scrollView:addEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            scrollingEvent()
        end
    end )

    if uiItem.isFlush then
        uiItem.isFlush = nil
        scrollingEvent(true)
    else
        local jumpTo = config.jumpTo or 1
        local max = innerHeight - scrollViewSize.height
        local thumb =(jumpTo - 1) *(listItemSize.height + space) + topSpace
        local percent = 100 * math.min(1, math.max(0, thumb / max))
        scrollView:jumpToPercentVertical(percent)
        scrollingEvent(true)

        if not UIGuidePeople.guideFlag then
            if not config.noAction then
                ActionManager.ScrollView_SplashAction(scrollView, false, true)
            end
        end
    end

    return scrollingEvent
end

