---
layout: default
title: Filtering notifications from unknown senders
has_children: false
parent: Filters
nav_order: 1
grand_parent: Push Notifications
---

# Filtering notifications from unknown senders
{: .no_toc }
**Abstract:** This specification defines XMPP protocol extension allowing XMPP clients to order XMPP server to NOT SEND push notifications from unknown senders.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) defines a way for the XMPP server to generate push notifications by publishing them to the application specific XMPP Push Notification Component. However, that extension does not specify any rules for generating push notifications, nor any rules for filtering them forcing XMPP servers to publish notifications about any incoming messages while XMPP client is not connected.

This extension was created to provide those rules for filtering notifications, which SHOULD reduce load on the XMPP clients (ie. on mobile devices) by reduced number of push notifications sent to them.

## 2. Scope
This documents specifies way of informing XMPP server to NOT publish push notifications for stanzas sent from jids not added to the roster.  This rule is an extension to the payload send to enable push notifications as specified in [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html).

## 3.  Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

## 4. Filtering notifications from unknown senders
In may cases, users want to receive Push Notifications only from the senders with which they have exchanged messages before. In most cases, this means receiving push notifications from senders which are already in the users roster.

### 4.1. Discovering support
Before enabling this feature, a client SHOULD determine whether user's server supports filtering push notifications based on sender being part of a user's roster; to do so, it MUST send a  [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html)  [2] information query to the user's bare JID:

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
    <feature var='tigase:push:filter:ignore-unknown:0'/>
    ...
  </query>
</iq>
````

### 4.2. Enabling filter
To enable this filter, XMPP client SHOULD send enable request with  `<ignore-unknown />` element qualified by `tigase:push:filter:ignore-unknown:0` namespace:

**Example 3.** Enabling filter
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo'>
    <ignore-unknown xmlns='tigase:push:filter:ignore-unknown:0'/>
  </enable>
</iq>
````
