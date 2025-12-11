## **Analýza komunikace ve Wireshark**

V tomto dokumentu analyzuji dle zadání komunikaci mezi počítačem a sítí od momentu připojení (respektive od aktivace síťového rozhraní) až po navázání zabezpečeného webového spojení.

Odchyt paketů byl proveden pomocí programu Wireshark a poté byla prováděna postupná filtrace vzniklého záznamu pomocí CLI nástroje tshark tak, aby se vyhovělo požadavkům zadání. Výstup z jednotlivých filtrací jsem připojil k relevantním krokům v analýze.

Příklad filtrace: $ tshark -r pakety_filtr.pcapng -Y "frame.number == 3"

# **Analýza**

DHCP
    * po fyzické aktivaci síťového rozhraní by mělo dojít k tzv. DORA cyklu (Discover, Offer, Request, ACK), nicméně k tomuto plnému cyklu obvykle dochází jen tehdy, pokud se klient vyskytne v cílové síti poprvé a DHCP server jej nikdy neviděl (myšleno jeho MAC adresu respektive Client Identifier)
    * v mém případě došlo jen ke zrychlenému procesu (Request, ACK), kdy DHCP server provede znovupřidělení již dříve přidělené IP adresy

Pakety: 1,2

ARP
    * po DHCP konfiguraci síťového rozhraní se klient ptá pomocí Address Resolution Protocol (request) na MAC adresu své výchozí brány (Who has 192.168.1.1?)
    * v dalším paketu přichází odpověď ve formě Address Resolution Protocol (reply), ve které je uvedena MAC adresa brány (e4:8d:8c:b0:4d:97)
    * ARP protokol je tedy jakýmsi překladatelem adres mezi linkovou (MAC) a síťovou (IP) vrstvou

Pakety: 3,4

DNS
    * klient se dotazuje (pomocí DNS query) na A (IPv4) respektive AAAA (IPv6) záznam pro doménové jméno www.google.com. DNS server odpovídá (pomocí DNS response) s tím, že cílová ip adresa je 142.251.36.100 (IPv4), respektive 2a00:1450:4014:80b::2004 (IPv6)
    * DNS (Domain Name System) je hierarchická služba, která zajišťuje překlad mezi doménovými jmény a IP adresami

Pakety: 5,6,7,9

TCP
    * před samotným přenosem dat je nutné navázat spolehlivé TCP spojení pomocí tzv. trojcestného handshake. Ten se skládá z posloupnosti SYN, SYN-ACK a ACK
    * TCP (Transmission Control Protocol) je spojový protokol, jehož cílem je zaručit, že posílané pakety dorazí k cíli konzistentní (beze ztrát) a ve správném pořadí

Pakety: 13,15,17

TLS
    * po úspěšném vytvoření TCP spojení je zahájen TLS handshake pomocí ClientHello na který webserver odpovídá zprávou ServerHello, ve které jsou nastaveny parametry šifrování a ve které webserver také posílá svůj certifikát
    * po takto navázaném spojení následuje přenos šifrovaného obsahu webové stránky
    * tato komunikace probíhá ve standardním scénáři na cílový port 443
    * TLS (Transport Layer Security) je kryptografický protokol, který zajišťuje důvěrnost a integritu nad TCP

Pakety: 

    1 0.000000000      0.0.0.0 → 255.255.255.255 DHCP 339 DHCP Request  - Transaction ID 0xc4edb3f4
    2 0.014649952  192.168.1.1 → 192.168.1.166 DHCP 342 DHCP ACK      - Transaction ID 0xc4edb3f4
    3 0.027513265 Intel_75:ce:a2 → Broadcast    ARP 42 Who has 192.168.1.1? Tell 192.168.1.166
    4 0.028379011 Routerboardc_b0:4d:97 → Intel_75:ce:a2 ARP 60 192.168.1.1 is at e4:8d:8c:b0:4d:97
    5 0.031360420 192.168.1.166 → 192.168.1.1  DNS 85 Standard query 0x48f6 A www.google.com OPT
    6 0.031581348 192.168.1.166 → 192.168.1.1  DNS 85 Standard query 0x246d AAAA www.google.com OPT
    7 0.044684297  192.168.1.1 → 192.168.1.166 DNS 90 Standard query response 0x48f6 A www.google.com A 142.251.36.100
    8 0.045040802 192.168.1.166 → 192.168.1.1  DNS 74 Standard query 0xa1bd A www.google.com
    9 0.046542218  192.168.1.1 → 192.168.1.166 DNS 102 Standard query response 0x246d AAAA www.google.com AAAA 2a00:1450:4014:80b::2004
   10 0.046782194 192.168.1.166 → 192.168.1.1  DNS 74 Standard query 0x79fb AAAA www.google.com
   11 0.048360342  192.168.1.1 → 192.168.1.166 DNS 90 Standard query response 0xa1bd A www.google.com A 142.251.36.100
   12 0.049924937  192.168.1.1 → 192.168.1.166 DNS 102 Standard query response 0x79fb AAAA www.google.com AAAA 2a00:1450:4014:80b::2004
   13 0.051510918 192.168.1.166 → 142.251.36.100 TCP 74 49596 → 443 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=2206405876 TSecr=0 WS=1024
   14 0.051690145 192.168.1.166 → 142.251.36.100 TCP 74 49598 → 443 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=2206405876 TSecr=0 WS=1024
   15 0.061277991 142.251.36.100 → 192.168.1.166 TCP 74 443 → 49596 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1412 SACK_PERM TSval=93741002 TSecr=2206405876 WS=256
   16 0.062430956 142.251.36.100 → 192.168.1.166 TCP 74 443 → 49598 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1412 SACK_PERM TSval=4142974453 TSecr=2206405876 WS=256
   17 0.062687676 192.168.1.166 → 142.251.36.100 TLSv1.2 1790 Client Hello (SNI=www.google.com)
   18 0.064001550 192.168.1.166 → 142.251.36.100 TLSv1.2 1854 Client Hello (SNI=www.google.com)
   19 0.108090515 142.251.36.100 → 192.168.1.166 TLSv1.3 2866 Server Hello, Change Cipher Spec
   20 0.110708617 142.251.36.100 → 192.168.1.166 TLSv1.3 1466 Server Hello, Change Cipher Spec
   21 0.161040904 Routerboardc_b0:4d:97 → Broadcast    ARP 60 Who has 192.168.1.112? Tell 192.168.1.1
   22 0.468477302 192.168.1.166 → 192.168.1.1  DNS 88 Standard query 0x62e3 A ogads-pa.clients6.google.com
   23 0.468577888 192.168.1.166 → 192.168.1.1  DNS 88 Standard query 0x7a0c AAAA ogads-pa.clients6.google.com