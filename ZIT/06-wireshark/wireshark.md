## **Analýza komunikace ve Wireshark**

V tomto dokumentu analyzuji dle zadání komunikaci mezi počítačem a sítí od momentu připojení (respektive od aktivace síťového rozhraní) až po navázání zabezpečeného webového spojení.

Odchyt paketů byl proveden pomocí programu Wireshark a poté byla prováděna postupná filtrace vzniklého záznamu pomocí CLI nástroje tshark tak, aby se vyhovělo požadavkům zadání. Výstup z jednotlivých filtrací jsem připojil k relevantním krokům v analýze.

Příklad filtrace: $ tshark -r komunikace_filtered.pcapng -Y "frame.number == 3"

# **Analýza**

DHCP
    * po fyzické aktivaci síťového rozhraní by mělo dojít k tzv. DORA cyklu (Discover, Offer, Request, ACK), nicméně k tomuto plnému cyklu obvykle dochází jen tehdy, pokud se klient vyskytne v cílové síti poprvé a DHCP server jej nikdy neviděl (tedy jeho MAC adresu respektive Client Identifier)

    * v mém případě došlo jen ke zrychlenému procesu (Request, ACK), kdy DHCP server provede znovupřidělení již dříve přidělené IP adresy

    Pakety: 1,2

ARP
    * po DHCP konfiguraci síťového rozhraní se klient ptá pomocí Address Resolution Protocol (request) na MAC adresu své výchozí brány (Who has 192.168.1.1?)
    * v dalším paketu přichází odpověď ve formě Address Resolution Protocol (reply), ve které je uvedena MAC adresa brány (e4:8d:8c:b0:4d:97)
    * ARP protokol je tedy jakýmsi překladatelem adres mezi linkovou (MAC) a síťovou (IP) vrstvou

    Pakety: 3,4

DNS
    * 

TCP

HTTPS/TLS