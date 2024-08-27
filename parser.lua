local htmlparser = require "htmlparser"
local http_request = require "http.request"
require "lfs"

htmlparser_looplimit = 10000

local _M

local csvfile = assert(io.open('hotels.csv', "w"))

function parse_html(html)
	local data = {}
	local root = htmlparser.parse(html)
	local items = root:select('.info-part')
	for k, item in ipairs(items) do				
		 if (item:select('.info__text')[1]) then
			data[item:select('.info__name')[1]:getcontent()] = item:select('.info__text')[1]:getcontent()
		end
	end	
	for _, item in pairs(data) do
		str = str..';'..item
	end	
	csvfile:write(str..'\n')
end

function get_links()
	local links = {}
	local maxi = 1872
	local i = 1
	while i<=maxi do
		local url = 'https://tourism.gov.ru/reestry/reestr-gostinits-i-inykh-sredstv-razmeshcheniya/?PAGEN_1='..i	
		local headers, stream = assert(http_request.new_from_uri(url):go())
		local body = assert(stream:get_body_as_string())
		local items = root:select(".reestr-item")
		for _, item in ipairs(items) do		
			table.insert(links,item.attributes['data-link'])
		end			
		i = i + 1
	end		
	return links
end

function get_html(url)
	local headers, stream = assert(http_request.new_from_uri(url):go())
	return assert(stream:get_body_as_string())
end

function _M.parse()	
	for key,url in ipairs(get_links()) do
		parse_html(get_html(url))
	end
	csvfile:close()
end

return _M
