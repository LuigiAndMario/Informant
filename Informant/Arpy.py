import sys
from datetime import datetime
from scapy.all import srp, Ether, ARP, conf

try:
    interface = sys.argv[1]
    ip_range = sys.argv[2]
except KeyboardInterrupt:
    print "\nAborting..."
    sys.exit(1)

start_time = datetime.now()

### SCAN
conf.verb = 0
answered, unanswered = srp(Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(pdst = ip_range),
                           timeout = 2,
                           iface = interface,
                           inter = 0.1)

end_time = datetime.now()
print "\nFinished scanning after %d seconds." %(int((end_time - start_time).seconds))
print "Scanning went down with %d answer(s) and %d packet(s) dropped.\n" \
    %(len(answered), len(unanswered))

for sender, receiver in answered:
    print receiver.sprintf(r"%Ether.src% %ARP.psrc%")

exit(0)
