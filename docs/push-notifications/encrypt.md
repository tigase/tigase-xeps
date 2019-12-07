---
layout: default
title: Encrypted Push Notifications
has_children: false
parent: Push Notifications
nav_order: 4
---

# Encrypted Push Notifications
{: .no_toc }
**Abstract:** This document specifies a way to send encrypted payload with push notifications.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
Some of the XMPP users want to protect their privacy and not share any more data than it is required. In case of Push Notifications, it means that to have rich push notifications on the mobile clients, it is required to send message sender jid and body of the message to push notifications component and to the push notifications provider. This flow allows 2 more entities (owner of push notifications component and push notifications provider) to scan exchanged data.

Some developers of the XMPP clients, decided not to forward JID and message body to protect users privacy agreeing to the fact that those notifications may not contain useful data for their users.

## 2. Scope
This document describes a way to detect support for this feature, a way to share encryption key with the XMPP server and additional elements which are added the notification payload of encrypted push notifications.

## 3. Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

Additionally, it is REQUIRED that XMPP client and its push notification component support this feature to have full benefit of those additional data.

## 4. Entity Use Cases
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

If the XMPP servers supports protocol, then it MUST return `tigase:push:encrypt:0` in the list of supported features. Those features SHOULD include identifiers of encryption algorithms supported by the XMPP server prefixed with `tigase:push:encrypt:`:

**Example 2.** XMPP server supports protocol
````xml
<iq from='coven@chat.shakespeare.lit'
    to='juliet@capulet.lit/balcony'
    id='disco1'
    type='result'>
  <query xmlns='http://jabber.org/protocol/disco#info'>
   <feature var='tigase:push:encrypt:0'/>
   <feature var='tigase:push:encrypt:aes-128-gcm'/>
   ...
  </query>
</iq>
````

### 4.2. Enabling encryption
In order to enable encryption of push notification payload, the user’s XMPP client SHOULD send push notifications enable request with `<encrypt />` element qualified by `tigase:push:encrypt:0` namespace. This element MUST contain `alg` attribute set to the encryption algorithm supported by the server and the client.

List of supported encryption algorithms and possible values of `alg` attribute:
* `aes-128-gcm` - AES-128 in GCM mode with 128-bit authentication tag

At least AES-128 in GCM mode is required to be supported by the XMPP server and the XMPP client _(`aes-128-gcm`)_; valu to use AES128 encryption in GCM mode.  Moreover, it is REQUIRED that Base64 encoded AES128 encryption key will be value of this element.

`<encrypt />` element MAY also contain `max-size` attribute set to the number of bytes allowed for push notification payload. If this value is provided and payload will not fit, the XMPP server will try to reduce size of the message body (cutout end of the body) to obey specified size.

**Example 3.** Enabling encryption
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo' >
    <encrypt xmlns='tigase:push:encrypt:0' alg='aes-128-gcm'>
      BASE64_ENCODED_AES128_KEY....
    </encrypt>
  </enable>
</iq>
````

### 4.3. Disabling encryption
In order to disable encryption of push notification payload, the user’s XMPP client SHOULD disable push notifications on the XMPP server:

**Example 4.** Disabling encryption
````xml
<iq type='set' id='x42'>
  <disable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo' />
</iq>
````

or once again send push notifications enable request but without adding `<encrypt />` element:

**Example 5.** Reenabling notifications without encryption
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo' />
</iq>
````

### 4.4. Publishing notification
When the user's server detects an event warranting a push notification, it performs a PubSub publish to all XMPP Push Services registered for the user, where the item payload is a `<notification />` element in the `urn:xmpp:push:0` namespace.

A [Data Forms: XEP-0004](https://xmpp.org/extensions/xep-0004.html) form with `FORM_TYPE` set to `urn:xmpp:push:summary` SHOULD NOT be added to the `<notification />` element to be sure that no unencrypted data is being forwarded to push notifications component .

Instead of the form mentioned above, the XMPP server SHOULD create a JSON object with following fields:
* `unread` - containing a number of unread messages
* `sender` - containing a bare JID of a stanza sender causing this notification
* `type` - type of the push notification:
	* `chat` - for 1-1 messages
	* `groupchat` - for MUC rooms and groupchat messages
	* `subscribe` - for presence subscribe requests
	* `call` - for jingle calls
* `message` - body of a message (if available, MAY be only first part of the message body)
* `nickname` - in case of a message of `type` `groupchat`, this field should be set to the nickname of the message sender _(optional)_
* `sid` - in case of a Jingle session initiation, session id of the Jingle call initiated by message _(optional)_

**Example 6.** Payload before encryption
````json
{
  "unread": 1,
  "sender": "juliet@capulet.example",
  "type": "chat",
  "message": "Wherefore art thou, Romeo?"
}
````

This JSON object SHOULD be serialized to bytes and the encrypted using key and the algorithm provided by the XMPP client (specified during enabling of  push notifications).

A `<notification />` element SHOULD contain `<encrypted />` element qualified by the `tigase:push:encrypt:0`namespace. Value of this element SHOULD be a Base64 encoded result of the encryption, which in case of the AES-GCM encryption SHOULD contain attached auth tag at the end of encrypted data.

In case of usage AES-GCM,  `<encrypted/>` element SHOULD contain `iv` attribute set to Base64 encoded `iv` parameter of the AES-GCM encoder.

**Example 7.** Server publishes a push notification
````xml
<iq type='set'
    from='example.com'
    to='push-5.client.example'
    id='n12'>
  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
    <publish node='yxs32uqsflafdk3iuqo'>
      <item>
        <notification xmlns='urn:xmpp:push:0'>
          <encrypted xmlns='tigase:push:encrypt:0'
            iv='BASE64_ENCODED_IV_VALUE'>
            BASE64_ENCODED_ENCRYPTED_PAYLOAD_WITH_AUTHTAG
          </encrypted>
        </notification>
      </item>
    </publish>
  </pubsub>
</iq>
````

## 5. Questions
### 5.1. Why use JSON?
JSON is more lightweight and push notifications providers have a limits for payload length (usually from 2KB to 4KB).
