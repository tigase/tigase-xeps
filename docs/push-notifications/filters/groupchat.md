---
layout: default
title: Filtering groupchat notifications
has_children: false
parent: Filters
nav_order: 3
grand_parent: Push Notifications
---

# Filtering groupchat notifications
{: .no_toc }
**Abstract:** This specification defines XMPP protocol extension allowing XMPP clients to specify rules for XMPP server to filter Push Notifications  generated for groupchat messages before sending them to Push Notification Component.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) defines a way for the XMPP server to generate push notifications by publishing them to the application specific XMPP Push Notification Component. However, that extension does not specify any rules for generating push notifications, nor any rules for filtering them forcing XMPP servers to publish notifications about any incoming messages while XMPP client is not connected.

This extension was created to provide those rules for filtering notifications for groupchat messages, which SHOULD reduce load on the XMPP clients (ie. on mobile devices) by reduced number of push notifications sent to them.

## 2. Scope
This documents specifies ways of defining rules for filtering generated push notifications for groupchat messages. Those rules are extensions to payload send to enable push notifications as specified in [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html).

## 3.  Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

## 4. Filtering groupchat notifications
With usage of MUC users may want to receive some of the notifications. In some rooms all of them, in some none of notifications and in some rooms notifications only when their nick is mentioned in the message.

**_Note:_** This feature is supported only for MUC rooms which have support for sending messages to unavailable occupants (see Tigase custom extension).

### 4.1. Discovering support
Before enabling this feature, a client SHOULD determine whether user's server supports filtering push notifications from MUC rooms; to do so, it MUST send a  [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html)  [2] information query to the user's bare JID:

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
    <feature var='tigase:push:filter:groupchat:0'/>
    ...
  </query>
</iq>
````

### 4.2. Enabling filter
To enable this filter, XMPP client SHOULD send enable request with `<groupchat />` element qualified by the `tigase:push:filter:groupchat:0` namespace.

This element SHOULD contains list of rules for all groupchats for which notifications SHOULD be sent. Each rule MUST be specified as `<room />` element. It MUST have `jid` attribute set to groupchat bare JID and `allow` attribute set to:
* `always` - to receive notifications for all messages
* `never` - to never receive notifications
* `mentioned` - to receive notifications when mentions.

If `mentioned` is passed as a value for `allow` attribute, then `nick` attribute MUST be set as well to the value of a nickname for which notifications SHOULD be generated.

**Example 3.** Enabling filter
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo'>
    <groupchat xmlns='tigase:push:filter:groupchat:0'>
      <room jid='coven@chat.shakespeare.lit'
        allow='always' />
      <room jid='forres@chat.shakespeare.lit'
        allow='mentioned' nick='Juliet' />
    </muc>
  </enable>
</iq>
````
