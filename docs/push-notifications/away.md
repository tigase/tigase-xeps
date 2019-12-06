---
layout: default
title: Sending notifications while AWAY/XA
has_children: false
parent: Push Notifications
nav_order: 2
---

# Push Notifications - Sending notifications while AWAY/XA
{: .no_toc }
**Abstract:** This specification defines XMPP protocol extension allowing XMPP clients to inform XMPP server that it would like to receive Push Notifications even if another XMPP client is connected but it is in `AWAY`/`XA` state.


## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) defines a way for the XMPP server to generate push notifications by publishing them to the application specific XMPP Push Notification Component. However, that extension does not specify any rules for generating push notifications.

This extension was created to provide a way to inform XMPP server that client wants to receive push notifications even while other clients are in `AWAY`/`XA` state.

## 2. Scope
This documents specifies a way of enabling publishing push notifications while user has some connections active. This extension is an extenion to payload send to enable push notifications as specified in [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html).

## 3.  Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

## 4. Sending notifications while AWAY
In some cases XMPP clients want to receive notifications even if there is another client connected but in AWAY (presence with `xa` or `away`).

### 4.1. Discovering support
Before enabling this feature, a client SHOULD determine whether the user's server supports publishing push notifications while there are other clients with presence set to `away`; to do so, it MUST send a  [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html)  [2] information quest to the user's bare JID:

**Example 1.** Client queries server regarding protocol support
````xml
<iq from='user@example.com/mobile'
    to='user@example.com'
    id='x13'
    type='get'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
````

**Example 2.** Server communicates protocol support
````xml
<iq from='juliet@capulet.lit'
    to='juliet@capulet.lit/balcony'
    id='disco1'
    type='result'>
  <query xmlns='http://jabber.org/protocol/disco#info'>
    <identity category='account' type='registered'/>
    <feature var='tigase:push:away:0'/>
    ...
  </query>
</iq>
````

### 4.2. Enabling feature
To enable this feature XMPP client SHOULD send enable request with `away` attribute of `enable` element set to `true`:

**Example 3.** Enabling feature
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo'
    away='true' />
</iq>
````
