---
layout: default
title: Muting notifications from contact
has_children: false
parent: Filters
nav_order: 2
grand_parent: Push Notifications
---

# Muting notifications from contact
{: .no_toc }
**Abstract:** This specification defines XMPP protocol extension allowing XMPP clients to specify JIDs for which the XMPP server SHOULD NOT generate Push Notifications.

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}
---

## 1. Introduction
[XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) defines a way for the XMPP server to generate push notifications by publishing them to the application specific XMPP Push Notification Component. However, that extension does not specify any rules for generating push notifications, nor any rules for filtering them forcing XMPP servers to publish notifications about any incoming messages while XMPP client is not connected.

This extension was created to provide a way to inform the XMPP server that it SHOULD not generate push notifications for particular JIDs.

## 2. Scope
This documents specifies ways of defining rule for filtering generated push notifications by skipping push notifications from particular JIDs. This rule is an extension to payload send to enable push notifications as specified in [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html).

## 3.  Requirements
The XMPP server MUST support [XEP-0357: Push Notifications](https://xmpp.org/extensions/xep-0357.html) as this specification is the extension to push notifications.

## 4. Mute notifications
In some cases users want not to receive notifications from particular sender, ie. from some bots sending them unimportant messages.

## 4.1. Discovering support
Before enabling this feature, a client SHOULD determine whether user's server supports filtering push notifications based on the list of muted conversations; to do so, it MUST send a  [Service Discovery (XEP-0030)](https://xmpp.org/extensions/xep-0030.html)  [2] information query to the user's bare JID:

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
    <feature var='tigase:push:filter:muted:0'/>
    ...
  </query>
</iq>
````

### 4.2. Enabling filter
To enable this filter, XMPP client SHOULD send enable request with `<muted />` element qualified by the `tigase:push:filter:muted:0` namespace.

This element SHOULD contains list of `<item />`  elements which should have `jid` attribute set to the bare JID for which push notifications SHOULD NOT be generated.

**Example 3.** Enabling filter
````xml
<iq type='set' id='x42'>
  <enable xmlns='urn:xmpp:push:0' jid='push-5.client.example'
    node='yxs32uqsflafdk3iuqo'>
    <muted xmlns='tigase:push:filter:muted:0'>
      <item jid='romeo@example.com' />
      <item jid='romeo@montague.net' />
    </muted>
  </enable>
</iq>
````
