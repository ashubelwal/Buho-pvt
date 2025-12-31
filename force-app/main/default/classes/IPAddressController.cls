public with sharing class IPAddressController {

    public String ip { get; private set; }

    public PageReference getUserIPAddress() {
        // True-Client-IP has the value when the request is coming via the caching integration.
        ip = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (String.isBlank(ip)) {
            ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }

        // get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(ip)) {
            ip = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }

        ip = JSON.serialize(new Map<String, String> {'ip' => ip});

        return null;
    }
}