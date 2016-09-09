#!/usr/bin/python3 
import http.server
from urllib.parse import urlparse
import socketserver
from os import system;

webPage = open("/var/www/index.html", 'r')
resp = webPage.read();
webPage.close();
respReboot = "wifi configuration changed, rebooting"

def reconfigNetwork(ssid, password):
	system("systemctl enable dhcpcd.service")
	system("rm /etc/network/interfaces") 
	system("mv /etc/network/interfaces.bak /etc/network/interfaces") 	
	system("rm /etc/rc.local") 
	system("mv /etc/rc.local.bak /etc/rc.local") 
	system('echo "network={" > /etc/wpa_supplicant/wpa_supplicant.conf')
	system('echo \'ssid="'+ssid+'"\' >> /etc/wpa_supplicant/wpa_supplicant.conf') 	
	system('echo \'psk="'+password+'"\' >> /etc/wpa_supplicant/wpa_supplicant.conf')
	system('echo "}" >> /etc/wpa_supplicant/wpa_supplicant.conf') 
	system('sleep 2 && reboot &')
	
def sendResponse(self, respText):
	self.send_response(200)
	self.send_header("Content-type", "text/html")
	self.send_header("Content-length", len(respText))
	self.end_headers()
	self.wfile.write(respText.encode(encoding='utf_8'))

class Server(http.server.SimpleHTTPRequestHandler):
	def do_GET(self):
		query = urlparse(self.path).query
		if(len(query) > 2):			
			query_components = dict(qc.split("=") for qc in query.split("&"))
			ssid = query_components["SSID"]
			password = query_components["PASSWORD"]
			reconfigNetwork(ssid, password)			
			sendResponse(self, respReboot)
		else:					
			sendResponse(self, resp)

	def serve_forever(port):
		socketserver.TCPServer(('', port), Server).serve_forever()

if __name__ == "__main__":
    Server.serve_forever(8000)
