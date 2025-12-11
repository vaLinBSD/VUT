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