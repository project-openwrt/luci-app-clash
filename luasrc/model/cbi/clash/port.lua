local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local DISP = require "luci.dispatcher"
local UTIL = require "luci.util"
local uci = require("luci.model.uci").cursor()

m = Map("clash")
s = m:section(TypedSection, "clash")
m.pageaction = false
s.anonymous = true

o = s:option(Value, "http_port")
o.title = translate("Http Port")
o.default = 7890
o.datatype = "port"
o.rmempty = false
o.description = translate("Http Port")

o = s:option(Value, "socks_port")
o.title = translate("Socks Port")
o.default = 7891
o.datatype = "port"
o.rmempty = false
o.description = translate("Socks Port")

o = s:option(Value, "redir_port")
o.title = translate("Redir Port")
o.default = 7892
o.datatype = "port"
o.rmempty = false
o.description = translate("Redir Port")

o = s:option(Value, "dash_port")
o.title = translate("Dashboard Port")
o.default = 9191
o.datatype = "port"
o.rmempty = false
o.description = translate("Dashboard Port")

o = s:option(Value, "dash_pass")
o.title = translate("Dashboard Secret")
o.default = 123456
o.rmempty = false
o.description = translate("Dashboard Secret")

o = s:option(ListValue, "level", translate("Log level"))
o.description = translate("Choose Log Level")
o:value("info", "info")
o:value("silent", "silent")
o:value("warning", "warning")
o:value("error", "error")
o:value("debug", "debug")

o = s:option(Button, "Apply")
o.title = translate("Save & Apply")
o.inputtitle = translate("Save & Apply")
o.inputstyle = "apply"
o.write = function()
local clash_conf = "/etc/clash/config.yaml"
if NXFS.access(clash_conf) then
	uci:commit("clash")
	SYS.call("sh /usr/share/clash/yum_change.sh 2>&1 &")
	if luci.sys.call("pidof clash >/dev/null") == 0 then
	SYS.call("/etc/init.d/clash restart >/dev/null 2>&1 &")
	end
  	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "clash" , "settings", "port"))
else
  	uci:commit("clash")
  	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "clash" , "settings", "port"))
end
end

return m
