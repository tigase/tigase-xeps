---
layout: default
title: Encrypted Push Notifications - OMEMO (experimental)
has_children: false
parent: Push Notifications
nav_order: 5
---

# Encrypted Push Notifications - OMEMO
{: .no_toc }
## **WARNING:** THIS IS A PROTOTYPE SPECIFICATION, NOT IMPLEMENTED AND NOT VALIDATED!
{: .no_toc }
**Abstract:** This document specifies a way to send encrypted payload with push notifications for OMEMO encrypted messages.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
Some of the XMPP users want to protect their privacy and not share any more data than it is required. With use of OMEMO XMPP server is unaware of the content of messages and CANNOT publish “rich” notifications.

If XMPP server would be aware of `device_id` of the XMPP client used for OMEMO encryption, in theory it could select proper key from the `<message />` element and forward this data with OMEMO encrypted message.

## 2. Scope
This document describes a way to detect support for this feature, a way to share OMEMO `device_id` used by the XMPP client with the XMPP server.

## 3. Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

The XMPP server MUST support Encrypted Push Notifications as this extension is based on `Encrypted Push Notifications`.

Additionally, it is REQUIRED that XMPP client and its push notification component support this feature to have full benefit of those additional data.

## 4. Push notifications for OMEMO
### 4.1. Discovering support
Before XMPP entity attempts to enable encryption of push notifications, its client SHOULD check if the XMPP server support that; to do so, it MUST send a [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html) to the user’s bare JID:

**Example 1.** Entity queries MUC room for protocol support
````xml
<iq from='juliet@capulet.lit/balcony'
    to='juliet@capulet.lit'
    id='disco1'
    type='get'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
````

If the XMPP servers supports protocol, then it MUST return `tigase:push:encrypt:omemo:0` in the list of supported features:

**Example 2.** XMPP server supports protocol
````xml
<iq from='coven@chat.shakespeare.lit'
    to='juliet@capulet.lit/balcony'
    id='disco1'
    type='result'>
  <query xmlns='http://jabber.org/protocol/disco#info'>
   <feature var='tigase:push:encrypt:omemo:0'/>
   ...
  </query>
</iq>
````

### 4.2. Enabling encryption
In order to enable encryption of push notification payload, the user’s XMPP client SHOULD send push notifications enable request with `<encrypt />` element qualified by `tigase:push:encrypt:0` namespace. This element MUST comply with `Encrypted Push Notification` extension.

Additionally, `<enable/>` element SHOULD contain `<omemo />` element qualified by the `tigase:push:encrypt:omemo:0` namespace. This element MUST contain `deviceId` attribute set to `device_id` used by the XMPP client enabling this push notifications for OMEMO encryption.

**Example 3.** Enabling encryption
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo' >
    <encrypt xmlns='tigase:push:encrypt:0' alg='aes-gcm'>
      BASE64_ENCRYPTED_AES128_KEY....
    </encrypt>
    <omemo xmlns='tigase:push:encrypt:omemo:0'
      deviceId='1325' />
  </enable>
</iq>
````

### 4.3. Publishing notification
When the user's server detects an event warranting a push notification, it performs a PubSub publish to all XMPP Push Services registered for the user, where the item payload is a `<notification />` element in the `urn:xmpp:push:0` namespace.

If this feature is enabled, the XMPP server SHOULD add JSON object as `omemo` to the encrypted JSON object created for `Encrypted Push Notifications`. This new object SHOULD contain following fields:
* `keys` - list of Base64 encoded keys in the OMEMO encrypted message matching `device_id` specified by the client while enabling this feature.
* `sid` - `device_id` of the sender of this encrypted message
* `data` - OMEMO encrypted message
* `iv`- Base64 value of `iv` element from OMEMO header

**Example 4.** Push notification encrypted JSON object with OMEMO data
````json
{
  "unread": 1,
  "sender": "juliet@capulet.example",
  "type": "chat",
  "message": "Encrypted message!",
  "omemo": {
    "keys": [
      "BASE64ENCODED...",
      "BASE64ENCODED..."
    ],
    "sid": "27183",
    "iv": "BASE64ENCODED...",
    "data": "BASE64ENCODED..."
  }
}
````
